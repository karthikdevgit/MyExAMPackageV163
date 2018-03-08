@isTest
public class TestAssessmentWeightMgmtController {
    static testMethod void method1(){
        Main_questionaire__c[] assTempList = new Main_questionaire__c[]{
            new Main_questionaire__c(Template_Name__c= 'test temp')
        };
            insert assTempList;
        Section_Template__c[] secList = new Section_Template__c[]{
            new Section_Template__c(Questionnaire_Section__c = assTempList[0].Id,Section_label__c = 'test sec')
        };
            insert secList;
        Question_Template__c[] quesList = new Question_Template__c[]{
            new Question_Template__c(Section_Question__c = secList[0].Id,Question_Label__c='test ques',
                                    Question_Type__c='RadioPicklist',Weight_of_Answer__c='10~20'),
                new Question_Template__c(Section_Question__c = secList[0].Id,Question_Label__c='test ques1',
                                    Question_Type__c='RadioPicklist',Weight_of_Answer__c='20~20')
        };
            insert quesList;
        Answer_Option__c[] ansOptList = new Answer_Option__c[]{
            new Answer_Option__c(Name='test opt',Question_Template__c=quesList[0].Id,Order_No__c=1,
                                Weight__c=50),
                new Answer_Option__c(Name='test opt1',Question_Template__c=quesList[0].Id,Order_No__c=2,
                                Weight__c=50),
                new Answer_Option__c(Name='test opt1',Question_Template__c=quesList[1].Id,Order_No__c=1,
                                Weight__c=50),
                new Answer_Option__c(Name='test opt2',Question_Template__c=quesList[1].Id,Order_No__c=2,
                                Weight__c=50)
                
        };
            insert ansOptList;
        ApexPages.StandardController sc = new ApexPages.StandardController(assTempList[0]);
        AssessmentWeightMgmtController testAss = new AssessmentWeightMgmtController(sc);
        testAss.templateid = assTempList[0].Id;
        testAss.sectionid = secList[0].Id;
        testAss.wtTemplate = 'test';
        testAss.sectionScore = 'test';
        testAss.templateName = 'test';
        testAss.setwtTemplate();
        testAss.setquestionList();
        testAss.cancel();
        testAss.exit();
        testAss.savequestions();
        testAss.savesections();
        testAss.questionsLists[0].Weight_Of_Answer__c = '10~10';
        testAss.savequestions();
    }
}