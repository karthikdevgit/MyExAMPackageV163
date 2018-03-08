public with sharing class MultiAssessmentcontroller {
  
    public string questionid{get;set;}
    public string sectionid{get;set;}
    public string templateName{get;set;}
    public string templateid{get;set;}
    public string issueId{get;set;}
    public string accountId{get;set;}
    public string accountName{get;set;}

    public Question_Template__c selectedQuestion{get;set;}
    public Questionnaire_Response__c response{get;set;}
    //public Account  acc{ get; set; }//this is the child account of the main school i.e room1,room2,play area etc   

    public string[] multi{get;set;}
    public List<Account> childAccountLists { get; set; }
    //public List<Section_Template__c > sectionsLists{ get; set; }
    public List<Question_Template__c> questionsLists { get; set; }
    public List<Questionnaire_Response__c> responseObjects { get; set; }
    public List<Questionnaire_Response__c> ansLists{ get; set; }
    public List<Section_Group_Section_Relation__c> group_sectionlist { get; set; }
    public List<Section_Group__c> alltemplateLists { get; set; }

    public List<SelectOption> childAccOptionLists { get; set; }
    public List<SelectOption> questionOptionLists { get; set; }
    public List<SelectOption> ansOptionLists { get; set; }
    public List<SelectOption> sectionOptionLists { get; set; }
    public List<SelectOption> templateLists { get; set; }

    public List<QuestionDisplay> listQuestWithOptions;  
    public List<Attachment> allFileList {get; set;} //max 5
   
    public MultiAssessmentcontroller (ApexPages.StandardController controller)
    {   
        try{
            templateLists =new List<SelectOption>();
            sectionOptionLists =new List<SelectOption>();
            questionOptionLists =new List<SelectOption>();
            sectionOptionLists =new List<SelectOption>();
            questionOptionLists =new List<SelectOption>();
            childAccOptionLists =new List<SelectOption>();
            allFileList = new List<Attachment>() ;
            responseObjects = new List<Questionnaire_Response__c>();  
            multi= new string[]{};
            // allFileList.clear() ;  
            //Adding multiple attachments instance  
            for(Integer i = 0 ; i <= 4 ; i++)  
            {allFileList.add(new Attachment()) ; }
            issueId= System.currentPageReference().getParameters().get('id');
            accountId=System.currentPageReference().getParameters().get('accid');//to get the parent school or account id
            accountName=System.currentPageReference().getParameters().get('accname');
            childAccountLists =[select id,name,parentid from account where parentid=:accountId];
            System.debug('~~1~~'+accountId+','+accountName+',,,'+childAccountLists );
            // childAccOptionLists.add(new SelectOption(childAccountLists[0].parent.id,childAccountLists[0].parent.name));
            childAccOptionLists.add(new SelectOption(accountId,accountName));
            //childAccountLists =[Select ID,name (Select id,parentid,name From accounts__r) From Account WHERE id =:accountId];
            for(Account res: childAccountLists ) 
            {
                //System.debug('~~~1 res.Weight_Template__c'+res.Template_name__c );
                childAccOptionLists.add(new SelectOption(res.id,res.name ));                     
            }
            response=new Questionnaire_Response__c(); 
            ansOptionLists  = new List<SelectOption>();  

            SFDCAccessController accessForobj = ExAMUtilClass.AccessController;
            List<string> fieldsList = new List<string>{'ExAM__Group_Name__c'};
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
            multi= new string[]{};
            if((templateid!=null)&&(templateid!='None'))
            {
                if(sectionOptionLists!=null){sectionOptionLists =new List<SelectOption>();}
                //Get all the sections listSelect Id, Name From Object2 Where Id = :Object1.field1__c
                // sectionsLists = [Select Id, Name,status__c,Section_Weight__c,Section_label__c,(Select id,Section_Group__c,Section_Template__c,Default_Section__c,Section_Active__c from Section_Template_Junction__r where Section_Group__c=:templateid)from  Section_Template__c Where Id IN : (Select Section_Template__c From Section_Template_Junction__r)  ];
                //sectionsLists = [Select Id, Name,status__c,Section_Weight__c,Section_label__c from Section_Template__c where Section_Group_Section_Relation__r.Section_Group__c=:templateid];

                SFDCAccessController accessForobj = ExAMUtilClass.AccessController;
                List<string> fieldsList = new List<string>{'ExAM__Section_Group__c','ExAM__Default_Section__c','ExAM__Section_Active__c','ExAM__Section_Template__c'};
                accessForobj.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Section_Group_Section_Relation__c'), fieldsList); 
              
                group_sectionlist = [Select id,Section_Group__c,Default_Section__c,Section_Active__c,Section_Group__r.id,Section_Template__c,Section_Template__r.Section_label__c,Section_Template__r.id from Section_Group_Section_Relation__c where Section_Group__c=:templateid AND Section_Active__c=true];
                //sectionsLists.add();
                System.debug('~~~group_sectionlist list'+  group_sectionlist.size());  
                sectionOptionLists.add(new SelectOption('None','None'));
                for(Section_Group_Section_Relation__c  res: group_sectionlist ) 
                {
                    sectionOptionLists.add(new SelectOption(res.Section_Template__r.id,res.Section_Template__r.Section_label__c));
                    if(res.Default_Section__c==true)
                    {
                        sectionid=res.Section_Template__r.id;questionid='All'; 
                    }
                }
                //setAllQuestions();
                /*
                for(Section_Template__c res: sectionsLists ) 
                {
                    sectionOptionLists.add(new SelectOption(res.id,res.Section_label__c));
                }
                */
                //System.debug('~~~section list'+  sectionsLists.size());                
            }
            questionsLists=null;  
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
        public string questionFlag{get;set;}//default
        public List<SelectOption> optionsList{get;set;} 
        public string sectionLabel{get;set;}
        public string[] multiselectlist{get;set;} 
        public string acctId{get;set;}        
        public string issueId{get;set;}
        
        public QuestionDisplay(Question_Template__c question,List<SelectOption> subQuestionOption,Questionnaire_Response__c responseObj,string[] multi)
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
        public void innerSave(List<QuestionDisplay> qdisplist,string accountId,string issueid,map<string, string> formsubparams) {
            try {
                //Section_Template__c =:listQuestWithOptions[0].newquestFormat.Section_Question__r.id
                acctId=accountId;  
                issueId=issueid;
                Questionnaire_Response__c[] responseLists=new Questionnaire_Response__c[]{}; 
                //Give all responses for this section and account
                //Questionnaire_Response__c[] reponseObjects=[Select id,Response__c,Question_Template__r.Section_Question__r.id,Question_Template__r.Weight_of_Answer__c,Question_Template__c,Account_to_Response__c,Issue_Request__c,Weight_Response__c,Questionnaire_Taker_user__c,(SELECT Id,Title,body,CreatedDate,Owner.FirstName,Owner.LastName FROM Notes order by CreatedDate)  from Questionnaire_Response__c where Issue_Request__c=:issueId AND Account_to_Response__c=:acctId AND Question_Template__r.Section_Question__r.id=:qdisplist[0].newquestFormat.Section_Question__r.id]; 
                //TO get both notes and attachments--- List<CombinedAttachMent> n=oo.CombinedAttachments;
                Note[] attachnotes=new Note[]{};

                for(QuestionDisplay t: qdisplist)
                {
                    Questionnaire_Response__c respRecord=new Questionnaire_Response__c(); 
                    System.debug('create new record');
                    respRecord.Question_Template__c = t.newquestFormat.id;
                    respRecord.Questionnaire_Taker_user__c=UserInfo.getUserId();
                    System.debug('!!!!!!!!!!!~~~~~~~~~~!!!!!!!!!!!new record account'+accountId);
                    respRecord.Account_to_Response__c=accountId;
                    respRecord.Issue_Request__c=issueId; 
                    //For taking the weights from the question table and assigning the appropriate one to response field of weight
                    List<string> qoptionvalue=new List<string>{};
                    List<string> wtoptionvalue=new List<string>{};

                    if ( t.newquestFormat.Answer_Options__r.size() == 0 ){
                        string qoption=t.newquestFormat.Subquestion_Label__c;
                        if(qoption!=null){qoptionvalue=qoption.split('~');}
                        string wtoption=t.newquestFormat.Weight_of_Answer__c;
                        if(wtoption!=null){wtoptionvalue=wtoption.split('~');}                  
                    } else {
                        for( Answer_Option__c ansOpt :t.newquestFormat.Answer_Options__r ){
                            if ( ansOpt != null ){
                                if ( ansOpt.Name != null && ansOpt.Name !='' ){
                                    qoptionvalue.add(ansOpt.Name);
                                }
                                if ( ansOpt.Weight__c != null ){    
                                    wtoptionvalue.add(string.valueOf(ansOpt.Weight__c));
                                }
                            }
                        }
                    }
                    //for multilist
                    //if its mutiselect is not null than put logic to store with tilde sign   
                    string[] str=t.multiselectlist;           
                    string s='';

                    double multireswt=0;
                    if(str!=null)
                    {
                        if(t.newquestFormat.Question_Type__c.equalsIgnoreCase('MultiselectPicklist'))
                        {
                            respRecord.Weight_Response__c=-1;
                            for(integer i = 0; i < str.size(); i++) 
                            {
                                s=str[i]+'~'+s;
                            }
                            if(s.endsWithIgnoreCase('~'))
                            {
                                s=s.substring(0,s.length()-1);
                                respRecord.Response__c=s;
                            }
                        }
                        else
                        {
                            System.debug('qqqqqqqq SAVING RECORDnewSetStr ============ ' +t.resObj.Response__c);
                            respRecord.Response__c=t.resObj.Response__c;
                            // System.debug('qqqqqqqq SAVING RECORD BELOW ============ ' +respRecord.Response__c);
                            if((respRecord.Response__c!=null))
                            {
                                if ( t.newquestFormat.Question_Type__c.equalsIgnoreCase('RadioPicklist') )
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
                            }
                        }
                        responseLists.add(respRecord); System.debug('!!!'+respRecord);
                    }
                }//end for loop  
                //System.debug('-------ALL RECORD TO BE UPSERTED!!!'+responseLists);
                if(responseLists.size()>0)
                {
                    System.debug('-------ALL RECORD TO BE UPSERTEDresponseLists.size()>0!!!'+responseLists);

                    SFDCAccessController accessForSSupsert = ExAMUtilClass.AccessController;
                    List<string> fieldsListSSInsert = new List<string>{'ExAM__Question_Template__c', 'ExAM__Questionnaire_Taker_user__c', 'ExAM__Account_to_Response__c','Exam__Issue_Request__c', 'ExAM__Response__c','ExAM__Weight_Response__c','ExAM__Question_Type__c'};
                    accessForSSupsert.assertAuthorizedToCreate(Schema.getGlobalDescribe().get('exam__Questionnaire_Response__c'), fieldsListSSInsert);

                    accessForSSupsert.assertAuthorizedToUpdate(Schema.getGlobalDescribe().get('exam__Questionnaire_Response__c'), fieldsListSSInsert);
                    upsert responseLists;
                }

                //to call create notes and get existing notes
                //attachnotes=createNotes(responseLists,formsubparams);
            }catch(Exception e){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
            }
        }  
    }
     
    public List<QuestionDisplay> getquestionsList(){

        listQuestWithOptions= new QuestionDisplay[]{};Integer i=0;
        setQuestions();
        string accountId=System.currentPageReference().getParameters().get('accid'); //accId=accountId;
        string issueId= System.currentPageReference().getParameters().get('issueid');

        //questionsLists = [SELECT  Id,Section_Question__r.id,Question_Label__c,Question_Order_No__c,Question_Type__c,HelpText__c,Weight_of_Answer__c,Subquestion_Label__c FROM Question_Template__c where Section_Question__r.id=:sectionid order by Question_Order_No__c]; 

        List<Id> questionIds = new List<Id>();
        if(questionsLists !=NULL && questionsLists.size()>=1)
        { 
            /*
            for(Question_Template__c qids:questionsLists)
            {
                questionIds.add(qids.id);
                //System.debug('~~~~~~~~~id='+qids);responseObjects 
            }
            */
            for(Question_Template__c quest: questionsLists ) 
            {
                //allFileList.add(new Attachment()) ; 
                Note[] attachnotes=new Note[]{};
                Questionnaire_Response__c resp=new Questionnaire_Response__c();   
                //resp.Notes=  attachnotes;     
                List<SelectOption> options = new List<SelectOption>();         
                if(quest.Question_Type__c.equalsIgnoreCase('RadioPicklist') )
                {
                    string qoptionValues = '';
                    List<string> ls = new List<string>();
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
                        for(string s: ls) 
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
                    if (resp.Response__c == null) {
                         if (quest.Subquestion_Label__c != null && quest.Answer_Options__r.size() == 0 ) {
                             resp.Response__c = quest.Subquestion_Label__c;
                         } else if( quest.Answer_Options__r.size() > 0 ) {
                             resp.Response__c = quest.Answer_Options__r[0].Name;
                         }
                     }
                     listQuestWithOptions.add(new QuestionDisplay(quest,options,resp,null));             
                }
                else if(quest.Question_Type__c.equalsIgnoreCase('MultiselectPicklist'))
                {
                    string[] multilist = new string[]{};
                    string qoptionValues = '';
                    List<string> ls = new List<string>();
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
                        for(string s: ls) 
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
        return listQuestWithOptions;
    }

    public void setQuestions()
    {    
        try{
            
            System.debug('1~~~setQuestionsTemplate'+templateid+',sectionid'+sectionid);//questionsLists =null;
            questionOptionLists =new List<SelectOption>();
            ansOptionLists  = new List<SelectOption>();  
            multi= new string[]{};
            if((templateid!=null)&&(sectionid!=null)&&(sectionid!='None')&&(templateid!='None'))
            {
              //Get all the sections list
              SFDCAccessController accessForobj = ExAMUtilClass.AccessController;
              List<string> fieldsList = new List<string>{'ExAM__Question_Label__c','ExAM__Question_Order_No__c','ExAM__Question_Type__c','ExAM__HelpText__c','ExAM__Weight_of_Answer__c','ExAM__Subquestion_Label__c'};
              accessForobj.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam_Question_Template__c'), fieldsList); 
              questionsLists = [SELECT  Id,Section_Question__r.id,Question_Label__c,Question_Order_No__c,Question_Type__c,HelpText__c,Weight_of_Answer__c,
                                  Subquestion_Label__c,(SELECT Id,Name,Help_Text__c,Weight__c FROM Answer_Options__r) 
                                  FROM Question_Template__c 
                                  WHERE Section_Question__r.id=:sectionid ORDER BY Question_Order_No__c]; 
             questionOptionLists.add(new SelectOption('All','All'));questionid='All';
               for(Question_Template__c res: questionsLists ) 
                  {
                     questionOptionLists.add(new SelectOption(res.id,res.Question_Label__c));
                  }                  
             }  System.debug('2~~setQuestions~question list'+  questionsLists .size());
         }catch(Exception e){
             ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
         }       
    }
    
    public void setAnswers()
    {
    
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
                {
                    System.debug('3~~~'+questionid+'~~~~'+res.id);
                    if(questionid==res.id)
                    {
                        response.Question_Template__c=res.id; selectedQuestion=res;
                        if(res.Question_Type__c.equalsIgnoreCase('RadioPicklist') )
                        {
                            string qoptionValues = '';
                            List<string> ls = new List<string>();
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
                                for(string s: ls) 
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
                            string[] multilist = new string[]{};
                            string qoptionValues = '';
                            List<string> ls = new List<string>();
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
                                for(string s: ls) 
                                {                   
                                    ansOptionLists.add(new SelectOption(s,s));                   
                                }
                            }
                        }       
                        break;
                    }
                }//for(Question_Template__c res: questionsLists ) 
            }
            //if(questionsLists .size()>0)
            //return options;
        }
        else
        { 
            if(questionid=='All'){}
        }
        System.debug('-end set ans');
    }

    public PageReference cancel()
    {
        PageReference cancelClicked=new PageReference(ApexPages.currentPage().getUrl());
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
        //  SFDCAccessController accessForobj = ExAMUtilClass.AccessController;
        //  List<string> fieldsList = new List<string>{'ExAM__Question_Label__c','ExAM__Question_Order_No__c','ExAM__Question_Type__c','ExAM__HelpText__c','ExAM__Weight_of_Answer__c','ExAM__Subquestion_Label__c'};
        // accessForobj.assertAuthorizedToCreate(Schema.getGlobalDescribe().get('note'), fieldsList);

        upsert attachnotes;
    }

    public PageReference save()
    {  
        //call inner save for saving all questions and below logic for one by one
        try{
            System.debug('SAVE selectedQuestion'+selectedQuestion);
            map<string, string> formparams = ApexPages.currentPage().getParameters();
            map<string, string> formsubparams=new map<string,string>();
            for(string keyName: formparams.keySet()) {
                if(keyName.contains('row'))
                {
                    formsubparams.put(keyName,formparams.get(keyName));
                    System.debug('~~~~~~~~~~in ' + keyName + ': ' + formparams.get(keyName));
                }
                else
                {//System.debug('~~~~~~~~~~in ' + keyName + ': ' + formparams.get(keyName));}
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
                l.innerSave(listQuestWithOptions,accountId,issueId,formsubparams);  
            }
            else
            {
                //one question at a time
                System.debug('create new response'+selectedQuestion.Subquestion_Label__c+','+selectedQuestion.Weight_of_Answer__c);
                System.debug('create new allFileList '+allFileList );
                System.debug('create new resp'+response);
        
                response.Questionnaire_Taker_user__c=UserInfo.getUserId();                   
                //For taking the weights from the question table and assigning the appropriate one to response field of weight
                List<string> qoptionvalue=new List<string>{};
                List<string> wtoptionvalue=new List<string>{};

                if ( selectedQuestion.Answer_Options__r.size() == 0  ){         
                    string qoption=selectedQuestion.Subquestion_Label__c;
                    if(qoption!=null){qoptionvalue=qoption.split('~');}
                    string wtoption=selectedQuestion.Weight_of_Answer__c;
                    if(wtoption!=null){wtoptionvalue=wtoption.split('~');}                  
                } else {
                    for( Answer_Option__c ansOpt :selectedQuestion.Answer_Options__r ){
                        if ( ansOpt != null ){
                            if ( ansOpt.Name != null && ansOpt.Name !='' ){
                                qoptionvalue.add(ansOpt.Name);
                            }
                            if ( ansOpt.Weight__c != null ){    
                                wtoptionvalue.add(string.valueOf(ansOpt.Weight__c));
                            }
                        }
                    }
                }
                //System.debug('~~~~~~~~~before assigningwtoptionvalue'+wtoptionvalue+',qoptionvalue:'+qoptionvalue); 
                //for multilist
                //if its mutiselect is not null than put logic to store with tilde sign   
                string[] str=multi; System.debug('~~~~~~~~~after assigning');          
                string s='';
                double multireswt=0;
                if((str!=null)&&(str.size()>0))
                {
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
                            {
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
                                        }
                                    }
                                } 
                            }
                        }
                        else
                        {
                            response.Weight_Response__c=-1;
                        }
                    }
                }//else 
                    System.debug('-------ALL RECORD TO BE UPSERTED!!!'+response);
           
                    SFDCAccessController accessForSSupsert = ExAMUtilClass.AccessController;
                    List<string> fieldsListSSInsert = new List<string>{'ExAM__Question_Template__c', 'ExAM__Questionnaire_Taker_user__c', 'ExAM__Account_to_Response__c','Exam__Issue_Request__c', 'ExAM__Response__c','ExAM__Weight_Response__c','ExAM__Question_Type__c'};
                    accessForSSupsert.assertAuthorizedToCreate(Schema.getGlobalDescribe().get('exam__Questionnaire_Response__c'), fieldsListSSInsert);

                    accessForSSupsert.assertAuthorizedToUpdate(Schema.getGlobalDescribe().get('exam__Questionnaire_Response__c'), fieldsListSSInsert);

                    upsert response;

                    //to call create notes 
                    createNotes(response,formsubparams);
                    List<Attachment> insertFileList =new List<Attachment>() ;
                    for(Integer i = 0 ; i <= 4 ; i++)  
                    {
                        if(allFileList[i].body!=null)
                        {
                            allFileList[i].parentId=response.id;
                            insertFileList.add(allFileList[i]) ; 
                        }
                    }
                    if(insertFileList .size()>0){
                        upsert insertFileList;
                    }
                    for(Integer i = 0 ; i <= 4 ; i++)  {
                        allFileList.add(new Attachment());
                    }
                }
            }
        }catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        }
        string urlform='/apex/MultiAssessmentManager?accid='+accountId+'&id='+issueId+'&accname='+System.currentPageReference().getParameters().get('accname');          
        //MultiAssessmentManager?accid=001G000001FrCLc&accname=George+Marshall+High+School&issueid=a0JG000000Q3Dqg
        PageReference cancelClicked=new PageReference(urlform);
        cancelClicked.setRedirect(true);
        return cancelClicked;
    }
                
    public PageReference home()
    {
        PageReference cancelClicked;
        string userAgent =ApexPages.currentPage().getHeaders().get('USER-AGENT');
        if(userAgent.contains('iPhone')) {
            cancelClicked=new PageReference('/one/one.app');
        }
        else {
            cancelClicked=new PageReference('/home/home.jsp');
        }
        cancelClicked.setRedirect(true);
        return cancelClicked;  
    }

    public PageReference subApproval()
    {
        // save();
        try
        {
            issueId= System.currentPageReference().getParameters().get('id');

            SFDCAccessController accessForobj = ExAMUtilClass.AccessController;
            List<string> fieldsList = new List<string>{'ExAM__Assessor_Resource__c','ExAM__Assessment_Form_Completion__c','ExAM__Date_Completed__c','ExAM__Status__c'};
            accessForobj.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam_IssueRequest_Life_Cycle__c'), fieldsList);

            IssueRequest_Life_Cycle__c issuerecord=[Select id,Assessor_Resource__c,Assessment_Form_Completion__c,Date_Completed__c,Status__c from IssueRequest_Life_Cycle__c where id= :issueId];
            if(issuerecord!=null)
            {
                issuerecord.Assessment_Form_Completion__c='Complete';
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
            System.debug(' SUMIT FOR APPROVAl---------- exception'+e);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
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
 
    public static testMethod void MultiAssessmentManager_Test()
    {
        //Test converage for the visualforce page
        PageReference pageRef = Page.MultiAssessmentManager;
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
        string q1id=scq.id;
        string q2id=scqp.id;
        string q3id=scqm.id;

        System.currentPageReference().getParameters().put(q1id+'noterow1','Comment: test1');
        System.currentPageReference().getParameters().put(q2id+'noterow1','Recommendation: test1');
        IssueRequest_Life_Cycle__c issuetest=new IssueRequest_Life_Cycle__c(Facility_Name__c=acc.id,InvestigationType__c=maintest.id);
        insert issuetest; 
        System.currentPageReference().getParameters().put('accid',acc.id);
        System.currentPageReference().getParameters().put('accname',acc.name);
        ApexPages.CurrentPage().getparameters().put('id', issuetest.id) ;            
        ApexPages.StandardController scont = new ApexPages.StandardController(issuetest);
        MultiAssessmentcontroller  d= new MultiAssessmentcontroller (scont ); 
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
        d= new MultiAssessmentcontroller (scont ); 
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