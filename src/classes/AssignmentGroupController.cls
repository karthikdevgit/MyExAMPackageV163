global with sharing class AssignmentGroupController {

    public string selectedGroup { get; set; }
    public string selectedGroupId2 { get;set; }
    public string selectedObj{get;set;}
    public string selectrecBystring{get;set;}
    public string userId { get; set; }
    public string msgResult { get; set; }

    public Integer selectedRecords { get; set; }
    public Integer totalRecords { get; set; }

    //public Boolean isTempGroup { get; set; }
    public Boolean selectAllCheckbox {get; set;} 
    public Boolean errormsg{get;set;} 
    public Boolean displayboxes;
    public Boolean recurringEvent { get; set; }

    public List<string> idList;
    public List<SelectOption> groupOptions { get; set; }
    public List<SelectOption> ObjectGroup { get; set; }    
    public List<Sobject> selectedRecs { get; set; } 
    public List<innerCls> objList {get; set;} 

    public set<string> recstring{get;set;}

    public Map<string, string> objectNameAPIwithAMfieldNameAPIMap {get; set;}    

    public IssueRequest_Life_Cycle__c assMan{get;set;}
    public Assessment_Group__c assGroup { get; set; }
    public Assessment_Event__c assEvent { get; set; }
    public Map<Id, Assessment_Group__c> assessmentGroupMap;
    
    ExAMUtilClass.AssessableObjectDetails objectDetail;
    Map<string, string> fieldsAPIMap;

    public AssignmentGroupController(){

        selectedGroup ='';
        selectedGroupId2 = '';
        selectedObj = '';
        userId = '';
        msgResult = '';

        selectedRecords = 0;
        totalRecords = 0;

        //isTempGroup = false;

        idList = new List<string>();
        groupOptions = new List<SelectOption>();
        ObjectGroup = new List<SelectOption>();
        selectedRecs = new List<Sobject>();

        assessmentGroupMap = new Map<Id, Assessment_Group__c>();

        objectNameAPIwithAMfieldNameAPIMap = new Map<string, string>();

        assMan = new IssueRequest_Life_Cycle__c();
        assGroup = new Assessment_Group__c();
        assEvent = new Assessment_Event__c();

        ObjectGroup.add(new selectOption('--None--','--None--'));
        groupOptions.add(new SelectOption('--None--','--None--'));

        objectDetail = ExAMUtilClass.getAssessableObjectDetails('ExAM__Assessment_Group_Junction__c');
        fieldsAPIMap = objectDetail.assessableObjectAPIMap;
        Map<string, string> fieldsLabelMap = objectDetail.assessableObjectLabelMap;

        for (string referenceFieldAPIInAM : fieldsAPIMap.keySet()) {

            string AssessableObjectAPIName = fieldsAPIMap.get(referenceFieldAPIInAM);
            string AssessableObjectLabel = fieldsLabelMap.get(referenceFieldAPIInAM);
            ObjectGroup.add(new SelectOption(AssessableObjectAPIName, AssessableObjectLabel));  
            objectNameAPIwithAMfieldNameAPIMap.put(AssessableObjectAPIName, referenceFieldAPIInAM);
        }    
        if (ObjectGroup != null && ObjectGroup.size() > 0) {
            ObjectGroup = AssessmentMapBuilderController.sortSelectOptionList(ObjectGroup);
        }
        if (ObjectGroup.size() == 0) {
            ObjectGroup.add(new SelectOption('--None--','--None--'));
        }
    }
    
    public PageReference saveAssessmentGroup() {

        ApexPages.Message myMsg;

        try {
            if (assGroup.name != null && assGroup.Name != '' && selectedObj != null && selectedObj != '') {

                SFDCAccessController accessAG = ExAMUtilClass.AccessController;
                List<String> fieldsListAG = new List<String>{'ExAM__Type__c'};
                accessAG.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Assessment_Group__c'), fieldsListAG);

                assGroup.type__c = selectedObj;
                List<Assessment_Group__c> assessmentGroupList = [SELECT Id, Name, Type__c FROM Assessment_Group__c WHERE Name =: assGroup.name AND Type__c != null AND Type__c != '' AND Type__c =:selectedObj];
                if( assessmentGroupList == null || assessmentGroupList.size() == 0 ) {

                    SFDCAccessController accessAGCreate = ExAMUtilClass.AccessController;
                    List<String> fieldsListAGCreate = new List<String>{'ExAM__Type__c'};
                    accessAGCreate.assertAuthorizedToCreate(Schema.getGlobalDescribe().get('exam__Assessment_Group__c'), fieldsListAGCreate);

                    insert assGroup;
                    groupOptions.add(new SelectOption(assGroup.Id,assGroup.Name));
                    groupOptions = AssessmentMapBuilderController.sortSelectOptionList(groupOptions);
                    selectedGroup = assGroup.Id;
                    myMsg = new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Assessment Group created successfully');
                } else {
                    selectedGroup = assessmentGroupList[0].id;
                    assGroup.name ='';
                }
                assGroup = new Assessment_Group__c();
            }
            else {
                myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Please make sure that you have selected a Assessable object and entered a name for new Assessment Group');
            }
        } catch( Exception e) {
            myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage());
        }
        if (myMsg != null) {
            ApexPages.addMessage( myMsg );
        }
        return null;
    }

    /*public PageReference updateSelectedGroup() {
        ApexPages.Message myMsg;
        try {
            if( selectedGroup != null && selectedGroup != '') {
                Assessment_Group__c assGroup = new Assessment_Group__c( Id = selectedGroup);
                update assGroup;
                myMsg = new ApexPages.Message(ApexPages.Severity.INFO,'Updated Assessment Group Record');      
            }        
        } catch(Exception e) {
            myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage());      
        }
        ApexPages.addMessage( myMsg );
        return null;
    }*/

    public class innerCls{
        public Sobject con {get; set;}
        public Boolean selected {get; set;}
        
        /*This is the contructor method. When we create a new innerCls object we pass a
        Sobject that is set to the con property. We also set the selected value to false*/
        public innerCls(Sobject c){
             con = c;
             selected = false;
        }
    }
    
    /* Method to fetch the selected records*/
    public void processSelected(){
        string idsVal = ApexPages.currentPage().getParameters().get('idsVal');
        string totalRec = ApexPages.currentPage().getParameters().get('totelRec');
        if( idsVal != null && idsVal !='') {
            idList = idsVal.split(',');
            selectedRecords = idList != null ? idList.size() : 0;
            totalRecords = totalRec != null && totalRec != '' ? Integer.valueOf(totalRec) : 0;
        }
        //return null;   
    }

    public PageReference saveSelectedRecords() {
        ApexPages.Message myMsg;
        try {
            List<Assessment_Group_Junction__c> insertAGJList = new List<Assessment_Group_Junction__c>(); 
            if( idList != null && idList.size() > 0 && selectedGroup != null && selectedGroup != '') {

                SFDCAccessController accessAGJCreate = ExAMUtilClass.AccessController;
                List<String> fieldsListAGJCreate = new List<String>{'ExAM__Assessment_Group__c'};

                for(string idVal : idList) {
                    Assessment_Group_Junction__c agj = new Assessment_Group_Junction__c();
                    if( objectNameAPIwithAMfieldNameAPIMap != null && objectNameAPIwithAMfieldNameAPIMap.containskey(selectedObj) ) {
                        agj.put(objectNameAPIwithAMfieldNameAPIMap.get(selectedObj), idVal);
                        agj.put('ExAM__Assessment_Group__c',selectedGroup);
                        insertAGJList.add( agj );

                        fieldsListAGJCreate.add(objectNameAPIwithAMfieldNameAPIMap.get(selectedObj) );
                    }
                }
                if (insertAGJList != null && insertAGJList.size() > 0 ) {

                    accessAGJCreate.assertAuthorizedToCreate(Schema.getGlobalDescribe().get('exam__Assessment_Group_Junction__c'), fieldsListAGJCreate);

                    insert insertAGJList;
                    myMsg = new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Record saved successfully');
                }
            } else if (idList != null && idList.size() > 0 ) {

                myMsg = new ApexPages.Message(ApexPages.Severity.INFO, 'Please select or create assessment group');
            } else {

                myMsg = new ApexPages.Message(ApexPages.Severity.INFO, 'Please select atleast one record');
            }
            /*
            if( selectedGroup != null && selectedGroup != '') {
                Assessment_Group__c assGroup = new Assessment_Group__c( Id = selectedGroup);
                update assGroup;
            }
            */       
        } catch(Exception e) {

            myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage());
        }
        ApexPages.addMessage( myMsg );
        return null;
    }    
    public PageReference insertAssignmentManager() {

        Savepoint sp = Database.setSavepoint();
        try {
            Map<string, string> agjcustomLkupFieldWithAMcustomLkupField = new Map<string, string>();
            List<IssueRequest_Life_Cycle__c> insertAssignmentManagerList = new List<IssueRequest_Life_Cycle__c>();

            //Assessment group junction query where group name            
            for (string referenceFieldAPIInAGJ : fieldsAPIMap.keySet()) {

                string referenceFieldAPIInAM = (referenceFieldAPIInAGJ.startsWithIgnoreCase('AGJ_')) ? referenceFieldAPIInAGJ.replaceFirst('AGJ_', 'AM_') : referenceFieldAPIInAGJ;
                agjcustomLkupFieldWithAMcustomLkupField.put(referenceFieldAPIInAGJ, referenceFieldAPIInAM);
            }
            string objType = '';
            if (string.isNotBlank(selectedGroupId2) && assessmentGroupMap.containsKey(selectedGroupId2) ) {
                objType = assessmentGroupMap.get(selectedGroupId2).Type__c;
                if (objType.startsWithIgnoreCase('ExAM__')) {
                    objType = objType.replace('ExAM__', 'AGJ_');
                }
                else if (objType == 'Account') {
                    objType = 'ExAM__Facility_Name__c';
                }
                else {
                    objType = 'AGJ_'+objType;
                }
            }

            SFDCAccessController accessAGJ = ExAMUtilClass.AccessController;
            List<String> fieldsListAGJ = new List<String>{'ExAM__Assessment_Group__c'};

            string agjQuery = 'SELECT Id, Name, ExAM__Assessment_Group__c';
            for (string agjfieldName : agjcustomLkupFieldWithAMcustomLkupField.keySet()) {
                agjQuery += ','+agjfieldName;
                if (objType == agjfieldName) {
                    fieldsListAGJ.add( agjfieldName );
                }
            }
            agjQuery += ' FROM ExAM__Assessment_Group_Junction__c WHERE ExAM__Assessment_Group__c =:selectedGroupId2';

            accessAGJ.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Assessment_Group_Junction__c'), fieldsListAGJ);

            List<Assessment_Group_Junction__c> assGroupJunctionList = Database.query(agjQuery);
            
            if( assEvent.Name != NULL && assEvent.Name != '') {

                SFDCAccessController accessAE = ExAMUtilClass.AccessController;
                List<String> fieldsListAE = new List<String>{'ExAM__Description__c', 'ExAM__Event_Date__c', 'ExAM__Event_Finish_Time__c', 'ExAM__Event_Start_Time__c'};
                accessAE.assertAuthorizedToCreate(Schema.getGlobalDescribe().get('exam__Assessment_Event__c'), fieldsListAE);

                upsert assEvent;
            }

            SFDCAccessController accessAMCreate = ExAMUtilClass.AccessController;
            List<String> fieldsListAMCreate = new List<String>{'ExAM__Assessment_Event__c', 'ExAM__Assessment_Group__c', 'ExAM__Assessor_Resource__c', 'ExAM__InvestigationType__c'};

            for (Assessment_Group_Junction__c agj : assGroupJunctionList) {
                
                IssueRequest_Life_Cycle__c am = new IssueRequest_Life_Cycle__c();
                for (string agjfieldName : agjcustomLkupFieldWithAMcustomLkupField.keySet()) {
                    if (agj.get(agjfieldName) != null) {

                        am.put(agjcustomLkupFieldWithAMcustomLkupField.get(agjfieldName), agj.get(agjfieldName));
                        fieldsListAMCreate.add( agjcustomLkupFieldWithAMcustomLkupField.get(agjfieldName) );
                    }
                }               
                if (selectedGroupId2 != '') {
                    am.put('ExAM__Assessment_Group__c', selectedGroupId2);
                }
                if( assEvent.Id != null ) {
                    am.put('ExAM__Assessment_Event__c', assEvent.Id);
                }
                am.put('ExAM__InvestigationType__c', assMan.InvestigationType__c);
                if (assMan.Assessor_Resource__c != NULL) {
                    am.put('ExAM__Assessor_Resource__c', assMan.Assessor_Resource__c);
                }         
                insertAssignmentManagerList.add( am );
            }
            if ( insertAssignmentManagerList != null && insertAssignmentManagerList.size() > 0 ) {

                accessAMCreate.assertAuthorizedToCreate(Schema.getGlobalDescribe().get('exam__IssueRequest_Life_Cycle__c'), fieldsListAMCreate);

                insert insertAssignmentManagerList;                
                assMan = new IssueRequest_Life_Cycle__c();
                msgResult = 'Assignment manager record created successfully';
            } else {
                msgResult = 'No record found in this group';
                Database.rollback(sp);
            }
        } catch(Exception e) {
            Database.rollback(sp);
            msgResult = ''+e.getMessage();
        }
        return null;
    }
    
    public void refreshFn(){
            
        selectedObj = selectedObj ;
    }

    @RemoteAction
    global static string getRecords(string selectedObj, string selectrecBystring, string SelectedGrp, string objectapiwithfieldAPIMap) { //Map<string, string> objectNameAPIwithAMfieldNameAPIMap1) {

        try {

            Set<Id> existingSelectedIdSet = new Set<Id>();
            //objectNameAPIwithAMfieldNameAPIMap = new Map<string, string>();
            Map<string, string> objectNameAPIwithAMfieldNameAPIMap1 = new Map<string, string>();
            if( objectapiwithfieldAPIMap != null && objectapiwithfieldAPIMap != '') {
                objectapiwithfieldAPIMap = objectapiwithfieldAPIMap.removeStart('{');
                objectapiwithfieldAPIMap = objectapiwithfieldAPIMap.removeEnd('}');
                List<string> keyValuesList = objectapiwithfieldAPIMap.split(',');
                
                for( string keyValue : keyValuesList ) {
                    keyValue = keyValue.trim();
                    List<string> keyandValue = keyValue.split('=');
                    if( keyandValue != null && keyandValue.size() == 2) {
                        objectNameAPIwithAMfieldNameAPIMap1.put(keyandValue[0],keyandValue[1]); 
                    }               
                }
            }
        
            if (!string.isBlank(selectedObj)) {
                if (objectNameAPIwithAMfieldNameAPIMap1 != null && objectNameAPIwithAMfieldNameAPIMap1.containsKey(selectedObj)) {

                    SFDCAccessController accessAGJ = ExAMUtilClass.AccessController;
                    List<String> fieldsListAGJ = new List<String>{'ExAM__Assessment_Group__c'};
                    fieldsListAGJ.add( objectNameAPIwithAMfieldNameAPIMap1.get(selectedObj) );

                    string existAGJQuery = 'SELECT Id, ExAM__Assessment_Group__c, '+objectNameAPIwithAMfieldNameAPIMap1.get(selectedObj)+' FROM ExAM__Assessment_Group_Junction__c ';
                    existAGJQuery += 'WHERE '+objectNameAPIwithAMfieldNameAPIMap1.get(selectedObj)+' != NULL AND ExAM__Assessment_Group__c =:SelectedGrp';//\'a2Tm0000000DQtV\'';//

                    accessAGJ.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Assessment_Group_Junction__c'), fieldsListAGJ);

                    List<Assessment_Group_Junction__c> existAGJList = Database.query(existAGJQuery);
                    for (Assessment_Group_Junction__c agj : existAGJList) {
                        string fieldAPIName = objectNameAPIwithAMfieldNameAPIMap1.get(selectedObj);
                        existingSelectedIdSet.add(string.ValueOf(agj.get(fieldAPIName)));
                    }
                }
                string qry = '';
                if (selectedObj.equalsIgnoreCase('Case')) {
                    qry = 'select Id,CaseNumber FROM '+selectedObj;
                } else {
                    qry = 'SELECT Id,Name FROM '+selectedObj;
                }
                string nameS = selectrecBystring +'%';
            
                if(!string.isBlank(selectrecBystring ) && selectrecBystring.toUpperCase() != 'ALL' && selectrecBystring.toUpperCase() != '#' && !selectedObj.equalsIgnoreCase('Case') ){
                    qry += ' WHERE Name like :nameS' ;
                    if (existingSelectedIdSet != null && existingSelectedIdSet.size() > 0 ) {
                        qry += ' AND ID NOT IN :existingSelectedIdSet';
                    }
                }
                else if (!string.isBlank(selectrecBystring ) && selectrecBystring == '#' && !selectedObj.equalsIgnoreCase('Case')  ){
                    qry += ' WHERE ( Name LIKE \'1%\' OR Name LIKE \'2%\' OR Name LIKE \'3%\' OR Name LIKE \'4%\' OR Name LIKE \'5%\' OR Name LIKE \'6%\' OR Name LIKE \'7%\' OR Name LIKE \'8%\' OR Name LIKE \'9%\' OR Name LIKE \'0%\' ) ';
                    if (existingSelectedIdSet != null && existingSelectedIdSet.size() > 0 ) {
                        qry += ' AND ID NOT IN :existingSelectedIdSet';
                    }
                } else if(!string.isBlank(selectrecBystring ) && selectrecBystring.toUpperCase() != 'ALL' && selectrecBystring.toUpperCase() != '#' && selectedObj.equalsIgnoreCase('Case') ){
                    qry += ' WHERE CaseNumber like :nameS' ;
                    if (existingSelectedIdSet != null && existingSelectedIdSet.size() > 0 ) {
                        qry += ' AND ID NOT IN :existingSelectedIdSet';
                    }
                } else if (!string.isBlank(selectrecBystring ) && selectrecBystring == '#' && selectedObj.equalsIgnoreCase('Case')  ){
                    qry += ' WHERE ( CaseNumber LIKE \'1%\' OR CaseNumber LIKE \'2%\' OR CaseNumber LIKE \'3%\' OR CaseNumber LIKE \'4%\' OR CaseNumber LIKE \'5%\' OR CaseNumber LIKE \'6%\' OR CaseNumber LIKE \'7%\' OR CaseNumber LIKE \'8%\' OR CaseNumber LIKE \'9%\' OR CaseNumber LIKE \'0%\' ) ';
                    if (existingSelectedIdSet != null && existingSelectedIdSet.size() > 0 ) {
                        qry += ' AND ID NOT IN :existingSelectedIdSet';
                    }
                } else if (!string.isBlank(selectrecBystring ) && selectrecBystring.toUpperCase() == 'ALL') {
                    qry += ' WHERE ID != NULL';
                    if (existingSelectedIdSet != null && existingSelectedIdSet.size() > 0 ) {
                        qry += ' AND ID NOT IN :existingSelectedIdSet';
                    }
                }
                if( selectedObj.equalsIgnoreCase('User')) { 
                    qry += ' AND IsActive = true';
                }
                if (!selectedObj.equalsIgnoreCase('Case')) {   
                    qry += ' ORDER BY Name ASC LIMIT 9000';
                } else {
                    qry += ' ORDER BY CaseNumber ASC LIMIT 9000';
                }
            
                List<Sobject> qryObjList = new List<Sobject>();
                qryObjList = Database.query(qry);
                string jsonstring = JSON.serialize(qryObjList);
                return jsonstring;
            }
            //List<Account> accountList = [SELECT id, name FROM Account where name LIKE:listStr+'%'];
            //string jsonstring = JSON.serialize(accountList);
        } catch( Exception e) {
           return JSON.serialize(e.getMessage());
        }
        return null;
    }    
    
    public PageReference changeObject() {

        try {

            assessmentGroupMap = new Map<Id, Assessment_Group__c>();

            groupOptions = new List<SelectOption>();
            groupOptions.add( new SelectOption('--None--', '--None--') );

            string objectName = Apexpages.currentPage().getParameters().get('selectedObjectAPIName');
            if (objectName != null && objectName != '' && objectName != 'null') {

                SFDCAccessController accessAG = ExAMUtilClass.AccessController;
                List<String> fieldsListAG = new List<String>{'ExAM__Type__c'};
                accessAG.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Assessment_Group__c'), fieldsListAG);

                for ( Assessment_Group__c assGp : [ SELECT Id, Name, Type__c FROM Assessment_Group__c WHERE Type__c =: selectedObj ORDER BY CreatedDate DESC LIMIT 1000]) {
                    groupOptions.add(new SelectOption(assGp.Id,assGp.Name));
                    groupOptions = AssessmentMapBuilderController.sortSelectOptionList(groupOptions);
                    assessmentGroupMap.put(assGp.Id, assGp);
                }
            }
            if( groupOptions != null && groupOptions.size() == 0 ) {
                groupOptions.add(new SelectOption('--None--','--None--'));
            }
        } catch(Exception e) {

            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()) );
        }
        return null;
    }
    
    @RemoteAction
    global static List<assessmentGroupJunctionClass> getCreatedRecords(string selectedObj, string SelectedGrp, string objectapiwithfieldAPIMap) {
        List<Assessment_Group_Junction__c> existAGJList = new List<Assessment_Group_Junction__c>();
        List<assessmentGroupJunctionClass> resultList = new List<assessmentGroupJunctionClass>();
        try{
            Set<Id> existingSelectedIdSet = new Set<Id>();
            //objectNameAPIwithAMfieldNameAPIMap = new Map<string, string>();
            Map<string, string> objectNameAPIwithAMfieldNameAPIMap1 = new Map<string, string>();
            if( objectapiwithfieldAPIMap != null && objectapiwithfieldAPIMap != '') {
                objectapiwithfieldAPIMap = objectapiwithfieldAPIMap.removeStart('{');
                objectapiwithfieldAPIMap = objectapiwithfieldAPIMap.removeEnd('}');
                List<string> keyValuesList = objectapiwithfieldAPIMap.split(',');
                for( string keyValue : keyValuesList ) {
                    keyValue = keyValue.trim();
                    List<string> keyandValue = keyValue.split('=');
                    if( keyandValue != null && keyandValue.size() == 2) {
                        objectNameAPIwithAMfieldNameAPIMap1.put(keyandValue[0],keyandValue[1]); 
                    }               
                }
            }
            
            if (!string.isBlank(selectedObj)) {
                if (objectNameAPIwithAMfieldNameAPIMap1 != null && objectNameAPIwithAMfieldNameAPIMap1.containsKey(selectedObj)) {
                    string fieldAPIName = objectNameAPIwithAMfieldNameAPIMap1.get(selectedObj);
                    string fieldRelatedObjectName = '';
                    if (fieldAPIName.endsWithIgnoreCase('__c')) {
                        fieldRelatedObjectName = fieldAPIName.substring(0,fieldAPIName.length()-1) +'r';
                    }
                    SFDCAccessController accessAGJ = ExAMUtilClass.AccessController;
                    List<String> fieldsListAGJ = new List<String>{'ExAM__Assessment_Group__c'};
                    fieldsListAGJ.add( fieldAPIName );
                    string existAGJQuery = 'SELECT Id, Name, ExAM__Assessment_Group__c,  ExAM__Assessment_Group__r.Name, '+fieldAPIName;
                    if (fieldRelatedObjectName != '') {
                        if (!selectedObj.equalsIgnoreCase('Case')) {
                            existAGJQuery += ', '+fieldRelatedObjectName+'.Name';
                        } else {
                            existAGJQuery += ', '+fieldRelatedObjectName+'.CaseNumber'; 
                        } 
                    }
                    existAGJQuery += ' FROM ExAM__Assessment_Group_Junction__c ';
                    existAGJQuery += 'WHERE '+objectNameAPIwithAMfieldNameAPIMap1.get(selectedObj)+' != NULL AND ExAM__Assessment_Group__c =:SelectedGrp';//\'a2Tm0000000DQtV\'';//
                    if (fieldRelatedObjectName != '') {
                        if (!selectedObj.equalsIgnoreCase('Case')) {
                            existAGJQuery += ' ORDER BY '+fieldRelatedObjectName+'.Name ASC';
                        } else {
                            existAGJQuery += ' ORDER BY '+fieldRelatedObjectName+'.CaseNumber ASC'; 
                        } 
                    }
                    accessAGJ.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Assessment_Group_Junction__c'), fieldsListAGJ);
    
                    existAGJList = Database.query(existAGJQuery);
                    for (Assessment_Group_Junction__c agj : existAGJList) {
                        assessmentGroupJunctionClass agjcls = new assessmentGroupJunctionClass();
                        agjcls.agjName = agj.Name;
                        agjcls.agjId = agj.Id;
                        
                        
                        agjcls.assessableObjectFieldIdValue = string.ValueOf(agj.get(fieldAPIName));
                        if (fieldRelatedObjectName != '') {
                            //SObject assessmentObj = agj.getSObject(fieldAPIName);
                            string name = '';
                            if(!selectedObj.equalsIgnoreCase('Case')) {
                                name = (string) agj.getSobject(fieldRelatedObjectName).get('Name');   
                            } else {
                                name = (string) agj.getSobject(fieldRelatedObjectName).get('CaseNumber');   
                            }
                            agjcls.assessableObjectFieldNameValue = name;
                        }
                        agjcls.assessmentGroupName = agj.Assessment_Group__r.name;
                        agjcls.assessmentGroupId = agj.Assessment_Group__c;
                        resultList.add(agjcls);                    
                        existingSelectedIdSet.add(string.ValueOf(agj.get(fieldAPIName)));
                    }
                }
            }
        } catch(Exception e){
            assessmentGroupJunctionClass agjcls = new assessmentGroupJunctionClass();
            agjcls.agjName = e.getMessage();
            agjcls.agjId = 'error';
            resultList.add(agjcls);
        }
        return resultList;
    }
    @RemoteAction 
    global static void deleteAssessmentJunctionRecord(string assGrpJunId) {
        try {

            SFDCAccessController accessForobj = ExAMUtilClass.AccessController;
            if (accessForobj.isAuthorizedToDelete(Assessment_Group_Junction__c.sObjectType)) {
                Assessment_Group_Junction__c delAGJ = new Assessment_Group_Junction__c (id = Id.valueOf(assGrpJunId));
                delete delAGJ;
            }
            else {
                throw new CustomException('You do not have access to delete Assessment Group Junction', null);
            }
        }
        catch(Exception ex) {
            throw new CustomException(ex.getMessage(), null);
        }
    }

    global class assessmentGroupJunctionClass {
        public string agjName ;
        public string agjId;
        public string assessableObjectFieldIdValue;
        public string assessableObjectFieldNameValue;
        public string assessmentGroupName;
        public string assessmentGroupId;
        public Boolean Is_convered_to_Assignment_Manager;
    }
    
    public PageReference saveRecordwithUploadAssessment() {

        string assessmentRecordStr = apexPages.currentPage().getParameters().get('attBlob');
        Blob csvFile = EncodingUtil.base64Decode(assessmentRecordStr );
        List<List<string>> assessmentResult = AssignmentGroupController.parseCSV(csvFile.tostring(),false);
        Set<string> headerSet = new Set<string>();
        Map<Integer, string> header = new Map<Integer, string>();
        ApexPages.Message myMsg;
        try{
            if(assessmentResult != null) {
                
                csvFile = NULL;
               
                if ( assessmentResult.size() < 2 ){
    
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'File does not have data. Please upload a file with data or confirm if it is a valid csv file.'));            
                    return null;
                }
    
                if ( assessmentResult.size() > 0 ){
                   
                   for (Integer i = 0; i < (assessmentResult.get(0)).size(); i++ ){
                   
                       header.put(i, (assessmentResult.get(0)).get(i) );
                       if((assessmentResult.get(0)).get(i) != '') {
                           headerSet.add((assessmentResult.get(0)).get(i).toUpperCase().trim());
                       }
                   }
                }
                if(headerSet != null && headerSet.size() > 0 && !headerSet.contains('ID') ) {
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please upload a valid CSV file'));
                    return null;
                }
                Set<Id> assessableRecordIdSet = new Set<Id>();
                    
                if (objectNameAPIwithAMfieldNameAPIMap != null && objectNameAPIwithAMfieldNameAPIMap.containsKey(selectedObj)) {
                    
                    string assessableObAPI = objectNameAPIwithAMfieldNameAPIMap.get(selectedObj);
                    string existingAssessmentRecordQuery = ' SELECT Id, ExAM__Assessment_Group__c, '+string.EscapeSingleQuotes(assessableObAPI)+' FROM ExAM__Assessment_Group_Junction__c '+
                                                           ' WHERE ExAM__Assessment_Group__c != NULL AND ExAM__Assessment_Group__c = \''+string.EscapeSingleQuotes(selectedGroup)+'\' AND ' +string.EscapeSingleQuotes(assessableObAPI) +' != NULL';
                    
    
                    SFDCAccessController accessAGJ = ExAMUtilClass.AccessController;
                    List<String> fieldsListAGJ = new List<String>{'ExAM__Assessment_Group__c'};
                    fieldsListAGJ.add( assessableObAPI );
                    accessAGJ.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Assessment_Group_Junction__c'), fieldsListAGJ);
    
                    for (SObject sob : Database.Query(existingAssessmentRecordQuery)) {
                        assessableRecordIdSet.add((Id)sob.get(assessableObAPI));
                    }
                    
                }
                List<Assessment_Group_Junction__c> insertAGJList = new List<Assessment_Group_Junction__c>();
                
                SFDCAccessController accessAGJ = ExAMUtilClass.AccessController;
                List<String> fieldsListAGJ = new List<String>{'ExAM__Assessment_Group__c'};
    
                for (Integer i=1; i < assessmentResult.size(); i++) {  
                    Assessment_Group_Junction__c agj = new Assessment_Group_Junction__c();
                    if(selectedGroup != null && selectedGroup != '' ) {
                        agj.put('ExAM__Assessment_Group__c',selectedGroup);
                        for (Integer j=0; j<(assessmentResult.get(i)).size(); j++) {
                            if(header != null && header.get(j) != null && header.get(j) != '') {
                                string currentColHeader =header.get(j).toUpperCase().trim();
                                string currentData = ((assessmentResult.get(i)).get(j)).trim();
                                                
                                if ( currentColHeader.equals('ID') && currentData != null && currentData != ''
                                     && objectNameAPIwithAMfieldNameAPIMap != null && objectNameAPIwithAMfieldNameAPIMap.containskey(selectedObj) 
                                     && !assessableRecordIdSet.contains(currentData)) {
                                            
                                    agj.put(objectNameAPIwithAMfieldNameAPIMap.get(selectedObj), currentData);
                                    fieldsListAGJ.add( objectNameAPIwithAMfieldNameAPIMap.get(selectedObj) );
                                    insertAGJList.add(agj);    
                                    assessableRecordIdSet.add(currentData);    
                                }
                            }
                        }
                    }
                }
                    
                    if (insertAGJList.size() > 0 && insertAGJList.size() <= LIMITS.getLimitDMLRows()) {
    
                        accessAGJ.assertAuthorizedToCreate(Schema.getGlobalDescribe().get('exam__Assessment_Group_Junction__c'), fieldsListAGJ);
                        insert insertAGJList;
                        myMsg = new ApexPages.Message(ApexPages.Severity.INFO,'Records created successfully.');
                    } else if(insertAGJList.size() > LIMITS.getLimitDMLRows()) {
                        myMsg = new ApexPages.Message(ApexPages.Severity.WARNING,'You can not upload more than '+ LIMITS.getLimitDMLRows() + ' Records');
                    } else {
                        myMsg = new ApexPages.Message(ApexPages.Severity.INFO,'Assessable records are already upload or File does not have records');
                    }
                
            }
        } catch ( Exception ex ){
            myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage());
        }
        ApexPages.addMessage( myMsg );
        return null;
    }
    
    
    public static List<List<string>> parseCSV(string contents, Boolean skipHeaders) {
        List<List<string>> allFields = new List<List<string>>();

        // replace instances where a double quote begins a field containing a comma
        // in this case you get a double quote followed by a doubled double quote
        // do this for beginning and end of a field
        contents = contents.replaceAll(',"""',',"DBLQT').replaceall('""",','DBLQT",');
        
        // now replace all remaining double quotes - we do this so that we can reconstruct
        // fields with commas inside assuming they begin and end with a double quote
        contents = contents.replaceAll('""','DBLQT');
        
        // we are not attempting to handle fields with a newline inside of them
        // so, split on newline to get the spreadsheet rows
        contents = contents.replaceAll('\n\n','\n');
        contents = contents.replaceAll('\r\n','\n');
        
        Pattern newlineChar = Pattern.compile('\r\n');
        contents = newlineChar.matcher(contents).replaceAll('\n');
             
        newlineChar = Pattern.compile('\r');
        contents = newlineChar.matcher(contents).replaceAll('\n');
        
        
        List<string> lines = new List<string>();
        try {
            lines = contents.split('\n');
            
        } catch (System.ListException e) {

        }
        Integer num = 0;
        for(string line : lines) {
            // check for blank CSV lines (only commas)

            if (line.replaceAll(',','').trim().length() == 0) continue;            
            List<string> fields = line.split(',');
            List<string> cleanFields = new List<string>();
            string compositeField;
            boolean makeCompositeField = false;
            for(string field : fields) {
                if (field.startsWith('"') && field.endsWith('"')) {
                    string x = field.replaceAll('DBLQT','"');
                    x = x.substring(1);
                    x = x.substring(0, x.length()-1);
                    cleanFields.add(x);                    
                } else if (field.startsWith('"')) {
                    makeCompositeField = true;
                    compositeField = field;
                } else if (field.endsWith('"')) {
                    compositeField += ',' + field;
                    string x = compositeField.replaceAll('DBLQT','"');
                    x = x.substring(1);
                    x = x.substring(0, x.length()-1);
                    
                    cleanFields.add(x);
                    makeCompositeField = false;
                } else if (makeCompositeField) {
                    compositeField +=  ',' + field;
                } else {
                    cleanFields.add(field.replaceAll('DBLQT','"'));
                }
            }
            allFields.add(cleanFields);
        }
        
        if (skipHeaders && allFields.size() > 0 ) allFields.remove(0);
        System.Debug(LoggingLevel.INFO, 'All Fields :: ' + allFields.size());
        return allFields;       
    } 
}