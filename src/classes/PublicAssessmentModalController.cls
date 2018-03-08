public with sharing class PublicAssessmentModalController {
    public string assTempJSON {get;set;}
    public string amJSON {get;set;}
    public string assessableObjJSON {get;set;}
    public String exceptMsg { get; set; }
    
    public class AssessableObjectClass {
        public String objectApi;
        public String objectLabel;
    }
    public class AssessableRecordClass {
        public String RecordName;
        public String RecordId;
    }
    public class AssessableQueryResultClass {
        public List<AssessableRecordClass> assessableRecords;
        public string success;
        public string error;
    }
    public PublicAssessmentModalController() {
        try{
            exceptMsg = '';
            List<Main_questionaire__c> assTempList = new List<Main_questionaire__c>();
            List<IssueRequest_Life_Cycle__c> amList = new List<IssueRequest_Life_Cycle__c>();
            List<AssessableObjectClass> assessableObjList = new List<AssessableObjectClass>();
            
            SFDCAccessController accessForAT = ExAMUtilClass.AccessController;
            List<String> fieldsListAT = new List<String>{'ExAM__Template_name__c'};
            accessForAT.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Main_questionaire__c'), fieldsListAT);
            System.debug('test exception msg::');
            assTempList = [SELECT ID,Name,Template_name__c FROM Main_questionaire__c ORDER BY CreatedDate DESC LIMIT 1000];
            
            if (assTempList != null && assTempList.size() > 0) {
                assTempJSON = JSON.serialize(assTempList);
            } else {
                assTempJSON = JSON.serialize(new List<Main_questionaire__c >());
            }
            accessForAT.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__IssueRequest_Life_Cycle__c'), new List<String>());
            amList = [SELECT Id,Name FROM IssueRequest_Life_Cycle__c ORDER BY CreatedDate DESC LIMIT 1000];
            
            if (assTempList != null && assTempList.size() > 0) {
                amJSON = JSON.serialize(amList);
            } else {
                amJSON = JSON.serialize(new List<IssueRequest_Life_Cycle__c>());
            }
            ExAMUtilClass.AssessableObjectDetails objectDetails = ExAMUtilClass.getAssessableObjectDetails('ExAM__IssueRequest_Life_Cycle__c');
            if (objectDetails != null && objectDetails.objectAPIAndLabelMap != null && objectDetails.objectAPIAndLabelMap.size() > 0) {
                for (string objectApiName : objectDetails.objectAPIAndLabelMap.keySet()) {

                    string objectLabelName = objectDetails.objectAPIAndLabelMap.get(objectApiName);

                    AssessableObjectClass assclass = new AssessableObjectClass();
                    assclass.objectApi = objectApiName;
                    assclass.objectLabel = objectLabelName;
                    assessableObjList.add(assclass);
                }
                if (assessableObjList.size() > 0) {
                    assessableObjJSON = JSON.serialize(assessableObjList);
                }
            }
        } catch(Exception e) {
            system.debug(':::::e:::::'+e);
            exceptMsg = e.getMessage();
        }
    }
    
    @RemoteAction
    public static string queryAssessableRecords(String recName, string assessableObj) {
        try {
            List<SObject> assessableResultList = new List<SObject>();
            AssessableQueryResultClass assResult = new AssessableQueryResultClass();
            assResult.assessableRecords = new List<AssessableRecordClass>();
            assResult.success = '';
            assResult.error = '';
            
            List<AssessableRecordClass> assResultRecList = new List<AssessableRecordClass>();
            
            SFDCAccessController accessForAssObj = ExAMUtilClass.AccessController;
            String queryStr = '';
            
             if (assessableObj != '') {
                if (assessableObj.equalsIgnoreCase('Contact') || assessableObj.equalsIgnoreCase('Lead')) {
                    List<String> fieldsList = new List<String>{'LastName'};
                    accessForAssObj.assertAuthorizedToView(Schema.getGlobalDescribe().get(assessableObj), fieldsList);
                    queryStr = 'SELECT Id, LastName, Name, CreatedDate FROM '+assessableObj;
                    if (recName != null && recName != '') {
                        queryStr += ' WHERE LastName LIKE \''+recName+'%\'';
                    }
                    queryStr += ' ORDER BY CreatedDate DESC LIMIT 1000';
                    
                } else if (!assessableObj.equalsIgnoreCase('Case')) {
                    accessForAssObj.assertAuthorizedToView(Schema.getGlobalDescribe().get(assessableObj), new List<String>());
                    queryStr = 'SELECT Id, Name, CreatedDate FROM '+assessableObj;
                    if (recName != null && recName != '') {
                        queryStr += ' WHERE Name LIKE \''+recName+'%\'';
                    }
                    queryStr += ' ORDER BY CreatedDate DESC LIMIT 1000';
                    
                } else {
                    List<String> fieldsList = new List<String>{'CaseNumber'};
                    accessForAssObj.assertAuthorizedToView(Schema.getGlobalDescribe().get(assessableObj), fieldsList);
                    queryStr = 'SELECT Id, CaseNumber, CreatedDate FROM '+assessableObj;
                    if (recName != null && recName != '') {
                        queryStr += ' WHERE CaseNumber LIKE \''+recName+'%\'';
                    }
                    queryStr += ' ORDER BY CreatedDate DESC LIMIT 1000';            
                } 
            }
            assessableResultList = Database.query(queryStr);
            
            if(assessableResultList != null && assessableResultList.size() > 0) {
                for (SObject sob :assessableResultList) {
                    if (!assessableObj.equalsIgnoreCase('Case')) {
                        AssessableRecordClass arc = new AssessableRecordClass();
                        arc.RecordName = String.valueOf(sob.get('Name'));
                        arc.RecordId = String.valueOf(sob.get('Id'));
                        assResultRecList.add(arc);
                    } else {
                        AssessableRecordClass arc = new AssessableRecordClass();
                        arc.RecordName = String.valueOf(sob.get('CaseNumber'));
                        arc.RecordId = String.valueOf(sob.get('Id'));
                        assResultRecList.add(arc);
                    }
                }
                assResult.assessableRecords = assResultRecList;
                assResult.success = 'success';

                return JSON.Serialize(assResult);
            } else {
                assResult.error = 'No Records Found';
                return JSON.Serialize(assResult);
            }
         } catch(Exception e) {
            AssessableQueryResultClass assResultError = new AssessableQueryResultClass();
            assResultError.assessableRecords = new List<AssessableRecordClass>();
            assResultError.success = '';
            assResultError.error = e.getMessage();
            return JSON.Serialize(assResultError);
        } 
    }
}