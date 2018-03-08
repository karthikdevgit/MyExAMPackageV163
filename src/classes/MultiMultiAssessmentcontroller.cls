public with sharing class MultiMultiAssessmentcontroller  {
  
    public String questionid{get;set;}
    public String sectionid{get;set;}
    public String templateName{get;set;}
    public String templateid{get;set;}
    public String issueId{get;set;}
    public String accountId{get;set;}
    public String accountName{get;set;}

    public Question_Template__c selectedQuestion{get;set;}
    public Questionnaire_Response__c response{get;set;}
    //public Account  acc{ get; set; }//this is the child account of the main school i.e room1,room2,play area etc   

    public List<Account> childAccountLists { get; set; }
    public List<String> selectedAccountLists { get; set; }
    public List<Question_Template__c> questionsLists { get; set; }
    public List<Section_Group_Section_Relation__c> group_sectionlist { get; set; }
    public List<Questionnaire_Response__c> responseObjects { get; set; }
    public List<Questionnaire_Response__c> ansLists{ get; set; }
    //public List<Section_Template__c > sectionsLists{ get; set; }

    public List<SelectOption> childAccOptionLists { get; set; }
    public List<SelectOption> questionOptionLists { get; set; }
    public List<SelectOption> ansOptionLists { get; set; }
    public List<SelectOption> sectionOptionLists { get; set; }
    public List<Section_Group__c> alltemplateLists { get; set; }
    public List<SelectOption> templateLists { get; set; }
    public String[] multi{get;set;}
    public List<QuestionDisplay> listQuestWithOptions;  
    public List<Attachment> allFileList {get; set;} //max 5
   
    public MultiMultiAssessmentcontroller  (ApexPages.StandardController controller)
    {
        try{
            templateLists =new List<SelectOption>();
            selectedAccountLists =new List<String>();
            sectionOptionLists =new List<SelectOption>();
            questionOptionLists =new List<SelectOption>();
            sectionOptionLists =new List<SelectOption>();
            questionOptionLists =new List<SelectOption>();
            childAccOptionLists =new List<SelectOption>();
            allFileList = new List<Attachment>() ;
            responseObjects = new List<Questionnaire_Response__c>();  
            multi= new String[]{};

            // allFileList.clear() ;  
            //Adding multiple attachments instance  
            for(Integer i = 0 ; i <= 4 ; i++)  
            {allFileList.add(new Attachment()) ; }
            issueId= System.currentPageReference().getParameters().get('id');
            accountId=System.currentPageReference().getParameters().get('accid');//to get the parent school or account id
            accountName=System.currentPageReference().getParameters().get('accname');
            // If NO accountId is passed in the URL
            if( accountId == NULL && issueId != NULL ) {
                SFDCAccessController accessForobj = ExAMUtilClass.AccessController;
                List<String> fieldsList = new List<String>{'ExAM__Facility_Name__c'};
                accessForobj.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__IssueRequest_Life_Cycle__c'), fieldsList);
                accountId = [SELECT Id,ExAM__Facility_Name__c FROM ExAM__IssueRequest_Life_Cycle__c WHERE Id=:issueId].ExAM__Facility_Name__c;
            }
            childAccountLists =[select id,name,parentid from account where parentid=:accountId or id=:accountId order by name];
            System.debug('~~1~~'+accountId+','+accountName+',,,'+childAccountLists );
            // childAccOptionLists.add(new SelectOption(childAccountLists[0].parent.id,childAccountLists[0].parent.name));
            //childAccOptionLists.add(new SelectOption(accountId,accountName));
            //childAccountLists =[Select ID,name (Select id,parentid,name From accounts__r) From Account WHERE id =:accountId];
            for(Account res: childAccountLists ) 
            {
                //System.debug('~~~1 res.Weight_Template__c'+res.Template_name__c );
                childAccOptionLists.add(new SelectOption(res.id,res.name ));                     
            }
            response=new Questionnaire_Response__c(); 
            ansOptionLists  = new List<SelectOption>();
             
            SFDCAccessController accessForobj = ExAMUtilClass.AccessController;
            List<String> fieldsList = new List<String>{'ExAM__Group_Name__c'};
            accessForobj.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Section_Group__c'), fieldsList);    
            alltemplateLists = [Select Id, Name,Group_Name__c from Section_Group__c order by Group_Name__c LIMIT 1000];
            templateLists.add(new SelectOption('None','None'));
            for(Section_Group__c  res: alltemplateLists ) 
            {
                //System.debug('~~~1 res.Weight_Template__c'+res.Template_name__c );
                templateLists.add(new SelectOption(res.id,res.Group_Name__c ));                     
            }
        }catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        }
    }

    public void setSections()
    {
        //System.debug('~~~Template'+templateid);
        try{
            sectionOptionLists =new List<SelectOption>();
            questionOptionLists =new List<SelectOption>();
            ansOptionLists  = new List<SelectOption>();  
            multi= new String[]{};
            if((templateid!=null)&&(templateid!='None')){ 

                if(sectionOptionLists!=null){sectionOptionLists =new List<SelectOption>();}
                //Get all the sections listSelect Id, Name From Object2 Where Id = :Object1.field1__c
                // sectionsLists = [Select Id, Name,status__c,Section_Weight__c,Section_label__c,(Select id,Section_Group__c,Section_Template__c,Default_Section__c,Section_Active__c from Section_Template_Junction__r where Section_Group__c=:templateid)from  Section_Template__c Where Id IN : (Select Section_Template__c From Section_Template_Junction__r)  ];
                //sectionsLists = [Select Id, Name,status__c,Section_Weight__c,Section_label__c from Section_Template__c where Section_Group_Section_Relation__r.Section_Group__c=:templateid];
                SFDCAccessController accessForobj = ExAMUtilClass.AccessController;
                List<String> fieldsList = new List<String>{'ExAM__Section_Group__c','ExAM__Default_Section__c','ExAM__Section_Active__c','ExAM__Section_Template__c'};
                accessForobj.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Section_Group_Section_Relation__c'), fieldsList); 
                group_sectionlist = [Select id,Section_Group__c,Default_Section__c,Section_Active__c,Section_Group__r.id,Section_Template__c,Section_Template__r.Section_label__c,Section_Template__r.id from Section_Group_Section_Relation__c where Section_Group__c=:templateid AND Section_Active__c=true];
                //sectionsLists.add();
                System.debug('~~~group_sectionlist list'+  group_sectionlist.size());  
                sectionOptionLists.add(new SelectOption('None','None'));
                for(Section_Group_Section_Relation__c  res: group_sectionlist ) 
                {
                    sectionOptionLists.add(new SelectOption(res.Section_Template__r.id,res.Section_Template__r.Section_label__c));
                    if(res.Default_Section__c==true)
                    {//sectionid=res.Section_Template__r.id;questionid='All'; 
                    }
                }
            }
            questionsLists=null;
            questionid=null;
        }catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        }
    }

    public class QuestionDisplay
    {
        //each record is sent to the visualforce frontend page iteratively through class vaiable.        
        //SELECT  Id,Question_Label__c,Question_Order_No__c,Question_Type__c,Subquestion_Label__c FROM Question_Template__c where Section_Question__r.id=:id order by Question_Order_No__c];         
        public Question_Template__c newquestFormat{get;set;}
        public Questionnaire_Response__c resObj{get;set;}
        public String questionFlag{get;set;}//default
        public List<SelectOption> optionsList{get;set;} 
        public String sectionLabel{get;set;}
        public String[] multiselectlist{get;set;} 
        public String acctId{get;set;}        
        public String issueId{get;set;}
        
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
        public QuestionDisplay()
        {
        }
    }

    public List<QuestionDisplay> getquestionsList()
    {
        listQuestWithOptions= new QuestionDisplay[]{};Integer i=0;
        setQuestions();
        String accountId=System.currentPageReference().getParameters().get('accid'); //accId=accountId;
        String issueId= System.currentPageReference().getParameters().get('issueid');

        //questionsLists = [SELECT  Id,Section_Question__r.id,Question_Label__c,Question_Order_No__c,Question_Type__c,HelpText__c,Weight_of_Answer__c,Subquestion_Label__c FROM Question_Template__c where Section_Question__r.id=:sectionid order by Question_Order_No__c]; 
        
        List<Id> questionIds = new List<Id>();
        if(questionsLists !=NULL && questionsLists.size()>=1)
        { 
            /*for(Question_Template__c qids:questionsLists)
            {
                questionIds.add(qids.id);
                //System.debug('~~~~~~~~~id='+qids);responseObjects 
            }*/
            for(Question_Template__c quest: questionsLists ) 
            { //allFileList.add(new Attachment()) ; 
                Note[] attachnotes=new Note[]{};
                Questionnaire_Response__c resp=new Questionnaire_Response__c();   
                //resp.Notes=  attachnotes;     
                List<SelectOption> options = new List<SelectOption>();         
                if(quest.Question_Type__c.equalsIgnoreCase('RadioPicklist'))
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
                    //System.debug('-----radio picklist:'+qoptionValues);  
                    listQuestWithOptions.add(new QuestionDisplay(quest,options,resp,null) );   
                    i=1;         
                } 
                else if(quest.Question_Type__c.equalsIgnoreCase('Text'))
                {
                    //Textflag='true';
                    // System.debug('-----text:'); 
                    options.add(new SelectOption('none','none'));
                    if (quest.Subquestion_Label__c != null && quest.Answer_Options__r.size() == 0 ) {
                        resp.Response__c = quest.Subquestion_Label__c;
                    } else  if( quest.Answer_Options__r.size() > 0 ){
                        resp.Response__c = quest.Answer_Options__r[0].Name;
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
                        for(String s: ls) 
                        {                   
                            options.add(new SelectOption(s,s));                   
                        } 
                    }
                    //MultiselectPicklistflag='true';
                    //System.debug('-----radio picklist:'+   qoptionValues); 
                    listQuestWithOptions.add(new QuestionDisplay(quest,options,resp,multilist) ); 
                    i=1;             
                }       
                                    
            } 
        }
        System.debug('---'+listQuestWithOptions);
        return listQuestWithOptions;
    }

    public void setQuestions()
    {   
        try{
            
            System.debug('1~~~setQuestionsTemplate'+templateid+',sectionid'+sectionid);//questionsLists =null;
            questionOptionLists =new List<SelectOption>();
            ansOptionLists  = new List<SelectOption>();  
            multi= new String[]{};questionid=null;
            if((templateid!=null)&&(sectionid!=null)&&(sectionid!='None')&&(templateid!='None'))
            {
              //Get all the sections list
               SFDCAccessController accessForobj = ExAMUtilClass.AccessController;
               List<String> fieldsList = new List<String>{'ExAM__Question_Label__c','ExAM__Question_Order_No__c','ExAM__Question_Type__c','ExAM__HelpText__c','ExAM__Weight_of_Answer__c','ExAM__Subquestion_Label__c'};
               accessForobj.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam_Question_Template__c'), fieldsList); 
              
               questionsLists = [SELECT  Id,Section_Question__r.id,Question_Label__c,Question_Order_No__c,Question_Type__c,HelpText__c,Weight_of_Answer__c,
                                  Subquestion_Label__c,(SELECT Id,Name,Help_Text__c,Weight__c FROM Answer_Options__r) 
                                  FROM Question_Template__c 
                                  WHERE Section_Question__r.id=:sectionid ORDER BY Question_Order_No__c]; 
             //questionOptionLists.add(new SelectOption('All','All'));questionid='All';
              questionOptionLists.add(new SelectOption('None','None'));//questionid='None';
               
               for(Question_Template__c res: questionsLists ) 
                  {
                     questionOptionLists.add(new SelectOption(res.id,res.Question_Label__c));
                  }                  
             }  System.debug('2~~setQuestions~question list'+  questionsLists .size());    
             
         }catch(Exception e){
             ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
         }      
    }
    
    public void setAnswers(){
    
        System.debug('1~~~~setAnswers'+templateid+',sec'+sectionid);System.debug('~~~questionid'+questionid);
        if((templateid!=null)&&(sectionid!=null)&&(questionid!=null)&&(questionid!='None')&&(questionid!='All')&&(sectionid!='None')&&(templateid!='None'))
        {
            //assuming always new record is created for edit we will provide separate functionality
            /*ansLists = [Select id,Response__c,Question_Template__r.Section_Question__r.id,Question_Template__c,Account_to_Response__c,Issue_Request__c,Questionnaire_Taker_user__c,(SELECT Id,Title,body,CreatedDate,Owner.FirstName,Owner.LastName FROM Notes order by CreatedDate)  from Questionnaire_Response__c where Issue_Request__c=:issueId AND Question_Template__r.Section_Question__r.id=:questionid]; 
            
            if(ansLists.size()==0)
            {*/
                ansOptionLists  = new List<SelectOption>();  
                response.Issue_Request__c=issueId;
                //response.Account_to_Response__c=accountId;
                System.debug('2~~~'+questionid+'~~~~');
                if(questionsLists != null && questionsLists.size()>0)
                {
                 for(Question_Template__c res: questionsLists ) 
                  {System.debug('3~~~'+questionid+'~~~~'+res.id);
                   if(questionid==res.id)
                   {response.Question_Template__c=res.id; selectedQuestion=res;
                     if(res.Question_Type__c.equalsIgnoreCase('RadioPicklist') )
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
                                 } else  if( res.Answer_Options__r.size() > 0 ){
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
                                if ( ls.size() > 0){
                                    for(String s: ls) 
                                    {                   
                                        ansOptionLists.add(new SelectOption(s,s));                   
                                    }
                                }
                                //System.debug('-----multi:'+   qoptionValues); 
                                           
                         }       
                    break;
                   }
                   
                  }//for(Question_Template__c res: questionsLists ) 
                }//if(questionsLists .size()>0)
         
           //return options;
        }
        else
        { 
        if(questionid=='All'){}
        }System.debug('-end set ans');
    }
     public PageReference cancel()
     {
        //PageReference cancelClicked=new PageReference(ApexPages.currentPage().getUrl());
       String urlform='/apex/MultiMultiAssessmentManager?accid='+accountId+'&id='+issueId+'&accname='+System.currentPageReference().getParameters().get('accname');          
      //MultiAssessmentManager?accid=001G000001FrCLc&accname=George+Marshall+High+School&issueid=a0JG000000Q3Dqg
        PageReference cancelClicked=new PageReference(urlform);
        cancelClicked.setRedirect(true);
        return cancelClicked;
     }
     public void createNotes(Questionnaire_Response__c responseObj,map<string, string>formsubparams)
       {
       Note[] attachnotes=new Note[]{};
      
             for(string keyName: formsubparams.keySet()) 
                {
                                        
                    if((keyName.startsWith(responseObj.Question_Template__c))&&(keyName.contains('noterow')))
                      {   
                         System.debug('-------NOTES IFformsubparams.get(keyName):'+formsubparams.get(keyName));
                         if((formsubparams.get(keyName)!=null)&&(formsubparams.get(keyName)!=''))
                           {
                              note n = new note();
                              n.parentId= responseObj.id;                                               
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
                               
                             }
                          }
                     }
                    
                        upsert attachnotes;
                    
       }

     public PageReference save()
     {  
         //call inner save for saving all questions and below logic for one by one
         try{
             System.debug('SAVE selectedQuestion'+selectedQuestion);
             map<string, string> formparams = ApexPages.currentPage().getParameters();
             map<string, string> formsubparams=new map<string,string>();
             Questionnaire_Response__c[] responseLists=new Questionnaire_Response__c[]{}; 
             for(string keyName: formparams.keySet()) {
                if(keyName.contains('row'))
                {
                    formsubparams.put(keyName,formparams.get(keyName));
                    System.debug('~~~~~~~~~~in ' + keyName + ': ' + formparams.get(keyName));
                }
                else
                {//System.debug('~~~~~~~~~~in ' + keyName + ': ' + formparams.get(keyName));
                }
            }
             if(issueId==null)
             {
             issueId= System.currentPageReference().getParameters().get('id');
             }
             if(accountId==null)
             {
             accountId=System.currentPageReference().getParameters().get('accid');//to get the parent school or account id
             }
             if(accountName==null)
             {
             accountName=System.currentPageReference().getParameters().get('accname');
             }
             if(selectedQuestion==null)
             {
                QuestionDisplay l=new QuestionDisplay(); 
               
                //l.innerSave(listQuestWithOptions,accountId,issueId,formsubparams);  
             }
             else
             {
             //one question at a time
             System.debug('~~ALWAYS HERE IN SAVE NO INNERSAVE CALLED EVERcreate new response'+selectedQuestion.Subquestion_Label__c+','+selectedQuestion.Weight_of_Answer__c);
             //System.debug('create new allFileList '+allFileList );
             System.debug('create new resp'+response);
             System.debug('~~~SEECTED ACCOUNTS'+selectedAccountLists);
             response.Questionnaire_Taker_user__c=UserInfo.getUserId();                   
             //For taking the weights from the question table and assigning the appropriate one to response field of weight
             List<String> qoptionvalue=new List<String>{};
             List<String> wtoptionvalue=new List<String>{};
             
             if ( selectedQuestion.Answer_Options__r.size() == 0  ){         
                 String qoption=selectedQuestion.Subquestion_Label__c;
                 if(qoption!=null){qoptionvalue=qoption.split('~');}
                 String wtoption=selectedQuestion.Weight_of_Answer__c;
                 if(wtoption!=null){wtoptionvalue=wtoption.split('~');}                  
             } else {
                 for( Answer_Option__c ansOpt :selectedQuestion.Answer_Options__r ){
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
             //System.debug('~~~~~~~~~before assigningwtoptionvalue'+wtoptionvalue+',qoptionvalue:'+qoptionvalue); 
             //for multilist
             //if its mutiselect is not null than put logic to store with tilde sign   
             String[] str=multi; System.debug('~~~~~~~~~after assigning');          
             String s='';
             double multireswt=0;
             if((str!=null)&&(str.size()>0))
                {System.debug('qqqqqqqq SAVING RECmulti');
                 if(selectedQuestion.Question_Type__c.equalsIgnoreCase('MultiselectPicklist'))
                     {
                        response.Weight_Response__c=-1;
                                                           
                     }
                  for(integer i = 0; i < str.size(); i++) 
                    {
                        s=str[i]+'~'+s;
                        //for multiselect weight
                    }
                  if(s.endsWithIgnoreCase('~'))
                    {
                        s=s.substring(0,s.length()-1);
                        // s=s.trim();
                        // System.debug('qqqqqqqq SAVING RECORDnewSetStr ============ ' + s);
                        response.Response__c=s;
                     }
                 }
                 else
                 {
                     System.debug('qqqqqqqq SAVING RECORDnewSetStr ============ ' +response.Response__c); 
                     if((response.Response__c!=null))
                        {
                            if(selectedQuestion.Question_Type__c.equalsIgnoreCase('RadioPicklist') )
                            {
                                for(integer i = 0; i< qoptionvalue.size(); i++)
                                {      System.debug('qqqqqqqq SAVINGqoptionvalue'+qoptionvalue+',wtoptionvalue'+wtoptionvalue);                                           
                                    if((response.Response__c).equalsIgnoreCase(qoptionvalue.get(i)))
                                    {
                                        if((response.Response__c).equalsIgnoreCase('N/A')||(response.Response__c).equalsIgnoreCase('NA'))
                                        {
                                        response.Weight_Response__c=-1;
                                        }
                                        else
                                        {
                                        if(wtoptionvalue.size()>0)
                                        {
                                        response.Weight_Response__c=Double.valueOf(wtoptionvalue.get(i).trim());System.debug('response.Weight_Response__c='+response.Weight_Response__c);break; 
                                        }}
                                    } 
                                }
                            }
                            else
                            {
                            response.Weight_Response__c=-1;
                            }
                                                        
                         }
                                        
               }//else 
               System.debug('FINA selectedAccountLists'+selectedAccountLists);
               Questionnaire_Response__c rRecord;
                 for(String acc: selectedAccountLists)  
                {//create the same response for all accounts selected
               
                rRecord=new Questionnaire_Response__c(); 
                //rRecord=response;
                rRecord.Questionnaire_Taker_user__c=response.Questionnaire_Taker_user__c;
                rRecord.Account_to_Response__c=acc;
                rRecord.Weight_Response__c=response.Weight_Response__c;
                rRecord.Response__c=response.Response__c;
                rRecord.Issue_Request__c=response.Issue_Request__c;
                rRecord.Priority__c=response.Priority__c;
                rRecord.Question_Template__c=response.Question_Template__c;
                rRecord.Weight_Response__c=response.Weight_Response__c;
                rRecord.Responsible_Party__c=response.Responsible_Party__c;
                //System.debug('FINA selectedAc'+acc);
                System.debug('FINA respRecord'+rRecord);
                responseLists.add(rRecord);
                System.debug('FINAresponseLists'+responseLists);
                }
                
                
                SFDCAccessController accessForSSupsert = ExAMUtilClass.AccessController;
                List<String> fieldsListSSInsert = new List<String>{'ExAM__Question_Template__c', 'ExAM__Questionnaire_Taker_user__c', 'ExAM__Account_to_Response__c','Exam__Issue_Request__c', 'ExAM__Response__c','ExAM__Weight_Response__c','ExAM__Question_Type__c','ExAM__Priority','ExAM__Responsible_Party__c'};
                accessForSSupsert.assertAuthorizedToCreate(Schema.getGlobalDescribe().get('exam__Questionnaire_Response__c'), fieldsListSSInsert);
    
                accessForSSupsert.assertAuthorizedToUpdate(Schema.getGlobalDescribe().get('exam__Questionnaire_Response__c'), fieldsListSSInsert);
                System.debug('FINALLLLLLL RESPONSE   -------ALL RECORD TO BE UPSERTED!!!'+responseLists);
                
                upsert responseLists;
                          
               //to call create notes 
               /*createNotes(response,formsubparams);
               List<Attachment> insertFileList =new List<Attachment>() ;
               for(Integer i = 0 ; i <= 4 ; i++)  
                {
                if(allFileList[i].body!=null)
                {
                allFileList[i].parentId=response.id;
                insertFileList.add(allFileList[i]) ; 
                }
                }
                if(insertFileList .size()>0) {
                    upsert insertFileList;
                }
               for(Integer i = 0 ; i <= 4 ; i++)  
                {allFileList.add(new Attachment()) ; } */
            }
        }
        catch(Exception e){ 
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
            System.debug(' SUMIT FOR APPROVAl---------- exception'+e);
        }
        String urlform='/apex/MultiMultiAssessmentManager?accid='+accountId+'&id='+issueId+'&accname='+System.currentPageReference().getParameters().get('accname');          
        //MultiAssessmentManager?accid=001G000001FrCLc&accname=George+Marshall+High+School&issueid=a0JG000000Q3Dqg
        PageReference cancelClicked=new PageReference(urlform);
        cancelClicked.setRedirect(false);
        return cancelClicked;
    }
                
    public PageReference home()
    {
        PageReference cancelClicked;
        String userAgent =ApexPages.currentPage().getHeaders().get('USER-AGENT');
        if(userAgent.contains('iPhone')) {
            cancelClicked=new PageReference('/one/one.app');
        }
        else {
            cancelClicked=new PageReference('/home/home.jsp');
        }
        cancelClicked.setRedirect(true);
        return cancelClicked;  
    }

    public void createSubAccount()
    {
    }

    public PageReference subApproval()
    {
        // save();
        try
        {
            issueId= System.currentPageReference().getParameters().get('id');

            SFDCAccessController accessForobj = ExAMUtilClass.AccessController;
            List<String> fieldsList = new List<String>{'ExAM__Assessor_Resource__c','ExAM__Assessment_Form_Completion__c','ExAM__Date_Completed__c','ExAM__Status__c'};
            accessForobj.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam_IssueRequest_Life_Cycle__c'), fieldsList);

            IssueRequest_Life_Cycle__c issuerecord=[Select id,Assessor_Resource__c,Assessment_Form_Completion__c,Date_Completed__c,Status__c from IssueRequest_Life_Cycle__c where id = :issueId];
            if(issuerecord!=null)
            {
                issuerecord.Assessment_Form_Completion__c='Complete';
                //issuerecord.Status__c ='Closed';
                accessForobj.assertAuthorizedToCreate(Schema.getGlobalDescribe().get('exam_IssueRequest_Life_Cycle__c'), fieldsList);
                accessForobj.assertAuthorizedToUpdate(Schema.getGlobalDescribe().get('exam_IssueRequest_Life_Cycle__c'), fieldsList);
                upsert issuerecord;
            }
            /*
            Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
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
            }
            */
        }catch(Exception e){ 
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
            System.debug(' SUMIT FOR APPROVAl---------- exception'+e);
        }
        /*
        try{
            folder[] ff = [select id,name from folder where name = 'Assessment Manager'];
            System.debug('~~~~~~~~~~~~~:'+ff);
            id fid = (ff.isEmpty()) ? null : ff[0].id;
            list<Report> listReports = [select id, name from report where ownerid = : fid and name='Assignment Manager with Responses'];
            System.debug('docid:'+listReports);
            PageReference cancelClicked=new PageReference('/'+listReports [0].id);
            cancelClicked.setRedirect(false);
            return cancelClicked;
        }
        catch(Exception e){}
        */
        PageReference cancelClicked=new PageReference('/'+issueId);
        cancelClicked.setRedirect(true);
        return cancelClicked;
    }
 
    public static testMethod void MultiMultiAssessmentManager_Test() {

        //Test converage for the visualforce page
        PageReference pageRef = Page.MultiMultiAssessmentManager;
        Test.setCurrentPageReference(pageRef);

        Test.startTest();

        Section_Group__c maintestg=new Section_Group__c(Group_Name__c ='test');
        upsert maintestg;

        Account acc=new Account(name='test account1',Create_Survey__c=true); upsert acc; 
        Main_questionaire__c maintest=new Main_questionaire__c (Template_name__c ='test',TemplateFlag__c=true);
        upsert maintest;
        Account accchild=new Account(name='test account2',Create_Survey__c=true,parentid=acc.id); upsert accchild; 
        Section_Template__c sc= new Section_Template__c(Questionnaire_Section__c=maintest.id,Section_label__c='test section'); 
        insert sc;
        Section_Template__c sc1= new Section_Template__c(Questionnaire_Section__c=maintest.id,Section_label__c='test section 2'); 
        insert sc1;
        Section_Group_Section_Relation__c  sgrelation=new Section_Group_Section_Relation__c (Section_Group__c=maintestg.id,Default_Section__c=true,Section_Active__c=true,Section_Template__c=sc.id);
        upsert sgrelation;
        Question_Template__c scq= new Question_Template__c(Section_Question__c=sc.id,Question_Label__c='What is your name?',Question_Order_No__c=1,Question_Type__c='Text',Focus_category__c='CCTV',Weight_of_Answer__c='4');     
        Question_Template__c scqp= new Question_Template__c(Section_Question__c=sc.id,Question_Label__c='What is your age?',Question_Order_No__c=2,Weight_Of_Question__c=2,Question_Type__c='RadioPicklist',Subquestion_Label__c='10-30~31-50',Focus_category__c='Perimeter',Weight_of_Answer__c='2~3');     
        Question_Template__c scqm= new Question_Template__c(Section_Question__c=sc.id,Question_Label__c='What is your qualification?',Question_Order_No__c=3,Question_Type__c='MultiselectPicklist',Subquestion_Label__c='High School~Bachelors~Masters',Focus_category__c='Emergency Response Plan',Weight_of_Answer__c='2~3~4');
        insert scq;insert scqp;insert scqm;
        String q1id=scq.id;
        String q2id=scqp.id;
        String q3id=scqm.id;

        System.currentPageReference().getParameters().put(q1id+'noterow1','Comment: test1');
        System.currentPageReference().getParameters().put(q2id+'noterow1','Recommendation: test1');
        IssueRequest_Life_Cycle__c issuetest=new IssueRequest_Life_Cycle__c(Facility_Name__c=acc.id,InvestigationType__c=maintest.id);
        insert issuetest; 
        System.currentPageReference().getParameters().put('accid',acc.id);
        System.currentPageReference().getParameters().put('accname',acc.name);
        ApexPages.CurrentPage().getparameters().put('id', issuetest.id) ;            
        ApexPages.StandardController scont = new ApexPages.StandardController(issuetest);
        MultiMultiAssessmentcontroller   d= new MultiMultiAssessmentcontroller  (scont ); 
        d.alltemplateLists.add(maintestg);

        d.issueid=issuetest.id;
        d.accountId=acc.id;
        d.accountName=acc.name;

        System.currentPageReference().getParameters().put('templateid', maintestg.id);          

        System.currentPageReference().getParameters().put('sectionid', sc.id);
        d.selectedQuestion=scqp;

        d.templateid=maintest.id;

        d.setSections();
        d.sectionid=sc.id;
        d.setQuestions(); d.getquestionsList();
        d.questionid=d.selectedQuestion.id;d.setAnswers();

        //d.response.Question_Template__c=d.selectedQuestion.id;
        d.save();d.subApproval();d.cancel();
        ApexPages.currentPage().getHeaders().put('USER-AGENT','iPhone');d.home();

        //multiselect
        scont = new ApexPages.StandardController(issuetest);
        d= new MultiMultiAssessmentcontroller  (scont ); 
        d.alltemplateLists.add(maintestg);             
        d.issueid=issuetest.id;
        System.currentPageReference().getParameters().put('accid',acc.id);
        System.currentPageReference().getParameters().put('accname',acc.name);
        d.accountId=acc.id;
        d.templateid=maintest.id;
        d.sectionid=sc.id;d.questionid='All';
        //d.sectionsLists=new List<Section_Template__c>();
        //d.questionsLists=new List<Question_Template__c >();
        //d.sectionsLists.add(sc);//d.sectionsLists.add(sc1);
        //d.questionsLists.add(scq);d.questionsLists.add(scqp);d.questionsLists.add(scqm);

        d.selectedQuestion=null;
        //d.selectedQuestion.id;
        d.setSections();d.setQuestions();
        d.setAnswers();
        d.getquestionsList();
        System.assert(d.getquestionsList()!=null,'questionslist not null');
        d.save();

        //System.assert(d.setwtTemplate()==null,'sectionslist returns  null');
        Test.stopTest();
    }
}