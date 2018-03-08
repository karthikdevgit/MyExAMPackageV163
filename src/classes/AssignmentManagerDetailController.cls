public with sharing class AssignmentManagerDetailController {

    public ExAM__IssueRequest_Life_Cycle__c assignmenManagerRec { get; set; }
    
    public AssignmentManagerDetailController() {

        assignmenManagerRec = new IssueRequest_Life_Cycle__c();
        String assignmentManagerid = apexPages.currentpage().getParameters().get('amid');    
        
        
        if( assignmentManagerid != null && assignmentManagerid != '') {
            assignmenManagerRec = getAssignmentManager(assignmentManagerid);            
        }
    }
    
    public List<Schema.FieldSetMember> getFields() {
        return SObjectType.ExAM__IssueRequest_Life_Cycle__c.FieldSets.ExAM__Viewer_Field_Set.getFields();
    }
    
    private ExAM__IssueRequest_Life_Cycle__c getAssignmentManager(String amId) {
        ExAM__IssueRequest_Life_Cycle__c am = new IssueRequest_Life_Cycle__c();
        
        if (this.getFields() != null && this.getFields().size() > 0) {
            try {
                String query = 'SELECT ';
                List<String> queryFieldList = new List<String>();
                
                SFDCAccessController accessAM = ExAMUtilClass.AccessController;

                for(Schema.FieldSetMember f : this.getFields()) {
                    queryFieldList.add(f.getFieldPath());
                }
                
                query += String.join(queryFieldList, ', ');
                query += ' FROM ExAM__IssueRequest_Life_Cycle__c WHERE Id =:amId LIMIT 1';

                List<String> fieldsListAM = new List<String>();
                fieldsListAM.addAll( queryFieldList );
                accessAM.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__IssueRequest_Life_Cycle__c'), fieldsListAM);

                List<IssueRequest_Life_Cycle__c> amList = Database.query(query);
                if (amList != null && amList.size() > 0) {
                    return amList[0];
                }
            } catch (Exception e) {
                System.debug('There is error while Fetching Assignment manager using Dynamic SOQL in Field Set. Error Detail - '+e.getMessage()); //This is Utility Method to display error message on VF Page
                ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()) );
            }
        }
        return null;
    }
    
}