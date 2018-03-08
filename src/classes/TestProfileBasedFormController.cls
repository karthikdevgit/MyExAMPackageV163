@isTest
private class TestProfileBasedFormController {

    public static testMethod void testlistacc() {
        
        
        //ApexPages.StandardController sc = new ApexPages.StandardSetController(c);
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None'
        Limit 1];
        Profile profile1 = [Select Id from Profile where name = 'System Administrator'];
        User portalAccountOwner1 = new User(
        UserRoleId = portalRole.Id,
        ProfileId = profile1.Id,
        Username = (Math.round(Math.random()*100)) + 'test2@test.com' + System.now().millisecond(),
        Alias = 'testxyz',
        Email = 'test@test.com',
        EmailEncodingKey = 'UTF-8',
        Firstname = 'TEST',
        Lastname = 'test',
        LanguageLocaleKey = 'en_US',
        LocaleSidKey = 'en_US',
        TimeZoneSidKey = 'America/Chicago');
        Database.insert(portalAccountOwner1);
        User thisUser = [select Id from User where Id = : UserInfo.getUserId()];
        User u;
        Account acc = new Account();
        ExAM__Main_questionaire__c tem = new ExAM__Main_questionaire__c();
        System.runAs(thisUser) {
        
            acc = new Account(name = 'test account', OwnerId = portalAccountOwner1.Id);
            insert acc;
            Contact c = new Contact(AccountId = acc.id, lastname = 'lastname');
            insert c;

            tem = new ExAM__Main_questionaire__c(ExAM__Template_name__c = 'template1');
            insert tem;
            
            Profile portalProfile = [SELECT Id FROM Profile WHERE Name LIKE '%System Administrator%' Limit 1];

            u = new User(profileId = portalProfile.Id, username = (Math.round(Math.random()*100)) + 'testemail@gmail.com' + System.now().millisecond(), email = System.now().millisecond() + 'testemail@gmail.com', emailencodingkey = 'UTF-8', localesidkey = 'en_US', languagelocalekey = 'en_US', timezonesidkey = 'America/Los_Angeles', alias = 'cspu', lastname = 'lastname');
            insert u;

        }
        
        
    
        System.RunAs(u) {
            ExAM__IssueRequest_Life_Cycle__c iss = new ExAM__IssueRequest_Life_Cycle__c();
            ApexPages.StandardController scc = new ApexPages.StandardController(iss);
            ProfileBasedFormController d = new ProfileBasedFormController(scc);
            
            d.accname = 'test';
            d.tempid = 'test';
            d.acc = acc;
            System.currentPagereference().getParameters().put('templat',tem.id); 
            d.save();
            d.cancel();
            System.assertNotEquals(acc.Id, null);
            
        }
    }
}