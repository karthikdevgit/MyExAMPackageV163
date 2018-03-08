// Test cases for class 'AdminConfigController'
@isTest
public class TestAdminConfigController{
    static testMethod void method1(){
        ExAM__GoogleMapsAPIKey__c  customset = new ExAM__GoogleMapsAPIKey__c( Name ='GoogleMapsAPIKey',ExAM__API_Key__c ='12345') ;
        insert customset;
        ExAM__SF_sub_domain__c domainURLName = new ExAM__SF_sub_domain__c (Name = 'EndPointURL', EndPointURL__c = 'https://xx.salesforce.com');
        insert domainURLName;
        
        
        AdminConfigController con = new AdminConfigController();
        con.gleMapAPI.ExAM__API_Key__c = '67899';
        con.showEditFlag();
        con.updateCustomSetting();
        
        
        
        con.selectedObj = 'Opportunity';
        con.alreadyCreatedFields();
        //PageReference pageref = con.SaveEndpointUrl();
        //pageReference showEndpoint = con.showEditEndpointUrl();
        con.loadObjects();
        
        pageReference createfield = con.createLookupField();
        
        System.assertEquals(con.selectedObj,'Opportunity');        
        
        
        
        
    }
}