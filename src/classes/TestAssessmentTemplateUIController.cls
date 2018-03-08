@isTest
public class TestAssessmentTemplateUIController {
    static TestMethod void method1(){
        Main_questionaire__c[] templateList = new Main_questionaire__c[]{
            new Main_questionaire__c(Template_name__c = 'test template',
                                    PublishPlace__c = 'Internal to salesforce'
                                    )
        };
        insert templateList;
        Section_Template__c[] secList = new Section_Template__c[]{
            new Section_Template__c(Questionnaire_Section__c = templateList[0].Id)
        };
        insert secList;
        Question_Template__c[] qt = new Question_Template__c[]{
            new Question_Template__c(Question_Order_No__c = 1,Question_Label__c = 'test question',
                                    Question_Type__c = 'Text',Subquestion_Label__c = 'tst sub question',
                                    Weight_Of_Question__c = 100,Section_Question__c = secList[0].Id                                   )
        };
        insert qt;
        Section_Group__c sg =  new Section_Group__c();
        sg.Group_Name__c = 'test sg name';
        insert sg;
        
        ApexPages.currentPage().getParameters().put('templateid',templateList[0].Id);
        
        AssessmentTemplateUIController atuic = new AssessmentTemplateUIController();
        
        Account[] newAccount = new Account[] {
            new Account(name='XYZ Organization',Create_Survey__c = FALSE,
                        Main_Questionnaire_Template__c = NULL
                       )
                };
        insert newAccount;
        atuic.selectedAccountId=newAccount[0].id;
        atuic.AccountList = new List<SelectOption>{
            new SelectOption(templateList[0].Id, templateList[0].Id)
        };

        atuic.save();
        List<Account> acctList = new List<Account>([SELECT Id, Name FROM Account LIMIT 1]);
        if ( acctList != null && acctList.size() > 0 ) {
            system.assertEquals(acctList[0].Name, 'XYZ Organization');
        }

        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(newAccount);
        new AssessmentTemplateUIController(sc);
        atuic.getsecgrouplist();
        atuic.gettemplatesList();
        atuic.cloneTemp();
        atuic.EditSurvey();
        atuic.save();
        atuic.cancel();
        atuic.saveMulti();
        atuic.selectedAccountId = NULL;
        atuic.AccName = 'test acc';
    }
}