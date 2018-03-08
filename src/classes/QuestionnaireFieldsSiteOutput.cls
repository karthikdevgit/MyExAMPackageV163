public with sharing class QuestionnaireFieldsSiteOutput {

    public string templateName{get;set;}
    public string sectionId{get;set;}
    public string accountId{get;set;}
    public Account acc{get;set;}
    public string accountName{get;set;}
    public List<Section_Template__c > sectionsLists{ get; set; }
    public List<Question_Template__c> questionsLists { get; set; }
    public List<Questionnaire_Response__c> responseLists { get; set; }
    public List<Main_questionaire__c> templateLists { get; set; }
    public List<SectionStatus__c > sectionsStatusLists{ get; set; }

    public QuestionnaireFieldsSiteOutput(ApexPages.StandardSetController controller){ }

    public QuestionnaireFieldsSiteOutput(){}
   
    public class Section {
        public string name {get; set;} 
        public List<Question> questionList {get; set;}
        public Section() {}
    } 

    public class Question {
        public Question() {}
        public string name {get; set;} 
        public string responsename {get; set;} 
    }

    public List<Section> sectionList {get; set;}
     
    public void sectionStatus() {

        try {

            accountId = System.currentPageReference().getParameters().get('accId');//to get the school or account id
            //System.debug('!!!!!!!!!!!!!!!!~~~~~~~~~~~~~acct id from diff page :'+accountid);

            SFDCAccessController accessForAcct = ExAMUtilClass.AccessController;

            List<String> fieldsListAcctAT = new List<String>{'ExAM__Template_name__c'};
            accessForAcct.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Main_questionaire__c'), fieldsListAcctAT);

            List<String> fieldsListAcct = new List<String>{'ExAM__Main_Questionnaire_Template__c', 'ExAM__School_Logo__c'};
            accessForAcct.assertAuthorizedToView(Schema.getGlobalDescribe().get('Account'), fieldsListAcct);

            Account a = [SELECT Id, Main_Questionnaire_Template__c, Main_Questionnaire_Template__r.Template_name__c, Name, School_Logo__c FROM Account WHERE Id = :accountId LIMIT 1];
            acc=a;
            accountName = a.Name;

            templateLists = [SELECT Id, Name FROM Main_questionaire__c where Template_name__c=:a.Main_Questionnaire_Template__r.Template_name__c];
            sectionList = new List<Section>(); 
            if(templateLists!=NULL && templateLists.size()>=1) {

                templateName = templateLists.get(0).Name;   

                SFDCAccessController accessForST = ExAMUtilClass.AccessController;
                List<String> fieldsListST = new List<String>{'ExAM__Order_No__c', 'ExAM__Section_label__c'};
                accessForST.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Section_Template__c'), fieldsListST);

                SFDCAccessController accessForQT = ExAMUtilClass.AccessController;
                List<String> fieldsListQT = new List<String>{'ExAM__HelpText__c', 'ExAM__Question_Label__c', 'ExAM__Question_Order_No__c', 'ExAM__Question_Type__c', 'ExAM__Subquestion_Label__c', 'ExAM__Section_Question__c'};
                accessForQT.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Question_Template__c'), fieldsListQT);

                sectionsLists = [
                    SELECT Id, Order_No__c, Section_label__c,
                           (SELECT  HelpText__c, Id, Question_Label__c, Question_Order_No__c, Question_Type__c,
                                    Subquestion_Label__c, Section_Question__c
                            FROM    Question_Template__r ORDER BY Question_Order_No__c)
                    FROM   Section_Template__c
                    WHERE  Questionnaire_Section__c = :templateLists.get(0).Id ORDER BY Order_No__c
                ];

                SFDCAccessController accessForAnswer = ExAMUtilClass.AccessController;
                List<String> fieldsListAnswer = new List<String>{'ExAM__Account_to_Response__c', 'ExAM__Question_Template__c', 'ExAM__Response__c'};
                accessForAnswer.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Questionnaire_Response__c'), fieldsListAnswer);

                responseLists = [SELECT Account_to_Response__c, Id, Question_Template__c, Response__c FROM Questionnaire_Response__c WHERE Account_to_Response__c = :accountId] ;                 
                System.debug('!!!!!!!!!!!!!!!!~~~~~~~~~~~~~acct id from diff page :'+accountid+'lllllll'+responseLists);
                for(Section_Template__c sec : sectionsLists) {

                    Section s = new Section();
                    s.name = sec.Section_label__c;
                    s.questionList = new List<Question>();          
                    for(Question_Template__c quest : sec.Question_Template__r) {

                        //System.debug('!!!!!question'+quest.Question_Label__c);
                        Questionnaire_Response__c reponseObject = new Questionnaire_Response__c();

                        Question q=new Question();
                        q.name=quest.Question_Label__c;
                        for(Questionnaire_Response__c resp: responseLists) {

                            //Questionnaire_Response__c reponseObject=[Select id,Response__c,Question_Template__c,Account_to_Response__c from Questionnaire_Response__c where Account_to_Response__c= :accountId AND Question_Template__c=:quest.id] ;
                            if(resp.Question_Template__c==quest.id)
                            {
                                reponseObject=resp;System.debug('!!!!!shouldnt come here if res is 0'+resp);break;
                            }
                        }
                        if(reponseObject==null) {
                            q.responsename='No response';
                        }
                        else {
                            System.debug('!!!!!shouldnt come here if res is 0'+reponseObject);
                            q.responsename=reponseObject.Response__c;
                        }
                        s.questionList.add(q);
                    }
                    sectionList.add(s);
                }
            }

            SFDCAccessController accessForSS = ExAMUtilClass.AccessController;

            List<String> fieldsListSSST = new List<String>{'ExAM__Order_No__c', 'ExAM__Section_Label__c'};
            accessForSS.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Section_Template__c'), fieldsListSSST);

            List<String> fieldsListSS = new List<String>{'ExAM__Account_to_SectionStatus__c', 'ExAM__Section_Template__c', 'ExAM__Status__c', 'ExAM__User__c'};
            accessForSS.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__SectionStatus__c'), fieldsListSS);

            //FROM the force.com site if we want to update data in Account for CCTV etc scores I am adding the code here, as here the responses would be given and data would be added to Main Report DAta object for reports 
            // To set the focus category scores for the account
            sectionsStatusLists = [
                SELECT Account_to_SectionStatus__c, Id, Section_Template__c, Section_Template__r.Order_No__c,
                       Section_Template__r.Section_Label__c, Status__c, User__c
                FROM   SectionStatus__c
                WHERE  Account_to_SectionStatus__c = :accountId AND (Section_Template__c != null) ORDER BY Section_Template__r.Order_No__c
            ];

            /*List<aggregateResult> aggr=[
            Select Account__c, Question_Template__r.Focus_category__c focus, SUM(Questionnaire_Response__r.Total_Score__c)total
            from Main_Report_Data__c where Account__c=:accountId
            GROUP BY  Account__c,Question_Template__r.Focus_category__c ];
            Account acc= [SELECT id,name,Adequate_Lighting_Score__c,Adequate_Locking_Score__c,CCTV_Score__c,Emergency_Response_Plan__c,Mail_Handling_Score__c,Overall_Score__c,Perimeter_Score__c,Create_Survey__c From Account where Create_Survey__c=:true AND id=:accountId];
            if(acc!=null) {

                acc.Overall_Score__c = 0;
                integer b=0;
                for(SectionStatus__c res: sectionsStatusLists) {
    
                    if(res.status__c.equalsIgnoreCase('complete')) {
                        b++;
                        System.debug('!!!!!!!!!!!!!!!!!!b='+b+','+ res.status__c);
                    }                               
                }
                if(b==sectionsLists.size()) {
                    System.debug('!!!!!!!!!!!!!!!!!!b val:'+b);
                    acc.Survey_Completed__c='Complete';
                }
                for (AggregateResult ar : aggr) {

                    string focuscat=string.valueOf(ar.get('focus')); 
                    System.debug('account id:'+acc.id+'focus category:'+focuscat);
                    acc.Overall_Score__c+=Integer.valueOf(ar.get('total'));
                    if(focuscat.equalsIgnoreCase('CCTV')) {
                        System.debug('ccccccccccctvfocuscat'+focuscat);
                        acc.CCTV_Score__c=Integer.valueOf(ar.get('total'));                  
                    }
                    else if(focuscat.equalsIgnoreCase('Perimeter')) {
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
        catch(Exception e) {
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()) );
        }
    }

    public static testMethod void testgetSections() {

        QuestionnaireFieldsSiteOutput d= new QuestionnaireFieldsSiteOutput();
        Test.setCurrentPageReference(new PageReference('Page.ReportPDF'));
        Main_questionaire__c maintest=new Main_questionaire__c (Template_name__c ='DOI');
        insert maintest; 
        //System.currentPageReference().getParameters().put('TemplateName', maintest.Template_name__c ); 
        Account ac=new Account(name='test account1',Create_Survey__c=true);  
        ac.Main_Questionnaire_Template__c=maintest.id; 
        insert ac;
        System.currentPageReference().getParameters().put('accId', ac.id);  
        Section_Template__c sc= new Section_Template__c(Questionnaire_Section__c=maintest.id,Section_label__c='test section'); 
        insert sc;
        Section_Template__c sc1= new Section_Template__c(Questionnaire_Section__c=maintest.id,Section_label__c='test section 2'); 
        insert sc1;
        Question_Template__c scq= new Question_Template__c(Section_Question__c=sc.id,Question_Label__c='What is your name?',Question_Order_No__c=1,Question_Type__c='Text',Focus_category__c='CCTV');     
        Question_Template__c scqp= new Question_Template__c(Section_Question__c=sc.id,Question_Label__c='What is your age?',Question_Order_No__c=2,Question_Type__c='RadioPicklist',Subquestion_Label__c='10-30~31-50',Focus_category__c='Perimeter');     
        Question_Template__c scqm= new Question_Template__c(Section_Question__c=sc.id,Question_Label__c='What is your qualification?',Question_Order_No__c=3,Question_Type__c='MultiselectPicklist',Subquestion_Label__c='High School~Bachelors~Masters',Focus_category__c='Emergency Response Plan');     
        Question_Template__c scqp1= new Question_Template__c(Section_Question__c=sc.id,Question_Label__c='What is your age?',Question_Order_No__c=4,Question_Type__c='RadioPicklist',Subquestion_Label__c='10-30~31-50',Focus_category__c='Adequate Lighting');     
        Question_Template__c scqm1= new Question_Template__c(Section_Question__c=sc.id,Question_Label__c='What is your qualification?',Question_Order_No__c=5,Question_Type__c='MultiselectPicklist',Subquestion_Label__c='High School~Bachelors~Masters',Focus_category__c='Adequate Locking System');     
        Question_Template__c scqp2= new Question_Template__c(Section_Question__c=sc.id,Question_Label__c='What is your age?',Question_Order_No__c=6,Question_Type__c='RadioPicklist',Subquestion_Label__c='10-30~31-50',Focus_category__c='Mail Handling');     

        insert scq;insert scqp;insert scqm;insert scqp1;insert scqm1;insert scqp2;
        Main_Report_Data__c  reportd=new Main_Report_Data__c(Account__c=ac.id, Question_Template__c=scq.id); 
        Main_Report_Data__c  reportd1=new Main_Report_Data__c(Account__c=ac.id,Question_Template__c= scqp.id);
        Main_Report_Data__c  reportd2=new Main_Report_Data__c(Account__c=ac.id, Question_Template__c=scqp1.id); 
        Main_Report_Data__c  reportd3=new Main_Report_Data__c(Account__c=ac.id, Question_Template__c=scqp2.id); 
        Main_Report_Data__c  reportd4=new Main_Report_Data__c(Account__c=ac.id, Question_Template__c=scqm1.id); 
        Main_Report_Data__c  reportd5=new Main_Report_Data__c(Account__c=ac.id, Question_Template__c=scqm.id);   
        insert reportd;insert reportd1;insert reportd2;insert reportd3;insert reportd4;insert reportd5;
        //sc=[Select id from Section_Template__c limit 1];
            
        List<Section> scAlls=new List<Section>();  
     
        Test.startTest();
        d.acc=ac;
        d.accountName=ac.name;
        d.sectionStatus();
        System.assert(ac!=null,'Response data with questions not found');
        Test.stopTest();
    } 
}//end main class