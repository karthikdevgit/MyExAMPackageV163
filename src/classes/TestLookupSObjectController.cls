@isTest
public class TestLookupSObjectController {
    
    static Testmethod void method1(){
        
        List<Account> accList = new List<Account>();
        List<Contact> conList = new List<Contact>();
        List<Case> caseList = new List<Case>();
        
        for(Integer i = 1; i <=20 ; i++){
            accList.add(new Account(Name='test account'+ i));
        }
        conList.add(new Contact(LastName='test Con'));
        caseList.add(new Case(Subject='test Case', Status='New', Origin ='Web'));
        
        insert accList;
        insert conList;
        insert caseList;
        
        List<Id> fixedSearchResults = new List<Id>();
        
        for(Integer i = 0; i < 20; i++){ 
            fixedSearchResults.add(accList[i].Id); 
            
        }  
        fixedSearchResults.add(caseList[0].Id);
        fixedSearchResults.add(conList[0].Id);
        
        Test.setFixedSearchResults(fixedSearchResults);
        // search Account
        List<LookupSObjectController.Result>  results = LookupSObjectController.lookup('test','Account');
        System.assertEquals(10, results.size());
        System.assertEquals(accList[0].Name, results[0].SObjectLabel);
        System.assertEquals(accList[0].Id, results[0].sObjectId);
        // search Case
        List<LookupSObjectController.Result>  caseResults = LookupSObjectController.lookup('test','Case');
        System.assertEquals(1, caseResults.size());
        Case caseRd = [SELECT Id, CaseNumber FROM Case WHERE Id =:caseList[0].Id];
        System.assertEquals(caseRd.CaseNumber, caseResults[0].SObjectLabel);
        System.assertEquals(caseRd.Id, caseResults[0].sObjectId);
        // get Record Name based on contactId
        String recordName = LookupSObjectController.fetchSpecifyRecord(conList[0].Id, 'Contact');
        System.assertEquals('test Con', recordName);
    }
    
}