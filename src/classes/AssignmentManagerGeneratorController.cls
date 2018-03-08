global with sharing class AssignmentManagerGeneratorController {
    
    public string assessableObjectJSON { get; set; }
    public string assessmentTemplateJSON { get; set; }
    public string errorMsg { get; set; }
    
    public class AssessableObjectClass {
        public string objectApi;
        public string objectLabel;
        public string assignmentManagerApi;
        public string assessmentGroupJunctionApi;
    }
    
    public class Assessment_GroupClass {
        public string assessmentGroupId;
        public string assessmentGroupName;
        public string assessmentGroupType;        
    }
    
    global class AssessableRecordClass {
        public string RecordName;
        public string RecordId;
    }

    public AssignmentManagerGeneratorController(PublicAssessmentCreationController  paController) {
    }

    global AssignmentmanagergeneratorController() {
        
        try {

            List<AssessableObjectClass> assessableObjectList = new List<AssessableObjectClass>();

            assessableObjectJSON = '';

            AssessableObjectClass asscls1 = new AssessableObjectClass();
            asscls1.objectApi = '';
            asscls1.objectLabel = '--None--';
            assessableObjectList.add(asscls1);

            ExAMUtilClass.AssessableObjectDetails objectDetails = ExAMUtilClass.getAssessableObjectDetails('ExAM__Assessment_Group_Junction__c');
            for (string objectAPINameInAGJ : objectDetails.assessableObjectAPIMap.keySet()) {

                string objectAPIName = objectDetails.assessableObjectAPIMap.get( objectAPINameInAGJ );
                string objectLabelName = objectDetails.objectAPIAndLabelMap.get( objectAPIName );

                AssessableObjectClass asscls = new AssessableObjectClass();
                asscls.objectApi = objectAPIName;
                asscls.objectLabel = objectLabelName;
                asscls.assignmentManagerApi = (objectAPINameInAGJ.startsWith('AGJ_')) ? objectAPINameInAGJ.replaceFirst('AGJ_', 'AM_') : objectAPINameInAGJ;
                asscls.assessmentGroupJunctionApi = objectAPINameInAGJ;
                assessableObjectList.add(asscls);
            }
            if (assessableObjectList.size() > 0) {
                assessableObjectJSON = JSON.serialize(assessableObjectList);
            }

            SFDCAccessController accessAT = ExAMUtilClass.AccessController;
            List<string> fieldsListAT = new List<string>{'ExAM__Template_name__c'};
            accessAT.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Main_questionaire__c'), fieldsListAT);
        
            List<Main_questionaire__c > assessmentTemplateList = [SELECT Id, Name, Template_name__c FROM Main_questionaire__c WHERE Template_name__c != null LIMIT 1000];
            if (assessmentTemplateList != null && assessmentTemplateList.size() > 0) {
                assessmentTemplateJSON = JSON.serialize(assessmentTemplateList);
            } else {
                assessmentTemplateJSON = JSON.serialize(new List<Main_questionaire__c >());
            }
        }
        catch(Exception e) {
            errorMsg = e.getMessage();
        }
    }

    @RemoteAction
    global static string getAssessmentGroups(string assessableOb) {

        try {

            List<Assessment_GroupClass> aglist = new List<Assessment_GroupClass> ();
            Assessment_GroupClass agc1 = new Assessment_GroupClass();
            agc1.assessmentGroupId = '';
            agc1.assessmentGroupName = '--None--';
            aglist.add(agc1);
            if (assessableOb != null && assessableOb != '') {

                SFDCAccessController accessAG = ExAMUtilClass.AccessController;
                List<string> fieldsListAG = new List<string>{'ExAM__Type__c'};
                accessAG.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Assessment_Group__c'), fieldsListAG);

                for (Assessment_Group__c ag :[SELECT Id, Name, Type__c FROM Assessment_Group__c WHERE Type__c =:assessableOb ORDER BY Name ASC]) {
                    Assessment_GroupClass agc = new Assessment_GroupClass();
                    agc.assessmentGroupId = ag.Id;
                    agc.assessmentGroupName = ag.Name;
                    agc.assessmentGroupType = ag.Type__c;
                    aglist.add(agc);                
                }
            }
            return JSON.serialize(aglist);
        }
        catch(Exception e) {
            throw new CustomException(e.getMessage(), null);
        }
        return null;
    }
    @RemoteAction 
    global static string saveAssignmentmanagerList(string AMApi, string assessmentGroupJunctionFieldApi, 
            string selectedGroupId, string selectedTemplateId, string noofrecords, string AssessableObjectApi,
            string selectedobjectLabel, string assessableRecId) {

        try {
            List<IssueRequest_Life_Cycle__c> insertNewAssignmentManagerList = new List<IssueRequest_Life_Cycle__c>(); 
            string responseMsg = '';  
            Integer totalNoOfRecords = 0;
            Date expDate;

            if (string.isNotBlank(assessmentGroupJunctionFieldApi) && assessmentGroupJunctionFieldApi.contains('@@')) {
                string expDateStr = (assessmentGroupJunctionFieldApi.split('@@').size() > 1) ? assessmentGroupJunctionFieldApi.split('@@')[1] : '';
                if (string.isNotBlank(expDateStr) && expDateStr.contains('/')) {
                    expDate = date.parse(expDateStr);
                }
                assessmentGroupJunctionFieldApi = assessmentGroupJunctionFieldApi.split('@@')[0];
            }

            if (AMApi != null && selectedTemplateId != null && selectedTemplateId != '') {

                SFDCAccessController accessAM = ExAMUtilClass.AccessController;
                List<String> fieldsListAM = new List<String>{'ExAM__InvestigationType__c'};
                fieldsListAM.add(AMApi);
                accessAM.assertAuthorizedToCreate(Schema.getGlobalDescribe().get('exam__IssueRequest_Life_Cycle__c'), fieldsListAM);

                if ( assessmentGroupJunctionFieldApi != null && selectedGroupId != null && selectedGroupId != '') {

                    SFDCAccessController accessAGJ = ExAMUtilClass.AccessController;
                    List<String> fieldsListAGJ = new List<String>{'ExAM__Assessment_Group__c'};
                    fieldsListAGJ.add(assessmentGroupJunctionFieldApi);
                    accessAGJ.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Assessment_Group_Junction__c'), fieldsListAGJ);

                    string queryStr = 'SELECT Id, Name, Assessment_Group__c, '+assessmentGroupJunctionFieldApi+' FROM Assessment_Group_Junction__c ';
                    queryStr += ' WHERE Assessment_Group__c =:selectedGroupId AND '+assessmentGroupJunctionFieldApi +'!= NULL';

                    List<Assessment_Group_Junction__c> agjList = Database.query(queryStr);
                    totalNoOfRecords = agjList.size();
                    if(agjList.size() > 0) {

                        for (Assessment_Group_Junction__c agj : agjList) {
                            IssueRequest_Life_Cycle__c am = new IssueRequest_Life_Cycle__c();
                            am.put('ExAM__InvestigationType__c', selectedTemplateId);
                            am.put(AMApi, agj.get(assessmentGroupJunctionFieldApi));
                            insertNewAssignmentManagerList.add(am);
                        }

                        if(insertNewAssignmentManagerList.size() > 0 && insertNewAssignmentManagerList != null) {
                            AssignmentManagerGenerator_Batch assManager = new AssignmentManagerGenerator_Batch();
                            assManager.assignmentManagerList = insertNewAssignmentManagerList;
                            assMAnager.totalNoOfRecords = totalNoOfRecords;
                            assManager.AMApi = AMApi;
                            assManager.templateId = selectedTemplateId;
                            assManager.expDate = expDate;
                            Database.executeBatch(assManager,2000);
                        }  
                        responseMsg = 'success';
                    } else {
                        responseMsg = 'The selected Assessment Group has no records.';
                    }

                } else if (noofrecords != null && noofrecords != '' && noofrecords.isNumeric() && AssessableObjectApi != null && AssessableObjectApi != '') {
                    Integer numberofRecords = Integer.valueOf(noofrecords);

                    if (assessableRecId == null || assessableRecId == '') {

                        totalNoOfRecords = numberofRecords;
                        for (integer cnt = 1; cnt <= numberofRecords; cnt++) {
                            IssueRequest_Life_Cycle__c am = new IssueRequest_Life_Cycle__c();
                            am.put('ExAM__InvestigationType__c', selectedTemplateId);
                            am.put(AMApi, '');
                            insertNewAssignmentManagerList.add(am);
                        }

                        if(insertNewAssignmentManagerList.size() > 0 && insertNewAssignmentManagerList != null) {

                            AssignmentManagerGenerator_Batch assManager = new AssignmentManagerGenerator_Batch();
                            assManager.assignmentManagerList = insertNewAssignmentManagerList;
                            assManager.assessbleObjAPI = AssessableObjectApi;
                            assManager.selectedobjectLabel = selectedobjectLabel;
                            assManager.AMApi = AMApi;
                            assManager.templateId = selectedTemplateId;
                            assMAnager.totalNoOfRecords = totalNoOfRecords;
                            assManager.expDate = expDate;
                            Database.executeBatch(assManager,2000);
                        }   
                    } else {

                        totalNoOfRecords = numberofRecords;
                        for (integer cnt = 0; cnt < numberofRecords; cnt++) {

                            IssueRequest_Life_Cycle__c am = new IssueRequest_Life_Cycle__c();
                            am.put('ExAM__InvestigationType__c', selectedTemplateId);
                            am.put(AMApi, assessableRecId);
                            insertNewAssignmentManagerList.add(am);
                        }
                        if(insertNewAssignmentManagerList.size() > 0 && insertNewAssignmentManagerList != null) {
                            AssignmentManagerGenerator_Batch assManager = new AssignmentManagerGenerator_Batch();
                            assManager.assignmentManagerList = insertNewAssignmentManagerList;
                            assMAnager.totalNoOfRecords = totalNoOfRecords;
                            assManager.AMApi = AMApi;
                            assManager.templateId = selectedTemplateId;
                            assManager.expDate = expDate;
                            Database.executeBatch(assManager,2000);
                        }   
                    }
                    responseMsg = 'success';
                }
            }
            return responseMsg;
        } catch (Exception ex) {
            throw new CustomException(ex.getMessage(), null);
        } 
        return null;
    }
    @RemoteAction 
    global static string queryAssessableRecords(string recName, string assessableObj) {

        try {
            List<SObject> assessableResultList = new List<SObject>();
            string queryStr = '';
            if (assessableObj != '') {

                SFDCAccessController accessSObj = ExAMUtilClass.AccessController;
                List<String> fieldsListSObj = new List<String>();

                if (assessableObj.equalsIgnoreCase('Contact') || assessableObj.equalsIgnoreCase('Lead')) {

                    fieldsListSObj.add('LastName');
                    queryStr = 'SELECT Id, LastName, Name, CreatedDate FROM '+assessableObj;
                    if (recName != null && recName != '') {
                        queryStr += ' WHERE LastName LIKE \'%'+recName+'%\'';
                    }
                    queryStr += ' ORDER BY CreatedDate DESC LIMIT 1000';
                    
                } else if (!assessableObj.equalsIgnoreCase('Case')) {

                    queryStr = 'SELECT Id, Name, CreatedDate FROM '+assessableObj;
                    if (recName != null && recName != '') {
                        queryStr += ' WHERE Name LIKE \'%'+recName+'%\'';
                    }
                    queryStr += ' ORDER BY CreatedDate DESC LIMIT 1000';
                    
                } else {

                    fieldsListSObj.add('CaseNumber');
                    queryStr = 'SELECT Id, CaseNumber, CreatedDate FROM '+assessableObj;
                    if (recName != null && recName != '') {
                        queryStr += ' WHERE CaseNumber LIKE \'%'+recName+'%\'';
                    }
                    queryStr += ' ORDER BY CreatedDate DESC LIMIT 1000';            
                } 
                accessSObj.assertAuthorizedToView(Schema.getGlobalDescribe().get(assessableObj), fieldsListSObj);

                assessableResultList = Database.query(queryStr);

                List<AssessableRecordClass> assResultRecList = new List<AssessableRecordClass>();
                for (SObject sob :assessableResultList) {
                    if (!assessableObj.equalsIgnoreCase('Case')) {
                        AssessableRecordClass arc = new AssessableRecordClass();
                        arc.RecordName = string.valueOf(sob.get('Name'));
                        arc.RecordId = string.valueOf(sob.get('Id'));
                        assResultRecList.add(arc);
                    } else {
                        AssessableRecordClass arc = new AssessableRecordClass();
                        arc.RecordName = string.valueOf(sob.get('CaseNumber'));
                        arc.RecordId = string.valueOf(sob.get('Id'));
                        assResultRecList.add(arc);
                    }
                }
                return JSON.Serialize(assResultRecList);
            }
        } catch (Exception ex) {
            throw new CustomException(ex.getMessage(), null);
        } 
        return null;
    }
}