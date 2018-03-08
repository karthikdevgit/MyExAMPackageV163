@isTest 
private class TestRestGetAnswersForOneTimeAssesment {

    @testSetup
    static void createRecords() {
        Account acc = new Account();
        acc.Name = 'Test';
        insert acc;

        Main_questionaire__c assessmentTemplate = new Main_questionaire__c();
        assessmentTemplate.Template_Name__c = 'Test Template';
        assessmentTemplate.One_Time_Assessment__c = true;
        insert assessmentTemplate;

        Section_Template__c sectionTemplate = new Section_Template__c();
        sectionTemplate.Questionnaire_Section__c = assessmentTemplate.Id;
        sectionTemplate.Section_label__c = 'Test Section';
        insert sectionTemplate;

        Question_Template__c qtnTemplate = new Question_Template__c();
        qtnTemplate.Section_Question__c = sectionTemplate.Id;
        qtnTemplate.Question_Label__c = 'How is your experience with our service?';
        qtnTemplate.Subquestion_Label__c = 'Very Satisfied~Satisfied~Not Satisfied';
        qtnTemplate.Weight_of_Answer__c = '10~50~40';
        qtnTemplate.Question_Type__c = 'RadioPicklist';
        qtnTemplate.Weight_Of_Question__c = 10;
        insert qtnTemplate;

        IssueRequest_Life_Cycle__c managerRecord = new IssueRequest_Life_Cycle__c();
        managerRecord.investigationType__c = assessmentTemplate.Id;
        managerRecord.Facility_Name__c = acc.Id;
        managerRecord.scheduled_start_date__c = Date.today()-5;
        managerRecord.Show_Configuration_Options_in_Viewer__c = True;
        insert managerRecord;
        
        Questionnaire_Response__c answer = new Questionnaire_Response__c();
        answer.Question_Template__c = qtnTemplate.Id;
        answer.Issue_Request__c = managerRecord.Id;
        answer.Response__c = 'Satisfied';
        insert answer;
    
    }
    static testMethod void method1() {
        List<Main_questionaire__c> assTempList = new List<Main_questionaire__c>([SELECT Id,Name FROM Main_questionaire__c LIMIT 1]);
        System.assertEquals(assTempList.size(),1);
        List<IssueRequest_Life_Cycle__c> assManagerList =  new List<IssueRequest_Life_Cycle__c>([SELECT Id,Name FROM IssueRequest_Life_Cycle__c LIMIT 1]);
        System.assertEquals(assManagerList.size(),1);
        List<Question_Template__c> quesTempList = new List<Question_Template__c>([SELECT Id,Name FROM Question_Template__c LIMIT 1]);
        System.assertEquals(quesTempList.size(),1);
        List<Questionnaire_Response__c> ansList =  new List<Questionnaire_Response__c>([SELECT Id,Name FROM Questionnaire_Response__c LIMIT 1]);
        System.assertEquals(ansList.size(),1);
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/OTAAnswers/';  
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
            String results = RestGetAnswersForOneTimeAssesment.getAnswersForOneTimeAssesment(assTempList[0].Id,assManagerList[0].Id,'');
            MobileAppUtill.FilteredSectionAndQuestionTemplateAndAnswerClass returnResponse = (MobileAppUtill.FilteredSectionAndQuestionTemplateAndAnswerClass)JSON.deserialize(results,MobileAppUtill.FilteredSectionAndQuestionTemplateAndAnswerClass.class);
            System.assertEquals(returnResponse.quesIdANDAnsIdMap.get(quesTempList[0].Id),ansList[0].Id);
        Test.stopTest();
    }
}