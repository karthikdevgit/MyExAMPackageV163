public class ExAMUtilClass {

    public static SFDCAccessController AccessController {
        get {
            if (AccessController == null) {
                AccessController = new SFDCAccessController();
            }
            return AccessController;
        }
        private set;
    }

    public static string getNameSpacePrefix() {
    
        string nameSpacePrefix = IssueRequest_Life_Cycle__c.sObjectType.getDescribe().getName().subStringBefore('IssueRequest_Life_Cycle__c');
        return nameSpacePrefix;
    }

    /**
        Method which returns fields map of sobject
    **/
    public static Map<string, Schema.SObjectField> getSObjectFieldsMap(string sObjectApiName) {

        if (Schema.getGlobalDescribe().containsKey(sObjectApiName) && Schema.getGlobalDescribe().get(sObjectApiName) != null) {
            return Schema.getGlobalDescribe().get(sObjectApiName).getDescribe().fields.getMap();
        }
        return null;
    }

    /**
        Method which returns a map of Object Api Name and prefix of reference field created in object.
    **/
    public static Map<string, string> getAssessableObjectFieldPrefixMap() {

        Map<string, string> fieldPrefixMap = new Map<string, string>{
            'ExAM__IssueRequest_Life_Cycle__c' => 'AM_',
            'ExAM__Questionnaire_Response__c' => 'ANS_',
            'ExAM__Assessment_Group_Junction__c' => 'AGJ_',
            'ExAM__Public_Assessment__c' => 'PA_'
        };
        return fieldPrefixMap;
    }

    /**
        Method which returns wrapper class instance of Assessable object details in Assessment object.
    **/
    public static AssessableObjectDetails getAssessableObjectDetails(string sObjectApiName) {

        AssessableObjectDetails wrapperInstance = new AssessableObjectDetails();
        wrapperInstance.assessableFieldInAMMap = new Map<string, string>();
        wrapperInstance.assessableObjectAPIMap = new Map<string, string>();
        wrapperInstance.assessableObjectLabelMap = new Map<string, string>();
        wrapperInstance.objectAndFieldAPIMap = new Map<string, string>();
        wrapperInstance.objectAPIAndLabelMap = new Map<string, string>();
        wrapperInstance.assessableObjectChildRelationshipMap = new Map<string, string>();
        wrapperInstance.assessableObjectChildRelationshipMapWeb = new Map<string, string>();

        if (string.isNotBlank(sObjectApiName)) {

            string assessableObjectApiInAM = (sObjectApiName != 'ExAM__Questionnaire_Response__c') ? 'ExAM__Facility_Name__c' : 'ExAM__Account_to_Response__c';

            Map<string, string> fieldPrefixMap = ExAMUtilClass.getAssessableObjectFieldPrefixMap();
            if (fieldPrefixMap.containsKey(sObjectApiName) && fieldPrefixMap.get(sObjectApiName) != null) {

                string fieldPrefix = fieldPrefixMap.get(sObjectApiName);
                Schema.SObjectType sObj = Schema.getGlobalDescribe().get(sObjectApiName);

                Map<string, Schema.SObjectField> sObjFieldsMap = getSObjectFieldsMap( sObjectApiName );
                if (sObjFieldsMap != null && sObjFieldsMap.size() > 0) {
                    for (Schema.SObjectField eachfield : sObjFieldsMap.Values()) {
    
                        Schema.DescribeFieldResult dfr = eachfield.getDescribe();
    
                        if ((dfr.getName().equalsIgnoreCase(assessableObjectApiInAM))
                            || (dfr.isCustom() && (dfr.getType() == Schema.DisplayType.REFERENCE) && dfr.getLocalName().startsWithIgnoreCase(fieldPrefix))
                        ) {
    
                            string objectChildRelationShipNameInAM = '';
    
                            Schema.DescribeSObjectResult dsor = dfr.getReferenceTo().get(0).getDescribe();
                            for (Schema.ChildRelationShip child : dsor.getChildRelationships()) {
                                if (sObj == child.getChildSObject()) {
                                    objectChildRelationShipNameInAM = child.getRelationShipName();
                                    break;
                                }
                            }
    
                            wrapperInstance.assessableFieldInAMMap.put(dfr.getName(), dfr.getLabel());
                            wrapperInstance.assessableObjectAPIMap.put(dfr.getName(), dsor.getName());
                            wrapperInstance.assessableObjectLabelMap.put(dfr.getName(), dsor.getLabel());
                            wrapperInstance.objectAndFieldAPIMap.put(dsor.getName(), dfr.getName());
                            wrapperInstance.objectAPIAndLabelMap.put(dsor.getName(), dsor.getLabel());
                            wrapperInstance.assessableObjectChildRelationshipMap.put(dfr.getName(), dfr.getRelationshipName());
                            wrapperInstance.assessableObjectChildRelationshipMapWeb.put(dfr.getName(), objectChildRelationShipNameInAM);
                        }
                    }
                }
            }
        }
        return wrapperInstance;
    }

    /**
        Method which returns a wrapper instance of assignment manager and assessable object details
    **/
    public static AssessableObjectInAMClass getAssessableObjectDetailsFromAM(List<IssueRequest_Life_Cycle__c> amList) {

        AssessableObjectInAMClass wrapperInstance = new AssessableObjectInAMClass();
        wrapperInstance.managerIdWithAssessableObjectIdMap = new Map<Id, Id>();
        wrapperInstance.managerIdWithAssessableObjectAPINameMap = new Map<Id, string>();
        wrapperInstance.managerIdWithAssessableObjectLabelMap = new Map<Id, string>();
        wrapperInstance.managerIdWithAssessmentTemplateIdMap = new Map<Id, Id>();

        if (amList != null && amList.size() > 0) {

            AssessableObjectDetails objectDetail = getAssessableObjectDetails('ExAM__IssueRequest_Life_Cycle__c');
            Map<string, string> fieldsMap = objectDetail.assessableObjectAPIMap;

            for (IssueRequest_Life_Cycle__c am : amList) {
                for (string referenceFieldInAM : fieldsMap.keySet()) {
                    if (am.get(referenceFieldInAM) != null) {

                        Id AmId = am.Id;
                        Id AssessableObjectId = (Id)am.get(referenceFieldInAM);
                        Id AssessamentTemplateId = am.InvestigationType__c;
                        string AssessableObjectAPIName = AssessableObjectId.getSObjectType().getDescribe().getName();
                        string AssessableObjectLabel = AssessableObjectId.getSObjectType().getDescribe().getLabel();

                        wrapperInstance.managerIdWithAssessableObjectIdMap.put(AmId, AssessableObjectId);
                        wrapperInstance.managerIdWithAssessableObjectAPINameMap.put(AmId, AssessableObjectAPIName);
                        wrapperInstance.managerIdWithAssessableObjectLabelMap.put(AmId, AssessableObjectLabel);
                        wrapperInstance.managerIdWithAssessmentTemplateIdMap.put(AmId, AssessamentTemplateId);
                        break;
                    }
                }
            }
        }
        return wrapperInstance;
    }

    public static List<AssessableRecordsClass> getAssessableRecords(List<IssueRequest_Life_Cycle__c> amList, Boolean forViewerController) {

        List<AssessableRecordsClass> AssessableRecordsList = new List<AssessableRecordsClass>();

        ExAMUtilClass.AssessableObjectInAMClass assessableObjectDetails = ExAMUtilClass.getAssessableObjectDetailsFromAM( amList );
        if (assessableObjectDetails != null) {

            string SELECT_CLAUSE = '';
            string FROM_CLAUSE = '';
            string WHERE_CLAUSE = '';
            string ORDER_BY_CLAUSE = '';
            string QUERY_STRING = '';
            string AssessableObjectAPIName = '';
            string parentObjectIdField = '';
            string parentObjectNameField = '';
            Id AssessableObjectId;
            
            List<SObject> sObjectList = new List<SObject>();
            for (string amId : assessableObjectDetails.managerIdWithAssessableObjectIdMap.keySet()) {

                AssessableObjectId = assessableObjectDetails.managerIdWithAssessableObjectIdMap.get(amId);
                AssessableObjectAPIName = assessableObjectDetails.managerIdWithAssessableObjectAPINameMap.get(amId);

                if (AssessableObjectAPIName.equalsIgnoreCase('Account')) {
                    SELECT_CLAUSE = 'Id, Name, ParentId, Parent.Name';
                    WHERE_CLAUSE = 'Id = \''+AssessableObjectId+'\'';
                    ORDER_BY_CLAUSE = 'Name ASC';
                }
                else if (AssessableObjectAPIName.equalsIgnoreCase('Case')) {
                    SELECT_CLAUSE = 'CaseNumber, Id, ParentId, Parent.CaseNumber';
                    WHERE_CLAUSE = 'Id = \''+AssessableObjectId+'\'';
                    ORDER_BY_CLAUSE = 'CaseNumber ASC';
                }
                else {

                    SELECT_CLAUSE = 'Id, Name';
                    WHERE_CLAUSE = 'Id = \''+AssessableObjectId+'\'';
                    ORDER_BY_CLAUSE = 'Name ASC';

                    Map<string, string> parentReferenceFieldMap = ExAMUtilClass.getParentReferenceMapFromSobject(AssessableObjectAPIName);
                    if (parentReferenceFieldMap.containsKey(AssessableObjectAPIName) && string.isNotBlank(parentReferenceFieldMap.get(AssessableObjectAPIName))) {

                        string parentApiName = parentReferenceFieldMap.get(AssessableObjectAPIName);
                        parentObjectIdField = parentApiName;
                        parentObjectNameField = (parentApiName.endsWithIgnoreCase('__c')) ? parentApiName.replace('__c', '__r') : parentApiName.substring(0, parentApiName.length()-2);
                        SELECT_CLAUSE += ', '+parentObjectIdField+', '+parentObjectNameField+'.Name';
                    }
                }

                if (!forViewerController) {

                    string truncatedSObjectApiName = (AssessableObjectAPIName.endsWithIgnoreCase('__c')) ? AssessableObjectAPIName.substringBefore('__c') : AssessableObjectAPIName;
                    string fieldSetName = 'ViewerFieldSet_'+truncatedSObjectApiName;

                    List<string> fieldsArray = ExAMUtilClass.getFieldsListFromFieldSet(AssessableObjectAPIName, fieldSetName);
                    if (fieldsArray.size() > 0) {
                        for(string fieldSetMember : fieldsArray) {
                            if (!SELECT_CLAUSE.containsIgnoreCase(fieldSetMember)) {
                                SELECT_CLAUSE += ', '+fieldSetMember;
                            }
                        }
                    }
                }
            }
            if( SELECT_CLAUSE != null && SELECT_CLAUSE != '' ){
                FROM_CLAUSE = AssessableObjectAPIName;
                QUERY_STRING = 'SELECT '+SELECT_CLAUSE+' FROM '+FROM_CLAUSE+' WHERE '+WHERE_CLAUSE+' ORDER BY '+ORDER_BY_CLAUSE;
                sObjectList = Database.query(QUERY_STRING);
            }
            if (sObjectList != null && sObjectList.size() > 0) {

                for(SObject sObj : sObjectList) {
                    Id recordId = (Id)sObj.get('Id');
                    string objectName = recordId.getSObjectType().getDescribe().getName();

                    //Get Assessable Record Data
                    AssessableRecordsClass arc = new AssessableRecordsClass();
                    arc.recordId = recordId;
                    arc.recordName = (objectName == 'Case') ? (string)sObj.get('CaseNumber') : (string)sObj.get('Name');
                    arc.sObjectRecord = sObj;
                    AssessableRecordsList.add( arc );
                    string parentId = '';
                    string parentName = '';
                    if ((objectName == 'Case') || (objectName == 'Account')) {

                        if (sObj.get('ParentId') != null) {

                            parentId = (Id)sObj.get('ParentId');
                            parentName = (objectName == 'Case') ? (string)sObj.getSobject('Parent').get('CaseNumber') : (string)sObj.getSobject('Parent').get('Name');

                            //Get Assessable Record Parent Data
                            AssessableRecordsClass parentARC = new AssessableRecordsClass();
                            parentARC.recordId = parentId;
                            parentARC.recordName = parentName;
                            AssessableRecordsList.add( parentARC );
                        }
                    }
                    else if (string.isNotBlank(parentObjectIdField) && sObj.get(parentObjectIdField) != null) {

                        parentId = (Id)sObj.get(parentObjectIdField);
                        parentName = (string)sObj.getSObject(parentObjectNameField).get('Name');

                        //Get Assessable Record Parent Data
                        AssessableRecordsClass parentARC = new AssessableRecordsClass();
                        parentARC.recordId = parentId;
                        parentARC.recordName = parentName;
                        AssessableRecordsList.add( parentARC );

                    }
                }
            }
        }
        return AssessableRecordsList;
    }

    /**
        Method which returns List of field API names of a given field set of given sobject
    **/
    public static List<string> getFieldsListFromFieldSet(string sObjectApiName, string fieldSetName) {

        List<string> fieldsList = new List<string>();

        if ( string.isNotBlank(sObjectApiName) ) {

            Map<string, Schema.SObjectType> sObjectMap = Schema.getGlobalDescribe();
            if (sObjectMap.containsKey(sObjectApiName) && sObjectMap.get(sObjectApiName) != null) {

                Schema.DescribeSObjectResult dsor = sObjectMap.get(sObjectApiName).getDescribe();

                Map<string, Schema.FieldSet> fieldSetMap = dsor.FieldSets.getMap();
                if (fieldSetMap.containsKey(fieldSetName) && fieldSetMap.get(fieldSetName) != null) {

                    for (Schema.FieldSetMember member : fieldSetMap.get(fieldSetName).getFields()) {
                        fieldsList.add( member.getFieldPath() );
                    }
                }
            }
        }
        return fieldsList;
    }

    /**
        Method which returns List of Field Set Members of a given field set of given sobject
    **/
    public static List<Schema.FieldSetMember> getFieldSetMembers(string sObjectApiName, string fieldSetName) {

        if ( string.isNotBlank(sObjectApiName) ) {

            Map<string, Schema.SObjectType> sObjectMap = Schema.getGlobalDescribe();
            if (sObjectMap.containsKey(sObjectApiName) && sObjectMap.get(sObjectApiName) != null) {

                Schema.DescribeSObjectResult dsor = sObjectMap.get(sObjectApiName).getDescribe();

                Map<string, Schema.FieldSet> fieldSetMap = dsor.FieldSets.getMap();
                if (fieldSetMap.containsKey(fieldSetName) && fieldSetMap.get(fieldSetName) != null) {

                    return fieldSetMap.get(fieldSetName).getFields();
                }
            }
        }
        return null;
    }

    /**
        Method which returns map whose key sobject name and value is api name of self lookup field in that sobject
    **/
    public static Map<string, string> getParentReferenceMapFromSobject(string sObjectApiName) {

        Map<string, string> referenceMap = new Map<string, string>();

        if (string.isNotBlank(sObjectApiName)) {

            Map<string, Schema.SObjectField> sObjFieldsMap = getSObjectFieldsMap( sObjectApiName );
            if (sObjFieldsMap != null && sObjFieldsMap.size() > 0) {
                for (Schema.SObjectField field : sObjFieldsMap.Values()) {

                    Schema.DescribeFieldResult dfr = field.getDescribe();
                    if ( dfr.isCustom() && (dfr.getType() == Schema.DisplayType.REFERENCE) && (dfr.getReferenceTo().get(0).getDescribe().getName() == sObjectApiName) ) {

                        referenceMap.put(sObjectApiName, dfr.getName());
                    }
                }
            }
        }
        return referenceMap;
    }

    /**
        Method which does field mapping on Assessable entity which is linked as an Assessable object on Assignment Manager
    **/
    public static void updateAssessableObjectUsingFieldMapping(List<IssueRequest_Life_Cycle__c> managers, Boolean runAMFieldMappingOnly) {

        string objectApiName = '';       
        string objApiNameAndTemplateId = '';
        string templateId = '';       
        string objectId = ''; 

        Set<Id> templateIdSet = new Set<Id>();
        Set<string> amIdWithQtnIdSet = new Set<string>();

        Map<string, Map<string, string>> objectApiTemplateIdWithFieldApiMap = new Map<string, Map<string, string>>();
        Map<string, Map<string, string>> objectApiTemplateIdWithFieldApiAndTobeStoredValueMap = new Map<string, Map<string, string>>();
        Map<string, Map<string, Set<string>>> objectApiTemplateIdWithQtnTemplateIdAndFieldApiMap = new Map<string, Map<string, Set<string>>>();
        Map<Id, SObject> updateSObjectMap = new Map<Id, SObject>(); //001 => {Id = '001', Type = 'Industry'}
        Map<Id, List<Questionnaire_Response__c>> amIdWithAnswersMap = new Map<Id, List<Questionnaire_Response__c>>();

        ExAMUtilClass.AssessableObjectInAMClass assessableObjectDetails = ExAMUtilClass.getAssessableObjectDetailsFromAM( managers );
        if (assessableObjectDetails != null) {

            Map<Id, Id> managerIdWithAssessableObjectIdMap = assessableObjectDetails.managerIdWithAssessableObjectIdMap;
            Map<Id, string> managerIdWithAssessableObjectAPINameMap = assessableObjectDetails.managerIdWithAssessableObjectAPINameMap;
            Map<Id, Id> managerIdWithAssessmentTemplateIdMap = assessableObjectDetails.managerIdWithAssessmentTemplateIdMap;

            for (Assessable_Fields_Mapping__c afm : [SELECT Id, Assessable_Object_API__c, Assessable_Object_Field_API__c,
                                                            Assessment_Template__c, Question_Template__c,
                                                            Is_Case_Response__c, Store_Answer_Response_Or_Score__c,
                                                            Mapped_From__c, Assignment_Manager_Field_API__c
                                                     FROM   Assessable_Fields_Mapping__c
                                                     WHERE  Assessable_Object_API__c != null
                                                            AND Assessment_Template__c != null
                                                            AND ((Question_Template__c != null) OR (Assignment_Manager_Field_API__c != null))
                                                            AND Assessable_Object_Field_API__c != null 
                                                            AND Assessable_Object_API__c IN :managerIdWithAssessableObjectAPINameMap.values()
                                                            AND Assessment_Template__c IN :managerIdWithAssessmentTemplateIdMap.values()
                                                            AND Is_Case_Response__c = false]) {

                objApiNameAndTemplateId = afm.Assessable_Object_API__c+''+afm.Assessment_Template__c;
                if ( string.isNotBlank(afm.Assignment_Manager_Field_API__c) ) {
                    if (!objectApiTemplateIdWithFieldApiMap.containsKey(objApiNameAndTemplateId)) {
                        objectApiTemplateIdWithFieldApiMap.put(objApiNameAndTemplateId, new Map<string, string>());
                    }
                    objectApiTemplateIdWithFieldApiMap.get(objApiNameAndTemplateId).put(afm.Assessable_Object_Field_API__c, afm.Assignment_Manager_Field_API__c);
                }
                else if (!runAMFieldMappingOnly && string.isNotBlank(afm.Question_Template__c) ) {
                    if (!objectApiTemplateIdWithQtnTemplateIdAndFieldApiMap.containsKey(objApiNameAndTemplateId)) {
                        objectApiTemplateIdWithQtnTemplateIdAndFieldApiMap.put(objApiNameAndTemplateId, new Map<string, Set<string>>());
                        objectApiTemplateIdWithFieldApiAndTobeStoredValueMap.put(objApiNameAndTemplateId, new Map<string, string>());
                    }
                    if (!objectApiTemplateIdWithQtnTemplateIdAndFieldApiMap.get(objApiNameAndTemplateId).containsKey(afm.Question_Template__c)) {
                        objectApiTemplateIdWithQtnTemplateIdAndFieldApiMap.get(objApiNameAndTemplateId).put(afm.Question_Template__c, new Set<string>());
                    }
                    objectApiTemplateIdWithQtnTemplateIdAndFieldApiMap.get(objApiNameAndTemplateId).get(afm.Question_Template__c).add( afm.Assessable_Object_Field_API__c );
                    objectApiTemplateIdWithFieldApiAndTobeStoredValueMap.get(objApiNameAndTemplateId).put(afm.Assessable_Object_Field_API__c, afm.Store_Answer_Response_Or_Score__c);
                    templateIdSet.add(afm.Assessment_Template__c);
                }
            }
            if (objectApiTemplateIdWithFieldApiMap != null && objectApiTemplateIdWithFieldApiMap.size() > 0) {        

                SObject sob;
                Set<string> objectApiNameSet = new Set<string>();
                Map<string, Schema.SObjectField> objectFieldDescribeMap = new Map<string, Schema.SObjectField>();

                for (IssueRequest_Life_Cycle__c am : managers) {       

                    objectApiName = managerIdWithAssessableObjectAPINameMap.get(am.Id);     
                    templateId = am.InvestigationType__c;       
                    objectId = managerIdWithAssessableObjectIdMap.get(am.Id);        

                    if (!objectApiNameSet.contains(objectApiName)) {
                        objectFieldDescribeMap.putAll( getSObjectFieldsMap(objectApiName) );
                        objectApiNameSet.add(objectApiName);
                    }

                    objApiNameAndTemplateId = objectApiName+templateId;   
                    if (objectApiTemplateIdWithFieldApiMap.containsKey(objApiNameAndTemplateId) && objectApiTemplateIdWithFieldApiMap.get( objApiNameAndTemplateId ) != null) {       

                        Map<string, string> fieldApiMap = new Map<string, string>();      
                        fieldApiMap = objectApiTemplateIdWithFieldApiMap.get( objApiNameAndTemplateId );     

                        if (updateSObjectMap.containsKey(objectId) && updateSObjectMap.get(objectId) != null && updateSObjectMap.get(objectId).get('Id') != null) {
                            sob = updateSObjectMap.get(objectId);
                        }
                        else {
                            sob = Schema.getGlobalDescribe().get(objectApiName).newSObject();        
                            sob.put('Id', objectId);
                        } 
                        for (string objFieldApiName : fieldApiMap.keySet()) { 
                                        
                            string amFieldApiName = fieldApiMap.get( objFieldApiName );  
                            string objFieldApiNameInLowerCase = objFieldApiName.toLowerCase();
                            if (objectFieldDescribeMap.containsKey(objFieldApiNameInLowerCase) && objectFieldDescribeMap.get(objFieldApiNameInLowerCase) != null) {
                                Schema.DisplayType fieldType = objectFieldDescribeMap.get(objFieldApiNameInLowerCase).getDescribe().getType(); 
                                if(fieldType == Schema.DisplayType.STRING || fieldType == Schema.DisplayType.TEXTAREA) {    
                                    sob.put(objFieldApiName, string.valueOf(am.get(amFieldApiName)));   
                                } else {
                                    sob.put(objFieldApiName, am.get(amFieldApiName) );   
                                }
                            }
                        }       
                        updateSObjectMap.put(objectId, sob);     
                    }       
                }       
            }       
            if (!runAMFieldMappingOnly && objectApiTemplateIdWithQtnTemplateIdAndFieldApiMap != null && objectApiTemplateIdWithQtnTemplateIdAndFieldApiMap.size() > 0) {

                SObject sob;
                Set<string> objectApiNameSet = new Set<string>();
                Map<string, Schema.SObjectField> sObjFieldsMap = new Map<string, Schema.SObjectField>();

                for (Questionnaire_Response__c ans : [ SELECT Id, Issue_Request__c, Issue_Request__r.InvestigationType__c, Response__c, Question_Template__c, LastModifiedDate, Total_Score__c 
                                                       FROM   Questionnaire_Response__c    
                                                       WHERE  Issue_Request__c != NULL
                                                              AND Issue_Request__r.InvestigationType__c != NULL
                                                              AND Issue_Request__c IN :managers
                                                              AND Issue_Request__r.InvestigationType__c IN :templateIdSet
                                                              ORDER BY LastModifiedDate DESC]) {

                    if (!amIdWithAnswersMap.containsKey(ans.Issue_Request__c)) {
                        amIdWithAnswersMap.put(ans.Issue_Request__c, new List<Questionnaire_Response__c>());
                    }
                    if (!amIdWithQtnIdSet.contains(ans.Issue_Request__c+''+ans.Question_Template__c) && ans.Response__c != null) {
                        amIdWithAnswersMap.get(ans.Issue_Request__c).add(ans);
                        amIdWithQtnIdSet.add(ans.Issue_Request__c+''+ans.Question_Template__c);
                    }
                }

                for (Id amId : amIdWithAnswersMap.KeySet()) {

                    objectApiName = managerIdWithAssessableObjectAPINameMap.get(amId);
                    objectId = managerIdWithAssessableObjectIdMap.get(amId);        
                    if (string.isNotBlank(objectApiName) && string.isNotBlank(objectId)) {

                        if (!objectApiNameSet.contains(objectApiName)) {
                            sObjFieldsMap.putAll( getSObjectFieldsMap(objectApiName) );
                            objectApiNameSet.add(objectApiName);
                        }

                        if (updateSObjectMap.containsKey(objectId) && updateSObjectMap.get(objectId) != null && updateSObjectMap.get(objectId).get('Id') != null) {
                            sob = updateSObjectMap.get(objectId);
                        }
                        else {
                            sob = Schema.getGlobalDescribe().get(objectApiName).newSObject();        
                            sob.put('Id', objectId);
                        } 

                        for (Questionnaire_Response__c ansRes : amIdWithAnswersMap.get(amId)) {

                            objApiNameAndTemplateId = objectApiName+''+ansRes.Issue_Request__r.InvestigationType__c;
                            List<string> FieldListdyn = new List<string>();
                            if (ansRes.Response__c != null
                                && objectApiTemplateIdWithQtnTemplateIdAndFieldApiMap.containsKey(objApiNameAndTemplateId)
                                && objectApiTemplateIdWithQtnTemplateIdAndFieldApiMap.get(objApiNameAndTemplateId) != null
                                && objectApiTemplateIdWithQtnTemplateIdAndFieldApiMap.get(objApiNameAndTemplateId).containsKey(ansRes.Question_Template__c)
                                && objectApiTemplateIdWithQtnTemplateIdAndFieldApiMap.get(objApiNameAndTemplateId).get(ansRes.Question_Template__c).size() > 0
                            ) { 

                                Map<string, Set<string>> qtnIdWithObjectFieldsSetMap = new Map<string, Set<string>>();
                                qtnIdWithObjectFieldsSetMap = objectApiTemplateIdWithQtnTemplateIdAndFieldApiMap.get(objApiNameAndTemplateId);
                                    
                                for(string eachField : qtnIdWithObjectFieldsSetMap.get(ansRes.Question_Template__c)) {

                                    string objFieldApiNameInLowerCase = eachField.toLowerCase();
                                    if (sObjFieldsMap.containsKey(objFieldApiNameInLowerCase) && sObjFieldsMap.get(objFieldApiNameInLowerCase) != null) {

                                        Schema.DisplayType fieldType = sObjFieldsMap.get(objFieldApiNameInLowerCase).getDescribe().getType();
                                        if (fieldType == Schema.DisplayType.DATE) {
                                            string[] dateStr = (ansRes.Response__c).split('/');
                                            Date response = date.newinstance( Integer.valueOf(dateStr[2]), Integer.valueOf(dateStr[1]), Integer.valueOf(dateStr[0]) );
                                            sob.put(eachField, response);                                            
                                        } else if (fieldType == Schema.DisplayType.DATETIME) {
                                            string[] dateStr = (ansRes.Response__c).split('/');
                                            Datetime response = dateTime.newinstance( Integer.valueOf(dateStr[2]), Integer.valueOf(dateStr[1]), Integer.valueOf(dateStr[0]) );
                                            sob.put(eachField, response);
                                        } else if (fieldType == Schema.DisplayType.DOUBLE) {
                                            string whichFieldValueNeedTobeStored = objectApiTemplateIdWithFieldApiAndTobeStoredValueMap.get(objApiNameAndTemplateId).get(eachField);
                                            if (whichFieldValueNeedTobeStored == 'Response' && ansRes.Response__c.isNumeric()) {
                                                sob.put(eachField, Decimal.valueOf(ansRes.Response__c));
                                            }
                                            else if (whichFieldValueNeedTobeStored == 'Score') {
                                                sob.put(eachField, ansRes.Total_Score__c);
                                            }
                                        } else if (fieldType == Schema.DisplayType.INTEGER) {
                                            string whichFieldValueNeedTobeStored = objectApiTemplateIdWithFieldApiAndTobeStoredValueMap.get(objApiNameAndTemplateId).get(eachField);
                                            if (whichFieldValueNeedTobeStored == 'Response' && ansRes.Response__c.isNumeric()) {
                                                sob.put(eachField, Integer.valueOf(ansRes.Response__c));
                                            }
                                            else if (whichFieldValueNeedTobeStored == 'Score') {
                                                sob.put(eachField, ansRes.Total_Score__c);
                                            }
                                        } else {

                                            string whichFieldValueNeedTobeStored = objectApiTemplateIdWithFieldApiAndTobeStoredValueMap.get(objApiNameAndTemplateId).get(eachField);
                                            if (whichFieldValueNeedTobeStored == 'Response') {
                                                sob.put(eachField, ansRes.Response__c);
                                            }
                                            else if (whichFieldValueNeedTobeStored == 'Score') {
                                                sob.put(eachField, string.valueOf(ansRes.Total_Score__c));
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        updateSObjectMap.put(sob.Id, sob);
                    }
                }
            }                                               
            if (updateSObjectMap != null && updateSObjectMap.size() > 0) {
                Database.DMLOptions dml = new Database.DMLOptions();
                dml.allowFieldTruncation = true;
                Database.update(updateSObjectMap.Values(), dml);
            }
        }
    }

    /**
        Method which returns a list of assignment manager fields which are configured in Assessable Field Mapping object
    **/
    public static List<string> getAMFieldsFromAFM(AssessableObjectInAMClass assessableObjectDetails) {

        List<string> amFields = new List<string>();
        Set<string> amFieldsSet = new Set<string>();

        if (assessableObjectDetails != null) {

            Map<Id, string> managerIdWithAssessableObjectAPINameMap = assessableObjectDetails.managerIdWithAssessableObjectAPINameMap;
            Map<Id, Id> managerIdWithAssessmentTemplateIdMap = assessableObjectDetails.managerIdWithAssessmentTemplateIdMap;

            for (Assessable_Fields_Mapping__c afm : [SELECT Id, Assessable_Object_API__c, Assessable_Object_Field_API__c,
                                                            Assessment_Template__c, Question_Template__c,
                                                            Is_Case_Response__c, Store_Answer_Response_Or_Score__c,
                                                            Mapped_From__c, Assignment_Manager_Field_API__c
                                                     FROM   Assessable_Fields_Mapping__c
                                                     WHERE  Assessable_Object_API__c != null
                                                            AND Assessment_Template__c != null
                                                            AND Question_Template__c = null
                                                            AND Assignment_Manager_Field_API__c != null
                                                            AND Assessable_Object_Field_API__c != null 
                                                            AND Assessable_Object_API__c IN :managerIdWithAssessableObjectAPINameMap.values()
                                                            AND Assessment_Template__c IN :managerIdWithAssessmentTemplateIdMap.values()
                                                            AND Is_Case_Response__c = false]) {

                amFieldsSet.add( afm.Assignment_Manager_Field_API__c );

            }
        }
        if (amFieldsSet.size() > 0) {
            amFields.addAll( amFieldsSet );
        }
        return amFields;
    }

    /**
        Method which returns Random set of Questions based on below parameters sent to this method
        #1 questionList >> Total Questions
        #2 randomQuesCount >> Questions Count
    **/
    public static List<Question_Template__c> sectionRandomizationFunc(List<Question_Template__c> questionList, Integer randomQuesCount) {

        List<Question_Template__c> randomizedQuestionList = new List<Question_Template__c>();
        List<Question_Template__c> randomizedCaseQuestionList = new List<Question_Template__c>();
        Set<Integer> randomNumSet = new Set<Integer>();
        Integer quesLength = questionList.size()-1;
        Integer i=0;
        while(i < randomQuesCount) {
            Integer randomNum = Integer.ValueOf(Math.rint(Math.random() * quesLength));
            if(!randomNumSet.contains(randomNum)) {
                randomNumSet.add(randomNum);
                if( questionList[randomNum].Question_Type__c == 'Case' ){
                    randomizedCaseQuestionList.add(questionList[randomNum]);
                } else { 
                    randomizedQuestionList.add(questionList[randomNum]);
                }
                i++;
            }
            
        }
        randomizedQuestionList.addAll(randomizedCaseQuestionList);
        return randomizedQuestionList;
    }
    
    /**
        Prepares a list of answer object instance for hidden question type
    **/
    public static List<Questionnaire_Response__c> prepareAnswers(string templateId, string sectionId, string amId, Boolean isSingleQtnMode) {

        Boolean isOTA = false;
        List<Questionnaire_Response__c> answersList = new List<Questionnaire_Response__c>();
        Map<Id, List<Questionnaire_Response__c>> qtnTemplateIdAndAnswersMap = new Map<Id, List<Questionnaire_Response__c>>();

        Map<Id, Main_questionaire__c> templateMap = new Map<ID, Main_questionaire__c>([SELECT Id, Name, One_Time_Assessment__c FROM Main_questionaire__c WHERE Id = :templateId AND One_Time_Assessment__c = true LIMIT 1]);

        if (templateMap != null && templateMap.size() > 0 && string.isNotBlank(amId)) {

            isOTA = true;

            for (Questionnaire_Response__c answer : [SELECT Id, Name, Question_Template__c, Question_Template__r.Question_Type__c,
                                                                  Question_Template__r.Section_Question__c, Issue_Request__c,
                                                                  Question_Template__r.Section_Question__r.Questionnaire_Section__c, Response__c
                                                           FROM   Questionnaire_Response__c
                                                           WHERE  Question_Template__c != null
                                                                  AND Question_Template__r.Question_Type__c = 'Hidden'
                                                                  AND Question_Template__r.Section_Question__r.Questionnaire_Section__c = :templateId 
                                                                  AND Issue_Request__c = :amId]) {

                if (!qtnTemplateIdAndAnswersMap.containsKey(answer.Question_Template__c)) {
                    qtnTemplateIdAndAnswersMap.put(answer.Question_Template__c, new List<Questionnaire_Response__c>());
                }
                qtnTemplateIdAndAnswersMap.get(answer.Question_Template__c).add( answer );
            }
        }

        string SELECT_CLAUSE = 'ExAM__Default_Value__c, ExAM__Disabled__c, ExAM__Do_Not_Create_Answer__c, Id, ExAM__Question_Type__c';
        string FROM_CLAUSE = 'ExAM__Question_Template__c';
        string WHERE_CLAUSE = 'ExAM__Question_Type__c = \'Hidden\' AND ExAM__Section_Question__r.ExAM__Questionnaire_Section__c = :templateId AND ExAM__Disabled__c = false AND ExAM__Do_Not_Create_Answer__c = false';
        if (string.isNotBlank(sectionId) ) {
            WHERE_CLAUSE += ' AND ExAM__Section_Question__c = :sectionId';
        }
        string QUERY_STRING = 'SELECT '+SELECT_CLAUSE+' FROM '+FROM_CLAUSE+' WHERE '+WHERE_CLAUSE;

        List<Question_Template__c> questions = Database.query(QUERY_STRING);
        if (questions != null && questions.size() > 0) {

            for (Question_Template__c qtn : questions) {

                if ((string.isBlank(sectionId)) || (string.isNotBlank(sectionId) && isSingleQtnMode)) {

                    if (!isOTA || (isOTA && !qtnTemplateIdAndAnswersMap.containsKey(qtn.Id))) {

                        Questionnaire_Response__c ans = new Questionnaire_Response__c();
                        ans.Question_Template__c = qtn.Id;
                        ans.Response__c = qtn.Default_Value__c;
                        if(string.isNotBlank(amId)) {
                            ans.Issue_Request__c = amId;
                        }
                        ans.Questionnaire_Taker_user__c = UserInfo.getUserId();
                        answersList.add( ans );
                    }
                }
            }
        }
        return answersList;
    }
    public static LimitClass getDailyEmailLimit() {

        string sfid = '';

        if(!Test.isRunningTest()){
            PageReference pg = new PageReference('/apex/GetSessionId');
            sfid = pg.getContent().toString();
        }

        LimitClass l = new LimitClass();

        String endpointURL = URL.getSalesforceBaseUrl().toExternalForm();
        List<SF_sub_domain__c> sfsubdomainList = [SELECT Id, Name, EndPointURL__c FROM SF_sub_domain__c WHERE Name = 'EndPointURL' LIMIT 1];
        if (sfsubdomainList != null && sfsubdomainList.size() > 0) {
            endpointURL = sfsubdomainList[0].EndPointURL__c;
        }
        endpointURL += '/' + System.Label.SFLimitEndPointURL;

        HttpRequest req = new HttpRequest();
        req.setEndPoint(endpointURL);
        req.setHeader('Authorization', 'Bearer '+sfid);
        req.setMethod('GET');
        req.setTimeout(20000);
        Http h = new Http();
        HttpResponse res = new HttpResponse();
        res = h.send( req );
        string response = res.getBody();
        string status = res.getStatus();
        Integer code = res.getStatusCode();
        if (status == 'OK' && code == 200 && string.isNotBlank(response)) {
            l.response = response;
            Map<string, Object> responseMap = (Map<string, Object>)Json.deserializeUntyped(response);
            if (responseMap.containsKey('SingleEmail') && responseMap.get('SingleEmail') != null) {
                Map<string, Object> massEmailLimitMap = (Map<string, Object>)responseMap.get('SingleEmail');
                l.max = (Integer)massEmailLimitMap.get('Max');
                l.remaining = (Integer)massEmailLimitMap.get('Remaining');
            }
        }
        return l;
    }
    
    public class AssessableObjectDetails {
        public Map<string, string> assessableFieldInAMMap;
        public Map<string, string> assessableObjectAPIMap;
        public Map<string, string> assessableObjectLabelMap;
        public Map<string, string> objectAndFieldAPIMap;
        public Map<string, string> objectAPIAndLabelMap;
        public Map<string, string> assessableObjectChildRelationshipMap;
        public Map<string, string> assessableObjectChildRelationshipMapWeb;
    }

    public class AssessableObjectInAMClass {
        public Map<Id, Id> managerIdWithAssessableObjectIdMap;
        public Map<Id, string> managerIdWithAssessableObjectAPINameMap;
        public Map<Id, string> managerIdWithAssessableObjectLabelMap;
        public Map<Id, Id> managerIdWithAssessmentTemplateIdMap;
    }

    public class AssessableRecordsClass {
        public string recordId;
        public string recordName;
        public SObject sObjectRecord;
    }
    public class LimitClass {
        @AuraEnabled 
        public string response;
        @AuraEnabled 
        public Integer max;
        @AuraEnabled 
        public Integer remaining;
    }
}