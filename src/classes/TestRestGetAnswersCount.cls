@isTest
public class TestRestGetAnswersCount {
    static testMethod void method1(){
        List<Id> templateIdList = new List<Id>();
        Main_questionaire__c[] templateList = new Main_questionaire__c[] {
            new Main_questionaire__c(Template_name__c = 'Fire Safety')
        };
        insert templateList;
		templateIdList.add(templateList[0].Id);
        Section_Template__c[] sectionTemplateList = new Section_Template__c[] {
            new Section_Template__c(Questionnaire_Section__c = templateList[0].Id, Section_label__c = 'Section Template 4')
        };
        insert sectionTemplateList; 
        Question_Template__c[] qtList = new Question_Template__c[] {
            new Question_Template__c(Subquestion_Label__c = '1~2~3~4~5', Question_Type__c = 'RadioPicklist', Question_Label__c = 'How is your overall experience?', Section_Question__c = sectionTemplateList[0].Id,Question_Order_No__c = 1),
        	new Question_Template__c(Subquestion_Label__c = '1~2~3~4~5', Question_Type__c = 'RadioPicklist', Question_Label__c = 'How is your overall experience?', Section_Question__c = sectionTemplateList[0].Id,Question_Order_No__c = 2)
        };
        insert qtList;
        IssueRequest_Life_Cycle__c[] amList = new IssueRequest_Life_Cycle__c[]{
            new IssueRequest_Life_Cycle__c(InvestigationType__c =templateList[0].id),
            new IssueRequest_Life_Cycle__c(InvestigationType__c =templateList[0].id),
            new IssueRequest_Life_Cycle__c(InvestigationType__c =templateList[0].id),
            new IssueRequest_Life_Cycle__c(InvestigationType__c =templateList[0].id),
            new IssueRequest_Life_Cycle__c(InvestigationType__c =templateList[0].id)
        };
        insert amList;
        IssueRequest_Life_Cycle__c[] upAmList = new IssueRequest_Life_Cycle__c[]{
            new IssueRequest_Life_Cycle__c(Id=amList[0].id,Related_Assignment_Manager1__c=amList[1].id,
                                          Related_Assignment_Manager2__c=amList[2].id,
                                          Related_Assignment_Manager3__c=amList[3].id,
                                          Related_Assignment_Manager4__c=amList[4].id
                                          )
        };
        update upAmList;
        Questionnaire_Response__c[] resList = new Questionnaire_Response__c[]{
            new Questionnaire_Response__c(Response__c='1',Question_Template__c=qtList[0].Id,Issue_Request__c=amList[0].Id,Decision_Tree_Launched_Question__c=qtList[1].Id)
        };
        insert resList;
        
        RestGetAnswersCount.AnswerWeightWrapper aww = new RestGetAnswersCount.AnswerWeightWrapper();
        aww.templateIdList = templateIdList;
        String res = RestGetAnswersCount.getAnswersCount(aww);
        List<MobileAppUtill.AnswerWeightClass> awcList= (List<MobileAppUtill.AnswerWeightClass>)JSON.deserialize(res, List<MobileAppUtill.AnswerWeightClass>.class);
        System.assertEquals(1, awcList[0].isAnsweredArray.size());
    }
}