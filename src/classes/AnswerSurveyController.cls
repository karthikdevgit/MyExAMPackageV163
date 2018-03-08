global with sharing class AnswerSurveyController {

    public string assTempJSON {get;set;}
    public string statusJSON {get;set;}
    public string accessViolationMsg {get;set;}

    public class AnswersDetail {
        public List<Questionnaire_Response__c> answers;
        public string errorMsg;
    }

    public class QtnsPerAssessmentTemplateDetails {
        public List<Question_Template__c> questions;
        public string errorMsg;
    }

    public AnswerSurveyController() {

        assTempJSON = '';
        statusJSON = '';
        accessViolationMsg = '';

        try {
            List<Main_questionaire__c> assTempList = new List<Main_questionaire__c>();
            List<string> statusList = new List<string>();

            SFDCAccessController accessAT = ExAMUtilClass.AccessController;
            List<string> fieldsListAT = new List<string>{'ExAM__Template_name__c'};
            accessAT.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Main_questionaire__c'), fieldsListAT);

            assTempList = [SELECT Id, Name, Template_name__c FROM Main_questionaire__c ORDER BY LastModifiedDate DESC LIMIT 1000];
            assTempJSON = JSON.serialize(assTempList);

            statusList.add('---None---');
            Schema.DescribeFieldResult fieldResult = IssueRequest_Life_Cycle__c.Status__c.getDescribe();
            List<Schema.PicklistEntry> options = fieldResult.getPicklistValues();
            for( Schema.PicklistEntry f : options) {
                statusList.add(f.getValue());
            }       
            statusJSON = JSON.serialize(statusList); 
        }
        catch(Exception e) {
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
            accessViolationMsg = e.getMessage();
        }
     }

    //useless method
    @RemoteAction 
    global static List<Questionnaire_Response__c> answerQuery(string selectedAssTemp,string AMstartDate,string AMendDate,list<Id> selectedQuesTempIdList,string overallStatus) {
        return null;
    }

    @RemoteAction 
    global static List<Questionnaire_Response__c> answerQuery1(string selectedAssTemp,string AMstartDate,string AMendDate,list<Id> selectedQuesTempIdList,string overallStatus,string createdDate) {
        return null;
    }        

    @RemoteAction 
    global static string queryAnswers(string searchCriteria) {

        string response = '';
        AnswersDetail ansDtl = new AnswersDetail();

        try {

            DateTime createdStartDate, createdEndDate;

            Map<string, Object> searchMap = (Map<string, Object>)Json.deserializeUntyped(searchCriteria);
            string selectedAssTemp = (string)searchMap.get('templateId');
            string createdDate = (string)searchMap.get('createdDate');
            string amStartDate = (string)searchMap.get('amStartDate');
            string amEndDate = (string)searchMap.get('amEndDate');
            string status = (string)searchMap.get('status');
            System.debug(':::::createdDate:::::'+createdDate);
            SFDCAccessController accessAM = ExAMUtilClass.AccessController;
            List<string> fieldsListAM = new List<string>{'ExAM__Priority__c'};
            accessAM.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__IssueRequest_Life_Cycle__c'), fieldsListAM);

            SFDCAccessController accessQT = ExAMUtilClass.AccessController;
            List<string> fieldsListQT = new List<string>{'ExAM__Question_Label__c'};
            accessQT.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Question_Template__c'), fieldsListQT);

            SFDCAccessController accessAnswer = ExAMUtilClass.AccessController;
            List<string> fieldsListAnswer = new List<string>{'ExAM__Issue_Request__c', 'ExAM__Question_Template__c', 'ExAM__Response__c'};
            accessAnswer.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Questionnaire_Response__c'), fieldsListAnswer);

            string queryConfig = 'SELECT CreatedDate, ExAM__Issue_Request__c, ExAM__Issue_Request__r.Name,';
            queryConfig += ' ExAM__Issue_Request__r.ExAM__Priority__c, ExAM__Question_Template__r.ExAM__Question_Label__c,';
            queryConfig += ' ExAM__Response__c, Id';
            queryConfig += ' FROM ExAM__Questionnaire_Response__c';

            if (selectedAssTemp != null && selectedAssTemp !='') {
                queryConfig += ' WHERE ExAM__Issue_Request__r.ExAM__InvestigationType__c =\''+string.EscapeSingleQuotes(selectedAssTemp)+'\'';
            }
            if (createdDate != null && createdDate != '') {
                System.debug(':::::createdDate9999:::::'+createdDate);
                string[] tempArr = createdDate.split('T');
                
                //Long dtLong = Long.ValueOf(createdDate);
                System.debug('::tempArr:::'+tempArr);
                DateTime dtTime = DateTime.newInstance(Integer.valueOf(tempArr[0].split('-')[0]),Integer.valueOf(tempArr[0].split('-')[1]),Integer.valueOf(tempArr[0].split('-')[2]),Integer.valueOf(tempArr[1].split(':')[0]),Integer.valueOf(tempArr[1].split(':')[1]),0);
                System.debug(':::::dtTime:::::'+dtTime);
                string dtstring = dtTime.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
                System.debug(':::::dtstring:::::'+dtstring);
                queryConfig +=' AND CreatedDate <'+dtstring; 
            }
            if (amStartDate != null && amStartDate != '' && amStartDate.split('/').size() == 3) {
                string eDt;
                string sDt;
                string[] dateStr = amStartDate.split('/');
                createdStartDate = dateTime.newinstance( Integer.valueOf(dateStr[2]), Integer.valueOf(dateStr[0]), Integer.valueOf(dateStr[1]) );  
                sDt = createdStartDate.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
                System.debug(':::::sDt:::::'+sDt);
                if(amEndDate != null && amEndDate != '' && amEndDate.split('/').size() == 3){
                    string[] dateStr2 = amEndDate.split('/');
                    createdEndDate = dateTime.newinstance( Integer.valueOf(dateStr2[2]), Integer.valueOf(dateStr2[0]), Integer.valueOf(dateStr2[1]) );
                    createdEndDate = createdEndDate.addDays(1);
                    eDt = createdEndDate.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
                } else {
                    eDt = 'today';
                }
                System.debug(':::::eDt:::::'+eDt);
                queryConfig += ' AND ExAM__Issue_Request__r.CreatedDate >='+sDt+' AND ExAM__Issue_Request__r.CreatedDate <='+eDt; 
            }
            if (status != null && status != '') {
                queryConfig += ' AND ExAM__Issue_Request__r.ExAM__Status__c =\''+string.EscapeSingleQuotes(status)+'\''; 
            }
            if (searchMap.containsKey('qtnIdList') != null && searchMap.get('qtnIdList')!= null) {
                List<Object> objs = (List<Object>)searchMap.get('qtnIdList');
                Integer i = 0;
                string qtnIds = '';
                for(Object obj : objs) {

                    string quesId = (string)obj;
                    if(i == 0) {
                        qtnIds = '\''+string.EscapeSingleQuotes(quesId)+'\'';
                    } else {
                        qtnIds += ', \''+string.EscapeSingleQuotes(quesId)+'\'';  
                    } 
                    i++;     
                }
                if (qtnIds != '' && qtnIds != null) {
                    qtnIds = '('+qtnIds+')';
                    queryConfig +=' AND ExAM__Question_Template__c IN '+qtnIds;
                }
                else {
                    queryConfig +=' AND ExAM__Question_Template__c != null';
                }
            }
            queryConfig += ' ORDER BY CreatedDate DESC LIMIT 30000';
            system.debug('::::::::'+queryConfig);

            ansDtl.answers = Database.query(queryConfig);
            ansDtl.errorMsg = '';

        } catch(Exception ex) {
            ansDtl.answers = new List<Questionnaire_Response__c>();
            ansDtl.errorMsg = ex.getMessage();
        }
        response = Json.serialize(ansDtl);
        return response;
    }

    @RemoteAction 
    global static List<Question_Template__c> questionTempalteQuery(string assTempId) {
        return new List<Question_Template__c>();
    }

    @RemoteAction 
    global static string queryQuestionTemplates(string searchCriteria) {

        string response = '';
        QtnsPerAssessmentTemplateDetails qtnsPerAt = new QtnsPerAssessmentTemplateDetails();

        try {
            if(searchCriteria != null && searchCriteria !='') {

                Map<string, Object> searchMap = (Map<string, Object>)Json.deserializeUntyped(searchCriteria);
                string assTempId = (string)searchMap.get('templateId');

                SFDCAccessController accessQT = ExAMUtilClass.AccessController;
                List<string> fieldsListQT = new List<string>{'ExAM__Question_Label__c'};
                accessQT.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Question_Template__c'), fieldsListQT);

                List<Question_Template__c> quesTempList = new List<Question_Template__c>();
                quesTempList = [
                    SELECT Id, Name, Question_Label__c
                    FROM   Question_Template__c
                    WHERE  Section_Question__r.Questionnaire_Section__c = :assTempId
                ];
                if (quesTempList != null && quesTempList.size() > 0) {
                    qtnsPerAt.questions = quesTempList;
                    qtnsPerAt.errorMsg = '';
                }
                else {
                    qtnsPerAt.questions = new List<Question_Template__c>();
                    qtnsPerAt.errorMsg = 'Question Templates not exists below selected Assessment Template';
                }
            }
        } catch(Exception ex) {
            qtnsPerAt.questions = new List<Question_Template__c>();
            qtnsPerAt.errorMsg = ex.getMessage();
        }
        response = Json.serialize( qtnsPerAt );
        return response;
    }
}