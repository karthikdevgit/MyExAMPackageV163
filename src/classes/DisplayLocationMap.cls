public with sharing class DisplayLocationMap
{
     public List<Locations> accounts;
     public Account[] accLists { get; set; }
    
     public List<Account> allaccounts=new List<Account>();
     public List<Main_Report_Data__c> allreportdata=new List<Main_Report_Data__c>();
     public integer MailHandlingScore=0;
     public integer CCTVScore=0;
     public integer PerimeterScore=0;
     public integer AdequateLightingScore=0;
     public integer AdequateLockingScore=0;
     public integer EmergencyResponsePlanScore=0;
     public integer OverallScore=0;
    //public = new QuestionDisplay[]{};
  
/*public List<Locations> getlistacc()
    {
       accounts=[SELECT id,BillingStreet,BillingCity,BillingPostalCode,BillingCountry,name From Account where BillingStreet <>NULL and BillingPostalCode<>NULL];
       System.debug('!!!!!!!!!!!!!!!!! accoount-'+accounts);
       //System.debug('!!!!!!!!!!!!!!!!! acoount-'+accounts);
       return accounts;
    }


public void EditScores()
{
 accLists=new Account[]{};
 accounts= new Locations[]{};
 List<aggregateResult> aggr=[
   Select Account__c, Question_Template__r.Focus_category__c focus, SUM(Questionnaire_Response__r.Total_Score__c)total
   from Main_Report_Data__c
   GROUP BY Account__c, Question_Template__r.Focus_category__c];
    for (Account acc : [SELECT id,BillingStreet,BillingCity,BillingPostalCode,BillingCountry,name,Adequate_Lighting_Score__c,Adequate_Locking_Score__c,CCTV_Score__c,Emergency_Response_Plan__c,Mail_Handling_Score__c,Overall_Score__c,Perimeter_Score__c,Create_Survey__c From Account where Create_Survey__c=:true])
       {  
           acc.Overall_Score__c=0;
           for (AggregateResult ar : aggr)
           {
             
             String accid=String.valueOf(ar.get('Account__c'));
            
              if(accid.equalsIgnoreCase(acc.id))
              {
              String focuscat=String.valueOf(ar.get('focus')); 
              System.debug('account id:'+acc.id+'focus category:'+focuscat);
              acc.Overall_Score__c+=Integer.valueOf(ar.get('total'));
                  if(focuscat.equalsIgnoreCase('CCTV'))
                  {
                  System.debug('ccccccccccctvfocuscat'+focuscat);
                    acc.CCTV_Score__c=Integer.valueOf(ar.get('total'));
                  
                  }
                  else if(focuscat.equalsIgnoreCase('Perimeter'))
                  {
                 
                    acc.Perimeter_Score__c=Integer.valueOf(ar.get('total'));
                  
                  }
                   else if(focuscat.equalsIgnoreCase('Adequate Lighting'))
                  {
                 
                    acc.Adequate_Lighting_Score__c=Integer.valueOf(ar.get('total'));
                  
                  }
                   else if(focuscat.equalsIgnoreCase('Adequate Locking System'))
                  {
                  
                    acc.Adequate_Locking_Score__c=Integer.valueOf(ar.get('total'));
                  
                  }
                   else if(focuscat.equalsIgnoreCase('Emergency Response Plan'))
                  {
                 
                    acc.Emergency_Response_Plan__c=Integer.valueOf(ar.get('total'));
                  
                  }
                   else if(focuscat.equalsIgnoreCase('Mail Handling'))
                  {
                 
                    acc.Mail_Handling_Score__c=Integer.valueOf(ar.get('total'));
                  
                  }
                  
                   
                 
                   
             */ 
             
          //    }//if stmt
              
      //     }//for inner of aggr
     //   accounts.add(new Locations(acc));
     //   accLists.add(acc); 

//}
 // Creates section List
public List<Locations> getlistacc()
{
    try{
        
       SFDCAccessController accessForobj = ExAMUtilClass.AccessController;
       List<String> fieldsList = new List<String>{'ExAM__Main_Questionnaire_Template__c','ExAM__Adequate_Lighting_Score__c','ExAM__Adequate_Locking_Score__c','ExAM__CCTV_Score__c','ExAM__Emergency_Response_Plan__c','ExAM__Mail_Handling_Score__c','ExAM__Overall_Score__c','ExAM__Perimeter_Score__c','ExAM__Create_Survey__c'};
       accessForobj.assertAuthorizedToView(Schema.getGlobalDescribe().get('Account'), fieldsList);
       
       List<String> fieldsList1 = new List<String>{'ExAM__Template_name__c'};
       accessForobj.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Main_questionaire__c'), fieldsList1);
       accLists=[SELECT id,Main_Questionnaire_Template__r.Template_name__c,Main_Questionnaire_Template__c,BillingStreet,BillingCity,BillingPostalCode,BillingCountry,name,Adequate_Lighting_Score__c,Adequate_Locking_Score__c,CCTV_Score__c,Emergency_Response_Plan__c,Mail_Handling_Score__c,Overall_Score__c,Perimeter_Score__c,Create_Survey__c From Account where Create_Survey__c=:true and (BillingStreet <>NULL OR BillingCity<>NULL)and BillingPostalCode<>NULL and Main_Questionnaire_Template__c!=null and Overall_Score__c>0 and Main_Questionnaire_Template__r.Template_name__c='DOI'];
       accounts= new Locations[]{};
      
       for (Account a :accLists )
           {  
             String addr=a.BillingStreet+','+a.BillingCity+','+a.BillingPostalCode+','+a.BillingCountry;
                 
             accounts.add(new Locations(a.id,a.name,addr,a.Adequate_Lighting_Score__c,a.Adequate_Locking_Score__c,a.CCTV_Score__c,a.Emergency_Response_Plan__c,a.Mail_Handling_Score__c,a.Overall_Score__c,a.Perimeter_Score__c));
            
            }
             // Add Question Records
          /*  for (Account a : [SELECT id,color__c,Adequate_Lighting_Score__c,Adequate_Locking_Score__c,CCTV_Score__c,Emergency_Response_Plan__c,Mail_Handling_Score__c,Overall_Score__c,Perimeter_Score__c,BillingStreet,BillingCity,BillingPostalCode,BillingCountry,name From Account where BillingStreet <>NULL and BillingPostalCode<>NULL]){
                String addr=a.BillingStreet+','+a.BillingCity+','+a.BillingPostalCode+','+a.BillingCountry;
                
                
                accounts.add(new Locations(a.id,a.name,addr,a.color__c) ); 
            }*/
          
            
          return accounts;
      }catch(Exception e){
          accounts= new Locations[]{};
          String ErrorMsg = e.getMessage();
          accounts.add(new Locations(ErrorMsg));
          return accounts;
      }
    }
    
    // Create an inner class
    public class Locations{
       
        public String accountid {get; set;}
        public String accountname {get; set;}
        public String accountaddress {get; set;}
        public String accountcolor{get;set;}
        public Decimal accountLightingScore {get; set;}
        public Decimal accountLockingScore {get; set;}
        public Decimal accountCCTVScore{get; set;}
        public Decimal accountEResponseScore{get;set;}   
        public Decimal accountMailHandlingScore{get;set;}
        public Decimal accountOverallScore{get;set;}
        public Decimal accountPerimeterScore{get;set;}   
        public Account accountobj{get;set;}
        public String ErrorMsg{get;set;}
        public  Locations(String aid,String aname,String aaddress,Decimal Lighting_Score,Decimal Locking_Score,Decimal CCTV_Score,Decimal Emergency_Response_Score,Decimal Mail_Handling_Score,Decimal Overall_Score,Decimal Perimeter_Score)
        {
            accountid=aid;
            accountname=aname;
            accountaddress=aaddress;
            accountLightingScore =Lighting_Score;  
            accountLockingScore=Locking_Score;
            accountCCTVScore =CCTV_Score;
            accountEResponseScore=Emergency_Response_Score;
            accountMailHandlingScore=Mail_Handling_Score;  
            accountOverallScore           =Overall_Score;
            accountPerimeterScore           =Perimeter_Score;
                     
        }
        public  Locations(String errmsg){
            ErrorMsg = errmsg;
        }
        /* public  Locations(Account accnt)
         {
         accountobj=accnt;
         }*/
    }

/*@isTest(SeeAllData=true)
 public static void testlistacc()
 {
    DisplayLocationMap d= new DisplayLocationMap();
    List<Locations> accountstest=new List<Locations>();
     Test.startTest();
    
    accountstest=d.getlistacc();
     Test.stopTest();
     
    
     System.assert(accountstest!=null,'Account is null');
     
 }
 */
  public static testMethod void testlistacc()
 {
    DisplayLocationMap d= new DisplayLocationMap();
    Test.startTest();
    Main_questionaire__c maintest=new Main_questionaire__c (Template_name__c ='DOI');
    upsert maintest;
    Account acc=new Account(BillingStreet='2425 Wilson Blvd',BillingCity='arlington',BillingPostalCode='22209',BillingCountry='USA',name='test account',Adequate_Lighting_Score__c=0,Adequate_Locking_Score__c=8,CCTV_Score__c=8,Overall_Score__c=16,Create_Survey__c=true);
    acc.Main_Questionnaire_Template__c=maintest.id;
    upsert acc;
    List<Locations> accountstest=new List<Locations>();
    
    accountstest=d.getlistacc();
    Test.stopTest();
     
     //assert results
     System.assert(accountstest!=null,'Account is null');
     
 }
}