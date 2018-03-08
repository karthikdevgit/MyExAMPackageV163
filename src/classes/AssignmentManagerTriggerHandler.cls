public class AssignmentManagerTriggerHandler {

    private Boolean m_isExecuting = false;
    private Integer BatchSize = 0;

    private static examConfigClass examConfig { //assingment manager submit status
        get {
            if (examConfig == null) {
                examConfig = new examConfigClass();
                examConfig.AMSubmitStatus = 'Completed';
                examConfig.isFieldMapping = false;
                try{

                    List<ExAM_Configuration__c> examConfigList = [
                        SELECT Id, Is_Field_Mapping__c, Overall_Status_on_Submit__c
                        FROM   ExAM_Configuration__c
                        WHERE  Name = 'Configuration' ORDER BY CreatedDate DESC LIMIT 1
                    ];                 
                    if (examConfigList != null && examConfigList.size() > 0) {
                        if (examConfigList[0].Overall_Status_on_Submit__c != null 
                            && examConfigList[0].Overall_Status_on_Submit__c != '') {
                                examConfig.AMSubmitStatus = examConfigList[0].Overall_Status_on_Submit__c;
                            }
                        if (examConfigList[0].Is_Field_Mapping__c) {
                            examConfig.isFieldMapping = examConfigList[0].Is_Field_Mapping__c;
                        }
                    }
                }catch(Exception e){
                    throw e;
                } 
            }
            return examConfig;
        }
        set;
    }

    public class examConfigClass {
        public string AMSubmitStatus;
        public Boolean isFieldMapping;
    }

    public AssignmentManagerTriggerHandler(boolean isExecuting, integer size){
        m_isExecuting = isExecuting;
        BatchSize = size;
    }
    
    //Before insert assignment Manager process 
    public void onBeforeInsert(List<IssueRequest_Life_Cycle__c> newAMList) {
        
        for (IssueRequest_Life_Cycle__c am :newAMList) {
            if (am.Assessor_Resource__c!= null) {
                am.OwnerId = am.Assessor_Resource__c;
            }            
        }
        protectMorethenOneCustomLookupValuePopulate(newAMList);
    }
    
    //After insert assignment Manager process
    public void onAfterInsert(List<IssueRequest_Life_Cycle__c> newAMList) {
        executeFieldMappingOnAMSave(newAMList, new Map<Id, IssueRequest_Life_Cycle__c>(), true);
    }

    //Before update assignment Manager process
    public void onBeforeUpdate( List<IssueRequest_Life_Cycle__c> oldAMList, 
                                List<IssueRequest_Life_Cycle__c> newAMList,
                                Map<ID, IssueRequest_Life_Cycle__c> newAssignmentManagerMap) {
        Map<ID, IssueRequest_Life_Cycle__c> scoreUpdateAssignmentManagerMap = new Map<ID, IssueRequest_Life_Cycle__c> ();
        for (IssueRequest_Life_Cycle__c oldAM :oldAMList) {
            if (newAssignmentManagerMap.get(oldAM.Id).Assessor_Resource__c != null 
                    && newAssignmentManagerMap.get(oldAM.Id).Assessor_Resource__c != oldAM.Assessor_Resource__c) {
                newAssignmentManagerMap.get(oldAM.Id).OwnerId = newAssignmentManagerMap.get(oldAM.Id).Assessor_Resource__c;
            } 
            if (newAssignmentManagerMap.get(oldAM.Id).Status__c == examConfig.AMSubmitStatus && oldAM.Status__c != examConfig.AMSubmitStatus ) {
                scoreUpdateAssignmentManagerMap.put(oldAM.Id, newAssignmentManagerMap.get(oldAM.Id));
                if( newAssignmentManagerMap.get(oldAM.Id).Date_Completed__c == null ){
                    newAssignmentManagerMap.get(oldAM.Id).Date_Completed__c = System.now();
                }
            }     
        }
        protectMorethenOneCustomLookupValuePopulate(newAMList);    
        if (scoreUpdateAssignmentManagerMap.size() > 0) {
            calculateScore(scoreUpdateAssignmentManagerMap);
        }    
    }
    
    public void onAfterUpdate(List<IssueRequest_Life_Cycle__c> oldAMList, 
                                List<IssueRequest_Life_Cycle__c> newAMList,
                                Map<ID, IssueRequest_Life_Cycle__c> oldAMMap,
                                Map<ID, IssueRequest_Life_Cycle__c> newAMMap) {
    
        //update assissable
        updateAssessableRecords(oldAMList, newAMList, newAMMap); 
        createCase(oldAMList, newAMMap);       
        generateCaseOrLead(oldAMList, newAMMap);
        executeFieldMappingOnAMSave(newAMList, oldAMMap, false);
    }
    
    public void protectMorethenOneCustomLookupValuePopulate(List<IssueRequest_Life_Cycle__c> newAMList) {
    
        Map<string, string> fieldAPIFieldLabelMap = new Map<string, string>();
        
        ExAMUtilClass.AssessableObjectDetails objectDetail = ExAMUtilClass.getAssessableObjectDetails('ExAM__IssueRequest_Life_Cycle__c');
        fieldAPIFieldLabelMap = objectDetail.assessableFieldInAMMap;

        for (IssueRequest_Life_Cycle__c assMang : newAMList) {
            Integer AMValueFieldcount = 0;
            List<string> fieldsLabel = new List<string>();
            for (string fieldApiName : fieldAPIFieldLabelMap.keySet()) {
                if (assMang.get(fieldApiName) != NULL) {
                    AMValueFieldcount++;
                    fieldsLabel.add(fieldAPIFieldLabelMap.get(fieldApiName));
                }                          
            }
            if ( AMValueFieldcount > 1 ) {
                assMang.addError('Can\'t do more than one inspection at a time. Inspection created for '+string.join(fieldsLabel,', ')+' fields.');
            } 
        }        
    }
    public static void calculateScore(Map<ID, IssueRequest_Life_Cycle__c> scoreAssignmentManagerMap) {
        
        Map<Id, Decimal> amIdwithTotalScoreMap = new Map<Id, Decimal>();
        Map<Id, Decimal> amIdwithMaxScoreMap = new Map<Id, Decimal>();
        
        try{
            for(Questionnaire_Response__c ans : [SELECT ID, Weight_Response__c, Total_Score__c, Max_Score__c, Issue_Request__c, 
                                                        Question_Template__c, Question_Template__r.Question_Type__c 
                                                    FROM Questionnaire_Response__c 
                                                    WHERE Issue_Request__c IN:scoreAssignmentManagerMap.keySet()
                                                    AND Total_Score__c != null 
                                                    AND Max_Score__c != null]) {
                                                    /* Total score and Max score in AM will be set to 0 when there is no answer record with total score/ Max score > 0. 
                                                       This is done to support score based redirection logic in Public Assessment*/
                                                    //AND Question_Template__r.Question_Type__c IN ('RadioPicklist','Dropdown Picklist','Button','Image','List','Horizontal Radiopicklist','Likert'
                
                if (!amIdwithTotalScoreMap.containsKey(ans.Issue_Request__c)) {
                    amIdwithTotalScoreMap.put(ans.Issue_Request__c, 0.00);
                }
                if (!amIdwithMaxScoreMap.containsKey(ans.Issue_Request__c)) {
                    amIdwithMaxScoreMap.put(ans.Issue_Request__c, 0.00);
                } 
             
                amIdwithTotalScoreMap.put(ans.Issue_Request__c, amIdwithTotalScoreMap.get(ans.Issue_Request__c) + ans.Total_Score__c);
                amIdwithMaxScoreMap.put(ans.Issue_Request__c, amIdwithMaxScoreMap.get(ans.Issue_Request__c) + ans.Max_Score__c);
            }
            for (Id amId : amIdwithTotalScoreMap.KeySet()) {
                if (amIdwithMaxScoreMap != null && amIdwithMaxScoreMap.containsKey(amId)) { //amIdwithTotalScoreMap.get(amId) != 0  && amIdwithMaxScoreMap.get(amId) != 0
                    scoreAssignmentManagerMap.get(amId).Total_Score__c = amIdwithTotalScoreMap.get(amId);
                    scoreAssignmentManagerMap.get(amId).Max_Score__c = amIdwithMaxScoreMap.get(amId);
                }
            }
        }catch(Exception e){
            throw e;
        }
    }
    
    public void updateAssessableRecords(List<IssueRequest_Life_Cycle__c> oldAMList, List<IssueRequest_Life_Cycle__c> newAMList, Map<ID, IssueRequest_Life_Cycle__c> newAMMap) {

        if (examConfig.isFieldMapping) {

            List<IssueRequest_Life_Cycle__c> filteredManagers = new List<IssueRequest_Life_Cycle__c>();

            ExAMUtilClass.AssessableObjectDetails objectDetail = ExAMUtilClass.getAssessableObjectDetails('ExAM__IssueRequest_Life_Cycle__c');
            Map<string, string> fieldsMap = objectDetail.assessableObjectAPIMap;
                
            for (IssueRequest_Life_Cycle__c oldAM : oldAMList) {
                if (newAMMap.get(oldAM.Id).Status__c == examConfig.AMSubmitStatus && newAMMap.get(oldAM.Id).InvestigationType__c != null) {
                    for (string assessablefld : fieldsMap.keySet()) {
                        if (newAMMap.get(oldAM.Id).get(assessablefld) != null 
                            && ((newAMMap.get(oldAM.Id).get(assessablefld) != oldAM.get(assessablefld))
                                || (newAMMap.get(oldAM.Id).Status__c != oldAM.Status__c))
                        ) {

                            filteredManagers.add( oldAM );           
                            break;
                        } 
                    }
                }
            }

            if (filteredManagers != null && filteredManagers.size() > 0) {
                ExAMUtilClass.updateAssessableObjectUsingFieldMapping(filteredManagers, false);          
            }
        }
    }

    public void createCase(List<IssueRequest_Life_Cycle__c> oldAMList, Map<ID, IssueRequest_Life_Cycle__c> newAMMap) {
        
        try {

            Set<Id> AMIdSet = new Set<Id>();
            List<Case> caseList = new List<Case>();
            string watchlisttext = '';
        
            for(IssueRequest_Life_Cycle__c am : oldAMList) {
                if(am.Status__c != newAMMap.get(am.Id).Status__c) {
                    if(newAMMap.get(am.Id).Status__c == examConfig.AMSubmitStatus) {
                        AMIdSet.add(am.Id);
                    }                 
                }
            }
            for(Questionnaire_Response__c ans : [SELECT Response__c, Issue_Request__c, Issue_Request__r.Name, 
                                                 Question_Template__r.Section_Question__r.Questionnaire_Section__r.Watchlist_Of_Words__c 
                                                 FROM Questionnaire_Response__c 
                                                 WHERE Issue_Request__c in :AMIdSet]) {
                List<string> checkStringList = new List<string>();
                if(ans.Response__c != NULL && ans.Question_Template__r.Section_Question__r.Questionnaire_Section__r.Watchlist_Of_Words__c != NULL) {
                
                    checkStringList = ans.Question_Template__r.Section_Question__r.Questionnaire_Section__r.Watchlist_Of_Words__c.split('~');
                    watchlisttext = '';
                
                    if(checkStringList.size() > 0) {
                        for(string st : checkStringList) {
                            if(ans.Response__c.indexOf(st) != -1) {
                                watchlisttext += st + ', ';
                            }
                        }                    
                        if(watchlisttext != '' && watchlisttext.lastIndexOf(',') != -1) {
                            watchlisttext = watchlisttext.substring(0, watchlisttext.lastIndexOf(','));
                            string sub = 'Watchlist - ' + watchlisttext + ' - '+ ans.Issue_Request__r.Name;
                            case cs = new Case(Description = ans.Response__c, Subject = sub);
                            caseList.add(cs);
                        }
                    }
                }
            }
            if(caseList != null && caseList.size() > 0) {
                insert caseList;
            }
        }       
        catch(Exception exp) {   
            throw exp;   
        }
    }
   
    public void generateCaseOrLead(List<IssueRequest_Life_Cycle__c> oldAMList, Map<ID, IssueRequest_Life_Cycle__c> newAMMap) {
       
        List<SObject> sObjList = new List<SObject>();       
        Set<Id> amIdSet = new Set<Id>();        
        Set<Id> templateIdSet = new Set<Id>();      
        Map<Id, string> templateIdEntityNameMap = new Map<Id, string>();        
        Map<string, Id> assessableFieldNameQtnTemplateIdMap = new Map<string, Id>();        
        Map<Id, string> qtnIdAnswerResponseMap = new Map<Id, string>();     
        Map<string, Schema.SObjectType> sObjectsMap = Schema.getGlobalDescribe();       
        try {       
            for(IssueRequest_Life_Cycle__c oldAM : oldAMList) {     
                IssueRequest_Life_Cycle__c newAM = newAMMap.get(oldAM.Id);      
                if((oldAM.Status__c != newAM.Status__c)     
                    && (examConfig.AMSubmitStatus == newAM.Status__c)       
                    && (newAM.InvestigationType__c != null)     
                ) {     
                    amIdSet.add( newAM.Id );        
                    templateIdSet.add( newAM.InvestigationType__c );        
                }       
            }   
            if (!templateIdSet.isEmpty()) {  
                for (Main_questionaire__c template : [SELECT Generate_Case_Or_Lead__c, Id, Name     
                                                      FROM   Main_questionaire__c       
                                                      WHERE  Id IN :templateIdSet AND Generate_Case_Or_Lead__c != null]) {      
                        templateIdEntityNameMap.put(template.Id, template.Generate_Case_Or_Lead__c);        
                }       
            }       
            if (templateIdEntityNameMap != null && templateIdEntityNameMap.size() > 0) {  

                for (Assessable_Fields_Mapping__c afm : [SELECT Assessable_Object_API__c, Assessable_Object_Field_API__c,       
                                                                Assessment_Template__c, Id, Is_Case_Response__c,        
                                                                Name, Question_Template__c      
                                                         FROM   Assessable_Fields_Mapping__c        
                                                         WHERE  Assessment_Template__c IN :templateIdEntityNameMap.KeySet()     
                                                                AND Assessable_Object_API__c IN :templateIdEntityNameMap.values()       
                                                                AND Is_Case_Response__c = true      
                                                                AND Assessable_Object_Field_API__c != null      
                                                                AND Question_Template__c != null]) {        
                        assessableFieldNameQtnTemplateIdMap.put(afm.Assessable_Object_Field_API__c, afm.Question_Template__c);      
                }  

                for (Questionnaire_Response__c ans : [SELECT CreatedDate, Issue_Request__c, Question_Template__c,       
                                                             Question_Template__r.Section_Question__c,      
                                                             Question_Template__r.Section_Question__r.Questionnaire_Section__c,     
                                                             Response__c        
                                                      FROM   Questionnaire_Response__c      
                                                      WHERE  Issue_Request__c IN :amIdSet       
                                                             AND Question_Template__r.Section_Question__r.Questionnaire_Section__c IN :templateIdEntityNameMap.KeySet() ORDER BY CreatedDate DESC]) {       
                        if (!qtnIdAnswerResponseMap.containsKey(ans.Question_Template__c) ) {       
                            qtnIdAnswerResponseMap.put(ans.Question_Template__c, ans.Response__c);      
                        }       
                }       
                string entity = '';
                List<string> fieldsListEntity = new List<string>();
                for (string templateId : templateIdEntityNameMap.keySet()) {        
                    entity = templateIdEntityNameMap.get(templateId);        
                    if ( (string.isNotBlank(entity)) && (sObjectsMap.containsKey(entity) && sObjectsMap.get(entity) != null) ) {        
                        Map<string, Schema.SObjectField> sObjFieldDescribeMap = sObjectsMap.get(entity).getDescribe().fields.getMap();      
                        if (assessableFieldNameQtnTemplateIdMap != null && assessableFieldNameQtnTemplateIdMap.size() > 0) {        
                            sObject sObj = sObjectsMap.get(entity).newSObject() ;       
                            for (string assessableObjectField : assessableFieldNameQtnTemplateIdMap.keySet()) {     
                                if (sObjFieldDescribeMap.containsKey(assessableObjectField) && sObjFieldDescribeMap.get(assessableObjectField) != null) {       
                                    Id qtnTemplateId = assessableFieldNameQtnTemplateIdMap.get(assessableObjectField);      
                                    if (qtnIdAnswerResponseMap.containsKey(qtnTemplateId) && qtnIdAnswerResponseMap.get(qtnTemplateId) != null) {       
                                        string ansRes = qtnIdAnswerResponseMap.get(qtnTemplateId);        
                                        fieldsListEntity.add(assessableObjectField); 
                                        Schema.DisplayType fieldType = sObjFieldDescribeMap.get(assessableObjectField).getDescribe().getType();
                                        if (fieldType == Schema.DisplayType.DATE) {
                                            string[] dateStr = (ansRes).split('/');
                                            Date response = date.newinstance( Integer.valueOf(dateStr[2]), Integer.valueOf(dateStr[1]), Integer.valueOf(dateStr[0]) );
                                            sObj.put(assessableObjectField, response);                                            
                                        } else if (fieldType == Schema.DisplayType.DATETIME) {
                                            string[] dateStr = (ansRes).split('/');
                                            Datetime response = dateTime.newinstance( Integer.valueOf(dateStr[2]), Integer.valueOf(dateStr[1]), Integer.valueOf(dateStr[0]) );
                                            sObj.put(assessableObjectField, response);
                                        } else if (fieldType == Schema.DisplayType.DOUBLE) {
                                            sObj.put(assessableObjectField, Decimal.valueOf(ansRes));
                                        } else if (fieldType == Schema.DisplayType.INTEGER) {
                                            sObj.put(assessableObjectField, Integer.valueOf(ansRes));
                                        } else {
                                            sObj.put(assessableObjectField, ansRes);
                                        } 
                                    }       
                                }       
                            }       
                            sObjList.add( sObj );       
                        }       
                    }       
                }
                if ((sObjList != null && sObjList.size() > 0)
                    && (string.isNotBlank(entity))
                    && (sObjectsMap.containsKey(entity) && sObjectsMap.get(entity) != null)
                ) {
                    insert sObjList;
                }       
            }       
        }       
        catch(Exception exp) {   
            throw exp;   
        }       
    }

    public static void executeFieldMappingOnAMSave(List<IssueRequest_Life_Cycle__c> newAMs, Map<ID, IssueRequest_Life_Cycle__c> oldAMMap, Boolean isCreateAM) {

        List<IssueRequest_Life_Cycle__c> contextAMs = new List<IssueRequest_Life_Cycle__c>();
        List<IssueRequest_Life_Cycle__c> filteredManagers = new List<IssueRequest_Life_Cycle__c>();
        Set<Id> templateIdSet = new Set<Id>();

        //Find which Reference field has value and prepare a map of Assignment Manager Id with Assessable Object Id{'a0H' => '001'}
        ExAMUtilClass.AssessableObjectInAMClass assessableObjectDetail = ExAMUtilClass.getAssessableObjectDetailsFromAM(newAMs);
        if (assessableObjectDetail != null) {

            Map<Id, Id> fieldsMap = assessableObjectDetail.managerIdWithAssessableObjectIdMap;                                    

            for (IssueRequest_Life_Cycle__c newAM : newAMs) {

                if (isCreateAM && newAM.InvestigationType__c != null
                    && (fieldsMap.containsKey(newAM.Id) && fieldsMap.get(newAM.Id) != null)
                ) {

                    templateIdSet.add( newAM.InvestigationType__c );
                    contextAMs.add( newAM );
                }
                else if (!isCreateAM) {

                    for (Schema.SObjectField amField : ExAMUtilClass.getSObjectFieldsMap('ExAM__IssueRequest_Life_Cycle__c').Values()) {

                        string amFieldAPI = amField.getDescribe().getName();
                        if (newAM.InvestigationType__c != null
                            && (fieldsMap.containsKey(newAM.Id) && fieldsMap.get(newAM.Id) != null)
                            && (oldAMMap.get(newAM.Id).get(amFieldAPI) != newAM.get(amFieldAPI))
                        ) {
    
                            templateIdSet.add( newAM.InvestigationType__c );
                            contextAMs.add( newAM );
                            break;
                        }
                    }
                }
            }
            if (contextAMs != null && contextAMs.size() > 0) {

                Map<Id, Main_questionaire__c> templateMap = new Map<Id, Main_questionaire__c>([SELECT Id, Execute_Field_Mapping_On_AM__c FROM Main_questionaire__c WHERE Id IN :templateIdSet AND Execute_Field_Mapping_On_AM__c = true]);

                for (IssueRequest_Life_Cycle__c newAM : contextAMs) {
                    if (templateMap.containsKey(newAM.InvestigationType__c) && templateMap.get(newAM.InvestigationType__c) != null ) {
                        filteredManagers.add( newAM );
                    }
                }
                if (filteredManagers != null && filteredManagers.size() > 0) {
                    ExAMUtilClass.updateAssessableObjectUsingFieldMapping(filteredManagers, true);
                }
            }
        }
    }
}