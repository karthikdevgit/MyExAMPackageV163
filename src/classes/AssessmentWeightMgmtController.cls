public with sharing class AssessmentWeightMgmtController {

    public string wtTemplate{get;set;}
    public string sectionScore{get;set;}
    public string templateName{get;set;}
    public string templateid{get;set;}
    public string sectionid{get;set;}

    public List<Question_Template__c> questionsLists { get; set; }
    public List<Section_Template__c > sectionsLists{ get; set; }
    public List<SelectOption> templateLists { get; set; }
    public List<SelectOption> sectionOptionLists { get; set; }
    public List<Main_questionaire__c> alltemplateLists { get; set; }

    public Map<Id, string> quesIdwithTempMap;
    
    public AssessmentWeightMgmtController(ApexPages.StandardController controller) {

        try {

            templateLists =new List<SelectOption>();
            sectionOptionLists =new List<SelectOption>();
            /*
            Schema.DescribeFieldResult wttemplates = Main_questionaire__c.Weight_Template__c.getDescribe();
            List<Schema.PicklistEntry> wttemplatesValues = wttemplates.getPicklistValues();
            System.debug('~~~4 '+wttemplatesValues);
            wttemplateLists.add(new SelectOption('None','None'));
            for (Schema.PicklistEntry a : wttemplatesValues)
            {
                System.debug('~~~3 '+a.getLabel()+ a.getValue());
                wttemplateLists.add(new SelectOption(a.getLabel(), a.getValue()));
            }
            */

            SFDCAccessController accessAT = ExAMUtilClass.AccessController;
            List<String> fieldsListAT = new List<String>{'ExAM__Template_name__c', 'ExAM__Score_By_Section_Weight__c', 'ExAM__Weight_Template__c'};
            accessAT.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Main_questionaire__c'), fieldsListAT);

            alltemplateLists = [SELECT Id, Name, Template_name__c, Score_By_Section_Weight__c, Weight_Template__c FROM Main_questionaire__c ORDER BY Template_name__c LIMIT 1000];
            templateLists.add(new SelectOption('None','None'));
            for(Main_questionaire__c res: alltemplateLists ) 
            {
                System.debug('~~~1 res.Weight_Template__c'+res.Weight_Template__c );
                if ( res.Template_name__c != null ){
                    templateLists.add(new SelectOption(res.id,res.Template_name__c ));
                } else {
                    templateLists.add(new SelectOption(res.id,res.Name ));
                }
                //wttemplateLists.add(new SelectOption(res.id,res.Weight_Template__c ));
                //System.debug('~~~2 res.Weight_Template__c'+res.Weight_Template__c );
            }
        }
        catch(Exception e) {
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()) );
        }
    }

    /*public string getwtTemplate () {
        return wtTemplate ;
    }*/

    public void setwtTemplate() {
        try {
            System.debug('~~~setwtTemplate'+templateid);
            if(templateid!=null)
            {
                if(sectionOptionLists!=null){ sectionOptionLists =new List<SelectOption>();}
                /*
                for(Main_questionaire__c res: alltemplateLists ) 
                {
                    string ids=(string)res.id;
                    if(ids.equalsIgnoreCase(templateid))
                    {
                        wtTemplate  = res.Weight_Template__c;
                        System.debug('~~~setwtTemplate '+wtTemplate   );break;
                    }
                }
                */

                SFDCAccessController accessST = ExAMUtilClass.AccessController;
                List<String> fieldsListST = new List<String>{'ExAM__Order_No__c', 'ExAM__status__c', 'ExAM__Section_label__c', 'ExAM__Section_Weight__c'};
                accessST.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Section_Template__c'), fieldsListST);

                //Get all the sections list
                sectionsLists = [SELECT Id, Name, Order_No__c, status__c, Section_label__c, Section_Weight__c FROM Section_Template__c where Questionnaire_Section__c=:templateid ORDER BY Order_No__c];
                sectionOptionLists.add(new SelectOption('None','None'));
                for(Section_Template__c res: sectionsLists )
                {
                    if ( res.Section_label__c != null ){
                        sectionOptionLists.add(new SelectOption(res.id,res.Section_label__c));
                    } else {
                        sectionOptionLists.add(new SelectOption(res.id,res.Name));
                    }
                }
            }
            questionsLists=null;
        }
        catch(Exception e) {
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()) );
        }
    }

    public void setquestionList() {

        try {
            System.debug('~~~setwtTemplate'+templateid);questionsLists =null;
            if((templateid!=null)&&(sectionid!=null))
            {
                //Get all the sections list
                //questionsLists = [SELECT  Id,Section_Question__c,Question_Label__c,Subquestion_Label__c,Weight_Of_Question__c,Question_Order_No__c,Question_Type__c,Weight_of_Answer__c FROM Question_Template__c where (Section_Question__c=:sectionid AND Question_Type__c='RadioPicklist') ORDER BY Question_Order_No__c]; 
                questionsLists = new List<Question_Template__c>();
                quesIdwithTempMap = new Map<Id,string>();

                SFDCAccessController accessQT = ExAMUtilClass.AccessController;
                List<String> fieldsListQT = new List<String>{'ExAM__Question_Label__c', 'ExAM__Question_Order_No__c', 'ExAM__Question_Type__c', 'ExAM__Section_Question__c', 'ExAM__Subquestion_Label__c', 'ExAM__Weight_of_Answer__c', 'ExAM__Weight_Of_Question__c'};
                accessQT.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Question_Template__c'), fieldsListQT);

                SFDCAccessController accessAO = ExAMUtilClass.AccessController;
                List<String> fieldsListAO = new List<String>{'ExAM__Help_Text__c', 'ExAM__Weight__c'};
                accessAO.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Answer_Option__c'), fieldsListAO);

                for(Question_Template__c quesTemp :[SELECT Id,Section_Question__c,Question_Label__c,Subquestion_Label__c,Weight_Of_Question__c,
                                                    Question_Order_No__c,Question_Type__c,Weight_of_Answer__c,
                                                    (SELECT Id,Name,Help_Text__c,Weight__c FROM Answer_Options__r) 
                                                    FROM Question_Template__c 
                                                    WHERE (Section_Question__c=:sectionid AND Question_Type__c='RadioPicklist') 
                                                    ORDER BY Question_Order_No__c]){ 
                    if( quesTemp.Answer_Options__r.size() > 0 ){
                        List<string> optList = new List<string>();
                        List<string> wtList = new List<string>();
                        for( Answer_Option__c ansOpt :quesTemp.Answer_Options__r ){
                            if( ansOpt != null ){
                                if( ansOpt.Name != null && ansOpt.Name != '' ) {
                                    optList.add(ansOpt.Name);
                                }
                                if( ansOpt.Weight__c != null ){
                                    wtList.add(string.valueOf(ansOpt.Weight__c));
                                }
                            }
                        }
                        if(  optList.size() > 0 ){
                            quesTemp.Subquestion_Label__c = string.join(optList,'~');
                        }
                        if(  wtList.size() > 0 ){
                            quesTemp.Weight_of_Answer__c = string.join(wtList,'~');
                        }
                    } else {
                       //questionsLists.add(quesTemp);
                    }
                    questionsLists.add(quesTemp);
                    string weight = quesTemp.Weight_of_Answer__c+'='+quesTemp.Weight_Of_Question__c;
                    System.debug('weight:::'+weight);
                    quesIdwithTempMap.put(quesTemp.Id,weight);
                }                 
            }
        }
        catch(Exception e) {
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()) );
        }
    }

    public PageReference savesections()
    {
        try {
            if(sectionsLists!=null)
            {
                System.debug('~~~sectionsLists '+sectionsLists );
                Decimal totalsections=0;
                for(Section_Template__c res: sectionsLists ) 
                {
                    if(res.Section_Weight__c!=null)
                    {
                        totalsections+=res.Section_Weight__c;
                    }
                }  
                if(totalsections==100)
                {
                    SFDCAccessController accessST = ExAMUtilClass.AccessController;
                    List<string> fieldsListST = new List<string>{'ExAM__Section_Weight__c'};
                    accessST.assertAuthorizedToUpdate(Schema.getGlobalDescribe().get('exam__Section_Template__c'), fieldsListST);

                    upsert sectionsLists;
                }
                else
                {
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Total Section score is not 100%');//Same old drama 
                    ApexPages.addMessage(myMsg);
                    // Return null so the page won't redirect
                    return null;
                }
            } 
            //string urlform='/apex/AssessmentWeightManagement';
            //PageReference saveClicked=new PageReference(urlform);
            //saveClicked.setRedirect(true); return saveClicked;
        }
        catch(Exception e) {
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()) );
        }
        return null;
    }

    public PageReference savequestions()
    {
        try {

            if((templateid!=null)&&(sectionid!=null))
            {
                if(questionsLists!=null)
                {
                    //added on 19-05-2017
                    List<Question_Template__c> updateQuesList = new List<Question_Template__c>();
                    for( Question_Template__c q :questionsLists ){
                        System.debug('map values'+quesIdwithTempMap.get(q.Id)+':::'+q.Weight_of_Answer__c);
                        string weight = q.Weight_of_Answer__c+'='+q.Weight_Of_Question__c;
                        System.debug('weight in save:::'+weight);
                        if ( weight != quesIdwithTempMap.get(q.Id) ) {
                            updateQuesList.add(q);
                        }
                    }
                    System.debug('to be update ques list:::'+updateQuesList);
                    System.debug('size of updat list:::'+updateQuesList.size());
                    List<Answer_Option__c> ansOptRecList = new List<Answer_Option__c>();     
                    for( Question_Template__c ques :updateQuesList ){
                        System.debug('ques template:::::'+ques.Answer_Options__r);
                        List<string> optList = new List<string>();
                        List<string> wtList = new List<string>();
                        System.debug('ans rec size:::'+ques.Answer_Options__r.size());
                        if( ques.Answer_Options__r.size() > 0 ){
                            System.debug('ans rec size:::>0');          
                            if( ques.Subquestion_Label__c != null && ques.Subquestion_Label__c != '' ){        
                                optList = ques.Subquestion_Label__c.split('~');
                            }
                            if( ques.Weight_of_Answer__c != null && ques.Weight_of_Answer__c != '' ){
                                wtList = ques.Weight_of_Answer__c.split('~');
                            }
                            System.debug('optList:::'+optList);
                            System.debug('wtList:::'+wtList);
                            Integer optLen = 0;
                            if( optList.size() > 0 ){
                                optLen = optList.size();
                                System.debug('len of opt list:::::'+optLen);
                            }
                            for( Integer i = 0; i < optLen; i++ ){
                                System.debug('i:::'+i);
                                System.debug('option:::'+optList[i]);
                                for( Answer_Option__c ansOpt :ques.Answer_Options__r ){
                                    System.debug('ansOpt:::'+ansOpt.Name+':::'+optList[i]);
                                    if ( ansOpt != null && ansOpt.Name == optList[i] ){
                                        System.debug('equal:::');
                                        if( wtList.size() > 0 && wtList[i] != null ){
                                            ansOpt.Weight__c = Decimal.valueOf(  wtList[i] );
                                            System.debug('ansOpt:::'+ansOpt);
                                        } else {
                                            System.debug('else ansOpt:::'+ansOpt);
                                            ansOpt.Weight__c = 0;
                                        }
                                        ansOptRecList.add(ansOpt);
                                        System.debug('added ansOptRecList:::'+ansOptRecList);
                                        //break;
                                    }
                                }
                            }
                            System.debug('ansOptRecList:::'+ansOptRecList);
                            //ques.Subquestion_Label__c = '';
                            //ques.Weight_of_Answer__c = '';
                        }
                    }
                    System.debug('~~~ update questionsLists'+updateQuesList);

                    SFDCAccessController accessQT = ExAMUtilClass.AccessController;
                    List<string> fieldsListQT = new List<string>{'ExAM__Weight_of_Answer__c', 'ExAM__Weight_Of_Question__c'};
                    accessQT.assertAuthorizedToUpdate(Schema.getGlobalDescribe().get('exam__Question_Template__c'), fieldsListQT);

                    upsert updateQuesList;

                    for ( Question_Template__c ques :updateQuesList ){
                        string weight = ques.Weight_of_Answer__c+'='+ques.Weight_Of_Question__c;
                        System.debug('weight in save:::'+weight);
                        quesIdwithTempMap.put(ques.Id,weight);
                    }
                    System.debug('quesIdwithTempMap=='+quesIdwithTempMap);
                    if( ansOptRecList.size() > 0 ){

                        SFDCAccessController accessAO = ExAMUtilClass.AccessController;
                        List<string> fieldsListAO = new List<string>{'ExAM__Weight__c'};
                        accessAO.assertAuthorizedToUpdate(Schema.getGlobalDescribe().get('exam__Answer_Option__c'), fieldsListAO);

                        update ansOptRecList;
                        /*
                        PageReference tempPage = ApexPages.currentPage();            
                        tempPage.setRedirect(true);
                        return tempPage;
                        */
                    }
                }
            } 
            //string urlform='/apex/AssessmentWeightManagement';
            //PageReference saveClicked=new PageReference(urlform);
            //saveClicked.setRedirect(true); return saveClicked;
        }
        catch(Exception e) {
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()) );
        }
        return null;
    }

    public PageReference cancel()
    { 
        string urlform='/apex/AssessmentWeightManagement';
        //'/apex/QuestionnaireCustomIssue?accid='+accountId+'&issueid='+issueId+'&templatename='+templateName;
        PageReference saveClicked=new PageReference(urlform);
        saveClicked.setRedirect(true);
        return saveClicked;
    }

    public PageReference exit()
    {
        PageReference cancelClicked;
        /*
        string userAgent =ApexPages.currentPage().getHeaders().get('USER-AGENT');
        if(userAgent.contains('iPhone')) {
            cancelClicked=new PageReference('/one/one.app');
        }
        else {
        */
        cancelClicked=new PageReference('/home/home.jsp');
        //}
        cancelClicked.setRedirect(true);
        return cancelClicked;  
    }

    public static testMethod void AssessmentWeightManagement_Test()
    {

        //Test converage for the visualforce page
        PageReference pageRef = Page.AssessmentWeightManagement;
        Test.setCurrentPageReference(pageRef);
        Test.startTest();
        Main_questionaire__c maintest=new Main_questionaire__c (Template_name__c ='test');
        upsert maintest;
        Section_Template__c sc= new Section_Template__c(Questionnaire_Section__c=maintest.id,Section_Weight__c=50,Section_label__c='test section'); 
        insert sc;
        Section_Template__c sc1= new Section_Template__c(Questionnaire_Section__c=maintest.id,Section_label__c='test section 2'); 
        insert sc1;
        System.currentPageReference().getParameters().put('templateid', maintest.id);

        Question_Template__c scq= new Question_Template__c(Section_Question__c=sc.id,Question_Label__c='What is your name?',Question_Order_No__c=1,Question_Type__c='Text',Focus_category__c='CCTV',Weight_of_Answer__c='4');     
        Question_Template__c scqp= new Question_Template__c(Section_Question__c=sc.id,Question_Label__c='What is your age?',Question_Order_No__c=2,Weight_Of_Question__c=2,Question_Type__c='RadioPicklist',Subquestion_Label__c='10-30~31-50',Focus_category__c='Perimeter',Weight_of_Answer__c='2~3');     
        Question_Template__c scqm= new Question_Template__c(Section_Question__c=sc.id,Question_Label__c='What is your qualification?',Question_Order_No__c=3,Question_Type__c='MultiselectPicklist',Subquestion_Label__c='High School~Bachelors~Masters',Focus_category__c='Emergency Response Plan',Weight_of_Answer__c='2~3~4');     
        Question_Template__c scqp1= new Question_Template__c(Section_Question__c=sc.id,Question_Label__c='What is your age?',Question_Order_No__c=4,Question_Type__c='RadioPicklist',Subquestion_Label__c='10-30~31-50',Focus_category__c='Adequate Lighting',Weight_of_Answer__c='2~3');     
        Question_Template__c scqm1= new Question_Template__c(Section_Question__c=sc.id,Question_Label__c='What is your qualification?',Question_Order_No__c=5,Question_Type__c='MultiselectPicklist',Subquestion_Label__c='High School~Bachelors~Masters',Focus_category__c='Adequate Locking System');     
        Question_Template__c scqp2= new Question_Template__c(Section_Question__c=sc.id,Question_Label__c='What is your age?',Question_Order_No__c=6,Question_Type__c='RadioPicklist',Subquestion_Label__c='10-30~31-50',Focus_category__c='Mail Handling');     

        insert scq;insert scqp;insert scqm;insert scqp1;insert scqm1;insert scqp2;

        ApexPages.StandardController scont = new ApexPages.StandardController(maintest);
        AssessmentWeightMgmtController d= new AssessmentWeightMgmtController(scont ); 
        d.alltemplateLists.add(maintest);

        System.currentPageReference().getParameters().put('templateid', maintest.id);
        System.currentPageReference().getParameters().put('sectionid', sc.id);
        d.sectionsLists=new List<Section_Template__c>();
        d.sectionsLists.add(sc);d.sectionsLists.add(sc1);
        d.setwtTemplate();d.setquestionList();d.savesections();d.savequestions();
        d.cancel();d.exit();
        System.assert(d.setquestionList()==null,'questionslist returns null');

        System.assert(d.setwtTemplate()==null,'sectionslist returns  null');
        Test.stopTest();
    }
}