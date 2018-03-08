public with sharing class ReportBuilderHeaderFooterController {
    public ExAM_Configuration__c config { get; set; }
    
    public ReportBuilderHeaderFooterController() {
        try{
            SFDCAccessController accessForRB = ExAMUtilClass.AccessController;
            List<String> fieldsListEC = new List<String>{'ExAM__Report_Builder_Page_Header__c','ExAM__Report_Builder_Page_Footer__c'};
            accessForRB.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__ExAM_Configuration__c'), fieldsListEC);
            List<ExAM_Configuration__c> exConfigList = [ SELECT Id, Name, Report_Builder_Page_Header__c, Report_Builder_Page_Footer__c 
                                                           FROM ExAM_Configuration__c 
                                                           WHERE Name = 'Configuration' Limit 1];
            
            config = new ExAM_Configuration__c();
            if (exConfigList != null && exConfigList.size() > 0) {
                config = exConfigList[0];
            }   
        } catch (Exception e){
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()) );
        }    
    }
    
    @RemoteAction
    public static string saveReportHeaderAndFooter(string headerStr, string footerStr) {
        string resultMsg = '';
        try{
            if (headerStr != null && headerStr != '' && footerStr != null && footerStr != '') {
                
                SFDCAccessController accessForRB = ExAMUtilClass.AccessController;
                List<String> fieldsListEC = new List<String>{'ExAM__Report_Builder_Page_Header__c','ExAM__Report_Builder_Page_Footer__c'};
                accessForRB.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__ExAM_Configuration__c'), fieldsListEC);
                ExAM_Configuration__c configSave = new ExAM_Configuration__c ();
                List<ExAM_Configuration__c> exConfigList = [ SELECT Id, Name, Report_Builder_Page_Header__c, Report_Builder_Page_Footer__c 
                                                           FROM ExAM_Configuration__c 
                                                           WHERE Name = 'Configuration' Limit 1];
            
                
                if (exConfigList != null && exConfigList.size() > 0) {
                    configSave.Id = exConfigList[0].Id;
                }
                system.debug(':::::headerStr:::'+headerStr);
                system.debug(':::::footerStr:::'+footerStr);        
                
                configSave.Report_Builder_Page_Header__c = headerStr;
                configSave.Report_Builder_Page_Footer__c = footerStr;
                
                accessForRB.assertAuthorizedToCreate(Schema.getGlobalDescribe().get('exam__ExAM_Configuration__c'), fieldsListEC);
                upsert configSave;
                resultMsg = 'Report Builder Header and Footer saved successfully';
                
            } else {
                resultMsg = 'No changes';
            }
        } catch (Exception e){
            resultMsg = e.getMessage();
        }
        return resultMsg;
    }
    
}