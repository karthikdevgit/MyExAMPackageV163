@isTest
private class TestQuestionResponseAnalyticsController {
    static testMethod void validateGetAnswerResponseWithCount(){
        
        Main_questionaire__c assessment = new Main_questionaire__c();
        assessment.Template_name__c = 'ExAM';
        insert assessment;
        
        Section_Template__c section = new Section_Template__c();
        section.Section_label__c = 'Section1';
        section.Questionnaire_Section__c = assessment.Id;
        insert section;

        List<Question_Template__c> quesTempList = new List<Question_Template__c> {
            new Question_Template__c(Section_Question__c = section.id, Question_Label__c = 'Radio Question', 
                Question_Order_No__c = 1, Question_Type__c = 'RadioPicklist', Weight_of_Answer__c  = '10'),       
            new Question_Template__c(Section_Question__c = section.id, Question_Label__c = 'MultiSelect Question', 
                Question_Order_No__c = 2, Question_Type__c = 'MultiselectPicklist', Weight_of_Answer__c  = '10'),  
            new Question_Template__c(Section_Question__c = section.id, Question_Label__c = 'Button Question', 
                Question_Order_No__c = 3, Question_Type__c = 'Button', Weight_of_Answer__c  = '10'),
            new Question_Template__c(Section_Question__c = section.id, Question_Label__c = 'Text Question', 
                Question_Order_No__c = 4, Question_Type__c = 'Text', Weight_of_Answer__c  = '10'),       
            new Question_Template__c(Section_Question__c = section.id, Question_Label__c = 'TextArea Question', 
                Question_Order_No__c = 5, Question_Type__c = 'Textarea', Weight_of_Answer__c  = '10'),  
            new Question_Template__c(Section_Question__c = section.id, Question_Label__c = 'Email Question', 
                Question_Order_No__c = 6, Question_Type__c = 'Email', Weight_of_Answer__c  = '10')
        };
        insert quesTempList;

        List<Answer_Option__c> ansoptions1 = new List<Answer_Option__c> {
            new Answer_Option__c(Question_Template__c = quesTempList[0].Id, Order_No__c = 1, Name = 'RadiooptA'),
            new Answer_Option__c(Question_Template__c = quesTempList[0].Id, Order_No__c = 2, Name = 'RadiooptB'),
            new Answer_Option__c(Question_Template__c = quesTempList[1].Id, Order_No__c = 3, Name = 'MultioptA'),
            new Answer_Option__c(Question_Template__c = quesTempList[1].Id, Order_No__c = 4, Name = 'MultioptB'),
            new Answer_Option__c(Question_Template__c = quesTempList[2].Id, Order_No__c = 5, Name = 'ButtonoptA'),
            new Answer_Option__c(Question_Template__c = quesTempList[2].Id, Order_No__c = 6, Name = 'ButtonoptB'),
            new Answer_Option__c(Question_Template__c = quesTempList[2].Id, Order_No__c = 7, Name = 'ButtonoptC')
           
        };
        insert ansoptions1;
        
        List<Questionnaire_Response__c> dependAnsList = new  list<Questionnaire_Response__c>{
            new Questionnaire_Response__c(Question_Template__c = quesTempList[0].Id,Response__c='RadiooptA'),
            new Questionnaire_Response__c(Question_Template__c = quesTempList[0].Id,Response__c='RadiooptA'),
            new Questionnaire_Response__c(Question_Template__c = quesTempList[0].Id,Response__c='RadiooptB'),
            new Questionnaire_Response__c(Question_Template__c = quesTempList[0].Id,Response__c='RadiooptB'),
            new Questionnaire_Response__c(Question_Template__c = quesTempList[0].Id,Response__c='RadiooptB'),
            new Questionnaire_Response__c(Question_Template__c = quesTempList[0].Id,Response__c='RadiooptB'),
            new Questionnaire_Response__c(Question_Template__c = quesTempList[1].Id,Response__c='MultioptA'),
            new Questionnaire_Response__c(Question_Template__c = quesTempList[1].Id,Response__c='MultioptA'),
            new Questionnaire_Response__c(Question_Template__c = quesTempList[1].Id,Response__c='MultioptA'),
            new Questionnaire_Response__c(Question_Template__c = quesTempList[1].Id,Response__c='MultioptB'),
            new Questionnaire_Response__c(Question_Template__c = quesTempList[1].Id,Response__c='MultioptB'),
            new Questionnaire_Response__c(Question_Template__c = quesTempList[2].Id,Response__c='ButtonoptA'),
            new Questionnaire_Response__c(Question_Template__c = quesTempList[2].Id,Response__c='ButtonoptB'),
            new Questionnaire_Response__c(Question_Template__c = quesTempList[2].Id,Response__c='ButtonoptB'),
            new Questionnaire_Response__c(Question_Template__c = quesTempList[2].Id,Response__c='ButtonoptC'),
            new Questionnaire_Response__c(Question_Template__c = quesTempList[2].Id,Response__c='ButtonoptC'),
            new Questionnaire_Response__c(Question_Template__c = quesTempList[2].Id,Response__c='ButtonoptC'),
            new Questionnaire_Response__c(Question_Template__c = quesTempList[3].Id,Response__c='Text Ans'),
            new Questionnaire_Response__c(Question_Template__c = quesTempList[3].Id,Response__c='Text'),
            new Questionnaire_Response__c(Question_Template__c = quesTempList[4].Id,Response__c='TextAreaResp'),
            new Questionnaire_Response__c(Question_Template__c = quesTempList[4].Id,Response__c='TextAreaResp'),
            new Questionnaire_Response__c(Question_Template__c = quesTempList[5].Id,Response__c='ss@gmail.com'),
            new Questionnaire_Response__c(Question_Template__c = quesTempList[5].Id,Response__c='ss2@gmail.com'),
            new Questionnaire_Response__c(Question_Template__c = quesTempList[5].Id,Response__c='ss2@gmail.com')
            
        };
        
        Integer noOfRec = 5;
        for(Integer i = 1; i <= 30; i++){
            
            for(Integer j = 0; j < noOfRec; j++){
                Questionnaire_Response__c answerResponse = new Questionnaire_Response__c();
                answerResponse.Response__c = 'opt'+i;
                answerResponse.Question_Template__c = quesTempList[3].Id;
                dependAnsList.add(answerResponse);
            }
            noOfRec += 5;
        }
        
        insert dependAnsList;
        
        QuestionResponseAnalyticsController.QuestionAnalyticInfo response = QuestionResponseAnalyticsController.getAnswerResponseWithCount(assessment.Id, 0);
        
        Integer noOfQuestions = response.noOfQuestions;
        System.assertEquals(6, noOfQuestions);
        
        List<QuestionResponseAnalyticsController.QuestionAnalytic> QuestionAnalyticResponse = response.questions;
        System.assertEquals(6, QuestionAnalyticResponse.size());
        
        //(Option based) CASE 1 : RadioPicklist question 
        
        String questionLable = QuestionAnalyticResponse[0].questionLablel;
        System.assertEquals('Radio Question', questionLable);
        
        List<QuestionResponseAnalyticsController.AnswerAnalytic> answer = QuestionAnalyticResponse[0].answer;
        System.assertEquals('RadiooptA', answer[0].name);
        System.assertEquals(2, answer[0].weight);
        
        System.assertEquals('RadiooptB', answer[1].name);
        System.assertEquals(4, answer[1].weight);
        
        // CASE 2 : MultiselectPicklist question 
        
        questionLable = QuestionAnalyticResponse[1].questionLablel;
        System.assertEquals('MultiSelect Question', questionLable);
        
        answer = QuestionAnalyticResponse[1].answer;
        System.assertEquals('MultioptA', answer[0].name);
        System.assertEquals(3, answer[0].weight);
        
        System.assertEquals('MultioptB', answer[1].name);
        System.assertEquals(2, answer[1].weight);
        
        // CASE 3 : Button Question 
        
        questionLable = QuestionAnalyticResponse[2].questionLablel;
        System.assertEquals('Button Question', questionLable);
        
        answer = QuestionAnalyticResponse[2].answer;
        System.assertEquals('ButtonoptA', answer[0].name);
        System.assertEquals(1, answer[0].weight);
        
        System.assertEquals('ButtonoptB', answer[1].name);
        System.assertEquals(2, answer[1].weight);
        
        System.assertEquals('ButtonoptC', answer[2].name);
        System.assertEquals(3, answer[2].weight);
        
        //(Non option based) CASE 4 : text question 
        
        questionLable = QuestionAnalyticResponse[3].questionLablel;
        System.assertEquals('Text Question', questionLable);
        
        answer = QuestionAnalyticResponse[3].answer;
        System.assertEquals(15, answer.size());
        
        System.assertEquals('opt30', answer[0].name);
        System.assertEquals(150, answer[0].weight);
        
        System.assertEquals('opt16', answer[14].name);
        System.assertEquals(80, answer[14].weight);
        
        // CASE 5 : textArea question 
        
        questionLable = QuestionAnalyticResponse[4].questionLablel;
        System.assertEquals('TextArea Question', questionLable);
        
        answer = QuestionAnalyticResponse[4].answer;
        System.assertEquals('TextAreaResp', answer[0].name);
        System.assertEquals(2, answer[0].weight);
        
        // CASE 6 : Email Question 
        
        questionLable = QuestionAnalyticResponse[5].questionLablel;
        System.assertEquals('Email Question', questionLable);
        
        answer = QuestionAnalyticResponse[5].answer;
        System.assertEquals('ss@gmail.com', answer[0].name);
        System.assertEquals(1, answer[0].weight);   
        
        System.assertEquals('ss2@gmail.com', answer[1].name);
        System.assertEquals(2, answer[1].weight);     
    }
}