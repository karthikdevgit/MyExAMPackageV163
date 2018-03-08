public with sharing class AssessableRecordController {

    public SObject assessableRec { get; set; }
    public List<Schema.FieldSetMember> fields { get; set; }

    public string assignmentManagerId;
    public string ObjectName { get; set; }

    public Boolean section1 { get; set; }
    public Boolean section2 { get; set; }

    List<string> fieldsList = new List<string>();

    public class AssessableRecordsClass {
        public string recordId;
        public string recordName;
    }

    public AssessableRecordController() {

        try {

            section1 = true;
            section2 = false;

            assessableRec = Schema.getGlobalDescribe().get('Account').newSObject() ;
            fields = new List<Schema.FieldSetMember> ();
            assignmentManagerId = apexPages.currentPage().getparameters().get('amid');
            List<ExAMUtilClass.AssessableRecordsClass> AssessableRecords = new List<ExAMUtilClass.AssessableRecordsClass>();

            ExAMUtilClass.AssessableObjectDetails objectDetail = ExAMUtilClass.getAssessableObjectDetails('ExAM__IssueRequest_Life_Cycle__c');
            Map<string, string> fieldsMap = objectDetail.assessableObjectAPIMap;

            if ( assignmentManagerId != null && assignmentManagerId != '') {
                //Id assignmentId = Id.valueOf(assignmentManagerId);

                SFDCAccessController accessAM = ExAMUtilClass.AccessController;
                List<String> fieldsListAM = new List<String>{'ExAM__Assignment_Manager__c', 'ExAM__InvestigationType__c'};

                string amQuery = 'SELECT Assignment_Manager__c, Facility_Name__r.Name, Id, InvestigationType__c, InvestigationType__r.Name, Name';
                for (string fldName : fieldsMap.keySet()) {
                    amQuery += ' ,' + fldName;
                    fieldsListAM.add(fldName);
                }
                amQuery += ' FROM IssueRequest_Life_Cycle__c WHERE Id =:assignmentManagerId LIMIT 1';

                accessAM.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__IssueRequest_Life_Cycle__c'), fieldsListAM);

                List<IssueRequest_Life_Cycle__c> assignmentManagerList = Database.query(amQuery );

                if (assignmentManagerList != null && assignmentManagerList.size() > 0 ) {

                    ExAMUtilClass.AssessableObjectInAMClass assessableObjectDetails = ExAMUtilClass.getAssessableObjectDetailsFromAM( assignmentManagerList );
                    if (assessableObjectDetails != null
                        && (assessableObjectDetails.managerIdWithAssessableObjectIdMap.containsKey(assignmentManagerList[0].Id) && assessableObjectDetails.managerIdWithAssessableObjectIdMap.get(assignmentManagerList[0].Id) != null)
                        && (assessableObjectDetails.managerIdWithAssessableObjectAPINameMap.containsKey(assignmentManagerList[0].Id) && assessableObjectDetails.managerIdWithAssessableObjectAPINameMap.get(assignmentManagerList[0].Id) != null)
                    ) {

                        Id AssessableObjectId = assessableObjectDetails.managerIdWithAssessableObjectIdMap.get( assignmentManagerList[0].Id );
                        string AssessableObjectAPIName = assessableObjectDetails.managerIdWithAssessableObjectAPINameMap.get( assignmentManagerList[0].Id );
                        string truncatedSObjectApiName = (AssessableObjectAPIName.endsWithIgnoreCase('__c')) ? AssessableObjectAPIName.substringBefore('__c') : AssessableObjectAPIName;
                        string fieldSetName = 'ViewerFieldSet_'+truncatedSObjectApiName;
                        fields = ExAMUtilClass.getFieldSetMembers(AssessableObjectAPIName, fieldSetName);
                        ObjectName = AssessableObjectAPIName;

                        AssessableRecords = ExAMUtilClass.getAssessableRecords(assignmentManagerList, false);
                        if (AssessableRecords != null && AssessableRecords.size() > 0) {
                            for (ExAMUtilClass.AssessableRecordsClass eachRecord : AssessableRecords) {
                                if (eachRecord.recordId == AssessableObjectId) {
                                    assessableRec = eachRecord.sObjectRecord;
                                    break;
                                }
                            }
                        }
                    }
                }//end if assignmentManagerList queried list not equals to null and size greater than 0 codn check
            }//end if assignmentManagerId not equals to null and blank codn check
        }
        catch(Exception e) {
            fields = new List<Schema.FieldSetMember> ();
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()) );
        }
    }   
    
    public void editRecord() {
        section1 = false;
        section2 = true;
    }
    
    public void saveRecord() {
        try {
            if (assessableRec != null && assessableRec.Id != null) {

                Id assessableObjectId = assessableRec.Id;
                Schema.DescribeSobjectResult sObj = assessableObjectId.getSObjectType().getDescribe();
                string assessableObjectName = '';
                if (sObj.isCustom()) {
                    assessableObjectName = 'exam__'+sObj.getLocalName();
                }
                else {
                    assessableObjectName = sObj.getName();
                }
                SFDCAccessController accessSObj = ExAMUtilClass.AccessController;
                accessSObj.assertAuthorizedToUpdate(Schema.getGlobalDescribe().get(assessableObjectName), fieldsList);
                update assessableRec;
                section1 = true;
                section2 = false;
            }
        } catch(Exception ex) {
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()) );
        }
    }

    public PageReference cancelRecord() {

        PageReference pref;
        if (assignmentManagerId != null && assignmentManagerId != '') {
            pref = new PageReference('/apex/ExAM__AssessableRecord?amid='+assignmentManagerId);
        }
        else {
            pref = new PageReference('/apex/ExAM__AssessableRecord');
        }
        pref.setRedirect(true);
        return pref; 
    }
}