@isTest
public class TestAssignmentManagerListController {
    Static testMethod void method1() {    
        
        Account acc = new Account();
        acc.Name = 'TestAcc';
        insert acc;
        
        contact con = new contact();
        con.AccountId=acc.id;
        con.LastName ='testCon';
        insert con;
        
        Main_questionaire__c asstemp = new Main_questionaire__c();
        asstemp.Template_name__c = 'testTemplate';
        insert asstemp;
        
        IssueRequest_Life_Cycle__c am = new IssueRequest_Life_Cycle__c();
        am.OwnerId = UserInfo.getUserId();
        am.Facility_Name__c = acc.id;
        am.Site_Contact__c = con.id;
        am.Date_Assigned__c = system.today();
        am.Status__c='open';
        am.Priority__c = 'high';
        am.InvestigationType__c =asstemp.id;
        am.Assessment_Form_Completion__c = 'complete';
        am.Assessment_Date_Time__c = system.today();
        insert am;
        
        List<IssueRequest_Life_Cycle__c> amList = [Select Id from IssueRequest_Life_Cycle__c]; 
        System.assertEquals(1,amList.size());
        
        AssignmentManagerListController amListCtrller = new AssignmentManagerListController();

        String asmListAsJson = AssignmentManagerListController.queryAllASMRecords();
    }
}