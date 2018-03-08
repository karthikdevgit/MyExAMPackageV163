global with sharing class PublicAssessmentCreationController {

    global class AssessibleObjectAndTemplateClass {
        global List<AssessibleObjectDetails> assessibleObjs { get; set; }
        global List<AssessmentTemplateDetails> assessmentTemplates { get; set; }
        global Map<string, string> agjAssessibleObjectApiNameMap { get; set; }
        global Map<string, string> paAssessibleObjectApiNameMap { get; set; }
        global string exceptMsg;
    }
    global class AssessibleObjectDetails {
        global string objApiName { get; set; }
        global string objLabel { get; set; }
        global AssessibleObjectDetails(string apiName, string label) {
            this.objApiName = apiName;
            this.objLabel = label;
        }
    }
    global class AssessmentTemplateDetails {
        global string recId { get; set; }
        global string templateName { get; set; }
        
        global AssessmentTemplateDetails(string recordId, string templateNameStr) {
            this.recId = recordId;
            this.templateName = templateNameStr;
        }
    }
    global class AssessmentGroupDetailsClass {
        global string exceptMsg;
        global List<AssessmentGroupDetails> assGrpDtlList;
    }
    global class AssessmentGroupDetails {
        global string objApiName { get; set; }
        global string objLabel { get; set; }
        global AssessmentGroupDetails(string apiName, string label) {
            this.objApiName = apiName;
            this.objLabel = label;
        }
    }
    global class SuccessClass {
        global string code { get; set; }
        global string msg { get; set; }
        global SuccessClass(string sCode, string sMsg) {
            this.code = sCode;
            this.msg = sMsg; 
        }
    }
    global class ErrorClass {
        global string errType { get; set; }
        global string errMsg { get; set; }
        global ErrorClass(string etype, string eMsg) {
            this.errType = etype;
            this.errMsg = eMsg; 
        }
    }

    public class AssessmentTemplate {
        public Main_questionaire__c template { get; set; }
    }

    global PublicAssessmentCreationController() {
    }

    global class AFMWrapper{
        public String selectedObj;
        public String templateId;
    }
    
    global class FieldMappingWrapper {
        public boolean isEnableFMConfig;
        public Set<String> requiredFieldsSet;
        public List<Assessable_Fields_Mapping__c> afmList;
    }
    
    @RemoteAction
    global static AssessibleObjectAndTemplateClass getAssessibleObjectAndTemplates() {
        try {
        Map<string, string> agjAssessibleObjectApiNameMap = new Map<string, string>();
        Map<string, string> paAssessibleObjectApiNameMap = new Map<string, string>();
        List<AssessibleObjectDetails> assessibleObjsList = new List<AssessibleObjectDetails>();
        List<AssessmentTemplateDetails> templateList = new List<AssessmentTemplateDetails>();
        
        assessibleObjsList.add( new AssessibleObjectDetails('', '--None--') );
        templateList.add( new AssessmentTemplateDetails('', '--None--') );

        string agjFieldPrefix = 'AGJ_';
        ExAMUtilClass.AssessableObjectDetails objectDetailsForAGJ = ExAMUtilClass.getAssessableObjectDetails('ExAM__Assessment_Group_Junction__c');
        if (objectDetailsForAGJ != null && objectDetailsForAGJ.assessableObjectAPIMap != null && objectDetailsForAGJ.assessableObjectAPIMap.size() > 0) {
            for(string objectApiNameInAGJ : objectDetailsForAGJ.assessableObjectAPIMap.keySet()) {

                string objectApiName = objectDetailsForAGJ.assessableObjectAPIMap.get(objectApiNameInAGJ);
                string objectLabel = objectDetailsForAGJ.objectAPIAndLabelMap.get(objectApiName);

                assessibleObjsList.add( new AssessibleObjectDetails(objectApiName, objectLabel) );
                agjAssessibleObjectApiNameMap.put(objectApiName, objectApiNameInAGJ);
            }
        }

        SFDCAccessController accessForAT = ExAMUtilClass.AccessController;
        List<string> fieldsListAT = new List<string>{'ExAM__Template_name__c'};
        accessForAT.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Main_questionaire__c'), fieldsListAT);
        
        for (Main_questionaire__c templateRec : [SELECT Id, Name, One_Time_Assessment__c, Template_Name__c FROM Main_questionaire__c LIMIT 1000]) {

            string templateNameStr = templateRec.Name+' ('+templateRec.Template_Name__c+')';

            AssessmentTemplate at = new AssessmentTemplate();
            at.template = templateRec;
            templateNameStr = Json.serialize( at );

            templateList.add( new AssessmentTemplateDetails(templateRec.Id, templateNameStr) );
        }
        
        string paFieldPrefix = 'PA_';
        ExAMUtilClass.AssessableObjectDetails objectDetailsForPA = ExAMUtilClass.getAssessableObjectDetails('ExAM__Public_Assessment__c');
        if (objectDetailsForPA != null && objectDetailsForPA.assessableObjectAPIMap != null && objectDetailsForPA.assessableObjectAPIMap.size() > 0) {
            for(string objectApiNameInPA : objectDetailsForPA.assessableObjectAPIMap.keySet()) {

                string objectApiName = objectDetailsForPA.assessableObjectAPIMap.get(objectApiNameInPA);
                paAssessibleObjectApiNameMap.put(objectApiName, objectApiNameInPA);
            }
        }

        AssessibleObjectAndTemplateClass objAndTemplateClassInstance = new AssessibleObjectAndTemplateClass();
        objAndTemplateClassInstance.assessibleObjs = assessibleObjsList;
        objAndTemplateClassInstance.assessmentTemplates = templateList;
        objAndTemplateClassInstance.agjAssessibleObjectApiNameMap = agjAssessibleObjectApiNameMap;
        objAndTemplateClassInstance.paAssessibleObjectApiNameMap = paAssessibleObjectApiNameMap;
        objAndTemplateClassInstance.exceptMsg = '';
        return objAndTemplateClassInstance;
        } catch (Exception e){
            AssessibleObjectAndTemplateClass objAndTemplateClassInstance = new AssessibleObjectAndTemplateClass();
            objAndTemplateClassInstance.assessibleObjs = new List<AssessibleObjectDetails>();
            objAndTemplateClassInstance.assessmentTemplates = new List<AssessmentTemplateDetails>();
            objAndTemplateClassInstance.agjAssessibleObjectApiNameMap = new Map<string, string>();
            objAndTemplateClassInstance.paAssessibleObjectApiNameMap = new Map<string, string>();
            objAndTemplateClassInstance.exceptMsg = e.getMessage();
            return objAndTemplateClassInstance;
        }
    }
    
    @RemoteAction
    global static String getAssessableFieldMapping(AFMWrapper afmObject) {
        List<Assessable_Fields_Mapping__c> fmList;
        List<ExAM_Configuration__c> examConfigList;
        String returnMsg = '';
        
        try{
            AFMWrapper afmobj = new AFMWrapper();
            FieldMappingWrapper fmObj = new FieldMappingWrapper();
            Set<String> requiredFieldsSet = new Set<String>();
            Set<String> availableFieldsSet = new Set<String>();
            
            afmobj = afmObject;
            SFDCAccessController accessForAFM = ExAMUtilClass.AccessController;
            List<string> examConfigFieldList = new List<string>{'ExAM__Is_Field_Mapping__c'};
            accessForAFM.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__ExAM_Configuration__c'), examConfigFieldList);
            List<string> fieldsListview = new List<string>{'ExAM__Assessment_Template__c', 'ExAM__Assessable_Object_API__c', 'ExAM__Mapped_From__c'};
            accessForAFM.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Assessable_Fields_Mapping__c'), fieldsListview);
            fmList = new List<Assessable_Fields_Mapping__c>();
            examConfigList = new List<ExAM_Configuration__c>();
            
            examConfigList = [SELECT Id, Is_Field_Mapping__c FROM ExAM_Configuration__c LIMIT 1];
            fmList = [SELECT Assessment_Template__c, Assessable_Object_API__c, Mapped_From__c, Id, Assessable_Object_Field_API__c FROM Assessable_Fields_Mapping__c WHERE Assessment_Template__c = :afmobj.templateId AND Assessable_Object_API__c = :afmobj.selectedObj ];
            for( Assessable_Fields_Mapping__c afm :fmList){
                availableFieldsSet.add(afm.Assessable_Object_Field_API__c);
            }
            Map<String, Schema.SObjectField> fldMap = Schema.getGlobalDescribe().get(afmobj.selectedObj).getDescribe().fields.getMap();
            for(Schema.SObjectField f : fldMap.values()) {
                Schema.DescribeFieldResult desribeResult = f.getDescribe();
                if ( !desribeResult.isNillable() && !desribeResult.isDefaultedOnCreate()
                     && desribeResult.isCreateable() && desribeResult.isUpdateable() 
                     &&  !(desribeResult.getType() == Schema.DisplayType.REFERENCE) ) {
                    if(!availableFieldsSet.contains(desribeResult.getName())){
                        requiredFieldsSet.add(desribeResult.getName());
                    }
                }
            }
            if(examConfigList.size() > 0) {
                fmObj.isEnableFMConfig = examConfigList[0].Is_Field_Mapping__c;
            } else {
                fmObj.isEnableFMConfig = false;
            }
            fmObj.requiredFieldsSet = requiredFieldsSet;
            fmObj.afmList = fmList;
            returnMsg = JSON.serialize(fmObj);
        } catch(Exception e){
            returnMsg = JSON.serialize( new ErrorClass('Error', e.getMessage()) );
        }
        return returnMsg;
    }
    
    @RemoteAction
    global static List<AssessmentGroupDetails> onAssessibleObjectChange(string selectedObj) {
        List<AssessmentGroupDetails> grpDtlsList;
        try {
            grpDtlsList = new List<AssessmentGroupDetails>();
            grpDtlsList.add( new AssessmentGroupDetails('', '--None--') );
    
            SFDCAccessController accessForAT = ExAMUtilClass.AccessController;
            List<string> fieldsListAT = new List<string>{'ExAM__Type__c'};
            accessForAT.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Assessment_Group__c'), fieldsListAT);
            
            for (Assessment_Group__c ag : [SELECT Id, Name, Type__c FROM Assessment_Group__c WHERE Type__c = :selectedObj]) {

                grpDtlsList.add( new AssessmentGroupDetails(ag.Id, ag.Name) );
            }
            
        } catch( Exception e ){
            grpDtlsList = new List<AssessmentGroupDetails>();
            grpDtlsList.add( new AssessmentGroupDetails('Error', e.getMessage()) );
         
        }
        return grpDtlsList;
    }

    @RemoteAction
    global static string createPublicAssessments(string selectedObj, string createPAForWhichEntity, string selectedTemplate, string expDateStr, Map<string, string> agjAssessibleObjectApiNameMap, Map<string, string> paAssessibleObjectApiNameMap) {

        List<SObject> paList = new List<SObject>();
        List<SObject> assessmentGrpJunctionRecords = new List<SObject>();
        Set<string> assessibleObjIdTemplateIdSet = new Set<string>();
        Set<string> assessibleObjAPITemplateIdSet = new Set<string>();
        string PA_CreationResponseMsg = '';
        string selectedGroup = '';
        string selectedRecordId = '';
        Date expDate;

        try {

            if (string.isNotBlank(selectedObj)
                && agjAssessibleObjectApiNameMap.containsKey(selectedObj) && agjAssessibleObjectApiNameMap.get(selectedObj) != null
                && paAssessibleObjectApiNameMap.containsKey(selectedObj) && paAssessibleObjectApiNameMap.get(selectedObj) != null
            ) {

                if (string.isNotBlank(createPAForWhichEntity)) {

                    List<string> entityList = createPAForWhichEntity.split('@@');
                    if (!entityList.isEmpty() ) {
                        if (entityList[0] == 'AssessmentGroup') {
                            selectedGroup = entityList[1];
                        }
                        else if (entityList[0] == 'AssessableRecord') {
                            selectedRecordId = entityList[1];
                        }
                    }
                }
                if (string.isNotBlank(expDateStr) && expDateStr.contains('/')) {
                    expDate = date.parse(expDateStr);
                }

                string agjParentObjectIdApi = agjAssessibleObjectApiNameMap.get(selectedObj);
                string paParentObjectIdApi = paAssessibleObjectApiNameMap.get(selectedObj);

                SFDCAccessController accessForAT = ExAMUtilClass.AccessController;
                List<string> fieldsListAT = new List<string>{'ExAM__Assessible_Object_ID__c','ExAM__Assessment_Template__c'};
                accessForAT.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Public_Assessment__c'), fieldsListAT);
                
                string paQueryStr = 'SELECT ExAM__Assessable_Object_API__c, ExAM__Assessible_Object_ID__c, ExAM__Assessment_Template__c, Id, Name, '+paParentObjectIdApi;
                paQueryStr += ' FROM ExAM__Public_Assessment__c';
                if (string.isNotBlank(selectedTemplate) && (string.isNotBlank(selectedRecordId) || string.isNotBlank(selectedGroup))) {
                    paQueryStr += ' WHERE ' + paParentObjectIdApi + ' != NULL';
                }
                else if (string.isNotBlank(selectedTemplate) && string.isBlank(selectedRecordId) && string.isBlank(selectedGroup)) {
                    paQueryStr += ' WHERE Assessable_Object_API__c != NULL';
                }

                List<Public_Assessment__c> pa_QueriedList = new List<Public_Assessment__c>();
                pa_QueriedList = Database.query(paQueryStr);

                for (Public_Assessment__c pa : pa_QueriedList) {

                    string uniqueStr = pa.Assessible_Object_ID__c+pa.Assessment_Template__c;
                    assessibleObjIdTemplateIdSet.add(uniqueStr);
                    if (string.isNotBlank(pa.Assessable_Object_API__c)) {
                        string apiNameTemplateIdUniqueStr = pa.Assessable_Object_API__c+pa.Assessment_Template__c;
                        assessibleObjAPITemplateIdSet.add( apiNameTemplateIdUniqueStr );
                    }
                }
                    
                if (string.isNotBlank(selectedRecordId)
                    || (string.isBlank(selectedRecordId) && string.isBlank(selectedGroup))
                ) {

                    string uniqueStr = (string.isNotBlank(selectedRecordId)) ? selectedRecordId+selectedTemplate : selectedObj+selectedTemplate;

                    if ( (string.isNotBlank(selectedRecordId) && !assessibleObjIdTemplateIdSet.contains(uniqueStr))
                         || (string.isBlank(selectedRecordId) && !assessibleObjAPITemplateIdSet.contains(uniqueStr))
                    ) {

                        //Create Public Assessment record for each unique assessment group junction record
                        SObject pa = Schema.getGlobalDescribe().get('exam__Public_Assessment__c').newSObject() ;
                        if ( string.isNotBlank(selectedRecordId) ) {
                            pa.put(paParentObjectIdApi, selectedRecordId);
                            pa.put('ExAM__Assessible_Object_ID__c', selectedRecordId);
                        }
                        else {
                            pa.put('ExAM__Assessable_Object_API__c', selectedObj);
                        }
                        pa.put('ExAM__Assessment_Template__c', selectedTemplate);
                        pa.put('ExAM__Expiration_Date__c', expDate);
                        paList.add( pa );
                    }
                    if (paList != null && paList.size() > 0 ) {
                        
                        SFDCAccessController accessPA1 = ExAMUtilClass.AccessController;
                        List<string> fieldsPA1 = new List<string>{'ExAM__Assessment_Template__c', 'ExAM__Expiration_Date__c'};
                        if (string.isNotBlank(selectedRecordId)) {
                            fieldsPA1.add( 'ExAM__Assessible_Object_ID__c' );
                            fieldsPA1.add( paParentObjectIdApi );
                        }
                        else {
                            fieldsPA1.add( 'ExAM__Assessable_Object_API__c' );
                        }
                        accessPA1.assertAuthorizedToCreate(Schema.getGlobalDescribe().get('exam__Public_Assessment__c'), fieldsPA1);

                        insert paList;
                        PA_CreationResponseMsg = JSON.serialize( new SuccessClass('success', 'Public Assessment record created successfully') );
                        
                    } else {
                        if (string.isNotBlank(selectedRecordId)) {
                            PA_CreationResponseMsg = JSON.serialize( new ErrorClass('RecordAlreadyExists', 'Public Assessments already created for this combination of Assessable record and Assessment template'));
                        }
                        else {
                            PA_CreationResponseMsg = JSON.serialize( new ErrorClass('RecordAlreadyExists', 'Public Assessments already created for this combination of Assessable object and Assessment template'));
                        }
                    }
                }
                else if (string.isNotBlank(selectedGroup) ) {
                    SFDCAccessController accessForSSInsert1 = ExAMUtilClass.AccessController;
                    List<string> fieldsListview = new List<string>{'ExAM__Assessment_Group__c'};
                    accessForSSInsert1.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Assessment_Group_Junction__c'), fieldsListview);
                    
                    string agjQueryStr = 'SELECT Assessment_Group__c, Id, Name, '+agjParentObjectIdApi;
                    agjQueryStr += ' FROM Assessment_Group_Junction__c';
                    agjQueryStr += ' WHERE Assessment_Group__c = \''+selectedGroup+'\' AND '+agjAssessibleObjectApiNameMap.get(selectedObj)+' != NULL';

                    List<SObject> agjList = new List<SObject>();
                    agjList = Database.query(agjQueryStr);
                    
                    if(agjList.size() > 0) {
                        for (SObject s : agjList) {

                            string uniqueStr = s.get(agjParentObjectIdApi)+selectedTemplate;

                            if (!assessibleObjIdTemplateIdSet.contains(uniqueStr)) {

                                //Create Public Assessment record for each unique assessment group junction record
                                SObject pa = Schema.getGlobalDescribe().get('exam__Public_Assessment__c').newSObject() ;
                                pa.put(paParentObjectIdApi, (Id)s.get(agjParentObjectIdApi));
                                pa.put('ExAM__Assessible_Object_ID__c', (Id)s.get(agjParentObjectIdApi));
                                pa.put('ExAM__Assessment_Template__c', selectedTemplate);
                                pa.put('ExAM__Expiration_Date__c', expDate);
                                paList.add( pa );
                            }
                        }
                        if (paList != null && paList.size() > 0 ) {
                            
                            SFDCAccessController accessPA2 = ExAMUtilClass.AccessController;
                            List<string> fieldsPA2 = new List<string>{'ExAM__Assessible_Object_ID__c', 'ExAM__Assessment_Template__c', 'ExAM__Expiration_Date__c'};
                            fieldsPA2.add( paParentObjectIdApi );
                            accessPA2.assertAuthorizedToCreate(Schema.getGlobalDescribe().get('exam__Public_Assessment__c'), fieldsPA2);
                            
                            insert paList;
                            PA_CreationResponseMsg = JSON.serialize( new SuccessClass('success', 'Public Assessment records created successfully') );
                        }
                        else if (agjList != null && agjList.size() > 0 && paList.size() == 0) {
                            PA_CreationResponseMsg = JSON.serialize( new ErrorClass('RecordAlreadyExists', 'Public Assessments already created for this combination of Assessable object and Assessment template') );
                        }
                    } else {
                        PA_CreationResponseMsg = JSON.serialize( new ErrorClass('No records', 'The selected Assessment Group has no records.') );
                    }
                }
            }
        }
        catch(Exception exp) {
            if (exp.getTypeName() == 'System.DMLException') {
                PA_CreationResponseMsg = JSON.serialize( new ErrorClass(exp.getTypeName(), exp.getDMLMessage(0)) );
            }
            else {
                PA_CreationResponseMsg = JSON.serialize( new ErrorClass(exp.getTypeName(), exp.getMessage()) );
            }
        }
        return PA_CreationResponseMsg;
    }
}