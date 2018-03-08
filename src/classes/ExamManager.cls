public with sharing class ExamManager {
    public static String objectName, Fields, constractQuery;
    public static List<Main_questionaire__c> assessmentCloneList =  new List<Main_questionaire__c>();
    public static List<Main_questionaire__c> clone(Map<Id,String> assessmentIdWthTempName){
        Set<Id> assessmentIds = assessmentIdWthTempName.keySet();
        List<Main_questionaire__c> assessmentList;
        List<Section_Template__c> sectionList;
        List<Question_Template__c> questionList;
        List<Answer_Option__c> answerOptionList;
        
        try{
            objectName = 'Main_questionaire__c';
            fields = ExamDescribeHelper.getFieldsOfSobject(objectName);             
            FieldLevelSecurity.checkObjectAccessByView(objectName);
            constractQuery = 'SELECT '+fields+' FROM ' + objectName+ ' WHERE Id IN :assessmentIds'; 
            assessmentList = Database.query(constractQuery);
        }
        catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
        
        for(Main_questionaire__c assessment : assessmentList){
            
            if(assessmentIdWthTempName.get(assessment.Id) != null){
                assessment.Template_name__c = assessmentIdWthTempName.get(assessment.Id);
            }
            
        }
        
        try{
            objectName = 'Section_Template__c';
            fields = ExamDescribeHelper.getFieldsOfSobject(objectName); 
            FieldLevelSecurity.checkObjectAccessByView(objectName);
            constractQuery = 'SELECT '+fields+' FROM ' + objectName+ ' WHERE Questionnaire_Section__c IN :assessmentIds ORDER BY Order_No__c';
            sectionList = Database.query(constractQuery);
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
        
        Map<Id,List<Section_Template__c>> assessmentIdWthSections = new Map<Id,List<Section_Template__c>>();
        Set<Id> sectionIds = new Set<Id>();
        
        for(Section_Template__c section : sectionList){
            
            if(assessmentIdWthSections.containsKey(section.Questionnaire_Section__c)){
                assessmentIdWthSections.get(section.Questionnaire_Section__c).add(section);                
            }else{
                assessmentIdWthSections.put(section.Questionnaire_Section__c, new List<Section_Template__c>{section});
            }
            
            sectionIds.add(section.Id);
        }  
        
        try{
            objectName = 'Question_Template__c';
            fields = ExamDescribeHelper.getFieldsOfSobject(objectName); 
            FieldLevelSecurity.checkObjectAccessByView(objectName);
            constractQuery = 'SELECT '+fields+' FROM ' + objectName+ ' WHERE Section_Question__c IN :sectionIds ORDER BY Question_Order_No__c';
            questionList = Database.query(constractQuery);
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
        
        Map<Id,List<Question_Template__c>> sectionIdWthQuestions = new Map<Id,List<Question_Template__c>>();
        Set<Id> questionIds = new Set<Id>();
        
        for(Question_Template__c question : questionList){
            
            if(sectionIdWthQuestions.containsKey(question.Section_Question__c)){
                sectionIdWthQuestions.get(question.Section_Question__c).add(question);
            }else{
                sectionIdWthQuestions.put(question.Section_Question__c, new List<Question_Template__c>{question});
            }
            
            questionIds.add(question.Id);
        }
        
        try{
            objectName = 'Answer_Option__c';
            fields = ExamDescribeHelper.getFieldsOfSobject(objectName); 
            FieldLevelSecurity.checkObjectAccessByView(objectName);            
            constractQuery = 'SELECT '+fields+' FROM ' + objectName+ ' WHERE Question_Template__c IN :questionIds ORDER BY Order_No__c';
            answerOptionList = Database.query(constractQuery);
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
        
        Map<Id,List<Answer_Option__c>> questionIdWthAnswers = new Map<Id,List<Answer_Option__c>>();
        
        for(Answer_Option__c answerOption : answerOptionList){
            
            if(questionIdWthAnswers.containsKey(answerOption.Question_Template__c)){
                questionIdWthAnswers.get(answerOption.Question_Template__c).add(answerOption);
            }else{
                questionIdWthAnswers.put(answerOption.Question_Template__c, new List<Answer_Option__c>{answerOption});
            }
            
        }
        
        buildWrapper(assessmentList,assessmentIdWthSections,sectionIdWthQuestions,questionIdWthAnswers);
        return assessmentCloneList;
    }
    
    public static List<Exam.AssessmentWrapper> buildWrapper(List<Main_questionaire__c> assessments, Map<Id,List<Section_Template__c>> assessmentIdWthSections, Map<Id,List<Question_Template__c>> sectionIdWthQuestions, Map<Id,List<Answer_Option__c>> questionIdWthAnswers){
        List<Exam.AssessmentWrapper> assessmentWrapper = new List<Exam.AssessmentWrapper>();
        for(Main_questionaire__c assessment : assessments){
            assessmentWrapper.add(new Exam.AssessmentWrapper(assessment,assessmentIdWthSections,sectionIdWthQuestions,questionIdWthAnswers));
        }
        cloneAssessments(assessmentWrapper);
        cloneSections(assessmentWrapper);
        Map<String,object> responseWthQuestionInfo = cloneQuestions(assessmentWrapper);
        cloneAnswerOptions(assessmentWrapper,responseWthQuestionInfo);
        
        return assessmentWrapper;
    }
    
    public static void cloneAssessments(List<Exam.AssessmentWrapper> assessments){
        Map<String, Main_questionaire__c> assessmentOldIdWthAssessment = new Map<String, Main_questionaire__c>();
        for(Exam.AssessmentWrapper assessment : assessments){
            assessmentOldIdWthAssessment.put(assessment.assessmentRecord.Id, assessment.cloneAssessment());
        }
        
        try{
            objectName = 'Main_questionaire__c';
            FieldLevelSecurity.checkObjectAccessByCreate(objectName);
            insert assessmentOldIdWthAssessment.values();
            assessmentCloneList.addAll(assessmentOldIdWthAssessment.values());
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
        // clone Attachment of Assessment 
        AttachmentService.cloneAttachmentByAssessment(assessmentOldIdWthAssessment);
        
    }
    
    public static void cloneSections(List<Exam.AssessmentWrapper> assessments){
        List<Section_Template__c> sectionList =  new List<Section_Template__c>();
        for(Exam.AssessmentWrapper assessment : assessments){
            if(assessment.sections != null){
                for(Exam.SectionWrapper section : assessment.sections){
                    sectionList.add(section.cloneSection(assessment));
                }
            }            
        }
        
        try{
            objectName = 'Section_Template__c';
            FieldLevelSecurity.checkObjectAccessByCreate(objectName);            
            insert sectionList;
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
        
    }
    
    public static Map<String,object> cloneQuestions(List<Exam.AssessmentWrapper> assessments){
        Map<String,Question_Template__c> questionOldNameWthNewQuestion = new Map<String,Question_Template__c>();
        List<Id> questionOldIds = new List<Id>();
        Map<String,object> responseWthQuestionInfo = new Map<String,object>();
        Map<Id,Id> questionOldIdWthNewId = new Map<Id,Id>();
        
        for(Exam.AssessmentWrapper assessment : assessments){
            if(assessment.sections != null){
                for(Exam.SectionWrapper section : assessment.sections){
                    if(section.questions != null){
                        for(Exam.QuestionWrapper question : section.questions){
                            questionOldIds.add(question.questionRecord.Id);
                            questionOldNameWthNewQuestion.put(question.questionRecord.Name,question.cloneQuestion(section));
                        }  
                    }
                    
                }
            }
        }
        
        try{
            objectName = 'Question_Template__c';
            FieldLevelSecurity.checkObjectAccessByCreate(objectName);
            insert questionOldNameWthNewQuestion.values();
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
        
        List<Question_Template__c> newQuestionList = questionOldNameWthNewQuestion.values();
        
        for(Integer i = 0; i < questionOldIds.size(); i++){
            questionOldIdWthNewId.put(questionOldIds[i], newQuestionList[i].Id);
        }
        updateCloneDecisionTreeQuestion(questionOldIdWthNewId.values(),questionOldNameWthNewQuestion);
        responseWthQuestionInfo.put('questionOldIdWthNewId', questionOldIdWthNewId);
        responseWthQuestionInfo.put('questionOldNameWthNewQuestion', questionOldNameWthNewQuestion);
        return responseWthQuestionInfo;
    }
    
    public static void updateCloneDecisionTreeQuestion(List<Id> questionNewIds, Map<String,Question_Template__c> questionOldNameWthNewQuestion){
        
        List<Question_Template__c> updatedList = new List<Question_Template__c>();
        Map<Id,Question_Template__c> updatableCloneQuestion = new Map<Id,Question_Template__c>([SELECT Id,Name, Next_Question__c, Dependent_Question__c FROM Question_Template__c WHERE Id IN : questionNewIds]);
        
        for(String questionId : updatableCloneQuestion.keySet()){
            Question_Template__c question = updatableCloneQuestion.get(questionId);
            
            if(question.Next_Question__c != null && question.Next_Question__c != '' ) {
                string newNextQuestion = '';
                for (string oldQName : question.Next_Question__c.split('~')) {
                    
                    if (questionOldNameWthNewQuestion.containsKey(oldQName)) {
                        
                        if (newNextQuestion != '') {
                            newNextQuestion += '~'+updatableCloneQuestion.get(questionOldNameWthNewQuestion.get(oldQName).Id).Name;
                        } else {
                            newNextQuestion += updatableCloneQuestion.get(questionOldNameWthNewQuestion.get(oldQName).Id).Name;
                        }
                        
                    }
                    
                }
                
                Question_Template__c questionTemp = new Question_Template__c(Id = questionId, Next_Question__c = newNextQuestion);
                updatedList.add(questionTemp);
            }else if(question.Dependent_Question__c != null ) {
                string newDependentQuestion = '';
                for (string oldQName : question.Dependent_Question__c.split('~')) {
                    
                    if (questionOldNameWthNewQuestion.containsKey(oldQName)) {
                        
                        if (newDependentQuestion != '') {
                            newDependentQuestion += '~'+updatableCloneQuestion.get(questionOldNameWthNewQuestion.get(oldQName).Id).Name;
                        } else {
                            newDependentQuestion += updatableCloneQuestion.get(questionOldNameWthNewQuestion.get(oldQName).Id).Name;
                        }
                        
                    }
                    
                }
                
                Question_Template__c questionTemp = new Question_Template__c(Id = questionId, Dependent_Question__c = newDependentQuestion);
                updatedList.add(questionTemp);
            }
            
        }
        
        try{
            objectName = 'Question_Template__c';
            fields = 'Next_Question__c, Dependent_Question__c';
            FieldLevelSecurity.checkFieldAccessByCriteria(fields, 'update', objectName);
            update updatedList;
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
        
    }
    
    public static void cloneAnswerOptions(List<Exam.AssessmentWrapper> assessments, Map<String,object> responseWthQuestionInfo){
        Map<Id,Id> answerOptOldIdWthNewId = new Map<Id,Id>();
        Map<Id,Answer_Option__c> answerOptionOldIdWthNewAnswerOption = new Map<Id,Answer_Option__c>();
        List<Answer_Option__c> answerOptionList = new List<Answer_Option__c>();
        List<String> weightOFAnswer = new List<String>();
        Id nextQuestion, dependentQuestion;
        List<Id> nextQuestionIds = new List<Id>();
        List<Id> dependentQuestionIds = new List<Id>();
        Map<Id,Id> questionOldIdWthNewId = (map<Id,Id>)responseWthQuestionInfo.get('questionOldIdWthNewId');
        Map<String,Question_Template__c> questionOldNameWthNewQuestion = (Map<String,Question_Template__c>)responseWthQuestionInfo.get('questionOldNameWthNewQuestion');
        for(Exam.AssessmentWrapper assessment : assessments){
            if(assessment.sections != null){
                for(Exam.SectionWrapper section : assessment.sections){
                    if(section.questions != null){
                        for(Exam.QuestionWrapper question : section.questions){
                            
                            if(question.answerOptions != null){
                                
                                for(Exam.AnswerOptionsWrapper answer : question.answerOptions){
                                    
                                    if(answer.answerOptionRecord.Next_Question__c != null){
                                        nextQuestion = questionOldIdWthNewId.get(answer.answerOptionRecord.Next_Question__c);
                                    }else if(answer.answerOptionRecord.Dependent_Question__c != null){
                                        dependentQuestion = questionOldIdWthNewId.get(answer.answerOptionRecord.Dependent_Question__c);
                                    }
                                    
                                    answerOptionOldIdWthNewAnswerOption.put(answer.answerOptionRecord.Id, answer.cloneAnswerOption(question,nextQuestion,dependentQuestion));
                                    nextQuestion = null;
                                    dependentQuestion = null;
                                    
                                }
                            }else{
                                if(question.questionRecord.Subquestion_Label__c != null){
                                    String answer = question.questionRecord.Subquestion_Label__c;
                                    Integer orderNo = 1;
                                    List<String> answerOptions = answer.split('~');
                                    
                                    if(question.questionRecord.Next_Question__c != null){
                                        for (string oldQName : question.questionRecord.Next_Question__c.split('~')) {
                                            nextQuestionIds.add(questionOldNameWthNewQuestion.get(oldQName).Id);    
                                        }
                                    }else if(question.questionRecord.Dependent_Question__c != null){
                                        for (string oldQName : question.questionRecord.Dependent_Question__c.split('~')) {
                                            dependentQuestionIds.add(questionOldNameWthNewQuestion.get(oldQName).Id);
                                        }
                                    }
                                    
                                    if(question.questionRecord.Weight_of_Answer__c != null){
                                        weightOFAnswer.addAll(question.questionRecord.Weight_of_Answer__c.split('~'));
                                    }
                                    
                                    for(Integer i = 0; i < answerOptions.size(); i++){
                                        Integer weight;
                                        if(!nextQuestionIds.isEmpty() && nextQuestionIds.size() > i){
                                            nextQuestion = nextQuestionIds[i];
                                        }else if(!dependentQuestionIds.isEmpty() && dependentQuestionIds.size() > i){
                                            dependentQuestion = dependentQuestionIds[i];
                                        }
                                        
                                        if(!weightOFAnswer.isEmpty() && weightOFAnswer.size() > i){
                                            weight = Integer.valueOf(weightOFAnswer[i]);
                                        }
                                        
                                        Answer_Option__c answerOpt = new Answer_Option__c(Name = answerOptions[i],Weight__c = weight,Order_No__c = orderNo++,Question_Template__c = question.questionRecord.Id,Next_Question__c = nextQuestion, Dependent_Question__c = dependentQuestion);
                                        answerOptionList.add(answerOpt);
                                        nextQuestion = null;
                                        dependentQuestion = null;
                                    }
                                    nextQuestionIds.clear();
                                    dependentQuestionIds.clear();
                                }
                            }
                            
                        }            
                    }
                    
                }  
            }
            
        }
        
        if(!answerOptionOldIdWthNewAnswerOption.isEmpty()){
            
            try{
                objectName = 'Answer_Option__c';
                FieldLevelSecurity.checkObjectAccessByCreate(objectName);
                insert answerOptionOldIdWthNewAnswerOption.values();
            }catch(Exception e){
                throw new AuraHandledException(e.getMessage());
            }
            
            List<Id> answerOptionOldIds = new List<Id>(answerOptionOldIdWthNewAnswerOption.keySet());
            List<Answer_Option__c> newAnswerOptionList = answerOptionOldIdWthNewAnswerOption.values();
            
            for(Integer i = 0; i < answerOptionOldIds.size(); i++){
                answerOptOldIdWthNewId.put(answerOptionOldIds[i], newAnswerOptionList[i].Id);
            }
            
            if(!Test.isRunningTest()){
                Database.executeBatch(new BatchAttachmentClone(answerOptOldIdWthNewId, false),1);   
            }
            
        }
        
        if(!answerOptionList.isEmpty()){
            insert answerOptionList;
            if(!Test.isRunningTest()){
                Database.executeBatch(new BatchAttachmentClone(questionOldIdWthNewId, true),1);  
            }
            
        }
        
        if(!questionOldIdWthNewId.isEmpty() && !Test.isRunningTest()){
           Database.executeBatch(new BatchAttachmentClone(questionOldIdWthNewId),1);  
        }
    }
}