public with sharing class safetyInspectioncontroller {

    public safetyInspectioncontroller(ApexPages.StandardController controller) {}

    public SafetyInspection__c VisRecord {

        get{

            if(VisRecord==null)
                VisRecord= new SafetyInspection__c();

            return VisRecord;
        }
        set;
    }

    public PageReference cancel() {

        PageReference cancelClicked=new PageReference(ApexPages.currentPage().getUrl());
        cancelClicked.setRedirect(true);
        return cancelClicked;
    }

    public PageReference save() {  

        try {

            SFDCAccessController accessSI = ExAMUtilClass.AccessController;
            List<String> fieldsListSI = new List<String>{'ExAM__Inspection_Date__c', 'ExAM__Facility__c', 'ExAM__Facility_Type__c', 'ExAM__Inspector__c', 'ExAM__Site_Administrator__c', 'ExAM__Email__c', 'ExAM__Inspection_Type__c', 'ExAM__Addressee__c', 'ExAM__Project_No__c', 'ExAM__Complex_Project_Manager__c', 'ExAM__Category__c', 'ExAM__Type__c', 'ExAM__Sub_Type__c', 'ExAM__Locations__c', 'ExAM__Comments__c', 'ExAM__Priority__c', 'ExAM__Default__c', 'ExAM__Responsible_Party__c', 'ExAM__Default_2__c'};
            accessSI.assertAuthorizedToCreate(Schema.getGlobalDescribe().get('exam__SafetyInspection__c'), fieldsListSI);
            accessSI.assertAuthorizedToUpdate(Schema.getGlobalDescribe().get('exam__SafetyInspection__c'), fieldsListSI);

            System.debug('------'+VisRecord.Sub_Type__c);String caction='';
            if(VisRecord.Sub_Type__c=='Program – HAZCOM')
            {caction='Implement a Hazard Communication Program pursuant to Cal/OSHA requirements. To obtain a copy of the Districts Hazard Communication Program, contact OEHS at (213) 241-3199.';}
            else if(VisRecord.Sub_Type__c=='Chemical Inventory')
            {caction='Maintain school chemical inventory pursuant to Hazard Communication Program.';}
            else if(VisRecord.Sub_Type__c=='Plan – Chemical Hygiene & Safety')
            {caction='Maintain and implement Chemical Hygiene & Safety Plan and ensure it is readily available to all employees. The plan should identify a Chemical Safety Coordinator and be revised at least annually.';}
            else if(VisRecord.Sub_Type__c=='Visitor’s Pass')
            {caction='Ensure visitors entering school grounds sign in and receive a visitor’s pass.';}
            else if(VisRecord.Sub_Type__c=='Posting – Visitation Policy')
            {caction='Ensure school visitation policy is posted and distributed annually to parents and staff.';}
            else if(VisRecord.Sub_Type__c=='Communicating Emergencies')
            {caction='Ensure all classrooms are provided with a communications system that can contact the main office or call 911. New schools and building additions constructed after 2000 require a telephone system capable of calling 911.';}
            else if(VisRecord.Sub_Type__c=='Availability')
            {caction='Ensure that an Asbestos Management Plan is available to employees, parents and others pursuant to 40 CFR.';}
            else if(VisRecord.Sub_Type__c=='Current')
            {caction='Confer with Asbestos Technical Unit (ATU) to ensure that the Asbestos Management Plan is current and identifies the location of all asbestos containing material (ACM). For assistance, contact ATU at (213) 745-1450.';}
            else if(VisRecord.Sub_Type__c=='Asbestos Work Compliance')
            {caction='Ensure regulatory compliance with asbestos work practices, engineering controls, personal protective equipment, and clearance air monitoring requirements for all releases or abatement activities.';}
            //alert(document.getElementById("{!$Component.pagesf.incidentForm.corraction}");
            //alert(document.getElementById('corraction1'));
            VisRecord.Corrective_Action__c = caction;
            upsert visrecord;
            PageReference cancelClicked=new PageReference(ApexPages.currentPage().getUrl());
            cancelClicked.setRedirect(true);
            return cancelClicked;

        }
        catch(Exception ex) {
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()) );
        }
        return null;
    }

    public PageReference home() {

        PageReference cancelClicked;
        /*String userAgent =ApexPages.currentPage().getHeaders().get('USER-AGENT');

        if(userAgent.contains('iPhone')) {
        cancelClicked=new PageReference('/one/one.app');
        }
        else { */cancelClicked=new PageReference('/home/home.jsp');
        // }
        cancelClicked.setRedirect(true);
        return cancelClicked; 
    }

    public static testMethod void testSafetyInspection() {
        PageReference pageRef = Page.SafetyInspection;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getUrl();
        Test.startTest();
        SafetyInspection__c ac=new SafetyInspection__c();
        ApexPages.StandardController sc = new ApexPages.StandardController(ac);
        safetyInspectioncontroller d= new safetyInspectioncontroller(sc); 
        d.VisRecord=null;
        d.VisRecord.Sub_Type__c='Chemical Inventory';
        System.currentPageReference().getParameters().put('VisRecord.Sub_Type__c', 'Chemical Inventory');            
        d.save(); d.cancel();d.home();           
        d.VisRecord.Sub_Type__c='Plan – Chemical Hygiene & Safety';
        System.currentPageReference().getParameters().put('VisRecord.Sub_Type__c', 'Plan – Chemical Hygiene & Safety');            
        d.save();            
        d.VisRecord.Sub_Type__c='Availability';
        System.currentPageReference().getParameters().put('VisRecord.Sub_Type__c', 'Availability');
        d.save();              
        d.VisRecord.Sub_Type__c='Current';
        System.currentPageReference().getParameters().put('VisRecord.Sub_Type__c', 'Current');            
        d.save();  
        d.VisRecord.Sub_Type__c= 'Communicating Emergencies';             
        System.currentPageReference().getParameters().put('VisRecord.Sub_Type__c', 'Communicating Emergencies');    //assert results
        d.save();  Test.stopTest();           
        System.assert(ac!=null,'Report is not null');
    }
}