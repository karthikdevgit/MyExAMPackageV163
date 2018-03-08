@isTest
private class TestRestSaveFeedbackAnswers{
    @testSetup 
    static void createRecords() {
        Main_questionaire__c assTemp = new Main_questionaire__c();
        insert assTemp;
        
        ExAM_Configuration__c ec= new ExAM_Configuration__c();
        ec.Feedback_Template__c = assTemp.Id;
        insert ec;
        
        Section_Template__c sec = new Section_Template__c();
        sec.Questionnaire_Section__c  = assTemp.Id;
        insert sec;
        
        IssueRequest_Life_Cycle__c m1 = new IssueRequest_Life_Cycle__c();
        m1.InvestigationType__c = assTemp.Id;
        insert m1;
        
        Question_Template__c[] qList = new Question_Template__c[]{
            new Question_Template__c(Question_Type__c = 'TEXT',Section_Question__c = sec.Id),
                new Question_Template__c(Question_Type__c = 'TEXT',Section_Question__c = sec.Id)
        };
        insert qList;
        
        Questionnaire_Response__c answer = new Questionnaire_Response__c();
        answer.Question_Template__c = qList[0].Id;
        answer.Issue_Request__c = m1.Id;
        answer.Response__c = 'Satisfied';
        insert answer;
    }
    static testMethod void saveFeedbackAnswersMethod1() {
        List<Main_questionaire__c> assTempList = new List<Main_questionaire__c>([SELECT Id,Name FROM Main_questionaire__c LIMIT 1]);
        System.assertEquals(assTempList.size(),1);
        List<IssueRequest_Life_Cycle__c> assManagerList =  new List<IssueRequest_Life_Cycle__c>([SELECT Id,Name FROM IssueRequest_Life_Cycle__c LIMIT 1]);
        System.assertEquals(assManagerList.size(),1);
        List<Question_Template__c> quesTempList = new List<Question_Template__c>([SELECT Id,Name FROM Question_Template__c]);
        System.assertEquals(quesTempList.size(),2);
        List<Questionnaire_Response__c> ansList =  new List<Questionnaire_Response__c>([SELECT Id,Name FROM Questionnaire_Response__c LIMIT 1]);
        System.assertEquals(ansList.size(),1);
        
        RestSaveFeedbackAnswers.FeedbackAnswersClass ansCls = new RestSaveFeedbackAnswers.FeedbackAnswersClass();
        ansCls.answerList = ansList;
        ansCls.userId = UserInfo.getUserId();
        ansCls.screenName = '';
        ansCls.decisionTreeQuestionId = quesTempList[1].id;
        
        String result = RestSaveFeedbackAnswers.saveFeedbackAnswers(ansCls);
    }
}