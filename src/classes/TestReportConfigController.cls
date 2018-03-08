@isTest
private class TestReportConfigController {
    static testMethod void method1() {
        Section_Group__c sG = new Section_Group__c();
        sG.Group_Name__c = 'TEST';
        insert sG;
        
    ReportConfigController reportConfigObject = new ReportConfigController();
        reportConfigObject.getAssignItems();
        List<SelectOption> opt = reportConfigObject.getSectionItems();
      System.assertEquals(1, opt.size());
    }
}