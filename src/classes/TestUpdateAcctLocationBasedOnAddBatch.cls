@isTest
global class TestUpdateAcctLocationBasedOnAddBatch {
    
    global class MockHttpResponseGenerator implements HttpCalloutMock {
        // Implement this interface method
        global HTTPResponse respond(HTTPRequest req) {
            // Optionally, only send a mock response for a specific endpoint
            // and method.
            // System.assertEquals('http://api.salesforce.com/foo/bar', req.getEndpoint());
            //System.assertEquals('GET', req.getMethod());
            
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"results":[{"address_components":[{"long_name":"625001","short_name":"625001","types":["postal_code"]},{"long_name":"Madurai","short_name":"Madurai","types":["locality","political"]},{"long_name":"Madurai","short_name":"Madurai","types":["administrative_area_level_2","political"]},{"long_name":"Tamil Nadu","short_name":"TN","types":["administrative_area_level_1","political"]},{"long_name":"India","short_name":"IN","types":["country","political"]}],"formatted_address":"Madurai, Tamil Nadu 625001, India","geometry":{"bounds":{"northeast":{"lat":9.931976899999999,"lng":78.1301907},"southwest":{"lat":9.9013498,"lng":78.108856}},"location":{"lat":9.915706199999999,"lng":78.1193823},"location_type":"APPROXIMATE","viewport":{"northeast":{"lat":9.931976899999999,"lng":78.1301907},"southwest":{"lat":9.9013498,"lng":78.108856}}},"place_id":"ChIJU0OYCYPFADsRYYmjihENWb0","types":["postal_code"]}],"status":"OK"}');
            res.setStatusCode(200);
            res.setStatus('OK');
            
            return res;
        }
    }
    static testMethod void method1(){
        
        GoogleMapsAPIKey__c key = new GoogleMapsAPIKey__c();
        key.API_Key__c = 'hjksdabdsnfkjsdafnskdfa';
        key.Name = 'GoogleMapsAPIKey';
        insert key;
        
        List<Account> accList = new List<Account>();
        for(Integer i = 0;i<10;i++){
            if ( i == 0 ){
                accList.add(new Account(Name = 'test'+i,BillingCity = 'Madurai',BillingPostalcode = '625001',BillingCountry = 'India' ));
            }
            else{
                accList.add(new Account(Name = 'test'+i,BillingCity = 'Madurai',BillingPostalcode = '625001',BillingCountry = 'India',BillingStreet = 'mdu' ));
            }
        }
        insert accList;
        
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        //Test.startTest();
        UpdateAccountLocationBasedOnAddressBatch batchObj = new UpdateAccountLocationBasedOnAddressBatch();            
        ID batchprocessid = Database.executeBatch(batchObj);

        Test.stopTest();

        List<Account> acctList = new List<Account>([SELECT BillingLatitude, BillingLongitude, Id, Name FROM Account LIMIT 1]);
        system.assertEquals(acctList.size(), 1);
        system.assertNotEquals(acctList[0].BillingLatitude, null);
        system.assertNotEquals(acctList[0].BillingLongitude, null);
    }
}