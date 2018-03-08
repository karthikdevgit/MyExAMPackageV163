public with sharing class AssessableRecordDetailController {

    public SObject assessableRec { get; set; }

    public List<Schema.FieldSetMember> fields { get; set; }

    public AssessableRecordDetailController() {

        try {

            assessableRec = Schema.getGlobalDescribe().get('Account').newSObject() ;

            fields = new List<Schema.FieldSetMember> ();
            String assignmentManagerId = apexPages.currentPage().getparameters().get('amid');

            List<ExAMUtilClass.AssessableRecordsClass> AssessableRecords = new List<ExAMUtilClass.AssessableRecordsClass>();

            ExAMUtilClass.AssessableObjectDetails objectDetail = ExAMUtilClass.getAssessableObjectDetails('ExAM__IssueRequest_Life_Cycle__c');
            Map<string, string> fieldsMap = objectDetail.assessableObjectAPIMap;

            SFDCAccessController accessAM = ExAMUtilClass.AccessController;
            List<String> fieldsListAM = new List<String>{'ExAM__Assignment_Manager__c', 'ExAM__InvestigationType__c'};

            if ( assignmentManagerId != null && assignmentManagerId != '') {
                Id assignmentId = Id.valueOf(assignmentManagerId);
                String amQuery = 'SELECT Assignment_Manager__c, Facility_Name__r.Name, Id, InvestigationType__c, InvestigationType__r.Name, Name';
                for (String fldName : fieldsMap.keySet()) {
                    amQuery += ', ' + fldName;
                    fieldsListAM.add( fldName );
                }
                amQuery += ' FROM IssueRequest_Life_Cycle__c WHERE Id = :assignmentManagerId LIMIT 1';

                accessAM.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__IssueRequest_Life_Cycle__c'), fieldsListAM);

                List<IssueRequest_Life_Cycle__c> assignmentManagerList = Database.query(amQuery );

                System.debug(':::assignmentManagerList :::'+assignmentManagerList );
                if (assignmentManagerList != null && assignmentManagerList.size() > 0 ) {

                    ExAMUtilClass.AssessableObjectInAMClass assessableObjectDetails = ExAMUtilClass.getAssessableObjectDetailsFromAM( assignmentManagerList );
                    Id AssessableObjectId = assessableObjectDetails.managerIdWithAssessableObjectIdMap.get( assignmentManagerList[0].Id );
                    string AssessableObjectAPIName = assessableObjectDetails.managerIdWithAssessableObjectAPINameMap.get( assignmentManagerList[0].Id );
                    string truncatedSObjectApiName = (AssessableObjectAPIName.endsWithIgnoreCase('__c')) ? AssessableObjectAPIName.substringBefore('__c') : AssessableObjectAPIName;
                    string fieldSetName = 'ViewerFieldSet_'+truncatedSObjectApiName;
                    fields = ExAMUtilClass.getFieldSetMembers(AssessableObjectAPIName, fieldSetName);

                    AssessableRecords = ExAMUtilClass.getAssessableRecords(assignmentManagerList, false);
                    for (ExAMUtilClass.AssessableRecordsClass eachRecord : AssessableRecords) {
                        if (eachRecord.recordId == AssessableObjectId) {
                            assessableRec = eachRecord.sObjectRecord;
                            break;
                        }
                    }
                }
            }
        }
        catch(Exception e) {
            fields = new List<Schema.FieldSetMember> ();
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()) );
        }
    } 
}