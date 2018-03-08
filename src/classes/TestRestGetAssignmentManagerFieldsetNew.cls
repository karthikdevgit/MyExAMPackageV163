@isTest
private class TestRestGetAssignmentManagerFieldsetNew {
    static testMethod void method1() {
        string response = RestGetAssignmentManagerFieldsetNew.getAssignmentManagerFieldsetNew();
        system.assertNotEquals(response, '');
    }
}