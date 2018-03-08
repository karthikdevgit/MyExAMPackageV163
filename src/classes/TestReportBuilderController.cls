@isTest
public class TestReportBuilderController {

    static testMethod void method1() {
        
        Account acc = new Account();
        acc.Name = 'Test';
        insert acc;
        
        contact con = new contact();
        con.AccountId=acc.id;
        con.FirstName = 'testcon';
        con.LastName ='testCon';
        insert con;
        
        Main_questionaire__c assTemp = new Main_questionaire__c();
        assTemp.Account__c = acc.Id;
        assTemp.ContactOrganization__c = con.Id;
        insert assTemp;
        
        IssueRequest_Life_Cycle__c assManager = new IssueRequest_Life_Cycle__c();
        assManager.investigationType__c = assTemp.Id;
        assManager.Facility_Name__c = acc.Id;
        assManager.scheduled_start_date__c = Date.today()-5;
        assManager.Show_Configuration_Options_in_Viewer__c = True;
        insert assManager;
        
        List<Report_Builder_Configuration__c> reportList = new List<Report_Builder_Configuration__c>{
            new Report_Builder_Configuration__c(Name = 'TestReport',Output_Format__c = 'PDF',Start_Date_Range__c = String.valueOf(Date.today()-3),End_Date_Range__c = String.valueOf(Date.today()-2),
            Choosed_Assignment_manager__c = assManager.Id,
            Assignment_Manager_position__c = '[{"position":1,"labelName":"Account Name","apiName":"ExAM__Facility_Name__c"},{"position":2,"labelName":"Account Classification","apiName":"ExAM__Location__c"},{"position":3,"labelName":"Account Name","apiName":"ExAM__Facility_Name__c"},{"position":4,"labelName":"Actual End Time","apiName":"ExAM__Field_End_Time__c"},{"position":5,"labelName":"Actual Start Time","apiName":"ExAM__Field_Start_Time__c"},{"apiName":"","labelName":"[  Blank Space  ]","position":6},{"position":7,"labelName":"Assessment Classification","apiName":"ExAM__Services_Required__c"},{"position":8,"labelName":"Assessment Date/Time","apiName":"ExAM__Assessment_Date_Time__c"},{"position":9,"labelName":"Assessment Event","apiName":"ExAM__Assessment_Event__c"},{"position":10,"labelName":"Assessment Form Completion","apiName":"ExAM__Assessment_Form_Completion__c"},{"apiName":"","labelName":"[  Blank Space  ]","position":11},{"position":12,"labelName":"Assessment Group","apiName":"ExAM__Assessment_Group__c"},{"position":13,"labelName":"Assessment Template ID","apiName":"ExAM__InvestigationType__c"},{"position":14,"labelName":"Assessment Template Type","apiName":"ExAM__Assessment_Template_Type__c"},{"position":15,"labelName":"Assigned Resource","apiName":"ExAM__Assessor_Resource__c"}]',
            Selected_Sections__c = '{"All":true}',Assessment_Template__c = assTemp.Id)};
        insert reportList;
        
        ExAM_Configuration__c exmConfig = new ExAM_Configuration__c();
            exmConfig.Name = 'Configuration';
            exmConfig.Report_Builder_Page_Header__c ='<table><tr rowspan="1"><td  style="height: 100px; text-align: center; width: 800px; background-color: rgb(204, 255, 255);"><img id="r1sp1" border="0" src="https://examdev-dev-ed.my.salesforce.com/servlet/servlet.ImageServer?id=01536000001UuP1&amp;oid=00D36000000jMi5"></img></td></tr></table>';
            exmConfig.Report_Builder_Page_Footer__c ='<table><tr rowspan="1"><td  style="height: 100px; text-align: center; width: 800px; background-color: rgb(204, 255, 255);"><img id="r1sp1" border="0" src="https://examdev-dev-ed.my.salesforce.com/servlet/servlet.ImageServer?id=01536000001UuP1&amp;oid=00D36000000jMi5"></img></td></tr></table>';
        insert exmConfig;
        
        apexPages.currentPage().getParameters().put('reportbuilderid',reportList[0].Id);
        
        Test.startTest();
            ReportBuilderController report = new ReportBuilderController();
            report.ReportBuilderControllerAction();
            report.headerAction();
            report.pageRedirectMethod();
        Test.stopTest();

        List<ExAM_Configuration__c> exmConfigList = new List<ExAM_Configuration__c>([SELECT Id, Name, Report_Builder_Page_Header__c FROM ExAM_Configuration__c WHERE Name = 'Configuration' LIMIT 1]);
        system.assertEquals(report.head, exmConfigList[0].Report_Builder_Page_Header__c);
    } 
    
    static testMethod void method2() {
        
        Account acc = new Account();
        acc.Name = 'Test';
        insert acc;
        
        contact con = new contact();
        con.AccountId=acc.id;
        con.FirstName = 'testcon';
        con.LastName ='testCon';
        insert con;
                
        Main_questionaire__c assTemp = new Main_questionaire__c();
        assTemp.Account__c = acc.Id;
        assTemp.ContactOrganization__c = con.Id;
        insert assTemp;
        
        List<Section_Template__c> secTempList = new List<Section_Template__c>{
            new Section_Template__c(Questionnaire_Section__c = assTemp.Id)
        };
        insert secTempList;
        
        List<Question_Template__c> quesTemplList = new List<Question_Template__c>{
            new Question_Template__c(Section_Question__c = secTempList[0].Id)
            
        };
        insert quesTemplList;
        
        IssueRequest_Life_Cycle__c assManager = new IssueRequest_Life_Cycle__c();
        assManager.investigationType__c = assTemp.Id;
        assManager.Facility_Name__c = acc.Id;
        assManager.scheduled_start_date__c = Date.today()-5;
        assManager.Show_Configuration_Options_in_Viewer__c = True;
        insert assManager;
        
        
        List<Questionnaire_Response__c> quesResTemp = new List<Questionnaire_Response__c>{
            new Questionnaire_Response__c(Question_Template__c = quesTemplList[0].Id,Issue_Request__c = assManager.Id)
        };
        insert quesResTemp; 
        
        List<Report_Builder_Configuration__c> reportList = new List<Report_Builder_Configuration__c>{
            new Report_Builder_Configuration__c(Name = 'TestReport',Output_Format__c = 'PDF',Start_Date_Range__c = String.valueOf(Date.today()-3),End_Date_Range__c = String.valueOf(Date.today()-2),
            Choosed_Assignment_manager__c = assManager.Id,
            Assignment_Manager_position__c = '[{"position":1,"labelName":"Account Name","apiName":"ExAM__Facility_Name__c"},{"position":2,"labelName":"Account Classification","apiName":"ExAM__Location__c"},{"position":3,"labelName":"Account Name","apiName":"ExAM__Facility_Name__c"},{"position":4,"labelName":"Actual End Time","apiName":"ExAM__Field_End_Time__c"},{"position":5,"labelName":"Actual Start Time","apiName":"ExAM__Field_Start_Time__c"},{"apiName":"","labelName":"[  Blank Space  ]","position":6},{"position":7,"labelName":"Assessment Classification","apiName":"ExAM__Services_Required__c"},{"position":8,"labelName":"Assessment Date/Time","apiName":"ExAM__Assessment_Date_Time__c"},{"position":9,"labelName":"Assessment Event","apiName":"ExAM__Assessment_Event__c"},{"position":10,"labelName":"Assessment Form Completion","apiName":"ExAM__Assessment_Form_Completion__c"},{"apiName":"","labelName":"[  Blank Space  ]","position":11},{"position":12,"labelName":"Assessment Group","apiName":"ExAM__Assessment_Group__c"},{"position":13,"labelName":"Assessment Template ID","apiName":"ExAM__InvestigationType__c"},{"position":14,"labelName":"Assessment Template Type","apiName":"ExAM__Assessment_Template_Type__c"},{"position":15,"labelName":"Assigned Resource","apiName":"ExAM__Assessor_Resource__c"}]',
            Selected_Sections__c = '{"secTempList[0].id":true}',Assessment_Template__c = assTemp.Id)};
        insert reportList;
        
        ExAM_Configuration__c exmConfig = new ExAM_Configuration__c();
            exmConfig.Name = 'Configuration';
            exmConfig.Report_Builder_Page_Header__c ='<table><tr rowspan="1"><td  style="height: 100px; text-align: center; width: 800px; background-color: rgb(204, 255, 255);"><img id="r1sp1" border="0" src="https://examdev-dev-ed.my.salesforce.com/servlet/servlet.ImageServer?id=01536000001UuP1&amp;oid=00D36000000jMi5"></img></td></tr></table>';
            exmConfig.Report_Builder_Page_Footer__c ='<table><tr rowspan="1"><td  style="height: 100px; text-align: center; width: 800px; background-color: rgb(204, 255, 255);"><img id="r1sp1" border="0" src="https://examdev-dev-ed.my.salesforce.com/servlet/servlet.ImageServer?id=01536000001UuP1&amp;oid=00D36000000jMi5"></img></td></tr></table>';
        insert exmConfig;
        
        apexPages.currentPage().getParameters().put('reportbuilderid',reportList[0].Id);
        
        Test.startTest();
            ReportBuilderController report = new ReportBuilderController();
            report.ReportBuilderControllerAction();
            report.headerAction();
            report.pageRedirectMethod();
        Test.stopTest();

        List<ExAM_Configuration__c> exmConfigList = new List<ExAM_Configuration__c>([SELECT Id, Name, Report_Builder_Page_Header__c, Report_Builder_Page_Footer__c FROM ExAM_Configuration__c WHERE Name = 'Configuration' LIMIT 1]);
        system.assertEquals(report.head, exmConfigList[0].Report_Builder_Page_Header__c);
        system.assertEquals(report.headerStr, exmConfigList[0].Report_Builder_Page_Header__c);
        system.assertEquals(report.footerStr, exmConfigList[0].Report_Builder_Page_Footer__c);
    } 
}