public with sharing class IncidentController {

    public PageReference refresh= new PageReference(ApexPages.currentPage().getUrl());
    public Attachment atimage{get;set;}
    // list of existing attachments - populated on demand
    public List<Attachment> attachments;
    
    // list of new attachments to add
    public List<Attachment> newAttachments {get; set;}
    // the number of new attachments to add to the list when the user clicks 'Add More'
    public static final Integer NUM_ATTACHMENTS_TO_ADD=3;
    public List<Incident_Report_Participants__c > newParticipants{get;set;}
    public List<Account> school;
    Id accId{get; set;}
    Id  incidentid{get; set;}

    public IncidentController(ApexPages.StandardController controller) {
        
        try{
            SFDCAccessController accessForobj = ExAMUtilClass.AccessController;
            List<String> fieldsList = new List<String>{'ExAM__FacilityOrSchoolName__c','ExAM__Facility_Name__c','ExAM__Facility_Type__c','ExAM__Incident_Classification__c','ExAM__IncidentDescription__c','ExAM__Incident_List__c','ExAM__Incident_Location__c','ExAM__Incident_Time__c','ExAM__Incident_Type__c','ExAM__Notifications__c','ExAM__Participants_List__c'};
            accessForobj.assertAuthorizedToview(Schema.getGlobalDescribe().get('exam__Incident__c'), fieldsList);
            VisRecord=(Incident__c)controller.getRecord();
            newParticipants=new List<Incident_Report_Participants__c >{};
            school=new List<Account>{};
            atimage = new Attachment(); 
            // instantiate the list with a single attachment
            newAttachments=new List<Attachment>{new Attachment()};
            for (Integer idx=0; idx<NUM_ATTACHMENTS_TO_ADD; idx++)
            {
                newAttachments.add(new Attachment());
            }
            //attachfile=new List<Attachment>();
            //VisRecord.Date_and_Time__c= System.now();//Date.today();
        }catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
           // return null;
        }
    }

    // retrieve the existing attachments
    /* public List<Attachment> getAttachments() {

        // only execute the SOQL if the list hasn't been initialised
        if (null==attachments)
        {
            attachments=[select Id, ParentId, Name, Description from Attachment];
        }
        return attachments;
    }*/

    // Add more attachments action method
    /*public void addMore()
    {
        // append NUM_ATTACHMENTS_TO_ADD to the new attachments list
        for (Integer idx=0; idx<NUM_ATTACHMENTS_TO_ADD; idx++)
        {
            newAttachments.add(new Attachment());
        }
    }*/ 

    //Incident__c
    public Incident__c VisRecord
    {

        get{
            if(VisRecord==null) {
                VisRecord= new Incident__c();
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

    public PageReference save()
    {
        String facilityname=VisRecord.Facility_Name__c;
        //where name like :facilityname
        school=[select id,name from Account where name=:facilityname];

        try{
            if(school.isEmpty())
            {

                SFDCAccessController accessAcc = ExAMUtilClass.AccessController;
                List<string> fieldsListAcc = new List<string>{'Name'};
                accessAcc.assertAuthorizedToCreate(Schema.getGlobalDescribe().get('Account'), fieldsListAcc);

                //school doesnt exist so craete the account and link it
                Account acc=new Account(name =facilityname);
                insert acc;
                accId=acc.id;
                VisRecord.FacilityOrSchoolName__c=accId;
            }
            else
            {
                VisRecord.FacilityOrSchoolName__c=school.get(0).id;
            }
            String pliststr='';
            if((VisRecord.Participants_List__c!=null)||(VisRecord.Participants_List__c!='\n'))
            {
                pliststr=VisRecord.Participants_List__c;
            }

            SFDCAccessController accessIncident = ExAMUtilClass.AccessController;
            List<string> fieldsListIncident = new List<string>{'ExAM__FacilityOrSchoolName__c', 'ExAM__Facility_Type__c', 'ExAM__Incident_Location__c', 'ExAM__Incident_Time__c', 'ExAM__Incident_Classification__c', 'ExAM__Incident_Type__c', 'ExAM__Incident_List__c', 'ExAM__Participants_List__c', 'ExAM__IncidentDescription__c', 'ExAM__Notifications__c'};
            accessIncident.assertAuthorizedToCreate(Schema.getGlobalDescribe().get('exam__Incident__c'), fieldsListIncident);

            insert VisRecord;
            incidentid = VisRecord.id;
            if(incidentid!=null)
            {
                if((pliststr!=null)||(pliststr!=''))
                {
                    LIST<String> plist = pliststr.split('\r?\n|\r');
                    for(String alllists: plist) 
                    {
                        Incident_Report_Participants__c  Partici= new Incident_Report_Participants__c ();
                        if(alllists!=null)
                        {
                            LIST<String> pData = alllists.split(',');
                            for(String partidata: pData) 
                            {
                                if(partidata.startsWith('Gender:'))
                                {
                                    Partici.Gender__c=partidata.substring(7);
                                }
                                else if(partidata.startsWith('Age:'))
                                {
                                    Partici.Age_LC__c=partidata.substring(4);
                                }
                                else if(partidata.startsWith('Status:'))
                                {
                                    Partici.Status__c=partidata.substring(7);
                                }
                                else if(partidata.startsWith('Grade:'))
                                {
                                    Partici.Grade_LC__c=partidata.substring(6);
                                }
                            }
                            Partici.IncidentParticipant__c=incidentid;
                            newParticipants.add(Partici);
                        }
                    }
                    SFDCAccessController accessForobj = ExAMUtilClass.AccessController;
                    List<String> fieldsList = new List<String>{'ExAM__Gender__c','ExAM__Age_LC__c','ExAM__Status__c','ExAM__Grade_LC__c','ExAM__IncidentParticipant__c'};
                    accessForobj.assertAuthorizedToCreate(Schema.getGlobalDescribe().get('exam__Incident_Report_Participants__c'), fieldsList);
                    accessForobj.assertAuthorizedToUpdate(Schema.getGlobalDescribe().get('exam__Incident_Report_Participants__c'), fieldsList);
                    upsert newParticipants;
                }
                List<Attachment> toInsert=new List<Attachment>();
                if(newAttachments!=null)
                {
                    for (Attachment newAtt : newAttachments)
                    {
                        if (newAtt.Body!=null)
                        {
                            newAtt.parentId=incidentid;
                            toInsert.add(newAtt);
                        }
                    }
                    insert toInsert;
                    newAttachments.clear();
                }
                // null the list of existing attachments - this will be rebuilt when the page is refreshed
                attachments=null;
                String urlform='/apex/IncidentForm';       
                PageReference saveClicked=new PageReference(urlform);
                saveClicked.setRedirect(true);
                //return refresh;
                return saveClicked;
            } 
        }catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
            return null;
        }
        return null;
        //return refresh;
    }

    /*public PageReference home()
    {
        PageReference cancelClicked=new PageReference('/home/home.jsp');
        cancelClicked.setRedirect(true);
        return cancelClicked;
    }*/
  
    public static testMethod void testIncidentReport()
    {
    
        PageReference pageRef = Page.IncidentForm;
        Test.setCurrentPage(pageRef);

        ApexPages.currentPage().getUrl();

        Test.startTest();
        Incident__c ac=new Incident__c();
        Incident_Report_Participants__c part=new Incident_Report_Participants__c();
        ApexPages.StandardController sc = new ApexPages.StandardController(ac);
        IncidentController   d= new IncidentController(sc); 
        Account acct=new Account(name='test school');insert acct;
        d.VisRecord=null;
        d.VisRecord.Participants_List__c='Gender:Male,Age:13,Grade:4,Status:Other';
        d.Participants=null;
        d.accId=acct.id;
        System.currentPageReference().getParameters().put('VisRecord.Facility_Name__c', 'test');
        d.VisRecord.Facility_Name__c= 'test';
        d.save(); d.cancel();//d.home();

        List<Attachment> newAttachments =new List<Attachment>();

        ac=new Incident__c(name ='test incident',FacilityOrSchoolName__c=acct.id,Facility_Name__c='test incident',Participants_List__c='Gender:Male,Age:13,Grade:4,Status:Other\nGender:Male,Age:13,Grade:4,Status:Other');
        insert ac;

        sc = new ApexPages.StandardController(ac);
        d = new IncidentController(sc); 
        d.VisRecord.Participants_List__c='Gender:Male,Age:13,Grade:4,Status:Other';
        d.VisRecord=ac;d.accId=acct.id;
        d.incidentid=ac.id;
    
        System.currentPageReference().getParameters().put('VisRecord.Facility_Name__c', 'test school');
        d.VisRecord.Facility_Name__c= 'test school';
        d.save();

        d= new IncidentController(sc);
        Incident_Report_Participants__c Participants= new Incident_Report_Participants__c (name='john',First_Name__c='John',Last_Name__c='Doe');

        Participants.IncidentParticipant__c=ac.id;
        insert Participants;

        Attachment attach=new Attachment();    
        attach.Name='Unit Test Attachment';
        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
        attach.body=bodyBlob;
        attach.parentId=ac.id;

        Attachment attach1=new Attachment();
        attach1.Name='Unit Test Attachment2';
        bodyBlob=Blob.valueOf('Unit Test Attachment Body');
        attach1.body=bodyBlob;
        attach1.parentId=ac.id;

        newAttachments.add(attach);
        newAttachments.add(attach1);
        upsert newAttachments;
        d.save();
        /*Incident__c  acnew=[Select id,FacilityOrSchoolName__c,Facility_Name__c,Participants_List__c from Incident__c  where name='test incident' limit 1];     
        d.VisRecord=acnew;
        d.save();d.home();*/
        Test.stopTest();

        //assert results
        System.assert(ac!=null,'Report is not null');
    }

    public PageReference cancel()
    {
        //Default goes to Home page so not putting anything here
        //PageReference cancelClicked=new PageReference('/apex/QuestionnaireCustom');
        return refresh;  
    }
}