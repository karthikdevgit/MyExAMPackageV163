@isTest
public class TestDelTemporaryReportBuilder_schedule {
    static testMethod void scheduleMethod1() {

        DateTime createdDateTime = DateTime.newInstance(2007, 1, 1);

        Report_Builder_Configuration__c rbc = new Report_Builder_Configuration__c(Is_Temporary__c = true);
        insert rbc;

        Test.setCreatedDate(rbc.Id, createdDateTime);

        List<Report_Builder_Configuration__c> rbcList = new List<Report_Builder_Configuration__c>([SELECT ID, Is_Temporary__c, CreatedDate FROM Report_Builder_Configuration__c WHERE Is_Temporary__c = true AND CreatedDate != TODAY]);
        system.assertEquals(rbcList[0].CreatedDate, createdDateTime);

        Test.startTest();
            DelTemporaryReportBuilder_schedule  p = new DelTemporaryReportBuilder_schedule();
            String sch = '0 0 0 * * ?';
            system.schedule('testx123', sch, p);
            p.notifyUser('Error');
        Test.stopTest();
    }
}