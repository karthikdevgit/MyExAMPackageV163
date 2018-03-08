@isTest
public class TestExportAMController {

    static testMethod void method1(){
    
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
        
        List<Section_Template__c> secTempList = new List<Section_Template__c>{
            new Section_Template__c(Questionnaire_Section__c = assTempList[0].Id),
            new Section_Template__c(Questionnaire_Section__c = assTempList[0].Id),
            new Section_Template__c(Questionnaire_Section__c = assTempList[1].Id),
            new Section_Template__c(Questionnaire_Section__c = assTempList[1].Id)
        };
        insert secTempList;
        
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
        
        List<IssueRequest_Life_Cycle__c> assManagerList = new List<IssueRequest_Life_Cycle__c>{
            new IssueRequest_Life_Cycle__c(InvestigationType__c= assTempList[0].Id,Scheduled_Start_Date__c = Date.today()),
            new IssueRequest_Life_Cycle__c(InvestigationType__c= assTempList[1].Id,Scheduled_Start_Date__c = Date.today())
        };
        insert assManagerList;
        
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
        
        ApexPages.currentPage().getParameters().put('ATId',assTempList[0].Id);
        ApexPages.currentPage().getParameters().put('ATType','Test');
        ApexPages.currentPage().getParameters().put('ATStart',String.valueOf(Date.today()));
        ApexPages.currentPage().getParameters().put('ATEnd',String.valueOf(Date.today()));
        ApexPages.currentPage().getParameters().put('AMCreatedStart',String.valueOf(Date.today()));
        ApexPages.currentPage().getParameters().put('AMCreatedEnd',String.valueOf(Date.today()));
        
        test.startTest();
            ExportAMController exAm = new ExportAMController();
            system.assertNotEquals( exAm.assessmentTemplateJSON, '' );
        test.stopTest();
    } 
    static testMethod void method2(){
    
        Account acc = new Account();
        acc.Name = 'Test';
        insert acc;
        
        contact con = new contact();
        con.AccountId=acc.id;
        con.LastName ='testCon';
        insert con;
        
        List<Main_questionaire__c> assTempList = new List<Main_questionaire__c>{
            new Main_questionaire__c(Account__c = acc.Id,ContactOrganization__c = con.Id),
            new Main_questionaire__c(Account__c = acc.Id,ContactOrganization__c = con.Id)
        };
        insert assTempList;
        
        List<Section_Template__c> secTempList = new List<Section_Template__c>{
            new Section_Template__c(Questionnaire_Section__c = assTempList[0].Id),
            new Section_Template__c(Questionnaire_Section__c = assTempList[0].Id),
            new Section_Template__c(Questionnaire_Section__c = assTempList[1].Id),
            new Section_Template__c(Questionnaire_Section__c = assTempList[1].Id)
        };
        insert secTempList;
        
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
        
        List<IssueRequest_Life_Cycle__c> assManagerList = new List<IssueRequest_Life_Cycle__c>{
            new IssueRequest_Life_Cycle__c(InvestigationType__c= assTempList[0].Id,Scheduled_Start_Date__c = Date.today()),
            new IssueRequest_Life_Cycle__c(InvestigationType__c= assTempList[1].Id,Scheduled_Start_Date__c = Date.today())
        };
        insert assManagerList;
        
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
        
        ApexPages.currentPage().getParameters().put('ATId','');
        ApexPages.currentPage().getParameters().put('ATType','Test');
        ApexPages.currentPage().getParameters().put('ATStart','2016/2/2');
        ApexPages.currentPage().getParameters().put('ATEnd','2016/2/2');
        ApexPages.currentPage().getParameters().put('AMCreatedStart','2016/2/2');
        ApexPages.currentPage().getParameters().put('AMCreatedEnd','2016/2/2');
        
        test.startTest();
            ExportAMController exAm = new ExportAMController();
            system.assertNotEquals( exAm.assessmentTemplateJSON, 'test' );
        test.stopTest();
    } 
}