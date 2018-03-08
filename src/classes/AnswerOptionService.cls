public with sharing class AnswerOptionService {
    
    public static Map<String,List<object>> upsertAnswerOptions(String answerOptions, List<String> removeOptionIds, Boolean derivedFromQuestion, List<Decimal> removedOptionIndices){
        Map<String,List<object>> AnswerOptionsWthAttachment = new Map<String,List<object>>();
        Set<Decimal> removedOptionIndicesPosition = new Set<Decimal>(removedOptionIndices);
        List<Attachment> attachments;
        List<String> chainQuestionName = new List<String>();
        List<String> weightOfAnswerOption;
        List<Question_Template__c> chainQuestions;
        Map<String,String> chainQuestionNameWthId = new Map<String,String>();
        List<Answer_Option__c> ansOptionList = new List<Answer_Option__c>();
        Set<String> AnswerOptionsId = new Set<String>();        
        // upsert support 
        ansOptionList.addAll((List<Answer_Option__c>)JSON.deserialize(answerOptions, List<Answer_Option__c>.class));
        String questionId = ansOptionList[0].Question_Template__c;
        Question_Template__c questionTemplate = QuestionService.getQuestion(questionId);
        
        // start AnswerOption Derived From Question 
        if(derivedFromQuestion == true){
            
            if(questionTemplate.Dependent_Question__c != null){
                chainQuestionName = questionTemplate.Dependent_Question__c.split('~');
            }else if(questionTemplate.Next_Question__c != null){
                chainQuestionName = questionTemplate.Next_Question__c.split('~');
            }
            
            if(questionTemplate.Weight_of_Answer__c != null){
                weightOfAnswerOption = questionTemplate.Weight_of_Answer__c.split('~');
            }
            
            if(!chainQuestionName.isEmpty()){
                try{
                    String fields = 'Name';
                    String sObjectName = 'Question_Template__c';
                    FieldLevelSecurity.checkFieldAccessByCriteria(fields, 'view', sObjectName);
                    chainQuestions = [SELECT Id, Name FROM Question_Template__c Where Name IN :chainQuestionName]; 
                }
                catch(Exception e){
                    throw new AuraHandledException(e.getMessage());
                }
                
                for(Question_Template__c chainQuestion : chainQuestions){
                    chainQuestionNameWthId.put(chainQuestion.Name,chainQuestion.Id);
                }
            }
            
        }
        List<Question_Template__c> dependentQuestions = new List<Question_Template__c>();
        // upsert Answer Options
        if(!ansOptionList.isEmpty()){
            
            for(Integer i = 0; i < ansOptionList.size(); i++){
                
                if(!chainQuestionNameWthId.isEmpty() && chainQuestionName.size() > i) {
                    
                    if(questionTemplate.Dependent_Question__c != null){
                        ansOptionList[i].Dependent_Question__c = chainQuestionNameWthId.get(chainQuestionName[i]);
                    }else if(questionTemplate.Next_Question__c != null){
                        ansOptionList[i].Next_Question__c = chainQuestionNameWthId.get(chainQuestionName[i]);
                    }
                    
                }
                
                if(String.isNotBlank(ansOptionList[i].Dependent_Question__c)){
                    Question_Template__c question = new Question_Template__c();
                    question.Id = ansOptionList[i].Dependent_Question__c;
                    question.Is_Dependent__c = true;
                    dependentQuestions.add(question);
                }
                
                if(questionTemplate.Weight_of_Answer__c != null && weightOfAnswerOption.size() > i){
                    ansOptionList[i].Weight__c = Decimal.valueOf(weightOfAnswerOption[i]);
                }
            }
            try{
                String fields = 'Name, Dependent_Question__c, Order_No__c, Weight__c, Question_Template__c, Next_Question__c, Help_Text__c'; 
                FieldLevelSecurity.checkFieldAccessByCriteria(fields, 'create', 'Answer_Option__c');
                fields = 'Name, Dependent_Question__c, Order_No__c, Weight__c, Next_Question__c, Help_Text__c'; 
                FieldLevelSecurity.checkFieldAccessByCriteria(fields, 'update', 'Answer_Option__c');                
                upsert ansOptionList;
                
                if(!dependentQuestions.isEmpty()){
                    fields = 'Is_Dependent__c'; 
                    FieldLevelSecurity.checkFieldAccessByCriteria(fields, 'update', 'Question_Template__c');  
                    update dependentQuestions;
                }
            }
            catch(Exception e){
                throw new AuraHandledException(e.getMessage()); 
            }
            
            
        }
        //collect AnswerOptions Ids
        for(Integer i = 0; i < ansOptionList.size(); i++){
            AnswerOptionsId.add(ansOptionList[i].Id);
        }
        
        ansOptionList = getAnswerOptionsWthRef(AnswerOptionsId);
        
        
        // Delete AnswerOptions by Ids
        if(!removeOptionIds.isEmpty()){
           
            try{
                FieldLevelSecurity.checkObjectAccessByDelete('Answer_Option__c');
                Database.delete(removeOptionIds);
            }
            catch(Exception e){
                throw new AuraHandledException(e.getMessage());
            }
            
            try{
                String fields = 'Name';
                FieldLevelSecurity.checkFieldAccessByCriteria(fields, 'view', 'Attachment');
                attachments = [SELECT Id, Name FROM Attachment WHERE ParentId IN :AnswerOptionsId]; 
            }catch(Exception e){
                throw new AuraHandledException(e.getMessage()); 
            }
            
            for(Integer i = 0; i < attachments.size(); i++){
                attachments[i].Name = String.valueOf(i+1);
            }        
            // ReOrder the attachment Name
            if(!attachments.isEmpty()){                
                try{
                    String fields = 'Name';
                    FieldLevelSecurity.checkFieldAccessByCriteria(fields, 'update', 'Attachment');
                    update attachments;
                }catch(Exception e){
                    throw new AuraHandledException(e.getMessage());
                }
                
                //attachments = AttachmentService.removeAttachmentBody(attachments);
                /*for(Attachment attach : attachments){
                attach.Body = null;
                }*/
                AnswerOptionsWthAttachment.put('AnswerOptionsWthAttachments',attachments);
            }
            
        }
        
        List<Attachment> attachmentAnswer = new List<Attachment>();
        
        // Attachments Derived From Question
        if(derivedFromQuestion == true){
            
            try{
                String fields = 'Name, Body, ContentType';
                FieldLevelSecurity.checkFieldAccessByCriteria(fields, 'view', 'Attachment');
                attachments = [SELECT Id, Name, ContentType, Body FROM Attachment WHERE ParentId = :questionId ORDER BY Name];
            }
            catch(Exception e){
                throw new AuraHandledException(e.getMessage());
            }
            
            // create Attachment Under by AnswerOptions
            if(!attachments.isEmpty()){
                Integer k = 0;
                for(Integer i = 0; i < ansOptionList.size(); i++){
                    if(!removedOptionIndicesPosition.contains(i)){

                        if(attachments.size() > k && attachments[k].Name == String.valueOf(i+1)){
                            Attachment attachment = new Attachment(Name = attachments[k].Name, ParentId = ansOptionList[i].Id, Body = attachments[k].Body, ContentType = attachments[k].ContentType); 
                            k++;
                            attachmentAnswer.add(attachment);
                        }
                        
                    }
                }
                
                attachmentAnswer = AttachmentService.createAttachments(attachmentAnswer);
                
                attachmentAnswer = AttachmentService.removeAttachmentBody(attachmentAnswer);
                AnswerOptionsWthAttachment.put('AnswerOptionsWthAttachments',attachmentAnswer);
            }
            
        }
        
        AnswerOptionsWthAttachment.put('AnswerOptions',ansOptionList);
        
        return AnswerOptionsWthAttachment;
    }
    
    public static map<String,Answer_Option__c> cloneAnswerOptionsByQuesId(Map<String,String> questionOldIdWthNewId){
        
        Set<String> oldQuestionIds = questionOldIdWthNewId.keySet();
        List<Answer_Option__c> answerOptions = getAnswerOptionsByQuesIds(oldQuestionIds);
        
        Map<String,Answer_Option__c> answerOldIdWthNewAnswer = new Map<String,Answer_Option__c>();
        
        for(Answer_Option__c answerOption : answerOptions){
            String oldAnswerId = answerOption.Id;
            answerOption.Id = null;
            answerOption.Question_Template__c = questionOldIdWthNewId.get(answerOption.Question_Template__c);
            
            if(answerOption.Next_Question__c != null){
                
                answerOption.Next_Question__c = questionOldIdWthNewId.get(answerOption.Next_Question__c);
            }else if (answerOption.Dependent_Question__c != null){
                answerOption.Dependent_Question__c = questionOldIdWthNewId.get(answerOption.Dependent_Question__c);
            }
            
            answerOldIdWthNewAnswer.put(oldAnswerId,answerOption);
        }        
        
        if(!answerOldIdWthNewAnswer.isEmpty()){
            String fields = 'Name, Dependent_Question__c, Order_No__c, Weight__c, Question_Template__c, Next_Question__c, Help_Text__c';
            FieldLevelSecurity.checkFieldAccessByCriteria(fields, 'create', 'Answer_Option__c');
            insert answerOldIdWthNewAnswer.values();
        }
        
        return answerOldIdWthNewAnswer;
    }
    
    public static Map<String,Answer_Option__c> cloneAnswerOptions(String questionId, String newQuestionId, Boolean withInSection){
        Set<String> questionIds = new Set<String>{questionId};
        List<Answer_Option__c> answerOptions;
        if(withInSection == true){
            answerOptions = getAnswerOptionsWthRefByQuesIds(questionIds);
        }else{
            answerOptions = getAnswerOptionsByQuesIds(questionIds);
        }
        Map<String,Answer_Option__c> answerOldIdWthNewAnswer = new Map<String,Answer_Option__c>();
        
        for(Answer_Option__c answerOption : answerOptions){
            String oldAnswerId = answerOption.Id;
            answerOption.Id = null;
            answerOption.Question_Template__c = newQuestionId;
            if(withInSection == false){
                
                if(answerOption.Dependent_Question__c != null){
                    answerOption.Dependent_Question__c = null;
                }else if(answerOption.Next_Question__c != null){
                    answerOption.Next_Question__c = null;
                }
            }
            answerOldIdWthNewAnswer.put(oldAnswerId,answerOption);
        }
        
        if(!answerOldIdWthNewAnswer.isEmpty()){
            
            try{
                String fields = 'Name, Dependent_Question__c, Order_No__c, Weight__c, Question_Template__c, Next_Question__c, Help_Text__c';
                FieldLevelSecurity.checkFieldAccessByCriteria(fields, 'create', 'Answer_Option__c');
                insert answerOldIdWthNewAnswer.values();
            }
            catch(Exception e){
                throw new AuraHandledException(e.getMessage());
            }
            
        }
        
        return answerOldIdWthNewAnswer;
    }
    
    public static List<Answer_Option__c> getAnswerOptionsByQuesIds(Set<String> questionIds){
        
        try{
            String fields = 'Name, Dependent_Question__c, Order_No__c, Weight__c, Question_Template__c, Next_Question__c, Help_Text__c';
            FieldLevelSecurity.checkFieldAccessByCriteria(fields, 'view', 'Answer_Option__c');
            List<Answer_Option__c> answerOptions = [SELECT Name, Dependent_Question__c, Order_No__c, Weight__c, Question_Template__c, Next_Question__c, Help_Text__c FROM Answer_Option__c WHERE Question_Template__c IN :questionIds ORDER BY Order_No__c];
            return answerOptions;
        }
        catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
        
    }
    public static List<Answer_Option__c> getAnswerOptionsWthRefByQuesIds(Set<String> questionIds){
        
        try{
            String fields = 'Name, Dependent_Question__c, Order_No__c, Weight__c, Question_Template__c, Next_Question__c, Help_Text__c';
            FieldLevelSecurity.checkFieldAccessByCriteria(fields, 'view', 'Answer_Option__c');
            fields = 'Name, Question_Label__c';
            FieldLevelSecurity.checkFieldAccessByCriteria(fields, 'view', 'Question_Template__c');
            List<Answer_Option__c> answerOptions = [SELECT Name, Dependent_Question__r.Name, 
                                                    Dependent_Question__r.Question_Label__c, Next_Question__r.Question_Label__c,
                                                    Dependent_Question__c, Order_No__c, Weight__c, Question_Template__c, 
                                                    Next_Question__c, Next_Question__r.Name, Help_Text__c FROM Answer_Option__c WHERE Question_Template__c IN :questionIds ORDER BY Order_No__c];
            return answerOptions;
        }
        catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
        
    }
    
    public static List<Answer_Option__c> getAnswerOptionsWthRef(Set<String> answerOptionsIds){
        
        try{
            String fields = 'Name, Dependent_Question__c, Order_No__c, Weight__c, Question_Template__c, Next_Question__c, Help_Text__c';
            String sObjectName = 'Answer_Option__c';
            FieldLevelSecurity.checkFieldAccessByCriteria(fields, 'view', sObjectName);
            fields = 'Name, Question_Label__c';
            sObjectName = 'Question_Template__c';
            FieldLevelSecurity.checkFieldAccessByCriteria(fields, 'view', sObjectName);
            List<Answer_Option__c> answerOptions= [SELECT Id,Name,Order_No__c,Dependent_Question__r.Name,
                                                   Dependent_Question__r.Question_Label__c,
                                                   Next_Question__r.Question_Label__c,
                                                   Help_Text__c,Next_Question__r.Name,Weight__c,Question_Template__c FROM Answer_Option__c WHERE Id IN :answerOptionsIds];
            return answerOptions;
        }
        catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
        
    }
    
    public static String getGrandParentsRef(String answerOptionId){
        FieldLevelSecurity.checkFieldAccessByCriteria( 'Question_Template__c', 'view', 'Answer_Option__c');
        FieldLevelSecurity.checkFieldAccessByCriteria( 'Section_Question__c', 'view', 'Question_Template__c');
        FieldLevelSecurity.checkFieldAccessByCriteria( 'Questionnaire_Section__c', 'view', 'Section_Template__c');
        
        Answer_Option__c answerOption = [SELECT Id, Question_Template__r.Section_Question__r.Questionnaire_Section__c FROM Answer_Option__c WHERE Id =:answerOptionId];
        String assessmentId = answerOption.Question_Template__r.Section_Question__r.Questionnaire_Section__c;
        return assessmentId;
    }
}