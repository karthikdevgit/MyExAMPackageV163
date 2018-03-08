@isTest
public class TestAssessableRecordDetailController {
    
      static testMethod void method1() {
    
        Account acc = new Account();
        acc.Name = 'Test';
        insert acc;
        
        contact con = new contact();
        con.AccountId=acc.id;
        con.LastName ='testCon';
        insert con;
        
        List<Main_questionaire__c> assTempList = new List<Main_questionaire__c>{
            new Main_questionaire__c(Account__c = acc.Id,ContactOrganization__c = con.Id,Template_name__c='Test1')
        };
        insert assTempList;
        System.assertEquals(assTempList.size(),1);
        
        List<Section_Template__c> secTempList = new List<Section_Template__c>{
            new Section_Template__c(Questionnaire_Section__c = assTempList[0].Id),
            new Section_Template__c(Questionnaire_Section__c = assTempList[0].Id)
        };
        insert secTempList;
        System.assertEquals(secTempList.size(),2);
        
        List<Question_Template__c> quesTemplList = new List<Question_Template__c>{
            new Question_Template__c(Section_Question__c = secTempList[0].Id),
            new Question_Template__c(Section_Question__c = secTempList[0].Id),
            new Question_Template__c(Section_Question__c = secTempList[1].Id),
            new Question_Template__c(Section_Question__c = secTempList[1].Id)
        };
        insert quesTemplList;
        System.assertEquals(quesTemplList.size(),4);
        
        List<IssueRequest_Life_Cycle__c> assManagerList = new List<IssueRequest_Life_Cycle__c>{
            new IssueRequest_Life_Cycle__c(InvestigationType__c= assTempList[0].Id,Scheduled_Start_Date__c = Date.today(),ExAM__Facility_Name__c = acc.Id)
        };
        insert assManagerList;
        System.assertEquals(assManagerList.size(),1);
        
        List<Questionnaire_Response__c> quesTemp = new List<Questionnaire_Response__c>{
            new Questionnaire_Response__c(Question_Template__c = quesTemplList[0].Id,Issue_Request__c = assManagerList[0].Id),
            new Questionnaire_Response__c(Question_Template__c = quesTemplList[0].Id,Issue_Request__c = assManagerList[0].Id),
            new Questionnaire_Response__c(Question_Template__c = quesTemplList[1].Id,Issue_Request__c = assManagerList[0].Id),
            new Questionnaire_Response__c(Question_Template__c = quesTemplList[1].Id,Issue_Request__c = assManagerList[0].Id)
        };
        insert quesTemp; 
        System.assertEquals(quesTemp.size(),4);
        
        ApexPages.currentPage().getParameters().put('amid',assManagerList[0].Id);
        
        test.startTest();
            AssessableRecordDetailController exAssTemp = new AssessableRecordDetailController();
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
            new Main_questionaire__c(Account__c = acc.Id,ContactOrganization__c = con.Id,Template_name__c='Test1')
        };
        insert assTempList;
        System.assertEquals(assTempList.size(),1);
        
        List<Section_Template__c> secTempList = new List<Section_Template__c>{
            new Section_Template__c(Questionnaire_Section__c = assTempList[0].Id),
            new Section_Template__c(Questionnaire_Section__c = assTempList[0].Id)
        };
        insert secTempList;
        System.assertEquals(secTempList.size(),2);
        
        List<Question_Template__c> quesTemplList = new List<Question_Template__c>{
            new Question_Template__c(Section_Question__c = secTempList[0].Id),
            new Question_Template__c(Section_Question__c = secTempList[0].Id),
            new Question_Template__c(Section_Question__c = secTempList[1].Id),
            new Question_Template__c(Section_Question__c = secTempList[1].Id)
        };
        insert quesTemplList;
        System.assertEquals(quesTemplList.size(),4);
       // IssueRequest_Life_Cycle__c i = new IssueRequest_Life_Cycle__c();
     //   i.
        List<ExAM__IssueRequest_Life_Cycle__c> assManagerList = new List<ExAM__IssueRequest_Life_Cycle__c>{
            new ExAM__IssueRequest_Life_Cycle__c(ExAM__InvestigationType__c= assTempList[0].Id,Scheduled_Start_Date__c = Date.today(),
                                         ExAM__Site_Contact__c = con.Id,ExAM__Facility_Name__c = acc.Id
                                          )
        };
        insert assManagerList;
        System.assertEquals(assManagerList.size(),1);
        
        List<Questionnaire_Response__c> quesTemp = new List<Questionnaire_Response__c>{
            new Questionnaire_Response__c(Question_Template__c = quesTemplList[0].Id,Issue_Request__c = assManagerList[0].Id),
            new Questionnaire_Response__c(Question_Template__c = quesTemplList[0].Id,Issue_Request__c = assManagerList[0].Id),
            new Questionnaire_Response__c(Question_Template__c = quesTemplList[1].Id,Issue_Request__c = assManagerList[0].Id),
            new Questionnaire_Response__c(Question_Template__c = quesTemplList[1].Id,Issue_Request__c = assManagerList[0].Id)
        };
        insert quesTemp; 
        System.assertEquals(quesTemp.size(),4);
        
        ApexPages.currentPage().getParameters().put('amid',assManagerList[0].Id);
        
        test.startTest();
            AssessableRecordDetailController exAssTemp = new AssessableRecordDetailController();
        test.stopTest();
    }

}