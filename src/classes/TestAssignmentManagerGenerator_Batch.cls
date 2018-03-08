@isTest 
private class TestAssignmentManagerGenerator_Batch {
    @testSetup
    public static void testSetUp() {
    
        Account acc = new Account();
        acc.Name = 'Test';
        insert acc;
        
        Viewer_Custom_Configuration__c viewerRec = new Viewer_Custom_Configuration__c();
        insert viewerRec;
        
        List<Main_questionaire__c> assTemp = new List<Main_questionaire__c> {
            new Main_questionaire__c(Viewer_Configuration__c =viewerRec.Id,Template_name__c= 'testTemplate1'),
            new Main_questionaire__c(Viewer_Configuration__c =viewerRec.Id,Template_name__c= 'testTemplate2'),
            new Main_questionaire__c(Viewer_Configuration__c =viewerRec.Id,Template_name__c= 'testTemplate3')
        };
        insert assTemp;
        
        List<Section_Template__c> secTemp = new List<Section_Template__c> {
            new Section_Template__c(Questionnaire_Section__c = assTemp[0].Id),
            new Section_Template__c(Questionnaire_Section__c = assTemp[1].Id),
            new Section_Template__c(Questionnaire_Section__c = assTemp[2].Id)
        };
        insert secTemp;
        
        List<Question_Template__c> quesTemp = new List<Question_Template__c> {
            new Question_Template__c(Section_Question__c = secTemp[0].Id)
        };
        insert quesTemp;
        
        Assessment_Group__c assGrpIns = new Assessment_Group__c();
        assGrpIns.Name = 'Account one';
        assGrpIns.Type__c = 'Account';
        insert assGrpIns;
        
        Assessment_Group_Junction__c assGrpJun = new Assessment_Group_Junction__c();
        assGrpJun.Facility_Name__c = acc.Id;
        assGrpJun.Assessment_Group__c = assGrpIns.Id;
        insert assGrpJun;
        
    }
            
    public static testMethod void testAmGeneratorWithAcc() {
    
        List<Main_questionaire__c> assTemp = [SELECT Id FROM Main_questionaire__c];
        List<IssueRequest_Life_Cycle__c> amList = new List<IssueRequest_Life_Cycle__c> {
            new IssueRequest_Life_Cycle__c(InvestigationType__c = assTemp[1].Id),
            new IssueRequest_Life_Cycle__c(InvestigationType__c = assTemp[1].Id),
            new IssueRequest_Life_Cycle__c(InvestigationType__c = assTemp[1].Id),
            new IssueRequest_Life_Cycle__c(InvestigationType__c = assTemp[1].Id),
            new IssueRequest_Life_Cycle__c(InvestigationType__c = assTemp[1].Id)
        };
        System.debug('::::::amList.size():::::::::'+amList.size());
        
        Test.StartTest();
            AssignmentManagerGenerator_Batch AmGeneratorBatch = new AssignmentManagerGenerator_Batch();
            AmGeneratorBatch.assignmentManagerList = amList;
            AmGeneratorBatch.totalNoOfRecords = 15;
            AmGeneratorBatch.assessbleObjAPI = 'Account';
            AmGeneratorBatch.selectedobjectLabel = 'Account';
            AmGeneratorBatch.AMApi = 'Facility_Name__c';
            Database.executeBatch(AmGeneratorBatch,2000);
        Test.StopTest(); 
        
        List<IssueRequest_Life_Cycle__c> assManagerList = new List<IssueRequest_Life_Cycle__c>();
        assManagerList = [SELECT Id FROM IssueRequest_Life_Cycle__c WHERE InvestigationType__c = :assTemp[1].Id];
        System.assertEquals(5, assManagerList.size());
    }
    
    public static testMethod void testAmGeneratorWithLead() {
    
       List<Main_questionaire__c> assTemp = [SELECT Id FROM Main_questionaire__c];
       List<IssueRequest_Life_Cycle__c> amList = new List<IssueRequest_Life_Cycle__c> {
            new IssueRequest_Life_Cycle__c(InvestigationType__c = assTemp[1].Id),
            new IssueRequest_Life_Cycle__c(InvestigationType__c = assTemp[1].Id),
            new IssueRequest_Life_Cycle__c(InvestigationType__c = assTemp[1].Id),
            new IssueRequest_Life_Cycle__c(InvestigationType__c = assTemp[1].Id),
            new IssueRequest_Life_Cycle__c(InvestigationType__c = assTemp[1].Id)
        };
        
        Test.StartTest();
            AssignmentManagerGenerator_Batch AmGeneratorBatch = new AssignmentManagerGenerator_Batch();
            AmGeneratorBatch.assignmentManagerList = amList;
            AmGeneratorBatch.totalNoOfRecords = 15;
            AmGeneratorBatch.assessbleObjAPI = 'Lead';
            AmGeneratorBatch.selectedobjectLabel = 'Lead';
            AmGeneratorBatch.AMApi ='Facility_Name__c';
            Database.executeBatch(AmGeneratorBatch,2000);
        Test.StopTest();
        
        List<IssueRequest_Life_Cycle__c> assManagerList = new List<IssueRequest_Life_Cycle__c>();
        assManagerList = [SELECT Id FROM IssueRequest_Life_Cycle__c WHERE InvestigationType__c = :assTemp[1].Id];
        System.assertEquals(0, assManagerList.size()); 
    }
    
    public static testMethod void testAmGeneratorWithCon() {
    
        List<Main_questionaire__c> assTemp = [SELECT Id FROM Main_questionaire__c];
        List<IssueRequest_Life_Cycle__c> amList = new List<IssueRequest_Life_Cycle__c> {
            new IssueRequest_Life_Cycle__c(InvestigationType__c = assTemp[0].Id),
            new IssueRequest_Life_Cycle__c(InvestigationType__c = assTemp[0].Id),
            new IssueRequest_Life_Cycle__c(InvestigationType__c = assTemp[0].Id),
            new IssueRequest_Life_Cycle__c(InvestigationType__c = assTemp[0].Id),
            new IssueRequest_Life_Cycle__c(InvestigationType__c = assTemp[0].Id)
        };
        
        Test.StartTest();
            AssignmentManagerGenerator_Batch AmGeneratorBatch = new AssignmentManagerGenerator_Batch();
            AmGeneratorBatch.assignmentManagerList = amList;
            AmGeneratorBatch.totalNoOfRecords = 5;
            AmGeneratorBatch.assessbleObjAPI = 'Contact';
            AmGeneratorBatch.selectedobjectLabel = 'Contact';
            AmGeneratorBatch.AMApi ='Facility_Name__c';
            Database.executeBatch(AmGeneratorBatch,5);
        Test.StopTest(); 
        
        List<IssueRequest_Life_Cycle__c> assManagerList = new List<IssueRequest_Life_Cycle__c>();
        assManagerList = [SELECT Id FROM IssueRequest_Life_Cycle__c WHERE InvestigationType__c = :assTemp[0].Id];
        System.assertEquals(0, assManagerList.size()); 
    }
    
    static testMethod void testAmGeneratorWithoutObj() {
    
        List<Account> accList = [SELECT Id FROM Account];
        List<Main_questionaire__c> assTemp = [SELECT Id FROM Main_questionaire__c];
        List<IssueRequest_Life_Cycle__c> amList = new List<IssueRequest_Life_Cycle__c> {
            new IssueRequest_Life_Cycle__c(InvestigationType__c = assTemp[0].Id,Facility_Name__c = accList[0].Id),
            new IssueRequest_Life_Cycle__c(InvestigationType__c = assTemp[0].Id,Facility_Name__c = accList[0].Id),
            new IssueRequest_Life_Cycle__c(InvestigationType__c = assTemp[0].Id,Facility_Name__c = accList[0].Id),
            new IssueRequest_Life_Cycle__c(InvestigationType__c = assTemp[0].Id,Facility_Name__c = accList[0].Id),
            new IssueRequest_Life_Cycle__c(InvestigationType__c = assTemp[0].Id,Facility_Name__c = accList[0].Id)
        };
        
        Test.StartTest();
            AssignmentManagerGenerator_Batch AmGeneratorBatch = new AssignmentManagerGenerator_Batch();
            AmGeneratorBatch.assignmentManagerList = amList ;
            AmGeneratorBatch.totalNoOfRecords = 5;
            AmGeneratorBatch.assessbleObjAPI = '';
            AmGeneratorBatch.AMApi = 'Facility_Name__c';
            Database.executeBatch(AmGeneratorBatch,5);
        Test.StopTest();
        
        List<IssueRequest_Life_Cycle__c> assManagerList = new List<IssueRequest_Life_Cycle__c>();
        assManagerList = [SELECT Id FROM IssueRequest_Life_Cycle__c WHERE InvestigationType__c = :assTemp[0].Id];
        System.assertEquals(5, assManagerList.size()); 
    }
}