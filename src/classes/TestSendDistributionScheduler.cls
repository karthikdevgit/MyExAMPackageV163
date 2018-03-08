@isTest
public class TestSendDistributionScheduler {

    @testSetup
    public static void testSetup() {

        EmailTemplate validEmailTemplate = new EmailTemplate();
        validEmailTemplate.IsActive = true;
        validEmailTemplate.Name = 'name';
        validEmailTemplate.DeveloperName = 'unique_name_addSomethingSpecialHere4';
        validEmailTemplate.TemplateType = 'Text';
        validEmailTemplate.FolderId = UserInfo.getUserId();
        validEmailTemplate.Body = '<b>Hello</b>';
        insert validEmailTemplate; 
    }       
   
    public static testMethod void method1() {
        
        List<EmailTemplate> emailTemp = [SELECT ID FROM EmailTemplate]; 

        List<EmailTemplate> validEmailTemplate = [SELECT ID,HTMLValue, Body FROM EmailTemplate WHERE DeveloperName = 'unique_name_addSomethingSpecialHere4'];


        Account acc = new Account(Name = 'Test Account 1');
        insert acc;

        Main_questionaire__c template = new Main_questionaire__c(Template_Name__c = 'Test Template 1');
        insert template;

        Distribution_Group__c[] distGpList = new Distribution_Group__c[]{
            new Distribution_Group__c(Name = 'Contact Group 1', Target_Object__c = 'Contact'),
            new Distribution_Group__c(Name = 'Lead Group 1', Target_Object__c = 'Lead'),
            new Distribution_Group__c(Name = 'User Group 1', Target_Object__c = 'User')
        };
        insert distGpList; 
        
        Id userId = UserInfo.getUserId();
        Date today = Date.today();
        Date endDate = Date.today().addMonths(3);
        string contactIds = '';
        string leadIds = '';
       
        List<Contact> contacts = new List<Contact>();
        for(Integer i = 0; i<= 5; i++) {

            string contactname = 'Test Contact 1'+i;
            string contactemail = 'testcontact1'+i+'@gmail.com';

            Contact con = new Contact(LastName = contactname, Email = contactemail);
            contacts.add( con );
        }    
        insert contacts;

        for(Contact contact : contacts) {
            if (string.isNotBlank(contactIds)) {
                contactIds += ','+contact.Id;
            }
            else {
                contactIds = contact.Id;
            }
        }
        
        List<Lead> leads = new List<Lead>();
        for(Integer i = 0; i<= 5; i++) {

            string leadname = 'Test Lead 1 '+i;
            string leadcompany = 'testleadcompany1'+i;
            string leademail = 'testlead1'+i+'@gmail.com';

            Lead l = new Lead(Company = leadcompany, Email = leademail, LastName = leadname);
            leads.add( l );
        }    
        insert leads;

        for(Lead lead : leads) {
            if (string.isNotBlank(leadIds)) {
                leadIds += ','+ lead.Id;
            }
            else {
                leadIds = lead.id;
            }
        }

        Distribution__c[] distributionList = new Distribution__c[]{
            new Distribution__c(Assessable_Object_API__c = 'Account', Assessable_Record__c = acc.Id, Assessment_Template__c = template.Id, Distribution_Group__c = distGpList[0].Id, Email_Template__c = validEmailTemplate[0].Id, Name = 'Test Contact Distribution', Start_Date__c = today, Expiration_Date__c = endDate, Send_Mode__c = 'Email with Salesforce', Type__c = 'Anonymous Link', Target_Object_Ids__c = contactIds), 
            new Distribution__c(Assessable_Object_API__c = 'Account', Assessable_Record__c = acc.Id, Assessment_Template__c = template.Id, Distribution_Group__c = distGpList[1].Id, Email_Template__c = validEmailTemplate[0].Id, Name = 'Test Lead Distribution', Start_Date__c = today, Expiration_Date__c = endDate, Send_Mode__c = 'Email with Salesforce', Type__c = 'Anonymous Link', Target_Object_Ids__c = leadIds), 
            new Distribution__c(Assessable_Object_API__c = 'Account', Assessable_Record__c = acc.Id, Assessment_Template__c = template.Id, Distribution_Group__c = distGpList[2].Id, Email_Template__c = validEmailTemplate[0].Id, Name = 'Test User Distribution', Start_Date__c = today, Expiration_Date__c = endDate, Send_Mode__c = 'Email with Salesforce', Type__c = 'Anonymous Link', Target_Object_Ids__c = userId)
        };
        insert distributionList;
        
        Public_Assessment__c[] paList = new Public_Assessment__c[]{
            new Public_Assessment__c(Distribution__c = distributionList[0].Id, Facility_Name__c = acc.Id, Assessment_Template__c = template.Id), 
            new Public_Assessment__c(Distribution__c = distributionList[1].Id, Facility_Name__c = acc.Id, Assessment_Template__c = template.Id), 
            new Public_Assessment__c(Distribution__c = distributionList[2].Id, Facility_Name__c = acc.Id, Assessment_Template__c = template.Id)
        };
        insert paList;

        List<Distribution__c> distList = new List<Distribution__c>([
            SELECT Assessable_Object_API__c, Assessable_Record__c, Distribution_Group__c, Distribution_Group__r.Target_Object__c,
                   Distribution_Group__r.Target_Object_Filter__c, Distribution_DateTime__c, Email_Template__c,
                   Id, Name, Target_Object_Ids__c,
                   (SELECT Id, Public_Assessment_URL__c FROM Public_Assessments__r)
            FROM   Distribution__c]);

        DateTime currentDateTime = System.now().addMinutes(2); 
       
        Test.startTest();  
        
        String nextScheduleTime=String.valueof(currentDateTime.second()) +' '+String.valueof(currentDateTime.minute())+' '
                                +String.valueof(currentDateTime.hour())+' '+String.valueof(currentDateTime.day())+' '
                                +String.valueof(currentDateTime.month())+' ? '+String.valueof(currentDateTime.Year());

        //Runs properly
        System.schedule('SendDistributionScheduler1'+system.now(), nextScheduleTime, new SendDistributionScheduler(distList[0].Id));
        System.schedule('SendDistributionScheduler2'+system.now(), nextScheduleTime, new SendDistributionScheduler(distList[1].Id));
        System.schedule('SendDistributionScheduler3'+system.now(), nextScheduleTime, new SendDistributionScheduler(distList[2].Id));
        Test.stopTest(); 
    }

    public static testMethod void method2() {
        
        List<EmailTemplate> emailTemp = [SELECT ID FROM EmailTemplate]; 

        List<EmailTemplate> validEmailTemplate = [SELECT ID,HTMLValue, Body FROM EmailTemplate WHERE DeveloperName = 'unique_name_addSomethingSpecialHere4'];


        Account acc = new Account(Name = 'Test Account 2');
        insert acc;

        Main_questionaire__c template = new Main_questionaire__c(Template_Name__c = 'Test Template 2');
        insert template;

        Distribution_Group__c[] distGpList = new Distribution_Group__c[]{
            new Distribution_Group__c(Name = 'Contact Group 2', Target_Object__c = 'Contact'),
            new Distribution_Group__c(Name = 'Lead Group 2', Target_Object__c = 'Lead'),
            new Distribution_Group__c(Name = 'User Group 2', Target_Object__c = 'User')
        };
        insert distGpList; 
        
        Id userId = UserInfo.getUserId();
        Date today = Date.today();
        Date endDate = Date.today().addMonths(3);
        string contactIds = '';
        string leadIds = '';
       
        List<Contact> contacts = new List<Contact>();
        for(Integer i = 0; i<= 5; i++) {

            string contactname = 'Test Contact 2'+i;
            string contactemail = 'testcontact2'+i+'@gmail.com';

            Contact con = new Contact(LastName = contactname, Email = contactemail);
            contacts.add( con );
        }    
        insert contacts;

        for(Contact contact : contacts) {
            if (string.isNotBlank(contactIds)) {
                contactIds += ','+contact.Id;
            }
            else {
                contactIds = contact.Id;
            }
        }
        
        List<Lead> leads = new List<Lead>();
        for(Integer i = 0; i<= 5; i++) {

            string leadname = 'Test Lead 2'+i;
            string leadcompany = 'testleadcompany2'+i;
            string leademail = 'testlead2'+i+'@gmail.com';

            Lead l = new Lead(Company = leadcompany, Email = leademail, LastName = leadname);
            leads.add( l );
        }    
        insert leads;

        for(Lead lead : leads) {
            if (string.isNotBlank(leadIds)) {
                leadIds += ','+ lead.Id;
            }
            else {
                leadIds = lead.id;
            }
        }

        Distribution__c[] distributionList = new Distribution__c[]{
            new Distribution__c(Assessable_Object_API__c = 'Account', Assessable_Record__c = acc.Id, Assessment_Template__c = template.Id, Distribution_Group__c = distGpList[0].Id, Email_Template__c = validEmailTemplate[0].Id, Name = 'Test Contact Distribution', Start_Date__c = today, Expiration_Date__c = endDate, Send_Mode__c = 'Email with Salesforce', Type__c = 'Anonymous Link', Target_Object_Ids__c = contactIds), 
            new Distribution__c(Assessable_Object_API__c = 'Account', Assessable_Record__c = acc.Id, Assessment_Template__c = template.Id, Distribution_Group__c = distGpList[1].Id, Email_Template__c = validEmailTemplate[0].Id, Name = 'Test Lead Distribution', Start_Date__c = today, Expiration_Date__c = endDate, Send_Mode__c = 'Email with Salesforce', Type__c = 'Anonymous Link', Target_Object_Ids__c = leadIds), 
            new Distribution__c(Assessable_Object_API__c = 'Account', Assessable_Record__c = acc.Id, Assessment_Template__c = template.Id, Distribution_Group__c = distGpList[2].Id, Email_Template__c = validEmailTemplate[0].Id, Name = 'Test User Distribution', Start_Date__c = today, Expiration_Date__c = endDate, Send_Mode__c = 'Email with Salesforce', Type__c = 'Anonymous Link', Target_Object_Ids__c = userId) 
        };
        insert distributionList;
        
        Public_Assessment__c[] paList = new Public_Assessment__c[]{
            new Public_Assessment__c(Distribution__c = distributionList[0].Id, Facility_Name__c = acc.Id, Assessment_Template__c = template.Id), 
            new Public_Assessment__c(Distribution__c = distributionList[1].Id, Facility_Name__c = acc.Id, Assessment_Template__c = template.Id), 
            new Public_Assessment__c(Distribution__c = distributionList[2].Id, Facility_Name__c = acc.Id, Assessment_Template__c = template.Id)
        };
        insert paList;

        List<Distribution__c> distList = new List<Distribution__c>([
            SELECT Assessable_Object_API__c, Assessable_Record__c, Distribution_Group__c, Distribution_Group__r.Target_Object__c,
                   Distribution_Group__r.Target_Object_Filter__c, Distribution_DateTime__c, Email_Template__c,
                   Id, Name, Target_Object_Ids__c,
                   (SELECT Id, Public_Assessment_URL__c FROM Public_Assessments__r)
            FROM   Distribution__c]);

        DateTime currentDateTime = System.now().addMinutes(2); 
       
        Test.startTest();  
        
        String nextScheduleTime=String.valueof(currentDateTime.second()) +' '+String.valueof(currentDateTime.minute())+' '
                                +String.valueof(currentDateTime.hour())+' '+String.valueof(currentDateTime.day())+' '
                                +String.valueof(currentDateTime.month())+' ? '+String.valueof(currentDateTime.Year());

        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator.MockClass1());

        //Runs properly
        System.schedule('SendDistributionScheduler1'+system.now(), nextScheduleTime, new SendDistributionScheduler(distList[0].Id));
        System.schedule('SendDistributionScheduler2'+system.now(), nextScheduleTime, new SendDistributionScheduler(distList[1].Id));
        System.schedule('SendDistributionScheduler3'+system.now(), nextScheduleTime, new SendDistributionScheduler(distList[2].Id));
        Test.stopTest(); 
    }
   
    public static testMethod void method3() {
        
        List<EmailTemplate> emailTemp = [SELECT ID FROM EmailTemplate]; 

        List<EmailTemplate> validEmailTemplate = [SELECT ID,HTMLValue, Body FROM EmailTemplate WHERE DeveloperName = 'unique_name_addSomethingSpecialHere4'];


        Account acc = new Account(Name = 'Test Account');
        insert acc;

        Main_questionaire__c template = new Main_questionaire__c(Template_Name__c = 'Test Template');
        insert template;

        Distribution_Group__c[] distGpList = new Distribution_Group__c[]{
            new Distribution_Group__c(Name = 'Contact Group 3', Target_Object__c = 'Contact'),
            new Distribution_Group__c(Name = 'Lead Group 3', Target_Object__c = 'Lead'),
            new Distribution_Group__c(Name = 'User Group 3', Target_Object__c = 'User')
        };
        insert distGpList; 
        
        Id userId = UserInfo.getUserId();
        Date today = Date.today();
        Date endDate = Date.today().addMonths(3);
        string contactIds = '';
        string leadIds = '';
       
        List<Contact> contacts = new List<Contact>();
        for(Integer i = 0; i<= 5; i++) {

            string contactname = 'Test Contact 3'+i;
            string contactemail = 'testcontact3'+i+'@gmail.com';

            Contact con = new Contact(LastName = contactname, Email = contactemail);
            contacts.add( con );
        }    
        insert contacts;

        for(Contact contact : contacts) {
            if (string.isNotBlank(contactIds)) {
                contactIds += ','+contact.Id;
            }
            else {
                contactIds = contact.Id;
            }
        }
        
        List<Lead> leads = new List<Lead>();
        for(Integer i = 0; i<= 5; i++) {

            string leadname = 'Test Lead 3'+i;
            string leadcompany = 'testleadcompany3'+i;
            string leademail = 'testlead3'+i+'@gmail.com';

            Lead l = new Lead(Company = leadcompany, Email = leademail, LastName = leadname);
            leads.add( l );
        }    
        insert leads;

        for(Lead lead : leads) {
            if (string.isNotBlank(leadIds)) {
                leadIds += ','+ lead.Id;
            }
            else {
                leadIds = lead.id;
            }
        }

        Distribution__c[] distributionList = new Distribution__c[]{
            new Distribution__c(Assessable_Object_API__c = 'Account', Assessable_Record__c = acc.Id, Assessment_Template__c = template.Id, Distribution_Group__c = distGpList[0].Id, Email_Template__c = validEmailTemplate[0].Id, Name = 'Test Contact Distribution', Start_Date__c = today, Expiration_Date__c = endDate, Send_Mode__c = 'Email with Salesforce', Type__c = 'Anonymous Link', Target_Object_Ids__c = contactIds), 
            new Distribution__c(Assessable_Object_API__c = 'Account', Assessable_Record__c = acc.Id, Assessment_Template__c = template.Id, Distribution_Group__c = distGpList[1].Id, Email_Template__c = validEmailTemplate[0].Id, Name = 'Test Lead Distribution', Start_Date__c = today, Expiration_Date__c = endDate, Send_Mode__c = 'Email with Salesforce', Type__c = 'Anonymous Link', Target_Object_Ids__c = leadIds), 
            new Distribution__c(Assessable_Object_API__c = 'Account', Assessable_Record__c = acc.Id, Assessment_Template__c = template.Id, Distribution_Group__c = distGpList[2].Id, Email_Template__c = validEmailTemplate[0].Id, Name = 'Test User Distribution', Start_Date__c = today, Expiration_Date__c = endDate, Send_Mode__c = 'Email with Salesforce', Type__c = 'Anonymous Link', Target_Object_Ids__c = userId) 
        };
        insert distributionList;
        
        Public_Assessment__c[] paList = new Public_Assessment__c[]{
            new Public_Assessment__c(Distribution__c = distributionList[0].Id, Facility_Name__c = acc.Id, Assessment_Template__c = template.Id), 
            new Public_Assessment__c(Distribution__c = distributionList[1].Id, Facility_Name__c = acc.Id, Assessment_Template__c = template.Id), 
            new Public_Assessment__c(Distribution__c = distributionList[2].Id, Facility_Name__c = acc.Id, Assessment_Template__c = template.Id)
        };
        insert paList;

        List<Distribution__c> distList = new List<Distribution__c>([
            SELECT Assessable_Object_API__c, Assessable_Record__c, Distribution_Group__c, Distribution_Group__r.Target_Object__c,
                   Distribution_Group__r.Target_Object_Filter__c, Distribution_DateTime__c, Email_Template__c,
                   Id, Name, Target_Object_Ids__c,
                   (SELECT Id, Public_Assessment_URL__c FROM Public_Assessments__r)
            FROM   Distribution__c]);

        DateTime currentDateTime = System.now().addMinutes(2); 
       
        Test.startTest();  
        
        String nextScheduleTime=String.valueof(currentDateTime.second()) +' '+String.valueof(currentDateTime.minute())+' '
                                +String.valueof(currentDateTime.hour())+' '+String.valueof(currentDateTime.day())+' '
                                +String.valueof(currentDateTime.month())+' ? '+String.valueof(currentDateTime.Year());

        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator.MockClass2());

        //Runs properly
        System.schedule('SendDistributionScheduler1'+system.now(), nextScheduleTime, new SendDistributionScheduler(distList[0].Id));
        System.schedule('SendDistributionScheduler2'+system.now(), nextScheduleTime, new SendDistributionScheduler(distList[1].Id));
        System.schedule('SendDistributionScheduler3'+system.now(), nextScheduleTime, new SendDistributionScheduler(distList[2].Id));
        Test.stopTest(); 
    }
}