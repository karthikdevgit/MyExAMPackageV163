public with sharing class LoadScoreAndMapFieldValueInAMController {

    public LoadScoreAndMapFieldValueInAMController() {}
  
    public class TemplateDetail {
         
        public List<ExAM__Main_questionaire__c> templatelist;
        public string amStatus;
        public string errorMsg;
    }
    
    public class AMDetail {
         
         public List<ExAM__IssueRequest_Life_Cycle__c> assmanlist;
         public string Errormessage;
    }

    @RemoteAction
    public static TemplateDetail getTemplates(string templateName) {

        string amOverallStatus = '';
        List<ExAM__Main_questionaire__c> templateList = new List<ExAM__Main_questionaire__c>();
        TemplateDetail assessibleEntityDtls = new TemplateDetail();
       
        try{
           
            SFDCAccessController accessForobj = ExAMUtilClass.AccessController;
            List<string> fieldsList = new List<string>{'ExAM__Overall_Status_on_Submit__c'};
            accessForobj.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__ExAM_Configuration__c'), fieldsList);

            List<ExAM__ExAM_Configuration__c> configurationList = new List<ExAM__ExAM_Configuration__c>([SELECT Id, Name, ExAM__Overall_Status_on_Submit__c FROM ExAM__ExAM_Configuration__c WHERE Name = 'Configuration' LIMIT 1]);
            if (configurationList != null && configurationList.size() > 0) {
                if ( string.isNotBlank(configurationList[0].ExAM__Overall_Status_on_Submit__c) ) {
                    amOverallStatus = configurationList[0].ExAM__Overall_Status_on_Submit__c;
                }
                else {
                    amOverallStatus = 'Completed';
                }
            }
            else {
                amOverallStatus = 'Completed';
            }

            List<string> templateFieldsList = new List<string>{'ExAM__Template_Name__c'};
            accessForobj.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Main_questionaire__c'), templateFieldsList);
    
            string query_str = 'SELECT Id, Name, ExAM__Template_Name__c FROM ExAM__Main_questionaire__c';
    
            if ( string.isNotBlank(templateName) ) {
                query_str += ' WHERE ((Name LIKE \'%'+templateName+'%\') OR (ExAM__Template_Name__c LIKE \'%'+templateName+'%\'))';
            }
            query_str += ' LIMIT 100';
            templateList = Database.query( query_str );

            assessibleEntityDtls.templatelist = templateList;
            assessibleEntityDtls.errorMsg = '';
            assessibleEntityDtls.amStatus = amOverallStatus;

        }catch(Exception e){
            assessibleEntityDtls.templatelist = templateList;
            assessibleEntityDtls.amStatus = '';
            assessibleEntityDtls.errorMsg =  e.getMessage();
        }
        return assessibleEntityDtls;
    }

    @RemoteAction
    public static AMDetail getAssignmentManagers(string searchCriteria) {

        List<ExAM__IssueRequest_Life_Cycle__c> assignmentManagers = new List<ExAM__IssueRequest_Life_Cycle__c>();
        Map<string, Object> m = (Map<string, Object>)JSON.deserializeUntyped(searchCriteria);
        AMDetail assessibleEntityDtls = new AMDetail();
        
        try{

            string query_str = 'SELECT Id, ExAM__Status__c FROM ExAM__IssueRequest_Life_Cycle__c';

            if (m.containsKey('templateId') && m.get('templateId') != null) {
                string templateId = (string)m.get('templateId');
                query_str += ' WHERE ExAM__InvestigationType__c = \''+templateId+'\'';
            }
            if (m.containsKey('status') && m.get('status') != null) {
                string status = (string)m.get('status');
                query_str += ' AND ExAM__Status__c = \''+status+'\'';
            }
            SFDCAccessController accessForobj = ExAMUtilClass.AccessController;
            List<string> fieldsList = new List<string>{'ExAM__Status__c'};
            accessForobj.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__IssueRequest_Life_Cycle__c'), fieldsList);
            assignmentManagers = Database.query( query_str );
            assessibleEntityDtls.assmanlist = assignmentManagers;
            assessibleEntityDtls.Errormessage = '';
        }catch(Exception e){
            assessibleEntityDtls.assmanlist = assignmentManagers;
            assessibleEntityDtls.Errormessage = e.getMessage();
        }
        return assessibleEntityDtls;
    }

    @RemoteAction
    public static string loadScoreInSelectedAssignmentManagers(List<ExAM__IssueRequest_Life_Cycle__c> amList) {

        ScoreUpdateResponse response;

        string scoreUpdateResponseMsg = '';

        List<ExAM__Questionnaire_Response__c> answers = new List<ExAM__Questionnaire_Response__c>();
        List<ExAM__Questionnaire_Response__c> answersWithoutWeightList = new List<ExAM__Questionnaire_Response__c>();
        List<ExAM__Questionnaire_Response__c> answerUpdateList = new List<ExAM__Questionnaire_Response__c>();
        List<ExAM__IssueRequest_Life_Cycle__c> amUpdateList = new List<ExAM__IssueRequest_Life_Cycle__c>();

        Set<string> questionTypeSet = new Set<string>{'Button', 'Dropdown Picklist', 'MultiselectPicklist', 'RadioPicklist','Horizontal Radiopicklist'};
        Set<Id> qtnIdSet = new Set<Id>();

        Map<Id, Decimal> amIdwithTotalScoreMap = new Map<Id, Decimal>();
        Map<Id, Decimal> amIdwithMaxScoreMap = new Map<Id, Decimal>();
        Map<Id, List<string>> qtnIdWithOptionsMap = new Map<Id, List<string>>();
        Map<Id, List<string>> qtnIdWithWeightListMap = new Map<Id, List<string>>();

        try {

            if (amList != null && amList.size() > 0) {

                Map<Id, ExAM__IssueRequest_Life_Cycle__c> amMap = new Map<Id, ExAM__IssueRequest_Life_Cycle__c>(amList);

                SFDCAccessController accessForobj = ExAMUtilClass.AccessController;
                List<string> fieldsList = new List<string>{'ExAM__Issue_Request__c', 'ExAM__Max_Score__c', 'ExAM__Question_Template__c', 'ExAM__Response__c', 'ExAM__Total_Score__c', 'ExAM__Weight_Response__c'};
                accessForobj.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Questionnaire_Response__c'), fieldsList);
                    
                List<string> fieldsList1 = new List<string>{'ExAM__Question_Type__c', 'ExAM__Weight_of_Question__c', 'ExAM__Weight_of_Answer__c', 'ExAM__Subquestion_Label__c'};
                accessForobj.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Question_Template__c'), fieldsList1);

                for(ExAM__Questionnaire_Response__c ans : [SELECT Id, ExAM__Weight_Response__c, ExAM__Total_Score__c, ExAM__Max_Score__c, ExAM__Issue_Request__c,
                                                                ExAM__Question_Template__c, ExAM__Question_Template__r.ExAM__Question_Type__c,
                                                                ExAM__Question_Template__r.ExAM__Weight_of_Question__c, 
                                                                ExAM__Question_Template__r.ExAM__Weight_of_Answer__c,
                                                                ExAM__Question_Template__r.ExAM__Subquestion_Label__c,
                                                                ExAM__Response__c
                                                         FROM   ExAM__Questionnaire_Response__c
                                                         WHERE  ExAM__Issue_Request__c IN :amMap.keySet()
                                                                AND ExAM__Question_Template__r.ExAM__Question_Type__c IN :questionTypeSet
                                                                AND ExAM__Question_Template__r.ExAM__Weight_of_Question__c != null
                                                                AND ExAM__Question_Template__r.ExAM__Weight_of_Question__c > 0]) {

                    if (ans.ExAM__Weight_Response__c == null) {
                        answersWithoutWeightList.add( ans );
                        qtnIdSet.add( ans.ExAM__Question_Template__c );
                    }
                    else if (ans.ExAM__Weight_Response__c != null && ans.ExAM__Weight_Response__c > 0) {
                        answers.add( ans );
                    }
                }

                if (answersWithoutWeightList != null && answersWithoutWeightList.size() > 0) {

                    List<string> fieldsListAO = new List<string>{'ExAM__Help_Text__c', 'ExAM__Question_Template__c', 'ExAM__Weight__c'};
                    accessForobj.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Answer_Option__c'), fieldsListAO);

                    for(ExAM__Answer_Option__c options : [SELECT ExAM__Help_Text__c, Id, Name, ExAM__Question_Template__c, ExAM__Weight__c FROM ExAM__Answer_Option__c WHERE ExAM__Question_Template__c IN :qtnIdSet AND ExAM__Weight__c != null]){

                        if (!qtnIdWithWeightListMap.containsKey(options.ExAM__Question_Template__c)) {
                            qtnIdWithWeightListMap.put(options.ExAM__Question_Template__c, new List<string>());
                        }
                        string optnWeight = string.valueOf(options.ExAM__Weight__c);
                        qtnIdWithWeightListMap.get(options.ExAM__Question_Template__c).add( optnWeight );

                        if (!qtnIdWithOptionsMap.containsKey(options.ExAM__Question_Template__c)) {
                            qtnIdWithOptionsMap.put(options.ExAM__Question_Template__c, new List<string>());
                        }
                        qtnIdWithOptionsMap.get(options.ExAM__Question_Template__c).add( options.Name );
                    }

                    for(ExAM__Questionnaire_Response__c ans : answersWithoutWeightList) {

                        //calculate answer weight 
                        if (string.isNotBlank(ans.ExAM__Response__c)){
                                
                            ExAM__Questionnaire_Response__c answerRecord = new ExAM__Questionnaire_Response__c(Id = ans.Id);
                            List<string> answerWeightList = new List<string>();
                            List<string> answerOptions = new List<string>();
                            if (!qtnIdWithWeightListMap.containsKey(ans.ExAM__Question_Template__c)
                                && !qtnIdWithOptionsMap.containsKey(ans.ExAM__Question_Template__c)
                                && string.isNotBlank(ans.ExAM__Question_Template__r.ExAM__Weight_of_Answer__c)
                                && string.isNotBlank(ans.ExAM__Question_Template__r.ExAM__Subquestion_Label__c) ) {

                                answerWeightList = ans.ExAM__Question_Template__r.ExAM__Weight_of_Answer__c.split('~');
                                answerOptions = ans.ExAM__Question_Template__r.ExAM__Subquestion_Label__c.split('~');
                            } else {

                                answerWeightList = qtnIdWithWeightListMap.get(ans.ExAM__Question_Template__c);
                                answerOptions = qtnIdWithOptionsMap.get(ans.ExAM__Question_Template__c);
                            }
                                
                            for (integer i = 0 ; i < answerOptions.size() ; i++) {
                                if (ans.ExAM__Response__c.equalsIgnoreCase(answerOptions.get(i))) {
                                    if ((ans.ExAM__Response__c).equalsIgnoreCase('N/A') || (ans.ExAM__Response__c).equalsIgnoreCase('NA')) {
                                        answerRecord.ExAM__Weight_Response__c = -1;
                                    } else if( answerWeightList != null && answerWeightList.size() > i ) {
                                        answerRecord.ExAM__Weight_Response__c = (answerWeightList.get(i).trim() != '') ? Decimal.valueOf(answerWeightList.get(i)) : null;
                                    }
                                }
                            }
                            if (answerRecord.ExAM__Weight_Response__c > 0) {
                                answerUpdateList.add( answerRecord );
                            }
                        }
                    }
                    if ( answerUpdateList != null && answerUpdateList.size() > 0 ) {

                        List<string> fieldsList3 = new List<string>{'ExAM__Weight_Response__c'};
                        accessForobj.assertAuthorizedToUpdate(Schema.getGlobalDescribe().get('exam__Questionnaire_Response__c'), fieldsList3);

                        update answerUpdateList;
                            
                        List<string> fieldsList2 = new List<string>{'ExAM__Question_Template__c', 'ExAM__Response__c','ExAM__Weight_Response__c', 'ExAM__Total_Score__c', 'ExAM__Max_Score__c', 'ExAM__Issue_Request__c'};
                        accessForobj.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Questionnaire_Response__c'), fieldsList2);

                        List<ExAM__Questionnaire_Response__c> updatedAnswersWithWeightResponseList = new List<ExAM__Questionnaire_Response__c>([
                            SELECT Id, ExAM__Weight_Response__c, ExAM__Total_Score__c, ExAM__Max_Score__c, ExAM__Issue_Request__c,
                                   ExAM__Question_Template__c, ExAM__Question_Template__r.ExAM__Question_Type__c,
                                   ExAM__Question_Template__r.ExAM__Weight_of_Question__c, ExAM__Response__c
                            FROM   ExAM__Questionnaire_Response__c
                            WHERE  Id IN :answerUpdateList
                        ]);

                        if (updatedAnswersWithWeightResponseList != null && updatedAnswersWithWeightResponseList.size() > 0) {
                            answers.addAll( updatedAnswersWithWeightResponseList );
                        }
                        //answer object Update/Accessible  permission check if codn ends
                    }//answerUpdateList size check if codn ends
                }//answersWithoutWeightList size check if codn ends
                
                if (answers != null && answers.size() > 0) {

                    for(ExAM__Questionnaire_Response__c ans : answers) {

                        if (!amIdwithTotalScoreMap.containsKey(ans.ExAM__Issue_Request__c)) {
                            amIdwithTotalScoreMap.put(ans.ExAM__Issue_Request__c, 0.00);
                        }
                        amIdwithTotalScoreMap.put(ans.ExAM__Issue_Request__c, amIdwithTotalScoreMap.get(ans.ExAM__Issue_Request__c)+ans.ExAM__Total_Score__c);

                        if (!amIdwithMaxScoreMap.containsKey(ans.ExAM__Issue_Request__c)) {
                            amIdwithMaxScoreMap.put(ans.ExAM__Issue_Request__c, 0.00);
                        }
                        amIdwithMaxScoreMap.put(ans.ExAM__Issue_Request__c, amIdwithMaxScoreMap.get(ans.ExAM__Issue_Request__c)+ans.ExAM__Max_Score__c);
                    }
                    for (ExAM__IssueRequest_Life_Cycle__c am : amList) {
                        if ( amIdwithTotalScoreMap.containsKey(am.Id) || amIdwithMaxScoreMap.containsKey(am.Id) ) {

                            ExAM__IssueRequest_Life_Cycle__c amToUpdate = new ExAM__IssueRequest_Life_Cycle__c(Id = am.Id);
                            if (amIdwithTotalScoreMap.containsKey(am.Id) ) {
                                amToUpdate.ExAM__Total_Score__c = amIdwithTotalScoreMap.get(am.Id);
                            }
                            if (amIdwithMaxScoreMap.containsKey(am.Id) ) {
                                amToUpdate.ExAM__Max_Score__c = amIdwithMaxScoreMap.get(am.Id);
                            }
                            amUpdateList.add( amToUpdate );
                        }
                    }
                }
                if (amUpdateList != null && amUpdateList.size() > 0) {

                    List<string> fieldsList4 = new List<string>{'ExAM__Max_Score__c', 'ExAM__Total_Score__c'};
                    accessForobj.assertAuthorizedToUpdate(Schema.getGlobalDescribe().get('exam__IssueRequest_Life_Cycle__c'), fieldsList4);

                    update amUpdateList;
                }
                Set<string> amFieldApiNameSet = new Set<string>();
                Set<Id> amIdSet = new Set<Id>();
                amIdSet.addAll( amMap.keySet() );

                string SELECT_CLAUSE = '';
                string FROM_CLAUSE = 'IssueRequest_Life_Cycle__c';
                string WHERE_CLAUSE = 'Id IN :amIdSet';
                string QUERY_CLAUSE = '';

                Map<string, Schema.SObjectField> sObjFieldsMap = ExAMUtilClass.getSObjectFieldsMap( 'ExAM__IssueRequest_Life_Cycle__c' );
                if (sObjFieldsMap != null && sObjFieldsMap.size() > 0) {
                    for (Schema.SObjectField field : sObjFieldsMap.Values()) {

                        string AMFieldApiName = field.getDescribe().getName();
                        string AMFieldApiNameWithoutNameSpacePrefix = field.getDescribe().getLocalName();
                        if (!amFieldApiNameSet.contains(AMFieldApiNameWithoutNameSpacePrefix)) {
                            SELECT_CLAUSE += (string.isBlank(SELECT_CLAUSE)) ? AMFieldApiName : ', '+AMFieldApiName;
                            amFieldApiNameSet.add(AMFieldApiNameWithoutNameSpacePrefix);
                        }
                    }
                }
                QUERY_CLAUSE = 'SELECT '+SELECT_CLAUSE+' FROM '+FROM_CLAUSE+' WHERE '+WHERE_CLAUSE;

                List<IssueRequest_Life_Cycle__c> managersList = Database.query(QUERY_CLAUSE);
                if (managersList != null && managersList.size() > 0) {

                    ExAMUtilClass.updateAssessableObjectUsingFieldMapping(managersList, false);
                    response = new ScoreUpdateResponse(true, 'Assignment Manager(s) updated successfully');
                }
            }//amList size check if codn ends
        }
        catch(Exception exp) {

            response = new ScoreUpdateResponse(false, (exp.getTypeName() == 'System.DMLException') ? exp.getDmlMessage(0) : exp.getMessage());
        }
        if ( response != null ) {
            scoreUpdateResponseMsg = Json.serialize(response);
        }
        return scoreUpdateResponseMsg; 
    }

    public class ScoreUpdateResponse {
        public Boolean isSuccess;
        public string message;
        public ScoreUpdateResponse(Boolean hasCallSuccess, string msg) {
            this.isSuccess = hasCallSuccess;
            this.message = msg;
        }
    }
}