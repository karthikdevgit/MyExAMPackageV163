@isTest
private class TestAnswerSurveyController {
    public class SearchCriteriaClass{
        Id templateId;
        String status;
        List<Id> qtnIdList;
        String createdDate;
        String amStartDate;
        String amEndDate;
        public SearchCriteriaClass(Id templateId,String status,List<Id> qtnIdList,String createdDate,String amStartDate,String amEndDate){
            this.qtnIdList = new List<Id>();
            this.templateId = templateId;
            this.status = status;
            this.qtnIdList = qtnIdList;
            this.createdDate = createdDate;
            this.amStartDate = amStartDate;
            this.amEndDate = amEndDate;
        }
    }
    static testMethod void method1() {
        String searchCriteria = '';
        Main_questionaire__c assTemp = new Main_questionaire__c();
        assTemp.Template_name__c = 'Test Template';
        insert assTemp;
        
        Section_Template__c secTemp = new Section_Template__c();
        secTemp.Questionnaire_Section__c = assTemp.Id;
        insert secTemp;
        
        List<Question_Template__c> quesTemp = new List<Question_Template__c> {
            new Question_Template__c(Section_Question__c=secTemp.Id,Question_Label__c = 'Test Question1'),
            new Question_Template__c(Section_Question__c=secTemp.Id,Question_Label__c = 'Test Question2'),
            new Question_Template__c(Section_Question__c=secTemp.Id,Question_Label__c = 'Test Question3'),
            new Question_Template__c(Section_Question__c=secTemp.Id,Question_Label__c = 'Test Question4')
        };
        insert quesTemp;
        List<Id> quesIdList = new List<Id>();
        quesIdList.add(quesTemp[0].Id);
        quesIdList.add(quesTemp[1].Id);
        quesIdList.add(quesTemp[2].Id);
        quesIdList.add(quesTemp[3].Id);
        
        IssueRequest_Life_Cycle__c assManager = new IssueRequest_Life_Cycle__c();
        assManager.investigationType__c = assTemp.Id;
        assManager.Status__c = 'open';
        DateTime myDateTime = DateTime.newInstance(2017,03, 16, 23, 0, 0);
        Date myDate = myDateTime.dateGMT();
        DateTime myDateTime1 = DateTime.newInstance(2017,10,16,23, 0, 0);
        Date myDate1 = myDateTime1.dateGMT();
        assManager.Scheduled_Start_Date__c = myDate;
        assManager.Scheduled_End_Date__c = myDate1;
        insert assManager;
        System.debug('::::aaaaa'+assManager);
        List<IssueRequest_Life_Cycle__c> amlist = [SELECT CreatedDate, Id, Status__c, Scheduled_Start_Date__c, Scheduled_End_Date__c FROM IssueRequest_Life_Cycle__c];
        //String creDate = String.valueOf(amlist[0].CreatedDate.getTime());
        //String creDate = String.valueOf(amlist[0].CreatedDate);
        String creDate = String.valueOf('2017-10-24T09:31:08');
        String startDate = '2017/03/16';
        String endDate = '2017/10/16';
        List<Questionnaire_Response__c> quesResList = new List<Questionnaire_Response__c> {
            new Questionnaire_Response__c(Response__c='Test Response1',Priority__c='High',Issue_Request__c=assManager.Id,Question_Template__c=quesTemp[0].Id),
            new Questionnaire_Response__c(Response__c='Test Response2',Priority__c='Emergency',Issue_Request__c=assManager.Id,Question_Template__c=quesTemp[1].Id),
            new Questionnaire_Response__c(Response__c='Test Response3',Priority__c='high',Issue_Request__c=assManager.Id,Question_Template__c=quesTemp[2].Id),
            new Questionnaire_Response__c(Response__c='Test Response4',Priority__c='Emergency',Issue_Request__c=assManager.Id,Question_Template__c=quesTemp[3].Id)
        };
        insert quesResList;
        
        System.assert(quesResList.size()==4);
        List<Id> quesTempId = new List<Id>();
        quesTempId.add(quesTemp[0].Id);
        quesTempId.add(quesTemp[1].Id);
        
        SearchCriteriaClass searchCriteriaObj = new SearchCriteriaClass(assTemp.Id,'open',quesIdList,creDate,startDate,endDate);
        System.debug('searchCriteriaObj::'+searchCriteriaObj);
        searchCriteria = JSON.serialize(searchCriteriaObj);
        
        Test.startTest();
            AnswerSurveyController ansSurvey = new AnswerSurveyController();
            AnswerSurveyController.answerQuery(assTemp.Id,'15/10/2016','15/10/2016',quesTempId,'open');
            AnswerSurveyController.answerQuery1(assTemp.Id,'15/10/2016','15/10/2016',quesTempId,'open','1476447869000');
            AnswerSurveyController.questionTempalteQuery(assTemp.Id);
            String queryStr = AnswerSurveyController.queryAnswers(searchCriteria);
            String queryQuesStr = AnswerSurveyController.queryQuestionTemplates(searchCriteria);
            System.debug(':::::'+queryStr);
        Test.stopTest();
            quesIdList = new List<Id>();
            Main_questionaire__c assTemp1 = new Main_questionaire__c();
            assTemp1.Template_name__c = 'Test Template';
            insert assTemp1;
            SearchCriteriaClass searchCriteriaObj1 = new SearchCriteriaClass(assTemp1.Id,'open',quesIdList,creDate,startDate,endDate);
            System.debug('searchCriteriaObj::'+searchCriteriaObj1);
            String searchCriteria1 = JSON.serialize(searchCriteriaObj1);
            String queryStr1 = AnswerSurveyController.queryAnswers(searchCriteria1);
            String queryQuesStr1 = AnswerSurveyController.queryQuestionTemplates(searchCriteria1);
    }
}