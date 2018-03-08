public with sharing class DoDEAIncidentReportController
{
    public PageReference refresh= new PageReference(ApexPages.currentPage().getUrl());
    //public DoDEA_Serious_Incident_Report__c VisRecord;
    //public Incident_Report_Participants__c Participants;

    public DoDEAIncidentReportController(ApexPages.StandardController controller)
    {
        try{
            SFDCAccessController accessObj = ExAMUtilClass.AccessController;
            List<String> fieldsListSer = new List<String>{'ExAM__Date_and_Time__c'};
            accessObj.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__DoDEA_Serious_Incident_Report__c'), fieldsListSer);
            System.debug('eeee~~~~~~~~~~~~~------'+controller.getRecord());
            VisRecord=(DoDEA_Serious_Incident_Report__c)controller.getRecord();
            VisRecord.Date_and_Time__c= System.now();//Date.today();
        }
        catch( Exception e ){
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()) );
        }
    }

    public DoDEA_Serious_Incident_Report__c VisRecord
    {
        get{
            if(VisRecord==null) {
                VisRecord= new DoDEA_Serious_Incident_Report__c ();
            }
            return VisRecord;
        }
        set;
    }

    public Incident_Report_Participants__c Participants
    {
        get{
            if(Participants==null) {
                Participants= new Incident_Report_Participants__c ();
            }
            return Participants;
        }
        set;
    }

    public Incident_Report_Participants__c Participants2
    {
        get{
            if(Participants2==null) {
                Participants2= new Incident_Report_Participants__c ();
            }
            return Participants2;
        }
        set;
    }

    public Incident_Report_Participants__c Participants3
    {
        get{
            if(Participants3==null) {
                Participants3= new Incident_Report_Participants__c ();
            }
            return Participants3;
        }
        set;
    }

    public Incident_Report_Participants__c Participants4
    {
        get{
            if(Participants4==null) {
                Participants4= new Incident_Report_Participants__c ();
            }
            return Participants4;
        }
        set;
    }

    public PageReference save()
    {   
        try{

            SFDCAccessController accessObj = ExAMUtilClass.AccessController;
            List<String> fieldsList = new List<String>{'ExAM__First_Name__c','ExAM__Last_Name__c'};
            accessObj.assertAuthorizedToCreate(Schema.getGlobalDescribe().get('exam__Incident_Report_Participants__c'), fieldsList);

            if((Participants.First_Name__c!=null)||(Participants.Last_Name__c!=null))
            {
                Participants.Name=Participants.First_Name__c+' '+Participants.Last_Name__c;           
                upsert Participants;
                VisRecord.Incident_Report_Participants__c = Participants.id; 
            }
            if((Participants2.First_Name__c!=null)||(Participants2.Last_Name__c!=null))
            {
                Participants2.Name=Participants2.First_Name__c+' '+Participants2.Last_Name__c;       
                upsert Participants2;
                VisRecord.Incident_Report_Participants2__c = Participants2.id; 
            }
            if((Participants3.First_Name__c!=null)||(Participants3.Last_Name__c!=null))
            {
                Participants3.Name=Participants3.First_Name__c+' '+Participants3.Last_Name__c;       
                upsert Participants3;
                VisRecord.Incident_Report_Participants3__c = Participants3.id; 
            }
            if((Participants4.First_Name__c!=null)||(Participants4.Last_Name__c!=null))
            {
                Participants4.Name=Participants4.First_Name__c+' '+Participants4.Last_Name__c;       
                upsert Participants4;
                VisRecord.Incident_Report_Participants4__c = Participants4.id; 
            }
            if(visRecord.School_Name__c!=null)
            {
                visRecord.Name=visRecord.School_Name__c; 
            }
            List<String> fieldsListPar = new List<String>{'ExAM__School_Name__c','ExAM__Incident_Report_Participants__c','ExAM__Incident_Report_Participants2__c','ExAM__Incident_Report_Participants3__c','ExAM__Incident_Report_Participants4__c'};
            accessObj.assertAuthorizedToCreate(Schema.getGlobalDescribe().get('exam__DoDEA_Serious_Incident_Report__c'), fieldsListPar);
            upsert visRecord; 
            System.debug('~~~~~~~~~~~~~------'+VisRecord+',,,,,'+Participants);
        } catch (Exception e){
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()) );
        }
        PageReference cancelClicked=new PageReference('/home/home.jsp');
        cancelClicked.setRedirect(false);
        return cancelClicked;  
    }

    public static testMethod void testIncidentReport()
    {
        PageReference pageRef = Page.DoDEAIncidentReport;
        Test.setCurrentPage(pageRef); 
        ApexPages.currentPage().getUrl();

        Test.startTest();
        Incident_Report_Participants__c Participants= new Incident_Report_Participants__c (First_Name__c='John',Last_Name__c='Doe');
        insert Participants;
        Incident_Report_Participants__c Participants2= new Incident_Report_Participants__c (First_Name__c='John2',Last_Name__c='Doe');
        insert Participants2;
        Incident_Report_Participants__c Participants3= new Incident_Report_Participants__c (First_Name__c='John3',Last_Name__c='Doe');
        insert Participants3;
        Incident_Report_Participants__c Participants4= new Incident_Report_Participants__c (First_Name__c='John4',Last_Name__c='Doe');
        insert Participants4;
        DoDEA_Serious_Incident_Report__c ac=new DoDEA_Serious_Incident_Report__c (name ='test school',Incident_Report_Participants__c = Participants.id,Incident_Report_Participants2__c=Participants2.id,Incident_Report_Participants3__c=Participants3.id,Incident_Report_Participants4__c=Participants4.id);
        insert ac; 
        //DoDEA_Serious_Incident_Report__c ac=[Select id from DoDEA_Serious_Incident_Report__c where name='Wilson Middle School' limit 1];     
        //Incident_Report_Participants__c ac1=[Select id,First_Name__c,Last_Name__c from Incident_Report_Participants__c  limit 1];
        ApexPages.StandardController sc = new ApexPages.StandardController(ac);

        DoDEAIncidentReportController d= new DoDEAIncidentReportController(sc); 
        d.VisRecord=null;
        d.Participants=null;
        d.Participants2=null;
        d.Participants3=null;
        d.Participants4=null;
        d.save();

        d.VisRecord=ac;
        d.Participants=Participants;
        d.Participants2=Participants2;
        d.Participants3=Participants3;
        d.Participants4=Participants4;

        d.save();
        //d.cancel();
        Test.stopTest();

        //assert results
        System.assert(ac!=null,'Report is null');
    }

    /*
    public PageReference submitForApproval()
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
    }

    public PageReference cancel()
    {
        //Default goes to Home page so not putting anything here
        //PageReference cancelClicked=new PageReference('/apex/QuestionnaireCustom');
        PageReference cancelClicked=new PageReference('/apex/SurveyList');
        cancelClicked.setRedirect(false);
        return cancelClicked;  
    }
    */
}