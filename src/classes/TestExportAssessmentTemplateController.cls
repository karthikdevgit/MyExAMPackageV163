@isTest

public class TestExportAssessmentTemplateController {

    static testMethod void method1() {
    
        Account acc = new Account();
        acc.Name = 'Test';
        insert acc;
        
        contact con = new contact();
        con.AccountId=acc.id;
        con.LastName ='testCon';
        insert con;
        
        List<Main_questionaire__c> assTempList = new List<Main_questionaire__c>{
            new Main_questionaire__c(Account__c = acc.Id,ContactOrganization__c = con.Id,Template_name__c='Test1'),
            new Main_questionaire__c(Account__c = acc.Id,ContactOrganization__c = con.Id,Template_name__c='test2')
        };
        insert assTempList;
        System.assertEquals(assTempList.size(),2);
        
        List<Section_Template__c> secTempList = new List<Section_Template__c>{
            new Section_Template__c(Questionnaire_Section__c = assTempList[0].Id),
            new Section_Template__c(Questionnaire_Section__c = assTempList[0].Id),
            new Section_Template__c(Questionnaire_Section__c = assTempList[1].Id),
            new Section_Template__c(Questionnaire_Section__c = assTempList[1].Id)
        };
        insert secTempList;
        System.assertEquals(secTempList.size(),4);
        
        List<Question_Template__c> quesTemplList = new List<Question_Template__c>{
            new Question_Template__c(Section_Question__c = secTempList[0].Id),
            new Question_Template__c(Section_Question__c = secTempList[0].Id),
            new Question_Template__c(Section_Question__c = secTempList[1].Id),
            new Question_Template__c(Section_Question__c = secTempList[1].Id),
            new Question_Template__c(Section_Question__c = secTempList[2].Id),
            new Question_Template__c(Section_Question__c = secTempList[2].Id),
            new Question_Template__c(Section_Question__c = secTempList[3].Id),
            new Question_Template__c(Section_Question__c = secTempList[3].Id)
        };
        insert quesTemplList;
        System.assertEquals(quesTemplList.size(),8);
        
        List<IssueRequest_Life_Cycle__c> assManagerList = new List<IssueRequest_Life_Cycle__c>{
            new IssueRequest_Life_Cycle__c(InvestigationType__c= assTempList[0].Id,Scheduled_Start_Date__c = Date.today()),
            new IssueRequest_Life_Cycle__c(InvestigationType__c= assTempList[1].Id,Scheduled_Start_Date__c = Date.today())
        };
        insert assManagerList;
        System.assertEquals(assManagerList.size(),2);
        
        List<Questionnaire_Response__c> quesTemp = new List<Questionnaire_Response__c>{
            new Questionnaire_Response__c(Question_Template__c = quesTemplList[0].Id,Issue_Request__c = assManagerList[0].Id),
            new Questionnaire_Response__c(Question_Template__c = quesTemplList[0].Id,Issue_Request__c = assManagerList[0].Id),
            new Questionnaire_Response__c(Question_Template__c = quesTemplList[1].Id,Issue_Request__c = assManagerList[0].Id),
            new Questionnaire_Response__c(Question_Template__c = quesTemplList[1].Id,Issue_Request__c = assManagerList[0].Id),
            new Questionnaire_Response__c(Question_Template__c = quesTemplList[2].Id,Issue_Request__c = assManagerList[1].Id),
            new Questionnaire_Response__c(Question_Template__c = quesTemplList[2].Id,Issue_Request__c = assManagerList[1].Id),
            new Questionnaire_Response__c(Question_Template__c = quesTemplList[3].Id,Issue_Request__c = assManagerList[1].Id),
            new Questionnaire_Response__c(Question_Template__c = quesTemplList[3].Id,Issue_Request__c = assManagerList[1].Id)
        };
        insert quesTemp; 
        System.assertEquals(quesTemp.size(),8);
        
        ApexPages.currentPage().getParameters().put('asTempId',assTempList[0].Id);
        ApexPages.currentPage().getParameters().put('startCreatedDate','03/31/2016');
        ApexPages.currentPage().getParameters().put('endCreatedDate','03/31/2016');
        
        test.startTest();
            ExportAssessmentTemplateController exAssTemp = new ExportAssessmentTemplateController();
        test.stopTest();
    }
    
    static testMethod void method2() {
    
        Account acc = new Account();
        acc.Name = 'Test';
        insert acc;
        
        contact con = new contact();
        con.AccountId=acc.id;
        con.LastName ='testCon';
        insert con;
        
        List<Main_questionaire__c> assTempList = new List<Main_questionaire__c>{
            new Main_questionaire__c(Account__c = acc.Id,ContactOrganization__c = con.Id,Template_name__c='Test1'),
            new Main_questionaire__c(Account__c = acc.Id,ContactOrganization__c = con.Id,Template_name__c='test2')
        };
        insert assTempList;
        System.assertEquals(assTempList.size(),2);
        
        List<Section_Template__c> secTempList = new List<Section_Template__c>{
            new Section_Template__c(Questionnaire_Section__c = assTempList[0].Id),
            new Section_Template__c(Questionnaire_Section__c = assTempList[0].Id),
            new Section_Template__c(Questionnaire_Section__c = assTempList[1].Id),
            new Section_Template__c(Questionnaire_Section__c = assTempList[1].Id)
        };
        insert secTempList;
        System.assertEquals(secTempList.size(),4);
        
        List<Question_Template__c> quesTemplList = new List<Question_Template__c>{
            new Question_Template__c(Section_Question__c = secTempList[0].Id),
            new Question_Template__c(Section_Question__c = secTempList[0].Id),
            new Question_Template__c(Section_Question__c = secTempList[1].Id),
            new Question_Template__c(Section_Question__c = secTempList[1].Id),
            new Question_Template__c(Section_Question__c = secTempList[2].Id),
            new Question_Template__c(Section_Question__c = secTempList[2].Id),
            new Question_Template__c(Section_Question__c = secTempList[3].Id),
            new Question_Template__c(Section_Question__c = secTempList[3].Id)
        };
        insert quesTemplList;
        System.assertEquals(quesTemplList.size(),8);
        
        List<IssueRequest_Life_Cycle__c> assManagerList = new List<IssueRequest_Life_Cycle__c>{
            new IssueRequest_Life_Cycle__c(InvestigationType__c= assTempList[0].Id,Scheduled_Start_Date__c = Date.today()),
            new IssueRequest_Life_Cycle__c(InvestigationType__c= assTempList[1].Id,Scheduled_Start_Date__c = Date.today())
        };
        insert assManagerList;
        System.assertEquals(assManagerList.size(),2);
        
        List<Questionnaire_Response__c> quesTemp = new List<Questionnaire_Response__c>{
            new Questionnaire_Response__c(Question_Template__c = quesTemplList[0].Id,Issue_Request__c = assManagerList[0].Id),
            new Questionnaire_Response__c(Question_Template__c = quesTemplList[0].Id,Issue_Request__c = assManagerList[0].Id),
            new Questionnaire_Response__c(Question_Template__c = quesTemplList[1].Id,Issue_Request__c = assManagerList[0].Id),
            new Questionnaire_Response__c(Question_Template__c = quesTemplList[1].Id,Issue_Request__c = assManagerList[0].Id),
            new Questionnaire_Response__c(Question_Template__c = quesTemplList[2].Id,Issue_Request__c = assManagerList[1].Id),
            new Questionnaire_Response__c(Question_Template__c = quesTemplList[2].Id,Issue_Request__c = assManagerList[1].Id),
            new Questionnaire_Response__c(Question_Template__c = quesTemplList[3].Id,Issue_Request__c = assManagerList[1].Id),
            new Questionnaire_Response__c(Question_Template__c = quesTemplList[3].Id,Issue_Request__c = assManagerList[1].Id)
        };
        insert quesTemp; 
        System.assertEquals(quesTemp.size(),8);
 
        
        ApexPages.currentPage().getParameters().put('startCreatedDate','');
        ApexPages.currentPage().getParameters().put('endCreatedDate','');
        
        test.startTest();
            ExportAssessmentTemplateController exAssTemp = new ExportAssessmentTemplateController();
            
            ApexPages.currentPage().getParameters().put('asTempId',assTempList[0].Id);
            ExportAssessmentTemplateController exAssTemp2 = new ExportAssessmentTemplateController();
            
        test.stopTest();
    }
}