@isTest 
public class TestReportBuilderConfigController {

    static testMethod void method1() {
    
        Account acc = new Account();
        acc.Name = 'Test';
        insert acc;
        
        contact con = new contact();
        con.AccountId=acc.id;
        con.LastName ='testCon';
        insert con;
        
        Main_questionaire__c assTemp = new Main_questionaire__c();
        assTemp.Account__c = acc.Id;
        assTemp.ContactOrganization__c = con.Id;
        insert assTemp;
        
        IssueRequest_Life_Cycle__c assManager = new IssueRequest_Life_Cycle__c();
        assManager.investigationType__c = assTemp.Id;
        assManager.Facility_Name__c = acc.Id;
        assManager.Show_Configuration_Options_in_Viewer__c = True;
        insert assManager;
        
        List<Report_Builder_Configuration__c> reportList = new List<Report_Builder_Configuration__c>{
            new Report_Builder_Configuration__c(Name = 'TestReport',Output_Format__c = 'PDF',Start_Date_Range__c = String.valueOf(Date.today()-5),End_Date_Range__c = String.valueof(Date.today()-2),
            Choosed_Assignment_manager__c = assManager.Id,Assignment_Manager_position__c = 'Test',Selected_Sections__c = 'test',Assessment_Template__c = assTemp.Id)};
        insert reportList;
        
        Test.startTest();
            ReportBuilderConfigController report = new ReportBuilderConfigController();
            ReportBuilderConfigController.queryAssignmentManagers('test','Test','2016/1/12','2016/2/12');
            ReportBuilderConfigController.querySectionTemplate(assTemp.Id);
            ReportBuilderConfigController.saveReportBuilderConfig(String.valueOf(reportList[0].Id),assTemp.Id,reportList[0].Name,'2016/1/12','2016/2/12','PDF',assManager.Id,'Test','All', false,'{"Comments":true,"Pictures":true}','','In Progress, Open, Completed');
            ReportBuilderConfigController.queryAssignmentManager(assManager.Id);
        Test.stopTest();
        
        List<Report_Builder_Configuration__c> reportBuildList = [SELECT Id,Name,Selected_Sections__c,Assignment_Manager_position__c FROM Report_Builder_Configuration__c LIMIT 1];
        System.assertEquals(reportBuildList[0].Selected_Sections__c,'All');
    }
}