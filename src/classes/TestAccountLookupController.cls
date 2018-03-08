@isTest
public class TestAccountLookupController {
    
    static testMethod void accountLookup() {

        Account acc = new Account(Name = 'Test 1');
        Insert acc;

        ApexPages.currentPage().getParameters().put('accName', 'Test 1');
        ApexPages.currentPage().getParameters().put('accNameFieldId', 'Test 1');
        ApexPages.currentPage().getParameters().put('accHiddenField',''+acc.id);        
        ApexPages.StandardController sc = new ApexPages.StandardController(acc);
        AccountLookupController alc = new AccountLookupController(sc);
        system.assertEquals(alc.accList.size(), 1, 'Records count not matched with actual number of records');

        PageReference searchTemp = alc.searchUsers();
        
        ApexPages.currentPage().getParameters().put('accName', 'Te');
        ApexPages.currentPage().getParameters().put('accNameFieldId', 'Te');
        ApexPages.currentPage().getParameters().put('accHiddenField',''+acc.id);
        ApexPages.StandardController sc2 = new ApexPages.StandardController(acc);
        AccountLookupController alc2 = new AccountLookupController(sc2);
        
        PageReference searchTemp2 = alc2.searchUsers();
        alc2.accName = null;
        PageReference searchTemp3 = alc2.searchUsers();
        
    }
}