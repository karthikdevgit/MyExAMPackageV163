public with sharing class ViewerConfigurationController {
    
    public String viewerConfigJSON { get; set; }
    
    public ViewerConfigurationController() {

        viewerConfigJSON = '';
        try {

            SFDCAccessController access = ExAMUtilClass.AccessController;
            List<String> fieldsList = new List<String>{'ExAM__Answer_Options__c', 'ExAM__Assignment_Manager__c', 'ExAM__Assignment_Manager_List__c', 'ExAM__Data_Management__c', 'ExAM__Hierarchical_Object__c', 'ExAM__Single_Question_Mode__c'};
            access.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Viewer_Custom_Configuration__c'), fieldsList);

            List<Viewer_Custom_Configuration__c > viewerCustomConfigList = [
                SELECT Answer_Options__c, Assignment_Manager__c, Assignment_Manager_List__c,
                       Data_Management__c, Hierarchical_Object__c, Id, Name, Single_Question_Mode__c
                FROM   Viewer_Custom_Configuration__c ORDER BY Name ASC Limit 1000
            ];
            if (viewerCustomConfigList != null && viewerCustomConfigList.size() > 0) {
                viewerConfigJSON = JSON.serialize(viewerCustomConfigList);
            }
        }
        catch (Exception e) {
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()) );
        }
    }

    @RemoteAction 
    public static String saveCustomConfigurationViewer1(Viewer_Custom_Configuration__c viewerRec) {

        String resultMessage = '';
        try {    
            if (viewerRec.Name != null && viewerRec.Name != '') {

                SFDCAccessController access = ExAMUtilClass.AccessController;
                List<String> fieldsListToCreate = new List<String>{'ExAM__Answer_Options__c', 'ExAM__Assignment_Manager__c', 'ExAM__Assignment_Manager_List__c', 'ExAM__Data_Management__c', 'ExAM__Hierarchical_Object__c', 'ExAM__Single_Question_Mode__c'};
                access.assertAuthorizedToCreate(Schema.getGlobalDescribe().get('exam__Viewer_Custom_Configuration__c'), fieldsListToCreate);

                insert viewerRec;
                resultMessage = 'success';
            } else {
                resultMessage = 'Viewer Name was blank';
            }
        } catch(Exception ex) {
            resultMessage = ex.getMessage();
        }
        return resultMessage;
    } 
}