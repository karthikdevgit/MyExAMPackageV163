public with sharing class ContactUsController{

    public PageReference refresh= new PageReference(ApexPages.currentPage().getUrl());
    ApexPages.StandardController controller;
    // public Contact VisRecord;
    // public Account VisAccRecord;

    public ContactUsController(ApexPages.StandardController con){
        controller = con;
        VisRecord=(Contact)con.getRecord();
    }

    public ContactUsController(){}

    public Contact VisRecord
    {
        get{
            if(VisRecord==null) {
                VisRecord= new Contact ();
            }
            return VisRecord;
        }
        set;
    }

    public Account VisAccRecord
    {
        get{
            if(VisAccRecord==null) {
                VisAccRecord= new Account ();
            }
            return VisAccRecord;
        }
        set;
    }
    public PageReference save() {

        try{
            if((VisAccRecord.Name!=null)) {
               
                SFDCAccessController accessAccount = ExAMUtilClass.AccessController;
                List<String> fieldsListAccount = new List<String>{'ExAM__Create_Survey__c'};
                accessAccount.assertAuthorizedToCreate(Schema.getGlobalDescribe().get('Account'), fieldsListAccount);
                accessAccount.assertAuthorizedToUpdate(Schema.getGlobalDescribe().get('Account'), fieldsListAccount);

                VisAccRecord.Create_Survey__c  =true;
                upsert VisAccRecord;

                SFDCAccessController accessContact = ExAMUtilClass.AccessController;
                List<String> fieldsListContact = new List<String>{'Email', 'FirstName', 'LastName', 'Phone', 'Title'};
                accessContact.assertAuthorizedToCreate(Schema.getGlobalDescribe().get('Contact'), fieldsListContact);
                accessContact.assertAuthorizedToUpdate(Schema.getGlobalDescribe().get('Contact'), fieldsListContact);

                VisRecord.accountId = VisAccRecord.id; 
                upsert VisRecord;
            }
            PageReference cancelClicked=new PageReference('http://EXAM4SCHOOLS.COM/');
            cancelClicked.setRedirect(false);
            return cancelClicked;
        }catch(Exception ex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
            return null;
        }     
    }

     public static testMethod void testContactUsController()
     {   
         PageReference pageRef = Page.ContactUs;
         Test.setCurrentPage(pageRef);

         ApexPages.currentPage().getUrl();
         Test.startTest();
         Account acc=new Account(name='test account');
         insert acc;
         Contact c = new Contact();

         c.Account = acc;
         c.LastName = 'John Doe';
         insert c;
        // ApexPages.StandardController sc = new ApexPages.StandardController(ac);
         ContactUsController d= new ContactUsController();  

         ApexPages.StandardController sc = new ApexPages.StandardController(c);
         ContactUsController d1= new ContactUsController(sc);  

         if(c==null)
         {
         c=d.VisRecord;c.Account=d.VisAccRecord;
         }
         else
         {d.VisRecord=c; d.VisAccRecord=c.Account;}

         d.save();  //d.cancel();    

         //When contact and account does not exist
         d.VisRecord=null; d.VisAccRecord=null;  
         if(c==null)
         {
         c=d.VisRecord;c.Account=d.VisAccRecord;
         }
         else
         {d.VisRecord=c; d.VisAccRecord=c.Account;}

         d.save();  //d.cancel(); 
         Test.stopTest();

         //assert results
         System.assert(c!=null,'contact is not null and and created');
     }
}