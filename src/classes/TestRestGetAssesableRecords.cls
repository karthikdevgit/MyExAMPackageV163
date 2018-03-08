@isTest
public class TestRestGetAssesableRecords {
    static testMethod void method1() {
        Account a = new Account();
        a.Name = 'TestAcc';
        insert a;
        Main_questionaire__c assTemp = new Main_questionaire__c();
        assTemp.Template_name__c = 'TempName';
        insert assTemp;
        IssueRequest_Life_Cycle__c newAssignmentManager = new IssueRequest_Life_Cycle__c();
        newAssignmentManager.Facility_Name__c = a.Id;
        insert newAssignmentManager;
        RestGetAssesableRecords obj = new RestGetAssesableRecords();
        String assRec = RestGetAssesableRecords.getAssesableRecord(newAssignmentManager.Id);
        List<Schema.FieldSetMember> fSet = obj.readFieldSet('New_Account_Mobile', 'Account');
        System.assert(assRec != NULL);
        System.assert(fSet != NULL);
    }
}