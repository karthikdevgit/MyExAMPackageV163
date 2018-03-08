@isTest
private class TestContextQuestionMappingConfigCtlr {

    static testMethod void method1(){
    
        List<Main_questionaire__c> asstempList = new List<Main_questionaire__c>{
            new Main_questionaire__c(Context_Questions_Mapping__c = 'field1~Comment__c'),
            new Main_questionaire__c(Context_Questions_Mapping__c = 'field1~Comment__c:field2~Comment__c')
        };
        insert asstempList;
        
        List<Section_Template__c> sectempList = new List<Section_Template__c>{
            new Section_Template__c(Questionnaire_Section__c = asstempList[0].Id),
            new Section_Template__c(Questionnaire_Section__c = asstempList[1].Id)
        };
        insert sectempList;
        
        List<Question_Template__c> questempList = new List<Question_Template__c>{
            new Question_Template__c(Question_Label__c = 'question1',Section_Question__c = sectempList[0].Id),
            new Question_Template__c(Question_Label__c = 'question2',Section_Question__c = sectempList[0].Id),
            new Question_Template__c(Question_Label__c = 'question3',Section_Question__c = sectempList[0].Id),
            new Question_Template__c(Question_Label__c = 'question4',Section_Question__c = sectempList[0].Id),
            new Question_Template__c(Question_Label__c = 'question5',Section_Question__c = sectempList[0].Id)
        };
        insert questempList;
        system.debug('::::questempList::::'+questempList);
        
        List<Question_Template__c> queryQuesTempList = [SELECT Id,Name FROM Question_Template__c WHERE Section_Question__c = :sectempList[0].Id];
        List<Question_Template__c> updateQuestempList = new List<Question_Template__c>{
            new Question_Template__c(Id=queryQuesTempList[0].Id,Next_Question__c=queryQuesTempList[1].Name),
            new Question_Template__c(Id=queryQuesTempList[1].Id,Next_Question__c=queryQuesTempList[2].Name+'~'+queryQuesTempList[3].Name)
        };
        update updateQuestempList;
        system.debug('::::updateQuestempList::::'+updateQuestempList);
        
        List<Main_questionaire__c> tempList = [SELECT Id,Context_Questions_Mapping__c FROM Main_questionaire__c];
        tempList[0].Context_Questions_Mapping__c = queryQuesTempList[4].Id+'~comment__c';
        update tempList;
        
        List<ContextQuestionMappingConfigCtlr.QuestionAndAnswerFieldClass> quesAndAnsFieldsList = new List<ContextQuestionMappingConfigCtlr.QuestionAndAnswerFieldClass>();
        ContextQuestionMappingConfigCtlr.QuestionAndAnswerFieldClass quesIdAndAnsField = new ContextQuestionMappingConfigCtlr.QuestionAndAnswerFieldClass();
        quesIdAndAnsField.questionId = questempList[0].Id;
        quesIdAndAnsField.answerFieldApi = 'test_field__c';
        quesAndAnsFieldsList.add(quesIdAndAnsField);
        
        List<ContextQuestionMappingConfigCtlr.QuestionAndAnswerFieldClass> quesAndAnsFieldsList1 = new List<ContextQuestionMappingConfigCtlr.QuestionAndAnswerFieldClass>();
        ApexPages.currentPage().getParameters().put('assTempId',asstempList[0].Id);
        ContextQuestionMappingConfigCtlr conQuesMapObj = new ContextQuestionMappingConfigCtlr();
        String savedMappingRes = ContextQuestionMappingConfigCtlr.saveMappingFieldsFunc(quesAndAnsFieldsList, asstempList[0].Id,true);
        System.assertEquals('success', savedMappingRes);
    }
    
    static testMethod void method2(){
    
        List<Main_questionaire__c> asstempList = new List<Main_questionaire__c>{
            new Main_questionaire__c()
        };
        insert asstempList;
        
        List<Section_Template__c> sectempList = new List<Section_Template__c>{
            new Section_Template__c(Questionnaire_Section__c = asstempList[0].Id)
        };
        insert sectempList;
        
        List<Question_Template__c> questempList = new List<Question_Template__c>{
            new Question_Template__c(Question_Label__c = 'question1',Section_Question__c = sectempList[0].Id),
            new Question_Template__c(Question_Label__c = 'question2',Section_Question__c = sectempList[0].Id),
            new Question_Template__c(Question_Label__c = 'question3',Section_Question__c = sectempList[0].Id)
        };
        insert questempList;
        
        List<Question_Template__c> updateQuestempList = new List<Question_Template__c>{
            new Question_Template__c(Id=questempList[0].Id,Next_Question__c=questempList[1].Name),
            new Question_Template__c(Id=questempList[1].Id,Next_Question__c=questempList[2].Name)
        };
        update updateQuestempList;
        
        List<ContextQuestionMappingConfigCtlr.QuestionAndAnswerFieldClass> quesAndAnsFieldsList = new List<ContextQuestionMappingConfigCtlr.QuestionAndAnswerFieldClass>();
        String savedMappingRes = ContextQuestionMappingConfigCtlr.saveMappingFieldsFunc(quesAndAnsFieldsList,asstempList[0].Id,true);
        System.assertEquals('success', savedMappingRes);
        
    }
    
    static testMethod void method3(){
    
        List<ContextQuestionMappingConfigCtlr.QuestionAndAnswerFieldClass> quesAndAnsFieldsList = new List<ContextQuestionMappingConfigCtlr.QuestionAndAnswerFieldClass>();
        ContextQuestionMappingConfigCtlr.QuestionAndAnswerFieldClass quesIdAndAnsField = new ContextQuestionMappingConfigCtlr.QuestionAndAnswerFieldClass();
        quesIdAndAnsField.questionId = 'dssd';
        quesIdAndAnsField.answerFieldApi = 'test_field__c';
        quesAndAnsFieldsList.add(quesIdAndAnsField);
        String savedMappingRes = ContextQuestionMappingConfigCtlr.saveMappingFieldsFunc(quesAndAnsFieldsList, 'dSADas',true);
        System.assertEquals('Invalid id: dSADas', savedMappingRes);
    }
}