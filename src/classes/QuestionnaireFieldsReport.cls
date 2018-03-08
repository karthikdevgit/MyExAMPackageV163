public with sharing class QuestionnaireFieldsReport{

    public string templateName { get; set; }
    public string sectionId { get; set; }
    public string templateId { get; set; }
    public string groupId { get; set; }
    public string groupName { get; set; }
    public string accountName { get; set; }

    public List<Section_Group__c> secgrpList { get; set; }
    public List<Section_Group_Section_Relation__c> group_sectionlist { get; set; }
    public List<Section_Template__c> sectionsLists { get; set; }
    public List<Question_Template__c> questionsLists { get; set; }
    public List<Questionnaire_Response__c> responseLists { get; set; }
    public List<Main_questionaire__c> templateLists { get; set; }
    public List<SectionStatus__c> sectionsStatusLists { get; set; }
    public List<Section> sectionList { get; set; } 

    public Map<Id, List<Question_Template__c>> sectionTemplateIdQuestionsTemplatesMap;

    public Account acc { get; set; }

    public QuestionnaireFieldsReport(ApexPages.StandardSetController controller){}

    public class Section
    {
        public string name {get; set;} 
        public List<Question> questionList {get; set;}
        public Section() {}
    } 

    public class Question 
    {
        public Question() {}
        public string name {get; set;} 
        public string subquestionname {get; set;} 
    }

    public QuestionnaireFieldsReport(){ 

        try {
            templateId=System.currentPageReference().getParameters().get('templateid');//to get the school or account id
            groupId=System.currentPageReference().getParameters().get('groupid');
            sectionList = new List<Section>(); 
            sectionTemplateIdQuestionsTemplatesMap = new Map<Id, List<Question_Template__c>>();
            //System.debug('!!!!!!!!!!!!!!!!~~~~~~~~~~~~~acct id from diff page :'+accountid);
            if(templateId!=null)
            {

                SFDCAccessController accessForAT = ExAMUtilClass.AccessController;
                List<string> fieldsListAT = new List<string>{'ExAM__Template_name__c'};
                accessForAT.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Main_questionaire__c'), fieldsListAT);

                templateLists = [SELECT Id, Name, Template_name__c FROM Main_questionaire__c WHERE id = :templateId];
                if(templateLists!=NULL && templateLists.size()>=1)
                {
                    templateName = templateLists.get(0).Template_name__c ;   

                    SFDCAccessController accessForST = ExAMUtilClass.AccessController;
                    List<string> fieldsListST = new List<string>{'ExAM__Order_No__c', 'ExAM__Section_label__c'};
                    accessForST.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Section_Template__c'), fieldsListST);

                    sectionsLists = [
                        SELECT Id, Section_label__c, Order_No__c
                        FROM   Section_Template__c
                        WHERE  Questionnaire_Section__c = :templateLists.get(0).Id ORDER BY Order_No__c
                    ];

                    SFDCAccessController accessForQT = ExAMUtilClass.AccessController;
                    List<string> fieldsListQT = new List<string>{'ExAM__HelpText__c', 'ExAM__Question_Label__c', 'ExAM__Question_Order_No__c', 'ExAM__Question_Type__c', 'ExAM__Section_Question__c', 'ExAM__Subquestion_Label__c'};
                    accessForQT.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Question_Template__c'), fieldsListQT);

                    SFDCAccessController accessForAO = ExAMUtilClass.AccessController;
                    List<string> fieldsListAO = new List<string>{'ExAM__Help_Text__c', 'ExAM__Weight__c'};
                    accessForAO.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Answer_Option__c'), fieldsListAO);

                    Map<Id, List<Question_Template__c>> sectionTemplateIdQuestionsTemplatesMap = new Map<Id, List<Question_Template__c>>();
                    questionsLists = new List<Question_Template__c>();
                    questionsLists = [
                        SELECT  HelpText__c, Id, Question_Label__c, Question_Order_No__c, Question_Type__c,
                                Section_Question__c, Subquestion_Label__c,
                                (SELECT Help_Text__c, Id, Name, Weight__c FROM Answer_Options__r) 
                        FROM    Question_Template__c 
                        WHERE   Section_Question__c IN :sectionsLists ORDER BY Question_Order_No__c
                    ];
                    if (questionsLists != null && questionsLists.size() > 0) {
                        for (Question_Template__c qt : questionsLists) {
                            if (!sectionTemplateIdQuestionsTemplatesMap.containsKey(qt.Section_Question__c)) {
                                sectionTemplateIdQuestionsTemplatesMap.put(qt.Section_Question__c, new List<Question_Template__c>());
                            }
                            sectionTemplateIdQuestionsTemplatesMap.get(qt.Section_Question__c).add( qt );
                        }
                    }

                    //responseLists=[Select id,Response__c,Question_Template__c,Account_to_Response__c from Questionnaire_Response__c where Account_to_Response__c= :accountId] ;                 
                    //System.debug('!!!!!!!!!!!!!!!!~~~~~~~~~~~~~acct id from diff page :'+accountid+'lllllll'+responseLists);
                    for(Section_Template__c sec: sectionsLists ) 
                    {
                        Section s=new Section();
                        s.name=sec.Section_label__c;
                        s.questionList =new List<Question>(); 
                        if( sectionTemplateIdQuestionsTemplatesMap.containsKey(sec.Id) ){
                            for(Question_Template__c quest : sectionTemplateIdQuestionsTemplatesMap.get(sec.Id) ) 
                            {
                                Question q=new Question();
                                q.name=quest.Question_Label__c;
                                if ( quest.Answer_Options__r.size() == 0 ){
                                    q.subquestionname =quest.Subquestion_Label__c;
                                } else {
                                    List<string> optList = new List<string>();
                                    for( Answer_Option__c ansRec :quest.Answer_Options__r ){
                                        if ( ansRec != null && ansRec.Name != null && ansRec.Name != '' ){
                                            optList.add(ansRec.Name);
                                        }
                                    }
                                    q.subquestionname = string.join(optList,'~');
                                }
                                s.questionList.add(q);
                            }
                        }
                        sectionList.add(s);
                    }
                }
            }
            else
            {
                if(groupId!=null)
                {

                    SFDCAccessController accessForSG = ExAMUtilClass.AccessController;
                    List<string> fieldsListSG = new List<string>{'ExAM__Group_Name__c'};
                    accessForSG.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Section_Group__c'), fieldsListSG);

                    secgrpList = [SELECT Group_Name__c, Id, Name FROM Section_Group__c WHERE Id = :groupId];
                    if(secgrpList !=NULL && secgrpList.size()>0)
                    {
                        groupName=secgrpList[0].Group_Name__c;

                        SFDCAccessController accessForSGSR = ExAMUtilClass.AccessController;

                        List<string> fieldsListSGSRST = new List<string>{'ExAM__Section_label__c'};
                        accessForSGSR.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Section_Template__c'), fieldsListSGSRST);

                        List<string> fieldsListSGSR = new List<string>{'ExAM__Default_Section__c', 'ExAM__Section_Active__c', 'ExAM__Section_Group__c', 'ExAM__Section_Template__c'};
                        accessForSGSR.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Section_Group_Section_Relation__c'), fieldsListSGSR);

                        Set<Id> sectionTemplateIdSet = new Set<Id>();
                        group_sectionlist = new List<Section_Group_Section_Relation__c>();

                        for(Section_Group_Section_Relation__c  res : [SELECT Default_Section__c, Id, Section_Active__c, Section_Group__c, Section_Template__c,
                                                                             Section_Template__r.Section_label__c
                                                                      FROM   Section_Group_Section_Relation__c
                                                                      WHERE  Section_Group__c = :secgrpList[0].id AND Section_Active__c = true]) {


                            sectionTemplateIdSet.add( res.Section_Template__c );
                            group_sectionlist.add( res );
                        }

                        SFDCAccessController accessForQT = ExAMUtilClass.AccessController;
                        List<string> fieldsListQT = new List<string>{'ExAM__HelpText__c', 'ExAM__Question_Label__c', 'ExAM__Question_Order_No__c', 'ExAM__Question_Type__c', 'ExAM__Section_Question__c', 'ExAM__Subquestion_Label__c'};
                        accessForQT.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Question_Template__c'), fieldsListQT);

                        SFDCAccessController accessForAO = ExAMUtilClass.AccessController;
                        List<string> fieldsListAO = new List<string>{'ExAM__Help_Text__c', 'ExAM__Weight__c'};
                        accessForAO.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Answer_Option__c'), fieldsListAO);

                        for(Question_Template__c  qt : [SELECT  HelpText__c, Id, Question_Label__c, Question_Order_No__c, Question_Type__c,
                                                                Section_Question__c, Subquestion_Label__c,
                                                                (SELECT Help_Text__c, Id, Name, Weight__c FROM Answer_Options__r) 
                                                        FROM    Question_Template__c
                                                        WHERE   Section_Question__c IN :sectionTemplateIdSet ORDER BY Question_Order_No__c]) {

                            if (!sectionTemplateIdQuestionsTemplatesMap.containsKey(qt.Section_Question__c)) {
                                sectionTemplateIdQuestionsTemplatesMap.put(qt.Section_Question__c, new List<Question_Template__c>());
                            }
                            sectionTemplateIdQuestionsTemplatesMap.get(qt.Section_Question__c).add( qt );
                        }

                        System.debug('!!!!!group_sectionlist '+group_sectionlist.size());
                        for(Section_Group_Section_Relation__c  res: group_sectionlist ) 
                        {
                            Section s=new Section();System.debug('11!!!!!sec');
                            s.name=res.Section_Template__r.Section_label__c;System.debug('222!!!!!sec'+s.name);
                            s.questionList =new List<Question>(); 
                            System.debug('!!!!!sec'+res.Section_Template__r.Section_label__c);

                            if ((sectionTemplateIdQuestionsTemplatesMap.containsKey(res.Section_Template__c))
                                && (sectionTemplateIdQuestionsTemplatesMap.get(res.Section_Template__c) != null
                                    && sectionTemplateIdQuestionsTemplatesMap.get(res.Section_Template__c).size() > 0)
                            ) {

                                for(Question_Template__c quest : sectionTemplateIdQuestionsTemplatesMap.get(res.Section_Template__c) ) 
                                {
                                    Question q=new Question();
                                    q.name=quest.Question_Label__c;
                                    if ( quest.Answer_Options__r.size() == 0 ){
                                        q.subquestionname =quest.Subquestion_Label__c;
                                    } else {
                                        List<string> optList = new List<string>();
                                        for( Answer_Option__c ansRec :quest.Answer_Options__r ){
                                            if ( ansRec != null && ansRec.Name != null && ansRec.Name != '' ){
                                                optList.add(ansRec.Name);
                                            }
                                        }
                                        q.subquestionname = string.join(optList,'~');
                                    }
                                    s.questionList.add(q);
                                }
                            }
                            System.debug('1111!!!!!question'+s);
                            sectionList.add(s);System.debug('222!!!!!question');
                        }
                    }
                }
            }
            //FROM the force.com site if we want to update data in Account for CCTV etc scores I am adding the code here, as here the responses would be given and data would be added to Main Report DAta object for reports 
            // To set the focus category scores for the account
            //sectionsStatusLists=[Select id,Section_Template__c,Section_Template__r.id,Section_Template__r.Section_Label__c,Section_Template__r.Order_No__c,Account_to_SectionStatus__c,Status__c,User__c from SectionStatus__c where Account_to_SectionStatus__c= :accountId AND (Section_Template__c!=null) order by Section_Template__r.Order_No__c] ;
            System.debug('---sectionList'+sectionList);
        }
        catch(Exception e) {
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()) );
        }
    }

    public static testMethod void testgetSections()
    {

        Test.setCurrentPageReference(new PageReference('Page.QuestionnaireViewReport'));
        Main_questionaire__c maintest=new Main_questionaire__c (Template_name__c ='DOI');
        insert maintest; 
        Section_Group__c maintestg=new Section_Group__c(Group_Name__c ='test');
        upsert maintestg;
        System.currentPageReference().getParameters().put('templateid', maintest.id ); 

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
        Section_Group_Section_Relation__c  sgrelation=new Section_Group_Section_Relation__c (Section_Group__c=maintestg.id,Default_Section__c=true,Section_Active__c=true,Section_Template__c=sc.id);
        upsert sgrelation;
            
        List<Section> scAlls=new List<Section>();  
        QuestionnaireFieldsReport d= new QuestionnaireFieldsReport();
        System.currentPageReference().getParameters().put('templateid',null ); 
        System.currentPageReference().getParameters().put('groupid', maintestg.id );

        Test.startTest();
        QuestionnaireFieldsReport d1= new QuestionnaireFieldsReport();
        System.assert(d!=null,'Response data with questions not found');
        Test.stopTest();
    }   
}//end main class