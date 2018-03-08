public with sharing class WebInterceptConfigurationController {

    public String templateId { get; set; }
    public String templateRecord {get;set;}
    
    public WebInterceptConfigurationController() {
        
        templateId = ApexPages.currentPage().getParameters().get('templateId');
        try{
            if (String.isNotBlank(templateId)) {
                
                SFDCAccessController accessForobj = ExAMUtilClass.AccessController;
                List<String> fieldsList = new List<String>{'ExAM__Web_Intercept_Header__c','ExAM__Web_Intercept_PA_Static_Resource_Name__c','ExAM__Web_Intercept_PA_Resource_File_Path__c','ExAM__Web_Intercept_Static_Resource_Name__c'};
                accessForobj.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Main_questionaire__c'), fieldsList);
    
                List<Main_questionaire__c> templateRecordsList = new List<Main_questionaire__c>();
                templateRecordsList = [
                        SELECT Id, Name,Web_Intercept_Header__c, 
                               Web_Intercept_PA_Static_Resource_Name__c,Web_Intercept_PA_Resource_File_Path__c,
                               Web_Intercept_Static_Resource_Name__c
                        FROM   Main_questionaire__c
                        WHERE  Id = :templateId
                ];
    
                if (templateRecordsList != null && templateRecordsList.size() > 0) {
                    templateRecord = JSON.serializePretty(templateRecordsList[0]);
                }
            }//end templateId string not blank code check
        }catch(Exception ex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
        }
    }//end constructor

    
    @RemoteAction
    public static string saveWIConfig(String templateRec) {
        
        String responseMsg;
        Main_questionaire__c assTemp = new Main_questionaire__c();
        
        if(String.isNotBlank(templateRec)) {
            assTemp = (Main_questionaire__c)JSON.deserialize(templateRec,Main_questionaire__c.Class);
        }
        try {
            SFDCAccessController accessForobj = ExAMUtilClass.AccessController;
            List<String> fieldsList = new List<String>{'ExAM__Web_Intercept_PA_Resource_File_Path__c'};
            accessForobj.assertAuthorizedToUpdate(Schema.getGlobalDescribe().get('exam__Main_questionaire__c'), fieldsList);
            update assTemp;
            responseMsg = 'success';
        } catch(Exception exp) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, exp.getMessage()));
            System.debug(':::exp:::::'+exp.getMessage());
            responseMsg = exp.getMessage();
        }
        return responseMsg;
    }
}