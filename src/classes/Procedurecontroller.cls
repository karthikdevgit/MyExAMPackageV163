public with sharing class Procedurecontroller {
    public List<Account> childAccountLists { get; set; }
    public List<SelectOption> childAccOptionLists { get; set; }
    public List<Question_Template__c> questionsLists { get; set; }
    
    public List<SelectOption> questionOptionLists { get; set; }
    public String questionid{get;set;}
    public Question_Template__c selectedQuestion{get;set;}
    public List<SelectOption> ansOptionLists { get; set; }
    public List<Questionnaire_Response__c> ansLists{ get; set; }
    public List<Section_Template__c > sectionsLists{ get; set; }
    public List<SelectOption> sectionOptionLists { get; set; }
    public String sectionid{get;set;}
    public List<Main_questionaire__c> alltemplateLists { get; set; }
    public List<SelectOption> templateLists { get; set; }
    public String templateName{get;set;}
    public String templateid{get;set;}
    
    public String accountId{get;set;}
    public String accountName{get;set;}
    public Questionnaire_Response__c response{get;set;}
    public String[] multi{get;set;}
    public List<Attachment> allFileList {get; set;} //max 5
   //public Account  acc{ get; set; }//this is the child account of the main school i.e room1,room2,play area etc   
   
    public Procedurecontroller (ApexPages.StandardController controller){
        try{
            SFDCAccessController accessForAT = ExAMUtilClass.AccessController;
            List<String> fieldsListAT = new List<String>{'ExAM__Template_name__c','ExAM__TemplateFlag__c'};
            accessForAT.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Main_questionaire__c'), fieldsListAT);
                
            response=new Questionnaire_Response__c();
            sectionOptionLists =new List<SelectOption>();
            questionOptionLists =new List<SelectOption>();
            sectionOptionLists =new List<SelectOption>();
            questionOptionLists =new List<SelectOption>();
            childAccOptionLists =new List<SelectOption>();
            allFileList = new List<Attachment>() ;
            accountName ='Emergency Procedures';
            multi= new String[]{};
            childAccountLists =[select id,name from account where name=:accountName ];
            System.debug('~~1~~'+accountId+','+accountName+',,,'+childAccountLists );
            templateName='Emergency Procedures';  
            ansOptionLists  = new List<SelectOption>();   
            alltemplateLists = [Select Id, Name,Template_name__c,TemplateFlag__c  from Main_questionaire__c where Template_name__c=:templateName order by Template_name__c ];
            if((alltemplateLists!=null) &&(alltemplateLists.size()>0))
            {
                templateid=alltemplateLists[0].id;
            }
            multi= new String[]{};
            if((templateid!=null)&&(templateid!='None'))
                { if(sectionOptionLists!=null){sectionOptionLists =new List<SelectOption>();}
            //Get all the sections list
            
            List<String> fieldsListST = new List<String>{'ExAM__status__c','ExAM__Section_Weight__c','ExAM__Section_label__c','ExAM__Order_No__c','ExAM__Questionnaire_Section__c'};
            accessForAT.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Section_Template__c'), fieldsListST);
            
            sectionsLists = [Select Id, Name,status__c,Section_Weight__c,Section_label__c,Order_No__c from Section_Template__c where Questionnaire_Section__c=:templateid order by Order_No__c];
            sectionOptionLists.add(new SelectOption('None','None'));
            for(Section_Template__c res: sectionsLists ) 
                {
                    sectionOptionLists.add(new SelectOption(res.id,res.Section_label__c));
                }    
                System.debug('~~~section list'+  sectionsLists.size());                
            }
            questionsLists=null;  
        } catch(Exception e){
             ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()) );
        }
    }
    
    public void setQuestions()
    {
        try{
            System.debug('~~~Template'+templateid+',sectionid'+sectionid);questionsLists =null;
            questionOptionLists =new List<SelectOption>();
            ansOptionLists  = new List<SelectOption>();  
            multi= new String[]{};
            
            SFDCAccessController accessForQT = ExAMUtilClass.AccessController;
            
            List<String> fieldsListOpT = new List<String>{'ExAM__Help_Text__c','ExAM__Weight__c'};
            accessForQT.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Answer_Option__c'), fieldsListOpT);
            
            List<String> fieldsListQT = new List<String>{'ExAM__Section_Question__c','ExAM__Question_Label__c','ExAM__Weight_of_Answer__c','ExAM__Subquestion_Label__c','ExAM__Question_Order_No__c','ExAM__Question_Type__c'};
            accessForQT.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Question_Template__c'), fieldsListQT);
            
            if((templateid!=null)&&(sectionid!=null)&&(sectionid!='None')&&(templateid!='None'))
            {
              //Get all the sections list
               questionsLists = [SELECT  Id,Section_Question__c,Question_Label__c,Weight_of_Answer__c,Subquestion_Label__c,Question_Order_No__c,Question_Type__c,
                                 (SELECT Id,Name,Help_Text__c,Weight__c FROM Answer_Options__r)
                                 FROM Question_Template__c 
                                 WHERE (Section_Question__c=:sectionid ) ORDER BY Question_Order_No__c]; 
               questionOptionLists.add(new SelectOption('None','None'));
               for(Question_Template__c res: questionsLists ) 
                  {
                     questionOptionLists.add(new SelectOption(res.id,res.Question_Label__c));
                  }                  
             }  System.debug('~~~question list'+  questionsLists .size());  
         }     
         catch(Exception e){
             ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()) );
         }
    }
    
    public void setAnswers()
    {System.debug('~~~~s'+templateid+',sec'+sectionid);System.debug('~~~questionid'+questionid);
        if((templateid!=null)&&(sectionid!=null)&&(questionid!=null)&&(questionid!='None')&&(sectionid!='None')&&(templateid!='None'))
        {
            //assuming always new record is created for edit we will provide separate functionality
            /*ansLists = [Select id,Response__c,Question_Template__r.Section_Question__r.id,Question_Template__c,Account_to_Response__c,Issue_Request__c,Questionnaire_Taker_user__c,(SELECT Id,Title,body,CreatedDate,Owner.FirstName,Owner.LastName FROM Notes order by CreatedDate)  from Questionnaire_Response__c where Issue_Request__c=:issueId AND Question_Template__r.Section_Question__r.id=:questionid]; 
            
            if(ansLists.size()==0)
            {*/
                ansOptionLists  = new List<SelectOption>();  
                
                //response.Account_to_Response__c=accountId;
                System.debug('~~~'+questionid+'~~~~');
                if(questionsLists.size()>0)
                {
                 for(Question_Template__c res: questionsLists ) 
                  {System.debug('~~~'+questionid+'~~~~'+res.id);
                   if(questionid==res.id)
                   {response.Question_Template__c=res.id; selectedQuestion=res;
                     if(res.Question_Type__c.equalsIgnoreCase('RadioPicklist') 
                        || res.Question_Type__c.equalsIgnoreCase('Horizontal Radiopicklist') )
                         {
                                String qoptionValues = '';
                                List<String> ls = new List<String>();
                                if ( res.Answer_Options__r.size() == 0 ){
                                    qoptionValues = res.Subquestion_Label__c;
                                    if ( qoptionValues != null ){
                                        ls = qoptionValues.split('~');
                                    }
                                } else {
                                    for( Answer_Option__c ansOpt :res.Answer_Options__r ){
                                        if ( ansOpt != null && ansOpt.Name != null && ansOpt.Name != '' ){
                                            ls.add(ansOpt.Name);
                                        }
                                    }
                                }  
                                if ( ls.size() > 0 ){
                                    for(String s: ls) 
                                    {                   
                                        ansOptionLists.add(new SelectOption(s,s));                   
                                    }   
                                }
                                System.debug('-----radio picklist:'+qoptionValues); 
                                //response.Question_Template__r.Question_Type__c='RadioPicklist';
                                     
                         } 
                          else if(res.Question_Type__c.equalsIgnoreCase('Text'))
                         {
                                 System.debug('-----text:'); 
                                 if (res.Subquestion_Label__c != null && res.Answer_Options__r.size() == 0 ) {
                                     response.Response__c = res.Subquestion_Label__c;
                                 } else if( res.Answer_Options__r.size() > 0 ) {
                                     response.Response__c = res.Answer_Options__r[0].Name;
                                 }   
                                // response.Question_Template__r.Question_Type__c='Text';         
                         }
                          else if(res.Question_Type__c.equalsIgnoreCase('MultiselectPicklist'))
                         {
                                String[] multilist = new String[]{};
                                String qoptionValues = '';
                                List<String> ls = new List<String>();
                                if ( res.Answer_Options__r.size() == 0 ){
                                    qoptionValues = res.Subquestion_Label__c;
                                    if ( qoptionValues != null ){
                                        ls = qoptionValues.split('~');
                                    }
                                } else {
                                    for( Answer_Option__c ansOpt :res.Answer_Options__r ){
                                        if ( ansOpt != null && ansOpt.Name != null && ansOpt.Name != '' ){
                                            ls.add(ansOpt.Name);
                                        }
                                    }
                                } 
                                if ( ls.size() > 0 ){ 
                                    for(String s: ls) {                   
                                        ansOptionLists.add(new SelectOption(s,s));                   
                                    }  
                                }
                                System.debug('-----multi:'+   qoptionValues); 
                                           
                         }       
                    break;
                   }
                   
                  }//for(Question_Template__c res: questionsLists ) 
                }//if(questionsLists .size()>0)
                
          /*  }
            else
            {
             //record already exists
             response=ansLists[0];
            
            }*/
            
           //return options;
        }
        else
        {//return null;
        }
    }
     public PageReference cancel()
     {
        PageReference cancelClicked=new PageReference(ApexPages.currentPage().getUrl());
        cancelClicked.setRedirect(true);
        return cancelClicked;
     }
    

    
 
        public static testMethod void Procedurecontroller_Test()
        {
            //Test converage for the visualforce page
            PageReference pageRef = Page.Procedures ;
            Test.setCurrentPageReference(pageRef);
            Test.startTest();
            Main_questionaire__c maintest=new Main_questionaire__c (Template_name__c ='Emergency Procedures',TemplateFlag__c=true);
            upsert maintest;
            Account acc=new Account(name='Emergency Procedures',Create_Survey__c=true); upsert acc; 
           
            Section_Template__c sc= new Section_Template__c(Questionnaire_Section__c=maintest.id,Section_label__c='test section'); 
             insert sc;
             Section_Template__c sc1= new Section_Template__c(Questionnaire_Section__c=maintest.id,Section_label__c='test section 2'); 
             insert sc1;
             
             Question_Template__c scq= new Question_Template__c(Section_Question__c=sc.id,Question_Label__c='What is your name?',Question_Order_No__c=1,Question_Type__c='Text',Focus_category__c='CCTV',Subquestion_Label__c='text value',Weight_of_Answer__c='4');     
             Question_Template__c scqp= new Question_Template__c(Section_Question__c=sc.id,Question_Label__c='What is your age?',Question_Order_No__c=2,Weight_Of_Question__c=2,Question_Type__c='RadioPicklist',Subquestion_Label__c='10-30~31-50',Focus_category__c='Perimeter',Weight_of_Answer__c='2~3');     
             Question_Template__c scqm= new Question_Template__c(Section_Question__c=sc.id,Question_Label__c='What is your qualification?',Question_Order_No__c=3,Question_Type__c='MultiselectPicklist',Subquestion_Label__c='High School~Bachelors~Masters',Focus_category__c='Emergency Response Plan',Weight_of_Answer__c='2~3~4');     
             Question_Template__c scqp1= new Question_Template__c(Section_Question__c=sc.id,Question_Label__c='What is your age?',Question_Order_No__c=4,Question_Type__c='RadioPicklist',Subquestion_Label__c='10-30~31-50',Focus_category__c='Adequate Lighting',Weight_of_Answer__c='2~3');     
             Question_Template__c scqm1= new Question_Template__c(Section_Question__c=sc.id,Question_Label__c='What is your qualification?',Question_Order_No__c=5,Question_Type__c='MultiselectPicklist',Subquestion_Label__c='High School~Bachelors~Masters',Focus_category__c='Adequate Locking System');     
             Question_Template__c scqp2= new Question_Template__c(Section_Question__c=sc.id,Question_Label__c='What is your age?',Question_Order_No__c=6,Question_Type__c='RadioPicklist',Subquestion_Label__c='10-30~31-50',Focus_category__c='Mail Handling');     
          
             insert scq;insert scqp;insert scqm;insert scqp1;insert scqm1;insert scqp2;
            
            ApexPages.StandardController scont = new ApexPages.StandardController(maintest);
            Procedurecontroller d= new Procedurecontroller(scont ); 
            d.alltemplateLists.add(maintest);
            d.accountId=acc.id;
            d.accountName=acc.name;
            d.templateid=maintest.id;
            
            d.sectionid=sc.id;
            d.sectionsLists=new List<Section_Template__c>();
            d.childAccountLists =new List<Account>();
            d.childAccountLists.add(acc);
            //d.childAccountLists[1] =[select id,name,parent.id,parent.name from account where parent.id=:acc.id];
           
            //d.childAccountLists[0].parent.id=acc.id;d.childAccountLists[0].parent.name=acc.name;
            d.questionsLists=new List<Question_Template__c >();
            d.sectionsLists.add(sc);d.sectionsLists.add(sc1);
            d.questionsLists.add(scq);d.questionsLists.add(scqp);d.questionsLists.add(scqm);
            d.selectedQuestion=scqp;
            d.questionid=d.selectedQuestion.id;
            System.assert(d.questionid!=null);
            d.setQuestions();d.setAnswers();
            d.response.Response__c='10-30';
            d.response.Question_Template__c=d.selectedQuestion.id;
           d.cancel();
            
            
            //System.assert(d.setwtTemplate()==null,'sectionslist returns  null');
            Test.stopTest();
     
}
 
 
 
 }