@isTest
private class TestAssignmentManagerGeneratorController {

    @isTest static void AMgenerator1() {
        Account acc = new Account();
        acc.Name = 'Test';
        insert acc;
        Account acc2 = new Account();
        acc2.Name = 'Account Label1';
        insert acc2;
        
        Viewer_Custom_Configuration__c viewerRec = new Viewer_Custom_Configuration__c();
        insert viewerRec;
        
        Main_questionaire__c assTemp = new Main_questionaire__c();
        assTemp.Viewer_Configuration__c = viewerRec.Id;
        assTemp.Template_name__c = 'testTemplate';
        insert assTemp;
        
        Section_Template__c secTemp = new Section_Template__c();
        secTemp.Questionnaire_Section__c = assTemp.Id;
        insert secTemp;
        
        Question_Template__c quesTemp = new Question_Template__c();
        quesTemp.Section_Question__c = secTemp.Id;
        insert quesTemp;
        
        Assessment_Group__c assGrpIns = new Assessment_Group__c();
        assGrpIns.Name = 'Account one';
        assGrpIns.Type__c = 'Account';
        insert assGrpIns;
        
        Assessment_Group_Junction__c assGrpJun = new Assessment_Group_Junction__c();
        assGrpJun.Facility_Name__c = acc.Id;
        assGrpJun.Assessment_Group__c = assGrpIns.Id;
        
        insert assGrpJun;
        
        test.startTest();
        
            AssignmentManagerGeneratorController amg = new AssignmentManagerGeneratorController();
            String getAssGrp = AssignmentManagerGeneratorController.getAssessmentGroups('Account');
            String saveAssManList = AssignmentManagerGeneratorController.saveAssignmentmanagerList('ExAM__Facility_Name__c', 'ExAM__Facility_Name__c', assGrpIns.Id, assTemp.Id, '', 'Account', 'Account Label','');
            String saveAssManList2 = AssignmentManagerGeneratorController.saveAssignmentmanagerList('ExAM__Facility_Name__c', 'ExAM__Facility_Name__c', '', assTemp.Id, '2', 'Account', 'Account Label','');
            String saveAssManList3 = AssignmentManagerGeneratorController.saveAssignmentmanagerList('ExAM__Facility_Name__c', 'ExAM__Facility_Name__c', '', assTemp.Id, '2', 'Account', 'Account Label',acc2.Id);

            AssignmentManagerGeneratorController.AssessableRecordClass recordClass;            
            List<AssignmentManagerGeneratorController.AssessableRecordClass> recordClassList;            

            String accStr1 = AssignmentManagerGeneratorController.queryAssessableRecords('Test','Account');
            Contact con = new Contact(LastName = 'Contact1');
            insert con;

            recordClass = new AssignmentManagerGeneratorController.AssessableRecordClass();
            recordClass.RecordName = con.LastName;
            recordClass.RecordId = con.Id;
            recordClassList = new List<AssignmentManagerGeneratorController.AssessableRecordClass>();
            recordClassList.add( recordClass );
            String conStr1 = AssignmentManagerGeneratorController.queryAssessableRecords('Contact1','Contact');
            system.assertEquals(conStr1, Json.serialize(recordClassList));

            Case case1 = new Case();
            insert case1;     
            List<Case> caseQuery = [SELECT Id, CaseNumber FROM Case WHERE Id =:case1.Id];   

            recordClass = new AssignmentManagerGeneratorController.AssessableRecordClass();
            recordClass.RecordName = caseQuery[0].CaseNumber;
            recordClass.RecordId = caseQuery[0].Id;
            recordClassList = new List<AssignmentManagerGeneratorController.AssessableRecordClass>();
            recordClassList.add( recordClass );
            String caseStr1 = AssignmentManagerGeneratorController.queryAssessableRecords(''+caseQuery[0].CaseNumber,'Case');
            system.assertEquals(caseStr1, Json.serialize(recordClassList));
            
            Lead lead1 = new Lead(LastName = 'lead1', Company = 'company1');
            insert lead1;        

            recordClass = new AssignmentManagerGeneratorController.AssessableRecordClass();
            recordClass.RecordName = lead1.LastName;
            recordClass.RecordId = lead1.Id;
            recordClassList = new List<AssignmentManagerGeneratorController.AssessableRecordClass>();
            recordClassList.add( recordClass );

            String leadStr1 = AssignmentManagerGeneratorController.queryAssessableRecords('lead1','Lead');
            system.assertEquals(leadStr1, Json.serialize(recordClassList));
        test.stopTest();
    }
    
    @isTest static void AMgenerator2() {
        
        test.startTest();
            AssignmentManagerGeneratorController amg = new AssignmentManagerGeneratorController();
        test.stopTest();
        system.assertEquals(amg.assessmentTemplateJSON, '[]');
    }
}