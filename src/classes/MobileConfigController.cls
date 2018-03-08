public with sharing class MobileConfigController {

    public string assTempJSON {get;set;}
    public string selectedStatuses {get; set;}
    public Integer syncLastXDaysCont { get; set; }
    public Integer syncFutureXDaysCont { get; set; }
    public string configuration { get; set; }
    public string mobileAssessableObjectMap { get; set; }
    //public string mobileAppImageSizeString { get; set; }
    
    public class templateClass {
        public string templateId;
        public string templateName;
        public string templateLabel;
        public Boolean isSelected;
    }
    public MobileConfigController() {
        try{
            assTempJSON = '';
            selectedStatuses = '';
            List<templateClass> assTempList = new List<templateClass>(); 
            ExAM_Configuration__c examConfig = new ExAM_Configuration__c();
            syncLastXDaysCont = null;
            syncFutureXDaysCont = null;
            
            SFDCAccessController accessForobj = ExAMUtilClass.AccessController;
            List<String> fieldsList = new List<String>{'ExAM__Mobile_Sync_Additional_Templates__c','ExAM__Mobile_Sync_Assignment_Manager_Statuses__c','ExAM__Mobile_Sync_Last_X_Days__c','ExAM__Mobile_Sync_Future_X_Days__c','ExAM__Mobile_Sync_Future_X_Days__c', 'ExAM__Turn_Off_Save_Submit__c', 'ExAM__Decision_Tree_Sync__c' , 'ExAM__Mobile_App_Image_Size__c'};
            accessForobj.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__ExAM_Configuration__c'), fieldsList);
               
                List<ExAM_Configuration__c> examConfigList = [SELECT Id,Mobile_Assessable_Object__c ,Mobile_Sync_Additional_Templates__c, Mobile_Sync_Assignment_Manager_Statuses__c,
                                                                      Mobile_Sync_Last_X_Days__c, Mobile_Sync_Future_X_Days__c, Turn_Off_Save_Submit__c, Decision_Tree_Sync__c, Name, 
                                                                      Mobile_App_Image_Size__c, Feedback_Template__c, Feedback_Template__r.Name, Feedback_Template__r.Template_name__c,
                                                                      ExAM__Mobile_Default_Assesable_Object__c
                                                                FROM ExAM_Configuration__c 
                                                                WHERE Name = 'Configuration' Limit 1];
                if(examConfigList != null && examConfigList.size() > 0) {
                    examConfig = examConfigList[0];
                    if (examConfigList[0].Mobile_Sync_Assignment_Manager_Statuses__c != null 
                        && examConfigList[0].Mobile_Sync_Assignment_Manager_Statuses__c != '') {
                        
                        List<String> statusTemp = examConfigList[0].Mobile_Sync_Assignment_Manager_Statuses__c.split('~');
                        selectedStatuses = JSON.Serialize(statusTemp);
                    }
                    if (examConfigList[0].Mobile_Sync_Last_X_Days__c != null) {
                        syncLastXDaysCont = Integer.valueOf(examConfigList[0].Mobile_Sync_Last_X_Days__c);
                    }
                    if (examConfigList[0].Mobile_Sync_Last_X_Days__c != null) {
                        syncFutureXDaysCont = Integer.valueOf(examConfigList[0].Mobile_Sync_Future_X_Days__c);
                    }
                    //if (examConfigList[0].Turn_Off_Save_Submit__c != null) {
                    //    turnOffSaveSubmit = examConfigList[0].Turn_Off_Save_Submit__c;
                    //}
                    Map<string, string> fieldsMap = new Map<string, string>();
                    fieldsMap = MobileAppUtill.getReferenceFieldMapInAM();
        
                    mobileAssessableObjectMap = JSON.serialize(fieldsMap);
                    
                    configuration = JSON.serialize(examConfigList[0]);
                    //if(Mobile_App_Image_Size__c){
                    
                   //}
                }
                
                
                Set<String> selectedIdSet = new set<String>();
                if (examConfig != null && examConfig.Mobile_Sync_Additional_Templates__c != null && examConfig.Mobile_Sync_Additional_Templates__c != '') {
                    List<String> selectedTemplates = examConfig.Mobile_Sync_Additional_Templates__c.split('~');
                    selectedIdSet.addAll(selectedTemplates);
                }
                
                SFDCAccessController accessForobj1 = ExAMUtilClass.AccessController;
                List<String> fieldsList1 = new List<String>{'ExAM__Template_name__c'};
                accessForobj1.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Main_questionaire__c'), fieldsList1);
                for (Main_questionaire__c assTemp : [SELECT ID,Name,Template_name__c FROM Main_questionaire__c ORDER BY CreatedDate DESC LIMIT 1000]) {
                    templateClass template = new templateClass ();
                    template.templateId = assTemp.Id;
                    template.templateName = assTemp.Name;
                    template.templateLabel = assTemp.Template_name__c; 
                    template.isSelected = false;                 
                    if (selectedIdSet != null && selectedIdSet.size() > 0 && selectedIdSet.contains(assTemp.Id)) {
                        template.isSelected = true;
                    }
                    assTempList.add(template);
                }
                 
                assTempJSON = JSON.serialize(assTempList);
            
            }catch(Exception e){
             ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
         } 
      /*  List<String> tempmobileAppImageSize = new List<String>();
       
        Schema.DescribeFieldResult fieldResult = ExAM__ExAM_Configuration__c.ExAM__Mobile_App_Image_Size__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        //statusList.add('--None--');
        for( Schema.PicklistEntry f : ple) {
            tempmobileAppImageSize.add(f.getValue());
        }
        mobileAppImageSizeString = JSON.serialize(tempmobileAppImageSize); */
    }
    @RemoteAction
    public static List<String> getOverallStatusList() {
        
        List<String> statusList = new List<String>();
        
        Schema.DescribeFieldResult fieldResult = ExAM__IssueRequest_Life_Cycle__c.ExAM__Status__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        statusList.add('--None--');
        for( Schema.PicklistEntry f : ple) {
            statusList.add(f.getValue());
        }       
        System.debug(':::::statusList::::'+statusList);  
        return statusList;        
    }
    
    @RemoteAction
    public static String queryAllAssessmentTemplates() {
    
        List<Main_questionaire__c> questionaireList = new  List<Main_questionaire__c>();
        questionaireList = [SELECT Id, Name, Template_Name__c FROM Main_questionaire__c ORDER BY CreatedDate DESC LIMIT 10000];
        
        return JSON.serialize(questionaireList);        
    }
    
    @RemoteAction
    public static String saveMobileConfig(ExAM_Configuration__c saveExamConfig, String syncLastXDays, String syncFutureXDays) {

        try{

            SFDCAccessController accessForobj = ExAMUtilClass.AccessController;
            List<String> fieldsList = new List<String>{'ExAM__Mobile_Sync_Additional_Templates__c','ExAM__Mobile_Sync_Assignment_Manager_Statuses__c','ExAM__Mobile_Sync_Last_X_Days__c','ExAM__Mobile_Sync_Future_X_Days__c'};
            accessForobj.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__ExAM_Configuration__c'), fieldsList);
            //ExAM_Configuration__c saveExamConfig = new ExAM_Configuration__c ();

            List<ExAM_Configuration__c> examConfigList = [
                SELECT Id, Mobile_Sync_Additional_Templates__c, Mobile_Sync_Assignment_Manager_Statuses__c,
                       Mobile_Sync_Last_X_Days__c,Mobile_Sync_Future_X_Days__c, Name
                FROM   ExAM_Configuration__c 
                WHERE  Name = 'Configuration' LIMIT 1
            ];
            if(examConfigList != null && examConfigList.size() > 0) {
                saveExamConfig.Id = examConfigList[0].Id;
            } else {
                saveExamConfig.Name = 'Configuration';
            }

            //saveExamConfig.Mobile_Sync_Additional_Templates__c = mobAddTemps;
            //saveExamConfig.Mobile_Sync_Assignment_Manager_Statuses__c = mobAssignmentStatuses;
            //saveExamConfig.Turn_Off_Save_Submit__c = turnOffSaveSubmitMobile;

            List<String> fieldsList1 = new List<String>{'ExAM__Mobile_Sync_Last_X_Days__c','ExAM__Mobile_Sync_Future_X_Days__c'};
            accessForobj.assertAuthorizedToCreate(Schema.getGlobalDescribe().get('exam__ExAM_Configuration__c'), fieldsList1);
            accessForobj.assertAuthorizedToUpdate(Schema.getGlobalDescribe().get('exam__ExAM_Configuration__c'), fieldsList1);

            if (syncLastXDays != null && syncLastXDays != '') {
                saveExamConfig.Mobile_Sync_Last_X_Days__c = Integer.valueOf(syncLastXDays);
            }
            else {
                saveExamConfig.Mobile_Sync_Last_X_Days__c = null;
            }
            if (syncFutureXDays != null && syncFutureXDays != '') {
                saveExamConfig.Mobile_Sync_Future_X_Days__c = Integer.valueOf(syncFutureXDays);
            }
            else {
                saveExamConfig.Mobile_Sync_Future_X_Days__c = null;
            }
            upsert saveExamConfig;
            return 'success';
        }
        catch(Exception e){
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
            return e.getMessage();
        } 
    }
    /**
        Method which returns custom lookup field created using Metadata API in Assignment Manager object
    **/
    /*public static Map<string, string> getReferenceFieldMapInAM() {

        Map<string, string> fieldsMap = new Map<string, string>{'Facility_Name__c' => 'Account'};

        Map<string, Schema.SObjectField> amFieldsMap = ExAM__IssueRequest_Life_Cycle__c.sObjectType.getDescribe().fields.getMap();
        for (Schema.SObjectField eachfield : amFieldsMap.Values()) {

            Schema.DescribeFieldResult dfr = eachfield.getDescribe();
            if (dfr.isCustom() && (dfr.getType() == Schema.DisplayType.REFERENCE) && dfr.getName().startsWithIgnoreCase('AM_')) {
                fieldsMap.put(dfr.getName(), dfr.getReferenceTo().get(0).getDescribe().getName());
            }
        }
        return fieldsMap;
    }*/

}