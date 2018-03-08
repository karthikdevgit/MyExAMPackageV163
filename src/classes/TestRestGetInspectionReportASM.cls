@isTest 
private class TestRestGetInspectionReportASM {

    static testMethod void method1() {
        Account acc = new Account();
        acc.Name = 'Test Account';
        insert acc;
        
        List<string> fieldList = new List<string>();
        fieldList.add('ExAM__Account_to_Response__c');
        fieldList.add('ExAM__Issue_Request__c');
        fieldList.add('ExAM__UPCS_V_Pass_or_Fail__c');
        
        Test.startTest();
            String returnValue = RestGetInspectionReportASM.getInspectionReportASM('ExAM__Questionnaire_Response__c',fieldList,acc.Id);
            System.assert(returnValue != Null);
        Test.stopTest();
    }
    static testMethod void method2() {
        List<string> fieldList = new List<string>();
        fieldList.add('ExAM__Account_to_Response__c');
        fieldList.add('ExAM__Issue_Request__c');
        fieldList.add('ExAM__UPCS_V_Pass_or_Fail__c');
        
        Test.startTest();
            String returnValue = RestGetInspectionReportASM.getInspectionReportASM('',fieldList,'');
            System.assert(returnValue != Null);
        Test.stopTest();
    }
}