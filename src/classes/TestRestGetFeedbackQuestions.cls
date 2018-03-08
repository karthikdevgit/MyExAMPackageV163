@isTest
private class TestRestGetFeedbackQuestions{
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
       
    }
    static testMethod void getFeedbackQuestionsMethod1() {
        RestGetFeedbackQuestions.FeedbackQuestionsClass feedbackQuestion = new RestGetFeedbackQuestions.FeedbackQuestionsClass();
        String result = RestGetFeedbackQuestions.getFeedbackQuestions(feedbackQuestion);
        List<RestGetFeedbackQuestions.FeedbackQuestionTemplateClass> feedbackQuestionTemplateList = (List<RestGetFeedbackQuestions.FeedbackQuestionTemplateClass>)JSON.deserialize(result, List<RestGetFeedbackQuestions.FeedbackQuestionTemplateClass>.class);
        System.assertEquals(feedbackQuestionTemplateList.size(), 2);
    }
}