@isTest
private class TestExamManager {
    
    static testMethod void validateExamManager() {
        
        Main_questionaire__c assessment = new Main_questionaire__c();
        assessment.Template_name__c = 'Food Survey';
        insert assessment;
        
        List<Section_Template__c> sectionList = new List<Section_Template__c>{
            new Section_Template__c(
                Questionnaire_Section__c = assessment.Id,
                Section_label__c = 'Starters',
                Order_No__c = 1
            ),
            new Section_Template__c(
                Questionnaire_Section__c = assessment.Id,
                Section_label__c = 'Main Course',
                Order_No__c = 2
            ),
            new Section_Template__c(
                Questionnaire_Section__c = assessment.Id,
                Section_label__c = 'Desserts',
                Order_No__c = 3
            ) 
        };
                    
        insert sectionList;
        Map<Id,Section_Template__c> oldIdWthSection = new Map<Id,Section_Template__c>(sectionList);
        List<Question_Template__c> questionList = new List<Question_Template__c>{
            new Question_Template__c(
                Question_Label__c = 'Which type of starters do you prefer mostly?',
                Question_Type__c = 'RadioPicklist',
                Question_Order_No__c = 1,
                Section_Question__c = sectionList[0].Id
            ),
            new Question_Template__c(
                Question_Label__c = 'Which category do you like most?',
                Question_Type__c = 'Button',
                Question_Order_No__c = 2,
                Section_Question__c = sectionList[0].Id
            ),
            new Question_Template__c(
                Question_Label__c = 'Which category do you like most?',
                Question_Type__c = 'Button',
                Question_Order_No__c = 3,
                Section_Question__c = sectionList[0].Id,
                Is_Dependent__c = true
            ),
            new Question_Template__c(
                Question_Label__c = 'Which type of Main Course do you choose mostly?',
                Question_Type__c = 'Button',
                Question_Order_No__c = 1,
                Section_Question__c = sectionList[1].Id
            ),
            new Question_Template__c(
                Question_Label__c = 'Which category do you like most?',
                Question_Type__c = 'Button',
                Question_Order_No__c = 2,
                Subquestion_Label__c = 'Sea Food~Others',
                Weight_of_Answer__c = '20~10',
                Section_Question__c = sectionList[1].Id
            ),
            new Question_Template__c(
                Question_Label__c = 'Which category do you like most?',
                Question_Type__c = 'Button',
                Question_Order_No__c = 3,
                Section_Question__c = sectionList[1].Id
            ),
            new Question_Template__c(
                Question_Label__c = 'Which category do you prefer mostly?',
                Question_Type__c = 'RadioPicklist',
                Question_Order_No__c = 4,
                Subquestion_Label__c = 'Meals~Biriyani~Others',
                Weight_of_Answer__c = '20~10~15',
                Is_Dependent__c = true,
                Section_Question__c = sectionList[1].Id
            ),
            new Question_Template__c(
                Question_Label__c = 'Which flavor do you like the most?',
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
        
        Map<Id,Question_Template__c> oldIdWthquestion = new Map<Id,Question_Template__c>(questionList);
        
        List<Answer_Option__c> answerOptionsList = new List<Answer_Option__c>{
            new Answer_Option__c(
                Name = 'Veg',
                Order_No__c = 1,
                Question_Template__c = questionList[0].Id
            ), 
            new Answer_Option__c(
                Name = 'Non-Veg',
                Order_No__c = 2,
                Question_Template__c = questionList[0].Id,
                Next_Question__c = questionList[1].Id
            ),
            new Answer_Option__c(
                Name = 'Sea Food',
                Order_No__c = 1,
                Question_Template__c = questionList[1].Id
            ),
            new Answer_Option__c(
                Name = 'Others',
                Order_No__c = 2,
                Question_Template__c = questionList[1].Id                    
            ),
            new Answer_Option__c(
                Name = 'Meals',
                Order_No__c = 1,
                Question_Template__c = questionList[2].Id,
                Dependent_Question__c =  questionList[1].Id
            ),
            new Answer_Option__c(
                Name = 'Veg',
                Order_No__c = 1,
                Question_Template__c = questionList[3].Id
            ), 
            new Answer_Option__c(
                Name = 'Non-Veg',
                Order_No__c = 2,
                Question_Template__c = questionList[3].Id
            ), 
            new Answer_Option__c(
                Name = 'Veg',
                Order_No__c = 1,
                Question_Template__c = questionList[5].Id
            ), 
            new Answer_Option__c(
                Name = 'Non-Veg',
                Order_No__c = 2,
                Question_Template__c = questionList[5].Id
            ), 
            new Answer_Option__c(
                Name = 'Chocolate',
                Order_No__c = 1,
                Question_Template__c = questionList[7].Id
            ),
            new Answer_Option__c(
                Name = 'Strawberry',
                Order_No__c = 2,
                Question_Template__c = questionList[7].Id
            )
                
        };
        insert answerOptionsList;
        set<Id> questionHasAnswers = new Set<Id>();
        for(Answer_Option__c answer : answerOptionsList){
            questionHasAnswers.add(answer.Question_Template__c);
        }
        
        Integer count = 0;
        
        for(Question_Template__c question : questionList){
            
            if(!questionHasAnswers.contains(question.Id)){
                
                if(question.Subquestion_Label__c != null){
                    List<String> answers = question.Subquestion_Label__c.split('~');
                    count += answers.size();
                }
                
            }
        }
        
        count += answerOptionsList.size();
        
        Map<Id,Answer_Option__c> oldIdWthAnswer = new Map<Id,Answer_Option__c>(answerOptionsList);
        
        
        List<Attachment> attach = new List<Attachment>{
            new Attachment(
                ParentId = answerOptionsList[9].Id,
                Name = 'kk',
                ContentType = 'jpg',
                Body = EncodingUtil.base64Decode('sfkjdhkjd')
            ),
            new Attachment(
                ParentId = answerOptionsList[10].Id,
                Name = 'kk1',
                ContentType = 'jpg',
                Body = EncodingUtil.base64Decode('sfkjdhkjd')
            )
                
        };
                    
        insert attach;
        
        List<Attachment> attachByQuestion = new List<Attachment>{
            
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
            )
                
        };
                    
        insert attachByQuestion;
        
        Map<Id,String> assessmentIdWthTempName = new Map<Id,String>{assessment.Id => 'test Food Survey'};
        ExamManager.clone(assessmentIdWthTempName);
        
        Map<Id,Id> oldWthNewId = new Map<Id,Id>();
        Map<Id,Id> questionOldWthNewId = new Map<Id,Id>();
        List<Question_Template__c> newQuestionList = [SELECT Id,Name FROM Question_Template__c WHERE Id NOT IN:oldIdWthquestion.keySet()];
        List<Answer_Option__c> newAnswerOptionsList = [SELECT Id,Name FROM Answer_Option__c WHERE Id NOT IN:oldIdWthAnswer.keySet()];
        
        
        for(Integer i = 0; i < newAnswerOptionsList.size(); i++){
            
            if(answerOptionsList.size() > i){
                oldWthNewId.put(answerOptionsList[i].Id, newAnswerOptionsList[i].Id); 
            }
            
        }
        
        for(Integer i = 0; i < newQuestionList.size(); i++){
            questionOldWthNewId.put(questionList[i].Id, newQuestionList[i].Id);
        }
        
        
        List<Main_questionaire__c> assessmentList = [SELECT Id, Template_name__c FROM Main_questionaire__c WHERE Template_name__c = 'test Food Survey'];
        System.assertEquals(1,assessmentList.size());
        
        
        List<Section_Template__c> cloneSectionList = [SELECT Id,Questionnaire_Section__c FROM Section_Template__c WHERE Questionnaire_Section__c =:assessmentList[0].Id];
        System.assertEquals(sectionList.size(), cloneSectionList.size());
        
        List<Question_Template__c> cloneQuestionList = [SELECT Id,Name,Section_Question__c FROM Question_Template__c WHERE Section_Question__c NOT IN:oldIdWthSection.keySet()];
       	System.assertEquals(questionList.size(), cloneQuestionList.size());
        
        System.assertEquals(count, newAnswerOptionsList.size());
        
        BatchAttachmentClone cloneAttachment = new BatchAttachmentClone(oldWthNewId,false);
        BatchAttachmentClone cloneAttachmentByQuestion = new BatchAttachmentClone(questionOldWthNewId,true);
        Test.StartTest();
        Database.executeBatch(cloneAttachment);
        Database.executeBatch(cloneAttachmentByQuestion);
        Test.StopTest();
        
        List<Attachment> attachmentListByAnswer = [SELECT Id,ParentId FROM Attachment WHERE ParentId =:oldWthNewId.values()];
        System.assertEquals(attach.size(), attachmentListByAnswer.size());
    }
    
}