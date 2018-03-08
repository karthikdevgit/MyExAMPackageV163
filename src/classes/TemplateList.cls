public with sharing class TemplateList {

    public List<Main_questionaire__c> templateLists { get; set; }
    public static String templateid {get;set;}

    public TemplateList() {

        try {

            SFDCAccessController access = ExAMUtilClass.AccessController;
            List<String> fieldsList = new List<String>{'ExAM__Template_name__c'};
            access.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Main_questionaire__c'), fieldsList);

            templateLists = [
                SELECT Id, Name, Template_name__c
                FROM   Main_questionaire__c ORDER BY Template_name__c LIMIT 1000
            ];
        }
        catch (Exception e) {
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()) );
        }
    }

    /* @RemoteAction
    global static void settemplateid(String tempid)
    {templateid =tempid; //System.currentPagereference().getParameters().get('templateid');//templateObj.InvestigationType__c=templateid;
    System.debug('Assess id'+',,,,'+templateid );
    
     String urlform='/'+templateObj;
           PageReference saveClicked=new PageReference(urlform);
           saveClicked.setRedirect(true);
           return saveClicked;
    }*/

    public IssueRequest_Life_Cycle__c templateObj
    {

        get{

            if(templateObj==null)
            {
                templateObj = new IssueRequest_Life_Cycle__c();
            }
            return templateObj;
        }
        set;
    }

    public List<SelectOption> getName() {

        List<SelectOption> options = new List<SelectOption>();

        try {

            SFDCAccessController access = ExAMUtilClass.AccessController;
            List<String> fieldsList = new List<String>{'ExAM__Template_name__c'};
            access.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Main_questionaire__c'), fieldsList);
            for(Main_questionaire__c f : [SELECT Id, Name, Template_name__c FROM Main_questionaire__c ORDER BY Template_name__c LIMIT 1000]) {
                options.add( new SelectOption(f.id, f.Template_name__c) );
            }
        }
        catch (Exception e) {
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()) );
        }
        return options;
    }

    public PageReference submitIssue() {

        try {

            //templateid = System.currentPagereference().getParameters().get('templateid');
            if (templateid != null && templateid != '') {

                SFDCAccessController access = ExAMUtilClass.AccessController;
                List<String> fieldsListToCreate = new List<String>{'ExAM__InvestigationType__c'};
                access.assertAuthorizedToCreate(Schema.getGlobalDescribe().get('exam__IssueRequest_Life_Cycle__c'), fieldsListToCreate);

                templateObj.InvestigationType__c = templateid;
                if(templateObj!=null ) {
                    upsert templateObj;
                }
                String urlform = '/'+templateObj.id;
                PageReference saveClicked = new PageReference(urlform);
                saveClicked.setRedirect(true);
                return saveClicked;
            }
            else {
                ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select a template to create Assignment Manager') );
            }
        }
        catch (Exception e) {
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()) );
        }
        return null;
    }

    public static testMethod void testlistacc() {

        Test.startTest();
        Main_questionaire__c maintest=new Main_questionaire__c (Template_name__c ='test');
        upsert maintest;
        TemplateList  d= new TemplateList ();
        d.getName();
        d.submitIssue();
        System.assert(d.templateObj!=null);
        Test.stopTest();
    }
}