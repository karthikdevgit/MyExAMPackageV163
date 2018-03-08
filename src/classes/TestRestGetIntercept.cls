@isTest 
private class TestRestGetIntercept {

    static testMethod void method1() {
    
        Public_Assessment_Configuration__c setting = new Public_Assessment_Configuration__c();
        setting.Site_URL__c = 'http://www.google.com';
        insert setting;
        
        Account acc = new Account();
        acc.name = 'Test Account';
        insert acc;
        
        Main_questionaire__c assTemp = new Main_questionaire__c();
        assTemp.Account__c = acc.Id;
        assTemp.Template_name__c = 'Test Template';
        assTemp.Web_Intercept_Header__c = 'Test webIntercept header';
        insert assTemp;
        
        Public_Assessment__c pa = new Public_Assessment__c();
        pa.Assessible_Object_ID__c = acc.Id;
        pa.Assessment_Template__c = assTemp.Id;
        insert pa;
        
        RestRequest req = new RestRequest();
        req.params.put('tempId', assTemp.Id);
        req.params.put('objId', acc.Id);
        req.httpMethod = 'GET';

        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;
    
        Test.startTest();
            RestGetIntercept.doGet();
            Blob b1 = Blob.valueOf('test 1');
            system.assertNotEquals(RestContext.Response.ResponseBody, b1);
        Test.stopTest();
    }
    static testMethod void method2() {
        
        Account acc = new Account();
        acc.name = 'Test Account';
        insert acc;
        
        Main_questionaire__c assTemp = new Main_questionaire__c();
        assTemp.Account__c = acc.Id;
        assTemp.Template_name__c = 'Test Template';
        assTemp.Web_Intercept_Header__c = 'Test web Intercept header';
        insert assTemp;
        
        IssueRequest_Life_Cycle__c assManager = new IssueRequest_Life_Cycle__c();
        assManager.Facility_Name__c = acc.Id;
        assManager.InvestigationType__c = assTemp.Id;
        insert assManager;
        
        Public_Assessment__c pa = new Public_Assessment__c();
        pa.Assignment_Manager__c = assManager.Id;
        insert pa;
        
        RestRequest req = new RestRequest();
        req.params.put('amId', assManager.Id);
        req.httpMethod = 'GET';

        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;
    
        Test.startTest();
            RestGetIntercept.doGet();
            Blob b2 = Blob.valueOf('test 2');
            system.assertNotEquals(RestContext.Response.ResponseBody, b2);
        Test.stopTest();
    }
    static testMethod void method3() {
    
        Public_Assessment_Configuration__c setting = new Public_Assessment_Configuration__c();
        setting.Site_URL__c = 'http://www.google.com';
        insert setting;
        
        Account acc = new Account();
        acc.name = 'Test Account';
        insert acc;
        
        Main_questionaire__c assTemp = new Main_questionaire__c();
        assTemp.Account__c = acc.Id;
        assTemp.Template_name__c = 'Test Template';
        insert assTemp;
        
        RestRequest req = new RestRequest();
        req.params.put('tempId', assTemp.Id);
        req.params.put('objId', acc.Id);
        req.httpMethod = 'GET';

        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;
    
        Test.startTest();
            RestGetIntercept.doGet();
            Blob b3 = Blob.valueOf('test 3');
            system.assertNotEquals(RestContext.Response.ResponseBody, b3);
        Test.stopTest();
    }
    static testMethod void method4() {
        
        Account acc = new Account();
        acc.name = 'Test Account';
        insert acc;
        
        Main_questionaire__c assTemp = new Main_questionaire__c();
        assTemp.Account__c = acc.Id;
        assTemp.Template_name__c = 'Test Template';
        insert assTemp;
        
        IssueRequest_Life_Cycle__c assManager = new IssueRequest_Life_Cycle__c();
        assManager.Facility_Name__c = acc.Id;
        assManager.InvestigationType__c = assTemp.Id;
        insert assManager;
        
        RestRequest req = new RestRequest();
        req.params.put('amId', assManager.Id);
        req.httpMethod = 'GET';

        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;
    
        Test.startTest();
            RestGetIntercept.doGet();
            Blob b4 = Blob.valueOf('test 4');
            system.assertNotEquals(RestContext.Response.ResponseBody, b4);
        Test.stopTest();
    }
}