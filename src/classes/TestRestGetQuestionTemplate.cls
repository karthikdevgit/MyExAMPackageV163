@isTest
public class TestRestGetQuestionTemplate {
    static testMethod void method1(){
        Main_questionaire__c[] templateList = new Main_questionaire__c[] {
            new Main_questionaire__c(Template_name__c = 'Fire Safety'),
            new Main_questionaire__c(Template_name__c = 'Fire Safety1'),
            new Main_questionaire__c(Template_name__c = 'Fire Safety2')
        };
        insert templateList;
        Section_Template__c[] sectionTemplateList = new Section_Template__c[] {
            new Section_Template__c(Questionnaire_Section__c = templateList[0].Id, Section_label__c = 'Section Template 4')
        };
        insert sectionTemplateList; 
        Question_Template__c[] qtList = new Question_Template__c[] {
            new Question_Template__c(Subquestion_Label__c = '1~2~3~4~5', Question_Type__c = 'RadioPicklist', Question_Label__c = 'How is your overall experience?', Section_Question__c = sectionTemplateList[0].Id,Question_Order_No__c = 1,Next_Question__c='Q-1~Q-2'),
            new Question_Template__c(Subquestion_Label__c = '1~2~3~4~5', Question_Type__c = 'RadioPicklist', Question_Label__c = 'How is your overall experience?', Section_Question__c = sectionTemplateList[0].Id,Question_Order_No__c = 2,Next_Question__c='Q-2'),
        	new Question_Template__c(Subquestion_Label__c = '1~2~3~4~5', Question_Type__c = 'RadioPicklist', Question_Label__c = 'How is your overall experience?', Section_Question__c = sectionTemplateList[0].Id,Question_Order_No__c = 3)
        };
        insert qtList;
        Answer_Option__c[] ansOptList = new Answer_Option__c[]{
        	new Answer_Option__c(Order_No__c=1,Name = 'opt1',Question_Template__c=qtList[0].Id,Next_Question__c=qtList[1].Id),
            new Answer_Option__c(Order_No__c=2,Name = 'opt2',Question_Template__c=qtList[0].Id,Next_Question__c=qtList[2].Id),
            new Answer_Option__c(Order_No__c=3,Name = 'opt3',Question_Template__c=qtList[1].Id)
        };
        insert ansOptList;
        RestGetQuestionTemplate.QuestionTemplateClass qtc = new RestGetQuestionTemplate.QuestionTemplateClass();
        qtc.templateId = templateList[0].id;
        String res = RestGetQuestionTemplate.getQuestionTemplate(qtc);
        RestGetQuestionTemplate.QuestionTemplateResponseClass qtrc = (RestGetQuestionTemplate.QuestionTemplateResponseClass)JSON.deserialize(res, RestGetQuestionTemplate.QuestionTemplateResponseClass.class);
        System.assertEquals(1, qtrc.sectionTemplateRecord.size());
        qtc.templateId = templateList[1].id;
        RestGetQuestionTemplate.getQuestionTemplate(qtc);
        qtc.templateId = null;
        RestGetQuestionTemplate.getQuestionTemplate(qtc);
        
    }
    
}