@isTest
public class TestLoadScoreForExistingAM {
    
    @testSetup static void dataforTest() {
        
        Account acct = new Account(Name = 'Test Account');
        insert acct;
        
        Main_questionaire__c assessmentTemplate = new Main_questionaire__c(Template_name__c = 'Test Template');     
        insert assessmentTemplate;
        
        List<IssueRequest_Life_Cycle__c> amList = new List<IssueRequest_Life_Cycle__c>{
            new IssueRequest_Life_Cycle__c(Facility_Name__c = acct.Id, InvestigationType__c = assessmentTemplate.Id, Status__c = 'Completed'),
            new IssueRequest_Life_Cycle__c(Facility_Name__c = acct.Id, InvestigationType__c = assessmentTemplate.Id, Status__c = 'Completed')
        };
        insert amList;        
        
        Section_Template__c sectionTemplate = new Section_Template__c(Questionnaire_Section__c = assessmentTemplate.Id, Section_label__c = 'Test Section');
        insert sectionTemplate;
        
        List<Question_Template__c> qtList = new List<Question_Template__c>{
            new Question_Template__c(Question_Label__c = 'How can you rate our service?', Question_Type__c = 'Button', Section_Question__c = sectionTemplate.Id, 
                Subquestion_Label__c = 'Bad~Good~Excellent', Weight_of_Answer__c = '0~30~70', Weight_Of_Question__c = 10),
            new Question_Template__c(Question_Label__c = 'How can you rate our service?', Question_Type__c = 'Button', Section_Question__c = sectionTemplate.Id, Weight_Of_Question__c = 10),
            new Question_Template__c(Question_Label__c = 'How much experience do you have in this domain?', Question_Type__c = 'Dropdown Picklist', Section_Question__c = sectionTemplate.Id, 
                Subquestion_Label__c = 'Beginner~Intermediate~Advanced', Weight_of_Answer__c = '10~40~50', Weight_Of_Question__c = 10),
            new Question_Template__c(Question_Label__c = 'How fast you can do this work?', Question_Type__c = 'MultiselectPicklist', Section_Question__c = sectionTemplate.Id, 
                Subquestion_Label__c = 'Less than 1 day~1 day~2 days', Weight_of_Answer__c = '60~25~15', Weight_Of_Question__c = 10),
            new Question_Template__c(Question_Label__c = 'How easy is our service?', Question_Type__c = 'RadioPicklist', Section_Question__c = sectionTemplate.Id,            
                Subquestion_Label__c = 'Difficult~Flexible', Weight_of_Answer__c = '45~55', Weight_Of_Question__c = 10),
            new Question_Template__c(Question_Label__c = 'When did you started learning salesforce?', Question_Type__c = 'Date', Section_Question__c = sectionTemplate.Id)
        };
        insert qtList;
        
        Answer_Option__c[] options = new Answer_Option__c[]{
            new Answer_Option__c(Name = 'Bad', Order_No__c = 1, Question_Template__c  = qtList[1].Id, Weight__c = 0),
            new Answer_Option__c (Name = 'Good', Order_No__c = 2, Question_Template__c  = qtList[1].Id, Weight__c = 30),
            new Answer_Option__c(Name = 'Excellent', Order_No__c = 3, Question_Template__c  = qtList[1].Id, Weight__c = 70)
        };
        insert options;
                
        Assessable_Fields_Mapping__c[] fieldsMapping = new Assessable_Fields_Mapping__c[] {
            new Assessable_Fields_Mapping__c(Assessable_Object_API__c = 'Account', Assessable_Object_Field_API__c = 'Description', Assessment_Template__c = assessmentTemplate.Id, Question_Template__c = qtList[0].Id, Store_Answer_Response_Or_Score__c = 'Response'),
            new Assessable_Fields_Mapping__c(Assessable_Object_API__c = 'Account', Assessable_Object_Field_API__c = 'Overall_Score__c', Assessment_Template__c = assessmentTemplate.Id, Question_Template__c = qtList[0].Id, Store_Answer_Response_Or_Score__c = 'Score'),
            new Assessable_Fields_Mapping__c(Assessable_Object_API__c = 'Account', Assessable_Object_Field_API__c = 'Type', Assessment_Template__c = assessmentTemplate.Id, Assignment_Manager_Field_API__c = 'Status__c'),
            new Assessable_Fields_Mapping__c(Assessable_Object_API__c = 'Account', Assessable_Object_Field_API__c = 'SLAExpirationDate__c', Assessment_Template__c = assessmentTemplate.Id, Question_Template__c = qtList[5].Id, Store_Answer_Response_Or_Score__c = 'Response')
        };
        insert fieldsMapping;        
        
        Questionnaire_Response__c[] answers = new Questionnaire_Response__c[] {
            new Questionnaire_Response__c(Account_to_Response__c = acct.Id, Issue_Request__c = amList[0].Id, Question_Template__c = qtList[0].Id, Response__c = 'Good'),
            new Questionnaire_Response__c(Account_to_Response__c = acct.Id, Issue_Request__c = amList[0].Id, Question_Template__c = qtList[1].Id, Response__c = 'Good'),
            new Questionnaire_Response__c(Account_to_Response__c = acct.Id, Issue_Request__c = amList[0].Id, Question_Template__c = qtList[2].Id, Response__c = 'Advanced'),
            new Questionnaire_Response__c(Account_to_Response__c = acct.Id, Issue_Request__c = amList[0].Id, Question_Template__c = qtList[3].Id, Response__c = 'Less than 1 day'),
            new Questionnaire_Response__c(Account_to_Response__c = acct.Id, Issue_Request__c = amList[0].Id, Question_Template__c = qtList[4].Id, Response__c = 'Difficult'),
            new Questionnaire_Response__c(Account_to_Response__c = acct.Id, Issue_Request__c = amList[0].Id, Question_Template__c = qtList[4].Id, Response__c = 'Difficult', Weight_Response__c = 45),
            new Questionnaire_Response__c(Account_to_Response__c = acct.Id, Issue_Request__c = amList[1].Id, Question_Template__c = qtList[0].Id, Response__c = 'Good'),
            new Questionnaire_Response__c(Account_to_Response__c = acct.Id, Issue_Request__c = amList[1].Id, Question_Template__c = qtList[1].Id, Response__c = 'Good'),
            new Questionnaire_Response__c(Account_to_Response__c = acct.Id, Issue_Request__c = amList[1].Id, Question_Template__c = qtList[2].Id, Response__c = 'Advanced'),
            new Questionnaire_Response__c(Account_to_Response__c = acct.Id, Issue_Request__c = amList[1].Id, Question_Template__c = qtList[3].Id, Response__c = 'Less than 1 day'),
            new Questionnaire_Response__c(Account_to_Response__c = acct.Id, Issue_Request__c = amList[1].Id, Question_Template__c = qtList[4].Id, Response__c = 'Difficult'),
            new Questionnaire_Response__c(Account_to_Response__c = acct.Id, Issue_Request__c = amList[1].Id, Question_Template__c = qtList[4].Id, Response__c = 'Difficult', Weight_Response__c = 45),
            new Questionnaire_Response__c(Account_to_Response__c = acct.Id, Issue_Request__c = amList[1].Id, Question_Template__c = qtList[5].Id, Response__c = Date.today().format())
        };
        insert answers;
    }

    /**
    static testmethod void testGetTemplate() {
       
        ExAM_Configuration__c econ = new ExAM_Configuration__c();
        econ.Name = 'Configuration';
        insert econ;
        
        LoadScoreAndMapFieldValueInAMController amScoreUpdateClass = new LoadScoreAndMapFieldValueInAMController();
        
        LoadScoreAndMapFieldValueInAMController.TemplateDetail tempdetail = new LoadScoreAndMapFieldValueInAMController.TemplateDetail();
        tempdetail = LoadScoreAndMapFieldValueInAMController.getTemplates('Test Template');
        
        System.assertEquals(1, tempdetail.templatelist.size());
        System.assertEquals('Completed',tempdetail.amStatus);
    }
    **/   

    static testmethod void testGetAssignmentManager() {
               
        List<Main_questionaire__c> assTempList = new List<Main_questionaire__c>([SELECT Id, Name FROM Main_questionaire__c ORDER BY CreatedDate ASC]);

        Map<String, String> amMap = new Map<String, String>{'templateId'=> assTempList[0].Id, 'status' => 'Completed'};
        String searchCriteria = Json.serialize( amMap );

        LoadScoreAndMapFieldValueInAMController.AMDetail amd = new LoadScoreAndMapFieldValueInAMController.AMDetail();
        
        amd = LoadScoreAndMapFieldValueInAMController.getAssignmentManagers(searchCriteria);

        String updateresponse = LoadScoreAndMapFieldValueInAMController.loadScoreInSelectedAssignmentManagers( amd.assmanlist );
        LoadScoreAndMapFieldValueInAMController.ScoreUpdateResponse responseInstance = (LoadScoreAndMapFieldValueInAMController.ScoreUpdateResponse)Json.deserialize(updateresponse, LoadScoreAndMapFieldValueInAMController.ScoreUpdateResponse.class);
        system.assertEquals(responseInstance.isSuccess, true);
        system.assertEquals(responseInstance.message, 'Assignment Manager(s) updated successfully');

        List<Account> acctListAfter = new List<Account>([SELECT Id, Name, Description, Overall_Score__c, Type, SLAExpirationDate__c FROM Account]);
        if (acctListAfter != null && acctListAfter.size() > 0) {
            system.assertEquals('Good', acctListAfter[0].Description);
            system.assertEquals('Completed', acctListAfter[0].Type);
        }
    }
}