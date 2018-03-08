public with sharing class ExportAMController {

    String assessmentTemplateId;
    String assessmentTempType;
    String assessmentTempStart;
    String assessmentTempEnd;
    
    String amCreatedStartDate;
    String amCreatedEndDate;
    
        
    Map<Id, AssignmentManager> AMIdValueMap = new Map<Id, AssignmentManager>();
    public String assessmentTemplateJSON { get; set; }
    
    //Inner class for Assignment Manager
    public class AssignmentManager{
    
        public String recName { get; set; }
        public String recId { get; set; }
        public String acctId { get; set; }
        public String accessibleObjectId { get; set; }
        public String assessmentTemplateType { get; set; }
        public List<Section> sectionList { get; set; }
        //public List<QA> QAList { get; set; }
        //public List<AttachedFile> AttachedFileList { get; set; }
    }
    
    public class AttachedFile{
    
        public Blob attachedPicture { get; set; }
        //public String attachedPicture { get; set; }
        public String Name { get; set; }
    }
    
    public class Section{
    
        public String sectionName { get; set; }
        public String sectionExternalId { get; set; }
        public String sectionId { get; set; }
        public List<Question> QuestionList { get; set; }
    }
    
    public class Question{
    
        public String questionName { get; set; }
        public String questionExternalId { get; set; }
        public String questionId { get; set; }
        public List<Answer> AnswerList { get; set; }
        //public String answerValue { get; set; }
    }
    
    public class Answer{
        public String answerId { get; set; }
        public String answerValue { get; set; }
        public String commentValue { get; set; }
    }
    
    public List<AssignmentManager> AMList{ get; set; }
    
    public ExportAMController(){
    
        try{
        SFDCAccessController accessForobj = ExAMUtilClass.AccessController;
        assessmentTemplateId = ApexPages.currentPage().getParameters().get('ATId');
        assessmentTempType = ApexPages.currentPage().getParameters().get('ATType');
        assessmentTempStart = ApexPages.currentPage().getParameters().get('ATStart');
        assessmentTempEnd = ApexPages.currentPage().getParameters().get('ATEnd');
        
        amCreatedStartDate = ApexPages.currentPage().getParameters().get('AMCreatedStart');
        amCreatedEndDate = ApexPages.currentPage().getParameters().get('AMCreatedEnd');
        
        if (assessmentTemplateId == null || assessmentTemplateId == '') {
        
            assessmentTemplateJSON = '';
            
            List<String> fieldsListAT = new List<String>{'ExAM__Template_name__c'};
            accessForobj.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Main_questionaire__c'), fieldsListAT);
            List<Main_questionaire__c> templateList = [SELECT Template_name__c, Id, Name FROM Main_questionaire__c Limit 1000];
            if (templateList != null && templateList.size() > 0) {
                assessmentTemplateJSON = JSON.serialize(templateList);
            }
        }
        
        system.debug('assessmentTempStart :::' + assessmentTempStart);
        DateTime startTime, endTime;
        if( assessmentTempStart != null && assessmentTempStart != '' && assessmentTempStart.split('/').size() == 3){
            
            String[] dateStr = assessmentTempStart.split('/');
            startTime = date.newinstance( Integer.valueOf(dateStr[2]), Integer.valueOf(dateStr[0]), Integer.valueOf(dateStr[1]) );
        } else {
            
            startTime = date.newinstance( Integer.valueOf('1900'), Integer.valueOf('01'), Integer.valueOf('01') );
        }
        system.debug('StartTime ::::' + startTime);
        
        if( assessmentTempEnd != null && assessmentTempEnd != '' && assessmentTempEnd.split('/').size() == 3){
        
            String[] dateStr2 = assessmentTempEnd.split('/');
            endTime = date.newinstance( Integer.valueOf(dateStr2[2]), Integer.valueOf(dateStr2[0]), Integer.valueOf(dateStr2[1]) );
            endTime = endTime.addDays(1);
        } else {
            
            endTime = system.now();
        }
        
        DateTime createdStartDate, createdEndDate;
        if( amCreatedStartDate != null && amCreatedStartDate != '' && amCreatedStartDate.split('/').size() == 3){
            
            String[] dateStr = amCreatedStartDate.split('/');
            createdStartDate = date.newinstance( Integer.valueOf(dateStr[2]), Integer.valueOf(dateStr[0]), Integer.valueOf(dateStr[1]) );
        } else {
            
            createdStartDate = date.newinstance( Integer.valueOf('1900'), Integer.valueOf('01'), Integer.valueOf('01') );
        }
        system.debug('createdStartDate ::::' +createdStartDate);
        
        if( amCreatedEndDate != null && amCreatedEndDate != '' && amCreatedEndDate.split('/').size() == 3 ){
        
            String[] dateStr2 = amCreatedEndDate.split('/');
            createdEndDate = date.newinstance( Integer.valueOf(dateStr2[2]), Integer.valueOf(dateStr2[0]), Integer.valueOf(dateStr2[1]) );
            System.debug('::::createdEndDate::::'+createdEndDate);
            createdEndDate = createdEndDate.addDays(1);
            System.debug('::::createdEndDate:::'+createdEndDate);
            
        } else {
            
            createdEndDate = system.now();
        }
        
        system.debug('createdEndDate ::::' + createdEndDate);
        
        System.debug('assessmentTemplateId ::::' + assessmentTemplateId );  
        
        AMList = new List<AssignmentManager>();
        
        List<String> fieldsList = new List<String>{'ExAM__Assessment_Template_Type__c'};
        accessForobj.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__IssueRequest_Life_Cycle__c'), fieldsList);
        
        List<String> fieldsList1 = new List<String>{'ExAM__Response__c','ExAM__Comment__c'};
        accessForobj.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Questionnaire_Response__c'), fieldsList1);
        
        List<String> fieldsList2 = new List<String>{'ExAM__Question_Label__c','ExAM__Section_Question__c'};
        accessForobj.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Question_Template__c'), fieldsList2);
        
        List<String> fieldsList3 = new List<String>{'ExAM__Section_label__c'};
        accessForobj.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Section_Template__c'), fieldsList3);
        
        if (assessmentTemplateId != null && assessmentTemplateId != '') {    
            for( IssueRequest_Life_Cycle__c assignManager : [ SELECT 
                                                                     Id, InvestigationType__c, Name, Scheduled_Start_Date__c, CreatedDate,
                                                                     Assessment_Template_Type__c, 
                                                                     (
                                                                      SELECT Id, Response__c, Comment__c,
                                                                             Question_Template__r.Question_Label__c,
                                                                             Question_Template__r.id,
                                                                             Question_Template__r.Section_Question__c,
                                                                             Question_Template__r.Section_Question__r.Section_label__c,
                                                                             Question_Template__r.Section_Question__r.id
                                                                      FROM Questionnaire_Response__r
                                                                      ORDER BY CreatedDate
                                                                     )
                                                                 FROM 
                                                                         IssueRequest_Life_Cycle__c 
                                                                 WHERE 
                                                                         InvestigationType__c = :assessmentTemplateId AND
                                                                         //Assessment_Template_Type__c = :assessmentTempType AND
                                                                         Scheduled_Start_Date__c >= :startTime AND
                                                                         Scheduled_Start_Date__c <= :endTime AND
                                                                         CreatedDate >= :createdStartDate AND
                                                                         CreatedDate <= :createdEndDate
                                                            ] ){
                
                //System.debug('assignManager :::' + assignManager.Id ); 
                                                       
                AssignmentManager tempAM = new AssignmentManager();
                tempAM.recName = assignManager.Name.escapeXml();
                tempAM.recId = assignManager.Id ;
                tempAM.assessmentTemplateType = assignManager.Assessment_Template_Type__c != null ? assignManager.Assessment_Template_Type__c.escapeXml() : assignManager.Assessment_Template_Type__c;
                
                List<Section> tempSectionList = new List<Section>();
                List<AttachedFile> tempAttachList = new List<AttachedFile>();
                Map<Id, List<Question> > sectionAnswerListMap = new Map<Id, List<Question> >();
                
                Map<Id, Section> sectionIdandSectionMap = new Map<Id, Section>();
                
                Map<Id, List<Answer>> questionIdwithListofAnswerMap = new Map<Id, List<Answer>>();
                Map<Id, Question> questionIdwithQuestionMap = new Map<Id, Question>();
                
                Map<Id, Map<Id, Question>> sectionIdwithMapOfquestionIdQuestionMap = new Map<Id, Map<Id, Question>>();

                for( Questionnaire_Response__c answers : assignManager.Questionnaire_Response__r ){
                    
                    //Create Section List and add Questions and Answers inside it
                    Section tempSection = sectionIdandSectionMap.get( answers.Question_Template__r.Section_Question__c ) != NULL ?
                                          sectionIdandSectionMap.get( answers.Question_Template__r.Section_Question__c ) :
                                          new Section();
                    //Section tempSection = new Section();
                        
                        if (tempSection.sectionName == null) { 
                            tempSection.sectionName = answers.Question_Template__r.Section_Question__r.Section_label__c != null ? answers.Question_Template__r.Section_Question__r.Section_label__c.escapeXml() : answers.Question_Template__r.Section_Question__r.Section_label__c ;
                            tempSection.sectionId = answers.Question_Template__r.Section_Question__r.id;
                        }
                        
                        List<Question> tempQuestionList = sectionAnswerListMap.get( answers.Question_Template__r.Section_Question__c ) != NULL ?
                                                          sectionAnswerListMap.get( answers.Question_Template__r.Section_Question__c ) :
                                                          new List<Question>();
                        
                        Question tempQuestion = new Question();
                        if (!questionIdwithQuestionMap.containsKey(answers.Question_Template__r.id)) {
                            tempQuestion.questionName = answers.Question_Template__r.Question_Label__c != null ? answers.Question_Template__r.Question_Label__c.escapeXml() : answers.Question_Template__r.Question_Label__c ;
                            tempQuestion.questionId = answers.Question_Template__r.id ;
                                
                            questionIdwithQuestionMap.put(answers.Question_Template__r.id, tempQuestion);
                        } 
                        tempQuestion = questionIdwithQuestionMap.get(answers.Question_Template__r.id);
                        
                        
                        Answer tempAns = new Answer ( );
                        tempAns.answerValue = answers.Response__c != null ? answers.Response__c.escapeXml() : answers.Response__c;
                        tempAns.commentValue = answers.Comment__c != null ? answers.Comment__c.escapeXml() : answers.Comment__c;
                        tempAns.answerId = answers.Id;
                        
                        if (!questionIdwithListofAnswerMap.containsKey(answers.Question_Template__r.id)) {
                            questionIdwithListofAnswerMap.put(answers.Question_Template__r.id, new List<Answer> ());
                        }
                        questionIdwithListofAnswerMap.get(answers.Question_Template__r.id).add(tempAns);
                        
                        
                        tempQuestion.AnswerList = new List<Answer>( questionIdwithListofAnswerMap.get(answers.Question_Template__r.id) );
                        
                        if (sectionIdwithMapOfquestionIdQuestionMap.containsKey( answers.Question_Template__r.Section_Question__c) 
                            &&  sectionIdwithMapOfquestionIdQuestionMap.get(answers.Question_Template__r.Section_Question__c).containsKey(answers.Question_Template__r.id)) {
                            
                            sectionIdwithMapOfquestionIdQuestionMap.get(answers.Question_Template__r.Section_Question__c).remove(answers.Question_Template__r.id);
                            
                        }
                        if (!sectionIdwithMapOfquestionIdQuestionMap.containsKey(answers.Question_Template__r.Section_Question__c)) {
                            sectionIdwithMapOfquestionIdQuestionMap.put(answers.Question_Template__r.Section_Question__c, new Map<Id, Question>());
                        }
                        sectionIdwithMapOfquestionIdQuestionMap.get(answers.Question_Template__r.Section_Question__c).put(answers.Question_Template__r.id, tempQuestion);
                        tempQuestionList = sectionIdwithMapOfquestionIdQuestionMap.get(answers.Question_Template__r.Section_Question__c).values();
                        
                        tempSection.QuestionList = tempQuestionList;
                        
                        
                        sectionAnswerListMap.put( answers.Question_Template__r.Section_Question__c, tempQuestionList );
                    
                    //System.debug('tempSection:::' + tempSection);
                    sectionIdandSectionMap.put( answers.Question_Template__r.Section_Question__c, tempSection );
                    
                    
                    
                }
                //System.debug('Outside for loop :: sectionIdandSectionMap:::' + sectionIdandSectionMap);
                //tempAM.QAList = tempQAList;
                tempAM.sectionList = new List<Section>();
                for( Section tempSection : sectionIdandSectionMap.values() ){
                    
                    tempAM.sectionList.add( tempSection );
                }
                //tempAM.sectionList = tempSectionList;
                AMList.add( tempAM );
                AMIdValueMap.put( assignManager.Id, tempAM );
            }
            
        } 
        
        //System.debug('AMList :::' + AMList );
    }catch(Exception e){
          ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
    }
    }
    
}