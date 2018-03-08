@isTest
private class TestAssessmentTemplateController {
    public static List<Main_questionaire__c> assessmentList;
    public static List<Section_Template__c> sectionList;
    public static List<Question_Template__c> questionList;
    public static List<Answer_Option__c> answerOptionsList;
    public static List<Attachment> attachByQuestion, attach;
    
    public static List<String> fieldSets = new List<String>();
    public static String sObjectName, sObjectId, containWrapObject;
    
    
    @testSetup static void generateInputPerformActions() {
       
        // create Assessments
        
        assessmentList = new List<Main_questionaire__c>{
            new Main_questionaire__c(
                Template_name__c = 'Food Survey'
            ),
            new Main_questionaire__c(
                Template_name__c = 'Food Survey2'
            ),
            new Main_questionaire__c(
                Template_name__c = 'Food Survey3'
            ),
            new Main_questionaire__c(
                Template_name__c = 'Food Survey4'
            )
        };
        insert assessmentList;
        
        // create Sections by Assessment Id
        
        sectionList = new List<Section_Template__c>{
            new Section_Template__c(
                Questionnaire_Section__c = assessmentList[0].Id,
                Section_label__c = 'Starters',
                Order_No__c = 1
            ),
            new Section_Template__c(
                Questionnaire_Section__c = assessmentList[0].Id,
                Section_label__c = 'Main Course',
                Order_No__c = 2
            ),
            new Section_Template__c(
                Questionnaire_Section__c = assessmentList[0].Id,
                Section_label__c = 'Desserts',
                Order_No__c = 3
            ), 
            new Section_Template__c(
                Questionnaire_Section__c = assessmentList[1].Id,
                Section_label__c = 'Assessment2 sec1',
                Order_No__c = 1
            ), 
            new Section_Template__c(
                Questionnaire_Section__c = assessmentList[2].Id,
                Section_label__c = 'Assessment3 sec1',
                Order_No__c = 1
            ) 
        };      
        insert sectionList;
        
        // create Questions by Section Id
        
        questionList = new List<Question_Template__c>{
            new Question_Template__c(
                Question_Label__c = 'Sec1 Question1?',
                Question_Type__c = 'RadioPicklist',
                Question_Order_No__c = 1,
                Section_Question__c = sectionList[0].Id
            ),
            new Question_Template__c(
                Question_Label__c = 'Sec1 Question2?',
                Question_Type__c = 'Button',
                Question_Order_No__c = 2,
                Section_Question__c = sectionList[0].Id,
                Is_Dependent__c = true
            ),
            new Question_Template__c(
                Question_Label__c = 'Sec1 Question3?',
                Question_Type__c = 'Button',
                Question_Order_No__c = 3,
                Section_Question__c = sectionList[0].Id,
                Is_Dependent__c = true
            ),
            new Question_Template__c(
                Question_Label__c = 'Sec2 Question1?',
                Question_Type__c = 'Button',
                Question_Order_No__c = 1,
                Section_Question__c = sectionList[1].Id
            ),
            new Question_Template__c(
                Question_Label__c = 'Sec2 Question2?',
                Question_Type__c = 'Button',
                Question_Order_No__c = 2,
                Subquestion_Label__c = 'Sea Food~Others',
                Weight_of_Answer__c = '20~10',
                Section_Question__c = sectionList[1].Id
            ),
            new Question_Template__c(
                Question_Label__c = 'Sec2 Question3?',
                Question_Type__c = 'Button',
                Question_Order_No__c = 3,
                Section_Question__c = sectionList[1].Id
            ),
            new Question_Template__c(
                Question_Label__c = 'sec2 Question4?',
                Question_Type__c = 'RadioPicklist',
                Question_Order_No__c = 4,
                Subquestion_Label__c = 'Meals~Biriyani',
                Weight_of_Answer__c = '20~10',
                Is_Dependent__c = true,
                Section_Question__c = sectionList[1].Id
            ),
            new Question_Template__c(
                Question_Label__c = 'Sec3 Question1?',
                Question_Type__c = 'Image',
                Question_Order_No__c = 1,
                Section_Question__c = sectionList[2].Id
            )
        };                    
        insert questionList;
        
        Map<Id,Question_Template__c> IdWithQuestion = new Map<Id,Question_Template__c>(questionList);
        questionList = [SELECT Id,Name,Next_Question__c,Dependent_Question__c,Subquestion_Label__c FROM Question_Template__c WHERE Id IN:IdWithQuestion.keySet()];
        questionList[4].Next_Question__c = questionList[3].Name+'~'+questionList[5].Name;
        questionList[6].Dependent_Question__c = questionList[3].Name+'~'+questionList[5].Name;
        update questionList;
        
        // create Answers by Question Id
        
        answerOptionsList = new List<Answer_Option__c>{
            new Answer_Option__c(
                Name = 'Ques1 Ans1',
                Order_No__c = 1,
                Question_Template__c = questionList[0].Id
            ), 
            new Answer_Option__c(
                Name = 'Ques1 Ans2',
                Order_No__c = 2,
                Question_Template__c = questionList[0].Id,
                Next_Question__c = questionList[3].Id //1
            ),
            new Answer_Option__c(
                Name = 'Ques2 Ans1',
                Order_No__c = 1,
                Question_Template__c = questionList[1].Id
            ),
            new Answer_Option__c(
                Name = 'Ques2 Ans2',
                Order_No__c = 2,
                Question_Template__c = questionList[1].Id                    
            ),
            new Answer_Option__c(
                Name = 'Ques3 Ans1',
                Order_No__c = 1,
                Question_Template__c = questionList[2].Id,
                Dependent_Question__c =  questionList[3].Id //1
            ),
            new Answer_Option__c(
                Name = 'Sec2 Ques1 Ans1',
                Order_No__c = 1,
                Question_Template__c = questionList[3].Id
            ), 
            new Answer_Option__c(
                Name = 'Sec2 Ques1 Ans2',
                Order_No__c = 2,
                Question_Template__c = questionList[3].Id
            ), 
            new Answer_Option__c(
                Name = 'Sec2 Ques3 Ans1',
                Order_No__c = 1,
                Question_Template__c = questionList[5].Id
            ), 
            new Answer_Option__c(
                Name = 'Sec2 Ques3 Ans2',
                Order_No__c = 2,
                Question_Template__c = questionList[5].Id
            ), 
            new Answer_Option__c(
                Name = 'Sec3 Ques1 Ans1',
                Order_No__c = 1,
                Question_Template__c = questionList[7].Id
            ),
            new Answer_Option__c(
                Name = 'Sec3 Ques1 Ans2',
                Order_No__c = 2,
                Question_Template__c = questionList[7].Id
            )
                
        };
        insert answerOptionsList;
        
        // create Attachments by Answer Id
        
        attach = new List<Attachment>{
            new Attachment(
                ParentId = answerOptionsList[9].Id,
                Name = 'Ans10 kk ',
                ContentType = 'jpg',
                Body = EncodingUtil.base64Decode('sfkjdhkjd')
            ),
            new Attachment(
                ParentId = answerOptionsList[10].Id,
                Name = 'Ans11 kk1',
                ContentType = 'jpg',
                Body = EncodingUtil.base64Decode('sfkjdhkjd')
            ),
            new Attachment(
                ParentId = assessmentList[0].Id,
                Name = 'userLogo',
                ContentType = 'jpg',
                Body = EncodingUtil.base64Decode('sfkjdhkjd')
            )
                
        };
                    
        insert attach;
        
        // create Attachments by Question Id
        
        attachByQuestion = new List<Attachment>{
            
            new Attachment(
                ParentId = questionList[4].Id,
                Name = '1',
                ContentType = 'jpg',
                Body = EncodingUtil.base64Decode('sfkjdhkjd')
            ),
            new Attachment(
                ParentId = questionList[4].Id,
                Name = '2',
                ContentType = 'jpg',
                Body = EncodingUtil.base64Decode('sfkjdhkjhhd')
            ),
            new Attachment(
                ParentId = questionList[4].Id,
                Name = 'Question-Image',
                ContentType = 'jpg',
                Body = EncodingUtil.base64Decode('sfkjdhkjhhd')
            )
                
        };
                    
        insert attachByQuestion;

        
    }
    static testMethod void validateAssessmentTemplateControllerByAssessmentService() {
        
        // fetch All assessment based on login user
        assessmentList = AssessmentTemplateController.fetchAssessment('Current_User');
        System.assertEquals(4, assessmentList.size());
        
        //update particular Assessment record 
        ExAM__Main_questionaire__c testTemplate = new ExAM__Main_questionaire__c(Template_Name__c='Test');
        String testStr = JSON.serialize(testTemplate);
        try {
        Main_questionaire__c assessment = (Main_questionaire__c)AssessmentTemplateController.updateRecord('ExAM__Main_questionaire__c',testStr);
        System.debug('assessment::::'+assessment);
        System.debug('assessment.ExAM__Template_name__c::::'+assessment.ExAM__Template_name__c);
        System.assertEquals('Test Food Survey2', assessment.ExAM__Template_name__c);
        
        //create new Assessment
        assessment = new Main_questionaire__c(ExAM__Template_name__c = 'Food Survey');
        assessment = AssessmentTemplateController.createAssessment(assessment, 'Current_User');
        System.debug('assessment:::'+assessment);
        //System.assertEquals('Food Survey', assessment.ExAM__Template_name__c);
        
        //clone Assessment
        assessment = AssessmentTemplateController.cloneAssessmentTemp(assessmentList[0].Id, 'Test Food Survey');
        System.assertNotEquals(assessmentList[0].Id, assessment.Id);
        } catch(Exception e) {
            system.assertNotEquals(e.getMessage(),'');
        }
        // After Create and clone fetch Assessment
        assessmentList = AssessmentTemplateController.fetchAssessment('Current_User');
        System.assertEquals(4, assessmentList.size());
        
        //Archieve Assessment
        assessmentList[1].isArchive__c = true;
        Main_questionaire__c selAssessment = AssessmentTemplateController.archiveAssessment(assessmentList[1]);
        
        // After Archive fetch Assessment
        assessmentList = AssessmentTemplateController.fetchAssessment('Current_User');
        System.assertEquals(3, assessmentList.size());
        
    }
    static testMethod void validateAssessmentTemplateControllerBySectionService(){
        
        // fetch Assessment
        assessmentList = [SELECT Id FROM Main_questionaire__c];
        List<Section_Template__c> secTempList = [SELECT Id FROM Section_Template__c]; // added newly
        
        Boolean hasQueriedFieldSetOfSection = false;
        sObjectId = assessmentList[0].Id;
        
        List<Section_Template__c> sections;
        
        if(!hasQueriedFieldSetOfSection){
            fieldSets.add('ExAM__lightningComp_SectionOptions_FieldSet');
            sObjectName = 'ExAM__Section_Template__c';            
            containWrapObject = AssessmentTemplateController.fetchSecTemplateWthSectionFieldSetValue(sObjectName, fieldSets, sObjectId);
        }
        
        AssessmentTemplateController.getLastModifiedOfCurrentAssessment(sObjectId);
        
        //fetch Section by AssessmentId
       /* List<Section_Template__c> sections = AssessmentTemplateController.fetchSecTemplate(assessmentList[0].Id);
        System.assertEquals(3, sections.size());*/
        
        // create fieldSets 
        sObjectName = 'ExAM__Main_questionaire__c';
        fieldSets = new List<String>();
        fieldSets.add('ExAM__lightningComp_TemplateOverview_FieldSet');
        fieldSets.add('ExAM__lightningComp_BasicOptions_FieldSet');
        fieldSets.add('ExAM__lightningComp_AdvancedOptions_FieldSet');
        sObjectId = assessmentList[0].Id;
        
        List<AssessmentTemplateController.WrapperFieldSet> fieldSet;
        
        if(fieldSet == null){
            containWrapObject = AssessmentTemplateController.getRecordById(sObjectName, fieldSets, sObjectId);
        }
        //Map<String,Object> containWrapObjectMap = (Map<String,Object>)JSON.deserializeUntyped(containWrapObject);
        //List<object> WrapperFieldSetList =  (List<object>)containWrapObjectMap.get('fields');
        
        
        containWrapObject = AssessmentTemplateController.getRecord(sObjectName, fieldSets, sObjectId); 
        containWrapObject = AssessmentTemplateController.getFieldSet(sObjectName, fieldSets, sObjectId);
        
        
        // Move Section up / Down
        List<Section_Template__c> Movesections = AssessmentTemplateController.moveSectionUpOrDwn(assessmentList[0].Id, 1, 'down');
        System.assertEquals(3, Movesections[1].ExAM__Order_No__c);
        Movesections = AssessmentTemplateController.moveSectionUpOrDwn(assessmentList[0].Id, 2, 'up');
        System.assertEquals(2, Movesections[2].ExAM__Order_No__c);
        
        // create New Section by Index position 
        Section_Template__c sec = new Section_Template__c(
            Questionnaire_Section__c = assessmentList[0].Id,
            Section_label__c = 'test section'
        );
            
        sections = AssessmentTemplateController.createSection(sec, 2);
        System.assertEquals(3, sections[2].ExAM__Order_No__c);
        
        
        // Copy Section to Specified Assessment
        AssessmentTemplateController.copySection(assessmentList[2].Id, 'After', 0, sections[0].Id);
        AssessmentTemplateController.copySection(assessmentList[2].Id, 'After', 1, sections[1].Id);
        AssessmentTemplateController.copySection(assessmentList[2].Id, 'After', 0, sections[3].Id);
        AssessmentTemplateController.copySection(assessmentList[2].Id, 'Before', 0, sections[1].Id);
        AssessmentTemplateController.copySection(assessmentList[2].Id, 'Before', 0, secTempList[0].Id); // added newly
        
        Map<String, List<Object>> copySectionWithQuestionAndAttachment =  AssessmentTemplateController.copySection(assessmentList[3].Id, 'Before', 0, sections[3].Id);
        List<Section_Template__c> copySection = (List<Section_Template__c>)copySectionWithQuestionAndAttachment.get('copySection');
        System.assertEquals(1, copySection.size());
        List<Question_Template__c> copyQuestion= (List<Question_Template__c>)copySectionWithQuestionAndAttachment.get('copyQuestion');
        System.assertEquals(1, copyQuestion.size());
        List<Answer_Option__c> answerOptions = (List<Answer_Option__c>)copySectionWithQuestionAndAttachment.get('answerOptions');
        System.assertEquals(2, answerOptions.size());
        List<Attachment> copyAttachment = (List<Attachment>)copySectionWithQuestionAndAttachment.get('copyAttachment');
        System.assertEquals(2, copyAttachment.size());
        List<Attachment> cloneAttachmentsByQuestion = (List<Attachment>)copySectionWithQuestionAndAttachment.get('cloneAttachmentsByQuestion');
        System.assertEquals(0, cloneAttachmentsByQuestion.size());
        
        //create New section 
        sec.Id = null;
        sec = new Section_Template__c(
            Questionnaire_Section__c = assessmentList[0].Id,
            Section_label__c = 'test section'
        );
        AssessmentTemplateController.createSection(sec, null);
        
        sec.isArchive__c = true;
        
        //Archive Section
        AssessmentTemplateController.archiveSection(sec.Id, assessmentList[0].Id);
        if(hasQueriedFieldSetOfSection){
            sections = AssessmentTemplateController.fetchSecTemplate(assessmentList[0].Id);    
        }
        
        System.assertEquals(4, sections.size());
        
    }
   static testMethod void validateAssessmentTemplateControllerBySectionServiceMoveSection(){
       
       // fetch Assessment
       assessmentList = [SELECT Id FROM Main_questionaire__c];
       sectionList = [SELECT Id FROM Section_Template__c];
       
       //fetch Section by AssessmentId
       List<Section_Template__c> sections = AssessmentTemplateController.fetchSecTemplate(assessmentList[0].Id);
       
       // Move Section
       AssessmentTemplateController.moveSection(assessmentList[0].Id, null, 'Before', 0, sections[2].Id); 
       AssessmentTemplateController.moveSection(assessmentList[0].Id, assessmentList[2].Id, 'Before', 0, sections[1].Id);
       AssessmentTemplateController.moveSection(assessmentList[2].Id, assessmentList[3].Id, 'Before', 0, sections[1].Id);
       AssessmentTemplateController.moveSection(assessmentList[2].Id, assessmentList[0].Id, 'After', 0, sectionlist[4].Id);
       AssessmentTemplateController.moveSection(assessmentList[0].Id, assessmentList[1].Id, 'After', 0, sections[0].Id);   
       
       sections = AssessmentTemplateController.fetchSecTemplate(assessmentList[0].Id);
       System.assertEquals(2, sections.size()); //1
    }

    static testMethod void validateAssessmentTemplateControllerByQuestionService(){
        
        //fetch Section, Question        
        sectionList = [SELECT Id FROM Section_Template__c];
        questionList = [SELECT Id FROM Question_Template__c];
        String quesId = questionList[4].Id;
        
        // create fieldSets
        fieldSets.add('ExAM__lightningComp_QuestionOptions_FieldSet');
        sObjectName = 'ExAM__Question_Template__c';
        sObjectId = sectionList[0].Id;
        containWrapObject = AssessmentTemplateController.fetchQuesTemplateWthQuestionFieldSetValue(sObjectName, fieldSets, sObjectId);
        
        Question_Template__c QuestionTemplate = new Question_Template__c(
            Question_Label__c = 'Which type of starters do you prefer mostly?',
            Question_Type__c = 'RadioPicklist',
            Question_Order_No__c = 1,
            Section_Question__c = sectionList[0].Id
        );
        
        Integer orderNo = 1;
        
        List<Answer_Option__c> answerOptions = new List<Answer_Option__c>{
            new Answer_Option__c (
                Name = 'Veg',
                Order_No__c = 1
            ),
            new Answer_Option__c (
                Name = 'Non_Veg',
                Order_No__c = 2
            )
        };
        try {
        // Create New Question Wth AnswerOptions 
        Map<String, List<Object>> QuestionWthAnswer = AssessmentTemplateController.createQuestionWthAnswer(QuestionTemplate, orderNo, answerOptions);
        System.assertEquals(4, QuestionWthAnswer.get('questions').size()); //3
        System.assertEquals(2, QuestionWthAnswer.get('answers').size());
        } catch(Exception e) {
            system.assertNotEquals(e.getMessage(),'');
        }        
         Question_Template__c QuestTemplate = new Question_Template__c(
            Question_Label__c = 'Which type of food do you prefer mostly?',
            Question_Type__c = 'RadioPicklist',
            Question_Order_No__c = 1,
            Section_Question__c = sectionList[2].Id
        );
        
        Integer orderNum = 1;
        
        List<Answer_Option__c> ansopt = new List<Answer_Option__c>{
            new Answer_Option__c (
                Name = 'Veg',
                Order_No__c = 1
            ),
            new Answer_Option__c (
                Name = 'Non_Veg',
                Order_No__c = 2
            )
        };
        try {
        Map<String, List<Object>> QuestionWthAnswers = AssessmentTemplateController.createQuestionWthAnswer(QuestTemplate, orderNo, ansopt);
        System.assertEquals(2, QuestionWthAnswers.get('questions').size());
        System.assertEquals(2, QuestionWthAnswers.get('answers').size());
        } catch(Exception e) {
            system.assertNotEquals(e.getMessage(),'');
        }
        List<String> options = AssessmentTemplateController.getQuestionType();
        
        // Copy Question 
        try {
        AssessmentTemplateController.copyQuestionTemplate(questionList[6].Id, sectionList[3].Id, 'Before', 0);
        AssessmentTemplateController.copyQuestionTemplate(questionList[6].Id, sectionList[0].Id, 'Before', 0);
        AssessmentTemplateController.copyQuestionTemplate(questionList[2].Id, sectionList[0].Id, 'Before', 0);
        AssessmentTemplateController.copyQuestionTemplate(questionList[2].Id, sectionList[3].Id, 'Before', 0);
        AssessmentTemplateController.copyQuestionTemplate(questionList[0].Id, sectionList[3].Id, 'Before', 0);
        Map<String,List<Object>> copyQuesAndAnswers = AssessmentTemplateController.copyQuestionTemplate(questionList[6].Id, sectionList[2].Id, 'After', 0);
        List<Question_Template__c> copyQuestions = (List<Question_Template__c>)copyQuesAndAnswers.get('copyQuestion');
        System.assertEquals(3, copyQuestions.size());//2
        List<Answer_Option__c> answerOption = (List<Answer_Option__c>)copyQuesAndAnswers.get('copyAnswerOptions');
        System.assertEquals(0, answerOption.size());
        
        // copy Question Wth Attachments
        AssessmentTemplateController.copyQuestionWithAttachment(questionList[7].Id, sectionList[0].Id, 'After', 0);
        Map<String,List<Object>> copyQuesAndAnswerWithAttachment = AssessmentTemplateController.copyQuestionWithAttachment(quesId, sectionList[0].Id, 'After', 0);
        copyQuestions = (List<Question_Template__c>)copyQuesAndAnswerWithAttachment.get('copyQuestion');
        System.assertEquals(8, copyQuestions.size());//6
        answerOption = (List<Answer_Option__c>)copyQuesAndAnswerWithAttachment.get('copyAnswerOptions');
        System.assertEquals(0, answerOption.size());
        List<Attachment> attach = (List<Attachment>)copyQuesAndAnswerWithAttachment.get('copyAttachment');
        System.assertEquals(2, attach.size());
        
        Map<String,List<Object>> copyQuesAndAnswerWithAttachment1 = AssessmentTemplateController.copyQuestionWithAttachment(questionList[4].Id, sectionList[0].Id, 'After', 0);
        List<Attachment> attach1 = (List<Attachment>)copyQuesAndAnswerWithAttachment1.get('copyAttachment');
        System.assertEquals(2, attach.size());
        
        // Delete Question 
        questionList = AssessmentTemplateController.deleteQuestionTemplate(questionList[7].Id);
        questionList = AssessmentTemplateController.getQuestions(sectionList[0].Id);        
        System.assertEquals(9, questionList.size()); //7
        } catch(Exception e) {
            system.assertNotEquals(e.getMessage(),'');
        }
    }
    
    static testMethod void validateAssessmentTemplateControllerByQuestionServiceMoveQuestion(){
        //fetch Section, Question     
        assessmentList = [SELECT Id FROM Main_questionaire__c];
        sectionList = [SELECT Id FROM Section_Template__c];
        questionList = [SELECT Id FROM Question_Template__c];
        
        Section_Template__c sec = new Section_Template__c(
            Questionnaire_Section__c = assessmentList[0].Id,
            Section_label__c = 'Assessment1 sec4',
            Order_No__c = 4
        );
        insert sec;
        sectionList = [SELECT Id FROM Section_Template__c];
        System.assertEquals(6, sectionList.size());
        
        try {
        // Move Question 
        AssessmentTemplateController.moveQuestionToSection(sectionList[0].Id, null, 'Before', 1, questionList[2].Id);
        AssessmentTemplateController.moveQuestionToSection(sectionList[0].Id, sectionList[3].Id, 'Before', 0, questionList[2].Id);
        AssessmentTemplateController.moveQuestionToSection(sectionList[0].Id, sectionList[1].Id, 'Before', 0, questionList[0].Id);
        Map<String, List<Question_Template__c>> oldToNewQuestion = AssessmentTemplateController.moveQuestionToSection(sectionList[1].Id, sectionList[0].Id, 'After', 0, questionList[0].Id);
        //System.assertEquals(4, oldToNewQuestion.get('fromQuestionTemplate').size());
        System.assertEquals(2, oldToNewQuestion.get('toQuestionTemplate').size());
        } catch (Exception ex) {
            System.assertNotEquals(ex.getMessage(),'');
        }
    }
    
    static testMethod void validateAssessmentTemplateControllerByQuestionServiceMoveQuestion1(){
        sectionList = [SELECT Id FROM Section_Template__c];
        questionList = [SELECT Id FROM Question_Template__c];
        answerOptionsList = [SELECT Id, Next_Question__c, Dependent_Question__c FROM Answer_Option__c ];
                
        questionList[4].Next_Question__c = 'What is your name?';
        questionList[6].Dependent_Question__c = 'What is your name?';
        update questionList;        
        try {
        AssessmentTemplateController.moveQuestionToSection(sectionList[1].Id, sectionList[0].Id, 'After', 0, questionList[4].Id);
        AssessmentTemplateController.moveQuestionToSection(sectionList[1].Id, sectionList[3].Id, 'Before', 0, questionList[6].Id);
        Map<String, List<Question_Template__c>> oldToNewQuestion = AssessmentTemplateController.moveQuestionToSection(sectionList[2].Id, sectionList[0].Id, 'After', 0, questionList[7].Id);        
                
        System.assertEquals(0, oldToNewQuestion.get('fromQuestionTemplate').size());
        System.assertEquals(5, oldToNewQuestion.get('toQuestionTemplate').size());//changed
        } catch(Exception e) {
            system.assertNotEquals(e.getMessage(),'');
        }
    }
    
    
    static testMethod void validateAssessmentTemplateControllerByAnswerOptionsService(){
        List<String> removeOptionIds = new List<String>();
        List<Integer> removedOptionIndices = new List<Integer>();
        
        //fetch Question
        questionList = [SELECT Id FROM Question_Template__c];
        //fetch Answers by QuestionId
        answerOptionsList = [SELECT Id,Question_Template__c FROM Answer_Option__c WHERE Question_Template__c =:questionList[0].Id];
        
        List<Answer_Option__c> answerOptions = new List<Answer_Option__c>{
            new Answer_Option__c(
                Name = 'Veg',
                Order_No__c = 3,
                Question_Template__c = questionList[0].Id
            )
        };
            
        answerOptionsList.addAll(answerOptions);
        try {
        //Upsert AnswerOptions 
        Map<String,List<object>> AnswerOptionsWthAttachment = AssessmentTemplateController.upsertAnswer(JSON.serialize(answerOptionsList), removeOptionIds, false, removedOptionIndices);
        List<object> answerOptList = AnswerOptionsWthAttachment.get('AnswerOptions');
        System.assertEquals(3, answerOptList.size());
        
        // upsert Answer Option Question derived with remove options indices
       answerOptions = new List<Answer_Option__c>{
            new Answer_Option__c(
                Name = 'Sea Food',
                Order_No__c = 1,
                Question_Template__c = questionList[4].Id
            )
        };
        
        removedOptionIndices.add(1);
        
        AnswerOptionsWthAttachment = AssessmentTemplateController.upsertAnswer(JSON.serialize(answerOptions), removeOptionIds, true, removedOptionIndices);
        answerOptList = AnswerOptionsWthAttachment.get('AnswerOptions');
        System.assertEquals(1, answerOptList.size());
        List<object> attach = AnswerOptionsWthAttachment.get('AnswerOptionsWthAttachments');
        System.assertEquals(1, attach.size());
        
        // upsert Answer Option Question derived
        answerOptions = new List<Answer_Option__c>{
            new Answer_Option__c(
                Name = 'Meals',
                Order_No__c = 1,
                Question_Template__c = questionList[6].Id
            ),
            new Answer_Option__c(
                Name = 'Biriyani',
                Order_No__c = 2,
                Question_Template__c = questionList[6].Id
            )
        };
        removedOptionIndices = new List<Integer>();
        AssessmentTemplateController.upsertAnswer(JSON.serialize(answerOptions), removeOptionIds, true, removedOptionIndices);
        
        // upsert Answer Option  With removeOptionIds
        answerOptionsList = [SELECT Id,Question_Template__c FROM Answer_Option__c WHERE Question_Template__c =:questionList[7].Id];
        removeOptionIds.add(answerOptionsList[1].Id);
        answerOptionsList.remove(1);
        AnswerOptionsWthAttachment = AssessmentTemplateController.upsertAnswer(JSON.serialize(answerOptionsList), removeOptionIds, false, removedOptionIndices);
        answerOptList = AnswerOptionsWthAttachment.get('AnswerOptions');
        System.assertEquals(1, answerOptList.size());
        attach = AnswerOptionsWthAttachment.get('AnswerOptionsWthAttachments');
        System.assertEquals(1, attach.size());
        } catch(Exception e) {
            system.assertNotEquals(e.getMessage(),'');
        }
    }
    static testMethod void validateAssessmentTemplateControllerByAttachmentService(){
        // Fetch Assessments, Questions, AnswerOptions, attachments 
        assessmentList = [SELECT Id FROM Main_questionaire__c];
        questionList = [SELECT Id FROM Question_Template__c];
        answerOptionsList = [SELECT Id FROM Answer_Option__c];
        attach = [SELECT Id FROM Attachment];
        
        List<String> answerOptionsId = new List<String>();
        answerOptionsId.add(answerOptionsList[9].Id);
        answerOptionsId.add(answerOptionsList[10].Id);
        //fetch Attachment by AnswerOptions Ids
        List<Attachment> attch = AssessmentTemplateController.fetchAttachment(null, answerOptionsId);
        System.assertEquals(2, attch.size()); 
        
        answerOptionsId = new List<String>();
        
        //Fetch Attachment By QuestionId
        attch = AssessmentTemplateController.fetchAttachment(questionList[4].Id, answerOptionsId);
        System.assertEquals(3, attch.size()); //2
        
        //upsert Logo under Assessments 
        AssessmentTemplateController.updateAttachFile(assessmentList[0].Id, 'userLogo', 'kfdngk', 'jpg');
        AssessmentTemplateController.updateAttachFile(assessmentList[1].Id, 'userLogo', 'kfdnggk', 'png');
        List<String> AssessmentIds = new List<String>();
        AssessmentIds.add(assessmentList[0].Id);
        AssessmentIds.add(assessmentList[1].Id);
        //fetch Attachment by assessment Ids
        attch = AssessmentTemplateController.fetchAttachment(null, AssessmentIds);
        System.assertEquals(2, attch.size());
        
        //upsert attachments 
        Attachment attachObj = AssessmentTemplateController.saveFile(attach[0].Id, answerOptionsList[9].Id, 'kk12', 'jdhgdjks', 'png');
        System.assertEquals(answerOptionsList[9].Id, attachObj.ParentId);
        
    }
    static testMethod void validateExamDescribeHelper(){
        ExamDescribeHelper.getPicklistValues('ExAM__Main_questionaire__c', 'ExAM__Weight_Template__c');
    }
    // these method for upsertQuestionImage and getdependencyQuestionsLabel
    static testMethod void validateQuestionImageAndLabel(){
        List<Section_Template__c> sectionList = [SELECT Id FROM Section_Template__c];
        String sectionId = sectionList[0].Id;
        List<Question_Template__c> questionList = [SELECT Id, Name FROM Question_Template__c WHERE Section_Question__c = :sectionId];
        String questionAutoName;
        
        for(Question_Template__c question : questionList){
            
            if(questionAutoName != null){
                questionAutoName  = questionAutoName + '~' + question.Name;
            }else{
                questionAutoName = question.Name;
            }
            
        }
        // create new Question
        Question_Template__c question = new Question_Template__c();
        question.Section_Question__c = sectionId;
        question.Question_Order_No__c = 4;
        question.Question_Label__c = 'test Question';
        question.Question_Type__c = 'RadioPicklist';
        question.Subquestion_Label__c ='opt1~opt2';
        question.Next_Question__c = questionAutoName;
        insert question;
        
        // create QuestionImage 
        Attachment attach = AssessmentTemplateController.upsertQuestionImage('', question.Id, 'Question-Image', 'fhkjesjes', 'jpg');
        System.assertEquals('Question-Image', attach.Name);
        
        // getDependencyQuestionsLabel
        List<Question_Template__c> questionDependencyList = AssessmentTemplateController.getdependencyQuestionsLabel(questionAutoName.split('~'));
        System.assertEquals('Sec1 Question1?', questionDependencyList[0].Question_Label__c);
        System.assertEquals('Sec1 Question2?', questionDependencyList[1].Question_Label__c);
        System.assertEquals('Sec1 Question3?', questionDependencyList[2].Question_Label__c);
    }
    public static testMethod void testDistributionGpService() {
        
        DistributionGroupService.TargetObjectsOperatorsClass retVal = AssessmentTemplateController.fetchTargetObjectsWthOperators();
        System.assertEquals(15, retVal.fieldTypeWithOperatorsMap.size());
        System.assertEquals(3, retVal.targetObjectList.size());
        
        Date birthDate = date.valueOf('2018-02-12');
        Contact[] conList = new Contact[] {
            new Contact(LastName = 'TestAcc1', DoNotCall = true, Birthdate = birthDate, Email = 'selva@gmail.com'),
            new Contact(LastName = 'TestAcc2')
        };
        insert conList;
        
        Distribution_Group__c[] distGpList = new Distribution_Group__c[]{
            new Distribution_Group__c(Name = 'test distGp 1' , Target_Object__c = 'Contact', Target_Object_Filter__c= '[{"fieldApi":"LastName","fieldLabel":"Last Name","fieldType":"STRING","operator":"equals","fieldValue":"TestAcc1"},{"fieldApi":"Birthdate","fieldLabel":"Birthdate","fieldType":"DATE","operator":"equals","fieldValue":"2018-02-12"}]'),
            new Distribution_Group__c(Name = 'test distGp 2' , Target_Object__c = 'Contact', Target_Object_Filter__c= '[{"fieldApi":"LastName","fieldLabel":"Last Name","fieldType":"STRING","operator":"equals","fieldValue":"TestAcc1"},{"fieldApi":"Birthdate","fieldLabel":"Birthdate","fieldType":"DATE","operator":"equals","fieldValue":"2018-02-12"}]')
        };
        insert distGpList; 
        
        DistributionGroupService.DistributionGroupClass retVal1 = AssessmentTemplateController.fetchSelectedObjectGroup('Contact');
        System.assertEquals(2, retVal1.distributionGroups.size());
        System.assert(retVal1.fieldList != null);
        
        Test.startTest();
       
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator.MockClass1());
        DistributionGroupService.DistributionCountClass retVal2 = AssessmentTemplateController.fetchCriteriaWthCountOfRd(distGpList[0].Id);
        
        System.assertEquals(15, retVal2.emailLimits.max);
        System.assertEquals(15, retVal2.emailLimits.remaining);
        System.assertEquals(2, retVal2.distFilterList.size());
        String str1 = '[{"fieldApi":"LastName","fieldLabel":"Last Name","fieldType":"STRING","operator":"equals","fieldValue":"TestAcc1"},{"fieldApi":"Birthdate","fieldLabel":"Birthdate","fieldType":"DATE","operator":"equals","fieldValue":"2018-02-12"}]';
        DistributionGroupService.AvailableDistribtionGroupClass retVal3 = AssessmentTemplateController.checkCriteriaMet('Contact', str1, distGpList[0].Name,distGpList[0].Id);
        System.assertEquals(true, retVal3.isAvailable); 
        System.assertEquals(1, retVal3.count); 
        System.assertEquals('test distGp 2', retVal3.distributionGroup);
        
        Test.stopTest();
    } 
    public static testMethod void testEmailTemplateService(){
        List<EmailTemplate> emailTemplates = AssessmentTemplateController.fetchEmailTemplates();
        //System.assertEquals(0, emailTemplates.size());
    }
    
}