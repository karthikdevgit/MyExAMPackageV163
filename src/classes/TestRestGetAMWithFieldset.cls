@isTest
private class TestRestGetAMWithFieldset {
    static testMethod void method1() {
        IssueRequest_Life_Cycle__c am = new IssueRequest_Life_Cycle__c();
        insert am;
        Test.startTest();
            String returnValue = RestGetAssignmentManagerWithFieldset.getAssignmentManagerWithFieldset(am.Id);
            system.assert(returnValue != null);
        Test.stopTest();
    }
}