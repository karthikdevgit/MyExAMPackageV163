public with sharing class CreateAssessmentController {

    public Boolean MobileVersion{get;set;}

    public Account acc { get; set; }

    public Map<Id, Main_questionaire__c> templateMap;

    public PageReference refresh = new PageReference(ApexPages.currentPage().getUrl());

    public CreateAssessmentController(ApexPages.StandardSetController controller) {
        startProcess();
    }

    public CreateAssessmentController() {
        MobileVersion = false;
        startProcess();
    }

    public void startProcess() {

        try{
            acc = new Account();
            templateMap = new Map<Id, Main_questionaire__c>();

            SFDCAccessController accessObj = ExAMUtilClass.AccessController;
            List<string> fieldsListAT = new List<string>{'ExAM__Template_name__c','ExAM__PublishPlace__c'};
            accessObj.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Main_questionaire__c'), fieldsListAT);

            List<Main_questionaire__c> templatesList = new List<Main_questionaire__c>();
            templatesList = [SELECT Id, PublishPlace__c, Template_name__c FROM Main_questionaire__c WHERE Template_name__c <> null AND PublishPlace__c <> null ORDER BY Template_name__c];
            if (templatesList.size() > 0) {
                templateMap = new Map<Id, Main_questionaire__c>(templatesList);
            }
        } catch(Exception e){
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()) );
        }
    }

    public PageReference mobilesave()
    {
        MobileVersion = true;
        PageReference ref = save();
        return ref;
    }

    public PageReference save() {
        try
        {
            PageReference saveClicked;
            //string mobversion=System.currentPageReference().getParameters().get('MobileVersion');

            if (acc.Name == null || acc.Main_Questionnaire_Template__c == null) {
                ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, 'Please enter Account name and choose a Assessment template') );
                return null;
            }
            else
            {
                acc.Create_Survey__c = true;
                if (templateMap.containsKey(acc.Main_Questionnaire_Template__c)
                    && templateMap.get(acc.Main_Questionnaire_Template__c) != null
                ) {
                    string templateName = templateMap.get(acc.Main_Questionnaire_Template__c).Template_name__c;
                    if (templateName.equalsIgnoreCase('DOI')) {
                        acc.AssessmentURL__c = URL.getSalesforceBaseUrl().toExternalForm() + '/apex/QuestionnaireCustomDOI';
                        acc.AssessmentURLMobile__c = URL.getSalesforceBaseUrl().toExternalForm() + '/apex/QuestionnaireCustomMobile';
                    }
                    else {
                        acc.AssessmentURL__c = URL.getSalesforceBaseUrl().toExternalForm() + '/apex/QuestionnaireCustom';
                        acc.AssessmentURLMobile__c = URL.getSalesforceBaseUrl().toExternalForm() + '/apex/QuestionnaireCustomMobile';
                    }
                }
                SFDCAccessController accessForAcc = ExAMUtilClass.AccessController;
                List<string> fieldsListAcc1 = new List<string>{'ExAM__AssessmentURL__c', 'ExAM__AssessmentURLMobile__c', 'ExAM__Create_Survey__c', 'ExAM__Main_Questionnaire_Template__c'};
                accessForAcc.assertAuthorizedToCreate(Schema.getGlobalDescribe().get('Account'), fieldsListAcc1);

                insert acc;

                if (templateMap.containsKey(acc.Main_Questionnaire_Template__c)
                    && templateMap.get(acc.Main_Questionnaire_Template__c) != null
                ) {

                    Account updateAcc = new Account(Id = acc.Id);
                    updateAcc.AssessmentURLMobile__c = URL.getSalesforceBaseUrl().toExternalForm() + '/apex/QuestionnaireCustomMobile?accId='+acc.Id;
                    updateAcc.AssessmentURL__c = URL.getSalesforceBaseUrl().toExternalForm() + '/apex/QuestionnaireCustom?accId='+acc.Id;   

                    string templateName = templateMap.get(acc.Main_Questionnaire_Template__c).Template_name__c;
                    string templatePublishPlace = templateMap.get(acc.Main_Questionnaire_Template__c).PublishPlace__c;
                    if( templatePublishPlace.equalsIgnoreCase('Internal to salesforce') )
                    {
                        //returnAssessList.add('/apex/QuestionnaireCustom?accId='+acc.Id);
                        if(templateName.equalsIgnoreCase('DOI'))
                        {
                            saveClicked = new PageReference('/apex/QuestionnaireCustomDOI?accId='+acc.Id);
                        }
                        else
                        {
                            if(MobileVersion==true)
                            {
                                saveClicked = new PageReference('/apex/QuestionnaireCustomMobile?accId='+acc.Id);
                            }
                            else
                            {
                                saveClicked = new PageReference('/apex/QuestionnaireCustom?accId='+acc.Id);
                            }
                            //saveClicked=new PageReference('/apex/QuestionnaireCustom?accId='+acc.Id);
                        }
                    }
                    else if( templatePublishPlace.equalsIgnoreCase('External Site') )
                    {
                        //returnAssessList.add('http://exam4schools-developer-edition.na15.force.com/ExAM/QuestionnaireCustomSite?accId='+acc.Id);  
                        Static_Data_Object__c externalsiteurl = Static_Data_Object__c.getValues('SiteURL');
                        if (externalsiteurl != null) {
                            string siteCompleteUrl = externalsiteurl.Site_URL__c+'QuestionnaireCustomSite?accId='+acc.Id;
                            //http://exam4schools-developer-edition.na15.force.com/ExAM/QuestionnaireCustomSite?accId='+acc.Id
                            saveClicked = new PageReference(siteCompleteUrl);
                        }
                        List<User> guestUserList = new List<User>([SELECT Id, isActive, Name FROM User WHERE Name = 'ExAM Site Guest User' LIMIT 1]);
                        if(guestUserList.size() == 0)
                        {
                            saveClicked = refresh;
                        }
                        else
                        {
                            updateAcc.OwnerId = guestUserList[0].Id;
                        }
                    }
                    /*
                    else if( templatePublishPlace.equalsIgnoreCase('External Site') )
                    {
                        //returnAssessList.add('http://exam4schools-developer-edition.na15.force.com/ExAM/QuestionnaireCustomSite?accId='+acc.Id);
                        saveClicked=new PageReference('http://exam4schools-developer-edition.na15.force.com/ExAM/QuestionnaireCustomSite?accId='+acc.Id);
                        List<User> guestUserList = new List<User>([SELECT Id, isActive, Name FROM User WHERE Name = 'ExAM Site Guest User' LIMIT 1]);
                        if(guestUserList.size() == 0)
                        {
                            saveClicked=refresh;
                        }
                        else
                        {
                            updateAcc.OwnerId = guestUserList[0].Id;
                        }
                    }
                    */
                    if (updateAcc != null && updateAcc.Id != null) {
                        SFDCAccessController accessAcc = ExAMUtilClass.AccessController;
                        List<string> fieldsListAcc = new List<string>{'ExAM__AssessmentURLMobile__c', 'ExAM__AssessmentURL__c'};
                        accessAcc.assertAuthorizedToUpdate(Schema.getGlobalDescribe().get('Account'), fieldsListAcc);
                        update updateAcc;
                    }
                }
            }
            if(saveClicked!=null)
            {          
                saveClicked.setRedirect(true);
                return saveClicked;
            }
            else
            {
                return refresh;
            }
        }
        catch(Exception e){
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()) );
        }  
        return null;
    } 
    
        
    public PageReference cancel()
    {
        return refresh;
    }
        
    public PageReference Home() {
        PageReference cancelClicked=new PageReference('/home/home.jsp');
        cancelClicked.setRedirect(true);
        return cancelClicked; 
    }

    public static testMethod void CreateAssessment_Test()
    {
        //Test converage for the visualforce page
        PageReference pageRef = Page.CreateAssessment;
        Test.setCurrentPageReference(pageRef);
        Test.startTest();
        Main_questionaire__c maintest=new Main_questionaire__c (Template_name__c ='test',PublishPlace__c='Internal to salesforce');
        upsert maintest;
        Main_questionaire__c maintest1=new Main_questionaire__c (Template_name__c ='test2',PublishPlace__c='External Site');
        upsert maintest1;
        Account acc=new Account(name='test acc',Create_Survey__c=true);
        acc.Main_Questionnaire_Template__c=maintest.id;
        insert acc;
        Account acc2=new Account(name='test acc2',Create_Survey__c=true);
        acc2.Main_Questionnaire_Template__c=maintest1.id;
        insert acc2;   
        CreateAssessmentController  d = new CreateAssessmentController();
        d.save();
        system.assertEquals(d.acc.Id, null);
        d.acc.Name = 'Test Account 1';
        d.acc.Main_Questionnaire_Template__c = maintest.Id;
        d.save();
        system.assertNotEquals(d.acc.Id, null);
        d.acc.Name = 'Test Account 2';
        d.acc.Main_Questionnaire_Template__c = maintest1.Id;
        d.save();
        system.assertNotEquals(d.acc.Id, null);
        d.mobilesave();
        d.Home();
        d.cancel();
        Test.stopTest();
    }
    public static testMethod void CreateAssessment_Test1()
    {
        //Test converage for the visualforce page
        PageReference pageRef = Page.CreateAssessment;
        Test.setCurrentPageReference(pageRef);
        Test.startTest();
        Main_questionaire__c maintest1=new Main_questionaire__c (Template_name__c ='test2',PublishPlace__c='External Site');
        upsert maintest1;
        Account acc=new Account(name='test acc',Create_Survey__c=true);
        acc.Main_Questionnaire_Template__c=maintest1.id;
        insert acc;
        Account acc2=new Account(name='test acc2',Create_Survey__c=true);
        acc2.Main_Questionnaire_Template__c=maintest1.id;
        insert acc2;   
        CreateAssessmentController  d = new CreateAssessmentController();
        d.save();
        system.assertEquals(d.acc.Id, null);
        d.acc.Name = 'Test Account 1';
        d.acc.Main_Questionnaire_Template__c = maintest1.Id;
        d.save();
        system.assertNotEquals(d.acc.Id, null);
        d.acc.Name = 'Test Account 2';
        d.acc.Main_Questionnaire_Template__c = maintest1.Id;
        d.save();
        system.assertNotEquals(d.acc.Id, null);
        d.mobilesave();
        d.Home();
        d.cancel();
        Test.stopTest();
    }
}