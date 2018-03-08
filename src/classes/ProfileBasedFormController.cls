public with sharing class ProfileBasedFormController {

    public ExAM__IssueRequest_Life_Cycle__c issue {
        get;
        set;
    }
    public List < ExAM__Main_questionaire__c > templateList {
        get;
        set;
    }
    public List < SelectOption > tempList {
        get;
        set;
    }
    public List < SelectOption > accList {
        get;
        set;
    }
    public List < Account > accObjs {
        get;
        set;
    }
    public String accname {
        get;
        set;
    }
    public String tempid {
        get;
        set;
    }
    public Account acc {
        get;
        set;
    }
    /*public String getLongDate() {

    Datetime cDT = System.now();

    LongDate = cDT.format('EEEE, MMMM d, yyyy');

    return LongDate;

  }*/

    public ProfileBasedFormController(ApexPages.StandardController controller) {
        try{
            accList = new List < SelectOption > ();
            tempList = new List < SelectOption > ();
            
            SFDCAccessController accessForAM = ExAMUtilClass.AccessController;
            
            List<String> fieldsListAM = new List<String>{'ExAM__Assessment_Date_Time__c','ExAM__Facility_Name__c'};
            accessForAM.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__IssueRequest_Life_Cycle__c'), fieldsListAM);
            
            issue = new ExAM__IssueRequest_Life_Cycle__c();
            issue.ExAM__Assessment_Date_Time__c = system.now();
            //issue.ExAM__Assessor_Resource__c=UserInfo.getUserId();
            User lstUser = [Select Id, ContactId from User where Id = : UserInfo.getUserId()];
            //String usrd='00317000001X20E';
            System.debug('lstUser details' + lstUser + ',,,lstUser.ContactId' + lstUser.ContactId);
            
            accObjs = new List < Account > ();
            if (lstUser.ContactId != null) {
                Contact con = [select id, AccountId, Account.Name from Contact where id = : lstUser.ContactId];
                System.debug('contact of user account portal' + con.Account.name);
                accname = con.Account.Name;
                issue.ExAM__Facility_Name__c = con.AccountId;
                System.debug('222');
            } else { //it is normal user so get all accounts for which it is the owner
                accObjs = [select id, name, ownerId, ExAM__Create_Survey__c from Account where ownerId = : UserInfo.getUserId() and ExAM__Create_Survey__c = false order by name limit 1000];
                System.debug('user id:' + UserInfo.getUserId() + ',,,,,' + accObjs);
                for (Account acc: accObjs) {
                    accList.add(new SelectOption(acc.id, acc.name));
                }
    
            }
            
            List<String> fieldsListAT = new List<String>{'ExAM__Template_name__c','ExAM__Description__c','ExAM__Available_in_Portal__c'};
            accessForAM.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Main_questionaire__c'), fieldsListAT);
            
            templateList = [select id, ExAM__Template_name__c, ExAM__Description__c, ExAM__Available_in_Portal__c from ExAM__Main_questionaire__c WHERE ExAM__Available_in_Portal__c = true order by ExAM__Template_name__c limit 1000];
            /*if(templateList!=null)
            {
            for(ExAM__Main_questionaire__c t:templateList)
                {
                 tempList.add(new SelectOption(t.id,t.ExAM__Template_name__c ));
                }
            }*/ 
        } catch( Exception e ){
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()) );
        }
    }
    public PageReference cancel() {
        String urlform = '/apex/ProfileBasedForm';
        //'/apex/QuestionnaireCustomIssue?accid='+accountId+'&issueid='+issueId+'&templatename='+templateName;
        PageReference saveClicked = new PageReference(urlform);
        saveClicked.setRedirect(true);
        return saveClicked;
    }
    public PageReference save() {
        try{
            System.debug('in SAVE');
            
            SFDCAccessController accessForSSCreate = ExAMUtilClass.AccessController;
            List<String> fieldsListSSCreate = new List<String>{'ExAM__InvestigationType__c'};
            accessForSSCreate.assertAuthorizedToCreate(Schema.getGlobalDescribe().get('exam__IssueRequest_Life_Cycle__c'), fieldsListSSCreate);
            
            String templateid = System.currentPagereference().getParameters().get('templat');
            if (templateid != null) {
                issue.ExAM__InvestigationType__c = templateid;
            }
            System.debug('in SAVEtemplateid' + templateid);
            System.debug('111111111 isue' + issue);
            upsert issue;
            System.debug('END SAVE');
            String urlform = '/' + issue.id;
            PageReference saveClicked = new PageReference(urlform);
            saveClicked.setRedirect(true);
            return saveClicked;
        } catch ( Exception e ){
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()) );
            return null;
        }
    }    
}