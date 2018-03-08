public with sharing class AssignmentManagerListController {

    public string assMngrPrefix{get; set;}

    public AssignmentManagerListController() {
        Schema.DescribeSObjectResult d = ExAM__IssueRequest_Life_Cycle__c.sObjectType.getDescribe();
        assMngrPrefix = d.getkeyPrefix(); 
    }

    @RemoteAction
    public static string queryAllASMRecords() {

        try {

            List<IssueRequest_Life_Cycle__c> assignmentManagerList = new List<IssueRequest_Life_Cycle__c>();

            SFDCAccessController accessEC = ExAMUtilClass.AccessController;
            List<string> fieldsListAC = new List<string>{'ExAM__Assignment_Manager_List_Status_Filter__c'};
            accessEC.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__ExAM_Configuration__c'), fieldsListAC);

            SFDCAccessController accessAM = ExAMUtilClass.AccessController;
            List<string> fieldsListAM = new List<string>{'ExAM__Assessor_Resource__c', 'ExAM__Assessment_Template_Type__c', 'ExAM__Priority__c', 'ExAM__Status__c'};
            accessAM.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__IssueRequest_Life_Cycle__c'), fieldsListAM);

            List<ExAM_Configuration__c> configList = new List<ExAM_Configuration__c>();
            configList = [SELECT Assignment_Manager_List_Status_Filter__c, Id FROM ExAM_Configuration__c WHERE Assignment_Manager_List_Status_Filter__c != NULL ORDER BY CreatedDate DESC LIMIT 1];

            if(configList != null && configList.size() > 0) {

                assignmentManagerList = [
                    SELECT Id, Name, Status__c, Assessment_Template_Type__c, Assessor_Resource__c, Assessor_Resource__r.Name, Priority__c, CreatedDate  
                    FROM   IssueRequest_Life_Cycle__c
                    WHERE  Status__c = :configList[0].Assignment_Manager_List_Status_Filter__c AND Assessor_Resource__c = :UserInfo.getUserId()
                    ORDER BY CreatedDate, Assessor_Resource__c DESC LIMIT 100
                ];
            
            } else {

                assignmentManagerList = [
                    SELECT Id, Name, Status__c, Assessment_Template_Type__c, Assessor_Resource__c, Assessor_Resource__r.Name, Priority__c, CreatedDate  
                    FROM   IssueRequest_Life_Cycle__c
                    WHERE  Assessor_Resource__c = :UserInfo.getUserId()
                    ORDER BY CreatedDate, Assessor_Resource__c DESC LIMIT 100
                ];

            }
            return JSON.serialize(assignmentManagerList);
        } catch (Exception ex) {
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()) );
        } 
        return null;
    }
}