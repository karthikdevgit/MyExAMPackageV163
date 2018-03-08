public with sharing class QuestionnaireFieldsDOI
{

    //this is extension class of Main_questionnaire template
    //TAke questionnaire field from section,question,question response,template
    public String message { get; set; }
    //public Id selectedTemplate { get; set; }
    //public Id selectedSection { get; set; }
    public List<Question_Template__c> questionsLists { get; set; }
    public List<Section_Template__c > sectionsLists{ get; set; }
    public List<Main_questionaire__c> templateLists { get; set; }
    public List<SectionStatus__c > sectionsStatusLists{ get; set; }
    //public Set<Id> sectionIds{get;set;}
    public String templateName{get;set;}
    public String templateId{get;set;}
    public String sectionId{get;set;}
    public String accountId{get;set;}
    public List<Questionnaire_Response__c> QuestionResponse{get;set;}
    public List<QuestionDisplay> listQuestWithOptions;  
    public QuestionDisplay[] listQuestWithText;       
    //public PageReference refresh=ApexPages.currentPage();
    //Apexpages.currentPage().getHeaders().put('X-UA-Com​patible', 'IE=8');
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
    public void setmyFlag(Boolean flags)
    {
        this.myFlag=flags;
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

    public QuestionnaireFieldsDOI(ApexPages.StandardSetController controller) {
        refreshPagePart=false; //sectionStatus();
    }

    public QuestionnaireFieldsDOI(){}
 
    public void sectionStatus() 
    {
        try {

            myFlag=false;
            theToggleVal =false;theToggleValApproval=false;//System.debug('----------initialized in sectionstatus'+initialized);
            if (!myFlag)
            {      
                SectionStatus__c[] StatusLists=new SectionStatus__c[]{};   //setinitialised(true); 
                accountId=System.currentPageReference().getParameters().get('accId');//to get the school or account id
                // templateName=System.currentPageReference().getParameters().get('TemplateName');
                System.debug('!!!!!!!!!!!!!!!!~~~~~~~~~~~~status ~acct id from diff page :'+accountid);

                SFDCAccessController accessForAT = ExAMUtilClass.AccessController;
                List<String> fieldsListAT = new List<String>{'ExAM__Template_name__c'};
                accessForAT.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Main_questionaire__c'), fieldsListAT);

                templateLists = [SELECT Id, Name, Template_name__c FROM Main_questionaire__c WHERE Template_name__c = 'DOI'];
                if(templateLists!=NULL && templateLists.size()>=1)
                {
                    templateName = templateLists.get(0).Template_name__c;

                    SFDCAccessController accessForST = ExAMUtilClass.AccessController;
                    List<String> fieldsListST = new List<String>{'ExAM__Order_No__c', 'ExAM__Section_label__c', 'ExAM__status__c'};
                    accessForST.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Section_Template__c'), fieldsListST);

                    sectionsLists = [SELECT Id, Name, Order_No__c, Section_label__c, status__c FROM Section_Template__c WHERE Questionnaire_Section__c = :templateLists.get(0).Id ORDER BY Order_No__c];

                    SFDCAccessController accessForSS1 = ExAMUtilClass.AccessController;

                    List<string> fieldsListSS1ST = new List<string>{'ExAM__Order_No__c', 'ExAM__Section_label__c'};
                    accessForSS1.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Section_Template__c'), fieldsListSS1ST);

                    List<String> fieldsListSS1 = new List<String>{'ExAM__Account_to_SectionStatus__c', 'ExAM__Section_Template__c', 'ExAM__Status__c', 'ExAM__User__c'};
                    accessForSS1.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__SectionStatus__c'), fieldsListSS1);

                    //iterate the sectionstatus table and we should remove userinfo check as there will always be 1 survey per account
                    SectionStatus__c[] userSectionStatus = [
                        SELECT    Account_to_SectionStatus__c, Id, Section_Template__c, Section_Template__r.Order_No__c,
                                  Section_Template__r.Section_Label__c, Status__c, User__c
                        FROM      SectionStatus__c
                        WHERE     Account_to_SectionStatus__c = :accountId
                                  AND (Section_Template__c!=null)
                        ORDER BY  Section_Template__r.Order_No__c
                    ];
                    System.debug('~~~~~~~~11111~sectionstatus~~~~~~~~~~~~'+userSectionStatus.size());
                    System.debug('sectionsLists ----'+sectionsLists.size());
                    // System.debug('~~~~~~~~~~~~~size both at top'+userSectionStatus.size()+',,,sec'+sectionsLists.size());
                  
                    if((userSectionStatus==null)||(userSectionStatus.size()==0))
                    {                   
                        System.debug('~~~~~~~~~~~~~COMES IN SECTION STATUS');
                        for(Section_Template__c res: sectionsLists ) 
                        {

                            SectionStatus__c stat=new SectionStatus__c();
                            stat.Account_to_SectionStatus__c=accountId;
                            stat.Section_Template__c= res.id; 
                            //stat.Section_StatusLabel__c=res.Section_Label__c;  
                            stat.status__c='Incomplete';
                            stat.User__c=UserInfo.getUserId();
                            System.debug('~~~~~~~~~~~~~default controller------'+stat);
                            StatusLists.add(stat);
                        }

                        SFDCAccessController accessForSSInsert1 = ExAMUtilClass.AccessController;
                        List<String> fieldsListSSInsert1 = new List<String>{'ExAM__Account_to_SectionStatus__c', 'ExAM__Section_Template__c', 'ExAM__status__c', 'ExAM__User__c'};
                        accessForSSInsert1.assertAuthorizedToCreate(Schema.getGlobalDescribe().get('exam__SectionStatus__c'), fieldsListSSInsert1);

                        upsert StatusLists;

                        SFDCAccessController accessForSS2 = ExAMUtilClass.AccessController;

                        List<string> fieldsListSS2ST = new List<string>{'ExAM__Order_No__c', 'ExAM__Section_label__c'};
                        accessForSS2.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Section_Template__c'), fieldsListSS2ST);

                        List<String> fieldsListSS2 = new List<String>{'ExAM__Account_to_SectionStatus__c', 'ExAM__Section_Template__c', 'ExAM__Status__c', 'ExAM__User__c'};
                        accessForSS2.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__SectionStatus__c'), fieldsListSS2);

                        sectionsStatusLists = [
                            SELECT    Account_to_SectionStatus__c, Id, Section_Template__c, Section_Template__r.Order_No__c,
                                      Section_Template__r.Section_Label__c, Status__c, User__c
                            FROM      SectionStatus__c
                            WHERE     Account_to_SectionStatus__c = :accountId
                                      AND (Section_Template__c!=null) 
                            ORDER BY  Section_Template__r.Order_No__c
                        ];
                    }
                    else if(userSectionStatus.size()<sectionsLists.size())
                    {   
                        integer i=0;
                        System.debug('~~~~~~~~~~~~~add new status default'+userSectionStatus.size()+userSectionStatus+',,,sec'+sectionsLists.size()+sectionsLists);
                        for(Section_Template__c res: sectionsLists ) 
                        {
                            for(SectionStatus__c statusobj: userSectionStatus)
                            {
                                if(res.id==statusobj.Section_Template__c)
                                {
                                    i=1;
                                    System.debug('~~both are equal~~~~~~~~~'+res.id+'status'+statusobj.Section_Template__c);
                                    break;
                                }
                            }
                            if(i==0)
                            {
                                SectionStatus__c stat=new SectionStatus__c();
                                stat.Account_to_SectionStatus__c=accountId; 
                                stat.Section_Template__c= res.id;
                                //stat.Section_StatusLabel__c=res.Section_Label__c;  
                                stat.status__c='Incomplete';
                                stat.User__c=UserInfo.getUserId();
                                //System.debug('~~~~~~~~~~~~~add new status default controller------'+stat);
                                StatusLists.add(stat);
                            }
                            i=0;
                        }

                        SFDCAccessController accessForSSInsert2 = ExAMUtilClass.AccessController;
                        List<String> fieldsListSSInsert2 = new List<String>{'ExAM__Account_to_SectionStatus__c', 'ExAM__Section_Template__c', 'ExAM__status__c', 'ExAM__User__c'};
                        accessForSSInsert2.assertAuthorizedToCreate(Schema.getGlobalDescribe().get('exam__SectionStatus__c'), fieldsListSSInsert2);

                        upsert StatusLists;

                        SFDCAccessController accessForSS3 = ExAMUtilClass.AccessController;

                        List<string> fieldsListSS3ST = new List<string>{'ExAM__Order_No__c', 'ExAM__Section_label__c'};
                        accessForSS3.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Section_Template__c'), fieldsListSS3ST);

                        List<String> fieldsListSS3 = new List<String>{'ExAM__Account_to_SectionStatus__c', 'ExAM__Section_Template__c', 'ExAM__Status__c', 'ExAM__User__c'};
                        accessForSS3.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__SectionStatus__c'), fieldsListSS3);

                        sectionsStatusLists = [
                            SELECT    Account_to_SectionStatus__c, Id, Section_Template__c, Section_Template__r.Section_Label__c, 
                                      Section_Template__r.Order_No__c, Status__c, User__c
                            FROM      SectionStatus__c
                            WHERE     Account_to_SectionStatus__c = :accountId
                                      AND (Section_Template__c!=null)
                            ORDER BY  Section_Template__r.Order_No__c
                        ];
                    }
                    else if(userSectionStatus.size()>sectionsLists.size())
                    {
                        //extra section status
                        integer i=0;
                        List<SectionStatus__c> deleteSectionStatus=new List<SectionStatus__c>();
                        for(SectionStatus__c statusobj: userSectionStatus) 
                        {
                            for(Section_Template__c res: sectionsLists )
                            {
                                if(res.id==statusobj.Section_Template__c)
                                {
                                    i=1;
                                    break;
                                }
                            }
                            if(i==0)
                            {
                                //stat.Section_StatusLabel__c=res.Section_Label__c;  
                                //System.debug('~~~~~~~~~~~~~default controller------'+statusobj);
                                deleteSectionStatus.add(statusobj);
                            }
                            i=0;
                        }

                        //while(SectionStatus__c statusobj: deleteSectionStatus)
                        integer l=0;
                        if(deleteSectionStatus != null && deleteSectionStatus.size() > 0)
                        {
                            SFDCAccessController accessForSSDel = ExAMUtilClass.AccessController;
                            if ( accessForSSDel.isAuthorizedToDelete(Schema.getGlobalDescribe().get('exam__SectionStatus__c')) )
                            {
                                delete deleteSectionStatus;
                            }
                        }

                        SFDCAccessController accessForSS4 = ExAMUtilClass.AccessController;

                        List<string> fieldsListSS4ST = new List<string>{'ExAM__Order_No__c', 'ExAM__Section_label__c'};
                        accessForSS4.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Section_Template__c'), fieldsListSS4ST);

                        List<String> fieldsListSS4 = new List<String>{'ExAM__Account_to_SectionStatus__c', 'ExAM__Section_Template__c', 'ExAM__Status__c', 'ExAM__User__c'};
                        accessForSS4.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__SectionStatus__c'), fieldsListSS4);

                        sectionsStatusLists = [
                            SELECT    Account_to_SectionStatus__c, Id, Section_Template__c, Section_Template__r.Section_Label__c,
                                      Section_Template__r.Order_No__c, Status__c, User__c
                            FROM      SectionStatus__c
                            WHERE     Account_to_SectionStatus__c = :accountId
                                      AND (Section_Template__c!=null)
                            ORDER BY  Section_Template__r.Order_No__c
                        ];
                    }
                    else
                    {

                        //sectionlist exists so no need for grabbing again
                        // sectionsStatusLists=[Select id,Section_Template__c,Section_Template__c,Section_Template__r.Section_Label__c,Status__c,User__c from SectionStatus__c where User__c= :UserInfo.getUserId()] ;
                        //sectionsStatusLists=[Select id,Section_Template__c,Section_Template__c,Section_Template__r.Section_Label__c,Section_Template__r.Order_No__c,stat.Account_to_SectionStatus__c,Status__c,User__c from SectionStatus__c where User__c= :UserInfo.getUserId() AND (Section_Template__c!=null) order by Section_Template__r.Order_No__c] ;
                        sectionsStatusLists=userSectionStatus;
                    }
                    System.debug('~~~~~~~222  section sttus~~~~~~final section list SECTION STATUS LIST----'+sectionsStatusLists);

                    SFDCAccessController accessMRD = ExAMUtilClass.AccessController;

                    List<String> fieldsListMRDQT = new List<String>{'ExAM__Focus_category__c'};
                    accessMRD.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Question_Template__c'), fieldsListMRDQT);

                    List<String> fieldsListMRDANS = new List<String>{'ExAM__Total_Score__c'};
                    accessMRD.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Questionnaire_Response__c'), fieldsListMRDANS);

                    List<String> fieldsListMRD = new List<String>{'ExAM__Account__c', 'ExAM__Question_Template__c', 'ExAM__Questionnaire_Response__c'};
                    accessMRD.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Main_Report_Data__c'), fieldsListMRD);

                    // To set the focus category scores for the account
                    List<aggregateResult> aggr = [
                        SELECT    Account__c, Question_Template__r.Focus_category__c focus, SUM(Questionnaire_Response__r.Total_Score__c)total
                        FROM      Main_Report_Data__c
                        WHERE     Account__c = :accountId
                        GROUP BY  Account__c,Question_Template__r.Focus_category__c
                    ];

                    SFDCAccessController accessACCT = ExAMUtilClass.AccessController;
                    List<String> fieldsListACCT = new List<String>{'ExAM__Adequate_Lighting_Score__c', 'ExAM__Adequate_Locking_Score__c', 'ExAM__CCTV_Score__c', 'ExAM__Create_Survey__c', 'ExAM__Emergency_Response_Plan__c', 'ExAM__Mail_Handling_Score__c', 'ExAM__Overall_Score__c', 'ExAM__Perimeter_Score__c'};
                    accessACCT.assertAuthorizedToView(Schema.getGlobalDescribe().get('Account'), fieldsListACCT);

                    Account acc = [
                        SELECT Adequate_Lighting_Score__c, Adequate_Locking_Score__c, CCTV_Score__c, Create_Survey__c,
                               Emergency_Response_Plan__c, Id, Mail_Handling_Score__c, Name, Overall_Score__c,
                               Perimeter_Score__c
                        FROM   Account
                        WHERE  Create_Survey__c = :true AND Id = :accountId
                    ];
                    if(acc!=null)
                    {

                        SFDCAccessController accessAcctSave = ExAMUtilClass.AccessController;
                        List<String> fieldsListAcctSave = new List<String>{'ExAM__Overall_Score__c', 'ExAM__Survey_Completed__c'};

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
                        if(b==sectionsLists.size())
                        {
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
                                    fieldsListAcctSave.add( 'ExAM__CCTV_Score__c' );
                                }
                                else if(focuscat.equalsIgnoreCase('Perimeter'))
                                {
                                    acc.Perimeter_Score__c=Integer.valueOf(ar.get('total'));
                                    fieldsListAcctSave.add( 'ExAM__Perimeter_Score__c' );
                                }
                                else if(focuscat.equalsIgnoreCase('Adequate Lighting'))
                                {
                                    acc.Adequate_Lighting_Score__c=Integer.valueOf(ar.get('total'));
                                    fieldsListAcctSave.add( 'ExAM__Adequate_Lighting_Score__c' );
                                }
                                else if(focuscat.equalsIgnoreCase('Adequate Locking System'))
                                {
                                    acc.Adequate_Locking_Score__c=Integer.valueOf(ar.get('total'));
                                    fieldsListAcctSave.add( 'ExAM__Adequate_Locking_Score__c' );
                                }
                                else if(focuscat.equalsIgnoreCase('Emergency Response Plan'))
                                {
                                    acc.Emergency_Response_Plan__c=Integer.valueOf(ar.get('total'));
                                    fieldsListAcctSave.add( 'ExAM__Emergency_Response_Plan__c' );
                                }
                                else if(focuscat.equalsIgnoreCase('Mail Handling'))
                                {
                                    acc.Mail_Handling_Score__c=Integer.valueOf(ar.get('total'));
                                    fieldsListAcctSave.add( 'ExAM__Mail_Handling_Score__c' );
                                }
                            }
                            System.debug('~~~~~~~~~~~~~~~~~~~~~~~ main report data'+acc);           
                            accessAcctSave.assertAuthorizedToUpdate(Schema.getGlobalDescribe().get('Account'), fieldsListAcctSave);
                            upsert acc;
                        }
                    }
                    myFlag=true;
                }   //if acc!=null
        }
        catch(Exception e) {
            system.debug(':::::e:::::'+e);
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()) );
        }
    }   

    public PageReference save()
    {
        System.debug('IN MAIN SAVE METHOD '+accountId);
        try{
            if((this.doRerenderSave!=null)||(this.doRerenderSave!=false))
            {           
                SectionStatus__c[] userSectionStatus=new SectionStatus__c[]{};
                /*if(sectionsStatusLists!=null)
                {
                    userSectionStatus=sectionsStatusLists;
                }
                else
                {*/

                    SFDCAccessController accessForSS4 = ExAMUtilClass.AccessController;
                    List<String> fieldsListSS4 = new List<String>{'ExAM__Account_to_SectionStatus__c', 'ExAM__Section_Template__c', 'ExAM__Status__c', 'ExAM__User__c'};
                    accessForSS4.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__SectionStatus__c'), fieldsListSS4);
                    if(listQuestWithOptions != null && listQuestWithOptions.size() > 0) {
                        userSectionStatus = [SELECT Account_to_SectionStatus__c, Id, Section_Template__c, Status__c, User__c FROM SectionStatus__c WHERE Account_to_SectionStatus__c = :accountId AND Section_Template__c =:listQuestWithOptions[0].newquestFormat.Section_Question__c] ;
                    }
                //} //System.debug('IN MAIN SAVE METHOD section status~~~~~~~~~~~~~'+userSectionStatus);
                if((userSectionStatus==null)||(userSectionStatus.size()==0))
                {                   

                    System.debug('!!!!~~~~~~~~~~~~~SHOULD NEVER COME HERE EVER');
                    SectionStatus__c stat=new SectionStatus__c();
                    stat.Account_to_SectionStatus__c=accountId; 
                    if(listQuestWithOptions != null && listQuestWithOptions.size() > 0) {
                        stat.Section_Template__c=  listQuestWithOptions[0].newquestFormat.Section_Question__c; 
                    }
                    stat.status__c='Complete';    
                    stat.User__c=UserInfo.getUserId();
                   // System.debug('~~~~~~~~~~~~~in save section status------'+stat);

                    SFDCAccessController accessForSSCreate = ExAMUtilClass.AccessController;
                    List<String> fieldsListSSCreate = new List<String>{'ExAM__Account_to_SectionStatus__c', 'ExAM__Section_Template__c', 'ExAM__Status__c', 'ExAM__User__c'};
                    accessForSSCreate.assertAuthorizedToCreate(Schema.getGlobalDescribe().get('exam__SectionStatus__c'), fieldsListSSCreate);

                    upsert stat;

                }
                else
                {
                    //System.debug('else in~~~~~~~~~~~~~'+userSectionStatus);
                    //System.debug('~~~~~~~~~~~~~Record already exists put code for edit');
                    userSectionStatus[0].Status__c='Complete';

                    SFDCAccessController accessForSSUpdate = ExAMUtilClass.AccessController;
                    List<String> fieldsListSSUpdate = new List<String>{'ExAM__Status__c'};
                    accessForSSUpdate.assertAuthorizedToUpdate(Schema.getGlobalDescribe().get('exam__SectionStatus__c'), fieldsListSSUpdate);

                    upsert userSectionStatus;
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

                QuestionDisplay l=new QuestionDisplay(); 
                l.innerSave(listQuestWithOptions,accountId);          
                /* for(QuestionDisplay t: listQuestWithOptions)
                {
                    //   System.debug('~~~~---------------- : in Save : ' +t);               
                    //  System.debug('~~~~---------------- : in Save response object from UI'+  t.resObj.Response__c); 

                    t.innerSave(accountId,t.resObj,t.multiselectlist);
                }*/

                System.debug(' ----------------Record saved successfully : ');
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO, 'Record saved successfully');
                ApexPages.addMessage(myMsg);

                refreshPagePart=true; theToggleValApproval=true;//myFlag=true; 

                PageReference saveClicked = new PageReference('/apex/QuestionnaireCustomDOI?accId='+accountId);
                saveClicked.setRedirect(true);
                //return refresh;
                return saveClicked;

            }//if dorender is not null         
            // refresh.setRedirect(true);
            // return refresh;
        }
        catch(Exception e){
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()) );
        }
        return null;
    }
   
    /*public PageReference submitForApproval()
    {
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setComments('Submitting request for approval.');
        System.debug(' SUMIT FOR APPROVAl-----------');
        accountId=System.currentPageReference().getParameters().get('accId');//to get the school or account id     
        req1.setObjectId(accountId);
        System.debug(' SUMIT FOR APPROVAl-----------'+accountId);
        ID elect = [select id from user where username='ilsa.lund@mbaoutcome.com' limit 1].id;
        req1.setNextApproverIds(new Id[] {elect});
        Approval.ProcessResult result = Approval.process(req1); 
        System.debug(' SUMIT FOR APPROVAl----result -------'+result );
        System.assert(result.isSuccess());  
        PageReference cancelClicked=new PageReference('/home/home.jsp');
        cancelClicked.setRedirect(false);
        return cancelClicked;  
    }*/

    public PageReference submitForApproval()
    {
        try{
            Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
            req1.setComments('Submitting request for approval.');
            System.debug(' SUMIT FOR APPROVAl-----------');
            accountId=System.currentPageReference().getParameters().get('accId');//to get the school or account id     
            req1.setObjectId(accountId);
            System.debug(' SUMIT FOR APPROVAl-----------'+accountId);

            SFDCAccessController accessForProfile = ExAMUtilClass.AccessController;
            List<string> fieldsListProfile = new List<string>{};
            accessForProfile.assertAuthorizedToView(Schema.getGlobalDescribe().get('Profile'), fieldsListProfile);

            Id syadmin = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1].id;
            if(syadmin!=null)
            {
                
                SFDCAccessController accessForUser = ExAMUtilClass.AccessController;
                List<string> fieldsListUser = new List<string>{'ProfileId'};
                accessForUser.assertAuthorizedToView(Schema.getGlobalDescribe().get('User'), fieldsListUser);

                ID elect = [SELECT Id, ProfileId FROM User WHERE ProfileId = :syadmin LIMIT 1].id;
                req1.setNextApproverIds(new Id[] {elect});
                Approval.ProcessResult result = Approval.process(req1); 
                System.debug(' SUMIT FOR APPROVAl----result -------'+result );
                System.assert(result.isSuccess());  
            }
            PageReference cancelClicked=new PageReference('/home/home.jsp');
            cancelClicked.setRedirect(false);
            return cancelClicked;  
        }
        catch(Exception e){
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()) );
        }
        return null;
    }
    public PageReference cancel()
    {
        //PageReference cancelClicked=new PageReference('/apex/QuestionnaireCustom');

        PageReference saveClicked=new PageReference('/apex/QuestionnaireCustomDOI?accId='+accountId);
        saveClicked.setRedirect(true);
        return saveClicked;
    }
    public PageReference exit()
    {
        PageReference cancelClicked=new PageReference('/home/home.jsp');
        cancelClicked.setRedirect(true);
        return cancelClicked;  
    }
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
       
        public QuestionDisplay(Question_Template__c question,List<SelectOption> subQuestionOption,Questionnaire_Response__c responseObj,String[] multi)
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
       
        public void innerSave(List<QuestionDisplay> qdisplist,String accountId) {

            //Section_Template__c =:listQuestWithOptions[0].newquestFormat.Section_Question__c
            acctId=accountId;  
            Questionnaire_Response__c[] responseLists = new Questionnaire_Response__c[]{}; 
            Questionnaire_Response__c[] reponseObjects = new Questionnaire_Response__c[]{}; 
            if(qdisplist != null && qdisplist.size() > 0) {
                //Give all responses for this section and account
                reponseObjects=[
                    SELECT Account_to_Response__c, Id, Questionnaire_Taker_user__c, Question_Template__c,
                           Question_Template__r.Section_Question__c, Response__c
                    FROM   Questionnaire_Response__c
                    WHERE  Account_to_Response__c = :accountId
                           AND Question_Template__r.Section_Question__c = :qdisplist[0].newquestFormat.Section_Question__c
                ];
            }

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
                    respRecord.Account_to_Response__c=accountId; 
                    respRecord.Question_Template__c = t.newquestFormat.id;
                    respRecord.Questionnaire_Taker_user__c=UserInfo.getUserId();
                    System.debug('!!!!!!!!!!!~~~~~~~~~~!!!!!!!!!!!new record account'+accountId);
                    respRecord.Weight_Response__c=1;//put some logic for future
                    //for multilist
                    //if its mutiselect is not null than put logic to store with tilde sign   
                    String[] str=t.multiselectlist;           
                    String s='';
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
                            respRecord.Response__c=s;
                        }
                    }
                    else
                    {
                        respRecord.Response__c=t.resObj.Response__c;
                    }
                    responseLists.add(respRecord); System.debug('!!!'+respRecord);
                }//end for loop
                System.debug('!!!'+responseLists);

                upsert responseLists;
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
                            //if its mutiselect is not null than put logic to store with tilde sign   
                            String[] str=t.multiselectlist;           
                            String s='';
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

                upsert responseLists;        
            }//else
        }

        /*public void innerSave(String accountId,Questionnaire_Response__c robj,String[] str) {
            try {
               
                acctId=accountId;                
                //logic to either create a new record or update if it alraedy exists,if question id and user id same than update elase create new
                Questionnaire_Response__c[] reponseObject=[Select id,Response__c,Question_Template__c,Account_to_Response__c,Questionnaire_Taker_user__c from Questionnaire_Response__c where Account_to_Response__c= :accountId AND Question_Template__c=:newquestFormat.id]; 
                System.debug('INNER SAVE,'+robj);
                                 
                 String s='';
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
    }//end inner class
    
       
    public List<QuestionDisplay> getquestionsList()
    {
        System.debug('Entering question Template::::::');
        listQuestWithOptions= new QuestionDisplay[]{};
        try {

            String accountId=System.currentPageReference().getParameters().get('accId'); //accId=accountId;
            System.debug('doRerender = '+this.doRerender);
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
                listQuestWithText= new QuestionDisplay[]{};
                Id id = System.currentPageReference().getParameters().get('sectionId');
                sectionId=id; 

                System.debug('!!!!!! id of accountId in get quetsion list:'+accountId);
                System.debug('~~~~~~~~333 start  getquestionlist'+id); 
                if(id==null)       
                {}
                else
                {

                    SFDCAccessController accessQT = ExAMUtilClass.AccessController;
                    List<String> fieldsListQT = new List<String>{'ExAM__HelpText__c', 'ExAM__Question_Label__c', 'ExAM__Question_Order_No__c', 'ExAM__Question_Type__c', 'ExAM__Section_Question__c', 'ExAM__Subquestion_Label__c'};
                    accessQT.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Question_Template__c'), fieldsListQT);

                    //this returns all questions list in that section 
                    questionsLists = [
                        SELECT  HelpText__c, Id, Question_Label__c, Question_Order_No__c, Question_Type__c, Section_Question__c,
                                Subquestion_Label__c, (SELECT Id,Name FROM Answer_Options__r)
                        FROM Question_Template__c
                        WHERE Section_Question__c = :id ORDER BY Question_Order_No__c
                    ]; 
                    System.debug('----------------questions Returned : ' + questionsLists);
                }
                List<Id> questionIds = new List<Id>();
                if(questionsLists != NULL && questionsLists.size()>=1)
                { 
                    for(Question_Template__c qids:questionsLists)
                    {
                        questionIds.add(qids.id);
                        //System.debug('~~~~~~~~~id='+qids);
                    }
                }

                SFDCAccessController accessAnswer = ExAMUtilClass.AccessController;
                List<String> fieldsListAnswer = new List<String>{'ExAM__Account_to_Response__c', 'ExAM__Questionnaire_Taker_user__c', 'ExAM__Question_Template__c', 'ExAM__Response__c'};
                accessAnswer.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Questionnaire_Response__c'), fieldsListAnswer);

                //List<Questionnaire_Response__c> responseObjects = new List<Questionnaire_Response__c>(); 
                Questionnaire_Response__c[] responseObjectsAll = [
                    SELECT    Account_to_Response__c, Id, Questionnaire_Taker_user__c, Question_Template__c, Response__c
                    FROM      Questionnaire_Response__c
                    WHERE     Account_to_Response__c = :accountId AND Question_Template__c IN :questionIds
                    ORDER BY  Question_Template__r.Question_Order_No__c
                ] ;

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
                }*/
                //System.debug('Hhhhhhhhhhhhh~~~~~~~~~~~~~'+responseObjects);
                if((responseObjectsAll==null)||(responseObjectsAll.size()==0))
                {                  
                    //System.debug('~~~~~~~~444 allresponse is null  getquestionlist'); 

                    System.debug('---------q all response null list:'+questionsLists);
                    //iterate over and depending on question type,create a list from subquestion label. 
                    if(questionsLists !=NULL && questionsLists.size()>=1)
                    { 
                        for(Question_Template__c quest: questionsLists ) 
                        {
                            Questionnaire_Response__c resp=new Questionnaire_Response__c();          
                            List<SelectOption> options = new List<SelectOption>();         
                            if(quest.Question_Type__c.equalsIgnoreCase('RadioPicklist'))
                            {
                                if ( quest.Answer_Options__r != null && quest.Answer_Options__r.size() == 0 ){
                                    List<String> ls = new List<String>();
                                    if(quest.Subquestion_Label__c.contains('~')) {
                                        ls=quest.Subquestion_Label__c.split('~');
                                    } else {
                                        ls.add(quest.Subquestion_Label__c);
                                    }                 
                                    for(String s: ls) 
                                    {                   
                                    options.add(new SelectOption(s,s));                   
                                    }  
                                   
                                } else {
                                    if ( quest.Answer_Options__r.size() > 0 ){
                                        options = splitAnswerOptions(quest.Answer_Options__r);
                                    }
                                }
                                //RadioPicklistflag='true';
                                  
                                listQuestWithOptions.add(new QuestionDisplay(quest,options,resp,null) );   
                                i=1;         
                            } 
                            else if(quest.Question_Type__c.equalsIgnoreCase('Text'))
                            {
                                //Textflag='true';
                                System.debug('-----text:'); 
                                options.add(new SelectOption('none','none'));
                                listQuestWithOptions.add(new QuestionDisplay(quest,options,resp,null));             
                            }
                            else if(quest.Question_Type__c.equalsIgnoreCase('MultiselectPicklist'))
                            {
                                String[] multilist = new String[]{};
                                if ( quest.Answer_Options__r != null && quest.Answer_Options__r.size() == 0 ){
                                    List<String> ls = new List<String>();
                                    if(quest.Subquestion_Label__c.contains('~')) {
                                        ls=quest.Subquestion_Label__c.split('~');
                                    } else {
                                        ls.add(quest.Subquestion_Label__c);
                                    }
                                    for(String s: ls) 
                                    {                   
                                        options.add(new SelectOption(s,s));                   
                                    } 
                                    //MultiselectPicklistflag='true';
                                    
                                } else {
                                    if ( quest.Answer_Options__r.size() > 0 ){
                                        options = splitAnswerOptions(quest.Answer_Options__r);
                                    }
                                }
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
                    if(questionsLists !=NULL && questionsLists.size()>=1)
                    { 
                        for(Question_Template__c quest: questionsLists ) 
                        {
                            Questionnaire_Response__c resp=new Questionnaire_Response__c(); 
                            for(Questionnaire_Response__c res: responseObjectsAll ) 
                            {
                                if(quest.id==res.Question_Template__c)
                                {
                                    resp=res;break;
                                }
                            }
                            //Questionnaire_Response__c[] reponseObject=[Select id,Response__c,Question_Template__c,Account_to_Response__c,Questionnaire_Taker_user__c from Questionnaire_Response__c where Questionnaire_Taker_user__c= :UserInfo.getUserId() AND Question_Template__c=:quest.id] ;
                            //Questionnaire_Response__c[] reponseObject=[Select id,Response__c,Question_Template__c,Account_to_Response__c,Questionnaire_Taker_user__c from Questionnaire_Response__c where Account_to_Response__c= :accountId AND Question_Template__c=:quest.id] ;

                            /* if((reponseObject==null)||(reponseObject.size()==0))
                            {
                            }
                            else
                            {
                                resp=reponseObject[0];
                            }       */
                            List<SelectOption> options = new List<SelectOption>();         

                            if(quest.Question_Type__c.equalsIgnoreCase('RadioPicklist'))
                            {
                                if ( quest.Answer_Options__r != null && quest.Answer_Options__r.size() == 0 ){
                                    List<String> ls = new List<String>();
                                    if(quest.Subquestion_Label__c.contains('~')) {
                                        ls=quest.Subquestion_Label__c.split('~');
                                    } else {
                                        ls.add(quest.Subquestion_Label__c);
                                    }                  
                                    for(String s: ls) 
                                    {
                                        options.add(new SelectOption(s,s));                   
                                    }
                                } else {
                                    if ( quest.Answer_Options__r.size() > 0 ){
                                        options = splitansweroptions(quest.Answer_Options__r);
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
                                options.add(new SelectOption('none','none'));
                                System.debug('-----resptext:'+resp);
                                listQuestWithOptions.add(new QuestionDisplay(quest,options,resp,null));
                            }
                            else if(quest.Question_Type__c.equalsIgnoreCase('MultiselectPicklist'))
                            {
                                String[] multilist = new String[]{};
                                if ( quest.Answer_Options__r != null && quest.Answer_Options__r.size() == 0 ){
                                    List<String> ls = new List<String>();
                                    if(quest.Subquestion_Label__c.contains('~')) {
                                        ls=quest.Subquestion_Label__c.split('~');
                                    } else {
                                        ls.add(quest.Subquestion_Label__c);
                                    } 
                                    for(String s: ls) 
                                    {
                                        options.add(new SelectOption(s,s));
                                    }
                                    //MultiselectPicklistflag='true';
                                   
                                } else {
                                    if ( quest.Answer_Options__r.size() > 0 ){
                                        options = splitansweroptions(quest.Answer_Options__r);
                                    }
                                }
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
            System.debug('~~~~~~~~END   start  getquestionlist'+listQuestWithOptions); 
        }
        catch(Exception e) {
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()) );
        }
        return listQuestWithOptions;
    }

    //Added on 22-06-2017, for Answer option model. 
    public List<SelectOption> splitAnswerOptions(List<Answer_Option__c> ansOptList){
        List<SelectOption> options = new List<SelectOption>();
        List<String> ls = new List<String>();
        for( Answer_Option__c ansOpt :ansOptList ){
            if ( ansOpt.Name != null && ansOpt.Name != '' ){
                ls.add(ansOpt.Name);
            }
        }
        for(String s: ls) {
            options.add(new SelectOption(s,s));
        }
        return options;
    }

    public static testMethod void testlistacc()
    {
        //QuestionnaireFields d= new QuestionnaireFields();
        //Test.setCurrentPageReference(new PageReference('Page.QuestionnaireCustom')); 
        /*Account acct=new Account(name='testorgacct');
        insert acct;  */
        //Account ac=new Account();
        PageReference pageRef = Page.QuestionnaireCustom;
        Test.setCurrentPage(pageRef);
        //ApexPages.StandardController sc = new ApexPages.StandardSetController(c);
      
        QuestionnaireFieldsDOI d= new QuestionnaireFieldsDOI();      
        ApexPages.currentPage().getUrl();
      
        Main_questionaire__c maintest=new Main_questionaire__c (Template_name__c ='DOI');
        insert maintest; 
        System.currentPageReference().getParameters().put('TemplateName', maintest.Template_name__c ); 
        Account ac=new Account(name='test account1',Create_Survey__c=true);  
        ac.Main_Questionnaire_Template__c=maintest.id;
        Account ac1=new Account(name='test account2',Create_Survey__c=true,Adequate_Lighting_Score__c=5,Adequate_Locking_Score__c=5,CCTV_Score__c=5,Emergency_Response_Plan__c=5,Mail_Handling_Score__c=10); 
        ac1.Main_Questionnaire_Template__c=maintest.id;
        Account ac2=new Account(name='test account3'); 
        ac2.Main_Questionnaire_Template__c=maintest.id;
        insert ac;insert ac1;insert ac2;
     
         //Test when userSectionstatus is null  when survey is not taken yet or started   
         System.currentPageReference().getParameters().put('accId', ac.id);
     
        Section_Template__c sc= new Section_Template__c(Questionnaire_Section__c=maintest.id,Section_label__c='test section'); 
        insert sc;
        Section_Template__c sc1= new Section_Template__c(Questionnaire_Section__c=maintest.id,Section_label__c='test section 2'); 
        insert sc1;
        System.currentPageReference().getParameters().put('sectionId', sc.id);
        Question_Template__c scq= new Question_Template__c(Section_Question__c=sc.id,Question_Label__c='What is your name?',Question_Order_No__c=1,Question_Type__c='Text',Focus_category__c='CCTV');     
        Question_Template__c scqp= new Question_Template__c(Section_Question__c=sc.id,Question_Label__c='What is your age?',Question_Order_No__c=2,Question_Type__c='RadioPicklist',Subquestion_Label__c='10-30~31-50',Focus_category__c='Perimeter');     
        Question_Template__c scqm= new Question_Template__c(Section_Question__c=sc.id,Question_Label__c='What is your qualification?',Question_Order_No__c=3,Question_Type__c='MultiselectPicklist',Subquestion_Label__c='High School~Bachelors~Masters',Focus_category__c='Emergency Response Plan');     
        Question_Template__c scqp1= new Question_Template__c(Section_Question__c=sc.id,Question_Label__c='What is your age?',Question_Order_No__c=4,Question_Type__c='RadioPicklist',Subquestion_Label__c='10-30~31-50',Focus_category__c='Adequate Lighting');     
        Question_Template__c scqm1= new Question_Template__c(Section_Question__c=sc.id,Question_Label__c='What is your qualification?',Question_Order_No__c=5,Question_Type__c='MultiselectPicklist',Subquestion_Label__c='High School~Bachelors~Masters',Focus_category__c='Adequate Locking System');     
        Question_Template__c scqp2= new Question_Template__c(Section_Question__c=sc.id,Question_Label__c='What is your age?',Question_Order_No__c=6,Question_Type__c='RadioPicklist',Subquestion_Label__c='10-30~31-50',Focus_category__c='Mail Handling');     
  
        insert scq;insert scqp;insert scqm;insert scqp1;insert scqm1;insert scqp2;

        List<Question_Template__c> questionsLists = [SELECT  Id,Section_Question__c,Question_Label__c,Question_Order_No__c,Question_Type__c,HelpText__c,Subquestion_Label__c FROM Question_Template__c where Section_Question__c=:sc.id order by Question_Order_No__c]; 
        Test.startTest();
        d.sectionsStatusLists=null;
        d.setdoRerender(true); 
        d.sectionStatus();   
        //d.setdoRerender(true);   
        d.getquestionsList();  
        d.setdoRerenderSave(true);  
        d.save();  d.cancel();   d.exit();  

        //Test when userSectionstatus is not null,set school to have response    
        System.currentPageReference().getParameters().put('accId', ac1.id);
        Questionnaire_Response__c responseObject=new Questionnaire_Response__c(Response__c='John',Question_Template__c=scq.id,Account_to_Response__c=ac1.id);
        insert responseObject;   
        Main_Report_Data__c  reportd=new Main_Report_Data__c(Account__c=ac1.id, Question_Template__c=scq.id); 
        Main_Report_Data__c  reportd1=new Main_Report_Data__c(Account__c=ac1.id,Question_Template__c= scqp.id);
        Main_Report_Data__c  reportd2=new Main_Report_Data__c(Account__c=ac1.id, Question_Template__c=scqp1.id); 
        Main_Report_Data__c  reportd3=new Main_Report_Data__c(Account__c=ac1.id, Question_Template__c=scqp2.id); 
        Main_Report_Data__c  reportd4=new Main_Report_Data__c(Account__c=ac1.id, Question_Template__c=scqm1.id); 
        Main_Report_Data__c  reportd5=new Main_Report_Data__c(Account__c=ac1.id, Question_Template__c=scqm.id);   
        insert reportd;insert reportd1;insert reportd2;insert reportd3;insert reportd4;insert reportd5;
        //sc=[Select id from Section_Template__c limit 1];
        //System.currentPageReference().getParameters().put('sectionId', sc.id);
        d.setdoRerender(true);
        d.sectionStatus();
        d.getquestionsList();
        QuestionDisplay qd=new QuestionDisplay (questionsLists[0]);

        d.save();

        d.submitForApproval();

        System.currentPageReference().getParameters().put('sectionId', sc1.id);
        SectionStatus__c stat=new SectionStatus__c(User__c=UserInfo.getUserId(),Section_Template__c=sc1.id,Account_to_SectionStatus__c=ac1.id,status__c='Incomplete');
        insert stat;
        d.sectionStatus();
        d.getquestionsList();
        // QuestionDisplay qd=new QuestionDisplay (questionsLists[0]);
        
        // d.save();
    
        Test.stopTest();
        //assert results
        System.assert(ac!=null,'Account is not null');     
    }
}//main class end