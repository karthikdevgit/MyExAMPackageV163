@isTest 

private class TestReportBuilderHeaderFooterController {

    static testMethod void testMethod1() {
    
        ExAM_Configuration__c exmConfig = new ExAM_Configuration__c();
            exmConfig.Name = 'Configuration';
            exmConfig.Report_Builder_Page_Header__c ='<table><tr rowspan="1"><td  style="height: 100px; text-align: center; width: 800px; background-color: rgb(204, 255, 255);"><img id="r1sp1" border="0" src="https://examdev-dev-ed.my.salesforce.com/servlet/servlet.ImageServer?id=01536000001UuP1&amp;oid=00D36000000jMi5"></img></td></tr></table>';
            exmConfig.Report_Builder_Page_Footer__c ='<table><tr rowspan="1"><td  style="height: 100px; text-align: center; width: 800px; background-color: rgb(204, 255, 255);"><img id="r1sp1" border="0" src="https://examdev-dev-ed.my.salesforce.com/servlet/servlet.ImageServer?id=01536000001UuP1&amp;oid=00D36000000jMi5"></img></td></tr></table>';
        insert exmConfig;
        
        Test.startTest();
            ReportBuilderHeaderFooterController report = new ReportBuilderHeaderFooterController();
            ReportBuilderHeaderFooterController.saveReportHeaderAndFooter('Test','Test');
        Test.stopTest();
        
        ExAM_Configuration__c examConfig = [SELECT Id,Name,Report_Builder_Page_Header__c,Report_Builder_Page_Footer__c FROM ExAM_Configuration__c LIMIT 1];
        System.assert(examConfig.Report_Builder_Page_Header__c=='Test');
    }
}