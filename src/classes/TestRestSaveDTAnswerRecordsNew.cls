/**
    Code coverage for RestSaveDecisionTreeAnswerRecordsNew class
**/

@isTest 
private class TestRestSaveDTAnswerRecordsNew {

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

        List<Question_Template__c> qtnTemplateList = new List<Question_Template__c>{
            new Question_Template__c(Section_Question__c = sectionTemplate.Id,Question_Label__c = 'DT Launched Ques',Question_Type__c = 'RadioPicklist',Weight_Of_Question__c = 10),
            new Question_Template__c(Section_Question__c = sectionTemplate.Id,Question_Label__c = 'Radio Picklist1',Question_Type__c = 'RadioPicklist',Weight_Of_Question__c = 10),
            new Question_Template__c(Section_Question__c = sectionTemplate.Id,Question_Label__c = 'Radio Picklist2',Question_Type__c = 'RadioPicklist',Weight_Of_Question__c = 10),
            new Question_Template__c(Section_Question__c = sectionTemplate.Id,Question_Label__c = 'Result1',Question_Type__c = 'Result',Weight_Of_Question__c = 10),
            new Question_Template__c(Section_Question__c = sectionTemplate.Id,Question_Label__c = 'Radio Picklist3',Question_Type__c = 'RadioPicklist',Weight_Of_Question__c = 10),
            new Question_Template__c(Section_Question__c = sectionTemplate.Id,Question_Label__c = 'Radio Picklist3',Question_Type__c = 'RadioPicklist',Weight_Of_Question__c = 10),
            new Question_Template__c(Section_Question__c = sectionTemplate.Id,Question_Label__c = 'Result2',Question_Type__c = 'Result',Weight_Of_Question__c = 10)
        };
        insert qtnTemplateList;
        List<Answer_Option__c> ansOptionList = new List<Answer_Option__c>{
            new Answer_Option__c(Name = 'DTOption1',Next_Question__c = qtnTemplateList[1].Id,Order_No__c = 1,Question_Template__c = qtnTemplateList[0].Id ),
            new Answer_Option__c(Name = 'DTOption2',Next_Question__c = qtnTemplateList[1].Id,Order_No__c = 2,Question_Template__c = qtnTemplateList[0].Id ),
            new Answer_Option__c(Name = 'RP1Option1',Next_Question__c = qtnTemplateList[2].Id,Order_No__c = 1,Question_Template__c = qtnTemplateList[1].Id ),
            new Answer_Option__c(Name = 'RP1Option2',Next_Question__c = qtnTemplateList[2].Id,Order_No__c = 2,Question_Template__c = qtnTemplateList[1].Id ),
            new Answer_Option__c(Name = 'RP2Option1',Next_Question__c = qtnTemplateList[3].Id,Order_No__c = 1,Question_Template__c = qtnTemplateList[2].Id ),
            new Answer_Option__c(Name = 'RP2Option2',Next_Question__c = qtnTemplateList[3].Id,Order_No__c = 2,Question_Template__c = qtnTemplateList[2].Id ),
            new Answer_Option__c(Name = 'Result1 Response',Next_Question__c = qtnTemplateList[4].Id,Order_No__c = 1,Question_Template__c = qtnTemplateList[3].Id ),
            new Answer_Option__c(Name = 'RP3Option1',Next_Question__c = qtnTemplateList[5].Id,Order_No__c = 1,Question_Template__c = qtnTemplateList[4].Id ),
            new Answer_Option__c(Name = 'RP3Option2',Next_Question__c = qtnTemplateList[5].Id,Order_No__c = 1,Question_Template__c = qtnTemplateList[4].Id ),
            new Answer_Option__c(Name = 'RP4Option1',Next_Question__c = qtnTemplateList[6].Id,Order_No__c = 1,Question_Template__c = qtnTemplateList[5].Id ),
            new Answer_Option__c(Name = 'RP4Option2',Next_Question__c = qtnTemplateList[6].Id,Order_No__c = 1,Question_Template__c = qtnTemplateList[5].Id )
        };
        insert ansOptionList;

        IssueRequest_Life_Cycle__c managerRecord = new IssueRequest_Life_Cycle__c();
        managerRecord.investigationType__c = assessmentTemplate.Id;
        managerRecord.Facility_Name__c = acc.Id;
        managerRecord.scheduled_start_date__c = Date.today()-5;
        managerRecord.Show_Configuration_Options_in_Viewer__c = True;
        insert managerRecord;
        
        Questionnaire_Response__c answer = new Questionnaire_Response__c();
        answer.Question_Template__c = qtnTemplateList[0].Id;
        answer.Issue_Request__c = managerRecord.Id;
        answer.Response__c = 'Satisfied';
        insert answer;
    
    }
    static testMethod void method1() {
        List<Main_questionaire__c> assTempList = new List<Main_questionaire__c>([SELECT Id,Name FROM Main_questionaire__c LIMIT 1]);
        System.assertEquals(assTempList.size(),1);
        List<IssueRequest_Life_Cycle__c> assManagerList =  new List<IssueRequest_Life_Cycle__c>([SELECT Id,Name FROM IssueRequest_Life_Cycle__c LIMIT 1]);
        System.assertEquals(assManagerList.size(),1);
        List<Question_Template__c> quesTempList = new List<Question_Template__c>([SELECT Id,Name FROM Question_Template__c]);
        System.assertEquals(quesTempList.size(),7);
        List<Questionnaire_Response__c> ansList =  new List<Questionnaire_Response__c>([SELECT Id,Name FROM Questionnaire_Response__c LIMIT 1]);
        System.assertEquals(ansList.size(),1);
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/SaveDecisionTreeNew/';  
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
            RestSaveDecisionTreeAnswerRecordsNew.DecisionTreeResponseClass param = new RestSaveDecisionTreeAnswerRecordsNew.DecisionTreeResponseClass();
            param.dtResponseList = ansList;
            param.oneTimeAss = true;
            param.startQuestion = quesTempList[0].Id;
            param.templateId = assTempList[0].Id;
            
            String results = RestSaveDecisionTreeAnswerRecordsNew.saveDecisionTreeAnswerRecords(param);
            
        Test.stopTest();
    }
}