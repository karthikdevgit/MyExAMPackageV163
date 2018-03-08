@isTest
private class TestAssignmentManagerTrigger {

    @isTest static void protectMorethenOneCustomLookupValuePopulate() {
        Account acc = new Account();
        acc.Name = 'Test';
        insert acc;
        
        contact con = new contact();
        con.AccountId=acc.id;
        con.LastName ='testCon';
        insert con;
        
        ExAM_Configuration__c config = new ExAM_Configuration__c();
        config.Name ='Configuration';
        config.Decision_Tree__c='TestFiels';
        config.Is_Field_Mapping__c = true;
        insert config;
        
        List<Main_questionaire__c> assTempList = new List<Main_questionaire__c>{
            new Main_questionaire__c(Account__c = acc.Id,ContactOrganization__c = con.Id,Template_name__c='Test1'),
            new Main_questionaire__c(Account__c = acc.Id,ContactOrganization__c = con.Id,Template_name__c='test2')
        };
        insert assTempList;
        
        List<Section_Template__c> secTempList = new List<Section_Template__c>{
            new Section_Template__c(Questionnaire_Section__c = assTempList[0].Id),
            new Section_Template__c(Questionnaire_Section__c = assTempList[0].Id),
            new Section_Template__c(Questionnaire_Section__c = assTempList[1].Id),
            new Section_Template__c(Questionnaire_Section__c = assTempList[1].Id)
        };
        insert secTempList;
        
        List<Question_Template__c> quesTemplList = new List<Question_Template__c>{
            new Question_Template__c(Section_Question__c = secTempList[0].Id),
            new Question_Template__c(Section_Question__c = secTempList[0].Id),
            new Question_Template__c(Section_Question__c = secTempList[1].Id),
            new Question_Template__c(Section_Question__c = secTempList[1].Id),
            new Question_Template__c(Section_Question__c = secTempList[2].Id),
            new Question_Template__c(Section_Question__c = secTempList[2].Id),
            new Question_Template__c(Section_Question__c = secTempList[3].Id),
            new Question_Template__c(Section_Question__c = secTempList[3].Id)
        };
        insert quesTemplList;
        
        List<IssueRequest_Life_Cycle__c> assManagerList = new List<IssueRequest_Life_Cycle__c>{
            new IssueRequest_Life_Cycle__c(InvestigationType__c= assTempList[0].Id,Scheduled_Start_Date__c = Date.today()),
            new IssueRequest_Life_Cycle__c(InvestigationType__c= assTempList[1].Id,Scheduled_Start_Date__c = Date.today())
        };
        insert assManagerList;
        
        List<Questionnaire_Response__c> quesTemp = new List<Questionnaire_Response__c>{
            new Questionnaire_Response__c(Question_Template__c = quesTemplList[0].Id,Issue_Request__c = assManagerList[0].Id, Response__c = 'test2'),
            new Questionnaire_Response__c(Question_Template__c = quesTemplList[0].Id,Issue_Request__c = assManagerList[0].Id, Response__c = 'test3'),
            new Questionnaire_Response__c(Question_Template__c = quesTemplList[1].Id,Issue_Request__c = assManagerList[0].Id, Response__c = 'test4'),
            new Questionnaire_Response__c(Question_Template__c = quesTemplList[1].Id,Issue_Request__c = assManagerList[0].Id, Response__c = 'test5'),
            new Questionnaire_Response__c(Question_Template__c = quesTemplList[2].Id,Issue_Request__c = assManagerList[1].Id, Response__c = 'test6'),
            new Questionnaire_Response__c(Question_Template__c = quesTemplList[2].Id,Issue_Request__c = assManagerList[1].Id, Response__c = 'test7'),
            new Questionnaire_Response__c(Question_Template__c = quesTemplList[3].Id,Issue_Request__c = assManagerList[1].Id, Response__c = 'test8'),
            new Questionnaire_Response__c(Question_Template__c = quesTemplList[3].Id,Issue_Request__c = assManagerList[1].Id, Response__c = 'test9')
        };
        insert quesTemp; 
        
        List<Questionnaire_Response__c> quesTempUpdate = new List<Questionnaire_Response__c>{
            new Questionnaire_Response__c(Id = quesTemp[0].Id, Question_Template__c = quesTemplList[0].Id,Issue_Request__c = assManagerList[0].Id, Response__c = 'test2'),
            new Questionnaire_Response__c(Id = quesTemp[1].Id, Question_Template__c = quesTemplList[0].Id,Issue_Request__c = assManagerList[0].Id, Response__c = 'test3'),
            new Questionnaire_Response__c(Id = quesTemp[2].Id, Question_Template__c = quesTemplList[1].Id,Issue_Request__c = assManagerList[0].Id, Response__c = 'test4'),
            new Questionnaire_Response__c(Id = quesTemp[3].Id, Question_Template__c = quesTemplList[1].Id,Issue_Request__c = assManagerList[0].Id, Response__c = 'test5'),
            new Questionnaire_Response__c(Id = quesTemp[4].Id, Question_Template__c = quesTemplList[2].Id,Issue_Request__c = assManagerList[1].Id, Response__c = 'test6'),
            new Questionnaire_Response__c(Id = quesTemp[5].Id, Question_Template__c = quesTemplList[2].Id,Issue_Request__c = assManagerList[1].Id, Response__c = 'test7'),
            new Questionnaire_Response__c(Id = quesTemp[6].Id, Question_Template__c = quesTemplList[3].Id,Issue_Request__c = assManagerList[1].Id, Response__c = 'test8'),
            new Questionnaire_Response__c(Id = quesTemp[7].Id, Question_Template__c = quesTemplList[3].Id,Issue_Request__c = assManagerList[1].Id, Response__c = 'test9')
        };
        update quesTemp; 
        List<Assessable_Fields_Mapping__c> afmList = new List<Assessable_Fields_Mapping__c> {
            new Assessable_Fields_Mapping__c(Assessable_Object_API__c = 'Account', Assessable_Object_Field_API__c = 'Name', Assessment_Template__c = assTempList[0].Id , Question_Template__c = quesTemplList[0].Id)
        };
        insert afmList;
        
        List<IssueRequest_Life_Cycle__c> updateassManagerList = new List<IssueRequest_Life_Cycle__c>{
            new IssueRequest_Life_Cycle__c(Id = assManagerList[0].Id, Facility_Name__c = acc.Id, InvestigationType__c= assTempList[0].Id,Scheduled_Start_Date__c = Date.today(), Status__c = 'Completed'),
            new IssueRequest_Life_Cycle__c(Id = assManagerList[1].Id, Facility_Name__c = acc.Id, InvestigationType__c= assTempList[1].Id,Scheduled_Start_Date__c = Date.today(), Status__c = 'Completed')
        };
        update updateassManagerList;

        List<Account> acctList = new List<Account>([SELECT Id, Name FROM Account WHERE Id = :acc.Id LIMIT 1]);
        system.assertEquals(acctList[0].Name, 'Test');
    }    
}