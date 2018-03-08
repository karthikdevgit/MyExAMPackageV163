@isTest
public class TestGeneralConfigController {

    static testMethod void method1() {
    
        GoogleMapsAPIKey__c key = new GoogleMapsAPIKey__c();
        key.Name = 'GoogleMapsAPIKey';
        key.API_Key__c ='78fd7w7472iu46';
        insert key;
        List<GoogleMapsAPIKey__c> keyList = [Select Id from GoogleMapsAPIKey__c Where Name = 'GoogleMapsAPIKey']; 
        System.assert(keyList.size() == 1);

        SF_sub_domain__c subdomain = new SF_sub_domain__c();
        subdomain.Name='EndPointURL';
        subdomain.EndPointURL__c ='https://www.google.com';
        insert subdomain;
        List<SF_sub_domain__c> domainList = [Select Id from SF_sub_domain__c Where Name = 'EndPointURL']; 
        System.assert(domainList.size() == 1);

        GeneralConfigController gc = new GeneralConfigController();
        GeneralConfigController.saveGoogleAPI('78fd7w7472iu46');
        GeneralConfigController.saveEndpointUrl('https://www.google.com');
        GeneralConfigController.createLookupField('exam__c');
        GeneralConfigController.createLookupField('contact');

        String typeStr = GeneralConfigController.getAllQuestionTypes();

        ExAM_Configuration__c configRecord = new ExAM_Configuration__c();
        configRecord.Name = 'Configuration';
        configRecord.ExAM__Data_Management_Tab_Filter__c = 'Text,Result,Button';
        
        String response = GeneralConfigController.saveSelectedQuestionTypesFilter(configRecord);

        String recId = [SELECT Id, Name FROM ExAM_Configuration__c LIMIT 1].Id;
        system.assertEquals(response, '{"successMsg":"Exam Configuration updated successfully","recId":\"'+recId+'\"}');
        GeneralConfigController.ExamConfigurationAndAssessmentTemplateDetails exConfTempd = GeneralConfigController.queryExamConfigRecordAndAllAssessmentTemplates();
        String ss = GeneralConfigController.saveSelectedTemplateIdsIntoExamConfigurationRecord(configRecord);
        String uedf = GeneralConfigController.updateExamConfig(true, true);
        List<String> srtList =  GeneralConfigController.getOverallStatusList();
        String ssEc = GeneralConfigController.saveStatusinExamConfig('test');
        String samlfEc = GeneralConfigController.saveAssignmentManagerListFilterInExamConfig('statusVal');
        String siteUrl = GeneralConfigController.doSaveSelectedSiteUrl('siteURL');
        String webUrl = GeneralConfigController.doSaveSelectedWebUrl('webURL');
        String saveStr = GeneralConfigController.savefieldMappping(true);
        String responseQT = GeneralConfigController.getAllQuestionTypes();
    }
}