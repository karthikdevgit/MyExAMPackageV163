@isTest 

private class TestCaseSurveyConfigurationCtlr {

    static testMethod void method1() {
    
        String json = '[{"configTempName":"T-1058","configFieldValue":"Mechanical","configFieldName":"Type"}]';
        
        Main_questionaire__c assTemp = new Main_questionaire__c();
        assTemp.Template_Name__c = 'Test Template';
        insert assTemp;
        
        ExAM_Configuration__c exmConfig = new ExAM_Configuration__c();
        exmConfig.Name='Configuration';
        exmConfig.Enable_Case_Survey__c = false;
        exmConfig.Case_Configuration__c = '[{"configTempName":"T-1058","configFieldValue":"Mechanical","configFieldName":"Type"},{"configTempName":"T-1058","configFieldValue":"Mechanical","configFieldName":"Type"}]';
        insert exmConfig;
        
        CaseSurveyConfigurationCtlr ctr = new CaseSurveyConfigurationCtlr(); 
        CaseSurveyConfigurationCtlr.saveFieldConfiguration(json,'false');
        
        List<ExAM_Configuration__c> config = new List<ExAM_Configuration__c>();
        config = [SELECT Id,Enable_Case_Survey__c,Case_Configuration__c FROM ExAM_Configuration__c WHERE Name='Configuration' ORDER BY CreatedDate DESC LIMIT 1];
        System.assert(config[0].Case_Configuration__c==json);
        System.assert(config[0].Enable_Case_Survey__c==false);
    }
    static testMethod void method2() {
        String json = '[{"configTempName":"T-1058","configFieldValue":"Mechanical","configFieldName":"Type"}]';
        CaseSurveyConfigurationCtlr ctr = new CaseSurveyConfigurationCtlr(); 
        CaseSurveyConfigurationCtlr.saveFieldConfiguration(json,'true');
        
        List<ExAM_Configuration__c> config = new List<ExAM_Configuration__c>();
        config = [SELECT Id,Enable_Case_Survey__c,Case_Configuration__c FROM ExAM_Configuration__c WHERE Name='Configuration' ORDER BY CreatedDate DESC LIMIT 1];
        System.assert(config[0].Case_Configuration__c==json);
        System.assert(config[0].Enable_Case_Survey__c==true);
    }
}