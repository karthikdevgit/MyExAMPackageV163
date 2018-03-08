public with sharing class QuestionnaireFieldsSite {

    //this is extension class of Main_questionnaire template
    //TAke questionnaire field from section,question,question response,template
    public string message { get; set; }
    //public Id selectedTemplate { get; set; }
    //public Id selectedSection { get; set; }
    public List<Question_Template__c> questionsLists { get; set; }
    public List<Section_Template__c > sectionsLists{ get; set; }
    public List<Main_questionaire__c> templateLists { get; set; }
    public List<SectionStatus__c > sectionsStatusLists{ get; set; }
    public Account acc{get;set;}
    //public Set<Id> sectionIds{get;set;}
    public string templateName{get;set;}
    public string sectionId{get;set;}
    public string accountId{get;set;}
    public List<Questionnaire_Response__c> QuestionResponse{get;set;}
    public List<QuestionDisplay> listQuestWithOptions;  
    public QuestionDisplay[] listQuestWithText;       
    //public PageReference refresh=ApexPages.currentPage();
    //Apexpages.currentPage().getHeaders().put('X-UA-Com​patible', 'IE=8');
    public PageReference refresh= new PageReference(ApexPages.currentPage().getUrl());
    public Boolean refreshPagePart{get;set;}
    private Boolean theToggleVal = false;
    static integer ltoggle=0;
    private Boolean theToggleValApproval = false;
    static integer ltoggleApproval=0;
    public Transient Boolean doRerender; 
    public Transient Boolean doRerenderSave; 
    public Boolean getdoRerender(){return doRerender;}
    public Boolean getdoRerenderSave(){return doRerenderSave;}
    //added for not doing DMl in constructor
    public Boolean myFlag{get; set;}
    public void setmyFlag(Boolean flags) {
        this.myFlag = flags;
    }

    public void setdoRerender(Boolean doRerender) {
        this.doRerender = doRerender;
        System.debug('doRerender should be set here to true: doRerender = '+this.doRerender);
    } 

    public void setdoRerenderSave(Boolean doRerenderSave) {
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
   
    public QuestionnaireFieldsSite(ApexPages.StandardSetController controller) {
        refreshPagePart=false;System.debug('in constructor'); //Apexpages.currentPage().getHeaders().put('X-UA-Compatible', 'IE=8');
        //sectionStatus();
    }
    public QuestionnaireFieldsSite(){//Apexpages.currentPage().getHeaders().put('X-UA-Compatible', 'IE=8');
    }
 
    public void sectionStatus() 
    {
        try {
            myFlag=false;
            theToggleVal =false;theToggleValApproval=false;
            if (!myFlag) {     

                SectionStatus__c[] StatusLists=new SectionStatus__c[]{};   //setinitialised(true); 
                accountId=System.currentPageReference().getParameters().get('accId');//to get the school or account id
                System.debug('!!!!!!!!!!!!!!!!~~~~~~~~~~~~status ~acct id from diff page :'+accountId);
                //List<Account> cm= [SELECT id,name,Main_Questionnaire_Template__c,Main_Questionnaire_Template__r.Template_name__c,Create_Survey__c From Account where Create_Survey__c=:true ];
                //System.debug('!!!!!!!!!!!!!!!!~'+cm);

                SFDCAccessController accessForAcct = ExAMUtilClass.AccessController;

                List<String> fieldsListAcctAT = new List<String>{'ExAM__Template_name__c'};
                accessForAcct.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Main_questionaire__c'), fieldsListAcctAT);

                List<string> fieldsListAcct = new List<string>{'ExAM__Create_Survey__c', 'ExAM__Main_Questionnaire_Template__c'};
                accessForAcct.assertAuthorizedToView(Schema.getGlobalDescribe().get('Account'), fieldsListAcct);

                acc= [SELECT Create_Survey__c, Id, Main_Questionnaire_Template__c, Main_Questionnaire_Template__r.Template_name__c, Name FROM Account WHERE Create_Survey__c = :true AND id = :accountId LIMIT 1];
                System.debug('!!!!!!!!!!!!!!!!~~~~~~~~~~~~status ~acct id from diff page :'+acc);
                //templateName=System.currentPageReference().getParameters().get('TemplateName');

                SFDCAccessController accessForAT = ExAMUtilClass.AccessController;
                List<string> fieldsListAT = new List<string>{'ExAM__Template_name__c'};
                accessForAT.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Main_questionaire__c'), fieldsListAT);

                templateLists = [SELECT Id, Name, Template_name__c FROM Main_questionaire__c WHERE Template_name__c = :acc.Main_Questionnaire_Template__r.Template_name__c];
                if(templateLists!=NULL && templateLists.size()>=1)
                {
                    templateName = templateLists.get(0).Name;   

                    SFDCAccessController accessForST = ExAMUtilClass.AccessController;
                    List<string> fieldsListST = new List<string>{'ExAM__Order_No__c', 'ExAM__Status__c', 'ExAM__Section_label__c'};
                    accessForST.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Section_Template__c'), fieldsListST);

                    sectionsLists = [SELECT Id, Name, Order_No__c, Status__c, Section_label__c FROM Section_Template__c WHERE Questionnaire_Section__c = :templateLists.get(0).Id ORDER BY Order_No__c];
                    //iterate the sectionstatus table and we should remove userinfo check as there will always be 1 survey per account

                    SFDCAccessController accessForSS = ExAMUtilClass.AccessController;
                    List<string> fieldsListSS = new List<string>{'ExAM__Account_to_SectionStatus__c', 'ExAM__Section_Template__c', 'ExAM__Status__c', 'ExAM__User__c'};
                    accessForSS.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__SectionStatus__c'), fieldsListSS);

                    SectionStatus__c[] userSectionStatus=[SELECT Account_to_SectionStatus__c, Id, Section_Template__c, Status__c, User__c FROM SectionStatus__c WHERE Account_to_SectionStatus__c= :accountId] ;
                    System.debug('~~~~~~~~11111~sectionstatus~~~~~~~~~~~~'+userSectionStatus.size());
                    //System.debug('sectionsLists ----'+sectionsLists.size());
                    // System.debug('~~~~~~~~~~~~~size both at top'+userSectionStatus.size()+',,,sec'+sectionsLists.size());

                    if((userSectionStatus==null)||(userSectionStatus.size()==0))
                    {                   
                        System.debug('~~~~~~~~~~~~~COMES IN SECTION STATUS');
                        for(Section_Template__c res: sectionsLists ) 
                        {

                            SectionStatus__c stat = new SectionStatus__c();
                            stat.User__c = UserInfo.getUserId();
                            stat.Account_to_SectionStatus__c = accountId;
                            stat.Section_Template__c = res.id; 
                            stat.status__c = 'Incomplete';
                            //stat.Section_StatusLabel__c=res.Section_Label__c;  
                            System.debug('~~~~~~~~~~~~~default controller------'+stat);
                            StatusLists.add( stat );
                        }

                        SFDCAccessController accessSS1 = ExAMUtilClass.AccessController;
                        List<string> fieldsListSS1 = new List<string>{'ExAM__Account_to_SectionStatus__c', 'ExAM__Section_Template__c', 'ExAM__Status__c', 'ExAM__User__c'};
                        accessSS1.assertAuthorizedToCreate(Schema.getGlobalDescribe().get('exam__SectionStatus__c'), fieldsListSS1);
                        accessSS1.assertAuthorizedToUpdate(Schema.getGlobalDescribe().get('exam__SectionStatus__c'), fieldsListSS1);

                        upsert StatusLists;
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
                                {i=1; System.debug('~~both are equal~~~~~~~~~'+res.id+'status'+statusobj.Section_Template__c);break;}
                            }
                            if(i==0)
                            {
                                SectionStatus__c stat=new SectionStatus__c();
                                stat.User__c=UserInfo.getUserId();
                                stat.Section_Template__c= res.id;
                                stat.Account_to_SectionStatus__c=accountId; 
                                stat.status__c='Incomplete';
                                //stat.Section_StatusLabel__c=res.Section_Label__c;  
                                //System.debug('~~~~~~~~~~~~~add new status default controller------'+stat);
                                StatusLists.add(stat);
                            }
                            i=0;                                               
                        }

                        SFDCAccessController accessSS2 = ExAMUtilClass.AccessController;
                        List<string> fieldsListSS2 = new List<string>{'ExAM__Account_to_SectionStatus__c', 'ExAM__Section_Template__c', 'ExAM__Status__c', 'ExAM__User__c'};
                        accessSS2.assertAuthorizedToCreate(Schema.getGlobalDescribe().get('exam__SectionStatus__c'), fieldsListSS2);
                        accessSS2.assertAuthorizedToUpdate(Schema.getGlobalDescribe().get('exam__SectionStatus__c'), fieldsListSS2);

                        upsert StatusLists;
                    }
                    else if(userSectionStatus.size()>sectionsLists.size())
                    {   //extra section status
                        integer i=0;
                        List<SectionStatus__c> deleteSectionStatus=new List<SectionStatus__c>();
                        for(SectionStatus__c statusobj: userSectionStatus) 
                        {
                            for(Section_Template__c res: sectionsLists ) 
                            {
                                if(res.id==statusobj.Section_Template__c)
                                {i=1;break;}
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
                    }
                    // sectionsStatusLists=[Select id,Section_Template__c,Section_Template__r.id,Section_Template__r.Section_Label__c,Status__c,User__c from SectionStatus__c where User__c= :UserInfo.getUserId()] ;
                    //sectionsStatusLists=[Select id,Section_Template__c,Section_Template__r.id,Section_Template__r.Section_Label__c,Section_Template__r.Order_No__c,stat.Account_to_SectionStatus__c,Status__c,User__c from SectionStatus__c where User__c= :UserInfo.getUserId() AND (Section_Template__c!=null) order by Section_Template__r.Order_No__c] ;

                    SFDCAccessController accessForSS3 = ExAMUtilClass.AccessController;

                    List<String> fieldsListSS3ST = new List<String>{'ExAM__Order_No__c', 'ExAM__Section_Label__c'};
                    accessForSS3.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Section_Template__c'), fieldsListSS3ST);

                    List<string> fieldsListSS3 = new List<string>{'ExAM__Account_to_SectionStatus__c', 'ExAM__Section_Template__c', 'ExAM__Status__c', 'ExAM__User__c'};
                    accessForSS3.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__SectionStatus__c'), fieldsListSS3);

                    sectionsStatusLists=[
                        SELECT Account_to_SectionStatus__c, Id, Section_Template__c, Section_Template__r.Order_No__c,
                               Section_Template__r.Section_Label__c, Status__c, User__c
                        FROM   SectionStatus__c
                        WHERE  Account_to_SectionStatus__c = :accountId AND (Section_Template__c!=null) 
                               ORDER BY Section_Template__r.Order_No__c
                    ] ;
                    System.debug('~~~~~~~222  section sttus~~~~~~final section list SECTION STATUS LIST----'+sectionsStatusLists);

                    // To set the focus category scores for the account
                    /*List<aggregateResult> aggr=[
                        Select Account__c, Question_Template__r.Focus_category__c focus,
                               SUM(Questionnaire_Response__r.Total_Score__c)total
                        from   Main_Report_Data__c
                        where Account__c = :accountId GROUP BY Account__c,Question_Template__r.Focus_category__c
                    ];
                    Account acc= [SELECT id,name,Adequate_Lighting_Score__c,Adequate_Locking_Score__c,CCTV_Score__c,Emergency_Response_Plan__c,Mail_Handling_Score__c,Overall_Score__c,Perimeter_Score__c,Create_Survey__c From Account where Create_Survey__c=:true AND id=:accountId];
                    if(acc!=null)
                    {
                        acc.Overall_Score__c=0;
                        integer b=0;
                        for(SectionStatus__c res: sectionsStatusLists) 
                        {
                            if(res.status__c.equalsIgnoreCase('complete'))
                            {b++;System.debug('!!!!!!!!!!!!!!!!!!b='+b+','+ res.status__c);}
                        }
                        if(b==4)
                        {
                            System.debug('!!!!!!!!!!!!!!!!!!b val:'+b);
                            acc.Survey_Completed__c='Complete';
                        }
                       for (AggregateResult ar : aggr)
                       {
                            string focuscat=string.valueOf(ar.get('focus')); 
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
                        }
                    }    
                    System.debug('~~~~~~~~~~~~~~~~~~~~~~~ main report data'+acc);
                try{
                    upsert acc;
                }catch(Exception e){}*/
                }
                myFlag=true;
            }   
        }catch(Exception e){
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()) );
        }
    }   

    public PageReference save()
    {
        System.debug('IN MAIN SAVE METHOD '+accountId);
        try{
            if((this.doRerenderSave!=null)||(this.doRerenderSave!=false))
            {           
                //SectionStatus__c[] userSectionStatus=[Select id,Section_Template__c,Status__c,User__c from SectionStatus__c where User__c= :UserInfo.getUserId()AND Section_Template__c =:listQuestWithOptions[0].newquestFormat.Section_Question__c] ;

                SFDCAccessController accessForSS = ExAMUtilClass.AccessController;
                List<string> fieldsListSS = new List<string>{'ExAM__Account_to_SectionStatus__c', 'ExAM__Section_Template__c', 'ExAM__Status__c', 'ExAM__User__c'};
                accessForSS.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__SectionStatus__c'), fieldsListSS);

                SectionStatus__c[] userSectionStatus = [
                    SELECT Account_to_SectionStatus__c, Id, Section_Template__c, Status__c, User__c
                    FROM   SectionStatus__c
                    WHERE  Account_to_SectionStatus__c = :accountId AND Section_Template__c = :listQuestWithOptions[0].newquestFormat.Section_Question__c
                ];
                //System.debug('IN MAIN SAVE METHOD section status~~~~~~~~~~~~~'+userSectionStatus);
                if((userSectionStatus==null)||(userSectionStatus.size()==0))
                {                   

                    SFDCAccessController accessSS3 = ExAMUtilClass.AccessController;
                    List<string> fieldsListSS3 = new List<string>{'ExAM__Account_to_SectionStatus__c', 'ExAM__Section_Template__c', 'ExAM__Status__c', 'ExAM__User__c'};
                    accessSS3.assertAuthorizedToCreate(Schema.getGlobalDescribe().get('exam__SectionStatus__c'), fieldsListSS3);

                    System.debug('!!!!~~~~~~~~~~~~~SHOULD NEVER COME HERE EVER');
                    SectionStatus__c stat=new SectionStatus__c();
                    stat.User__c=UserInfo.getUserId();
                    stat.Account_to_SectionStatus__c=accountId; 
                    stat.Section_Template__c=  listQuestWithOptions[0].newquestFormat.Section_Question__c; 
                    stat.status__c='Complete';    
                    System.debug('~~~~~~~~~~~~~in save section status------'+stat);
                    upsert stat;                    
                }
                else
                {
                    System.debug('else in~~~~~~~~~~~~~'+userSectionStatus);
                    System.debug('~~~~~~~~~~~~~Record already exists put code for edit');

                    SFDCAccessController accessSS4 = ExAMUtilClass.AccessController;
                    List<string> fieldsListSS4 = new List<string>{'ExAM__Status__c'};
                    accessSS4.assertAuthorizedToUpdate(Schema.getGlobalDescribe().get('exam__SectionStatus__c'), fieldsListSS4);

                    userSectionStatus[0].Status__c='Complete';
                    upsert userSectionStatus;
                }

                //System.debug('---------------- : in Save : ' + listQuestWithOptions);
                System.debug('~~~~---------------- : in Save : ' + listQuestWithOptions[0].newquestFormat.Section_Question__c);                

                SFDCAccessController accessAnswerSave = ExAMUtilClass.AccessController;

                List<string> fieldsListAnswerCreate = new List<string>{'ExAM__Account_to_Response__c', 'ExAM__Question_Template__c', 'ExAM__Questionnaire_Taker_user__c', 'ExAM__Response__c', 'ExAM__Weight_Response__c'};
                accessAnswerSave.assertAuthorizedToCreate(Schema.getGlobalDescribe().get('exam__Questionnaire_Response__c'), fieldsListAnswerCreate);

                List<string> fieldsListAnswerUpdate = new List<string>{'ExAM__Account_to_Response__c', 'ExAM__Questionnaire_Taker_user__c', 'ExAM__Response__c', 'ExAM__Weight_Response__c'};
                accessAnswerSave.assertAuthorizedToUpdate(Schema.getGlobalDescribe().get('exam__Questionnaire_Response__c'), fieldsListAnswerUpdate);

                if (listQuestWithOptions != null && listQuestWithOptions.size() > 0) {
                    //System.debug('~~~~~~~~~~in save account id:'+accountId);                
                    QuestionDisplay t = new QuestionDisplay(); 
                    t.innerSave(listQuestWithOptions, accountId);
                }
                System.debug(' ----------------Record saved successfully : ');
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO, 'Record saved successfully');
                ApexPages.addMessage(myMsg);
                refreshPagePart=true; theToggleValApproval=true;//myFlag=true; 
            }//if dorender is not null         
            // refresh.setRedirect(true);
            System.debug('!!!!!!!!!!!!!!!!!!!!!REFRESH IN SAVE:'+refresh);

            string urlform='/apex/QuestionnaireCustomSite?accId='+accountId;
            PageReference saveClicked=new PageReference(urlform);
            saveClicked.setRedirect(true);
            // return refresh;
            return saveClicked;
        }catch(Exception e){
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()) );
        }
        return null;
    }

    public PageReference submitForApproval() {

        try{
            Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
            req1.setComments('Submitting request for approval.');
            System.debug(' SUMIT FOR APPROVAl-----------');
            accountId=System.currentPageReference().getParameters().get('accId');//to get the school or account id     
            req1.setObjectId(accountId);
            System.debug(' SUMIT FOR APPROVAl-----------'+accountId);

            Id syadmin=[select id from profile where name='System Administrator'].id;
            if(syadmin!=null)
            {

                SFDCAccessController accessForUser = ExAMUtilClass.AccessController;
                List<string> fieldsListUser = new List<string>{'ProfileId'};
                accessForUser.assertAuthorizedToView(Schema.getGlobalDescribe().get('User'), fieldsListUser);

                ID elect = [select id,ProfileId from user where ProfileId=:syadmin LIMIT 1].id;
                req1.setNextApproverIds(new Id[] {elect});
                Approval.ProcessResult result = Approval.process(req1); 
                System.debug(' SUMIT FOR APPROVAl----result -------'+result );
                System.assert(result.isSuccess());  

                PageReference cancelClicked=new PageReference('http://EXAM4SCHOOLS.COM/');
                cancelClicked.setRedirect(false);
                return cancelClicked;   
            }
        }catch(Exception e){
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()) );
        }
        return null;
    }
    public PageReference cancel()
    {
        //PageReference cancelClicked=new PageReference('/apex/QuestionnaireCustom');
        PageReference cancelClicked=new PageReference('http://EXAM4SCHOOLS.COM/');
        cancelClicked.setRedirect(false);
        return cancelClicked;  
    }
    public PageReference exit() {
        PageReference cancelClicked=new PageReference('http://EXAM4SCHOOLS.COM/');
        cancelClicked.setRedirect(true);
        return cancelClicked;  
    }
    //create a new inner class so that we can add the flags for each record and display/create the questions as checklist/text/piclist etc.
    public class QuestionDisplay
    {
        //each record is sent to the visualforce frontend page iteratively through class vaiable.        
        //SELECT  Id,Question_Label__c,Question_Order_No__c,Question_Type__c,Subquestion_Label__c FROM Question_Template__c where Section_Question__r.id=:id order by Question_Order_No__c];         
        public Question_Template__c newquestFormat{get;set;}
        public Questionnaire_Response__c resObj{get;set;}
        public string questionFlag{get;set;}//default
        public List<SelectOption> optionsList{get;set;} 
        public string sectionLabel{get;set;}
        public string acctId{get;set;}        

        public QuestionDisplay(Question_Template__c question,List<SelectOption> subQuestionOption,Questionnaire_Response__c responseObj)
        {
            newquestFormat = new Question_Template__c();
            optionsList=new List<SelectOption>(); 
            resObj = new Questionnaire_Response__c();       
            this.newquestFormat=question;
            this.resObj=responseObj;
            //this.sectionLabel=sectionLabels;
            this.optionsList=subQuestionOption;
        }
        public QuestionDisplay(Question_Template__c question)
        {
            this.newquestFormat=question;
        }
        public QuestionDisplay() {}
        /*public void statusSection()
        {             
        }*/
        public void innerSave(List<QuestionDisplay> qdisplist, string accountId) {

            System.debug('INNER SAVE CALLED');
            //upsert newquestFormat;
            acctId=accountId;                

            SFDCAccessController accessForAnswer = ExAMUtilClass.AccessController;
            List<string> fieldsListAnswer = new List<string>{'ExAM__Account_to_Response__c', 'ExAM__Question_Template__c', 'ExAM__Questionnaire_Taker_user__c', 'ExAM__Response__c'};
            accessForAnswer.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Questionnaire_Response__c'), fieldsListAnswer);

            List<Questionnaire_Response__c> upsertAnswerList = new List<Questionnaire_Response__c>();
            Set<Id> qtnIdSet = new Set<Id>();
            for (QuestionDisplay qtn : qdisplist) {
                qtnIdSet.add( qtn.newquestFormat.Id );
            }

            //logic to either create a new record or update if it alraedy exists,if question id and user id same than update elase create new
            Questionnaire_Response__c[] reponseObject = [
                SELECT Account_to_Response__c, Id, Question_Template__c, Questionnaire_Taker_user__c, Response__c
                FROM   Questionnaire_Response__c
                WHERE  Account_to_Response__c = :accountId AND Question_Template__c IN :qtnIdSet
            ]; 
            //System.debug('Hhhhhhhhhhhhh~~~~~~~~~~~~~'+reponseObject);
            if((reponseObject==null)||(reponseObject.size()==0))
            {
                System.debug('create new record');

                for (QuestionDisplay qtn : qdisplist) {

                    Questionnaire_Response__c resObj = new Questionnaire_Response__c();
                    resObj.Question_Template__c = qtn.newquestFormat.Id;
                    resObj.Questionnaire_Taker_user__c = UserInfo.getUserId();
                    System.debug('!!!!!!!!!!!~~~~~~~~~~!!!!!!!!!!!new record account'+accountId);
                    resObj.Account_to_Response__c = accountId; 
                    resObj.Weight_Response__c = 1;//put some logic for future
                    upsertAnswerList.add( resObj );
                }
                if (upsertAnswerList != null && upsertAnswerList.size() > 0) {
                    upsert upsertAnswerList;
                }
            }
            else
            {
                System.debug('else in~~~~~~~~~~~~~'+reponseObject);
                System.debug('~~~~~~~~~~~~~Record already exists put code for edit');
                /* reponseObject[0].Response__c=resObj.Response__c;
                upsert reponseObject;*/
                // if((reponseObject[0].Response__c).equalsIgnoreCase(resObj.Response__c))
                //  {//The response is same as before so dont update in database
                //     System.debug('~~~~~~~~~~~~~~~~~~~~~~~ comes here is response is same as before');
                //  }
                //   else
                //   {
                if ( resObj != null && resObj.Response__c != null && resObj.Response__c != '' ){
                    reponseObject[0].Response__c=resObj.Response__c;
                }
                
                    upsert reponseObject;
                
                //  }
            }
        }
    }//end inner class

    public List<QuestionDisplay> getquestionsList()
    {
        try {
            string accountId=System.currentPageReference().getParameters().get('accId'); //accId=accountId;
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
                listQuestWithOptions= new QuestionDisplay[]{};
                listQuestWithText= new QuestionDisplay[]{};
                Id id = System.currentPageReference().getParameters().get('sectionId');
                sectionId=id; 
        
                System.debug('!!!!!! id of accountId in get quetsion list:'+accountId);
                System.debug('~~~~~~~~333 start  getquestionlist'); 
                if(id==null) {}
                else
                {

                    SFDCAccessController accessForQT = ExAMUtilClass.AccessController;
                    List<string> fieldsListQT = new List<string>{'ExAM__HelpText__c', 'ExAM__Question_Label__c', 'ExAM__Question_Order_No__c', 'ExAM__Question_Type__c', 'ExAM__Subquestion_Label__c', 'ExAM__Section_Question__c'};
                    accessForQT.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Question_Template__c'), fieldsListQT);

                    //this returns all questions list in that section 
                    questionsLists = [SELECT HelpText__c, Id, Question_Label__c, Question_Order_No__c, Question_Type__c, Section_Question__c,
                                     Subquestion_Label__c, (SELECT Id,Name FROM Answer_Options__r)
                                     FROM Question_Template__c
                                     WHERE Section_Question__c = :id
                                     ORDER BY Question_Order_No__c]; 
                    //System.debug('----------------questions Returned : ' + questionsLists);
                }
                List<Id> questionIds = new List<Id>();
                if(questionsLists !=NULL && questionsLists.size()>=1)
                { 
                    for(Question_Template__c qids:questionsLists)
                    {
                        questionIds.add(qids.id);
                        //System.debug('~~~~~~~~~id='+qids);
                    }
                }

                SFDCAccessController accessForAnswer = ExAMUtilClass.AccessController;
                List<string> fieldsListAnswer = new List<string>{'ExAM__Account_to_Response__c', 'ExAM__Question_Template__c', 'ExAM__Questionnaire_Taker_user__c', 'ExAM__Response__c'};
                accessForAnswer.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Questionnaire_Response__c'), fieldsListAnswer);

                //List<Questionnaire_Response__c> responseObjects = new List<Questionnaire_Response__c>(); 
                Questionnaire_Response__c[] responseObjectsAll = [
                    SELECT Account_to_Response__c, Id, Question_Template__c, Questionnaire_Taker_user__c, Response__c
                    FROM   Questionnaire_Response__c
                    WHERE  Account_to_Response__c = :accountId AND Question_Template__c IN :questionIds
                           ORDER BY Question_Template__r.Question_Order_No__c
                ];
   
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
                            if(quest.Question_Type__c=='RadioPicklist')
                            {
                                if ( quest.Answer_Options__r != null && quest.Answer_Options__r.size() == 0 ){
                                    List<String> ls = new List<String>();
                                    if(quest.Subquestion_Label__c.contains('~')) {
                                        ls=quest.Subquestion_Label__c.split('~');
                                    } else {
                                        ls.add(quest.Subquestion_Label__c);
                                    }                  
                                    for(string s: ls) 
                                    {                   
                                        options.add(new SelectOption(s,s));                   
                                    }  
                                    //RadioPicklistflag='true';
                                      
                                } else {
                                    if ( quest.Answer_Options__r.size() > 0 ){
                                        options = splitansweroptions(quest.Answer_Options__r);
                                    }
                                }
                                listQuestWithOptions.add(new QuestionDisplay(quest,options,resp) );   
                                i=1;         
                            } 
                            else if(quest.Question_Type__c=='Text')
                            {
                                 //Textflag='true';
                                 System.debug('-----text:'); 
                                 options.add(new SelectOption('none','none'));
                                 listQuestWithOptions.add(new QuestionDisplay(quest,options,resp));             
                            }
                            /* else if(quest.Question_Type__c=='MultiselectPicklist')
                            {
                                string qoptionValues=quest.Subquestion_Label__c;
                                List<string> ls=qoptionValues.split('~'); 
                                for(string s: ls) 
                                {                   
                                options.add(new SelectOption(s,s));                   
                                } 
                                //MultiselectPicklistflag='true';
                                System.debug('-----radio picklist:'+   qoptionValues); 
                                listQuestWithOptions.add(new QuestionDisplay(quest,options,resp) ); 
                                i=1;             
                            }    */
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
                            /* if((reponseObject==null)||(reponseObject.size()==0)) {}
                            else {
                                resp=reponseObject[0];
                            }*/
                            List<SelectOption> options = new List<SelectOption>();         
                            if(quest.Question_Type__c=='RadioPicklist')
                            {    
                                if ( quest.Answer_Options__r != null && quest.Answer_Options__r.size() == 0 ){
                                    List<String> ls = new List<String>();
                                    if(quest.Subquestion_Label__c.contains('~')) {
                                        ls=quest.Subquestion_Label__c.split('~');
                                    } else {
                                        ls.add(quest.Subquestion_Label__c);
                                    }                 
                                    for(string s: ls) 
                                    {                   
                                        options.add(new SelectOption(s,s));                   
                                    }  
                                    //RadioPicklistflag='true';
                                } else {
                                    if ( quest.Answer_Options__r.size() > 0 ){
                                        options = splitansweroptions(quest.Answer_Options__r);
                                    }
                                }
                                System.debug('-----picklistresp:'+resp);  
                                listQuestWithOptions.add(new QuestionDisplay(quest,options,resp) );   
                                i=1;         
                            }
                            else if(quest.Question_Type__c=='Text')
                            {
                                //Textflag='true';
                                System.debug('-----text:'); 
                                options.add(new SelectOption('none','none'));
                                System.debug('-----resptext:'+resp);
                                listQuestWithOptions.add(new QuestionDisplay(quest,options,resp));             
                            }
                            /* else if(quest.Question_Type__c=='MultiselectPicklist')
                            {
                                string qoptionValues=quest.Subquestion_Label__c;
                                List<string> ls=qoptionValues.split('~'); 
                                for(string s: ls) 
                                {                   
                                    options.add(new SelectOption(s,s));                   
                                } 
                                //MultiselectPicklistflag='true';
                                System.debug('-----radio picklist:'+   qoptionValues); 
                                listQuestWithOptions.add(new QuestionDisplay(quest,options,resp) ); 
                                i=1;
                            }*/        
                            //} 
                        }              
                    }
                }
            }
            System.debug('~~~~~~~~END   start  getquestionlist'+listQuestWithOptions);
        }
        catch(Exception e ) {
            //System.debug('::::::::exception message::::'+e.getMessage());
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
        PageReference pageRef = Page.QuestionnaireCustomSite;
        Test.setCurrentPage(pageRef);
        //ApexPages.StandardController sc = new ApexPages.StandardSetController(c);

        QuestionnaireFieldsSite d= new QuestionnaireFieldsSite();      
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

        List<Question_Template__c> questionsLists = [SELECT  Id, Section_Question__c, Question_Label__c, Question_Order_No__c, Question_Type__c, HelpText__c, Subquestion_Label__c FROM Question_Template__c where Section_Question__r.id=:sc.id order by Question_Order_No__c]; 
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