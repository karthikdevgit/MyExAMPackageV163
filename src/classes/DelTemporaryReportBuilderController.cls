global with sharing class DelTemporaryReportBuilderController implements Database.Batchable<sObject> {
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'SELECT ID, Is_Temporary__c, CreatedDate FROM Report_Builder_Configuration__c WHERE Is_Temporary__c = true AND CreatedDate != TODAY';
        return Database.getQueryLocator(query);    
    }
    
    global void execute(Database.BatchableContext BC, List<SObject> tempReportBuilderList){
        if (tempReportBuilderList != null && tempReportBuilderList.size() > 0) {
            delete tempReportBuilderList;
        }
    }
    
    global void finish(Database.BatchableContext BC){
    
    }
}