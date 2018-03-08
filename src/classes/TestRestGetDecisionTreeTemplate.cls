@isTest
public class TestRestGetDecisionTreeTemplate {
    static testMethod void method1(){
        Main_questionaire__c[] templateList = new Main_questionaire__c[] {
            new Main_questionaire__c(Template_name__c = 'Fire Safety',Decision_Tree__c = 'Pictures:true:false:1~ExAM__Response__c:true:false:2~ExAM__Answer_Text__c:true:false:3~ExAM__Priority__c:true:false:4~ExAM__deficiency_status__c:true:false:5~ExAM__Answer_External_Id__c:true:false:6~ExAM__Comment__c:true:false:7')
        };
        insert templateList;
        Section_Template__c[] sectionTemplateList = new Section_Template__c[] {
            new Section_Template__c(Questionnaire_Section__c = templateList[0].Id, Section_label__c = 'Section Template 4')
        };
        insert sectionTemplateList; 
        Question_Template__c[] qtList = new Question_Template__c[] {
            new Question_Template__c(Subquestion_Label__c = '1~2~3~4~5', Question_Type__c = 'RadioPicklist', Question_Label__c = 'How is your overall experience?', Section_Question__c = sectionTemplateList[0].Id,Question_Order_No__c = 1,Decision_Tree__c = 'Pictures:true:false:1~ExAM__Response__c:true:false:2~ExAM__Answer_Text__c:true:false:3~ExAM__Priority__c:true:false:4~ExAM__deficiency_status__c:true:false:5~ExAM__Answer_External_Id__c:true:false:6~ExAM__Comment__c:true:false:7'),
            new Question_Template__c(Subquestion_Label__c = '1~2~3~4~5', Question_Type__c = 'RadioPicklist', Question_Label__c = 'How is your overall experience?', Section_Question__c = sectionTemplateList[0].Id,Question_Order_No__c = 2),
        	new Question_Template__c(Subquestion_Label__c = '1~2~3~4~5', Question_Type__c = 'RadioPicklist', Question_Label__c = 'How is your overall experience?', Section_Question__c = sectionTemplateList[0].Id,Question_Order_No__c = 3)
        };
        insert qtList;
        Answer_Option__c[] ansOptList = new Answer_Option__c[]{
        	new Answer_Option__c(Order_No__c=1,Name = 'opt1',Question_Template__c=qtList[0].Id,Next_Question__c=qtList[1].Id),
            new Answer_Option__c(Order_No__c=2,Name = 'opt2',Question_Template__c=qtList[0].Id,Next_Question__c=qtList[2].Id),
            new Answer_Option__c(Order_No__c=3,Name = 'opt3',Question_Template__c=qtList[1].Id)
        };
        insert ansOptList;
        RestGetDecisionTreeTemplate.DecisionTreeTemplateClass dttc = new RestGetDecisionTreeTemplate.DecisionTreeTemplateClass();
    	dttc.templateId = templateList[0].Id;
        List<String> tempIdList = new List<String>();
        tempIdList.add(templateList[0].Id);
        String res = RestGetDecisionTreeTemplate.getDecisionTreeTemplate(dttc);
        RestGetDecisionTreeTemplate.DecisionTreeTemplateResponseClass dtrc = (RestGetDecisionTreeTemplate.DecisionTreeTemplateResponseClass)JSON.deserialize(res, RestGetDecisionTreeTemplate.DecisionTreeTemplateResponseClass.class);
    	System.assertEquals(3, dtrc.questionNamewithQuestionTemplate.size());
    }
}