public with sharing class SafeandHealthySchoolReportController{

    public String templateName{get;set;}
    public String sectionId{get;set;}
    public String accountId{get;set;}
    public Account acc{get;set;}
    public String accountName{get;set;}
    public List<Section_Template__c > sectionsLists{ get; set; }
    public List<Question_Template__c> questionsLists { get; set; }
    public List<Questionnaire_Response__c> responseLists { get; set; }
    public List<Main_questionaire__c> templateLists { get; set; }
    public List<SectionStatus__c > sectionsStatusLists{ get; set; }
    public String issueId{get;set;}
    public SafeandHealthySchoolReportController(ApexPages.StandardSetController controller){ }
    public SafeandHealthySchoolReportController(){}
   
    public class Section {
        public String name {get; set;} 
        public Decimal totalscore{get; set;}
        public Decimal maxtotalscore{get; set;}
        public Decimal scorepercent{get; set;}
        public List<Question> questionList {get; set;}
        public Section() {}
    } 

    public class Question {
        public Question(){}
        public String name {get; set;} 
        public String qid{get; set;} 
        public String responsename {get; set;} 
        public Decimal score{get; set;}
        public Questionnaire_Response__c resObj{get;set;}
    }
       
    public List<Section> sectionList {get; set;} 
     
    public void sectionStatus() {

        try {

            accountId=System.currentPageReference().getParameters().get('accId');//to get the school or account id
            templateName=System.currentPageReference().getParameters().get('TemplateName');
            accountName=System.currentPageReference().getParameters().get('accName');
            //System.debug('!!!!!!!!!!!!!!!!~~~~~~~~~~~~~acct id from diff page :'+accountid);
            // acc= [SELECT id,name,Main_Questionnaire_Template__c,Main_Questionnaire_Template__r.Template_name__c,Create_Survey__c From Account where id=:accountId];
            issueId= System.currentPageReference().getParameters().get('issueid');
            //System.debug('!!!!!!!!!!!!!!!!~~~~~~~~~~~~~acct id from diff page :'+accountid);

            SFDCAccessController accessForAT = ExAMUtilClass.AccessController;
            List<String> fieldsListAT = new List<String>{'ExAM__Template_name__c'};
            accessForAT.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Main_questionaire__c'), fieldsListAT);

            templateLists = [SELECT Id, Name, Template_name__c FROM Main_questionaire__c WHERE Template_name__c = :templateName];
            sectionList = new List<Section>(); 
            if(templateLists != null && templateLists.size() >= 1) {

                //templateName = templateLists.get(0).Name;   

                SFDCAccessController accessForST = ExAMUtilClass.AccessController;
                List<String> fieldsListST = new List<String>{'ExAM__Order_No__c', 'ExAM__Section_label__c'};
                accessForST.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Section_Template__c'), fieldsListST);

                SFDCAccessController accessForQT = ExAMUtilClass.AccessController;
                List<String> fieldsListQT = new List<String>{'ExAM__HelpText__c', 'ExAM__Question_Label__c', 'ExAM__Question_Order_No__c', 'ExAM__Question_Type__c', 'ExAM__Section_Question__c', 'ExAM__Subquestion_Label__c'};
                accessForQT.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Question_Template__c'), fieldsListQT);

                sectionsLists = [
                    SELECT Id, Order_No__c, Section_label__c,
                           (SELECT  HelpText__c, Id, Name, Question_Label__c, Question_Order_No__c, Question_Type__c, Section_Question__c, Subquestion_Label__c FROM Question_Template__r ORDER BY Question_Order_No__c)
                    FROM   Section_Template__c
                    WHERE  Questionnaire_Section__c = :templateLists.get(0).Id ORDER BY Order_No__c
                ];

                SFDCAccessController accessForAnswer = ExAMUtilClass.AccessController;

                List<String> fieldsListANSQT = new List<String>{'ExAM__Section_Question__c'};
                accessForAnswer.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Question_Template__c'), fieldsListANSQT);

                List<String> fieldsListAnswer = new List<String>{'ExAM__Account_to_Response__c', 'ExAM__Issue_Request__c', 'ExAM__Max_Score__c', 'ExAM__Question_Template__c', 'ExAM__Response__c', 'ExAM__Total_Score__c'};
                accessForAnswer.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Questionnaire_Response__c'), fieldsListAnswer);

                responseLists = [
                    SELECT Account_to_Response__c, Id, Issue_Request__c, Max_Score__c, Question_Template__c,
                           Question_Template__r.Section_Question__c, Response__c, Total_Score__c,
                           (SELECT Body, Id, CreatedDate, Owner.FirstName, Owner.LastName, Title FROM Notes ORDER BY CreatedDate),
                           (SELECT Id, LastModifiedDate, Name FROM Attachments)
                    FROM   Questionnaire_Response__c
                    WHERE  Account_to_Response__c = :accountId AND Issue_Request__c = :issueId
                ]; 
                //[SELECT Id,Name, Response__c,Account_to_Response__c,Question_Template__r.id,Question_Template__r.Section_Question__r.id,Issue_Request__c,Total_Score__c,Max_Score__c FROM Questionnaire_Response__c where Account_to_Response__c= :accountId AND Issue_Request__c=:issueId];                
                System.debug('!!!!!!!!!!!!!!!!~~~~~~~~~~~~~acct id from diff page :'+accountid+'lllllll'+responseLists);
                for(Section_Template__c sec : sectionsLists ) {

                    Section s = new Section();
                    s.name = sec.Section_label__c;s.maxtotalscore=0;s.totalscore=0;s.scorepercent=0;
                    s.questionList = new List<Question>(); 

                    for(Question_Template__c quest: sec.Question_Template__r) {

                        //System.debug('!!!!!question'+quest.Question_Label__c);
                        Questionnaire_Response__c reponseObject=new Questionnaire_Response__c();

                        Question q=new Question();
                        q.name=quest.Question_Label__c;
                        q.qid=quest.name;
                        for(Questionnaire_Response__c resp: responseLists) {
                            //Questionnaire_Response__c reponseObject=[Select id,Response__c,Question_Template__c,Account_to_Response__c from Questionnaire_Response__c where Account_to_Response__c= :accountId AND Question_Template__c=:quest.id] ;
                            if(resp.Question_Template__c==quest.id)
                            {
                                reponseObject=resp;System.debug('!!!!!shouldnt come here if res is 0'+resp);
                                q.score=resp.Total_Score__c;
                                s.maxtotalscore+=resp.Max_Score__c ;
                                s.totalscore+=resp.Total_Score__c;
                                break;
                            }
                        }

                        if(reponseObject==null) {
                            q.responsename='No response';
                        }
                        else {   
                            System.debug('!!!!!shouldnt come here if res is 0'+reponseObject);
                            q.responsename=reponseObject.Response__c;
                            q.resObj=reponseObject;
                        }
                        s.questionList.add(q);
                    }
                    if((s.totalscore>0)&&(s.maxtotalscore>0)){
                        s.scorepercent=(s.totalscore/s.maxtotalscore)*100;s.scorepercent=(s.scorepercent).SetSCale(2);
                    }
                    sectionList.add(s);
                }
            }
        }
        catch(Exception e) {
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()) );
        }
    }

    public static testMethod void testgetSections() {

        SafeandHealthySchoolReportController d= new SafeandHealthySchoolReportController();
        Test.setCurrentPageReference(new PageReference('Page.SafeandHealthySchoolReport'));
        Main_questionaire__c maintest=new Main_questionaire__c (Template_name__c ='Coordinated Safe and Healthy School Assessment Practices');
        insert maintest; 
        //System.currentPageReference().getParameters().put('TemplateName', maintest.Template_name__c ); 
        Account ac=new Account(name='test account1',Create_Survey__c=true);  
        ac.Main_Questionnaire_Template__c=maintest.id; 
        insert ac;
        System.currentPageReference().getParameters().put('accId', ac.id); 
        IssueRequest_Life_Cycle__c issuetest=new IssueRequest_Life_Cycle__c(Facility_Name__c=ac.id,Investigation_Type__c='Coordinated Safe and Healthy School Assessment Practices');
        insert issuetest; 
        System.currentPageReference().getParameters().put('issueid', issuetest.id);
        System.currentPageReference().getParameters().put('TemplateName',maintest.Template_name__c ); 
        Section_Template__c sc= new Section_Template__c(Questionnaire_Section__c=maintest.id,Section_label__c='test section'); 
        insert sc;
        Section_Template__c sc1= new Section_Template__c(Questionnaire_Section__c=maintest.id,Section_label__c='test section 2'); 
        insert sc1;
        Question_Template__c scq= new Question_Template__c(Section_Question__c=sc.id,Question_Label__c='What is your name?',Question_Order_No__c=1,Question_Type__c='Text',Focus_category__c='CCTV');     
        Question_Template__c scqp= new Question_Template__c(Section_Question__c=sc.id,Question_Label__c='What is your age?',Question_Order_No__c=2,Question_Type__c='RadioPicklist',Weight_Of_Question__c=4,Subquestion_Label__c='10-30~31-50',Focus_category__c='Perimeter');     
        Question_Template__c scqm= new Question_Template__c(Section_Question__c=sc.id,Question_Label__c='What is your qualification?',Question_Order_No__c=3,Question_Type__c='MultiselectPicklist',Subquestion_Label__c='High School~Bachelors~Masters',Focus_category__c='Emergency Response Plan');     
        Question_Template__c scqp1= new Question_Template__c(Section_Question__c=sc.id,Question_Label__c='What is your age?',Question_Order_No__c=4,Question_Type__c='RadioPicklist',Weight_Of_Question__c=2,Subquestion_Label__c='10-30~31-50',Focus_category__c='Adequate Lighting');     
        Question_Template__c scqm1= new Question_Template__c(Section_Question__c=sc.id,Question_Label__c='What is your qualification?',Question_Order_No__c=5,Question_Type__c='MultiselectPicklist',Subquestion_Label__c='High School~Bachelors~Masters',Focus_category__c='Adequate Locking System');     
        Question_Template__c scqp2= new Question_Template__c(Section_Question__c=sc.id,Question_Label__c='What is your age?',Question_Order_No__c=6,Question_Type__c='RadioPicklist',Weight_Of_Question__c=4,Subquestion_Label__c='10-30~31-50',Focus_category__c='Mail Handling');     
  
        insert scq;insert scqp;insert scqm;insert scqp1;insert scqm1;insert scqp2;
     
        //sc=[Select id from Section_Template__c limit 1];
            
        List<Section> scAlls=new List<Section>();  
     
        Test.startTest();     
        d.sectionStatus();
        System.assert(ac!=null,'Response data with questions not found');
        Test.stopTest();
    }
}