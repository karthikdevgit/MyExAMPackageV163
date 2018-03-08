@isTest
public class TestRestGetAssignmentManagers {
    static testMethod void method1() {
        Main_questionaire__c aT1 = new Main_questionaire__c();
        aT1.Template_name__c = 'aT1';
        insert aT1;
        Main_questionaire__c aT2 = new Main_questionaire__c();
        aT1.Template_name__c = 'aT2';
        insert aT2;
        
        IssueRequest_Life_Cycle__c aM1 = new IssueRequest_Life_Cycle__c();
        aM1.InvestigationType__c = aT1.Id;
        insert aM1;
        IssueRequest_Life_Cycle__c aM2 = new IssueRequest_Life_Cycle__c();
        aM2.InvestigationType__c = aT2.Id;
        insert aM2;
        
        List<Id> managersId = new List<Id>();
        managersId.add(aM1.Id);
        managersId.add(aM2.Id);
        String managers = RestGetAssignmentManagers.getAssignmentManagers(managersId);
        System.assert(managers != NULL);
    }
}