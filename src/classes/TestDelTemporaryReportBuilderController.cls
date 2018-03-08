@isTest
public class TestDelTemporaryReportBuilderController {

    static testMethod void delTempReport() {

        DateTime createdDateTime = DateTime.newInstance(2012,12,12);

        List<Report_Builder_Configuration__c> reb = new List<Report_Builder_Configuration__c> {
                                new Report_Builder_Configuration__c(Name = 'Test1', Is_Temporary__c = true)
                                };
        
        insert reb;
        Test.setCreatedDate(reb[0].Id, createdDateTime);

        List<Report_Builder_Configuration__c> rbcList = new List<Report_Builder_Configuration__c>([SELECT ID, Is_Temporary__c, CreatedDate FROM Report_Builder_Configuration__c WHERE Is_Temporary__c = true AND CreatedDate != TODAY]);
        system.assertEquals(rbcList[0].CreatedDate, createdDateTime);

        Test.startTest();
        DelTemporaryReportBuilderController c = new DelTemporaryReportBuilderController();
        
        Database.executeBatch(new DelTemporaryReportBuilderController(), 1);
        Test.stopTest();

    }
}