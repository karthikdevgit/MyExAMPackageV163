@isTest
public class TestMapConfigCtrller {
    
    static testmethod void testMethodMapPinColorConfigCtrller(){
        
        Map_Pin_Color_Configuration__c mapInColorConfig = new Map_Pin_Color_Configuration__c(Name = 'Test Map Pin Color Config', Assessible_Object__c = 'Test Assessible Object', Assessible_Object_Field__c = 'Test Assessible Object', Color_Mapping__c = 'This is the sample test color mapping');
        insert mapInColorConfig;
        
        MapPinColorConfigCtrller mapPinColorConfigCtrl = new MapPinColorConfigCtrller();
        
        MapPinColorConfigCtrller.queryAllAccessibleObjsFromASM();
        
        //Map_Pin_Color_Configuration__c record Insertion.
        MapPinColorConfigCtrller.saveMapPinColorConfiguration(mapInColorConfig);
        
        List<Map_Pin_Color_Configuration__c> mapInColorConfigList = [SELECT Id, Name, Assessible_Object__c, Assessible_Object_Field__c, Color_Mapping__c FROM Map_Pin_Color_Configuration__c WHERE Id =:mapInColorConfig.Id];
        System.AssertEquals(mapInColorConfigList.size(), 1);
        System.AssertEquals(mapInColorConfigList[0].Assessible_Object_Field__c, 'Test Assessible Object');
        
        //Map_Pin_Color_Configuration__c record Deletion.
        MapPinColorConfigCtrller.deleteMapPinColorConfiguration(mapInColorConfig);
        
        List<Map_Pin_Color_Configuration__c> mapInColorConfigList1 = [SELECT Id, Name, Assessible_Object__c, Assessible_Object_Field__c, Color_Mapping__c FROM Map_Pin_Color_Configuration__c WHERE Id =:mapInColorConfig.Id];
        System.AssertEquals(mapInColorConfigList1.size(), 0);
    }
    
    static testmethod void testMethodMapPinColorConfigCtrller1(){
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Custom: Marketing Profile']; 
        User u = new User(Alias = 'newUser', Email='newuser@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='testus@tabc.co');
        
        
        System.runAs(u) {

            Map_Pin_Color_Configuration__c mapInColorConfig = new Map_Pin_Color_Configuration__c(Name = 'Test Map Pin Color Config', Assessible_Object__c = 'Test Assessible Object', Assessible_Object_Field__c = 'Test Assessible Object', Color_Mapping__c = 'This is the sample test color mapping');
            insert mapInColorConfig;
            
            //Map_Pin_Color_Configuration__c record Insertion.
            MapPinColorConfigCtrller.saveMapPinColorConfiguration(mapInColorConfig);
            
            delete mapInColorConfig;
            
            //Map_Pin_Color_Configuration__c record Deletion.
            string deleteResponse = MapPinColorConfigCtrller.deleteMapPinColorConfiguration(mapInColorConfig);
            system.assertEquals( deleteResponse, 'Exception-You do not have access to delete Map Pin Color Configuration' );
        }
    }
    
    static testmethod void testMethodMapPinColorConfigCtrller2(){
        
        
        Map_Pin_Color_Configuration__c mapInColorConfig = new Map_Pin_Color_Configuration__c(Name = 'Test Map Pin Color Config', Assessible_Object__c = 'Test Assessible Object', Assessible_Object_Field__c = 'Test Assessible Object', Color_Mapping__c = 'This is the sample test color mapping');
        insert mapInColorConfig;
        
        delete mapInColorConfig;
        
        //Map_Pin_Color_Configuration__c record Deletion.
        string deleteResponse = MapPinColorConfigCtrller.deleteMapPinColorConfiguration(mapInColorConfig);
        system.assertEquals( deleteResponse, 'Exception-entity is deleted' );
    }
    
    static testmethod void testMethodMapAnythingAddressConfigCtrller(){
        
        Map_Anything_Address_Configuration__c mapAnythingAddrConfig = new Map_Anything_Address_Configuration__c(Name = 'Test Map Anything Addr Config', Address__c = 'Test Address', City_Field_Name__c = 'Test City', Country_Field_Name__c = 'Test Country', Postal_Code_Field_Name__c = 'Test Postal Code', Street_Field_Name__c = 'Test Street');
        insert mapAnythingAddrConfig;
        
        MapAnythingAddressConfigCtrller mapPinColorConfigCtrl = new MapAnythingAddressConfigCtrller();
        
        MapAnythingAddressConfigCtrller.queryAllAccessibleObjsFromASM();
        
        //Map_Anything_Address_Configuration__c record Insertion.
        MapAnythingAddressConfigCtrller.saveMapAddressConfiguration(mapAnythingAddrConfig);
        
        List<Map_Anything_Address_Configuration__c> mapAnythingAddrConfigList = [SELECT Id, Name, Address__c, City_Field_Name__c, Country_Field_Name__c, Postal_Code_Field_Name__c, Street_Field_Name__c FROM Map_Anything_Address_Configuration__c WHERE Id = :mapAnythingAddrConfig.Id];
        System.AssertEquals(mapAnythingAddrConfigList.size(), 1);
        System.AssertEquals(mapAnythingAddrConfigList[0].Country_Field_Name__c, 'Test Country');
        
        
        //Map_Anything_Address_Configuration__c record Deletion.
        MapAnythingAddressConfigCtrller.deleteMapAddressConfiguration(mapAnythingAddrConfig);
        
        List<Map_Anything_Address_Configuration__c> mapAnythingAddrConfigList1 = [SELECT Id, Name, Address__c, City_Field_Name__c, Country_Field_Name__c, Postal_Code_Field_Name__c, Street_Field_Name__c FROM Map_Anything_Address_Configuration__c WHERE Id = :mapAnythingAddrConfig.Id];
        System.AssertEquals(mapAnythingAddrConfigList1.size(), 0);
    }
    
    static testmethod void testMethodMapAnythingAddressConfigCtrller1(){
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Custom: Marketing Profile']; 
        User u = new User(Alias = 'newUser', Email='newuser@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='testus1@tabc.co');
        
        
        System.runAs(u) {

            Map_Anything_Address_Configuration__c mapAnythingAddrConfig = new Map_Anything_Address_Configuration__c(Name = 'Test Map Anything Addr Config', Address__c = 'Test Address', City_Field_Name__c = 'Test City', Country_Field_Name__c = 'Test Country', Postal_Code_Field_Name__c = 'Test Postal Code', Street_Field_Name__c = 'Test Street');
            insert mapAnythingAddrConfig;
            
            //Map_Pin_Color_Configuration__c record Insertion.
            MapAnythingAddressConfigCtrller.saveMapAddressConfiguration(mapAnythingAddrConfig);
            
            delete mapAnythingAddrConfig;
            
            //Map_Pin_Color_Configuration__c record Deletion.
            string deleteResponse = MapAnythingAddressConfigCtrller.deleteMapAddressConfiguration(mapAnythingAddrConfig);
            system.assertEquals( deleteResponse, 'Exception-You don\'t have access to delete Map Anything Address Configuration' );
        }
    }
    
    static testmethod void testMethodMapAnythingAddressConfigCtrller2(){
        
        Map_Anything_Address_Configuration__c mapAnythingAddrConfig = new Map_Anything_Address_Configuration__c(Name = 'Test Map Anything Addr Config', Address__c = 'Test Address', City_Field_Name__c = 'Test City', Country_Field_Name__c = 'Test Country', Postal_Code_Field_Name__c = 'Test Postal Code', Street_Field_Name__c = 'Test Street');
        insert mapAnythingAddrConfig;
        
        delete mapAnythingAddrConfig;
        
        //Map_Anything_Address_Configuration__c record Deletion.
        string deleteResponse = MapAnythingAddressConfigCtrller.deleteMapAddressConfiguration(mapAnythingAddrConfig);
        system.assertEquals( deleteResponse, 'Exception-entity is deleted' );
    }
}