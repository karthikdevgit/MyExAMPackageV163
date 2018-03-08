public with sharing class AssessmentTemplateUIController
{

    public string AccName { get; set; }
    public string templateId{get;set;}
    public string SelectedAccountId {set;get;}
    public string Accountname{set;get;}

    public Boolean myFlag{get;set;}
    public Boolean myFlagmulti{get;set;}

    public List<Account> allaccounts=new List<Account>();
    public List<Section_Group__c> groupList { get; set; }
    
    public AssessmentTemplateUIController(ApexPages.StandardSetController controller) {
        myFlag=false;myFlagmulti=false;
    }
    public Boolean pageMsg { get; set; }
    public AssessmentTemplateUIController() {
        pageMsg = true;
    }

    public List<Section_Group__c> getsecgrouplist()
    {
        List<Section_Group__c> groupList;
        try {

            SFDCAccessController accessSG = ExAMUtilClass.AccessController;
            List<String> fieldsListSG = new List<String>{'ExAM__Group_Name__c'};
            accessSG.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Section_Group__c'), fieldsListSG);

            groupList = new List<Section_Group__c>();
            groupList =[SELECT Id, Group_Name__c, Name FROM Section_Group__c ORDER BY Group_Name__c LIMIT 10000];
        }
        catch(Exception e) {
            groupList = new List<Section_Group__c>();
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()) );
        }
        return groupList;
    }

    public List<Main_questionaire__c> gettemplatesList() {
        List<Main_questionaire__c> templateList;
        try {

            SFDCAccessController accessAT = ExAMUtilClass.AccessController;
            List<String> fieldsListAT = new List<String>{'ExAM__Template_name__c'};
            accessAT.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Main_questionaire__c'), fieldsListAT);

            templateList = new List<Main_questionaire__c>();
            templateList = [SELECT Id, Template_name__c FROM Main_questionaire__c ORDER BY Template_name__c ASC LIMIT 1000];
        }
        catch(Exception e) {
            templateList = new List<Main_questionaire__c>();
            System.debug('except::::');
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()) );
        }
        return templateList;
    }

    public Section_Group__c grpObj
    {
        get{
            if(grpObj==null)
            {
                grpObj= new Section_Group__c ();
            }
            return grpObj;
        }
        set;
    }

    public Main_questionaire__c templateObj
    {
        get{
            if(templateObj==null)
            {
                templateObj= new Main_questionaire__c();
            }
            return templateObj;
        }
        set;
    }

    public List<SelectOption> AccountList
    {
        get
        {
            allaccounts = [SELECT Id, Name FROM Account WHERE (Create_Survey__c=:null OR Create_Survey__c=:false) AND (Main_Questionnaire_Template__c=:NULL) ORDER BY name];
            List<SelectOption> AccountList = new List<SelectOption>();
            AccountList.add(new SelectOption('None','None'));
            for(Account temp : allaccounts)
            {
                AccountList.add(new SelectOption(temp.Id, temp.Name));
            }
            return AccountList;
        }
        set;
    }

    /*
    public AssessmentTemplateUIController(ApexPages.standardController con)
    {
        templateObj=new Main_questionaire__c();
        templateObj=(Main_questionaire__c)con.getRecord();
        System.debug('222values in CONSTRUCTIRes'+templateObj.Template_name__c);
    }
    */

    public PageReference EditSurvey()
    {
        templateId = System.currentPageReference().getParameters().get('templateid');
        string urlform='/'+this.templateId;
        PageReference saveClicked=new PageReference(urlform);
        saveClicked.setRedirect(true);
        return saveClicked;
        //return null;
    }

    public PageReference save()
    {
        System.debug('!!!!!!!!!!!vales IN SAVE'+templateObj);
        string templateId;
        try
        {
            if(templateObj!=null)
            {                
                //System.debug('2222222222222222!!!!!!!!!!!vales IN SAVE'+templateObj);
                SFDCAccessController accessAT = ExAMUtilClass.AccessController;
                List<string> fieldsListAT = new List<string>{'ExAM__Description__c', 'ExAM__PublishPlace__c', 'ExAM__TemplateFlag__c', 'ExAM__Template_name__c', 'ExAM__Viewer_Configuration__c'};
                accessAT.assertAuthorizedToCreate(Schema.getGlobalDescribe().get('exam__Main_questionaire__c'), fieldsListAT);

                upsert templateObj;
                templateId = templateObj.Id;
            } 
            Account acc=new Account();
            if(Accountname==null)
            {
                //This is to create a hierarchy whenever a new  template is craeted we create an account object with the same label or label given by user and associate the parent org with this new template name or account name
                acc.name = templateObj.Template_name__c;
            }
            else
            {                
                acc.name = Accountname;
                System.debug('--------acc name:'+acc);
            }
            acc.name = templateObj.Template_name__c;
            acc.Main_Questionnaire_Template__c = templateId;

            if((SelectedAccountId==null)||(SelectedAccountId.equalsIgnoreCase('none')))
            { 
                System.debug('no parent acc'+acc);
                SFDCAccessController accessAcct = ExAMUtilClass.AccessController;
                List<string> fieldsListAcct = new List<string>{'ExAM__Main_Questionnaire_Template__c'};
                accessAcct.assertAuthorizedToCreate(Schema.getGlobalDescribe().get('Account'), fieldsListAcct);

                upsert acc;
            }
            else
            {
                List<Account> acctList = new List<Account>();
                for(Account parentAcc: allaccounts)
                {
                    string parentId=parentAcc.Id;
                    if(parentId.equalsIgnoreCase(SelectedAccountId))
                    {
                        System.debug('parentId:='+parentId+',SelectedAccountId='+SelectedAccountId);
                        acc.parentid=parentId;
                        System.debug('------'+acc+',,,'+parentAcc);
                        acctList.add( acc );
                        break;
                    }
                }
                if (acctList != null && acctList.size() > 0) {

                    SFDCAccessController accessAcct = ExAMUtilClass.AccessController;
                    List<string> fieldsListAcct = new List<string>{'ParentId'};
                    accessAcct.assertAuthorizedToUpdate(Schema.getGlobalDescribe().get('Account'), fieldsListAcct);

                    upsert acctList;
                }
            }
            string urlform='/';
            if(templateObj.id!=null)
            {
                urlform=urlform+templateObj.id;
            }
            /*
            PageReference saveClicked=new PageReference(urlform);
            saveClicked.setRedirect(true);
            return saveClicked;
            */
            PageReference cancelClicked=new PageReference('/apex/ExAM__AssessmentTemplateBuilder');
            cancelClicked.setRedirect(true);
            return cancelClicked;
        } catch(Exception e) {
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()) );
        }
        return null;
    }

    public PageReference saveMulti()
    {
        try {
            System.debug('!!!!!!!!!!!vales IN SAVE'+grpObj);
            if(grpObj!=null)
            {
                SFDCAccessController accessSG = ExAMUtilClass.AccessController;
                List<string> fieldsListSG = new List<string>{'ExAM__Group_Name__c'};
                accessSG.assertAuthorizedToCreate(Schema.getGlobalDescribe().get('exam__Section_Group__c'), fieldsListSG);
                accessSG.assertAuthorizedToUpdate(Schema.getGlobalDescribe().get('exam__Section_Group__c'), fieldsListSG);

                upsert grpObj;
                string urlform='/';
                if(grpObj.id!=null)
                {
                    urlform=urlform+grpObj.id;
                }
            }
            //PageReference saveClicked=new PageReference(urlform);
            PageReference saveClicked=new PageReference('/apex/ExAM__AssessmentTemplateBuilder');
            saveClicked.setRedirect(true);
            return saveClicked;
        }
        catch(Exception e) {
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()) );
        }
        return null;
    }

    public PageReference cancel()
    {
        string urlform='/apex/ExAM__AssessmentTemplateBuilder';
        PageReference saveClicked=new PageReference(urlform);
        saveClicked.setRedirect(true);
        return saveClicked;
    }

    public PageReference cloneTemp(){
        Map<string,Id> sectionMap = new Map<string,Id>();
        Map<string,Id> questionMap = new Map<string,Id>();
        Map<Id,List<Question_Template__c>> secIdWithQuesTempMap = new Map<Id,List<Question_Template__c>>();
        Map<Id,List<Answer_Option__c>> quesIdWithAnsOptMap = new Map<Id,List<Answer_Option__c>>();
        List<Section_Template__c> sectionList = new List<Section_Template__c>();
        Section_Template__c section = new Section_Template__c();
        List<Id> sectionIdList = new List<Id>();
        List<Id> quesIdList = new List<Id>();
        Main_questionaire__c assesTemp = new Main_questionaire__c();
        List<Question_Template__c> questionList = new List<Question_Template__c>();
        Question_Template__c question = new Question_Template__c();
        List<Answer_Option__c> ansOptList = new List<Answer_Option__c>();
        Answer_Option__c ansOptRec = new Answer_Option__c();
        templateId=System.currentPageReference().getParameters().get('templateid');
        System.debug('assesmmnst wizard:'+templateId);
        try{
            if(templateId != NULL){
    
                SFDCAccessController accessAT = ExAMUtilClass.AccessController;
                List<string> fieldsListAT = new List<string>{'ExAM__PublishPlace__c', 'ExAM__Template_name__c'};
                accessAT.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Main_questionaire__c'), fieldsListAT);
    
                for (Main_questionaire__c asses : [SELECT Id, Name, PublishPlace__c, Template_name__c FROM Main_questionaire__c WHERE Id =:templateId]){
                    assesTemp.Template_name__c = asses.Template_name__c+'-Clone';
                    assesTemp.PublishPlace__c = asses.PublishPlace__c;
                }
                System.debug('assesTemp:::::::'+assesTemp);
    
                SFDCAccessController accessCreateAT = ExAMUtilClass.AccessController;
                List<string> fieldsListCreateAT = new List<string>{'ExAM__PublishPlace__c', 'ExAM__Template_name__c'};
                accessCreateAT.assertAuthorizedToCreate(Schema.getGlobalDescribe().get('exam__Main_questionaire__c'), fieldsListCreateAT);
    
                insert assesTemp;
    
                SFDCAccessController accessST = ExAMUtilClass.AccessController;
                List<string> fieldsListST = new List<string>{'ExAM__Order_No__c', 'ExAM__Section_label__c', 'ExAM__Section_Weight__c'};
                accessST.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Section_Template__c'), fieldsListST);
    
                for(Section_Template__c sec : [SELECT Id,Name,Section_label__c,Section_Weight__c,Order_No__c FROM Section_Template__c WHERE Questionnaire_Section__r.Id =:templateId]){
                    sectionIdList.add(sec.Id);
                    section = new Section_Template__c();
                    section.Section_label__c = sec.Section_label__c;
                    section.Section_Weight__c = sec.Section_Weight__c;
                    section.Order_No__c = sec.Order_No__c;
                    section.Questionnaire_Section__c = assesTemp.Id;
                    sectionList.add(section);
                }
                System.Debug('sectionList::::::'+sectionList);
                if(sectionList != NULL && sectionList.size() > 0) {
    
                    SFDCAccessController accessCreateST = ExAMUtilClass.AccessController;
                    List<string> fieldsListCreateST = new List<string>{'ExAM__Order_No__c', 'ExAM__Questionnaire_Section__c', 'ExAM__Section_label__c', 'ExAM__Section_Weight__c'};
                    accessCreateST.assertAuthorizedToCreate(Schema.getGlobalDescribe().get('exam__Section_Template__c'), fieldsListCreateST);
    
                    insert sectionList;
                }
                Integer secLen = sectionList.size();
                for(Integer i = 0;i < secLen;i++){
                    sectionMap.put(sectionIdList[i],sectionList[i].Id);
                }
                System.Debug('sectionMap::::::::'+sectionMap);
    
                SFDCAccessController accessQT = ExAMUtilClass.AccessController;
                List<string> fieldsListQT = new List<string>{'ExAM__Question_Order_No__c', 'ExAM__Question_Label__c', 'ExAM__Question_Type__c', 'ExAM__Section_Question__c', 'ExAM__Subquestion_Label__c', 'ExAM__Weight_Of_Question__c'};
                accessQT.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Question_Template__c'), fieldsListQT);
    
                for(Question_Template__c ques :[SELECT Id,Name,Question_Order_No__c,Question_Label__c,Question_Type__c,Subquestion_Label__c,Weight_Of_Question__c,Section_Question__c FROM Question_Template__c WHERE Section_Question__r.Id IN :sectionIdList] ){
                    quesIdList.add(ques.Id);
                    question = new Question_Template__c();
                    question.Question_Label__c = ques.Question_Label__c;
                    question.Question_Type__c = ques.Question_Type__c;
                    question.Subquestion_Label__c = ques.Subquestion_Label__c;
                    question.Weight_Of_Question__c = ques.Weight_Of_Question__c;
                    question.Question_Order_No__c = ques.Question_Order_No__c;
                    question.Section_Question__c = sectionMap.get(ques.Section_Question__c );
                    questionList.add(question);
                }
                System.Debug('questionList::::::::'+questionList);
                if(questionList != NULL && questionList.size() > 0) {
    
                    SFDCAccessController accessCreateQT = ExAMUtilClass.AccessController;
                    List<string> fieldsListCreateQT = new List<string>{'ExAM__Question_Label__c', 'ExAM__Question_Order_No__c', 'ExAM__Question_Type__c', 'ExAM__Section_Question__c', 'ExAM__Subquestion_Label__c', 'ExAM__Weight_Of_Question__c'};
                    accessCreateQT.assertAuthorizedToCreate(Schema.getGlobalDescribe().get('exam__Question_Template__c'), fieldsListCreateQT);
    
                    insert questionList;
    
                    Integer quesLen = questionList.size();
                    for(Integer i = 0;i < quesLen;i++){
                        questionMap.put(quesIdList[i], questionList[i].Id);
                    }
    
                    SFDCAccessController accessAO = ExAMUtilClass.AccessController;
                    List<string> fieldsListAO = new List<string>{'ExAM__Dependent_Question__c', 'ExAM__Help_Text__c', 'ExAM__Next_Question__c', 'ExAM__Order_No__c', 'ExAM__Question_Template__c', 'ExAM__Weight__c'};
                    accessAO.assertAuthorizedToCreate(Schema.getGlobalDescribe().get('exam__Answer_Option__c'), fieldsListAO);
    
                    for(Answer_Option__c ansOpt :[SELECT Id,Name,Help_Text__c,Weight__c,Dependent_Question__c,Next_Question__c,Question_Template__c,Order_No__c FROM Answer_Option__c WHERE Question_Template__c = :quesIdList] ){
                        ansOptRec = new Answer_Option__c();
                        ansOptRec.Name = ansOpt.Name;
                        ansOptRec.Help_Text__c = ansOpt.Help_Text__c;
                        ansOptRec.Weight__c = ansOpt.Weight__c;
                        ansOptRec.Order_No__c = ansOpt.Order_No__c;
                        if ( ansOpt.Dependent_Question__c != null ){
                            ansOptRec.Dependent_Question__c = questionMap.get(ansOpt.Dependent_Question__c);
                        } else if ( ansOpt.Next_Question__c != null ){
                            ansOptRec.Next_Question__c = questionMap.get(ansOpt.Next_Question__c);
                        }
                        ansOptRec.Question_Template__c = questionMap.get(ansOpt.Question_Template__c);
                        ansOptList.add(ansOptRec);
                    }
                    if ( ansOptList != null && ansOptList.size() > 0 ) {
    
                        SFDCAccessController accessCreateAO = ExAMUtilClass.AccessController;
                        List<string> fieldsListCreateAO = new List<string>{'ExAM__Dependent_Question__c', 'ExAM__Help_Text__c', 'ExAM__Next_Question__c', 'ExAM__Order_No__c', 'ExAM__Question_Template__c', 'ExAM__Weight__c'};
                        accessCreateAO.assertAuthorizedToCreate(Schema.getGlobalDescribe().get('exam__Answer_Option__c'), fieldsListCreateAO);
    
                        insert ansOptList;
                    }
                }
            }
        }
        catch(Exception e){
            
            pageMsg = false;
            System.debug('test:pageMsg:::'+pageMsg);
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()) );
            return NULL;
        }
        return NULL;
    }

    /*
    public PageReference NewSurvey()
    {
        return null;
    }
    */
    @isTest
    public static void AssessmentTemplateUITest()
    {
        //Test converage for the visualforce page
        PageReference pageRef = Page.AssessmentTemplateUI;
        Test.setCurrentPageReference(pageRef);
        Test.startTest();
        Main_questionaire__c maintest=new Main_questionaire__c (Template_name__c ='test');
        upsert maintest;
        Main_questionaire__c[] accountList = [SELECT id,Template_name__c FROM Main_questionaire__c];
        System.debug('----INTEST'+accountList );
        Section_Group__c maintestg=new Section_Group__c(Group_Name__c ='test');
        //upsert maintestg;
        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(accountList);
        AssessmentTemplateUIController d= new AssessmentTemplateUIController(); 
        d.grpObj=maintestg;d.saveMulti();
        //When its null
        Main_questionaire__c maint=d.templateObj;
        d.save();
        System.assert(d.templateObj!=null,'template is not null and created');
        //When not null
        Main_questionaire__c maint2=new Main_questionaire__c (Template_name__c ='test');
        upsert maint2;
        d.templateObj=maint2;
        System.currentPageReference().getParameters().put('templateid', accountList[0].id);
        d.EditSurvey();
        d.Accountname=null;
        d.save();

        d.Accountname='testdata';
        d.save();
        System.assert(d.EditSurvey()!=null,'survey is not null and edited');
        d.SelectedAccountId=null;
        d.save();
        Account newAccount = new Account (name='XYZ Organization');
        insert newAccount;
        Account newAccount2 = new Account (name='XYZ2 Organization');
        insert newAccount2;
        d.SelectedAccountId=newAccount.id;
        d.save();
        List<SelectOption> AccList = d.AccountList;
        d.allaccounts=[SELECT id,name,parentid FROM Account];
        d.save();
        ApexPages.StandardSetController scc = new ApexPages.StandardSetController(d.allaccounts);

        d.cancel();
        System.assert(d.save()!=null,'save completed properly');
        Test.stopTest();
    }
}