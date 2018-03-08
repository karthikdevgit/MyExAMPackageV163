@isTest
public class TestRestGetAMAndAccountData {

    @testSetUp
    static void testData() {

        Account[] AccTestData = new Account[] {
            new Account(ExAM__Account_External_Id__c = 'ACC0001', Name = 'Test Account 1', Rating = 'Hot', Type = 'Prospect'),
            new Account(ExAM__Account_External_Id__c = 'ACC0002', Name = 'Test Account 2', Rating = 'Hot', Type = 'Installation Partner'),
            new Account(ExAM__Account_External_Id__c = 'ACC0003', Name = 'Test Account 3', Rating = 'Warm', Type = 'Technology Partner'),
            new Account(ExAM__Account_External_Id__c = 'ACC0004', Name = 'Test Account 4', Rating = 'Warm', Type = 'Customer - Direct'),
            new Account(ExAM__Account_External_Id__c = 'ACC0005', Name = 'Test Account 5', Rating = 'Cold', Type = 'Other')
        };
        insert AccTestData; 

        ExAM__Main_questionaire__c TemplateTestData = new ExAM__Main_questionaire__c(ExAM__Template_name__c = 'Test Template');
        insert TemplateTestData;

        ExAM__IssueRequest_Life_Cycle__c[] AMTestData = new ExAM__IssueRequest_Life_Cycle__c[] {
            new ExAM__IssueRequest_Life_Cycle__c(ExAM__Facility_Name__c = AccTestData[0].Id, ExAM__Assignment_External_Id__c = 'AM0001', ExAM__InvestigationType__c = TemplateTestData.Id, ExAM__Priority__c = 'Routine', ExAM__Status__c = 'Open'),
            new ExAM__IssueRequest_Life_Cycle__c(ExAM__Facility_Name__c = AccTestData[1].Id, ExAM__Assignment_External_Id__c = 'AM0002', ExAM__InvestigationType__c = TemplateTestData.Id, ExAM__Priority__c = 'Routine', ExAM__Status__c = 'Open'),
            new ExAM__IssueRequest_Life_Cycle__c(ExAM__Facility_Name__c = AccTestData[2].Id, ExAM__Assignment_External_Id__c = 'AM0003', ExAM__InvestigationType__c = TemplateTestData.Id, ExAM__Priority__c = 'Emergency', ExAM__Status__c = 'In Progress'),
            new ExAM__IssueRequest_Life_Cycle__c(ExAM__Facility_Name__c = AccTestData[3].Id, ExAM__Assignment_External_Id__c = 'AM0004', ExAM__InvestigationType__c = TemplateTestData.Id, ExAM__Priority__c = 'Emergency', ExAM__Status__c = 'In Progress'),
            new ExAM__IssueRequest_Life_Cycle__c(ExAM__Facility_Name__c = AccTestData[4].Id, ExAM__Assignment_External_Id__c = 'AM0005', ExAM__InvestigationType__c = TemplateTestData.Id, ExAM__Priority__c = 'High', ExAM__Status__c = 'On Hold')
        };
        insert AMTestData; 
    }

    /**
        Test method with no data
    **/
    static testmethod void method1() {

        Blob b = Blob.valueOf('');

        RestRequest req = new RestRequest();
        req.requestBody = b;

        RestContext.request = req;

        RestGetAMAndAccountData.ResponseClass response = RestGetAMAndAccountData.getAMandAccountData();
        system.assertEquals(response.message, 'Please provide a valid request to get Assignment Manager and Account data');
    }

    /**
        Test method with invalid data
    **/
    static testmethod void method2() {

        List<Account> AccTestData = new List<Account>([SELECT Id, Name, ExAM__Account_External_Id__c, Rating, Type FROM Account]);
        List<ExAM__IssueRequest_Life_Cycle__c> AMTestData = new List<ExAM__IssueRequest_Life_Cycle__c>([SELECT Id, Name, ExAM__Facility_Name__c, ExAM__Assignment_External_Id__c, ExAM__InvestigationType__c, ExAM__Priority__c, ExAM__Status__c FROM ExAM__IssueRequest_Life_Cycle__c]);

        RestGetAMAndAccountData.AssignmentManagerDetails amDetail = new RestGetAMAndAccountData.AssignmentManagerDetails();
        amDetail.recIds = new List<Id>();
        amDetail.externalIds = new List<string>{'AM0015'};
        amDetail.fields = new List<string>{'ExAM__Facility_Name__c', 'ExAM__Assignment_External_Id__c', 'ExAM__InvestigationType__c', 'ExAM__Priority__c', 'ExAM__Status__c'};

        RestGetAMAndAccountData.AccountDetails acctDetail = new RestGetAMAndAccountData.AccountDetails();
        acctDetail.recIds = new List<Id>();
        acctDetail.externalIds = new List<string>{'ACC0101'};
        acctDetail.fields = new List<string>{'ExAM__Account_External_Id__c', 'Name', 'Rating', 'Type'};

        RestGetAMAndAccountData.UserDataInput userData = new RestGetAMAndAccountData.UserDataInput();
        userData.amData = amDetail;
        userData.acctData = acctDetail;

        string jsonInput = Json.serialize( userData );
        Blob b = Blob.valueOf(jsonInput);

        RestRequest req = new RestRequest();
        req.requestBody = b;

        RestContext.request = req;

        RestGetAMAndAccountData.ResponseClass response = RestGetAMAndAccountData.getAMandAccountData();
        system.assertEquals(response.message, 'Data not exists for given request. Please make sure that supplied ids are valid');
    }

    /**
        Test method to retrieve am and account data based on record id
    **/
    static testmethod void method3() {

        List<Account> AccTestData = new List<Account>([SELECT Id, Name, ExAM__Account_External_Id__c, Rating, Type FROM Account]);
        List<ExAM__IssueRequest_Life_Cycle__c> AMTestData = new List<ExAM__IssueRequest_Life_Cycle__c>([SELECT Id, Name, ExAM__Facility_Name__c, ExAM__Assignment_External_Id__c, ExAM__InvestigationType__c, ExAM__Priority__c, ExAM__Status__c FROM ExAM__IssueRequest_Life_Cycle__c]);

        RestGetAMAndAccountData.AssignmentManagerDetails amDetail = new RestGetAMAndAccountData.AssignmentManagerDetails();
        amDetail.recIds = new List<Id>{AMTestData[4].Id};
        amDetail.externalIds = new List<string>();
        amDetail.fields = new List<string>{'ExAM__Facility_Name__c', 'ExAM__Assignment_External_Id__c', 'ExAM__InvestigationType__c', 'ExAM__Priority__c', 'ExAM__Status__c'};

        RestGetAMAndAccountData.AccountDetails acctDetail = new RestGetAMAndAccountData.AccountDetails();
        acctDetail.recIds = new List<Id>{AccTestData[0].Id, AccTestData[1].Id};
        acctDetail.externalIds = new List<string>();
        acctDetail.fields = new List<string>{'ExAM__Account_External_Id__c', 'Name', 'Rating', 'Type'};

        RestGetAMAndAccountData.UserDataInput userData = new RestGetAMAndAccountData.UserDataInput();
        userData.amData = amDetail;
        userData.acctData = acctDetail;

        string jsonInput = Json.serialize( userData );
        Blob b = Blob.valueOf(jsonInput);

        RestRequest req = new RestRequest();
        req.requestBody = b;

        RestContext.request = req;

        RestGetAMAndAccountData.ResponseClass response = RestGetAMAndAccountData.getAMandAccountData();
        system.assertEquals(response.message, 'SUCCESS');
        system.assertEquals(response.AssignmentManagers.size(), 1);
        system.assertEquals(response.Accounts.size(), 2);
    }

    /**
        Test method to retrieve am and account data based on external id
    **/
    static testmethod void method4() {

        List<Account> AccTestData = new List<Account>([SELECT Id, Name, ExAM__Account_External_Id__c, Rating, Type FROM Account]);
        List<ExAM__IssueRequest_Life_Cycle__c> AMTestData = new List<ExAM__IssueRequest_Life_Cycle__c>([SELECT Id, Name, ExAM__Facility_Name__c, ExAM__Assignment_External_Id__c, ExAM__InvestigationType__c, ExAM__Priority__c, ExAM__Status__c FROM ExAM__IssueRequest_Life_Cycle__c]);

        RestGetAMAndAccountData.AssignmentManagerDetails amDetail = new RestGetAMAndAccountData.AssignmentManagerDetails();
        amDetail.recIds = new List<Id>();
        amDetail.externalIds = new List<string>{'AM0001', 'AM0003', 'AM0005'};
        amDetail.fields = new List<string>{'ExAM__Facility_Name__c', 'ExAM__Assignment_External_Id__c', 'ExAM__InvestigationType__c', 'ExAM__Priority__c', 'ExAM__Status__c'};

        RestGetAMAndAccountData.AccountDetails acctDetail = new RestGetAMAndAccountData.AccountDetails();
        acctDetail.recIds = new List<Id>();
        acctDetail.externalIds = new List<string>{'ACC0002', 'ACC0004'};
        acctDetail.fields = new List<string>{'ExAM__Account_External_Id__c', 'Name', 'Rating', 'Type'};

        RestGetAMAndAccountData.UserDataInput userData = new RestGetAMAndAccountData.UserDataInput();
        userData.amData = amDetail;
        userData.acctData = acctDetail;

        string jsonInput = Json.serialize( userData );
        Blob b = Blob.valueOf(jsonInput);

        RestRequest req = new RestRequest();
        req.requestBody = b;

        RestContext.request = req;

        RestGetAMAndAccountData.ResponseClass response = RestGetAMAndAccountData.getAMandAccountData();
        system.assertEquals(response.message, 'SUCCESS');
        system.assertEquals(response.AssignmentManagers.size(), 3);
        system.assertEquals(response.Accounts.size(), 2);
    }

}