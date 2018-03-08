@isTest
public class TestAssignmentGroupController {

    static testMethod void method1() {
    
        Account acc = new Account();
        acc.Name = 'Test';
        insert acc;
        
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
        
        IssueRequest_Life_Cycle__c assManager = new IssueRequest_Life_Cycle__c();
        assManager.investigationType__c = assTemp.Id;
        assManager.Facility_Name__c = acc.Id;
        assManager.Show_Configuration_Options_in_Viewer__c = True;
        insert assManager;
        
        Assessment_Group__c assGrpIns = new Assessment_Group__c();
        assGrpIns.Type__c = 'Account';
        assGrpIns.Name = 'ass group';
        insert assGrpIns;
        
        Assessment_Group_Junction__c assGrpJun = new Assessment_Group_Junction__c();
        assGrpJun.Facility_Name__c = acc.Id;
        assGrpJun.Assessment_Group__c = assGrpIns.Id;
        
        insert assGrpJun;
        
        Id assGrpJuncId = assGrpJun.Id;
        Map<String,String> objNameAndFieldNameMap = new Map<String,String>();
        objNameAndFieldNameMap.put('Account','Facility_Name__c');
        //String testObj = objNameAndFieldNameMap;
        
        ApexPages.currentPage().getParameters().put('idsVal','assGrpJuncId');
        ApexPages.currentPage().getParameters().put('totelRec','1');
        ApexPages.currentPage().getParameters().put('selectedObjectAPIName','Account');
        
        AssignmentGroupController  assGrp = new AssignmentGroupController();
        
        assGrp.selectedObj = 'Account';
        assGrp.assGroup.Name = 'Account one';
        assGrp.selectedRecords = 1;
        assGrp.totalRecords =1;
        assGrp.selectedGroup = 'Account One';
       
        assGrp.insertAssignmentManager();
        assGrp.saveSelectedRecords();
        assGrp.processSelected();
        assGrp.saveAssessmentGroup();
        assGrp.refreshFn();
        assGrp.changeObject();
    
        String recRes =  AssignmentGroupController.getRecords('Account one','all','Account','Account=ExAM__Facility_Name__c');
        AssignmentGroupController.getCreatedRecords('Account', 'Account one', 'Account=ExAM__Facility_Name__c');
        AssignmentGroupController.deleteAssessmentJunctionRecord(assGrpJuncId);

        List<Assessment_Group_Junction__c> deletedAGJList = new List<Assessment_Group_Junction__c>([SELECT Id FROM Assessment_Group_Junction__c WHERE Id = :assGrpJuncId LIMIT 1]);
        if (deletedAGJList.size() == 0) {
            system.assertEquals(deletedAGJList.size(), 0, 'Record was not deleted');
        }

        AssignmentGroupController.innerCls innerIns = new AssignmentGroupController.innerCls(acc);        
    }
    
    static testMethod void method2() {
        Account acc = new Account();
        acc.Name = 'Test';
        insert acc;
        
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
        
        IssueRequest_Life_Cycle__c assManager = new IssueRequest_Life_Cycle__c();
        assManager.investigationType__c = assTemp.Id;
        assManager.Facility_Name__c = acc.Id;
        assManager.Show_Configuration_Options_in_Viewer__c = True;
        insert assManager;
        
        Assessment_Group__c assGrpIns = new Assessment_Group__c();
        assGrpIns.Name = 'Account one';
        assGrpIns.Type__c = 'Account';
        insert assGrpIns;
        
        Assessment_Group_Junction__c assGrpJun = new Assessment_Group_Junction__c();
        assGrpJun.Facility_Name__c = acc.Id;
        assGrpJun.Assessment_Group__c = assGrpIns.Id;
        
        insert assGrpJun;
        
        Id assGrpJuncId = assGrpJun.Id;
        Map<String,String> objNameAndFieldNameMap = new Map<String,String>();
        objNameAndFieldNameMap.put('Account','Facility_Name__c');
        //String testObj = '+objNameAndFieldNameMap+';
        
        ApexPages.currentPage().getParameters().put('idsVal', acc.Id);
        ApexPages.currentPage().getParameters().put('totelRec','1');
        
        AssignmentGroupController  assGrp = new AssignmentGroupController();
        
        assGrp.selectedObj = 'Account';
        assGrp.assGroup.Name = 'Account one';
        assGrp.selectedRecords = 1;
        assGrp.totalRecords =1;
        assGrp.selectedGroup = assGrpIns.Id;
        assGrp.selectedGroupId2 = assGrpIns.Id;
        
        assGrp.insertAssignmentManager();
        assGrp.processSelected();
        assGrp.saveSelectedRecords();

        List<ApexPages.Message> msgList = ApexPages.getMessages();
        if (msgList.size() > 0) {
            system.assertEquals(msgList[0].getSeverity(), ApexPages.Severity.CONFIRM);
            system.assertEquals(msgList[0].getDetail(), 'Record saved successfully');
        }

        List<Assessment_Group_Junction__c> insertedAGJList = new List<Assessment_Group_Junction__c>([SELECT ExAM__Assessment_Group__c, ExAM__Assessment_Group__r.ExAM__Type__c, ExAM__Facility_Name__c, ExAM__Facility_Name__r.Name, Id, Name FROM Assessment_Group_Junction__c LIMIT 1]); 
        if (insertedAGJList != null && insertedAGJList.size() > 0) {
            system.assertEquals(insertedAGJList[0].ExAM__Assessment_Group__r.ExAM__Type__c, 'Account');
            system.assertEquals(insertedAGJList[0].ExAM__Facility_Name__c, acc.Id);
            system.assertEquals(insertedAGJList[0].ExAM__Facility_Name__r.Name, 'Test');
        }

        assGrp.saveAssessmentGroup();
        assGrp.refreshFn();
        assGrp.changeObject();
    
        String recRes =  AssignmentGroupController.getRecords('Account one','all','Account','Account=ExAM__Facility_Name__c');
        AssignmentGroupController.getCreatedRecords('Account', 'Account one', 'Account=ExAM__Facility_Name__c');
        AssignmentGroupController.deleteAssessmentJunctionRecord(assGrpJuncId);
        
        AssignmentGroupController.innerCls innerIns = new AssignmentGroupController.innerCls(acc);
        
    }
    
    static testMethod void method3() {
    
        Account acc = new Account();
        acc.Name = 'Test';
        insert acc;
        
        Assessment_Group__c assGrpIns = new Assessment_Group__c();
        assGrpIns.Name = 'Account one';
        assGrpIns.Type__c = 'Account';
        insert assGrpIns;
        
        Assessment_Group_Junction__c assGrpJun = new Assessment_Group_Junction__c();
        assGrpJun.Facility_Name__c = acc.Id;
        assGrpJun.Assessment_Group__c = assGrpIns.Id;
        insert assGrpJun;
        
        AssignmentGroupController.getRecords('Account','all',assGrpIns.Id,'Account=ExAM__Facility_Name__c');
        AssignmentGroupController.getRecords('Case','Case',assGrpIns.Id,'Account=ExAM__Facility_Name__c');
        AssignmentGroupController.getRecords('Account','Case',assGrpIns.Id,'Account=ExAM__Facility_Name__c');
        AssignmentGroupController.getRecords('Case','#',assGrpIns.Id,'Account=ExAM__Facility_Name__c');
        AssignmentGroupController.getRecords('Account','#',assGrpIns.Id,'Account=ExAM__Facility_Name__c');
        AssignmentGroupController.getRecords('User','User',assGrpIns.Id,'Account=ExAM__Facility_Name__c');
        
        AssignmentGroupController.getCreatedRecords('Account', assGrpIns.Id, 'Account=ExAM__Facility_Name__c');
        
        String blobCsv = '\r\n'+acc.Id+'\r\n';
        blob b = Blob.valueOf(blobCsv);
    
        blobCsv = EncodingUtil.base64Encode(b);
        ApexPages.currentPage().getParameters().put('attBlob',blobCsv);
        AssignmentGroupController assignmentGroup = new AssignmentGroupController();
        assignmentGroup.saveRecordwithUploadAssessment();
        
        
        Account acc1 = new Account(Name = 'Test 1');
        insert acc1;
        Account acc2 = new Account(Name = 'Test 12');
        insert acc2;
        blobCsv = '\r\n'+acc1.Id+'\r\n'+'\r\n'+acc.Id+'\r\n'+'\r\n'+acc2.Id+'\r\n';
        b = Blob.valueOf(blobCsv);
    
        blobCsv = EncodingUtil.base64Encode(b);
        ApexPages.currentPage().getParameters().put('attBlob',blobCsv);
        assignmentGroup = new AssignmentGroupController();
        assignmentGroup.saveRecordwithUploadAssessment();
        
        blobCsv = 'Id,Name\r\n'+acc1.Id+',Test1\r\n'+'\r\n'+acc.Id+',Test 2\r\n'+'\r\n'+acc2.Id+',Test 12\r';
        b = Blob.valueOf(blobCsv);
    
        blobCsv = EncodingUtil.base64Encode(b);
        ApexPages.currentPage().getParameters().put('attBlob',blobCsv);
        assignmentGroup = new AssignmentGroupController();
        assignmentGroup.saveRecordwithUploadAssessment();

        List<ApexPages.Message> msgList = ApexPages.getMessages();
        if (msgList.size() > 0) {
            system.assertEquals(msgList[0].getSeverity(), ApexPages.Severity.ERROR);
            system.assertEquals(msgList[0].getDetail(), 'File does not have data. Please upload a file with data or confirm if it is a valid csv file.');
        }
    }
}