public with sharing class QuestionnaireFieldsIssue
{

    //this is extension class of Main_questionnaire template
    //TAke questionnaire field from section,question,question response,template
    public String message { get; set; }
    //public IssueRequest_Life_Cycle__c
    public String issueId{get;set;}
    public Account acc{get;set;}
    public List<Question_Template__c> questionsLists { get; set; }
    public List<Section_Template__c > sectionsLists{ get; set; }
    public List<Main_questionaire__c> templateLists { get; set; }
    public List<SectionStatus__c > sectionsStatusLists{ get; set; }
    //public Set<Id> sectionIds{get;set;}
    public String templateName{get;set;}
    public String templateId{get;set;}
    public String sectionId{get;set;}
    public String accountId{get;set;}
    public List<SelectOption> sectionsList{get;set;} 
    public List<Questionnaire_Response__c> QuestionResponse{get;set;}
    public List<QuestionDisplay> listQuestWithOptions;  
    public QuestionDisplay[] listQuestWithText;       

    public PageReference refresh= new PageReference(ApexPages.currentPage().getUrl());
    public Boolean refreshPagePart{get;set;}
    private Boolean theToggleVal = true;
    static integer ltoggle=0;
    private Boolean theToggleValApproval = false;
    static integer ltoggleApproval=0;
    public Transient Boolean doRerender; 
    public Transient Boolean doRerenderSave; 
    public Boolean getdoRerender(){return doRerender;}
    public Boolean getdoRerenderSave(){return doRerenderSave;}
    //added for not doing DMl in constructor
    public Boolean myFlag{get; set;}
    //public Boolean displaySubmitButton{get; set;}
    public List<Attachment> allFileList {get; set;}
    public void setmyFlag(Boolean flags)
    {
        this.myFlag=flags;
    }

    public boolean getpagehead()
    {
        String userAgent =ApexPages.currentPage().getHeaders().get('USER-AGENT');

        if(userAgent.contains('iPhone')) {
            return false;
        }
        else {
            return true;
        }
    }

    public void setdoRerender(Boolean doRerender)
    {
        this.doRerender = doRerender;
        System.debug('doRerender should be set here to true: doRerender = '+this.doRerender);
    } 

    public void setdoRerenderSave(Boolean doRerenderSave)
    {
        this.doRerenderSave = doRerenderSave;
        System.debug('doRerender should be set here to true: doRerender = '+this.doRerenderSave);
    } 

    public Boolean ParamToggle { get; set; }

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
   
    public QuestionnaireFieldsIssue(ApexPages.StandardSetController controller) {
        refreshPagePart=false; allFileList = new List<Attachment>() ; sectionsList=new List<SelectOption>(); //System.debug('eeee~~~~~~~~~~~~~------'+controller.getRecord()); //sectionStatus();
    }

    public QuestionnaireFieldsIssue(){sectionsList=new List<SelectOption>();}
 
    public void sectionStatus() 
    {
        try {

            myFlag=false;System.debug('-------------in section Status');
            theToggleVal =false;theToggleValApproval=false;//System.debug('----------initialized in sectionstatus'+initialized);
            if (!myFlag)
            {   
                sectionsList=new List<SelectOption>();
                issueId= System.currentPageReference().getParameters().get('issueid');
                templateName = System.currentPageReference().getParameters().get('templatename'); templateName =templateName.replaceAll('\\+',' ');
                System.debug('-------------in section Status'+templateName ); 
                SectionStatus__c[] StatusLists=new SectionStatus__c[]{};   //setinitialised(true); 
                accountId=System.currentPageReference().getParameters().get('accid');//to get the school or account id
                accountId= accountId != '' ? accountId : null;
                //Account or facility doesnt have template name on it, it is on the issue/request object
                //acc= [SELECT id,name From Account where id=:accountId];
                System.debug('!!!!!!!!!!!!!!!!~~~~~~~~~~~~status ~acct id from diff page :'+accountid);

                SFDCAccessController accessForAT = ExAMUtilClass.AccessController;
                List<String> fieldsListAT = new List<String>{'ExAM__Template_name__c'};
                accessForAT.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Main_questionaire__c'), fieldsListAT);

                templateLists = [SELECT Id, Name, Template_name__c FROM Main_questionaire__c WHERE Template_name__c = :templateName];
                if(templateLists!=NULL && templateLists.size()>=1)
                {
                    templateName = templateLists.get(0).Template_name__c;   

                    SFDCAccessController accessForST = ExAMUtilClass.AccessController;
                    List<String> fieldsListST = new List<String>{'ExAM__Order_No__c', 'ExAM__status__c', 'ExAM__Section_label__c'};
                    accessForST.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Section_Template__c'), fieldsListST);

                    sectionsLists = [SELECT Id, Name, Order_No__c, status__c, Section_label__c FROM Section_Template__c WHERE Questionnaire_Section__c = :templateLists.get(0).Id ORDER BY Order_No__c];
                    //displaySubmitButton=templateLists.get(0).Display_Submit_Button__c;

                    SFDCAccessController accessForSS1 = ExAMUtilClass.AccessController;

                    List<string> fieldsListSS1ST = new List<string>{'ExAM__Order_No__c', 'ExAM__Questionnaire_Section__c', 'ExAM__Section_label__c'};
                    accessForSS1.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Section_Template__c'), fieldsListSS1ST);

                    List<String> fieldsListSS1 = new List<String>{'ExAM__Issue_Request__c', 'ExAM__Section_Template__c', 'ExAM__Status__c', 'ExAM__User__c'};
                    accessForSS1.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__SectionStatus__c'), fieldsListSS1);

                    //iterate the sectionstatus table and we should remove userinfo check as there will always be 1 survey per account
                    SectionStatus__c[] userSectionStatus = [
                        SELECT    Id, Issue_Request__c, Section_Template__c, Section_Template__r.Order_No__c,
                                  Section_Template__r.Questionnaire_Section__c, Section_Template__r.Section_Label__c,
                                  Status__c, User__c
                        FROM      SectionStatus__c
                        WHERE     Issue_Request__c = :issueId
                        AND (Section_Template__c!=null)
                                  AND (Section_Template__r.Questionnaire_Section__c=:templateLists.get(0).Id)
                        ORDER BY  Section_Template__r.Order_No__c
                    ] ;
                    System.debug('~~~~~~~~11111~sectionstatus~~~~~~~~~~~~'+userSectionStatus.size()+'~~~sectionsLists '+sectionsLists.size());

                    if((userSectionStatus==null)||(userSectionStatus.size()==0))
                    {                   
                        System.debug('~~~~~~~~~~~~~COMES IN SECTION STATUS');

                        for(Section_Template__c res: sectionsLists ) 
                        {
                            SectionStatus__c stat=new SectionStatus__c();
                            stat.Account_to_SectionStatus__c=accountId != '' ?  accountId : null;
                            stat.Issue_Request__c =issueId;
                            stat.Section_Template__c= res.id; 
                            //stat.Section_StatusLabel__c=res.Section_Label__c;  
                            stat.status__c='Incomplete';
                            stat.User__c=UserInfo.getUserId();
                            System.debug('~~~~~~~~~~~~~default controller------'+stat);
                            StatusLists.add(stat);
                        }

                        SFDCAccessController accessForSSInsert1 = ExAMUtilClass.AccessController;
                        List<String> fieldsListSSInsert1 = new List<String>{'ExAM__Account_to_SectionStatus__c', 'ExAM__Issue_Request__c', 'ExAM__Section_Template__c', 'ExAM__status__c', 'ExAM__User__c'};
                        accessForSSInsert1.assertAuthorizedToCreate(Schema.getGlobalDescribe().get('exam__SectionStatus__c'), fieldsListSSInsert1);

                        upsert StatusLists;

                        SFDCAccessController accessForSS2 = ExAMUtilClass.AccessController;

                        List<string> fieldsListSS2ST = new List<string>{'ExAM__Order_No__c', 'ExAM__Questionnaire_Section__c', 'ExAM__Section_label__c'};
                        accessForSS2.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Section_Template__c'), fieldsListSS2ST);

                        List<String> fieldsListSS2 = new List<String>{'ExAM__Issue_Request__c', 'ExAM__Section_Template__c', 'ExAM__Status__c', 'ExAM__User__c'};
                        accessForSS2.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__SectionStatus__c'), fieldsListSS2);

                        sectionsStatusLists=[
                            SELECT    Id, Issue_Request__c , Section_Template__c, Section_Template__r.Order_No__c,
                                      Section_Template__r.Questionnaire_Section__c, Section_Template__r.Section_Label__c,
                                      Status__c, User__c
                            FROM      SectionStatus__c
                            WHERE     Issue_Request__c = :issueId
                                      AND (Section_Template__c!=null)
                                      AND (Section_Template__r.Questionnaire_Section__c=:templateLists.get(0).Id)
                            ORDER BY  Section_Template__r.Order_No__c
                        ];

                    }
                    else
                    {
                        //sectionlist exists so no need for grabbing again but some new section may be added later so create section status for them
                        integer newSectionFlag=0;
                        System.debug('~~~~~~~~2222 inside new section status~sectionstatus~~~~~~~~~~~~'+userSectionStatus.size()+'~~~sectionsLists '+sectionsLists.size());
                        for(Section_Template__c res: sectionsLists ) 
                        {
                            for(SectionStatus__c stat: userSectionStatus)
                            {
                                System.debug('~~~~~~~33 insede for sectionstatus'+stat.Section_Template__c+',,,'+res.id);
                                if(stat.Section_Template__c == res.id)
                                {
                                    newSectionFlag=1;
                                    break;
                                }
                            }
                            System.debug('~~~~~~~444newSectionFlag' +newSectionFlag);
                            if(newSectionFlag==0)
                            {
                                //create new section status
                                SectionStatus__c newstat=new SectionStatus__c();
                                newstat.Account_to_SectionStatus__c=accountId != '' ? accountId : null;
                                newstat.Issue_Request__c =issueId;
                                //stat.Section_StatusLabel__c=res.Section_Label__c;  
                                newstat.Section_Template__c= res.id; 
                                newstat.status__c='Incomplete';
                                newstat.User__c=UserInfo.getUserId();
                                System.debug('~~~~~~~~~~~~~default controller------'+newstat);
                                StatusLists.add(newstat);
                            }
                            newSectionFlag=0;
                        }
                        if(StatusLists.size()>0)
                        {//at least one new section added
                            System.debug('~~~~~~~~~~~~~StatusLists.size() after adding extra sections'+StatusLists.size());

                            SFDCAccessController accessForSSInsert2 = ExAMUtilClass.AccessController;
                            List<String> fieldsListSSInsert2 = new List<String>{'ExAM__Account_to_SectionStatus__c', 'ExAM__Issue_Request__c', 'ExAM__Section_Template__c', 'ExAM__status__c', 'ExAM__User__c'};
                            accessForSSInsert2.assertAuthorizedToCreate(Schema.getGlobalDescribe().get('exam__SectionStatus__c'), fieldsListSSInsert2);

                            upsert StatusLists;

                            SFDCAccessController accessForSS3 = ExAMUtilClass.AccessController;

                            List<string> fieldsListSS3ST = new List<string>{'ExAM__Order_No__c', 'ExAM__Questionnaire_Section__c', 'ExAM__Section_label__c'};
                            accessForSS3.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Section_Template__c'), fieldsListSS3ST);

                            List<String> fieldsListSS3 = new List<String>{'ExAM__Issue_Request__c', 'ExAM__Section_Template__c', 'ExAM__Status__c', 'ExAM__User__c'};
                            accessForSS3.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__SectionStatus__c'), fieldsListSS3);

                            sectionsStatusLists = [
                                SELECT    Id, Issue_Request__c, Section_Template__c, Section_Template__r.Order_No__c,
                                          Section_Template__r.Questionnaire_Section__c, Section_Template__r.Section_Label__c,
                                          Status__c, User__c
                                FROM      SectionStatus__c
                                WHERE     Issue_Request__c = :issueId
                                          AND (Section_Template__c!=null)
                                          AND (Section_Template__r.Questionnaire_Section__c=:templateLists.get(0).Id)
                                ORDER BY  Section_Template__r.Order_No__c
                            ] ;
                        }
                        else
                        {
                            sectionsStatusLists=userSectionStatus;
                        }
                    }
                    System.debug('~~~~~~~222  section sttus~~~~~~final section list SECTION STATUS LIST----'+sectionsStatusLists);
                    sectionsList.add(new SelectOption('','--None--'));
                    for(SectionStatus__c res: sectionsStatusLists) 
                    {
                        sectionsList.add(new SelectOption(res.Section_Template__c,res.Section_Template__r.Section_Label__c));
                    }
                    System.debug('~~~~~~~~~~~~~Sections list'+sectionsList);

                    // To set the focus category scores for the account
                    /*  List<aggregateResult> aggr=[
                    Select Account__c, Question_Template__r.Focus_category__c focus, SUM(Questionnaire_Response__r.Total_Score__c)total
                    from Main_Report_Data__c where Account__c=:accountId GROUP BY  Account__c,Question_Template__r.Focus_category__c ];
                    if(acc!=null)
                    {           
                        acc.Overall_Score__c=0;          
                        integer b=0;
                        for(SectionStatus__c res: sectionsStatusLists) 
                        {
                            if(res.status__c.equalsIgnoreCase('complete'))
                            {
                                b++;
                                System.debug('!!!!!!!!!!!!!!!!!!b='+b+','+ res.status__c);
                            }
                        }
                        if(b==sectionsLists.size()) {
                            System.debug('!!!!!!!!!!!!!!!!!!b val:'+b);
                            acc.Survey_Completed__c='Complete';}
                            for (AggregateResult ar : aggr)
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
                                else if(focuscat.equalsIgnoreCase('Mail Handling')) {
                                    acc.Mail_Handling_Score__c=Integer.valueOf(ar.get('total'));
                                }
                            }
                        }
                        System.debug('~~~~~~~~~~~~~~~~~~~~~~~ main report data'+acc);
                        try{
                            if(acc.Overall_Score__c>0)
                            {
                                upsert acc;
                            }
                        }catch(Exception e){}
                    }  */
                    //if acc!=null
                    myFlag=true;
                }
            }
        }
        catch(Exception e) {
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()) );
        }
    }   

    public PageReference save()
    {
        /*for(Integer i = 0 ; i <allFileList.size() ; i++) {
            System.debug('IN MAIN SAVE METHOD '+allFileList.size()+','+allFileList[i].name);
        }*/
        try{
            if((this.doRerenderSave!=null)||(this.doRerenderSave!=false))
            {           

                SFDCAccessController accessForSS4 = ExAMUtilClass.AccessController;
                List<String> fieldsListSS4 = new List<String>{'ExAM__Issue_Request__c', 'ExAM__Section_Template__c', 'ExAM__Status__c', 'ExAM__User__c'};
                accessForSS4.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__SectionStatus__c'), fieldsListSS4);

                SectionStatus__c[] userSectionStatus = new SectionStatus__c[]{};             
                userSectionStatus=[
                    SELECT Id, Issue_Request__c, Section_Template__c, Status__c, User__c
                    FROM   SectionStatus__c
                    WHERE  Issue_Request__c = :issueId AND Section_Template__c =:listQuestWithOptions[0].newquestFormat.Section_Question__c
                ] ;
                System.debug('IN MAIN SAVE METHOD section status~~~~~~~~~~~~~'+userSectionStatus);
                System.debug('IN MAIN SAVE METHOD------'+listQuestWithOptions[0].newquestFormat.Section_Question__c);
                if((userSectionStatus==null)||(userSectionStatus.size()==0))
                {                   
                    //System.debug('!!!!~~~~~~~~~~~~~SHOULD NEVER COME HERE EVER');
                    SectionStatus__c stat=new SectionStatus__c();
                    stat.Account_to_SectionStatus__c=accountId != '' ? accountId : null; 
                    stat.Issue_Request__c =issueId;
                    stat.Section_Template__c=  listQuestWithOptions[0].newquestFormat.Section_Question__c; 
                    stat.status__c='Complete';    
                    stat.User__c=UserInfo.getUserId();
                    System.debug('~~~~~~~~~~~~~in save section NEW status------'+stat);

                    SFDCAccessController accessForSSInsert3 = ExAMUtilClass.AccessController;
                    List<String> fieldsListSSInsert3 = new List<String>{'ExAM__Account_to_SectionStatus__c', 'ExAM__Issue_Request__c', 'ExAM__Section_Template__c', 'ExAM__status__c', 'ExAM__User__c'};
                    accessForSSInsert3.assertAuthorizedToCreate(Schema.getGlobalDescribe().get('exam__SectionStatus__c'), fieldsListSSInsert3);

                    upsert stat;
                }
                else
                {
                    System.debug('else in~EDIT~~~~~~~~~~~~'+userSectionStatus);
                    //System.debug('~~~~~~~~~~~~~Record already exists put code for edit');
                    userSectionStatus[0].Status__c='Complete';

                    SFDCAccessController accessForSSUpdate = ExAMUtilClass.AccessController;
                    List<String> fieldsListSSUpdate = new List<String>{'ExAM__status__c'};
                    accessForSSUpdate.assertAuthorizedToUpdate(Schema.getGlobalDescribe().get('exam__SectionStatus__c'), fieldsListSSUpdate);

                    upsert userSectionStatus;
                }

                map<string, string> formparams = ApexPages.currentPage().getParameters();
                map<string, string> formsubparams=new map<string,string>();
                for(string keyName: formparams.keySet()) {
                    if(keyName.contains('row'))
                    {
                        formsubparams.put(keyName,formparams.get(keyName));
                        System.debug('~~~~~~~~~~in ' + keyName + ': ' + formparams.get(keyName));
                    }
                    else
                    {
                        System.debug('~~~~~~~~~~in ' + keyName + ': ' + formparams.get(keyName));
                    }
                }

                SFDCAccessController accessAnswer = ExAMUtilClass.AccessController;

                List<string> fieldsListAnswerST = new List<string>{'ExAM__Section_Question__c', 'ExAM__Weight_of_Answer__c'};
                accessAnswer.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Question_Template__c'), fieldsListAnswerST);

                List<String> fieldsListAnswer = new List<String>{'ExAM__Account_to_Response__c', 'ExAM__Issue_Request__c', 'ExAM__Questionnaire_Taker_user__c', 'ExAM__Question_Template__c', 'ExAM__Response__c', 'ExAM__Weight_Response__c'};
                accessAnswer.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Questionnaire_Response__c'), fieldsListAnswer);

                SFDCAccessController accessAnswerSave = ExAMUtilClass.AccessController;

                List<String> fieldsListAnswerCreate = new List<String>{'ExAM__Account_to_Response__c', 'ExAM__Issue_Request__c', 'ExAM__Questionnaire_Taker_user__c', 'ExAM__Question_Template__c', 'ExAM__Response__c', 'ExAM__Weight_Response__c'};
                accessAnswerSave.assertAuthorizedToCreate(Schema.getGlobalDescribe().get('exam__Questionnaire_Response__c'), fieldsListAnswerCreate);

                List<String> fieldsListAnswerUpdate = new List<String>{'ExAM__Account_to_Response__c', 'ExAM__Issue_Request__c', 'ExAM__Questionnaire_Taker_user__c', 'ExAM__Response__c', 'ExAM__Weight_Response__c'};
                accessAnswerSave.assertAuthorizedToUpdate(Schema.getGlobalDescribe().get('exam__Questionnaire_Response__c'), fieldsListAnswerUpdate);

                //System.debug('~~~~~~~~~~in save listQuestWithOptions,issueId:'+listQuestWithOptions+','+issueId); 
                QuestionDisplay l=new QuestionDisplay(); 
                l.innerSave(listQuestWithOptions,accountId,issueId,formsubparams);          

                System.debug(' ----------------Record saved successfully : ');
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO, 'Record saved successfully');
                ApexPages.addMessage(myMsg);

                refreshPagePart=true; theToggleValApproval=true;//myFlag=true; 

                String urlform = '';
                if (accountId != '' && accountId != null ) {
                    urlform = '/apex/QuestionnaireCustomIssue?accid='+accountId+'&issueid='+issueId+'&templatename='+templateName.replaceAll(' ','%20');  
                } else {
                    urlform = '/apex/QuestionnaireCustomIssue?issueid='+issueId+'&templatename='+templateName.replaceAll(' ','%20');  
                }
                //String encodedString = EncodingUtil.urlEncode(urlform,'UTF-8');
                System.debug('-------save url'+  refresh);
                System.debug('-------save url'+urlform  );
                PageReference saveClicked=new PageReference(urlform);
                saveClicked.setRedirect(true);
                //return refresh;
                return saveClicked;

            }//if dorender is not null

        }catch(Exception e){
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()) );
        }
        return null;
    }

    public PageReference submitForApproval()
    {
        System.debug('~~~~~INSIDE SUBMITurl'+issueId);
        try
        {
            issueId= System.currentPageReference().getParameters().get('issueid');System.debug('22222~~~~~INSIDE SUBMITurl'+issueId);

            SFDCAccessController accessAM = ExAMUtilClass.AccessController;
            List<String> fieldsListAM = new List<String>{'ExAM__Assessment_Form_Completion__c', 'ExAM__Date_Completed__c', 'ExAM__Assessor_Resource__c', 'ExAM__Status__c'};
            accessAM.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__IssueRequest_Life_Cycle__c'), fieldsListAM);

            IssueRequest_Life_Cycle__c issuerecord = [
                SELECT Assessment_Form_Completion__c, Date_Completed__c, Assessor_Resource__c, Id, Status__c
                FROM   IssueRequest_Life_Cycle__c
                WHERE  Id = :issueId
            ];
            if(issuerecord!=null)
            {
                issuerecord.Assessment_Form_Completion__c='Complete';
                System.debug('=====urlissuerecord'+issuerecord);
                //issuerecord.Status__c ='Closed';

                SFDCAccessController accessAMSave = ExAMUtilClass.AccessController;
                List<String> fieldsListAMSave = new List<String>{'ExAM__Assessment_Form_Completion__c'};
                accessAMSave.assertAuthorizedToCreate(Schema.getGlobalDescribe().get('exam__IssueRequest_Life_Cycle__c'), fieldsListAMSave);
                accessAMSave.assertAuthorizedToUpdate(Schema.getGlobalDescribe().get('exam__IssueRequest_Life_Cycle__c'), fieldsListAMSave);

                upsert issuerecord;
            }
            /*Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
            req1.setComments('Submitting request for approval.');
            System.debug(' SUMIT FOR APPROVAl-----------');
            accountId=System.currentPageReference().getParameters().get('accid');//to get the school or account id     
            req1.setObjectId(accountId);
            System.debug(' SUMIT FOR APPROVAl-----------'+accountId);
            Id syadmin=[select id from profile where name='System Administrator'].id;
            if(syadmin!=null)
            {
                ID elect = [select id,ProfileId from user where ProfileId=:syadmin].id;
                req1.setNextApproverIds(new Id[] {elect});
                Approval.ProcessResult result = Approval.process(req1); 
                System.debug(' SUMIT FOR APPROVAl----result -------'+result );
                System.assert(result.isSuccess());  
            }*/
            String hostVal  = ApexPages.currentPage().getHeaders().get('Host');
            String urlVal = Apexpages.currentPage().getUrl();
            String URLL = 'https://' + hostVal+ urlVal;
            String urls='/'+issueId;System.debug('=====url '+urls);
            PageReference cancelClicked=new PageReference(urls);
            //System.debug('=====url page ref'+cancelClicked);
            cancelClicked.setRedirect(true);
            return cancelClicked;
        }catch(Exception e){
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()) );
        }
        return null;
    }

    public PageReference cancel()
    {
        String urlform='';
        if (accountId != null && accountId != '') {
            urlform = '/apex/QuestionnaireCustomIssue?accid='+accountId+'&issueid='+issueId+'&templatename='+templateName;
        } else {
            urlform = '/apex/QuestionnaireCustomIssue?issueid='+issueId+'&templatename='+templateName;
        }
        PageReference saveClicked=new PageReference(urlform);
        saveClicked.setRedirect(true);
        return saveClicked;
    }
    /*public PageReference exit()
    {
        PageReference cancelClicked;
        String userAgent =ApexPages.currentPage().getHeaders().get('USER-AGENT');

        if(userAgent.contains('iPhone')) {
            cancelClicked=new PageReference('/one/one.app');
        }
        else {
            cancelClicked=new PageReference('/home/home.jsp');
        }
        cancelClicked.setRedirect(false);
        return cancelClicked;   
    }*/
    //create a new inner class so that we can add the flags for each record and display/create the questions as checklist/text/piclist etc.
    public class QuestionDisplay
    {
        //each record is sent to the visualforce frontend page iteratively through class vaiable.        
        //SELECT  Id,Question_Label__c,Question_Order_No__c,Question_Type__c,Subquestion_Label__c FROM Question_Template__c where Section_Question__c=:id order by Question_Order_No__c];         
        public Question_Template__c newquestFormat{get;set;}
        public Questionnaire_Response__c resObj{get;set;}
        public String questionFlag{get;set;}//default
        public List<SelectOption> optionsList{get;set;} 
        public String sectionLabel{get;set;}
        public String[] multiselectlist{get;set;} 
        public String acctId{get;set;}        
        public String issueId{get;set;}

        public QuestionDisplay(Question_Template__c question, List<SelectOption> subQuestionOption, Questionnaire_Response__c responseObj, String[] multi)
        {
            newquestFormat = new Question_Template__c();
            optionsList=new List<SelectOption>(); 
            resObj = new Questionnaire_Response__c();       
            this.newquestFormat=question;
            this.resObj=responseObj;
            //this.sectionLabel=sectionLabels;
            this.optionsList=subQuestionOption;
            this.multiselectlist=multi;
        }
        public QuestionDisplay(Question_Template__c question)
        {
            this.newquestFormat=question;
        }
        public QuestionDisplay() {}

        public Note[] createNotes(Questionnaire_Response__c[] responseLists,map<string, string>formsubparams)
        {
            Note[] attachnotes=new Note[]{};
            for(Questionnaire_Response__c r:responseLists)
            {
                for(string keyName: formsubparams.keySet()) 
                {
                    if((keyName.startsWith(r.Question_Template__c))&&(keyName.contains('row')))
                    {   
                        System.debug('-------NOTES IFformsubparams.get(keyName):'+formsubparams.get(keyName));
                        if((formsubparams.get(keyName)!=null)&&(formsubparams.get(keyName)!=''))
                        {
                            note n = new note();
                            n.parentId= r.id;                                               
                            n.body=formsubparams.get(keyName); // body of the note. this should be populated from the notes field that you have shown in the screenshot
                            if((n.body.startsWith('Recommendation'))||(n.body.startsWith('recommendation')))
                            {
                                n.title='Recommendation'+System.now(); // the title of the note
                            }
                            else
                            {
                                n.title='Comment'+System.now();
                            }
                            n.isPrivate=false;  // if private it will be visible only for the owner and any user with modify all permission
                            //insert n;  
                            attachnotes.add(n);
                            System.debug('~~~NOTES~~~~~~~in ' + keyName + ': '+n.parentId );
                        }
                    }
                }
            }
            return attachnotes;
        }

        public void innerSave(List<QuestionDisplay> qdisplist,String accountId,String issueid,map<string, string> formsubparams) {

            //Section_Template__c =:listQuestWithOptions[0].newquestFormat.Section_Question__c
            acctId=accountId != '' ? accountId : null;  
            issueId=issueid;
            Questionnaire_Response__c[] responseLists=new Questionnaire_Response__c[]{}; 
            //Give all responses for this section and account
            Questionnaire_Response__c[] reponseObjects= new Questionnaire_Response__c[]{};
            if (acctId != null && acctId != '') {
                reponseObjects = [
                    SELECT Account_to_Response__c, Id, Issue_Request__c, Questionnaire_Taker_user__c, Question_Template__c,
                           Question_Template__r.Section_Question__c, Question_Template__r.Weight_of_Answer__c,
                           Response__c, Weight_Response__c,
                           (SELECT Body, CreatedDate, Id, Owner.FirstName, Owner.LastName, Title FROM Notes ORDER BY CreatedDate)
                    FROM   Questionnaire_Response__c
                    WHERE  Issue_Request__c = :issueId AND Account_to_Response__c=:acctId
                           AND Question_Template__r.Section_Question__c = :qdisplist[0].newquestFormat.Section_Question__c
                ]; 
            } else {
                reponseObjects = [
                    SELECT Account_to_Response__c, Id, Issue_Request__c, Questionnaire_Taker_user__c, Question_Template__c,
                           Question_Template__r.Section_Question__c, Question_Template__r.Weight_of_Answer__c,
                           Response__c, Weight_Response__c,
                           (SELECT Body, CreatedDate, Owner.FirstName, Owner.LastName, Id, Title FROM Notes ORDER BY CreatedDate)
                    FROM   Questionnaire_Response__c
                    WHERE  Issue_Request__c = :issueId
                           AND Question_Template__r.Section_Question__c =:qdisplist[0].newquestFormat.Section_Question__c
               ]; 
            }
            //TO get both notes and attachments--- List<CombinedAttachMent> n=oo.CombinedAttachments;
            Note[] attachnotes=new Note[]{};
            //List<Note> reponsenotes=reponseObjects.Note;
            //   System.debug('~~~~---------------- : in Save : ' +t);               
            //  System.debug('~~~~---------------- : in Save response object from UI'+  t.resObj.Response__c); 

            // t.innerSave(accountId,t.resObj,t.multiselectlist);

            //logic to either create a new record or update if it alraedy exists,if question id and user id same than update elase create new
            //Questionnaire_Response__c[] reponseObject=[Select id,Response__c,Question_Template__c,Account_to_Response__c,Questionnaire_Taker_user__c from Questionnaire_Response__c where Account_to_Response__c= :accountId AND Question_Template__c=:newquestFormat.id]; 
            // System.debug('INNER SAVE,'+robj);
            if((reponseObjects==null)||(reponseObjects.size()==0))
            {
                /*for(Questionnaire_Response__c res: reponseObjects) 
                {
                    if(quest.id==res.Question_Template__c)
                    {
                        resp=res;break;
                    }
                }*/
                for(QuestionDisplay t: qdisplist)
                {
                    Questionnaire_Response__c respRecord=new Questionnaire_Response__c(); 
                    System.debug('create new record');
                    respRecord.Question_Template__c = t.newquestFormat.id;
                    respRecord.Questionnaire_Taker_user__c=UserInfo.getUserId();
                    //System.debug('!!!!!!!!!!!~~~~~~~~~~!!!!!!!!!!!new record account'+accountId);
                    respRecord.Account_to_Response__c=accountId != '' ? accountId : null ;
                    respRecord.Issue_Request__c=issueId; 
                    //For taking the weights from the question table and assigning the appropriate one to response field of weight
                    List<String> qoptionvalue=new List<String>{};
                    List<String> wtoptionvalue=new List<String>{};
                    if ( t.newquestFormat.Answer_Options__r.size() == 0 ){
                        String qoption=t.newquestFormat.Subquestion_Label__c;
                        if(qoption!=null){qoptionvalue=qoption.split('~');}
                        String wtoption=t.newquestFormat.Weight_of_Answer__c;
                        if(wtoption!=null){wtoptionvalue=wtoption.split('~');}                  
                        } else {
                            for( Answer_Option__c ansOpt :t.newquestFormat.Answer_Options__r ){
                                if ( ansOpt != null ){
                                    if ( ansOpt.Name != null && ansOpt.Name !='' ){
                                        qoptionvalue.add(ansOpt.Name);
                                    }
                                    if ( ansOpt.Weight__c != null ){
                                        wtoptionvalue.add(String.valueOf(ansOpt.Weight__c));
                                    }
                                }
                            }
                        }
                        //respRecord.Weight_Response__c=0;//added logic below
                        //for multilist
                        //if its mutiselect is not null than put logic to store with tilde sign   
                        String[] str=t.multiselectlist;           
                        String s='';

                        double multireswt=0;
                        if(str!=null)
                        {
                            if(t.newquestFormat.Question_Type__c.equalsIgnoreCase('MultiselectPicklist'))
                            {
                                respRecord.Weight_Response__c=-1;
                            }
                            for(integer i = 0; i < str.size(); i++)
                            {
                                s=str[i]+'~'+s;
                                //for multiselect weight
                                /*if(wtoptionvalue.size()>0)
                                {
                                    for(integer i1 = 0; i1< qoptionvalue.size(); i1++)
                                    {
                                        if((str[i]).equalsIgnoreCase(qoptionvalue.get(i1)))
                                        {
                                            multireswt+=Double.valueOf(wtoptionvalue.get(i1).trim());
                                            break;
                                        }
                                    }
                                    respRecord.Weight_Response__c=multireswt;
                                }*/
                            }
                            if(s.endsWithIgnoreCase('~'))
                            {
                                s=s.substring(0,s.length()-1);
                                // s=s.trim();
                                // System.debug('qqqqqqqq SAVING RECORDnewSetStr ============ ' + s);
                                respRecord.Response__c=s;
                            }
                        }
                        else
                        {
                            //System.debug('qqqqqqqq SAVING RECORDnewSetStr ============ ' +t.resObj.Response__c);
                            respRecord.Response__c=t.resObj.Response__c;
                            // System.debug('qqqqqqqq SAVING RECORD BELOW ============ ' +respRecord.Response__c);
                            //List<String> qoptionvalue=qoption.split('~');
                            //List<String> wtoptionvalue=wtoption.split('~');  
                            if((respRecord.Response__c!=null))
                            {
                                if(t.newquestFormat.Question_Type__c.equalsIgnoreCase('RadioPicklist') 
                                   || t.newquestFormat.Question_Type__c.equalsIgnoreCase('Dropdown Picklist'))
                                {
                                    for(integer i = 0; i< qoptionvalue.size(); i++)
                                    {                                               
                                        if((respRecord.Response__c).equalsIgnoreCase(qoptionvalue.get(i)))
                                        {
                                            if((respRecord.Response__c).equalsIgnoreCase('N/A')||(respRecord.Response__c).equalsIgnoreCase('NA'))
                                            {
                                                respRecord.Weight_Response__c=-1;
                                            }
                                            else
                                            {
                                                if(wtoptionvalue.size()>0)
                                                {
                                                    respRecord.Weight_Response__c=Double.valueOf(wtoptionvalue.get(i).trim());break; 
                                                }
                                            }
                                        }
                                    }
                                }
                                else
                                {
                                    respRecord.Weight_Response__c=-1;
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
                    }//end for loop  
                    //System.debug('-------ALL RECORD TO BE UPSERTED!!!'+responseLists);
                    if(responseLists.size()>0)
                    {
                        System.debug('-------ALL RECORD TO BE UPSERTEDresponseLists.size()>0!!!'+responseLists);

                        upsert responseLists;

                        //to call create notes and get existing notes
                        attachnotes=createNotes(responseLists,formsubparams);
                    }
                }
                else
                {
                    //all objects exists so edit only
                    for(QuestionDisplay t: qdisplist)
                    {
                        integer flagnewquestion=0;//if a question is later added to assessmnet to a section than response record is created using this logic
                        List<String> qoptionvalue=new List<String>{};
                        List<String> wtoptionvalue=new List<String>{};
                        if ( t.newquestFormat.Answer_Options__r.size() == 0 ){
                            String qoption=t.newquestFormat.Subquestion_Label__c;
                            if(qoption!=null){
                                qoptionvalue=qoption.split('~');
                            }
                            String wtoption=t.newquestFormat.Weight_of_Answer__c;
                            if(wtoption!=null){
                                wtoptionvalue=wtoption.split('~');
                            }
                        } else {
                            for( Answer_Option__c ansOpt :t.newquestFormat.Answer_Options__r ){
                                if ( ansOpt != null ){
                                    if ( ansOpt.Name != null && ansOpt.Name !='' ){
                                        qoptionvalue.add(ansOpt.Name);
                                    }
                                    if ( ansOpt.Weight__c != null ){    
                                        wtoptionvalue.add(String.valueOf(ansOpt.Weight__c));
                                    }
                                }
                            }
                        }
                        for(Questionnaire_Response__c res: reponseObjects) 
                        {

                            //System.debug('1----- in edit else section t.multiselectlist'+t.multiselectlist+'qtype:'+t.newquestFormat.Question_Type__c);
                            // System.debug('2----- in edit else section response form database'+res);
                            if(t.newquestFormat.id==res.Question_Template__c)
                            {    //res.Weight_Response__c=0;
                                flagnewquestion=1;//both reospone object and UI contains that record
                                //if its mutiselect is not null than put logic to store with tilde sign   
                                String[] str=t.multiselectlist;           
                                String s='';double multireswt=0;
                                if(str!=null)
                                {
                                    if(t.newquestFormat.Question_Type__c.equalsIgnoreCase('MultiselectPicklist'))
                                    {
                                        res.Weight_Response__c=-1;
                                    }
                                    for(integer i = 0; i < str.size(); i++) 
                                    {
                                        s=str[i]+'~'+s;
                                        //for multiselect weights
                                        /* if(wtoptionvalue.size()>0)
                                        {
                                            for(integer i1 = 0; i1< qoptionvalue.size(); i1++)
                                            {
                                                if((str[i]).equalsIgnoreCase(qoptionvalue.get(i1)))
                                                {
                                                    //System.debug('3 ----- multiselect add weight');
                                                    multireswt+=Double.valueOf(wtoptionvalue.get(i1).trim());  break;
                                                }
                                            }
                                        }*/
                                    }
                                    /* if(wtoptionvalue.size()>0)
                                    {
                                        res.Weight_Response__c=multireswt;
                                        //System.debug('4 ----- multiselect add weight if option>0');
                                    }*/
                                    if(s.endsWithIgnoreCase('~'))
                                    {
                                        s=s.substring(0,s.length()-1);
                                        //System.debug(' newSetStr ============ ' + s);
                                        res.Response__c=s;
                                    }
                                }
                                else
                                {
                                    res.Response__c=t.resObj.Response__c;
                                    //System.debug('5 -------else-not multiselectres.Response__c'+res.Response__c);
                                    if((res.Response__c!=null))
                                    {
                                        if(t.newquestFormat.Question_Type__c.equalsIgnoreCase('RadioPicklist') 
                                           || t.newquestFormat.Question_Type__c.equalsIgnoreCase('Dropdown Picklist'))
                                        {
                                            if(wtoptionvalue.size()>0)
                                            {
                                                for(integer i = 0; i< qoptionvalue.size(); i++)
                                                {
                                                    if((res.Response__c).equalsIgnoreCase(qoptionvalue.get(i)))
                                                    {
                                                        if((res.Response__c).equalsIgnoreCase('N/A')||(res.Response__c).equalsIgnoreCase('NA'))
                                                        {
                                                            res.Weight_Response__c=-1;
                                                        }
                                                        else
                                                        {
                                                            if(wtoptionvalue.size()>0)
                                                            {
                                                                res.Weight_Response__c=Double.valueOf(wtoptionvalue.get(i).trim());
                                                                break;
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                        else
                                        {
                                            res.Weight_Response__c=-1;
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
                        }//for(Questionnaire_Response__c res
                        if(flagnewquestion==0)
                        {//its a new question enterd later so create a new response record for it

                            Questionnaire_Response__c respRecord=new Questionnaire_Response__c(); 
                            System.debug('create new record');
                            respRecord.Question_Template__c = t.newquestFormat.id;
                            respRecord.Questionnaire_Taker_user__c=UserInfo.getUserId();
                            //System.debug('!!!!!!!!!!!~~~~~~~~~~!!!!!!!!!!!new record account'+accountId);
                            respRecord.Account_to_Response__c=accountId != '' ? accountId : null;
                            respRecord.Issue_Request__c=issueId; 

                            //respRecord.Weight_Response__c=0;//added logic below
                            //for multilist
                            //if its mutiselect is not null than put logic to store with tilde sign   
                            String[] str=t.multiselectlist;           
                            String s='';

                            double multireswt=0;
                            if(str!=null)
                            {    
                                if(t.newquestFormat.Question_Type__c.equalsIgnoreCase('MultiselectPicklist'))
                                {
                                    respRecord.Weight_Response__c=-1;
                                }
                                for(integer i = 0; i < str.size(); i++)
                                {
                                    s=str[i]+'~'+s;
                                    //for multiselect weights
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
                                if(s.endsWithIgnoreCase('~'))
                                {
                                    s=s.substring(0,s.length()-1);
                                    // s=s.trim();
                                    // System.debug('qqqqqqqq SAVING RECORDnewSetStr ============ ' + s);
                                    respRecord.Response__c=s;
                                }
                            }
                            else
                            {
                                //System.debug('qqqqqqqq SAVING RECORDnewSetStr ============ ' +t.resObj.Response__c);
                                respRecord.Response__c=t.resObj.Response__c;
                                // System.debug('qqqqqqqq SAVING RECORD BELOW ============ ' +respRecord.Response__c);
                                //List<String> qoptionvalue=qoption.split('~');
                                //List<String> wtoptionvalue=wtoption.split('~');  
                                if((respRecord.Response__c!=null))
                                {
                                    if(t.newquestFormat.Question_Type__c.equalsIgnoreCase('RadioPicklist') 
                                        || t.newquestFormat.Question_Type__c.equalsIgnoreCase('Dropdown Picklist'))
                                    {
                                        for(integer i = 0; i< qoptionvalue.size(); i++)
                                        {                                               
                                            if((respRecord.Response__c).equalsIgnoreCase(qoptionvalue.get(i)))
                                            {
                                                if((respRecord.Response__c).equalsIgnoreCase('N/A')||(respRecord.Response__c).equalsIgnoreCase('NA'))
                                                {
                                                    respRecord.Weight_Response__c=-1;
                                                }
                                                else
                                                {
                                                    if(wtoptionvalue.size()>0)
                                                    {
                                                        respRecord.Weight_Response__c=Double.valueOf(wtoptionvalue.get(i).trim());break; 
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    else
                                    {
                                        respRecord.Weight_Response__c=-1;
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
                        }// if(flagnewquestion==0)
                    }//end for loop for(QuestionDisplay t: qdisplist) 
                    //System.debug('final responseLists:'+responseLists);
                    if(responseLists.size()>0){

                        upsert responseLists;
                        for(Questionnaire_Response__c r:responseLists)
                            //to call create notes and get existing notes
                            attachnotes=createNotes(responseLists,formsubparams);

                        // upsert responseLists;
                    }
                }//else

                if(attachnotes.size()>0){
                    upsert attachnotes;
                }
        }
    
    }//end inner class
    
       
    public List<QuestionDisplay> getquestionsList()
    {
        try {

            String accountId=System.currentPageReference().getParameters().get('accid'); //accId=accountId;
            accountId = accountId != '' ? accountId : null;
            String issueId= System.currentPageReference().getParameters().get('issueid');
            String templateName = System.currentPageReference().getParameters().get('templatename'); 
            Integer i=0;//theToggleVal =true;
            if(ltoggleApproval==0)
            {
                theToggleValApproval =true;
            }
            else
            {

            }
            ltoggleApproval++;
            if(ltoggle==0)
            {
                theToggleVal =true;
            }
            else
            {

            }
            ltoggle++;
            if(this.doRerender!=null)
            {
                System.debug('doRerender = '+this.doRerender+'sectionID diercly'+sectionId);
                listQuestWithOptions= new QuestionDisplay[]{};
                listQuestWithText= new QuestionDisplay[]{};
                Id id =sectionId; //System.currentPageReference().getParameters().get('sectionId');
                sectionId=id; 

                //System.debug('!!!!!! id of accountId in get quetsion list:'+accountId);
                //System.debug('~~~~~~~~333 start  getquestionlist sectiond id'+sectionId); 
                if(id==null)       
                {}
                else
                {

                    SFDCAccessController accessForQT = ExAMUtilClass.AccessController;
                    List<String> fieldsListQT = new List<String>{'ExAM__HelpText__c', 'ExAM__Question_Label__c', 'ExAM__Question_Order_No__c', 'ExAM__Question_Type__c', 'ExAM__Section_Question__c', 'ExAM__Weight_of_Answer__c', 'ExAM__Subquestion_Label__c'};
                    accessForQT.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Question_Template__c'), fieldsListQT);

                    SFDCAccessController accessForAT = ExAMUtilClass.AccessController;
                    List<String> fieldsListAT = new List<String>{'ExAM__Help_Text__c', 'ExAM__Weight__c'};
                    accessForAT.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Answer_Option__c'), fieldsListAT);

                    //this returns all questions list in that section 
                    questionsLists = [
                        SELECT  HelpText__c, Id, Question_Label__c, Question_Order_No__c, Question_Type__c, Section_Question__c,
                                Weight_of_Answer__c, Subquestion_Label__c,
                                (SELECT Help_Text__c, Id, Name, Weight__c FROM Answer_Options__r) 
                        FROM    Question_Template__c 
                        WHERE   Section_Question__c = :id ORDER BY Question_Order_No__c
                    ]; 

                    List<Id> questionIds = new List<Id>();
                    if(questionsLists !=NULL && questionsLists.size()>=1)
                    { 
                        for(Question_Template__c qids:questionsLists)
                        {
                            questionIds.add(qids.id);
                            //System.debug('~~~~~~~~~id='+qids);
                        }
                    }

                    SFDCAccessController accessForANSWER = ExAMUtilClass.AccessController;
                    List<String> fieldsListANSWER = new List<String>{'ExAM__Help_Text__c', 'ExAM__Weight__c'};
                    accessForANSWER.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Answer_Option__c'), fieldsListANSWER);

                    //List<Questionnaire_Response__c> responseObjects = new List<Questionnaire_Response__c>(); 
                    Questionnaire_Response__c[] responseObjectsAll= new Questionnaire_Response__c[]{};
                    if (accountId != null && accountId != '') {
                        responseObjectsAll=[Select Id,Response__c,Question_Template__c,Weight_Response__c,Account_to_Response__c,Issue_Request__c,Questionnaire_Taker_user__c,(SELECT Id,Title,body,CreatedDate,Owner.FirstName,Owner.LastName FROM Notes order by CreatedDate) from Questionnaire_Response__c where Issue_Request__c=:issueId AND Account_to_Response__c=:accountId and Question_Template__c IN :questionIds order by Question_Template__r.Question_Order_No__c] ;
                    } else {
                        responseObjectsAll=[Select Id,Response__c,Question_Template__c,Weight_Response__c,Account_to_Response__c,Issue_Request__c,Questionnaire_Taker_user__c,(SELECT Id,Title,body,CreatedDate,Owner.FirstName,Owner.LastName FROM Notes order by CreatedDate) from Questionnaire_Response__c where Issue_Request__c=:issueId AND Question_Template__c IN :questionIds order by Question_Template__r.Question_Order_No__c] ;
                    }

                    if((responseObjectsAll==null)||(responseObjectsAll.size()==0))
                    {                  
                        //System.debug('~~~~~~~~444 allresponse is null  getquestionlist');
                        System.debug('---------q all response null list:'+questionsLists);
                        //iterate over and depending on question type,create a list from subquestion label.
                        if(questionsLists !=NULL && questionsLists.size()>=1)
                        {
                            for(Question_Template__c quest: questionsLists )
                            {
                                //allFileList.add(new Attachment()) ; 
                                Note[] attachnotes=new Note[]{};
                                Questionnaire_Response__c resp=new Questionnaire_Response__c();
                                //resp.Notes=  attachnotes;
                                List<SelectOption> options = new List<SelectOption>();
                                if(quest.Question_Type__c.equalsIgnoreCase('RadioPicklist') 
                                   || quest.Question_Type__c.equalsIgnoreCase('Dropdown Picklist'))
                                {
                                    String qoptionValues = '';
                                    List<String> ls = new List<String>();
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
                                    if ( ls.size() > 0 ){                 
                                        for(String s: ls) 
                                        {                   
                                            options.add(new SelectOption(s,s));                   
                                        } 
                                    }
                                    //RadioPicklistflag='true';
                                    System.debug('-----radio picklist:'+qoptionValues);  
                                    listQuestWithOptions.add(new QuestionDisplay(quest,options,resp,null) );   
                                    i=1;         
                                }
                                else if(quest.Question_Type__c.equalsIgnoreCase('Text'))
                                {
                                    //Textflag='true';
                                    System.debug('-----text:'); 
                                    options.add(new SelectOption('none','none'));
                                    if ( quest.Subquestion_Label__c!=null && quest.Answer_Options__r.size() == 0 ) {
                                        resp.Response__c=quest.Subquestion_Label__c;
                                    } else {
                                        if ( quest.Answer_Options__r.size() > 0 ){
                                            resp.Response__c = quest.Answer_Options__r[0].Name;
                                        }
                                    }
                                    listQuestWithOptions.add(new QuestionDisplay(quest,options,resp,null));
                                }
                                else if(quest.Question_Type__c.equalsIgnoreCase('MultiselectPicklist'))
                                {
                                    String[] multilist = new String[]{};
                                    String qoptionValues = '';
                                    List<String> ls = new List<String>();
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
                                    if ( ls.size() > 0 ){
                                        for (String s: ls) {
                                            options.add(new SelectOption(s, s));
                                        }
                                    }
                                    //MultiselectPicklistflag='true';
                                    System.debug('-----radio picklist:'+   qoptionValues); 
                                    listQuestWithOptions.add(new QuestionDisplay(quest,options,resp,multilist) ); 
                                    i=1;             
                                }
                            }
                        }
                    }//if resp
                    else
                    {
                        System.debug('~~~~~~~~555 response list not null  getquestionlistq list:'+questionsLists);
                        //iterate over and depending on question type,create a list from subquestion label.
                        if(questionsLists !=NULL && questionsLists.size()>=1) { 
                            for(Question_Template__c quest: questionsLists ) 
                            {
                                Questionnaire_Response__c resp=new Questionnaire_Response__c();  //allFileList.add(new Attachment()) ; 
                                for(Questionnaire_Response__c res: responseObjectsAll ) 
                                {
                                    if(quest.id==res.Question_Template__c)
                                    {
                                        resp=res;break;
                                    }
                                }
                               
                                List<SelectOption> options = new List<SelectOption>();         
                                
                                if(quest.Question_Type__c.equalsIgnoreCase('RadioPicklist') 
                                   || quest.Question_Type__c.equalsIgnoreCase('Dropdown Picklist'))
                                {
                                    String qoptionValues = '';
                                    List<String> ls = new List<String>();
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
                                    if ( ls.size() > 0 ){ 
                                        for(String s: ls) {                   
                                            options.add(new SelectOption(s,s));                   
                                        }  
                                    }
                                    //RadioPicklistflag='true';
                                    System.debug('-----picklistresp:'+resp);
                                    listQuestWithOptions.add(new QuestionDisplay(quest,options,resp,null) );
                                    i=1;
                                }
                                else if(quest.Question_Type__c.equalsIgnoreCase('Text'))
                                {
                                    //Textflag='true';
                                    System.debug('-----text:'); 
                                    if(resp.Response__c==null)
                                    {
                                        if(quest.Subquestion_Label__c!=null)
                                        {
                                            resp.Response__c=quest.Subquestion_Label__c;
                                        }
                                    }
                                    System.debug('-----resptext:'+resp);
                                    listQuestWithOptions.add(new QuestionDisplay(quest,options,resp,null));             
                                }
                                else if(quest.Question_Type__c.equalsIgnoreCase('MultiselectPicklist'))
                                {      
                                    String[] multilist = new String[]{};
                                    String qoptionValues = '';
                                    List<String> ls = new List<String>();
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
                                    if ( ls.size() > 0 ){ 
                                        for (String s: ls) {
                                            options.add(new SelectOption(s, s));
                                        }
                                    }
                                    //MultiselectPicklistflag='true';
                                    System.debug('-----radio picklist:'+   qoptionValues); 
                                    if(resp.Response__c!=null)
                                    {
                                        multilist=(resp.Response__c).split('~');
                                        System.debug('QQQQQQQ'+multilist);
                                    }
                                    listQuestWithOptions.add(new QuestionDisplay(quest,options,resp,multilist) ); 
                                    i=1;             
                                }          
                            //} 
                            }
                        }
                    }
                }
            }//else no section id
            // System.debug('~~~~~~~~END   start  getquestionlist'+listQuestWithOptions);
        }
        catch(Exception e) {
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()) );
        }
        return listQuestWithOptions;
    }

    public static testMethod void testlistacc()
    {

        PageReference pageRef = Page.QuestionnaireCustomIssue;
        Test.setCurrentPage(pageRef);
        //ApexPages.StandardController sc = new ApexPages.StandardSetController(c);

        QuestionnaireFieldsIssue d= new QuestionnaireFieldsIssue();      
        //ApexPages.StandardController scc = new ApexPages.StandardSetController(ac);
        ApexPages.currentPage().getUrl();

        Main_questionaire__c maintest=new Main_questionaire__c (Template_name__c ='test');
        insert maintest; 
        System.currentPageReference().getParameters().put('TemplateName', maintest.Template_name__c ); 
        Account ac=new Account(name='test account1',Create_Survey__c=true);  
        ac.Main_Questionnaire_Template__c=maintest.id;
        Account ac1=new Account(name='test account2',Create_Survey__c=true,Adequate_Lighting_Score__c=5,Adequate_Locking_Score__c=5,CCTV_Score__c=5,Emergency_Response_Plan__c=5,Mail_Handling_Score__c=10); 
        ac1.Main_Questionnaire_Template__c=maintest.id;
        Account ac2=new Account(name='test account3'); 
        ac2.Main_Questionnaire_Template__c=maintest.id;
        insert ac;insert ac1;insert ac2;
        IssueRequest_Life_Cycle__c issuetest=new IssueRequest_Life_Cycle__c(Facility_Name__c=ac.id,InvestigationType__c=maintest.id);
        insert issuetest; 
        System.currentPageReference().getParameters().put('issueid',issuetest.id);
         //Test when userSectionstatus is null  when survey is not taken yet or started   

        Section_Template__c sc= new Section_Template__c(Questionnaire_Section__c=maintest.id,Section_label__c='test section'); 
        insert sc;
        Section_Template__c sc1= new Section_Template__c(Questionnaire_Section__c=maintest.id,Section_label__c='test section 2'); 
        insert sc1;
        System.currentPageReference().getParameters().put('sectionId', sc.id);
        Question_Template__c scq= new Question_Template__c(Section_Question__c=sc.id,Question_Label__c='What is your name?',Question_Order_No__c=1,Question_Type__c='Text',Focus_category__c='CCTV',Weight_of_Answer__c='4');     
        Question_Template__c scqp= new Question_Template__c(Section_Question__c=sc.id,Question_Label__c='What is your age?',Question_Order_No__c=2,Question_Type__c='RadioPicklist',Subquestion_Label__c='10-30~31-50',Focus_category__c='Perimeter',Weight_of_Answer__c='2~3');     
        Question_Template__c scqm= new Question_Template__c(Section_Question__c=sc.id,Question_Label__c='What is your qualification?',Question_Order_No__c=3,Question_Type__c='MultiselectPicklist',Subquestion_Label__c='High School~Bachelors~Masters',Focus_category__c='Emergency Response Plan',Weight_of_Answer__c='2~3~4');     
        Question_Template__c scqp1= new Question_Template__c(Section_Question__c=sc.id,Question_Label__c='What is your age?',Question_Order_No__c=4,Question_Type__c='RadioPicklist',Subquestion_Label__c='10-30~31-50',Focus_category__c='Adequate Lighting',Weight_of_Answer__c='2~3');     
        Question_Template__c scqm1= new Question_Template__c(Section_Question__c=sc.id,Question_Label__c='What is your qualification?',Question_Order_No__c=5,Question_Type__c='MultiselectPicklist',Subquestion_Label__c='High School~Bachelors~Masters',Focus_category__c='Adequate Locking System');     
        Question_Template__c scqp2= new Question_Template__c(Section_Question__c=sc.id,Question_Label__c='What is your age?',Question_Order_No__c=6,Question_Type__c='RadioPicklist',Subquestion_Label__c='10-30~31-50',Focus_category__c='Mail Handling');     

        insert scq;insert scqp;insert scqm;insert scqp1;insert scqm1;insert scqp2;
        String q1id=scq.id;
        String q2id=scqp.id;
        String q3id=scqm.id;
        String q4id=scqp1.id;
        String q5id=scqp2.id;
        System.currentPageReference().getParameters().put(q1id+'row1','Comment: test1');
        System.currentPageReference().getParameters().put(q2id+'row1','Recommendation: test1');
        System.currentPageReference().getParameters().put(q3id+'row1','Comment: test1');      
        System.currentPageReference().getParameters().put(q4id+'row1','Comment: test1');

        List<Question_Template__c> questionsLists = [SELECT  Id,Section_Question__c,Question_Label__c,Question_Order_No__c,Weight_of_Answer__c,Question_Type__c,HelpText__c,Subquestion_Label__c FROM Question_Template__c where Section_Question__c=:sc.id order by Question_Order_No__c]; 
        Test.startTest();
        System.currentPageReference().getParameters().put('accid', ac.id);
        d.sectionsStatusLists=null;
        d.setdoRerender(true); 
        boolean b=d.getdoRerender();
        b=d.getdoRerenderSave();
        d.sectionStatus();   
        d.sectionId=sc.id;
        d.getquestionsList();  
        d.setdoRerenderSave(true);  
        d.save();  d.cancel();   //d.exit();  

        d= new QuestionnaireFieldsIssue();d.setmyFlag(true);d.DoToggle();
        System.currentPageReference().getParameters().put('issueid',issuetest.id);
        //Test when userSectionstatus is not null,set school to have response    
        System.currentPageReference().getParameters().put('accid', ac.id);
        System.currentPageReference().getParameters().put(q1id+'row1','Comment: test1');
        System.currentPageReference().getParameters().put(q2id+'row1','Recommendation: test1');
        System.currentPageReference().getParameters().put(q3id+'row1','Comment: test1');      
        System.currentPageReference().getParameters().put(q4id+'row1','Comment: test1');
        Questionnaire_Response__c responseObject=new Questionnaire_Response__c(Response__c='John',Question_Template__c=q1id,Account_to_Response__c=ac.id,Issue_Request__c=issuetest.id);
        insert responseObject;
        d.setdoRerender(true);
        System.currentPageReference().getParameters().put('sectionId', sc.id);
        d.sectionId=sc.id;
        Question_Template__c scqp3= new Question_Template__c(Section_Question__c=sc.id,Question_Label__c='What is your age?',Question_Order_No__c=6,Question_Type__c='RadioPicklist',Subquestion_Label__c='10-30~31-50',Focus_category__c='Mail Handling',Weight_of_Answer__c='1~2');
        insert scqp3;
        //SectionStatus__c stat=new SectionStatus__c(User__c=UserInfo.getUserId(),Section_Template__c=sc.id,Account_to_SectionStatus__c=ac.id,status__c='Incomplete');
        //insert stat;
        d.sectionStatus();
        d.sectionId=sc.id;
        d.getquestionsList();
        //QuestionDisplay qd=new QuestionDisplay (questionsLists[0]);
        d.save();
        System.currentPageReference().getParameters().put('issueid',issuetest.id);
        d.submitForApproval();
        Test.stopTest();

        //assert results
        System.assert(ac!=null,'Account is not null');
    }
}//main class end