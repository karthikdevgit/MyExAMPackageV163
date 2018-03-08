public with sharing class ReportConfigController
{    
    public List<String> AssignmentManagerFields {get;set;}
    public List<ExAM__Section_Group__c> SectionList {get;set;}
    public Map<String,String> AssignFieldMapping {get;set;}
    
    public ReportConfigController(){    
        RetrieveAssignmentManagerFields();    
        RetrieveSectionItems();
    }
    
    public void RetrieveAssignmentManagerFields(){
        try{
            
            List<String> lsAssignmentFields = new List<String>();
            String objectName = 'ExAM__IssueRequest_Life_Cycle__c'; 
            String query = 'SELECT';
            Map<String, Schema.SObjectField> objectFields = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();
            System.Debug(objectFields);
            AssignFieldMapping = new Map<String,String>();
            for(String fieldName : objectFields.keySet()){
                Schema.SObjectField currentField = objectFields.get(fieldName);
                String fieldLabel = currentField.getDescribe().getLabel();
                AssignFieldMapping.put(fieldLabel, fieldName);
                lsAssignmentFields.add(fieldLabel);
            }        
            AssignmentManagerFields = lsAssignmentFields;
        } catch(Exception e){
            ApexPages.addMessage( new Apexpages.Message(ApexPages.Severity.ERROR, e.getMessage()) );
        }
    }
    
    public void RetrieveSectionItems(){
        try{
            SFDCAccessController accessForSG = ExAMUtilClass.AccessController;
            List<String> fieldsListSG = new List<String>{'ExAM__Group_Name__c'};
            accessForSG.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Section_Group__c'), fieldsListSG);
            List<ExAM__Section_Group__c> lsSections = new List<ExAM__Section_Group__c>();
            lsSections = [SELECT Id, ExAM__Group_Name__c FROM ExAM__Section_Group__c LIMIT 1000];        
            SectionList = lsSections;
        } catch(Exception e){
            ApexPages.addMessage( new Apexpages.Message(ApexPages.Severity.ERROR, e.getMessage()) );
        }
    }
    
    public List<SelectOption> getAssignItems() {
        List<SelectOption> options = new List<SelectOption>();
        for(String so :  this.AssignFieldMapping.keySet()){
            options.add(new SelectOption(this.AssignFieldMapping.get(so),so));
        }
        return options;
    }
    
    public List<SelectOption> getSectionItems(){
        List<SelectOption> options = new List<SelectOption>();    
        for(ExAM__Section_Group__c ex : this.SectionList){
              options.add(new SelectOption( ex.Id,ex.Exam__Group_Name__c));          
        }        
        return options;
    }
}