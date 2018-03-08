public with sharing class AssessmentTemplateController {
    
    
    @AuraEnabled
    public static List<Main_questionaire__c> fetchAssessment(String selectView) {
        
        List<Main_questionaire__c> assessmentTemp = AssessmentService.getAssessmentsByCurrentUser(selectView);
        
        return assessmentTemp; 
    }
    
    @AuraEnabled
    public static Main_questionaire__c archiveAssessment(Main_questionaire__c selAssessment){
        
        selAssessment = AssessmentService.archieveAssessment(selAssessment);
        return selAssessment;
    }
    
    @AuraEnabled
    public static Main_questionaire__c cloneAssessmentTemp(String recordId, String temp_name) {   
        Map<Id,String> assessmentIdWthTempName = new Map<Id,String>{recordId => temp_name};
        List<Main_questionaire__c> assessmentList = ExamManager.clone(assessmentIdWthTempName);
        String assessmentId = assessmentList[0].Id;
        AssessmentService.updateAssessmentDueToChildUpdates(assessmentId);
        String fields = 'Template_name__c, isArchive__c';
        FieldLevelSecurity.checkFieldAccessByCriteria(fields, 'view', 'Main_questionaire__c');
        assessmentList = [SELECT Id, Template_name__c, CreatedDate, LastModifiedDate FROM Main_questionaire__c WHERE Id =:assessmentId]; 
        return assessmentList[0];
    }
    
    
    @AuraEnabled
    public static List<Section_Template__c> fetchSecTemplate(String assessementId) {
        
        List<Section_Template__c> sectionTemplates = SectionService.getSectionsByAssessmentId(assessementId);
        return sectionTemplates;
    }
    
    @AuraEnabled
    public static String fetchSecTemplateWthSectionFieldSetValue(String sObjectName, List<String> fieldSets, String sObjectId) {
        
        Map<String,Object> containWrapObject = new Map<String,Object>();
        if(!fieldSets.isEmpty()){
            Map<String,List<WrapperFieldSet>> WrapperFieldSetList = new Map<String,List<WrapperFieldSet>>();
            for(String fieldSet : fieldSets){
                WrapperFieldSetList.put(fieldSet,ExamDescribeHelper.getFieldSetByRecord(fieldSet,sObjectName));
            }
            containWrapObject.put('fields',WrapperFieldSetList);
        }
        
        
        List<sObject> objList = ExamDescribeHelper.getRecordByFieldSet(sObjectName,fieldSets,sObjectId);
        
        List<Section_Template__c> sectionTemplates = (List<Section_Template__c>)objList;
        containWrapObject.put('sobject',sectionTemplates);
        return JSON.serialize(containWrapObject);
    }
    
    @AuraEnabled
    public static String fetchQuesTemplateWthQuestionFieldSetValue(String sObjectName, List<String> fieldSets, String sObjectId) {
        
        
        Map<String,Object> containWrapObject = new Map<String,Object>();
        if(!fieldSets.isEmpty()){
            Map<String,List<WrapperFieldSet>> WrapperFieldSetList = new Map<String,List<WrapperFieldSet>>();
            for(String fieldSet : fieldSets){
                WrapperFieldSetList.put(fieldSet,ExamDescribeHelper.getFieldSetByRecord(fieldSet,sObjectName));
            }
            containWrapObject.put('fields',WrapperFieldSetList);
        }
        
        
        List<sObject> objList = ExamDescribeHelper.getRecordByFieldSet(sObjectName,fieldSets,sObjectId);
        
        List<Question_Template__c> questionTemplates = (List<Question_Template__c>)objList;
        questionTemplates = QuestionService.filterGetNonDependentQuestions(questionTemplates);
        containWrapObject.put('sobject', questionTemplates);
        
        Map<Id, Question_Template__c> idWthQuestions = new Map<Id, Question_Template__c>(questionTemplates);
        Set<Id> questionIds = idWthQuestions.keySet();
        containWrapObject.put('attachment', AttachmentService.getAttachmentsByQuestionIds(questionIds));
        
        return JSON.serialize(containWrapObject);
    }
    
    @AuraEnabled
    public static List<String> getQuestionType(){
        
        List<String> options = new List<String>();
        Schema.DescribeFieldResult fieldResult = Question_Template__c.Question_Type__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
        for (Schema.PicklistEntry f: ple) {
            options.add(f.getLabel());
        }
        
        return options;
    }
    
    @AuraEnabled
    public static Map<String, List<Object>> createQuestionWthAnswer(Question_Template__c QuestionTemplate, Integer orderNo, List<Answer_Option__c> answerOptions){
        
        Map<String, List<Object>> QuestionWthAnswer = new Map<String, List<Object>>();
        Set<String> answerOptionIds = new Set<String>();
        List<Question_Template__c> questionTemplates = QuestionService.createQuestion(QuestionTemplate, orderNo);
        String questionId = questionTemplates[0].Id; // get Assessment Id
        Question_Template__c question = QuestionService.getQuestion(questionId);
        String assessmentId = question.Section_Question__r.Questionnaire_Section__c;
        questionId = questionTemplates[orderNo].Id;
        for(Answer_Option__c answer : answerOptions){
            answer.Question_Template__c = questionId;
        }
        try{
            String fields = 'Name, Dependent_Question__c, Order_No__c, Weight__c, Question_Template__c, Next_Question__c, Help_Text__c';
            FieldLevelSecurity.checkFieldAccessByCriteria(fields, 'create', 'Answer_Option__c');
            insert answerOptions;                               
        }
        catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
        
        // update Assessment
        AssessmentService.updateAssessmentDueToChildUpdates(assessmentId);
        
        QuestionWthAnswer.put('questions', QuestionService.filterGetNonDependentQuestions(questionTemplates));
        
        for(Answer_Option__c ans : answerOptions){
            answerOptionIds.add(ans.Id);
        }
        List<Answer_Option__c> questionOptions = AnswerOptionService.getAnswerOptionsWthRef(answerOptionIds);
        
        QuestionWthAnswer.put('answers', questionOptions);
        List<String> newQuestionId = new List<String>{questionId};
        QuestionWthAnswer.put('newQuestionId',newQuestionId);
        
        return QuestionWthAnswer;
    }
    
    @AuraEnabled
    public static List<Section_Template__c> createSection(Section_Template__c SectionTemplate, Integer orderNo){
        List<Section_Template__c> sectionTemplates = SectionService.createSection(SectionTemplate, orderNo);
        return sectionTemplates;
    }
    
    @AuraEnabled
    public static Main_questionaire__c createAssessment(Main_questionaire__c AssessmentTemplate, String selectView) {
        AssessmentTemplate = AssessmentService.createNewAssessment(AssessmentTemplate, selectView);
        return AssessmentTemplate;
    }
    
    
    @AuraEnabled
    public static Attachment saveFile(String attachmentId, String parentId, String fileName, String base64Data, String contentType) {
        
        Attachment attch = AttachmentService.saveAttachment(attachmentId, parentId, fileName, base64Data, contentType);
        attch.Body = null;
        String assessmentId = AnswerOptionService.getGrandParentsRef(attch.ParentId);
        AssessmentService.updateAssessmentDueToChildUpdates(assessmentId);
        return attch;
    }
    
    @AuraEnabled
    public static String updateAttachFile(String parentId, String fileName, String base64Data, String contentType){
        String attch = AttachmentService.saveFile(parentId, fileName, base64Data, contentType);
        AssessmentService.updateAssessmentDueToChildUpdates(parentId);
        return attch;
    }
    
    @AuraEnabled
    public static List<Attachment> fetchAttachment(String QuesId, List<String> answerOptionsId) { 
        List<Attachment> attachments;
        
        if(!answerOptionsId.isEmpty()){
            try{
                String fields = 'Name, ContentType, ParentId';
                FieldLevelSecurity.checkFieldAccessByCriteria(fields, 'view', 'Attachment');
                attachments =  [SELECT Id, Name, ContentType, ParentId FROM Attachment WHERE ParentId IN :answerOptionsId];
            }
            catch(Exception e){
                throw new AuraHandledException(e.getMessage());
            }
            
        }else if(QuesId != null){
            attachments = AttachmentService.getAttachmentsByParentId(QuesId);
            
        }
        
        return attachments;
    }
    
    @AuraEnabled
    public static String getRecordById(String sObjectName, List<String> fieldSets, String sObjectId) {   
        
        Map<String,List<WrapperFieldSet>> WrapperFieldSetList = new Map<String,List<WrapperFieldSet>>();
        
        Map<String,Object> containWrapObject = new Map<String,Object>();
        
        for(String fieldSet : fieldSets){
            WrapperFieldSetList.put(fieldSet,ExamDescribeHelper.getFieldSetByRecord(fieldSet,sObjectName));
        }
        
        List<sObject> objList = ExamDescribeHelper.getRecordByFieldSet(sObjectName,fieldSets,sObjectId);
        List<WrapperAttachment> attachments = AttachmentService.getAttachmentById(sObjectId);                       
        
        containWrapObject.put('fields',WrapperFieldSetList);
        containWrapObject.put('sobject',objList);
        containWrapObject.put('attachment',attachments);
        
        return JSON.serialize(containWrapObject);
    }
    
    @AuraEnabled
    public static String getFieldSet(String sObjectName, List<String> fieldSets, String sObjectId) { 
        
        Map<String,List<WrapperFieldSet>> WrapperFieldSetList = new Map<String,List<WrapperFieldSet>>();
        
        Map<String,Object> containWrapObject = new Map<String,Object>();
        
        for(String fieldSet : fieldSets){
            WrapperFieldSetList.put(fieldSet,ExamDescribeHelper.getFieldSetByRecord(fieldSet,sObjectName));             
        }
        containWrapObject.put('fields',WrapperFieldSetList);
        return JSON.serialize(containWrapObject);
    }
    
    public class WrapperFieldSet{
        
        @AuraEnabled
        public String fieldApi;
        @AuraEnabled
        public String fieldDataType;
        @AuraEnabled
        public String fieldLabel;
        @AuraEnabled
        public String sObjectApi;
        @AuraEnabled
        public List<String> options;
        @AuraEnabled
        public String inLineHelpText;
        
        public WrapperFieldSet(String fieldApi, String fieldDataType, List<String> options, String fieldLabel, String sObjectApi, String helpText){
            this.fieldApi = fieldApi;
            this.fieldDataType = fieldDataType;
            this.options = options;
            this.fieldLabel = fieldLabel;
            this.sObjectApi = sObjectApi;
            this.inLineHelpText = helpText;
        }
        
    }
    
    
    public class WrapperAttachment{
        @AuraEnabled
        public String Name;
        @AuraEnabled
        public String Id;
        @AuraEnabled
        public String ContentType;
        public WrapperAttachment(String Name, String Id, String ContentType){
            this.Name = Name;
            this.Id = Id;
            this.ContentType = ContentType;
        }
        
    }
    
    
    @AuraEnabled
    public static String getRecord(String sObjectName, List<String> fieldSets, String sObjectId) {   
        
        Map<String,Object> containWrapObject = new Map<String,Object>();
        
        List<sObject> objList = ExamDescribeHelper.getRecordByFieldSet(sObjectName,fieldSets,sObjectId);
        List<WrapperAttachment> attachments = AttachmentService.getAttachmentById(sObjectId);
        
        containWrapObject.put('sobject',objList);
        containWrapObject.put('attachment',attachments);
        
        return JSON.serialize(containWrapObject);
    }
    
    @AuraEnabled
    public static List<Section_Template__c> moveSectionUpOrDwn(String assessmentId, Decimal index, String direction){
        
        List<Section_Template__c> sectionTemplates = SectionService.moveSectionUpOrDown(assessmentId, index, direction);
        
        return sectionTemplates;
    }
    
    @AuraEnabled
    public static Map<String, List<Question_Template__c>> moveQuestionToSection(String oldSectionId, String newSectionId, String direction, Decimal index, String recordId){
        
        Map<String, List<Question_Template__c>> oldToNewQuestion = QuestionService.moveQuestion(oldSectionId, newSectionId, direction, index, recordId);
        return oldToNewQuestion;
    }
    
    
    @AuraEnabled
    public static Map<String,List<Object>> copyQuestionTemplate(String questionId, String sectionId, String direction, Decimal index){
        Map<String,List<Object>> copyQuesAndAnswers = new Map<String,List<Object>>();
        Map<String,object> responseMap = QuestionService.copyQuestion(questionId, sectionId, direction, index);
        object objectId =  responseMap.get('newQuestionId');
        String newQuestionId =  String.valueOf(objectId);
        Boolean withInSection = Boolean.valueOf(responseMap.get('withInSec')); 
        Map<String,Answer_Option__c> answerOldIdWthNewAnswer = AnswerOptionService.cloneAnswerOptions(questionId,newQuestionId,withInSection);
        List<Question_Template__c> questionTemplates =  (List<Question_Template__c>)responseMap.get('updateRecords');
        
        Map<String,String> questionOldIdWthNewId = new Map<String,String>();
        questionOldIdWthNewId.put(questionId,newQuestionId);
        List<Attachment> copyQuestionImage = AttachmentService.copyQuestionImage(questionOldIdWthNewId);
        
        
        //update Assessment 
        String assessmentId = questionTemplates[0].Section_Question__r.Questionnaire_Section__c;
        AssessmentService.updateAssessmentDueToChildUpdates(assessmentId);
        
        copyQuesAndAnswers.put('copyQuestion',questionTemplates);
        copyQuesAndAnswers.put('copyAnswerOptions',(List<object>)answerOldIdWthNewAnswer.values());
        copyQuesAndAnswers.put('questionImage',copyQuestionImage); // new
        
        return copyQuesAndAnswers;
    }
    /*
    @AuraEnabled
    public static sObject updateRecord(String ObjectName, String id, String fieldName, String fieldVal){
        sObject obj = ExamFieldEditorController.updateRecord(ObjectName, id, fieldName, fieldVal);
        return obj;
    }*/
    @AuraEnabled
    public static sObject updateRecord(String ObjectName, String JSONStr){
        System.debug('JSONStr::::'+JSONStr);
        sObject obj = ExamFieldEditorController.updateRecord(ObjectName, JSONStr);
        return obj;
    }
    
    @AuraEnabled
    public static Map<String,List<object>> upsertAnswer(String answerOptions, List<String> removeOptionIds, Boolean derivedFromQuestion, List<Integer> removedOptionIndices){
        Map<String,List<object>> answerOptionList = AnswerOptionService.upsertAnswerOptions(answerOptions, removeOptionIds, derivedFromQuestion, removedOptionIndices);
        List<Answer_Option__c> upsertAnswerOptions = (List<Answer_Option__c>)answerOptionList.get('AnswerOptions');
        String answerOptionId = (String)upsertAnswerOptions[0].Id;
        String assessmentId = AnswerOptionService.getGrandParentsRef(answerOptionId);
        AssessmentService.updateAssessmentDueToChildUpdates(assessmentId);
        return answerOptionList;
    }
    
    @AuraEnabled
    public static Map<String,List<Object>> copyQuestionWithAttachment(String questionId, String sectionId, String direction, Decimal index){
        Map<String,List<Object>> copyQuesAndAnswerWithAttachment = new Map<String,List<Object>>();
        Map<String,String> questionOldIdWthNewId;
        List<Attachment> cloneAttachments, copyQuestionImage;
        Map<String,object> responseMap = QuestionService.copyQuestion(questionId, sectionId, direction, index);
        object objectId =  responseMap.get('newQuestionId');
        String newQuestionId =  String.valueOf(objectId);
        Boolean withInSection = Boolean.valueOf(responseMap.get('withInSec')); 
        Map<String,Answer_Option__c> answerOldIdWthNewAnswer = AnswerOptionService.cloneAnswerOptions(questionId,newQuestionId,withInSection);
        
        questionOldIdWthNewId = new Map<String,String>();
        questionOldIdWthNewId.put(questionId,newQuestionId);
        
        if(answerOldIdWthNewAnswer.isEmpty()){
            
            cloneAttachments = AttachmentService.cloneAttachmentByQuestionIds(questionOldIdWthNewId);
        }else{
            cloneAttachments = AttachmentService.cloneAttachment(answerOldIdWthNewAnswer);
        }
        copyQuestionImage = AttachmentService.copyQuestionImage(questionOldIdWthNewId);
        
        List<Question_Template__c> questionTemplates =  (List<Question_Template__c>)responseMap.get('updateRecords');
        
        //update Assessment 
        String assessmentId = questionTemplates[0].Section_Question__r.Questionnaire_Section__c;
        AssessmentService.updateAssessmentDueToChildUpdates(assessmentId);
        
        copyQuesAndAnswerWithAttachment.put('copyQuestion',questionTemplates);
        copyQuesAndAnswerWithAttachment.put('copyAnswerOptions',(List<object>)answerOldIdWthNewAnswer.values());
        copyQuesAndAnswerWithAttachment.put('copyAttachment',cloneAttachments);
        copyQuesAndAnswerWithAttachment.put('questionImage',copyQuestionImage);
        
        return copyQuesAndAnswerWithAttachment;
    }
    
    @AuraEnabled
    public static List<Question_Template__c> deleteQuestionTemplate(String questionId){
        List<Question_Template__c> questionTemplate= QuestionService.deleteQuestion(questionId);
        return questionTemplate;
    }
    
    @AuraEnabled
    public static Section_Template__c archiveSection(String sectionId, String assessmentId){
        
        Section_Template__c sectionTemp = SectionService.archiveSection(sectionId, assessmentId);
        return sectionTemp;
    }
    
    @AuraEnabled
    public static Map<String, List<Section_Template__c>> moveSection(String oldAssessmentId, String newAssessmentId, String direction, Integer index, String recordId){
        
        Map<String, List<Section_Template__c>> oldToNewSection = SectionService.moveSection(oldAssessmentId, newAssessmentId, direction, index, recordId);
        return oldToNewSection;
    }
    
    @AuraEnabled
    public static Map<String, List<Object>> copySection(String toassessmentId, String direction, Integer index, String recordId){
        Map<String, List<Object>> copySectionWithQuestionAndAttachment = SectionService.copySectionWithRelatedQuestions(toassessmentId, direction, index, recordId);
        return copySectionWithQuestionAndAttachment;
    }
    
     @AuraEnabled
    public static Main_questionaire__c getLastModifiedOfCurrentAssessment(String assessmentId){
        try{
            String fields = 'Template_name__c, isArchive__c';
            FieldLevelSecurity.checkFieldAccessByCriteria(fields, 'view', 'Main_questionaire__c');
            Main_questionaire__c assessment = [SELECT Id, Template_name__c, CreatedDate, LastModifiedDate, isArchive__c FROM Main_questionaire__c WHERE Id =:assessmentId];
            return assessment;  
        }
        catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled 
    public static List<Question_Template__c> getQuestions(String sectionId){
        try{
            String fields = 'Name, Question_Label__c, Question_Order_No__c';
            FieldLevelSecurity.checkFieldAccessByCriteria(fields, 'view', 'Question_Template__c');
            List<Question_Template__c> questions = [SELECT Id, Name, Question_Label__c, Question_Order_No__c FROM Question_Template__c 
                                                    WHERE Section_Question__c = :sectionId ORDER BY Question_Order_No__c];
            return questions;   
        }
        catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled 
    public static Attachment upsertQuestionImage(String attachmentId, String parentId, String fileName, String base64Data, String contentType){
        Attachment attch = AttachmentService.saveAttachment(attachmentId, parentId, fileName, base64Data, contentType);
        String questionId = attch.ParentId;
        
        try{
            String fields = 'Section_Question__c';
            FieldLevelSecurity.checkFieldAccessByCriteria(fields, 'view', 'Question_Template__c');
            fields = 'Questionnaire_Section__c';
            FieldLevelSecurity.checkFieldAccessByCriteria(fields, 'view', 'Section_Template__c');
            Question_Template__c question = [SELECT Section_Question__r.Questionnaire_Section__c FROM Question_Template__c WHERE Id =:questionId];
            AssessmentService.updateAssessmentDueToChildUpdates(question.Section_Question__r.Questionnaire_Section__c);
        }
        catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
        
        attch.Body = null;
        return attch;
        
    }
    @AuraEnabled
    public static List<Question_Template__c> getdependencyQuestionsLabel(List<String> dependencyQuestions){
        List<Question_Template__c> questions = [SELECT Id, Question_Label__c FROM Question_Template__c WHERE Name IN :dependencyQuestions];
        return questions;
    }
    
    @AuraEnabled 
    public static List<Distribution__c> fetchDistribution(String assessmentId){
        List<Distribution__c> distributions = DistributionService.fetchDistribution(assessmentId);
        return distributions;
    }
    @AuraEnabled
    public static void archiveDistribution(String distributionId){
        DistributionService.archiveDistribution(distributionId);
    }
    @AuraEnabled
    public static void deleteDistribution(String distributionId){
       DistributionService.deleteDistribution(distributionId);    
    }
    @AuraEnabled
    public static List<DistributionService.AssessableObjectWrapper> getAssessableObjectDetails(String sObjectApiName){
        return DistributionService.getAssessableObjectDetails(sObjectApiName);
    }
    @AuraEnabled
    public static DistributionService.DistributionsDetails getDistributionsWthFieldSet(String assessmentId, List<String> fieldSets, String sObjectName){
        return DistributionService.getDistributionsWthFieldSet(assessmentId, fieldSets, sObjectName);
    }
    @AuraEnabled
    public static void createDistributionWthPALink(Distribution__c distributionObj, Distribution_Group__c distributionGroupObj, Integer countOfPALinks){
        DistributionService.createDistributionWthPALink(distributionObj, distributionGroupObj, countOfPALinks);
    }
    @AuraEnabled 
    public static DistributionGroupService.TargetObjectsOperatorsClass fetchTargetObjectsWthOperators(){
        DistributionGroupService.TargetObjectsOperatorsClass targetObjects = DistributionGroupService.fetchTargetObjectsWthOperators();
        return targetObjects;
    }
    @AuraEnabled 
    public static DistributionGroupService.DistributionGroupClass fetchSelectedObjectGroup(String objectName){
        DistributionGroupService.DistributionGroupClass selectedObjectGroup = DistributionGroupService.fetchSelectedObjectGroup(objectName);
        return selectedObjectGroup;
    }
    @AuraEnabled 
    public static DistributionGroupService.DistributionCountClass fetchCriteriaWthCountOfRd(String groupId){
        DistributionGroupService.DistributionCountClass distRecordDetails = DistributionGroupService.queryDistRecord(groupId);
        return distRecordDetails;
    }
    @AuraEnabled 
    public static List<EmailTemplate> fetchEmailTemplates(){
        List<EmailTemplate> emailTemplates = EmailTemplateService.fetchEmailTemplates();
        return emailTemplates;
    }
    @AuraEnabled 
    public static DistributionGroupService.AvailableDistribtionGroupClass checkCriteriaMet(String sObjectName, String JSONStr, String groupName, String selGrpId){
        DistributionGroupService.AvailableDistribtionGroupClass distGroupStatus = DistributionGroupService.checkFilterIsAvailable(sObjectName, JSONStr, groupName, selGrpId);
        return distGroupStatus;
    }
    @AuraEnabled
    public static ExamUtilClass.LimitClass getDailyEmailLimit() {
        return ExAMUtilClass.getDailyEmailLimit();
    } 
}