public with sharing class QuestionResponseAnalyticsController {
    @AuraEnabled 
    public static QuestionAnalyticInfo getAnswerResponseWithCount(String assessmentId, Integer offset){
        
        Map<Id, Section_Template__c> sectionTemplates = new Map<Id, Section_Template__c>([SELECT Id, Questionnaire_Section__c FROM Section_Template__c WHERE Questionnaire_Section__c = :assessmentId]);
        Map<Id, List<Questionnaire_Response__c>> questionIdWthAnswers = new Map<Id, List<Questionnaire_Response__c>>();
        
        Set<String> OptionBasedQuestionTypes = new Set<String>{'Dropdown Picklist','RadioPicklist', 
            'Button', 'MultiselectPicklist', 'List', 'Image', 'Horizontal Radiopicklist',
            'Hotspot Image'};
                
        List<String> filteringQuestionTypes = new List<String>{'Text','Textarea','Email'};
                    
        filteringQuestionTypes.addAll(OptionBasedQuestionTypes);
                
        String fields = 'Question_Template__c, Response__c';
        FieldLevelSecurity.checkFieldAccessByCriteria(fields, 'view', 'Questionnaire_Response__c');     
        
        List<Questionnaire_Response__c>  answerRecords = [SELECT Id, Question_Template__c, Response__c
                                                                  FROM Questionnaire_Response__c 
                                                                  WHERE Question_Template__r.Section_Question__c IN :sectionTemplates.keySet() 
                                                                  AND Question_Template__r.Question_Type__c IN :filteringQuestionTypes];
        
        for(Questionnaire_Response__c answerRecord : answerRecords){
            
            if(questionIdWthAnswers.containsKey(answerRecord.Question_Template__c)){
                questionIdWthAnswers.get(answerRecord.Question_Template__c).add(answerRecord);
            }else{
                questionIdWthAnswers.put(answerRecord.Question_Template__c, new List<Questionnaire_Response__c>{answerRecord});
            }
            
        }
        
        Set<Id> questionIds = questionIdWthAnswers.keySet();
        
        fields = 'Question_Label__c, Subquestion_Label__c, Question_Type__c';
        FieldLevelSecurity.checkFieldAccessByCriteria(fields, 'view', 'Question_Template__c');  
        
        String strQuery = 'SELECT Id, Question_Label__c, Subquestion_Label__c, Question_Type__c' 
            +' FROM Question_Template__c'
            +' WHERE Id IN : questionIds '            
            +' ORDER BY CreatedDate LIMIT 10 OFFSET ' + offset;
        
        
        List<Question_Template__c>  questions = Database.query(strQuery);
        List<QuestionAnalytic> QuestionAnalyticResponse = new List<QuestionAnalytic>();
        
        for(Question_Template__c question : questions){            
            List<Questionnaire_Response__c> answers = questionIdWthAnswers.get(question.Id);
            QuestionAnalytic questionResponse = new QuestionAnalytic();
            questionResponse.questionLablel = question.Question_Label__c;
            List<AnswerAnalytic> answerResponse = constructAnswerResponse(question, answers);
            
            if(OptionBasedQuestionTypes.contains(question.Question_Type__c)){
                questionResponse.optionBased = true;
                questionResponse.answer = answerResponse;
            }else{
                questionResponse.optionBased = false;
                if(answerResponse.size() > 15){
                    List<AnswerAnalytic> answerResponseDescList = new List<AnswerAnalytic>();
                    answerResponse.sort();
                    for(Integer i = 0; i < answerResponse.size()-1; i++){
                        
                        AnswerAnalytic answerResponseDesc = new AnswerAnalytic();
                        answerResponseDesc.Name = answerResponse[i].Name;
                        answerResponseDesc.weight = answerResponse[i].weight;
                        answerResponseDescList.add(answerResponseDesc);
                        
                        if(answerResponseDescList.size() == 15){
                            break;
                        }
                        
                    }
                    questionResponse.answer = answerResponseDescList; 
                }else{
                    questionResponse.answer = answerResponse;
                }
            }
            
            QuestionAnalyticResponse.add(questionResponse);
            
        }
        
        QuestionAnalyticInfo questionSizeAndCurrentViewer = new QuestionAnalyticInfo();
        questionSizeAndCurrentViewer.noOfQuestions = questionIds.size();
        questionSizeAndCurrentViewer.questions = QuestionAnalyticResponse;
        
        return questionSizeAndCurrentViewer;
    }
    
    public static List<AnswerAnalytic> constructAnswerResponse(Question_Template__c question, List<Questionnaire_Response__c> answers){
        Map<String, AnswerAnalytic> responseNameWthAnswerAnalytic = new Map<String, AnswerAnalytic>();
        for(Questionnaire_Response__c answer : answers){            
            if(question.Question_Type__c == 'MultiselectPicklist'){
                constructMultiPickResponse(answer.Response__c, responseNameWthAnswerAnalytic);
            }else{
                
                if(responseNameWthAnswerAnalytic.containsKey(answer.Response__c)){
                    AnswerAnalytic oldResponse = responseNameWthAnswerAnalytic.get(answer.Response__c);
                    oldResponse.weight += 1;
                }else{
                    AnswerAnalytic newResponse = new AnswerAnalytic();
                    newResponse.name = answer.Response__c;
                    newResponse.weight = 1;
                    responseNameWthAnswerAnalytic.put(answer.Response__c, newResponse);
                }
                
            }            
        }
        return responseNameWthAnswerAnalytic.values();
    }
    
    public static Map<String, AnswerAnalytic> constructMultiPickResponse(String answer, Map<String, AnswerAnalytic> responseNameWthAnswerAnalytic){
        List<String> answerResponse = answer.split('~');
        for(Integer i = 0; i < answerResponse.size(); i++){
            if(responseNameWthAnswerAnalytic.containsKey(answerResponse[i])){
                AnswerAnalytic oldResponse = responseNameWthAnswerAnalytic.get(answerResponse[i]);
                oldResponse.weight += 1; 
            }else{
                AnswerAnalytic newResponse = new AnswerAnalytic();
                newResponse.name = answerResponse[i];
                newResponse.weight = 1;
                responseNameWthAnswerAnalytic.put(answerResponse[i], newResponse);
            }
        }
        return responseNameWthAnswerAnalytic;
    }
    public class QuestionAnalyticInfo {
        @AuraEnabled
        public Integer noOfQuestions;
        @AuraEnabled
        public List<QuestionAnalytic> questions;
    }
    public class QuestionAnalytic {
        @AuraEnabled
        public String questionLablel;
        @AuraEnabled
        public Boolean optionBased;
        @AuraEnabled
        public List<AnswerAnalytic> answer;
    }
    public class AnswerAnalytic implements Comparable{
        @AuraEnabled
        public String name;	// response name of Answer
        @AuraEnabled
        public Integer weight; // count
        public Integer compareTo(Object compareTo) {
            
            AnswerAnalytic other = (AnswerAnalytic) compareTo;
            
            if (this.weight <= other.weight)
                return 1;
            else if (this.weight > other.weight)
                return 0;
            return -1;
        }
    }
}