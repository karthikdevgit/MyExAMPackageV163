@isTest
private class TestAssessmentMapUserImplementorCtlr {

    static testMethod void method1() {
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.BillingCity = 'test City';
        acc.BillingCountry = 'test country';
        acc.BillingState = 'test state';
        acc.BillingStreet = 'test Street';
        acc.BillingLatitude = 74.6;
        acc.BillingLongitude = 76.7;
        insert acc;
        
        Main_questionaire__c assTemp = new Main_questionaire__c();
        assTemp.Template_name__c = 'Unit Template';
        assTemp.Account__c = acc.Id;
        insert assTemp;
        
        Assessment_Group__c assGrp = new Assessment_Group__c();
        assGrp.Type__c = 'Account';
        insert assGrp;
        
        Assessment_Event__c assEvent = new Assessment_Event__c();
        assEvent.Description__c = 'Test Description';
        assEvent.Event_Date__c = System.today();
        assEvent.Event_Start_Time__c = System.now().addHours(-4);
        assEvent.Event_Finish_Time__c = System.now().addHours(1);
        insert assEvent;
        
        Map_Anything_Address_Configuration__c mapConfig = new Map_Anything_Address_Configuration__c();
        mapConfig.Name = 'Account';
        mapConfig.Address__c = 'BillingStreet';
        insert mapConfig;
        
        IssueRequest_Life_Cycle__c assManager = new IssueRequest_Life_Cycle__c();
        assManager.Facility_Name__c = acc.Id;
        assManager.Assessment_Form_Completion__c = 'Complete';
        assManager.Assessment_Event__c = assEvent.Id;
        assManager.Assessment_Group__c = assGrp.Id;
        assManager.Status__c = 'Completed';
        assManager.Priority__c = 'High';
        assManager.InvestigationType__c = assTemp.Id;
        insert assManager;
        
        date tt = system.today()-1;
        string ss = tt.format();
        date t = system.today() +1;
        String s = t.format();
        apexpages.currentpage().getparameters().put('AssessableObj','Account');
        apexpages.currentpage().getparameters().put('AssessmentGrp',assGrp.Id);
        apexpages.currentpage().getparameters().put('AssessmentEvt',assEvent.Id);

        apexpages.currentpage().getparameters().put('scheduledFrom',ss);
        apexpages.currentpage().getparameters().put('scheduledTo',s);
        
        apexpages.currentpage().getparameters().put('AMStatus',assManager.Status__c);
        apexpages.currentpage().getparameters().put('AMpriority',assManager.Priority__c);
        apexpages.currentpage().getparameters().put('AMassessmentCompletion',assManager.Assessment_Form_Completion__c);
        apexpages.currentpage().getparameters().put('AMassessmentType',assTemp.Id);
        system.currentPageReference().getParameters().put('showUsers','true');
        system.currentPageReference().getParameters().put('ColorBy','Name');
        AssessmentMapUserImplementorController mapCtlr = new AssessmentMapUserImplementorController();
        
        List<AssessmentMapUserImplementorController.AddressToLatLongConversion> latAndLangList = new List<AssessmentMapUserImplementorController.AddressToLatLongConversion>();
        AssessmentMapUserImplementorController.AddressToLatLongConversion latlang = new AssessmentMapUserImplementorController.AddressToLatLongConversion(acc.Id,'33.3','32.3');
        latAndLangList.add(latlang);
        List<AssessmentMapUserImplementorController.Locations> locList = new List<AssessmentMapUserImplementorController.Locations>();
        locList = mapCtlr.getlistacc();
        String latLangStr = JSON.serialize(latAndLangList);
        string response = AssessmentMapUserImplementorController.updateAssessibleObjectLatLng(latLangStr,'Account');
        system.assertEquals(response, 'Geolocation field in Account updated successfully');
        string response1 = AssessmentMapUserImplementorController.updateAssessibleObjectLatLng(latLangStr,'Case');
        
    }
    static testMethod void method2() {
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.BillingCity = 'test City';
        acc.BillingCountry = 'test country';
        acc.BillingState = 'test state';
        acc.BillingStreet = 'test Street';
        acc.BillingLatitude = 74.6;
        acc.BillingLongitude = 76.7;
        insert acc;
        
        Main_questionaire__c assTemp = new Main_questionaire__c();
        assTemp.Template_name__c = 'Unit Template';
        assTemp.Account__c = acc.Id;
        insert assTemp;
        
        Assessment_Group__c assGrp = new Assessment_Group__c();
        assGrp.Type__c = 'Account';
        insert assGrp;
        
        Assessment_Event__c assEvent = new Assessment_Event__c();
        assEvent.Description__c = 'Test Description';
        assEvent.Event_Date__c = System.today();
        assEvent.Event_Start_Time__c = System.now().addHours(-4);
        assEvent.Event_Finish_Time__c = System.now().addHours(1);
        insert assEvent;
        
        Map_Anything_Address_Configuration__c mapConfig = new Map_Anything_Address_Configuration__c();
        mapConfig.Name = 'Case';
        mapConfig.Street_Field_Name__c = 'Street';
        mapConfig.City_Field_Name__c = 'City';
        mapConfig.Postal_Code_Field_Name__c = 'PostalCode';
        mapConfig.Country_Field_Name__c = 'Country';
        insert mapConfig;
        
        IssueRequest_Life_Cycle__c assManager = new IssueRequest_Life_Cycle__c();
        assManager.Facility_Name__c = acc.Id;
        assManager.Assessment_Form_Completion__c = 'Complete';
        assManager.Assessment_Event__c = assEvent.Id;
        assManager.Assessment_Group__c = assGrp.Id;
        assManager.Status__c = 'Completed';
        assManager.Priority__c = 'High';
        assManager.InvestigationType__c = assTemp.Id;
        insert assManager;
        
        date tt = system.today()-1;
        string ss = tt.format();
        date t = system.today() +1;
        String s = t.format();
        apexpages.currentpage().getparameters().put('AssessableObj','Case');
        apexpages.currentpage().getparameters().put('AssessmentGrp',assGrp.Id);
        apexpages.currentpage().getparameters().put('AssessmentEvt',assEvent.Id);

        apexpages.currentpage().getparameters().put('scheduledFrom',ss);
        apexpages.currentpage().getparameters().put('scheduledTo',s);
        
        apexpages.currentpage().getparameters().put('AMStatus',assManager.Status__c);
        apexpages.currentpage().getparameters().put('AMpriority',assManager.Priority__c);
        apexpages.currentpage().getparameters().put('AMassessmentCompletion',assManager.Assessment_Form_Completion__c);
        apexpages.currentpage().getparameters().put('AMassessmentType',assTemp.Id);
        system.currentPageReference().getParameters().put('showUsers','true');
        system.currentPageReference().getParameters().put('ColorBy','Name');
        AssessmentMapUserImplementorController mapCtlr = new AssessmentMapUserImplementorController();
        
        List<AssessmentMapUserImplementorController.AddressToLatLongConversion> latAndLangList = new List<AssessmentMapUserImplementorController.AddressToLatLongConversion>();
        AssessmentMapUserImplementorController.AddressToLatLongConversion latlang = new AssessmentMapUserImplementorController.AddressToLatLongConversion(acc.Id,'33.3','32.3');
        latAndLangList.add(latlang);
        List<AssessmentMapUserImplementorController.Locations> locList = new List<AssessmentMapUserImplementorController.Locations>();
        locList = mapCtlr.getlistacc();
        String latLangStr = JSON.serialize(latAndLangList);
        string response = AssessmentMapUserImplementorController.updateAssessibleObjectLatLng(latLangStr,'Account');
        system.assertEquals(response, 'Geolocation field in Account updated successfully');
        string response1 = AssessmentMapUserImplementorController.updateAssessibleObjectLatLng(latLangStr,'User');
        
    }
}