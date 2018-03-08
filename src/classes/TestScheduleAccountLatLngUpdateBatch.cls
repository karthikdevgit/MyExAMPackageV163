@isTest
public class TestScheduleAccountLatLngUpdateBatch {

     public class HttpResponseForCon implements HttpCalloutMock {
        
        public HTTPResponse respond(HTTPRequest req) {
            
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            res.setBody('{"results" : [{"address_components" : [{"long_name" : "3501","short_name" : "3501","types" : [ "street_number" ]}],"formatted_address" : "3501 N Broadway, Los Angeles, CA 90031, USA","geometry" : {"location" : {"lat" : 34.0747068,"lng" : -118.2040366},"location_type" : "ROOFTOP","viewport" : {"northeast" :{"lat" : 34.0760557802915,"lng" : -118.2026876197085},"southwest" : {"lat" : 34.07335781970851,"lng" : -118.2053855802915}}},"place_id" : "ChIJGWHkatTFwoAR6fHGxKBVcHs","types" : [ "street_address" ]}],"status" : "OK"}');
            res.setStatus('Ok');
            return res;
        }
    }
    
    @testSetup static void insertRecords() {
        
        Account acct = new Account(Name = 'Test Account', BillingCity = 'Test City', BillingCountry = 'Test Country', BillingStreet = 'Test Street', BillingPostalcode = '123456', BillingLatitude = null, BillingLongitude = null);
        insert acct; 

        List<Account> acctList = new List<Account>([SELECT Id, Name FROM Account LIMIT 1]);
        system.assertEquals(acctList.size(), 1);
    }
    
    static testmethod void testMethodScheduleAccountLatLngUpdateBatch(){
        
        Test.setMock(HttpCalloutMock.class, new HttpResponseForCon());
        Test.StartTest();
        System.schedule('ScheduleAccountLatLngUpdateBatch', '1 0 * * * ? *', new ScheduleAccountLatLngUpdateBatch());
        Test.StopTest();

        List<Account> acctList = new List<Account>([SELECT BillingLatitude, BillingLongitude, Id, Name FROM Account LIMIT 1]);
        system.assertEquals(acctList.size(), 1);
        system.assertEquals(acctList[0].BillingLatitude, null);
        system.assertEquals(acctList[0].BillingLongitude, null);
    }
}