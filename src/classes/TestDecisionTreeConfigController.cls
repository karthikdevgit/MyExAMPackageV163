@isTest
public class TestDecisionTreeConfigController {
    Static testMethod void method1() {
        ExAM_Configuration__c config = new ExAM_Configuration__c();
        config.Name ='Configuration';
        config.Decision_Tree__c='TestFiels';
        insert config;
        List<ExAM_Configuration__c> configList = [Select Id from ExAM_Configuration__c Where Name = 'Configuration']; 
        System.assert(configList.size() == 1);
        
        DecisionTreeConfigController dt = new DecisionTreeConfigController();  
        DecisionTreeConfigController.saveDecisionTreeConfig('TestFields');
    }
}