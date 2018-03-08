@isTest

private class TestRestGetAssignmentManagersNew {

    static testMethod void method1() {
        Viewer_Custom_Configuration__c vcc = new Viewer_Custom_Configuration__c(Answer_Options__c = true, Data_Management__c = true);
        insert vcc;
        List<Main_questionaire__c> tempList = new List<Main_questionaire__c> {
                new Main_questionaire__c (Template_name__c = 'Unit Template',Viewer_Configuration__c = vcc.Id),
                new Main_questionaire__c (Template_name__c = 'Site Template',Viewer_Configuration__c = vcc.Id),
                new Main_questionaire__c (Template_name__c = 'Common Template',Viewer_Configuration__c = vcc.Id),
                new Main_questionaire__c (Template_name__c = 'System Template',Viewer_Configuration__c = vcc.Id),
                new Main_questionaire__c (Template_name__c = 'Exterior Template',Viewer_Configuration__c = vcc.Id)
        };
        insert tempList;
        
        ExAM_Configuration__c ec = new ExAM_Configuration__c();
        ec.Primary_Assessment_Type_Template__c = tempList[0].Id;
        ec.Related_Assessment_Type_1_Template__c = tempList[1].Id;
        ec.Related_Assessment_Type_2_Template__c = tempList[2].Id;
        ec.Related_Assessment_Type_3_Template__c = tempList[3].Id;
        ec.Related_Assessment_Type_4_Template__c = tempList[4].Id;
        ec.Mobile_Sync_Additional_Templates__c = tempList[0].Id+'~'+tempList[1].Id;
        ec.Mobile_Sync_Assignment_Manager_Statuses__c = 'Open~Completed';
        ec.Mobile_Sync_Last_X_Days__c = 160;
        ec.Mobile_Sync_Future_X_Days__c = 170;
        insert ec;
        
        List<Main_questionaire__c>  assTemp = [Select Id FROM Main_questionaire__c WHERE Viewer_Configuration__c = :vcc.Id];
        system.assertEquals(assTemp.size(),5);
        
        List<Id> tempIdList = new List<Id>();
        for(Main_questionaire__c temp : assTemp) {
            tempIdList.add(temp.Id);
        }
        RestGetAssignmentManagersNew.getAssignmentManagersNew(tempIdList);
        ExAM_Configuration__c ec1 = new ExAM_Configuration__c();
        ec1.Primary_Assessment_Type_Template__c = tempList[0].Id;
        ec1.Related_Assessment_Type_1_Template__c = tempList[1].Id;
        ec1.Related_Assessment_Type_2_Template__c = tempList[2].Id;
        ec1.Related_Assessment_Type_3_Template__c = tempList[3].Id;
        ec1.Related_Assessment_Type_4_Template__c = tempList[4].Id;
        ec1.Mobile_Sync_Additional_Templates__c = tempList[0].Id+'~'+tempList[1].Id;
        ec1.Mobile_Sync_Assignment_Manager_Statuses__c = 'Open~Completed';
        ec1.Mobile_Sync_Last_X_Days__c = 160;
        //ec.Mobile_Sync_Future_X_Days__c = 170;
        insert ec1;
        RestGetAssignmentManagersNew.getAssignmentManagersNew(tempIdList);
        
        ExAM_Configuration__c ec2 = new ExAM_Configuration__c();
        ec2.Primary_Assessment_Type_Template__c = tempList[0].Id;
        ec2.Related_Assessment_Type_1_Template__c = tempList[1].Id;
        ec2.Related_Assessment_Type_2_Template__c = tempList[2].Id;
        ec2.Related_Assessment_Type_3_Template__c = tempList[3].Id;
        ec2.Related_Assessment_Type_4_Template__c = tempList[4].Id;
        ec2.Mobile_Sync_Additional_Templates__c = tempList[0].Id+'~'+tempList[1].Id;
        ec2.Mobile_Sync_Assignment_Manager_Statuses__c = 'Open~Completed';
        //ec2.Mobile_Sync_Last_X_Days__c = 160;
        ec2.Mobile_Sync_Future_X_Days__c = 170;
        insert ec2;
        RestGetAssignmentManagersNew.getAssignmentManagersNew(tempIdList);
    }
}