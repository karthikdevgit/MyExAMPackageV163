public with sharing class IncidentLocationMAPController {

//not needed this class
    public List<Mobile_Incident_Report_Form__c> incidents{get;set;}//=new List<Mobile_Incident_Report_Form__c>();
    public String ErrorMsg {get; set;}
       
    public String getincidentslist()
    {    
        try{
            SFDCAccessController accessForobj = ExAMUtilClass.AccessController;
            List<String> fieldsList = new List<String>{'ExAM__Category__c','ExAM__Incident_Location__c','ExAM__Location__Latitude__s','ExAM__Location__Longitude__s','ExAM__Incident_Score__c'};
            accessForobj.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Mobile_Incident_Report_Form__c'), fieldsList);
            incidents=[SELECT id,name,Category__c,Incident_Location__c,Location__Latitude__s,Location__Longitude__s,Incident_Score__c from Mobile_Incident_Report_Form__c];
        
           // return JSON.serialize(incidents);
        }catch(Exception ex)
        {
            ErrorMsg = ex.getmessage();
            
        }
        return JSON.serialize(incidents);
    }

 /*public static testMethod void testlistacc()
 {
    DisplayLocationMapT2 d= new DisplayLocationMapT2();
    Test.startTest();
    Main_questionaire__c maintest=new Main_questionaire__c (Template_name__c ='test');
    upsert maintest;
    Account acc=new Account(BillingStreet='2425 Wilson Blvd',BillingCity='arlington',BillingPostalCode='22209',BillingCountry='USA',name='test account',Adequate_Lighting_Score__c=0,Adequate_Locking_Score__c=8,CCTV_Score__c=8,Overall_Score__c=16,Create_Survey__c=true);
    acc.Main_Questionnaire_Template__c=maintest.id;
    upsert acc;
    List<Locations> accountstest=new List<Locations>();
    
    accountstest=d.getlistacc();
    Test.stopTest();
     
     
     System.assert(accountstest!=null,'Account is null');
     
 }*/
}