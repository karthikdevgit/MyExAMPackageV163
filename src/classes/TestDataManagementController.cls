@isTest 
public class TestDataManagementController {

     static testMethod void method1() {
        ExAM_Configuration__c[] configList = new ExAM_Configuration__c[]{
        	new ExAM_Configuration__c(Name = 'test config',Knowledge_Article_Type_Name__c = 'test article type',
                                     Knowledge_Article_Content_Field_Name__c = 'test field name',
                                     Data_Management_Tab_Filter__c = 'test filter1,test filter2'
                                     )    
        };
        insert configList;
         
        Account acc = new Account();
        acc.Name ='Test';
        insert acc;
        
        contact con = new contact();
        con.AccountId = acc.Id;
        con.LastName = 'TestLastName';
        insert con;
        
        Main_questionaire__c assTemp = new Main_questionaire__c();
        insert assTemp;
        
        IssueRequest_Life_Cycle__c assManager1 = new IssueRequest_Life_Cycle__c();
        assManager1.investigationType__c = assTemp.Id;
        insert assManager1;
        
        IssueRequest_Life_Cycle__c assManager = new IssueRequest_Life_Cycle__c();
        assManager.investigationType__c = assTemp.Id;
        assManager.Related_Assignment_Manager1__c = assManager1.Id;
        assManager.Related_Assignment_Manager2__c = assManager1.Id;
        assManager.Related_Assignment_Manager3__c = assManager1.Id;
        insert assManager;
        
        Section_Template__c secTemp = new Section_Template__c();
        secTemp.Questionnaire_Section__c = assTemp.Id;
        insert secTemp;
        
        Question_Template__c quesTemp = new Question_Template__c();
        quesTemp.Section_Question__c = secTemp.Id;
        insert quesTemp;
        
        Questionnaire_Response__c queRes = new Questionnaire_Response__c();
        queRes.Question_Template__c = quesTemp.Id;
        queRes.Account_to_Response__c = acc.Id;
        queRes.deficiency_status__c = 'Closed';
        queRes.Comment__c = 'Test';
        queRes.Issue_Request__c = assManager.Id;
        queRes.Weight_Response__c = 765629;
        queRes.Response__c = 'test';
        queRes.Responsible_Party__c = con.Id;
        queRes.Priority__c ='high';
        insert queRes;
        
        ApexPages.currentPage().getParameters().put('amid',assManager.Id);
        
        DataManagementController.queryAllAnswerRecords(assManager.Id,false);
        String deleteAnswerRecordResult = DataManagementController.deleteAnswerRecord(queRes.Id);
        
        System.assertEquals('success', deleteAnswerRecordResult);
        DataManagementController dataMngmt = new DataManagementController();
         
        ExAM_Configuration__c econfig = new ExAM_Configuration__c();
        econfig.Data_Management_Tab_Filter__c = 'test filter';
        econfig.Id = configList[0].Id;
        configList[0] = econfig;
        update configList;
         
        DataManagementController.queryAllAnswerRecords(assManager.Id,false);
    }
    static testMethod void method2() {
        
        Account acc = new Account();
        acc.Name ='Test';
        insert acc;
        
        contact con = new contact();
        con.AccountId = acc.Id;
        con.LastName = 'TestLastName';
        insert con;
        
        Main_questionaire__c assTemp = new Main_questionaire__c();
        insert assTemp;
        
        IssueRequest_Life_Cycle__c assManager1 = new IssueRequest_Life_Cycle__c();
        assManager1.investigationType__c = assTemp.Id;
        insert assManager1;
        
        IssueRequest_Life_Cycle__c assManager = new IssueRequest_Life_Cycle__c();
        assManager.investigationType__c = assTemp.Id;
        assManager.Related_Assignment_Manager1__c = assManager1.Id;
        assManager.Related_Assignment_Manager2__c = assManager1.Id;
        assManager.Related_Assignment_Manager3__c = assManager1.Id;
        insert assManager;
        
        Section_Template__c secTemp = new Section_Template__c();
        secTemp.Questionnaire_Section__c = assTemp.Id;
        insert secTemp;
        
        Question_Template__c quesTemp = new Question_Template__c();
        quesTemp.Section_Question__c = secTemp.Id;
        insert quesTemp;
        
        Questionnaire_Response__c queRes = new Questionnaire_Response__c();
        queRes.Question_Template__c = quesTemp.Id;
        queRes.Account_to_Response__c = acc.Id;
        queRes.deficiency_status__c = 'Closed';
        queRes.Comment__c = 'Test';
        queRes.Issue_Request__c = assManager.Id;
        queRes.Weight_Response__c = 765629;
        queRes.Response__c = 'test';
        queRes.Responsible_Party__c = con.Id;
        queRes.Priority__c ='high';
        insert queRes;
        
        Attachment attach = new Attachment();
        attach.ParentId = queRes.Id;
        attach.name = 'testAttach';
        attach.Body = Blob.valueof('TestAttachBody');
        insert attach;
        
        ApexPages.currentPage().getParameters().put('amid',assManager.Id);
        
        DataManagementController.queryAllAnswerRecords(assManager.Id,true);
        String deleteAnswerRecordResult = DataManagementController.deleteAnswerRecord(queRes.Id);
        
        System.assertEquals('success', deleteAnswerRecordResult);
        DataManagementController dataMngmt = new DataManagementController();
        
    }
    
}