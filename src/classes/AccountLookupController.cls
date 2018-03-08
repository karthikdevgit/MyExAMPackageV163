public with sharing class AccountLookupController {

    public string accName { get; set; }
    public string accNameFieldId { get; set; }
    public string accHiddenFieldId { get; set; }

    public Boolean error { get; set; }

    public Id LicenseValue { get; set; }

    public Account accObj { get; set; }

    public List<Account> accList {get;set;}

    public AccountLookupController(ApexPages.StandardController controller) {  

        try {
            error = false;
            accObj = new Account();
            accName = ApexPages.currentPage().getParameters().get('accName');
            accNameFieldId = ApexPages.currentPage().getParameters().get('accNameFieldId');
            accHiddenFieldId = ApexPages.currentPage().getParameters().get('accHiddenField');

            SFDCAccessController accessAcct = ExAMUtilClass.AccessController;
            accessAcct.assertAuthorizedToView(Schema.getGlobalDescribe().get('Account'), new List<string>());

            if(string.isNotBlank(accName)){
                 accList = [
                     SELECT Id, Name
                     FROM Account
                     WHERE (Create_Survey__c=null OR Create_Survey__c=false) AND (Main_Questionnaire_Template__c=NULL) AND Name =: accName LIMIT 100
                 ];
                 if(accList.size() == 0 && accName.length() > 0){
                     accList = [
                         SELECT Id, Name
                         FROM Account
                         WHERE (Create_Survey__c=null OR Create_Survey__c=false) AND (Main_Questionnaire_Template__c=NULL) AND Name LIKE:  '%'+ accName +'%' LIMIT 100
                     ];
                 }
             }else{
                  accList = [SELECT Id, Name FROM Account WHERE (Create_Survey__c=null OR Create_Survey__c=false) AND (Main_Questionnaire_Template__c=NULL)  LIMIT 100];
             }
        }
        catch (Exception exp)
        {
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, exp.getMessage()));
        }
    }

    /*public PageReference consAction(){
        if(accList.size() == 0){
            string strCmpName;
            if(string.isNotBlank(strCmpName)){  
                Account newAccount = new Account();

                newAccount.Name = strCmpName;
                insert newAccount; 
                searchUsers();                 
            }
            
         }
         return NULL;
    }*/

    public PageReference searchUsers(){
        try {

            SFDCAccessController accessAcct = ExAMUtilClass.AccessController;
            accessAcct.assertAuthorizedToView(Schema.getGlobalDescribe().get('Account'), new List<string>());

            if(accName != NULL && accName != ''){
                accList = [
                    SELECT Id, Name 
                    FROM   Account
                    WHERE  Name = :accName
                           AND (Main_Questionnaire_Template__c=NULL)
                           AND (Create_Survey__c=null OR Create_Survey__c=false) LIMIT 100
                ];
                if(accList.size() == 0 && accName.length() > 0){
                    accList = [
                        SELECT Id, Name
                        FROM   Account
                        WHERE  Name LIKE:  '%'+ accName +'%'
                               AND (Main_Questionnaire_Template__c=NULL)
                               AND (Create_Survey__c=null OR Create_Survey__c=false) LIMIT 100
                    ];
                }
            }else{
                accList = [
                    SELECT Id, Name
                    FROM   Account
                    WHERE  (Create_Survey__c=null OR Create_Survey__c=false)
                           AND (Main_Questionnaire_Template__c=NULL) order by name LIMIT 100
                ]; 
            }
        }
        catch (Exception exp)
        {
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, exp.getMessage()));
        }
        return null;
    }

    /*public PageReference addAccount(){
        Account newAccount = new Account();
        if(string.isNotBlank(accName)){  
                                                
            string strCmpName; 
            if(string.isNotBlank(strCmpName)){  
                newAccount.Name = strCmpName;   

            }else{                         
                newAccount.Name = accName;  
                //ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR,accName+' is not valid ticker.'));
                //return NULL;
            }
            insert newAccount;
        }        
        return NULL;
    }*/
}