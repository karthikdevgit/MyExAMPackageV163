public with sharing class QuestionnaireFields {

    //this is extension class of Main_questionnaire template
    //TAke questionnaire field FROM section,question,question response,template
    public string message {
        get;
        set;
    }
    //public Id selectedTemplate { get; set; }
    //public Id selectedSection { get; set; }
    public Account acc {
        get;
        set;
    }

    public List <Question_Template__c> questionsLists {
        get;
        set;
    }

    public List <Section_Template__c> sectionsLists {
        get;
        set;
    }

    public List <Main_questionaire__c> templateLists {
        get;
        set;
    }

    public List <SectionStatus__c> sectionsStatusLists {
        get;
        set;
    }

    //public Set<Id> sectionIds{get;set;}

    public string templateName {
        get;
        set;
    }

    public string templateId {
        get;
        set;
    }

    public string sectionId {
        get;
        set;
    }

    public string accountId {
        get;
        set;
    }
    public List <Questionnaire_Response__c> QuestionResponse {
        get;
        set;
    }
    public List <QuestionDisplay> listQuestWithOptions;
    public List <QuestionDisplay> questionsList { get; set; }
    
    public QuestionDisplay[] listQuestWithText;
    //public PageReference refresh=ApexPages.currentPage();
    //Apexpages.currentPage().getHeaders().put('X-UA-Com​patible', 'IE=8');
    public PageReference refresh = new PageReference(ApexPages.currentPage().getUrl());

    public Boolean refreshPagePart {
        get;
        set;
    }

    private Boolean theToggleVal = true;
    static integer ltoggle = 0;
    private Boolean theToggleValApproval = false;
    static integer ltoggleApproval = 0;
    public Transient Boolean doRerender;
    public Transient Boolean doRerenderSave;

    public Boolean getdoRerender() {
        return doRerender;
    }

    public Boolean getdoRerenderSave() {
        return doRerenderSave;
    }
    //added for not doing DMl in constructor
    public Boolean myFlag {
        get;
        set;
    }

    public string issueId {
        get;
        set;
    }

    public void setmyFlag(Boolean flags) {
        this.myFlag = flags;
    }

    public void setdoRerender(Boolean doRerender) {
        this.doRerender = doRerender;
        System.debug('doRerender should be set here to true: doRerender = ' + this.doRerender);
    }

    public void setdoRerenderSave(Boolean doRerenderSave) {
        this.doRerenderSave = doRerenderSave;
        System.debug('doRerender should be set here to true: doRerender = ' + this.doRerenderSave);
    }

    public Boolean ParamToggle {
        get;
        set;
    }

    public void DoToggle() {
        theToggleVal = ParamToggle;
    }

    public Boolean ShouldDisplay {
        get {
            System.Debug(theToggleVal);
            return theToggleVal;
        }
    }

    public Boolean ShouldDisplayApproval {
        get {
            System.Debug(theToggleValApproval);
            return theToggleValApproval;
        }
    }

    public QuestionnaireFields(ApexPages.StandardSetController controller) {
        refreshPagePart = false; //sectionStatus();
        questionsList = new List<QuestionDisplay>();
        currentSectionQuestions();
    }

    public QuestionnaireFields() {}

    public void sectionStatus() {

        try {
            myFlag = false;
            theToggleVal = false;
            theToggleValApproval = false; //System.debug('----------initialized in sectionstatus'+initialized);
            if (!myFlag) {
                SectionStatus__c[] StatusLists = new SectionStatus__c[] {}; //setinitialised(true); 
                accountId = System.currentPageReference().getParameters().get('accId'); //to get the school or account id
                accountId = accountId != '' ? accountId : null;
                issueId = System.currentPageReference().getParameters().get('issueid');
                templateName = System.currentPageReference().getParameters().get('templatename');
                //acc= [SELECT id,name,Main_Questionnaire_Template__c,Main_Questionnaire_Template__r.Template_name__c,Adequate_Lighting_Score__c,Adequate_Locking_Score__c,CCTV_Score__c,Emergency_Response_Plan__c,Mail_Handling_Score__c,Overall_Score__c,Perimeter_Score__c,Create_Survey__c FROM Account WHERE Create_Survey__c=:true AND id=:accountId];
                //Account or facility doesnt have template name on it, it is on the issue/request object
                //acc= [SELECT id,name FROM Account WHERE id=:accountId];

                System.debug('!!!!!!!!!!!!!!!!~~~~~~~~~~~~status ~acct id FROM diff page :' + accountid);

                SFDCAccessController accessAT = ExAMUtilClass.AccessController;
                List<string> fieldsListAT = new List<string>{'ExAM__Template_name__c'};
                accessAT.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Main_questionaire__c'), fieldsListAT);

                //templateLists = [SELECT Id, Name,Template_name__c FROM Main_questionaire__c WHERE Template_name__c=:acc.Main_Questionnaire_Template__r.Template_name__c];
                templateLists = [SELECT Id, Name, Template_name__c FROM Main_questionaire__c WHERE Template_name__c = : templateName];
                if (templateLists != NULL && templateLists.size() >= 1) {
                    templateName = templateLists.get(0).Template_name__c;

                    SFDCAccessController accessST = ExAMUtilClass.AccessController;
                    List<string> fieldsListST = new List<string>{'ExAM__Order_No__c', 'ExAM__Questionnaire_Section__c', 'ExAM__Section_label__c', 'ExAM__status__c'};
                    accessST.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Section_Template__c'), fieldsListST);

                    sectionsLists = [SELECT Id, Name, status__c, Section_label__c, Order_No__c FROM Section_Template__c WHERE Questionnaire_Section__c = : templateLists.get(0).Id ORDER BY Order_No__c];
                    //iterate the sectionstatus table and we should remove userinfo check as there will always be 1 survey per account
                    //SectionStatus__c[] userSectionStatus=[SELECT id,Section_Template__c,Section_Template__r.id,Section_Template__r.Section_Label__c,Section_Template__r.Order_No__c,Status__c,Section_Template__r.Questionnaire_Section__c,User__c,Account_to_SectionStatus__c FROM SectionStatus__c WHERE Account_to_SectionStatus__c= :accountId AND (Section_Template__c!=null) AND (Section_Template__r.Questionnaire_Section__c=:templateLists.get(0).Id) ORDER BY Section_Template__r.Order_No__c] ;

                    SFDCAccessController accessSS = ExAMUtilClass.AccessController;
                    List<string> fieldsListSS = new List<string>{'ExAM__Section_Template__c', 'ExAM__Status__c', 'ExAM__User__c', 'ExAM__Issue_Request__c'};
                    accessSS.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__SectionStatus__c'), fieldsListSS);

                    SectionStatus__c[] userSectionStatus = [SELECT id, Section_Template__c, Section_Template__r.Section_Label__c, Section_Template__r.Order_No__c, Section_Template__r.Questionnaire_Section__c, Status__c, User__c, Issue_Request__c FROM SectionStatus__c WHERE Issue_Request__c = : issueId AND(Section_Template__c != null) AND(Section_Template__r.Questionnaire_Section__c = : templateLists.get(0).Id) ORDER BY Section_Template__r.Order_No__c];

                    System.debug('~~~~~~~~11111~sectionstatus~~~~~~~~~~~~' + userSectionStatus.size());
                    //System.debug('sectionsLists ----'+sectionsLists.size());
                    // System.debug('~~~~~~~~~~~~~size both at top'+userSectionStatus.size()+',,,sec'+sectionsLists.size());

                    if ((userSectionStatus == null) || (userSectionStatus.size() == 0)) {
                        System.debug('~~~~~~~~~~~~~COMES IN SECTION STATUS');
                        for (Section_Template__c res: sectionsLists) {

                            SectionStatus__c stat = new SectionStatus__c();
                            stat.User__c = UserInfo.getUserId();
                            stat.Issue_Request__c = issueId;
                            stat.Section_Template__c = res.id;
                            stat.status__c = 'Incomplete';
                            stat.Account_to_SectionStatus__c = accountId != '' ? accountId : null;
                            //stat.Section_StatusLabel__c=res.Section_Label__c;  
                            System.debug('~~~~~~~~~~~~~default controller------' + stat);
                            StatusLists.add(stat);
                        }

                        SFDCAccessController accessSSCreate = ExAMUtilClass.AccessController;
                        List<string> fieldsListSSCreate = new List<string>{'ExAM__Account_to_SectionStatus__c', 'ExAM__Section_Template__c', 'ExAM__Status__c', 'ExAM__User__c', 'ExAM__Issue_Request__c'};
                        accessSSCreate.assertAuthorizedToCreate(Schema.getGlobalDescribe().get('exam__SectionStatus__c'), fieldsListSSCreate);

                        upsert StatusLists;
                        //sectionsStatusLists=[SELECT id,Section_Template__c,Section_Template__r.id,Section_Template__r.Section_Label__c,Section_Template__r.Order_No__c,Account_to_SectionStatus__c,Section_Template__r.Questionnaire_Section__c,Status__c,User__c FROM SectionStatus__c WHERE Account_to_SectionStatus__c= :accountId AND (Section_Template__c!=null) AND (Section_Template__r.Questionnaire_Section__c=:templateLists.get(0).Id) ORDER BY Section_Template__r.Order_No__c] ;
                        sectionsStatusLists = [SELECT id, Section_Template__c, Section_Template__r.Section_Label__c, Section_Template__r.Order_No__c, Section_Template__r.Questionnaire_Section__c, Issue_Request__c, Status__c, User__c FROM SectionStatus__c WHERE Issue_Request__c = : issueId AND(Section_Template__c != null) AND(Section_Template__r.Questionnaire_Section__c = : templateLists.get(0).Id) ORDER BY Section_Template__r.Order_No__c];

                    } else if (userSectionStatus.size() < sectionsLists.size()) {
                        integer i = 0;
                        System.debug('~~~~~~~~~~~~~add new status default' + userSectionStatus.size() + userSectionStatus + ',,,sec' + sectionsLists.size() + sectionsLists);
                        for (Section_Template__c res: sectionsLists) {
                            for (SectionStatus__c statusobj: userSectionStatus) {
                                if (res.id == statusobj.Section_Template__c) {
                                    i = 1;
                                    System.debug('~~both are equal~~~~~~~~~' + res.id + 'status' + statusobj.Section_Template__c);
                                    break;
                                }
                            }

                            if (i == 0) {
                                /*SectionStatus__c stat=new SectionStatus__c();
                                            stat.User__c=UserInfo.getUserId();
                                            stat.Section_Template__c= res.id;
                                            stat.Account_to_SectionStatus__c=accountId; 
                                            stat.status__c='Incomplete';
                                            StatusLists.add(stat);*/
                                //create new section status
                                SectionStatus__c newstat = new SectionStatus__c();
                                newstat.User__c = UserInfo.getUserId();
                                newstat.Issue_Request__c = issueId;
                                newstat.Section_Template__c = res.id;
                                newstat.status__c = 'Incomplete';
                                newstat.Account_to_SectionStatus__c = accountId != '' ? accountId : null;
                                //stat.Section_StatusLabel__c=res.Section_Label__c;  
                                System.debug('~~~~~~~~~~~~~default controller------' + newstat);
                                StatusLists.add(newstat);
                            }
                            i = 0;

                        }
                        SFDCAccessController accessSSCreate = ExAMUtilClass.AccessController;
                        List<string> fieldsListSSCreate = new List<string>{'ExAM__Account_to_SectionStatus__c', 'ExAM__Section_Template__c', 'ExAM__Status__c', 'ExAM__User__c', 'ExAM__Issue_Request__c'};
                        accessSSCreate.assertAuthorizedToCreate(Schema.getGlobalDescribe().get('exam__SectionStatus__c'), fieldsListSSCreate);

                        upsert StatusLists;

                        //sectionsStatusLists=[SELECT id,Section_Template__c,Section_Template__r.id,Section_Template__r.Section_Label__c,Section_Template__r.Order_No__c,Account_to_SectionStatus__c,Status__c,User__c,Section_Template__r.Questionnaire_Section__c FROM SectionStatus__c WHERE Account_to_SectionStatus__c= :accountId AND (Section_Template__c!=null) AND (Section_Template__r.Questionnaire_Section__c=:templateLists.get(0).Id) ORDER BY Section_Template__r.Order_No__c] ;
                        sectionsStatusLists = [SELECT id, Section_Template__c, Section_Template__r.Section_Label__c, Section_Template__r.Questionnaire_Section__c, Section_Template__r.Order_No__c, Issue_Request__c, Status__c, User__c FROM SectionStatus__c WHERE Issue_Request__c = : issueId AND(Section_Template__c != null) AND(Section_Template__r.Questionnaire_Section__c = : templateLists.get(0).Id) ORDER BY Section_Template__r.Order_No__c];

                    } else if (userSectionStatus.size() > sectionsLists.size()) { //extra section status
                        integer i = 0;
                        List < SectionStatus__c > deleteSectionStatus = new List < SectionStatus__c > ();
                        for (SectionStatus__c statusobj: userSectionStatus) {
                            for (Section_Template__c res: sectionsLists) {
                                if (res.id == statusobj.Section_Template__c) {
                                    i = 1;
                                    break;
                                }
                            }
                            if (i == 0) {

                                //stat.Section_StatusLabel__c=res.Section_Label__c;  
                                //System.debug('~~~~~~~~~~~~~default controller------'+statusobj);
                                deleteSectionStatus.add(statusobj);
                            }
                            i = 0;

                        }
                        //while(SectionStatus__c statusobj: deleteSectionStatus)
                        integer l = 0;
                        if (deleteSectionStatus != null && deleteSectionStatus.size() > 0) {
                            SFDCAccessController accessForobj = ExAMUtilClass.AccessController;
                            if(accessForobj.isAuthorizedToDelete(Schema.getGlobalDescribe().get('exam__SectionStatus__c'))){
                                delete deleteSectionStatus;
                            }
                        }
                        //sectionsStatusLists=[SELECT id,Section_Template__c,Section_Template__r.id,Section_Template__r.Section_Label__c,Section_Template__r.Order_No__c,Account_to_SectionStatus__c,Status__c,User__c,Section_Template__r.Questionnaire_Section__c FROM SectionStatus__c WHERE Account_to_SectionStatus__c= :accountId AND (Section_Template__c!=null) AND (Section_Template__r.Questionnaire_Section__c=:templateLists.get(0).Id) ORDER BY Section_Template__r.Order_No__c] ;
                        sectionsStatusLists = [SELECT id, Section_Template__c, Section_Template__r.Section_Label__c, Section_Template__r.Questionnaire_Section__c, Section_Template__r.Order_No__c, Issue_Request__c, Status__c, User__c FROM SectionStatus__c WHERE Issue_Request__c = : issueId AND(Section_Template__c != null) AND(Section_Template__r.Questionnaire_Section__c = : templateLists.get(0).Id) ORDER BY Section_Template__r.Order_No__c];

                    } else { //sectionlist exists so no need for grabbing again
                        // sectionsStatusLists=[SELECT id,Section_Template__c,Section_Template__r.id,Section_Template__r.Section_Label__c,Status__c,User__c FROM SectionStatus__c WHERE User__c= :UserInfo.getUserId()] ;
                        //sectionsStatusLists=[SELECT id,Section_Template__c,Section_Template__r.id,Section_Template__r.Section_Label__c,Section_Template__r.Order_No__c,stat.Account_to_SectionStatus__c,Status__c,User__c FROM SectionStatus__c WHERE User__c= :UserInfo.getUserId() AND (Section_Template__c!=null) ORDER BY Section_Template__r.Order_No__c] ;
                        sectionsStatusLists = userSectionStatus;
                    }
                    System.debug('~~~~~~~222  section sttus~~~~~~final section list SECTION STATUS LIST----' + sectionsStatusLists);

                    // To set the focus category scores for the account
                    /*
                    List<aggregateResult> aggr=[
                        SELECT Account__c, Question_Template__r.Focus_category__c focus, SUM(Questionnaire_Response__r.Total_Score__c)total
                        FROM   Main_Report_Data__c WHERE Account__c=:accountId
                               GROUP BY  Account__c,Question_Template__r.Focus_category__c 
                    ];
                    if(acc!=null)
                    {
                        acc.Overall_Score__c=0;
                        integer b=0;
                        for(SectionStatus__c res: sectionsStatusLists) 
                        {
                            if(res.status__c.equalsIgnoreCase('complete'))
                            {
                                b++;System.debug('!!!!!!!!!!!!!!!!!!b='+b+','+ res.status__c);
                            }
                        }
                        if(b==sectionsLists.size())
                        {
                            System.debug('!!!!!!!!!!!!!!!!!!b val:'+b);
                            acc.Survey_Completed__c='Complete';}
                            for (AggregateResult ar : aggr)
                            {

                                string focuscat=String.valueOf(ar.get('focus')); 
                                System.debug('account id:'+acc.id+'focus category:'+focuscat);
                                acc.Overall_Score__c+=Integer.valueOf(ar.get('total'));
                                if(focuscat.equalsIgnoreCase('CCTV'))
                                {
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
                            }
                        }    
                        System.debug('~~~~~~~~~~~~~~~~~~~~~~~ main report data'+acc);
                        try{
                            if((acc.Overall_Score__c>0))
                            {
                                upsert acc;
                            }
                        }
                        catch(Exception e){}
                        */
                    }
                    myFlag = true;
                } //if acc!=null
        }
        catch(Exception ex) {
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()) );
        }
    }

    public PageReference save() {
        System.debug('IN MAIN SAVE METHOD ' + accountId);
        try {
            if ((this.doRerenderSave != null) || (this.doRerenderSave != false)) {
                SectionStatus__c[] userSectionStatus = new SectionStatus__c[] {};
                /*
                if(sectionsStatusLists!=null)
                {
                    userSectionStatus=sectionsStatusLists;
                }
                else
                {
                */

                SFDCAccessController accessSS = ExAMUtilClass.AccessController;
                List<string> fieldsListSS = new List<string>{'ExAM__Section_Template__c', 'ExAM__Status__c', 'ExAM__User__c', 'ExAM__Issue_Request__c'};
                accessSS.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__SectionStatus__c'), fieldsListSS);

                //userSectionStatus=[SELECT id,Section_Template__c,Status__c,Account_to_SectionStatus__c,User__c FROM SectionStatus__c WHERE Account_to_SectionStatus__c= :accountId AND Section_Template__c =:listQuestWithOptions[0].newquestFormat.Section_Question__r.id] ;
                userSectionStatus = [SELECT id, Section_Template__c, Status__c, Issue_Request__c, User__c FROM SectionStatus__c WHERE Issue_Request__c = : issueId AND Section_Template__c = : listQuestWithOptions[0].newquestFormat.Section_Question__r.id];
                // } 
                System.debug('IN MAIN SAVE METHOD section status~~~~~~~~~~~~~' + userSectionStatus);
                if ((userSectionStatus == null) || (userSectionStatus.size() == 0)) {

                    SectionStatus__c stat = new SectionStatus__c();
                    stat.User__c = UserInfo.getUserId();
                    stat.Account_to_SectionStatus__c = accountId != '' ? accountId : null;
                    stat.Issue_Request__c = issueId;
                    stat.Section_Template__c = listQuestWithOptions[0].newquestFormat.Section_Question__r.id;
                    stat.status__c = 'Complete';
                    System.debug('~~~~~~~~~~~~~in save section NEW status------' + stat);

                    SFDCAccessController accessSSCreate = ExAMUtilClass.AccessController;
                    List<string> fieldsListSSCreate = new List<string>{'ExAM__Account_to_SectionStatus__c', 'ExAM__Section_Template__c', 'ExAM__Status__c', 'ExAM__User__c', 'ExAM__Issue_Request__c'};
                    accessSSCreate.assertAuthorizedToCreate(Schema.getGlobalDescribe().get('exam__SectionStatus__c'), fieldsListSSCreate);

                    upsert stat;

                } else {
                    System.debug('else in~EDIT~~~~~~~~~~~~' + userSectionStatus);
                    //System.debug('~~~~~~~~~~~~~Record already exists put code for edit');
                    userSectionStatus[0].Status__c = 'Complete';

                    SFDCAccessController accessSSUpdate = ExAMUtilClass.AccessController;
                    List<string> fieldsListSSUpdate = new List<string>{'ExAM__Status__c'};
                    accessSSUpdate.assertAuthorizedToUpdate(Schema.getGlobalDescribe().get('exam__SectionStatus__c'), fieldsListSSUpdate);

                    upsert userSectionStatus;

                }
                map < string, string > formparams = ApexPages.currentPage().getParameters();
                map < string, string > formsubparams = new map < string, string > ();
                for (string keyName: formparams.keySet()) {
                    if (keyName.contains('row')) {
                        formsubparams.put(keyName, formparams.get(keyName));
                        System.debug('~~~~~~~~~~in ' + keyName + ': ' + formparams.get(keyName));
                    } else {
                        System.debug('~~~~~~~~~~in ' + keyName + ': ' + formparams.get(keyName));
                    }
                }
                //System.debug('---------------- : in SavelistQuestWithOptions : ' + listQuestWithOptions);
                //System.debug('~~~~---------------- : in Save : ' + listQuestWithOptions[0]);    
                // System.debug('~~~~~~~~~~in save account id:'+accountId); 
                SFDCAccessController accessAnswer = ExAMUtilClass.AccessController;

                List<string> fieldsListANSST = new List<string>{'ExAM__Section_Question__c'};
                accessAnswer.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Question_Template__c'), fieldsListANSST);

                List<String> fieldsListAnswer = new List<String>{'ExAM__Account_to_Response__c', 'ExAM__Questionnaire_Taker_user__c', 'ExAM__Question_Template__c', 'ExAM__Response__c'};
                accessAnswer.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Questionnaire_Response__c'), fieldsListAnswer);

                SFDCAccessController accessAnswerSave = ExAMUtilClass.AccessController;
                List<String> fieldsListAnswerCreate = new List<String>{'ExAM__Account_to_Response__c', 'ExAM__Questionnaire_Taker_user__c', 'ExAM__Question_Template__c', 'ExAM__Response__c', 'ExAM__Weight_Response__c'};
                accessAnswerSave.assertAuthorizedToCreate(Schema.getGlobalDescribe().get('exam__Questionnaire_Response__c'), fieldsListAnswerCreate);
                List<String> fieldsListAnswerUpdate = new List<String>{'ExAM__Account_to_Response__c', 'ExAM__Questionnaire_Taker_user__c', 'ExAM__Response__c', 'ExAM__Weight_Response__c'};
                accessAnswerSave.assertAuthorizedToUpdate(Schema.getGlobalDescribe().get('exam__Questionnaire_Response__c'), fieldsListAnswerUpdate);

                QuestionDisplay l = new QuestionDisplay();
                //l.innerSave(listQuestWithOptions,accountId);   
                l.innerSave(listQuestWithOptions, accountId, issueId, formsubparams);
                /*
                for(QuestionDisplay t: listQuestWithOptions)
                {
                    //   System.debug('~~~~---------------- : in Save : ' +t);               
                    //  System.debug('~~~~---------------- : in Save response object FROM UI'+  t.resObj.Response__c); 
                    t.innerSave(accountId,t.resObj,t.multiSELECTlist);
                }
                */
                System.debug(' ----------------Record saved successfully : ');
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO, 'Record saved successfully');
                ApexPages.addMessage(myMsg);
                refreshPagePart = true;
                theToggleValApproval = true; //myFlag=true; 
            } //if dorender is not null         
            // refresh.setRedirect(true);
            // return refresh;
            String urlform = '';
            if (accountId != null && accountId != '') {
                urlform = '/apex/QuestionnaireCustom?accid=' + accountId + '&issueid=' + issueId + '&templatename=' + templateName;
            } else {
                urlform = '/apex/QuestionnaireCustom?issueid=' + issueId + '&templatename=' + templateName;
            }
            PageReference saveClicked = new PageReference(urlform);
            saveClicked.setRedirect(true);
            //return refresh;
            templateName = System.currentPageReference().getParameters().get('templatename');

            SFDCAccessController accessAT = ExAMUtilClass.AccessController;
            List<string> fieldsListAT = new List<string>{'ExAM__Template_name__c'};
            accessAT.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Main_questionaire__c'), fieldsListAT);

            templateLists = [SELECT Id, Name, Template_name__c FROM Main_questionaire__c WHERE Template_name__c = : templateName];
            sectionsStatusLists = [SELECT id, Section_Template__c, Section_Template__r.Section_Label__c, Section_Template__r.Questionnaire_Section__c, Section_Template__r.Order_No__c, Issue_Request__c, Status__c, User__c FROM SectionStatus__c WHERE Issue_Request__c = : issueId AND(Section_Template__c != null) AND(Section_Template__r.Questionnaire_Section__c = : templateLists.get(0).Id) ORDER BY Section_Template__r.Order_No__c];
            currentSectionQuestions();
            if(System.currentPageReference().getParameters().get('saveType') == 'menu'){
                return null;
            }else {
                return saveClicked;
            }
        } catch (Exception e) {
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()) );
        }
        return null;
    }

    /*
    public PageReference submitForApproval()
    {
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setComments('Submitting request for approval.');
        System.debug(' SUMIT FOR APPROVAl-----------');
        accountId=System.currentPageReference().getParameters().get('accId');//to get the school or account id     
        req1.setObjectId(accountId);
        System.debug(' SUMIT FOR APPROVAl-----------'+accountId);
        ID elect = [SELECT id FROM user WHERE username='ilsa.lund@mbaoutcome.com' limit 1].id;
        req1.setNextApproverIds(new Id[] {elect});
        Approval.ProcessResult result = Approval.process(req1); 
        System.debug(' SUMIT FOR APPROVAl----result -------'+result );
        System.assert(result.isSuccess());  
        PageReference cancelClicked=new PageReference('http://EXAM4SCHOOLS.COM/');
        cancelClicked.setRedirect(false);
        return cancelClicked;         
    }
    */

    public PageReference submitForApproval() {
        System.debug('~~~~~INSIDE SUBMITurl' + issueId);
        try {
            PageReference saveAnswer = save();
            issueId = System.currentPageReference().getParameters().get('issueid');
            System.debug('22222~~~~~INSIDE SUBMITurl' + issueId);

            SFDCAccessController accessAM = ExAMUtilClass.AccessController;
            List<string> fieldsListAM = new List<string>{'ExAM__Assessor_Resource__c', 'ExAM__Assessment_Form_Completion__c', 'ExAM__Date_Completed__c', 'ExAM__Status__c'};
            accessAM.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__IssueRequest_Life_Cycle__c'), fieldsListAM);

            List <IssueRequest_Life_Cycle__c> issuerecord = [
                SELECT id, Assessor_Resource__c, Assessment_Form_Completion__c, Date_Completed__c, 
                       Status__c //, InvestigationType__c, InvestigationType__r.Override_URL__c,
                       //InvestigationType__r.Quiz_Completed_URL_Page__c
                FROM   IssueRequest_Life_Cycle__c WHERE id = : issueId
            ];
            if (issuerecord != null && issuerecord.size() > 0) {
                issuerecord[0].Assessment_Form_Completion__c = 'Complete';
                System.debug('=====urlissuerecord' + issuerecord);
                //issuerecord.Status__c ='Closed';
                issuerecord[0].Status__c = 'Completed';

                SFDCAccessController accessAMUpdate = ExAMUtilClass.AccessController;
                List<string> fieldsListAMUpdate = new List<string>{'ExAM__Assessment_Form_Completion__c', 'ExAM__Status__c'};
                accessAMUpdate.assertAuthorizedToUpdate(Schema.getGlobalDescribe().get('exam__IssueRequest_Life_Cycle__c'), fieldsListAMUpdate);

                upsert issuerecord;
                /*
                if (issuerecord[0].InvestigationType__r.Override_URL__c == true && issuerecord[0].InvestigationType__r.Quiz_Completed_URL_Page__c != null) {

                    PageReference pref1 = new PageReference(issuerecord[0].InvestigationType__r.Quiz_Completed_URL_Page__c + '?issueid=' + issuerecord[0].Id);
                    pref1.setRedirect(true);
                    return pref1;
                }
                */
            }
            /*
                Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
                req1.setComments('Submitting request for approval.');
                System.debug(' SUMIT FOR APPROVAl-----------');
                accountId=System.currentPageReference().getParameters().get('accid');//to get the school or account id     
                req1.setObjectId(accountId);
                System.debug(' SUMIT FOR APPROVAl-----------'+accountId);
                Id syadmin=[SELECT id FROM profile WHERE name='System Administrator'].id;
                if(syadmin!=null)
                {
                    ID elect = [SELECT id,ProfileId FROM user WHERE ProfileId=:syadmin].id;
                    req1.setNextApproverIds(new Id[] {elect});
                    Approval.ProcessResult result = Approval.process(req1); 
                    System.debug(' SUMIT FOR APPROVAl----result -------'+result );
                    System.assert(result.isSuccess());  
                }
            */
            string hostVal = ApexPages.currentPage().getHeaders().get('Host');
            string urlVal = Apexpages.currentPage().getUrl();
            string URLL = 'https://' + hostVal + urlVal;
            string urls = '/' + issueId;
            System.debug('=====url ' + urls);
            PageReference cancelClicked = new PageReference(urls);
            //System.debug('=====url page ref'+cancelClicked);
            cancelClicked.setRedirect(true);
            return cancelClicked;
        } catch (Exception e) {
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()) );
        }
        return null;
    }

    public PageReference cancel() {
        string urlform = '';
        if (accountId != null && accountId != '') {
            urlform = '/apex/QuestionnaireCustom?accid=' + accountId + '&issueid=' + issueId + '&templatename=' + templateName;
        } else {
            urlform = '/apex/QuestionnaireCustom?issueid=' + issueId + '&templatename=' + templateName;
        }
        PageReference saveClicked = new PageReference(urlform);
        saveClicked.setRedirect(true);
        return saveClicked;
    }

    public PageReference exit() {
        PageReference cancelClicked = new PageReference('/home/home.jsp');
        cancelClicked.setRedirect(true);
        return cancelClicked;
    }

    //create a new inner class so that we can add the flags for each record and display/create the questions as checklist/text/piclist etc.
    public class QuestionDisplay {
        //each record is sent to the visualforce frontend page iteratively through class vaiable.        
        //SELECT  Id,Question_Label__c,Question_Order_No__c,Question_Type__c,Subquestion_Label__c FROM Question_Template__c WHERE Section_Question__r.id=:id ORDER BY Question_Order_No__c];         
        public Question_Template__c newquestFormat {
            get;
            set;
        }
        public Questionnaire_Response__c resObj {
            get;
            set;
        }
        public string questionFlag {
            get;
            set;
        } //default
        public List < SELECTOption > optionsList {
            get;
            set;
        }
        public string sectionLabel {
            get;
            set;
        }
        public string[] multiSELECTlist {
            get;
            set;
        }
        public string acctId {
            get;
            set;
        }
        public string issueId {
            get;
            set;
        }

        public QuestionDisplay(Question_Template__c question, List < SELECTOption > subQuestionOption, Questionnaire_Response__c responseObj, string[] multi) {
            newquestFormat = new Question_Template__c();
            optionsList = new List < SELECTOption > ();
            resObj = new Questionnaire_Response__c();
            this.newquestFormat = question;
            this.resObj = responseObj;
            //this.sectionLabel=sectionLabels;
            this.optionsList = subQuestionOption;
            this.multiSELECTlist = multi;


        }
        public QuestionDisplay(Question_Template__c question) {
            this.newquestFormat = question;
        }
        public QuestionDisplay() {

        }

        public Note[] createNotes(Questionnaire_Response__c[] responseLists, map < string, string > formsubparams) {
            Note[] attachnotes = new Note[] {};
            for (Questionnaire_Response__c r: responseLists) {
                for (string keyName: formsubparams.keySet()) {

                    if ((keyName.startsWith(r.Question_Template__c)) && (keyName.contains('row'))) {
                        System.debug('-------NOTES IFformsubparams.get(keyName):' + formsubparams.get(keyName));
                        if ((formsubparams.get(keyName) != null) && (formsubparams.get(keyName) != '')) {
                            note n = new note();
                            n.parentId = r.id;
                            n.body = formsubparams.get(keyName); // body of the note. this should be populated FROM the notes field that you have shown in the screenshot
                            if ((n.body.startsWith('Recommendation')) || (n.body.startsWith('recommendation'))) {
                                n.title = 'Recommendation' + System.now(); // the title of the note
                            } else {
                                n.title = 'Comment' + System.now();
                            }
                            n.isPrivate = false; // if private it will be visible only for the owner and any user with modify all permission
                            //insert n;  
                            attachnotes.add(n);
                            System.debug('~~~NOTES~~~~~~~in ' + keyName + ': ' + n.parentId);
                        }
                    }
                }
            }
            return attachnotes;
        }

        /*public void innerSave(List<QuestionDisplay> qdisplist,string accountId,string issueid,map<string, string> formsubparams) {
       
            try {
                //Section_Template__c =:listQuestWithOptions[0].newquestFormat.Section_Question__r.id
                acctId=accountId;  
                Questionnaire_Response__c[] responseLists=new Questionnaire_Response__c[]{}; 
                //Give all responses for this section and account
                Questionnaire_Response__c[] reponseObjects=[SELECT id,Response__c,Question_Template__r.Section_Question__r.id,Question_Template__c,Account_to_Response__c,Questionnaire_Taker_user__c FROM Questionnaire_Response__c WHERE Account_to_Response__c= :accountId AND Question_Template__r.Section_Question__r.id=:qdisplist[0].newquestFormat.Section_Question__r.id]; 
               
                
                  //   System.debug('~~~~---------------- : in Save : ' +t);               
                  //  System.debug('~~~~---------------- : in Save response object FROM UI'+  t.resObj.Response__c); 
                               
                   // t.innerSave(accountId,t.resObj,t.multiSELECTlist);
                             
                //logic to either create a new record or update if it alraedy exists,if question id and user id same than update elase create new
                //Questionnaire_Response__c[] reponseObject=[SELECT id,Response__c,Question_Template__c,Account_to_Response__c,Questionnaire_Taker_user__c FROM Questionnaire_Response__c WHERE Account_to_Response__c= :accountId AND Question_Template__c=:newquestFormat.id]; 
               // System.debug('INNER SAVE,'+robj);
               if((reponseObjects==null)||(reponseObjects.size()==0))
                        {                   
                            
                             for(QuestionDisplay t: qdisplist)
                                {
                                    Questionnaire_Response__c respRecord=new Questionnaire_Response__c(); 
                                    System.debug('create new record');
                                    respRecord.Question_Template__c = t.newquestFormat.id;
                                    respRecord.Questionnaire_Taker_user__c=UserInfo.getUserId();
                                    System.debug('!!!!!!!!!!!~~~~~~~~~~!!!!!!!!!!!new record account'+accountId);
                                    respRecord.Account_to_Response__c=accountId; 
                                    respRecord.Weight_Response__c=1;//put some logic for future
                                    //for multilist
                                     //if its mutiSELECT is not null than put logic to store with tilde sign   
                                     string[] str=t.multiSELECTlist;           
                                     string s='';
                                     if(str!=null)
                                        {
                                            for(integer i = 0; i < str.size(); i++) 
                                            {
                                            s=str[i]+'~'+s;
                                            }
                                             
                                            if(s.endsWithIgnoreCase('~'))
                                            {
                                                s=s.substring(0,s.length()-1);
                                               // s=s.trim();
                                                System.debug('qqqqqqqq SAVING RECORDnewSetStr ============ ' + s);
                                                respRecord.Response__c=s;
                                                
                                                  
                                            }
                                        }
                                        else
                                        {
                                                 System.debug('qqqqqqqq SAVING RECORDnewSetStr ============ ' +t.resObj.Response__c);
                                                 respRecord.Response__c=t.resObj.Response__c;
                                                // System.debug('qqqqqqqq SAVING RECORD BELOW ============ ' +respRecord.Response__c);
                                              
                                        }
                                    responseLists.add(respRecord); System.debug('!!!'+respRecord);
                                  }//end for loop  
                                  System.debug('-------ALL RECORD TO BE UPSERTED!!!'+responseLists);
                                   if(responseLists.size()>0)
                                   {System.debug('-------ALL RECORD TO BE UPSERTEDresponseLists.size()>0!!!'+responseLists);
                                   upsert responseLists;
                                }
                       }
                       else
                       {
                       //all objects exists so edit only
                        for(QuestionDisplay t: qdisplist)
                                {
                                    for(Questionnaire_Response__c res: reponseObjects) 
                                    {
                                        if(t.newquestFormat.id==res.Question_Template__c)
                                        {
                                            //for multilist
                                             //if its mutiSELECT is not null than put logic to store with tilde sign   
                                             string[] str=t.multiSELECTlist;           
                                             string s='';
                                             if(str!=null)
                                                {
                                                    for(integer i = 0; i < str.size(); i++) 
                                                    {
                                                    s=str[i]+'~'+s;
                                                    }
                                                     
                                                    if(s.endsWithIgnoreCase('~'))
                                                    {
                                                        s=s.substring(0,s.length()-1);
                                                        System.debug(' newSetStr ============ ' + s);
                                                        res.Response__c=s;
                                                        
                                                          
                                                    }
                                                }
                                             else
                                                 {
                                                   res.Response__c=t.resObj.Response__c;
                                                 }
                                            
                                            
                                            responseLists.add(res);
                                            break;
                                        }
                                    }//for(Questionnaire_Response__c res
                                    
                                    
                                  }//end for loop for(QuestionDisplay t: qdisplist) 
                                  if(responseLists.size()>0)
                                   {
                                   upsert responseLists;
                                   }
                          // upsert responseLists;        
                  
                }//else
            
            } catch(Exception e ) {
                System.debug('----------------Exception in saving the records :  ' + e);
            }
            
        }
        public void innerSave(string accountId,Questionnaire_Response__c robj,string[] str) {
            try {
               
                acctId=accountId;                
                //logic to either create a new record or update if it alraedy exists,if question id and user id same than update elase create new
                Questionnaire_Response__c[] reponseObject=[SELECT id,Response__c,Question_Template__c,Account_to_Response__c,Questionnaire_Taker_user__c FROM Questionnaire_Response__c WHERE Account_to_Response__c= :accountId AND Question_Template__c=:newquestFormat.id]; 
                System.debug('INNER SAVE,'+robj);
                                 
                 string s='';
                 if(str!=null)
                    {
                        for(integer i = 0; i < str.size(); i++) 
                        {
                        s=str[i]+'~'+s;
                        }
                         
                        if(s.endsWithIgnoreCase('~'))
                        {
                            s=s.substring(0,s.length()-1);
                            System.debug(' newSetStr ============ ' + s);
                            resObj.Response__c=s;
                            
                              
                        }
                    }
                if((reponseObject==null)||(reponseObject.size()==0))
                {                   
                    System.debug('create new record');
                    resObj.Question_Template__c = newquestFormat.id;
                    resObj.Questionnaire_Taker_user__c=UserInfo.getUserId();
                    System.debug('!!!!!!!!!!!~~~~~~~~~~!!!!!!!!!!!new record account'+accountId);
                    resObj.Account_to_Response__c=accountId; 
                    resObj.Weight_Response__c=1;//put some logic for future
                    upsert resObj;
                }
                else
                {
                   
                        if(str!=null)
                        {
                           reponseObject[0].Response__c=s;
                           System.debug('******** str:'+s);
                           
                        }
                        else
                        {
                            reponseObject[0].Response__c=resObj.Response__c;
                            
                           
                        }
                        System.debug('~~~~~~~~~~~~~~~~~~reponseObject[0]:-- '+reponseObject[0]);
                        upsert reponseObject;
                }
                                
                
            } catch(Exception e ) {
                System.debug('----------------Exception in saving the records :  ' + e);
            }
            
        }*/

        public void innerSave(List < QuestionDisplay > qdisplist, string accountId, string issueid, map < string, string > formsubparams) {
            try {
                //Section_Template__c =:listQuestWithOptions[0].newquestFormat.Section_Question__r.id
                acctId = accountId != '' ? accountId : null;
                issueId = issueid;
                Questionnaire_Response__c[] responseLists = new Questionnaire_Response__c[] {};
                //Give all responses for this section and account
                Questionnaire_Response__c[] reponseObjects = new Questionnaire_Response__c[] {};
                if (acctId != null && acctId != '') {
                    reponseObjects = [SELECT id, Response__c, Question_Template__r.Section_Question__r.id, Question_Template__r.Weight_of_Answer__c, Question_Template__c, Account_to_Response__c, Issue_Request__c, Weight_Response__c, Questionnaire_Taker_user__c, (SELECT Id, Title, body, CreatedDate, Owner.FirstName, Owner.LastName FROM Notes ORDER BY CreatedDate) FROM Questionnaire_Response__c WHERE Issue_Request__c = : issueId AND Account_to_Response__c = : acctId AND Question_Template__r.Section_Question__r.id = : qdisplist[0].newquestFormat.Section_Question__r.id];
                } else {
                    reponseObjects = [SELECT id, Response__c, Question_Template__r.Section_Question__r.id, Question_Template__r.Weight_of_Answer__c, Question_Template__c, Account_to_Response__c, Issue_Request__c, Weight_Response__c, Questionnaire_Taker_user__c, (SELECT Id, Title, body, CreatedDate, Owner.FirstName, Owner.LastName FROM Notes ORDER BY CreatedDate) FROM Questionnaire_Response__c WHERE Issue_Request__c = : issueId AND Question_Template__r.Section_Question__r.id = : qdisplist[0].newquestFormat.Section_Question__r.id];
                }

                //TO get both notes and attachments--- List<CombinedAttachMent> n=oo.CombinedAttachments;
                Note[] attachnotes = new Note[] {};
                //List<Note> reponsenotes=reponseObjects.Note;
                //   System.debug('~~~~---------------- : in Save : ' +t);               
                //  System.debug('~~~~---------------- : in Save response object FROM UI'+  t.resObj.Response__c); 

                // t.innerSave(accountId,t.resObj,t.multiSELECTlist);

                //logic to either create a new record or update if it alraedy exists,if question id and user id same than update elase create new
                //Questionnaire_Response__c[] reponseObject=[SELECT id,Response__c,Question_Template__c,Account_to_Response__c,Questionnaire_Taker_user__c FROM Questionnaire_Response__c WHERE Account_to_Response__c= :accountId AND Question_Template__c=:newquestFormat.id]; 
                // System.debug('INNER SAVE,'+robj);
                if ((reponseObjects == null) || (reponseObjects.size() == 0)) {
                    /*for(Questionnaire_Response__c res: reponseObjects) 
                                {
                                    if(quest.id==res.Question_Template__c)
                                    {
                                        resp=res;break;
                                    }
                                }*/
                    for (QuestionDisplay t: qdisplist) {
                        Questionnaire_Response__c respRecord = new Questionnaire_Response__c();
                        System.debug('create new record');
                        respRecord.Question_Template__c = t.newquestFormat.id;
                        respRecord.Questionnaire_Taker_user__c = UserInfo.getUserId();
                        //System.debug('!!!!!!!!!!!~~~~~~~~~~!!!!!!!!!!!new record account'+accountId);
                        respRecord.Account_to_Response__c = accountId != '' ? accountId : null;
                        respRecord.Issue_Request__c = issueId;
                        //For taking the weights FROM the question table and assigning the appropriate one to response field of weight
                        List < string > qoptionvalue = new List < string > {};
                        List < string > wtoptionvalue = new List < string > {};
                        
                        if ( t.newquestFormat.Answer_Options__r.size() == 0 ){
                            string qoption=t.newquestFormat.Subquestion_Label__c;
                            if(qoption!=null){qoptionvalue=qoption.split('~');}
                            string wtoption=t.newquestFormat.Weight_of_Answer__c;
                            if(wtoption!=null){wtoptionvalue=wtoption.split('~');}                  
                        } else {
                            for( Answer_Option__c ansOpt :t.newquestFormat.Answer_Options__r ){
                                if ( ansOpt != null ){
                                    if ( ansOpt.Name != null && ansOpt.Name !='' ){
                                        qoptionvalue.add(ansOpt.Name);
                                    }
                                    if ( ansOpt.Weight__c != null ){    
                                        wtoptionvalue.add(string.valueOf(ansOpt.Weight__c));
                                    }
                                }
                            }
                        }

                        //respRecord.Weight_Response__c=0;//added logic below
                        //for multilist
                        //if its mutiSELECT is not null than put logic to store with tilde sign   
                        string[] str = t.multiSELECTlist;
                        string s = '';

                        double multireswt = 0;
                        if (str != null) {
                            if (t.newquestFormat.Question_Type__c.equalsIgnoreCase('MultiSELECTPicklist')) {
                                respRecord.Weight_Response__c = -1;

                            }
                            for (integer i = 0; i < str.size(); i++) {
                                s = str[i] + '~' + s;
                                //for multiSELECT weight
                                /*if(wtoptionvalue.size()>0)
                                            {
                                            for(integer i1 = 0; i1< qoptionvalue.size(); i1++)
                                                {                                               
                                                    if((str[i]).equalsIgnoreCase(qoptionvalue.get(i1)))
                                                    {
                                                        multireswt+=Double.valueOf(wtoptionvalue.get(i1).trim());  break;
                                                    } 
                                                }
                                            
                                            respRecord.Weight_Response__c=multireswt;
                                            }*/
                            }
                            if (s.endsWithIgnoreCase('~')) {
                                s = s.substring(0, s.length() - 1);
                                // s=s.trim();
                                // System.debug('qqqqqqqq SAVING RECORDnewSetStr ============ ' + s);
                                respRecord.Response__c = s;

                            }
                        } else {
                            //System.debug('qqqqqqqq SAVING RECORDnewSetStr ============ ' +t.resObj.Response__c);
                            respRecord.Response__c = t.resObj.Response__c;
                            // System.debug('qqqqqqqq SAVING RECORD BELOW ============ ' +respRecord.Response__c);
                            //List<string> qoptionvalue=qoption.split('~');
                            //List<string> wtoptionvalue=wtoption.split('~');  
                            if ((respRecord.Response__c != null)) {
                                if (t.newquestFormat.Question_Type__c.equalsIgnoreCase('RadioPicklist') 
                                    || t.newquestFormat.Question_Type__c.equalsIgnoreCase('Dropdown Picklist')) {
                                    for (integer i = 0; i < qoptionvalue.size(); i++) {
                                        if ((respRecord.Response__c).equalsIgnoreCase(qoptionvalue.get(i))) {
                                            if ((respRecord.Response__c).equalsIgnoreCase('N/A') || (respRecord.Response__c).equalsIgnoreCase('NA')) {
                                                respRecord.Weight_Response__c = -1;
                                            } else {
                                                if (wtoptionvalue.size() > 0) {
                                                    respRecord.Weight_Response__c = Double.valueOf(wtoptionvalue.get(i).trim());
                                                    break;
                                                }
                                            }
                                        }
                                    }
                                } else {
                                    respRecord.Weight_Response__c = -1;
                                }
                                /*else if((t.newquestFormat.Question_Type__c.equalsIgnoreCase('Text'))&&(respRecord.Response__c!=''))
                                                    {
                                                        if(t.newquestFormat.Weight_of_Answer__c!=null)
                                                                {
                                                                    respRecord.Weight_Response__c=Double.valueOf(t.newquestFormat.Weight_of_Answer__c.trim());
                                                                }
                                                    }*/
                            }
                        }


                        responseLists.add(respRecord); //System.debug('!!!'+respRecord);
                    } //end for loop  
                    //System.debug('-------ALL RECORD TO BE UPSERTED!!!'+responseLists);
                    if (responseLists.size() > 0) {
                        System.debug('-------ALL RECORD TO BE UPSERTEDresponseLists.size()>0!!!' + responseLists);
                        upsert responseLists;

                        //to call create notes and get existing notes
                        attachnotes = createNotes(responseLists, formsubparams);
                    }
                } else {
                    //all objects exists so edit only
                    for (QuestionDisplay t: qdisplist) {
                        integer flagnewquestion = 0; //if a question is later added to assessmnet to a section than response record is created using this logic
                        List < string > qoptionvalue = new List < string > {};
                        List < string > wtoptionvalue = new List < string > {};
                        
                        if ( t.newquestFormat.Answer_Options__r.size() == 0 ){
                            string qoption=t.newquestFormat.Subquestion_Label__c;
                            if(qoption!=null){qoptionvalue=qoption.split('~');}
                            string wtoption=t.newquestFormat.Weight_of_Answer__c;
                            if(wtoption!=null){wtoptionvalue=wtoption.split('~');}                  
                        } else {
                            for( Answer_Option__c ansOpt :t.newquestFormat.Answer_Options__r ){
                                if ( ansOpt != null ){
                                    if ( ansOpt.Name != null && ansOpt.Name !='' ){
                                        qoptionvalue.add(ansOpt.Name);
                                    }
                                    if ( ansOpt.Weight__c != null ){    
                                        wtoptionvalue.add(string.valueOf(ansOpt.Weight__c));
                                    }
                                }
                            }
                        }

                        for (Questionnaire_Response__c res: reponseObjects) {

                            //System.debug('1----- in edit else section t.multiSELECTlist'+t.multiSELECTlist+'qtype:'+t.newquestFormat.Question_Type__c);
                            // System.debug('2----- in edit else section response form database'+res);
                            if (t.newquestFormat.id == res.Question_Template__c) { //res.Weight_Response__c=0;
                                flagnewquestion = 1; //both reospone object and UI contains that record
                                //if its mutiSELECT is not null than put logic to store with tilde sign   
                                string[] str = t.multiSELECTlist;
                                string s = '';
                                double multireswt = 0;
                                if (str != null) {
                                    if (t.newquestFormat.Question_Type__c.equalsIgnoreCase('MultiSELECTPicklist')) {
                                        res.Weight_Response__c = -1;

                                    }
                                    for (integer i = 0; i < str.size(); i++) {
                                        s = str[i] + '~' + s;

                                        //for multiSELECT weights
                                        /* if(wtoptionvalue.size()>0)
                                                        {
                                                        for(integer i1 = 0; i1< qoptionvalue.size(); i1++)
                                                        {   
                                                                                                        
                                                            if((str[i]).equalsIgnoreCase(qoptionvalue.get(i1)))
                                                            {
                                                                //System.debug('3 ----- multiSELECT add weight');
                                                                multireswt+=Double.valueOf(wtoptionvalue.get(i1).trim());  break;
                                                            } 
                                                        }
                                                        }*/
                                    }
                                    /* if(wtoptionvalue.size()>0)
                                                        {res.Weight_Response__c=multireswt;
                                                        //System.debug('4 ----- multiSELECT add weight if option>0');
                                                        }*/

                                    if (s.endsWithIgnoreCase('~')) {
                                        s = s.substring(0, s.length() - 1);
                                        //System.debug(' newSetStr ============ ' + s);
                                        res.Response__c = s;

                                    }
                                } else {
                                    res.Response__c = t.resObj.Response__c;
                                    //System.debug('5 -------else-not multiSELECTres.Response__c'+res.Response__c);
                                    if ((res.Response__c != null)) {
                                        if (t.newquestFormat.Question_Type__c.equalsIgnoreCase('RadioPicklist') 
                                            || t.newquestFormat.Question_Type__c.equalsIgnoreCase('Dropdown Picklist')) {
                                            if (wtoptionvalue.size() > 0) {
                                                for (integer i = 0; i < qoptionvalue.size(); i++) {

                                                    if ((res.Response__c).equalsIgnoreCase(qoptionvalue.get(i))) {
                                                        if ((res.Response__c).equalsIgnoreCase('N/A') || (res.Response__c).equalsIgnoreCase('NA')) {
                                                            res.Weight_Response__c = -1;
                                                        } else {
                                                            if (wtoptionvalue.size() > 0) {
                                                                res.Weight_Response__c = Double.valueOf(wtoptionvalue.get(i).trim());
                                                                break;
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        } else {
                                            res.Weight_Response__c = -1;
                                        }
                                        /*else if((t.newquestFormat.Question_Type__c.equalsIgnoreCase('Text'))&&(res.Response__c!=''))
                                                        {
                                                           //System.debug(' 8---TEXT-----should not come here if response text blank'+res.Response__c);
                                                           if(t.newquestFormat.Weight_of_Answer__c!=null)
                                                           {
                                                           //System.debug(' 9---TEXT----- response text not blank so assign wtres.Response__c:'+res.Response__c);
                                                           res.Weight_Response__c=Double.valueOf(t.newquestFormat.Weight_of_Answer__c.trim());
                                                           }
                                                        }*/
                                    }

                                }

                                System.debug(res);
                                responseLists.add(res);
                                break;
                            }
                        } //for(Questionnaire_Response__c res
                        if (flagnewquestion == 0) { //its a new question enterd later so create a new response record for it

                            Questionnaire_Response__c respRecord = new Questionnaire_Response__c();
                            System.debug('create new record');
                            respRecord.Question_Template__c = t.newquestFormat.id;
                            respRecord.Questionnaire_Taker_user__c = UserInfo.getUserId();
                            //System.debug('!!!!!!!!!!!~~~~~~~~~~!!!!!!!!!!!new record account'+accountId);
                            respRecord.Account_to_Response__c = accountId != null ? accountId : null;
                            respRecord.Issue_Request__c = issueId;

                            //respRecord.Weight_Response__c=0;//added logic below
                            //for multilist
                            //if its mutiSELECT is not null than put logic to store with tilde sign   
                            string[] str = t.multiSELECTlist;
                            string s = '';

                            double multireswt = 0;
                            if (str != null) {
                                if (t.newquestFormat.Question_Type__c.equalsIgnoreCase('MultiSELECTPicklist')) {
                                    respRecord.Weight_Response__c = -1;

                                }
                                for (integer i = 0; i < str.size(); i++) {
                                    s = str[i] + '~' + s;
                                    //for multiSELECT weights
                                    /*if(wtoptionvalue.size()>0)
                                                {
                                                for(integer i1 = 0; i1< qoptionvalue.size(); i1++)
                                                    {                                               
                                                        if((str[i]).equalsIgnoreCase(qoptionvalue.get(i1)))
                                                        {
                                                            multireswt+=Double.valueOf(wtoptionvalue.get(i1).trim());  break;
                                                        } 
                                                    }
                                                
                                                respRecord.Weight_Response__c=multireswt;
                                                }*/
                                }
                                if (s.endsWithIgnoreCase('~')) {
                                    s = s.substring(0, s.length() - 1);
                                    // s=s.trim();
                                    // System.debug('qqqqqqqq SAVING RECORDnewSetStr ============ ' + s);
                                    respRecord.Response__c = s;

                                }
                            } else {
                                //System.debug('qqqqqqqq SAVING RECORDnewSetStr ============ ' +t.resObj.Response__c);
                                respRecord.Response__c = t.resObj.Response__c;
                                // System.debug('qqqqqqqq SAVING RECORD BELOW ============ ' +respRecord.Response__c);
                                //List<string> qoptionvalue=qoption.split('~');
                                //List<string> wtoptionvalue=wtoption.split('~');  
                                if ((respRecord.Response__c != null)) {
                                    if (t.newquestFormat.Question_Type__c.equalsIgnoreCase('RadioPicklist') 
                                        || t.newquestFormat.Question_Type__c.equalsIgnoreCase('Dropdown Picklist')) {
                                        for (integer i = 0; i < qoptionvalue.size(); i++) {
                                            if ((respRecord.Response__c).equalsIgnoreCase(qoptionvalue.get(i))) {
                                                if ((respRecord.Response__c).equalsIgnoreCase('N/A') || (respRecord.Response__c).equalsIgnoreCase('NA')) {
                                                    respRecord.Weight_Response__c = -1;
                                                } else {
                                                    if (wtoptionvalue.size() > 0) {
                                                        respRecord.Weight_Response__c = Double.valueOf(wtoptionvalue.get(i).trim());
                                                        break;
                                                    }
                                                }
                                            }
                                        }
                                    } else {
                                        respRecord.Weight_Response__c = -1;
                                    }
                                    /*else if((t.newquestFormat.Question_Type__c.equalsIgnoreCase('Text'))&&(respRecord.Response__c!=''))
                                                        {
                                                            if(t.newquestFormat.Weight_of_Answer__c!=null)
                                                                    {
                                                                        respRecord.Weight_Response__c=Double.valueOf(t.newquestFormat.Weight_of_Answer__c.trim());
                                                                    }
                                                        }*/
                                }
                            }




                            responseLists.add(respRecord);


                        } // if(flagnewquestion==0)

                    } //end for loop for(QuestionDisplay t: qdisplist) 
                    //System.debug('final responseLists:'+responseLists);
                    if (responseLists.size() > 0) {

                        upsert responseLists;
                        for (Questionnaire_Response__c r: responseLists)
                        //to call create notes and get existing notes
                        attachnotes = createNotes(responseLists, formsubparams);
                    }
                    // upsert responseLists;        

                } //else

                if (attachnotes.size() > 0) {
                    upsert attachnotes;
                }
            } catch (Exception e) {
                System.debug('----------------Exception in saving the records :  ' + e);
            } finally { //allFileList =null;
            }

        }
    } //end inner class


    public void currentSectionQuestions() {
        //string accountId=System.currentPageReference().getParameters().get('accId'); //accId=accountId;
        string accountId = System.currentPageReference().getParameters().get('accid'); //accId=accountId;
        string issueId = System.currentPageReference().getParameters().get('issueid');
        string templateName = System.currentPageReference().getParameters().get('templatename');
        System.debug('doRerender = ' + this.doRerender);
        Integer i = 0; //theToggleVal =true;
        if (ltoggleApproval == 0) {
            theToggleValApproval = true;
        } else {

        }
        ltoggleApproval++;
        if (ltoggle == 0) {
            theToggleVal = true;
        } else {

        }
        ltoggle++;
        if (this.doRerender == null) {
            List<SectionStatus__c> sectionStatusList = [ SELECT Id, Issue_Request__c, status__c 
                                                               FROM SectionStatus__c 
                                                               WHERE status__c ='Complete' 
                                                               AND Issue_Request__c =:issueId];
            if (sectionStatusList != NULL && sectionStatusList.size() > 0) {
            } else {
                this.doRerender = false;
            }    
            
        }
        if (this.doRerender != null) {

            listQuestWithOptions = new QuestionDisplay[] {};
            listQuestWithText = new QuestionDisplay[] {};
            Id id = System.currentPageReference().getParameters().get('sectionId');
            System.debug('::this.doRerender::::'+this.doRerender+'::::id:::'+id);
            if (!this.doRerender && (id == null )) {
                List<IssueRequest_Life_Cycle__c> amList = [SELECT Id, InvestigationType__c FROM IssueRequest_Life_Cycle__c WHERE Id =:issueId AND InvestigationType__c != NULL];
                if (amList != NULL && amList.size() > 0) {
                    List<Section_Template__c> secTempList = [SELECT Id, Questionnaire_Section__c, Order_No__c FROM Section_Template__c WHERE Questionnaire_Section__c =:amList[0].InvestigationType__c ORDER BY Order_No__c];
                    if (secTempList != null && secTempList.size() > 0) {
                        id = secTempList[0].id;
                    }
                }
            }
            sectionId = id;
            System.debug('!!!!!! id of accountId in get quetsion list:' + accountId);
            System.debug('~~~~~~~~333 start  getquestionlist');
            if (id == null) {} else {
                //this returns all questions list in that section 
                questionsLists = [SELECT Id, Section_Question__r.id, Question_Label__c, Question_Order_No__c, Weight_of_Answer__c, Question_Type__c, HelpText__c, 
                                    Subquestion_Label__c,(SELECT Id,Name,Help_Text__c,Weight__c,Dependent_Question__r.Name,Next_Question__r.Name FROM Answer_Options__r) 
                                    FROM Question_Template__c 
                                    WHERE Section_Question__r.id = : id ORDER BY Question_Order_No__c];

                //System.debug('----------------questions Returned : ' + questionsLists);
            }
            List < Id > questionIds = new List < Id > ();
            if (questionsLists != NULL && questionsLists.size() >= 1) {
                for (Question_Template__c qids: questionsLists) {
                    questionIds.add(qids.id);
                    //System.debug('~~~~~~~~~id='+qids);
                }
            }
            //List<Questionnaire_Response__c> responseObjects = new List<Questionnaire_Response__c>(); 
            //Questionnaire_Response__c[] responseObjectsAll=[SELECT id,Response__c,Question_Template__c,Account_to_Response__c,Questionnaire_Taker_user__c FROM Questionnaire_Response__c WHERE Account_to_Response__c=:accountId and Question_Template__c IN :questionIds ORDER BY Question_Template__r.Question_Order_No__c] ;
            Questionnaire_Response__c[] responseObjectsAll = new Questionnaire_Response__c[] {};
            if (accountId != null && accountId != '') {
                responseObjectsAll = [SELECT id, Response__c, Question_Template__c, Weight_Response__c, Account_to_Response__c, Issue_Request__c, Questionnaire_Taker_user__c, (SELECT Id, Title, body, CreatedDate, Owner.FirstName, Owner.LastName FROM Notes ORDER BY CreatedDate) FROM Questionnaire_Response__c WHERE Issue_Request__c = : issueId AND Account_to_Response__c = : accountId and Question_Template__c IN: questionIds ORDER BY Question_Template__r.Question_Order_No__c];
            } else {
                responseObjectsAll = [SELECT id, Response__c, Question_Template__c, Weight_Response__c, Account_to_Response__c, Issue_Request__c, Questionnaire_Taker_user__c, (SELECT Id, Title, body, CreatedDate, Owner.FirstName, Owner.LastName FROM Notes ORDER BY CreatedDate) FROM Questionnaire_Response__c WHERE Issue_Request__c = : issueId AND Question_Template__c IN: questionIds ORDER BY Question_Template__r.Question_Order_No__c];
            }

            /*for(Question_Template__c quest: questionsLists ) 
          {
                 if(responseObjectsAll !=NULL && responseObjectsAll.size()>=1)
                    { 
                        for(Questionnaire_Response__c res: responseObjectsAll ) 
                        {
                            if(quest.id==res.Question_Template__c)
                            {
                                responseObjects.add(res);
                            }
                        }
                    }
          }   */
            //System.debug('Hhhhhhhhhhhhh~~~~~~~~~~~~~'+responseObjects);
            if ((responseObjectsAll == null) || (responseObjectsAll.size() == 0)) {
                //System.debug('~~~~~~~~444 allresponse is null  getquestionlist'); 

                System.debug('---------q all response null list:' + questionsLists);
                //iterate over and depending on question type,create a list FROM subquestion label. 
                if (questionsLists != NULL && questionsLists.size() >= 1) {
                    for (Question_Template__c quest: questionsLists) { //allFileList.add(new Attachment()) ; 
                        Note[] attachnotes = new Note[] {};
                        Questionnaire_Response__c resp = new Questionnaire_Response__c();
                        //resp.Notes=  attachnotes;     
                        List < SELECTOption > options = new List < SELECTOption > ();
                        if (quest.Question_Type__c.equalsIgnoreCase('RadioPicklist') 
                            || quest.Question_Type__c.equalsIgnoreCase('Dropdown Picklist')) {
                            
                            string qoptionValues = '';
                            List<string> ls = new List<string>();
                            if ( quest.Answer_Options__r.size() == 0 ){
                                qoptionValues = quest.Subquestion_Label__c;
                                if ( qoptionValues != null ){
                                    ls = qoptionValues.split('~');
                                }
                            } else {
                                for( Answer_Option__c ansOpt :quest.Answer_Options__r ){
                                    if ( ansOpt != null && ansOpt.Name != null && ansOpt.Name != '' ){
                                        ls.add(ansOpt.Name);
                                    }
                                }
                            }                                   
                            for (string s: ls) {
                                options.add(new SELECTOption(s, s));
                            }
                            
                            listQuestWithOptions.add(new QuestionDisplay(quest, options, resp, null));
                            i = 1;
                        } else if (quest.Question_Type__c.equalsIgnoreCase('Text') || quest.Question_Type__c.equalsIgnoreCase('Textarea') || quest.Question_Type__c.equalsIgnoreCase('Date')) {
                            //Textflag='true';
                            System.debug('-----text:');
                            //options.add(new SELECTOption('none','none'));
                            //resp.Response__c=quest.Subquestion_Label__c;
                            //listQuestWithOptions.add(new QuestionDisplay(quest,options,resp,null));  

                            if (resp.Response__c == null) {
                                if (quest.Subquestion_Label__c != null && quest.Answer_Options__r.size() == 0 ) {
                                    if ( quest.Subquestion_Label__c != null && quest.Subquestion_Label__c != '' ){
                                        resp.Response__c = quest.Subquestion_Label__c;
                                    }
                                } else {
                                    if ( quest.Answer_Options__r.size() > 0 ){
                                        resp.Response__c = quest.Answer_Options__r[0].Name;
                                    }
                                }
                            }
                            System.debug('-----resptext:' + resp);
                            listQuestWithOptions.add(new QuestionDisplay(quest, options, resp, null));
                        } else if (quest.Question_Type__c.equalsIgnoreCase('MultiSELECTPicklist')) {
                            string[] multilist = new string[] {};
                            string qoptionValues = '';
                            List<string> ls = new List<string>();
                            
                            if ( quest.Answer_Options__r.size() == 0 ){
                                qoptionValues = quest.Subquestion_Label__c;
                                if ( qoptionValues != null ){
                                    ls = qoptionValues.split('~');
                                }
                            } else {
                                for( Answer_Option__c ansOpt :quest.Answer_Options__r ){
                                    if ( ansOpt != null && ansOpt.Name != null && ansOpt.Name != '' ){
                                        ls.add(ansOpt.Name);
                                    }
                                }
                            }
                            for (string s: ls) {
                                options.add(new SELECTOption(s, s));
                            }
                            
                            listQuestWithOptions.add(new QuestionDisplay(quest, options, resp, multilist));
                            i = 1;
                        }

                    }
                }
            } //if resp
            else {
                System.debug('~~~~~~~~555 response list not null  getquestionlistq list:' + questionsLists);
                //iterate over and depending on question type,create a list FROM subquestion label. 
                if (questionsLists != NULL && questionsLists.size() >= 1) {
                    for (Question_Template__c quest: questionsLists) {
                        Questionnaire_Response__c resp = new Questionnaire_Response__c();
                        for (Questionnaire_Response__c res: responseObjectsAll) {
                            if (quest.id == res.Question_Template__c) {
                                resp = res;
                                break;
                            }
                        }
                        //Questionnaire_Response__c[] reponseObject=[SELECT id,Response__c,Question_Template__c,Account_to_Response__c,Questionnaire_Taker_user__c FROM Questionnaire_Response__c WHERE Questionnaire_Taker_user__c= :UserInfo.getUserId() AND Question_Template__c=:quest.id] ;
                        //Questionnaire_Response__c[] reponseObject=[SELECT id,Response__c,Question_Template__c,Account_to_Response__c,Questionnaire_Taker_user__c FROM Questionnaire_Response__c WHERE Account_to_Response__c= :accountId AND Question_Template__c=:quest.id] ;


                        /* if((reponseObject==null)||(reponseObject.size()==0))
                                {
                                 }
                                  else
                                   {
                                   resp=reponseObject[0];
                                   }       */
                        List < SELECTOption > options = new List < SELECTOption > ();

                        if (quest.Question_Type__c.equalsIgnoreCase('RadioPicklist') 
                            || quest.Question_Type__c.equalsIgnoreCase('Dropdown Picklist')) {
                            
                            string qoptionValues = '';
                            List<string> ls = new List<string>();
                            if ( quest.Answer_Options__r.size() == 0 ){
                                qoptionValues = quest.Subquestion_Label__c;
                                if ( qoptionValues != null ){
                                    ls = qoptionValues.split('~');
                                }
                            } else {
                                for( Answer_Option__c ansOpt :quest.Answer_Options__r ){
                                    if ( ansOpt != null && ansOpt.Name != null && ansOpt.Name != '' ){
                                        ls.add(ansOpt.Name);
                                    }
                                }
                            }                               
                            for (string s: ls) {
                                options.add(new SELECTOption(s, s));
                            }
                            
                            listQuestWithOptions.add(new QuestionDisplay(quest, options, resp, null));
                            i = 1;
                        } else if (quest.Question_Type__c.equalsIgnoreCase('Text') || quest.Question_Type__c.equalsIgnoreCase('Textarea') || quest.Question_Type__c.equalsIgnoreCase('Date')) {
                            //Textflag='true';
                            System.debug('-----text:');
                            options.add(new SELECTOption('none', 'none'));
                            System.debug('-----resptext:' + resp);
                            listQuestWithOptions.add(new QuestionDisplay(quest, options, resp, null));
                        } else if (quest.Question_Type__c.equalsIgnoreCase('MultiSELECTPicklist')) {
                            string[] multilist = new string[] {};
                            string qoptionValues = '';
                            List<string> ls = new List<string>();
                            
                            if ( quest.Answer_Options__r.size() == 0 ){
                                qoptionValues = quest.Subquestion_Label__c;
                                if ( qoptionValues != null ){
                                    ls = qoptionValues.split('~');
                                }
                            } else {
                                for( Answer_Option__c ansOpt :quest.Answer_Options__r ){
                                    if ( ansOpt != null && ansOpt.Name != null && ansOpt.Name != '' ){
                                        ls.add(ansOpt.Name);
                                    }
                                }
                            }
                            for (string s: ls) {
                                options.add(new SELECTOption(s, s));
                            }
                            
                            if (resp.Response__c != null) {
                                multilist = (resp.Response__c).split('~');
                                System.debug('QQQQQQQ' + multilist);
                            }
                            listQuestWithOptions.add(new QuestionDisplay(quest, options, resp, multilist));
                            i = 1;
                        }
                        //} 
                    }
                }
            }
        }
        System.debug('~~~~~~~~END   start  getquestionlist' + listQuestWithOptions);
        questionsList = listQuestWithOptions;
    }

    public static testMethod void testlistacc() {
        //QuestionnaireFields d= new QuestionnaireFields();
        //Test.setCurrentPageReference(new PageReference('Page.QuestionnaireCustom')); 
        /*
        Account acct=new Account(name='testorgacct');
        insert acct;
        */
        //Account ac=new Account();
        PageReference pageRef = Page.QuestionnaireCustom;
        Test.setCurrentPage(pageRef);
        //ApexPages.StandardController sc = new ApexPages.StandardSetController(c);
        QuestionnaireFields d = new QuestionnaireFields();
        ApexPages.currentPage().getUrl();
        Main_questionaire__c maintest = new Main_questionaire__c(Template_name__c = 'test');
        insert maintest;
        System.currentPageReference().getParameters().put('TemplateName', maintest.Template_name__c);
        Account ac = new Account(name = 'test account1', Create_Survey__c = true);
        ac.Main_Questionnaire_Template__c = maintest.id;
        Account ac1 = new Account(name = 'test account2', Create_Survey__c = true, Adequate_Lighting_Score__c = 5, Adequate_Locking_Score__c = 5, CCTV_Score__c = 5, Emergency_Response_Plan__c = 5, Mail_Handling_Score__c = 10);
        ac1.Main_Questionnaire_Template__c = maintest.id;
        Account ac2 = new Account(name = 'test account3');
        ac2.Main_Questionnaire_Template__c = maintest.id;
        insert ac;
        insert ac1;
        insert ac2;
        IssueRequest_Life_Cycle__c issuetest = new IssueRequest_Life_Cycle__c(Facility_Name__c = ac.id, InvestigationType__c = maintest.id);
        insert issuetest;
        System.currentPageReference().getParameters().put('issueid', issuetest.id);
        //Test when userSectionstatus is null  when survey is not taken yet or started   
        System.currentPageReference().getParameters().put('accId', ac.id);
        Section_Template__c sc = new Section_Template__c(Questionnaire_Section__c = maintest.id, Section_label__c = 'test section');
        insert sc;
        Section_Template__c sc1 = new Section_Template__c(Questionnaire_Section__c = maintest.id, Section_label__c = 'test section 2');
        insert sc1;
        System.currentPageReference().getParameters().put('sectionId', sc.id);
        Question_Template__c scq = new Question_Template__c(Section_Question__c = sc.id, Question_Label__c = 'What is your name?', Question_Order_No__c = 1, Question_Type__c = 'Text', Focus_category__c = 'CCTV', Weight_of_Answer__c = '4');
        Question_Template__c scqp = new Question_Template__c(Section_Question__c = sc.id, Question_Label__c = 'What is your age?', Question_Order_No__c = 2, Question_Type__c = 'RadioPicklist', Subquestion_Label__c = '10-30~31-50', Focus_category__c = 'Perimeter', Weight_of_Answer__c = '2~3');
        Question_Template__c scqm = new Question_Template__c(Section_Question__c = sc.id, Question_Label__c = 'What is your qualification?', Question_Order_No__c = 3, Question_Type__c = 'MultiSELECTPicklist', Subquestion_Label__c = 'High School~Bachelors~Masters', Focus_category__c = 'Emergency Response Plan', Weight_of_Answer__c = '2~3~4');
        insert scq;
        insert scqp;
        insert scqm;
        string q1id = scq.id;
        string q2id = scqp.id;
        string q3id = scqm.id;
        System.currentPageReference().getParameters().put(q1id + 'row1', 'Comment: test1');
        System.currentPageReference().getParameters().put(q2id + 'row1', 'Recommendation: test1');
        System.currentPageReference().getParameters().put(q3id + 'row1', 'Comment: test1');
        d.sectionsLists = [SELECT Id, Name, status__c, Section_label__c, Order_No__c FROM Section_Template__c WHERE Questionnaire_Section__c = : maintest.id ORDER BY Order_No__c];
        d.questionsLists = [SELECT Id, Section_Question__r.id, Question_Label__c, Question_Order_No__c, Weight_of_Answer__c, Question_Type__c, HelpText__c, Subquestion_Label__c FROM Question_Template__c WHERE Section_Question__r.id = : sc.id ORDER BY Question_Order_No__c];
        Test.startTest();
        System.currentPageReference().getParameters().put('accid', ac.id);
        System.currentPageReference().getParameters().put('issueid', issuetest.id);
        d.sectionsStatusLists = null;
        d.setdoRerender(true);
        d.sectionStatus();
        //d.setdoRerender(true);   
        d.currentSectionQuestions();
        d.setdoRerenderSave(true);
        d.save();
        d.cancel();
        d.exit();
        d = new QuestionnaireFields();
        d.setmyFlag(true);
        d.DoToggle();
        System.currentPageReference().getParameters().put('issueid', issuetest.id);
        //Test when userSectionstatus is not null,set school to have response    
        System.currentPageReference().getParameters().put('accid', ac.id);
        System.currentPageReference().getParameters().put(q1id + 'row1', 'Comment: test1');
        System.currentPageReference().getParameters().put(q2id + 'row1', 'Recommendation: test1');
        System.currentPageReference().getParameters().put(q3id + 'row1', 'Comment: test1');
        d.sectionsLists = [SELECT Id, Name, status__c, Section_label__c, Order_No__c FROM Section_Template__c WHERE Questionnaire_Section__c = : maintest.id ORDER BY Order_No__c];
        d.questionsLists = [SELECT Id, Section_Question__r.id, Question_Label__c, Question_Order_No__c, Weight_of_Answer__c, Question_Type__c, HelpText__c, Subquestion_Label__c FROM Question_Template__c WHERE Section_Question__r.id = : sc.id ORDER BY Question_Order_No__c];
        Questionnaire_Response__c responseObject = new Questionnaire_Response__c(Response__c = 'John', Question_Template__c = q2id, Account_to_Response__c = ac.id, Issue_Request__c = issuetest.id);
        insert responseObject;
        Questionnaire_Response__c responseObject1 = new Questionnaire_Response__c(Response__c = 'Bachelors', Question_Template__c = q3id, Account_to_Response__c = ac.id, Issue_Request__c = issuetest.id);
        insert responseObject1;
        Questionnaire_Response__c responseObject2 = new Questionnaire_Response__c(Response__c = '10-30', Question_Template__c = q2id, Account_to_Response__c = ac.id, Issue_Request__c = issuetest.id);
        insert responseObject2;
        //Test when userSectionstatus is not null,set school to have response    
        //System.currentPageReference().getParameters().put('sectionId', sc.id);
        d.setdoRerender(true);
        d.sectionStatus();
        d.currentSectionQuestions();
        d.save();
        QuestionDisplay qd = new QuestionDisplay(d.questionsLists[0]);
        d.save();
        Section_Template__c sc2 = new Section_Template__c(Questionnaire_Section__c = maintest.id, Section_label__c = 'test section 3');
        insert sc2;
        System.currentPageReference().getParameters().put('sectionId', sc2.id);
        Question_Template__c scq1 = new Question_Template__c(Section_Question__c = sc2.id, Question_Label__c = 'What is your name?', Question_Order_No__c = 1, Question_Type__c = 'Text', Focus_category__c = 'CCTV', Weight_of_Answer__c = '4');
        insert scq1;
        d.sectionStatus();
        d.currentSectionQuestions();
        d.save();
        d.submitForApproval();
        Test.stopTest();
        //assert results
        System.assert(ac != null, 'Account is not null');
    }
} //main class end