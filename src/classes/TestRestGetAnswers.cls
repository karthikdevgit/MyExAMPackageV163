@isTest

public class TestRestGetAnswers {
    
    static testMethod void testMethod1() {
        
        RestGetAnswers r = new  RestGetAnswers();
        Account acc = new Account();
        acc.Name = 'Accname';
        insert acc;
        
        Main_questionaire__c temp = new Main_questionaire__c();//Template creation
        temp.Template_name__c = 'Template1';
        insert temp;
        
        IssueRequest_Life_Cycle__c assM = new IssueRequest_Life_Cycle__c();//AssignmentManager creation
        assM.InvestigationType__c = temp.Id;
        assM.Facility_Name__c = acc.Id;
        insert assM;
        
        String ret =  RestGetAnswers.getAnswers(assM.Id);
        System.assert(ret != Null);
  }
}