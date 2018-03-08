@isTest
public class TestIncidentLocationMAPController {
    
    static testMethod void method1(){

        List<Mobile_Incident_Report_Form__c> mirfList = new List<Mobile_Incident_Report_Form__c>{
            new Mobile_Incident_Report_Form__c(Name = 'test Form',Category__c = '')
        };
        insert mirfList;

        IncidentLocationMAPController tilMapCntrlr = new IncidentLocationMAPController();
        String tilMapRes = tilMapCntrlr.getincidentslist();
        system.assertEquals(tilMapCntrlr.incidents.size(), 1);
    }
}