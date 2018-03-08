global with sharing class UpdateAccountLocationBasedOnAddressBatch implements Database.Batchable<SObject>, Database.AllowsCallouts {

    global Database.QueryLocator start(Database.BatchableContext context) {

        String queryStr = 'SELECT BillingAddress, BillingCity, BillingCountry, BillingLatitude, BillingLongitude, ';
        queryStr += 'BillingPostalcode, BillingStreet, Id, Name ';
        queryStr += 'FROM Account ';
        queryStr += 'WHERE ((BillingLatitude = null AND BillingLongitude = null) AND ';
        queryStr += '((BillingStreet != null OR BillingCity != null) AND BillingPostalcode != null AND BillingCountry != null))';

        return Database.getQueryLocator(queryStr);
    }

    global void execute(Database.BatchableContext context, List<Account> scope) {

        Map<Id, Account> acctMap = new Map<Id, Account>();

        Map<String, ExAM__GoogleMapsAPIKey__c> allKeys = ExAM__GoogleMapsAPIKey__c.getAll();
        String GoogleMapsAPIKey = (allKeys.containskey('GoogleMapsAPIKey')? allKeys.get('GoogleMapsAPIKey').ExAM__API_Key__c : '');

        if( scope != null && scope.size() > 0 && String.isNotBlank(GoogleMapsAPIKey) ) {

            for(Account acct : scope) {

                String addressStr = '';

                if (String.isNotBlank(acct.BillingStreet)) {
                    addressStr = acct.BillingStreet+',';
                }
                if (String.isNotBlank(acct.BillingCity)) {

                    if (String.isNotBlank(addressStr)) {
                        addressStr = acct.BillingCity+',';
                    }
                    else {
                        addressStr += acct.BillingCity+',';
                    }
                }
                addressStr += acct.BillingPostalcode+','+acct.BillingCountry;

                // Callout.
                Http h = new Http();
                HttpRequest httpReq = new HttpRequest();
                httpReq.setEndpoint('https://maps.googleapis.com/maps/api/geocode/json?address='+addressStr+'&key='+GoogleMapsAPIKey); //+'&key='+GoogleMapsAPIKey+'&sensor=false'
                httpReq.setMethod('GET');
                httpReq.setTimeout(60000);
                HttpResponse httpResponseAddress = h.send(httpReq);

                string response_body = httpResponseAddress.getBody();
                Integer response_code = httpResponseAddress.getStatusCode();
                string response_status = httpResponseAddress.getStatus();
                system.debug(' response body '+response_body);


                if (response_code == 200 && response_status == 'OK') {

                    LatLngConversionResult response = (LatLngConversionResult)Json.deserialize(response_body, LatLngConversionResult.class);

                    if (response != null && response.results != null && response.results.size() > 0) {

                        Account act = new Account();
                        act.Id = acct.Id;
                        act.BillingLatitude = Decimal.valueOf(response.results[0].geometry.location.lat);
                        act.BillingLongitude = Decimal.valueOf(response.results[0].geometry.location.lng);
                        acctMap.put(act.Id, act);
                    }
                }
            }//end loop

            if (acctMap.size() > 0) {
                update acctMap.values();
            }

        }//end scope variable size greater than zero
    }//end execute method

    global void finish(Database.BatchableContext context) {}

    global class LatLngConversionResult {
        global string status;
        global string error_message;
        global List<LatLngConversion> results;
    }

    global class LatLngConversion {
        global GeometryClass geometry;
    }

    global class GeometryClass {
        global LocationClass location;
    }

    global class LocationClass {
        global string lat;
        global string lng;
    }
}