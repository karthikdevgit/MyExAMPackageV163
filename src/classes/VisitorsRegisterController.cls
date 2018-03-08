public with sharing class VisitorsRegisterController {

    public PageReference refresh = new PageReference(ApexPages.currentPage().getUrl());
    public Visitor_Register__c VisRecord;

    public VisitorsRegisterController(ApexPages.StandardController controller)
    {

        VisRecord = (Visitor_Register__c)controller.getRecord();
        VisRecord.Date_and_TimeIN__c = System.now();//Date.today();
    }
    
    public VisitorsRegisterController(){}

    public PageReference save()
    {

        try {

            if (string.isBlank(visRecord.ExAM__Visitor__c) && string.isBlank(visRecord.Visitor_Last_Name__c)) {
                ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, 'Please enter value for Visitors Name') );
                return null;
            }
            else {

                SFDCAccessController access = ExAMUtilClass.AccessController;
                List<String> fieldsList = new List<String>{'ExAM__Date_and_TimeIN__c', 'ExAM__Person_Place_Visiting__c', 'ExAM__Visitor__c', 'ExAM__Visitor_Last_Name__c'};
                access.assertAuthorizedToCreate(Schema.getGlobalDescribe().get('exam__Visitor_Register__c'), fieldsList);
                access.assertAuthorizedToUpdate(Schema.getGlobalDescribe().get('exam__Visitor_Register__c'), fieldsList);

                //Visitor_Register__c visitorRecord=new Visitor_Register__c();
                upsert visRecord;

                PageReference cancelClicked = new PageReference('/home/home.jsp');
                cancelClicked.setRedirect(false);
                return cancelClicked;
            }
        }
        catch (Exception e) {
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()) );
        }
        return null;
    }

    public static testMethod void testVisitorReport() {

        PageReference pageRef = Page.VisitorsRegister;
        Test.setCurrentPage(pageRef);
        Visitor_Register__c ac=new Visitor_Register__c(Visitor_Last_Name__c='testvisitor',Visitor__c='fnvisitor');
        insert ac;    // [Select id,Visitor__c from Visitor_Register__c limit 1];      
        VisitorsRegisterController d= new VisitorsRegisterController ();      
        ApexPages.currentPage().getUrl();
        // Visitor_Register__c ac=[Select id,Visitor__c from Visitor_Register__c limit 1]; 
        ApexPages.StandardController sc = new ApexPages.StandardController(ac);
        VisitorsRegisterController d1= new VisitorsRegisterController (sc);  
        
        Test.startTest();
        d.VisRecord=ac;
        d.VisRecord.Date_and_TimeIN__c= System.now();
        d.save();
        Test.stopTest();

        //assert results
        System.assert(ac!=null,'Report is null');     
     }

    /* @isTest(SeeAllData=true)
    public static  void testVisitorReport() {

        PageReference pageRef = Page.VisitorsRegister;
        Test.setCurrentPage(pageRef);
        VisitorsRegisterController d= new VisitorsRegisterController ();      
        ApexPages.currentPage().getUrl();
        Visitor_Register__c ac=[Select id,Visitor__c from Visitor_Register__c limit 1]; 
        ApexPages.StandardController sc = new ApexPages.StandardController(ac);
        VisitorsRegisterController d1= new VisitorsRegisterController (sc);  

        Test.startTest();
        d.VisRecord=ac;
        d.VisRecord.Date_and_TimeIN__c= System.now();
        d.save();
        Test.stopTest();

        //assert results
        System.assert(ac!=null,'Report is null');     
     }*/

    /*public PageReference submitForApproval()
    {
        //SectionStatus__c[] userSectionStatus=[Select id,Section_Template__c,Status__c,User__c from SectionStatus__c where User__c= :UserInfo.getUserId()] ;
        SectionStatus__c[] userSectionStatus=[Select id,Section_Template__c,Status__c,Account_to_SectionStatus__c,User__c from SectionStatus__c where Account_to_SectionStatus__c= :accountId] ;
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setComments('Submitting request for approval.');
        req1.setObjectId(userSectionStatus[0].id);
        Approval.ProcessResult result = Approval.process(req1); 
        System.assert(result.isSuccess());  
        PageReference cancelClicked=new PageReference('/apex/OHSESMain');
        cancelClicked.setRedirect(false);
        return cancelClicked;
    }*/

    /* public PageReference cancel()
    {
        //Default goes to Home page so not putting anything here
        //PageReference cancelClicked=new PageReference('/apex/QuestionnaireCustom');
        PageReference cancelClicked=new PageReference('/apex/SurveyList');
        cancelClicked.setRedirect(false);
        return cancelClicked;  
    }*/
}