@isTest
private class TestWebInterceptConfigurationController {
    static  testMethod void method1(){
        
        Main_questionaire__c templateRec = new Main_questionaire__c(
            Web_Intercept_PA_Resource_File_Path__c = 'test file path', Web_Intercept_Header__c = 'test header', 
            Web_Intercept_Static_Resource_Name__c = 'test modal css resource name',
            Web_Intercept_PA_Static_Resource_Name__c = 'test pa sr name'
        );
        insert templateRec;
        
        ApexPages.currentPage().getParameters().put('templateId',templateRec.Id);
        String templateRecString = JSON.serialize(templateRec);
        
        WebInterceptConfigurationController wicc = new WebInterceptConfigurationController();
        
        String saveWIConfigResult = WebInterceptConfigurationController.saveWIConfig(templateRecString);
        System.assertEquals('success', saveWIConfigResult);
        
        templateRecString = templateRecString.replace(templateRec.Id, '');
        String saveWIConfigResult1 = WebInterceptConfigurationController.saveWIConfig(templateRecString);
    }
}