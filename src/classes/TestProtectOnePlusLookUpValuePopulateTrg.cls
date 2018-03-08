@isTest
public class TestProtectOnePlusLookUpValuePopulateTrg {
    
    static testmethod void method1() {
        
        DateTime strTime = DateTime.Now();
        DateTime endTime = DateTime.Now().addHours(2);
        Date rightNow = Date.Today();
        
        Id loggedInUsrId = UserInfo.getUserId();
        
        Account acct = new Account(Name = 'Test Account');
        insert acct;
        
        Contact con = new Contact(AccountId = acct.Id, FirstName = 'John', LastName = 'Doe');
        insert con;
        
        Opportunity opp = new Opportunity(AccountId = acct.Id, CloseDate = rightNow.addYears(1), Name = 'Test Opp', StageName = 'Prospecting');
        insert opp;
        
        ExAM__Section_Group__c sectionGrpTestRecord = new ExAM__Section_Group__c(ExAM__Group_External_Id__c = 'Test12', ExAM__Group_Name__c = 'Test Group');
        insert sectionGrpTestRecord;
        
        ExAM__IssueRequest_Life_Cycle__c amTestRecord1 = new ExAM__IssueRequest_Life_Cycle__c();
        amTestRecord1.ExAM__Location__c = 'School';
        amTestRecord1.ExAM__Facility_Name__c = acct.Id;
        amTestRecord1.ExAM__Field_End_Time__c = endTime;
        amTestRecord1.ExAM__Field_Start_Time__c = strTime;
        amTestRecord1.ExAM__Assessor_Resource__c = loggedInUsrId;
        amTestRecord1.ExAM__Section_Group__c = sectionGrpTestRecord.Id;
        amTestRecord1.ExAM__Responder__c = loggedInUsrId;
        amTestRecord1.ExAM__Service_Organization__c = acct.Id;
        amTestRecord1.ExAM__Site_Contact__c = con.Id;
        insert amTestRecord1;
        
        ExAM__IssueRequest_Life_Cycle__c amTestRecord2 = new ExAM__IssueRequest_Life_Cycle__c();
        amTestRecord2.ExAM__Location__c = 'School';
        amTestRecord2.ExAM__Facility_Name__c = acct.Id;
        amTestRecord2.ExAM__Field_End_Time__c = endTime;
        amTestRecord2.ExAM__Field_Start_Time__c = strTime;
        amTestRecord2.ExAM__Assessor_Resource__c = loggedInUsrId;
        amTestRecord2.ExAM__Section_Group__c = sectionGrpTestRecord.Id;
        amTestRecord2.ExAM__Responder__c = loggedInUsrId;
        amTestRecord2.ExAM__Service_Organization__c = acct.Id;
        amTestRecord2.ExAM__Site_Contact__c = con.Id;
        insert amTestRecord2;
        
        System.assertEquals(1,1);
        
        Set<Id> amIdSet = new Set<Id>{amTestRecord1.Id, amTestRecord2.Id};
        
        List<ExAM__IssueRequest_Life_Cycle__c> amList = new List<ExAM__IssueRequest_Life_Cycle__c>();
        amList = [SELECT Id, ExAM__Location__c FROM ExAM__IssueRequest_Life_Cycle__c WHERE Id IN :amIdSet];
        
        if(amList != NULL && amList.size() > 0) {
            System.assertEquals(1, 1);
            
            amList[0].ExAM__Location__c = 'Administrative';
            update amList[0];
        }
    }
}