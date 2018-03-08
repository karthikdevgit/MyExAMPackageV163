public with sharing class JSONUploadAMAndAnswerController {

    public List<Assignment_ManagerClass> Assignment_ManagerList;    

    public class Assignment_ManagerClass {
        public string assignment_ManagerId;
        public string assignment_ManagerName;
        public string assessmentTemplateId;
        public string assessmentTemplateExternalId;
        public string assessmentTemplateName;
        public string assessableRecordId;
        public string assessableObject;
        public string assessableFieldAPI;
        public AssessableRecordClass assessableRecord;
        public List<AssignmentManagerValueClass> assignmentManagerValue;
        public List<AnswerValueClass> answers;
    }

    public class AssignmentManagerValueClass {
        public string f_Api;   //Field API
        public string f_Value; //Field Value
    }

    public class AssessableRecordClass {        
        public List<AssessableValueClass> assessableValue;
    }

    public class AssessableValueClass {
        public string ass_f_Api;
        public string ass_f_Value;
    }

    public class AnswerValueClass {
        public string answerId;
        public string response;
        public string questionId;
        public string questionName;
        public string q_ExternalId;
        public string AM_Id;
        public string comment;
        public string priority;
        public string deficiency_status;
        public string answer_text;
        public string assessableFieldValue;
        public string assessableApi; 
        public string questionnaire_Taker_user;
        public string responsible_Party;
        public Double maxScore;       
        public Double questionWeight;
        public Double weightResponse;
        //public List<answerAssessableApiClass> assessableRecordValues;
    }

    public class ResponseClass {
        public Boolean uploadedStatus;
        public string resMsg;
        public Integer numberOfAssessableRecInserted;
        public Integer numberOfAssignmentManagerRecInserted;
        public Integer numberOfAnswerRecInserted;        
        public List<string> errorMsgs;
    }

    @RemoteAction
    public static string saveRecords(string amAndAnsJSONListStr) {        

        string assessableObj = '';

        Map<string, SObject> oldAssessmentObjIdwithRecordMap = new Map<string, SObject>();
        Map<string, SObject> oldAssignmentManagerIdwithRecordMap = new Map<string, SObject>();
        Map<string, SObject> oldAnsIdwithRecordMap = new Map<string, SObject>();

        Set<string> assessmentTemplateExternalIdSet = new Set<string>();
        Set<string> answerExternalIdSet = new Set<string>();
        Set<string> erroredTemplateQuestionIdSet = new Set<string>();

        List<string> fieldslistforinsert;
        List<string> errorMessage = new List<string>();        
        List<string> answerErrorMsg = new List<string>();  
        List<Assignment_ManagerClass> amAndAnsJSONList = (List<Assignment_ManagerClass>)JSON.deserialize(amAndAnsJSONListStr, List<Assignment_ManagerClass>.class);

        ResponseClass rescls = new ResponseClass();
        rescls.errorMsgs = new List<string>();
        rescls.resMsg = '';

        for (Assignment_ManagerClass amAnsjson : amAndAnsJSONList) {
            if (amAnsjson.assessmentTemplateId != null && amAnsjson.assessmentTemplateId != '') { 
                if (amAnsjson.assessmentTemplateExternalId != null && amAnsjson.assessmentTemplateExternalId != '' ) {
                    assessmentTemplateExternalIdSet.add(amAnsjson.assessmentTemplateExternalId); 
                } else {
                    if (!erroredTemplateQuestionIdSet.contains(amAnsjson.assessmentTemplateId)) {
                        errorMessage.add('The "'+amAnsjson.assessmentTemplateName+'" Template does not have external Id value');
                        erroredTemplateQuestionIdSet.add(amAnsjson.assessmentTemplateId); 
                        rescls.uploadedStatus = false;
                    }
                }                
            }            
            for (AnswerValueClass ans :amAnsjson.answers) {
                if (ans.q_ExternalId != null && ans.q_ExternalId != '') {
                    answerExternalIdSet.add(ans.q_ExternalId);
                } else {
                    if (!erroredTemplateQuestionIdSet.contains(ans.questionId)) {
                        answerErrorMsg.add('The "'+ans.questionName+'" Question does not have external Id value');
                        erroredTemplateQuestionIdSet.add(ans.questionId); 
                        rescls.uploadedStatus = false;
                    }
                }
            } 
        } 
        if (answerErrorMsg != null && answerErrorMsg.size() > 0) {
            errorMessage.addAll(answerErrorMsg); 
        }
        if (errorMessage.size() == 0 && assessmentTemplateExternalIdSet.size() > 0) {
            Savepoint sp = Database.setSavepoint();
            try {

                Map<string, string> externalIdwithTempIdMap = new Map<string, string>();
                Map<string, string> externalQusIdwithQusIdMap = new Map<string, string>();

                SFDCAccessController accessForobj = ExAMUtilClass.AccessController;
                List<string> fieldsList = new List<string>{'ExAM__Template_External_Id__c'};
                accessForobj.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Main_questionaire__c'), fieldsList);
                for (Main_questionaire__c assTmp : [SELECT Id, Template_External_Id__c 
                                                        FROM Main_questionaire__c 
                                                        WHERE Template_External_Id__c  != null
                                                        AND Template_External_Id__c IN:assessmentTemplateExternalIdSet 
                                                        ]) {                                                    
                    externalIdwithTempIdMap.put(assTmp.Template_External_Id__c, assTmp.Id);  
                }
                if (answerExternalIdSet.size() > 0) {
                    List<string> fieldsList1 = new List<string>{'ExAM__Question_External_Id__c'};
                    accessForobj.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Question_Template__c'), fieldsList1);
                    for ( Question_Template__c qt : [SELECT Id, Question_External_Id__c FROM Question_Template__c 
                                                        WHERE Question_External_Id__c != null 
                                                        AND Question_External_Id__c IN:answerExternalIdSet LIMIT 50000]) {

                        externalQusIdwithQusIdMap.put(qt.Question_External_Id__c, qt.Id);
                    }
                }
                fieldslistforinsert = new List<string>();
                for (Assignment_ManagerClass amAnsjson : amAndAnsJSONList) {  
                    if (amAnsjson.assessableRecord != null && amAnsjson.assessableRecord.assessableValue != null && !oldAssessmentObjIdwithRecordMap.containsKey(amAnsjson.assessableRecordId)) {                    
                        assessableObj = amAnsjson.assessableObject;
                        //SObjectType accountType = Schema.getGlobalDescribe().get(amAnsjson.assessableObject);
                        Map<string, Schema.SObjectField> schemaFieldMap = Schema.getGlobalDescribe().get(amAnsjson.assessableObject).getDescribe().fields.getMap();
                        SObject tempSob = Schema.getGlobalDescribe().get(amAnsjson.assessableObject).newSObject();
                        for (AssessableValueClass assfld :amAnsjson.assessableRecord.assessableValue) {
                            Schema.DescribeFieldResult fieldDesc = schemaFieldMap.get(assfld.ass_f_Api.toLowerCase()).getdescribe();
                            if ( !assfld.ass_f_Api.equalsIgnoreCase('Id') && assfld.ass_f_Value != null
                                    && !fieldDesc.isCalculated()) { //CURRENCY, INTEGER, DOUBLE, DATE, STRING, PICKLIST

                                if(fieldDesc.isCustom()){
                                    fieldslistforinsert.add(assfld.ass_f_Api);
                                }
                                if (fieldDesc.getType() == Schema.DisplayType.CURRENCY
                                    || fieldDesc.getType() == Schema.DisplayType.DOUBLE) {

                                    tempSob.put(assfld.ass_f_Api,  Double.valueOf(assfld.ass_f_Value));
                                } else if (fieldDesc.getType() == Schema.DisplayType.INTEGER) {
                                    tempSob.put(assfld.ass_f_Api,  Integer.valueOf(assfld.ass_f_Value));
                                } else if (fieldDesc.getType() == Schema.DisplayType.DATE) {
                                    tempSob.put(assfld.ass_f_Api,  Date.valueOf(assfld.ass_f_Value));
                                } else if (fieldDesc.getType() == Schema.DisplayType.DATETIME) {
                                    tempSob.put(assfld.ass_f_Api,  Datetime.valueOf(assfld.ass_f_Value));
                                } else if (fieldDesc.getType() == Schema.DisplayType.BOOLEAN) {
                                    tempSob.put(assfld.ass_f_Api,  Boolean.valueOf(assfld.ass_f_Value));
                                } else {
                                    tempSob.put(assfld.ass_f_Api,  assfld.ass_f_Value);
                                }
                            }                          
                        }
                        oldAssessmentObjIdwithRecordMap.put(amAnsjson.assessableRecordId, tempSob); 
                    }
                }

                if (oldAssessmentObjIdwithRecordMap != null && oldAssessmentObjIdwithRecordMap.size() > 0) {

                    accessForobj.assertAuthorizedToCreate(Schema.getGlobalDescribe().get(assessableObj), fieldslistforinsert);
                    insert oldAssessmentObjIdwithRecordMap.values();

                    fieldslistforinsert = new List<string>();
                    // Start Assignment Manager creation logic
                    for (Assignment_ManagerClass amAnsjson : amAndAnsJSONList) { 

                        if (amAnsjson.assignment_ManagerId != null && amAnsjson.assignment_ManagerId != null) {                    
                            //SObjectType accountType = Schema.getGlobalDescribe().get(amAnsjson.assessableObject);
                            Map<string, Schema.SObjectField> schemaFieldMap = Schema.SObjectType.IssueRequest_Life_Cycle__c.fields.getMap();
                            IssueRequest_Life_Cycle__c tempAssignmentManager = new IssueRequest_Life_Cycle__c();
                            if (amAnsjson.assessableFieldAPI != null && amAnsjson.assessableRecordId != null && oldAssessmentObjIdwithRecordMap.containsKey(amAnsjson.assessableRecordId)) {
                                tempAssignmentManager.put(amAnsjson.assessableFieldAPI, oldAssessmentObjIdwithRecordMap.get(amAnsjson.assessableRecordId).Id);
                            }
                            if (amAnsjson.assessmentTemplateExternalId != null && externalIdwithTempIdMap.size() > 0 && externalIdwithTempIdMap.containsKey(amAnsjson.assessmentTemplateExternalId)) {
                                tempAssignmentManager.InvestigationType__c = externalIdwithTempIdMap.get(amAnsjson.assessmentTemplateExternalId);
                            }

                            for (AssignmentManagerValueClass amfld :amAnsjson.assignmentManagerValue) {
                                Schema.DescribeFieldResult assignmentfieldDesc = schemaFieldMap.get(amfld.f_Api.toLowerCase()).getdescribe(); 
                                if ( !amfld.f_Api.equalsIgnoreCase('Id') && !amfld.f_Api.equalsIgnoreCase('ExAM__InvestigationType__c') && amfld.f_Value != null
                                        && !assignmentfieldDesc.isCalculated()
                                        && (amAnsjson.assessableFieldAPI == null || (amAnsjson.assessableFieldAPI != null && !amfld.f_Api.equalsIgnoreCase(amAnsjson.assessableFieldAPI)))
                                    ) { //CURRENCY, INTEGER, DOUBLE, DATE, STRING, PICKLIST

                                    if(assignmentfieldDesc.iscustom()){
                                        fieldslistforinsert.add(assignmentfieldDesc.getName());
                                    }
                                    if (assignmentfieldDesc.getType() == Schema.DisplayType.CURRENCY
                                            || assignmentfieldDesc.getType() == Schema.DisplayType.DOUBLE) {

                                        tempAssignmentManager.put(amfld.f_Api,  Double.valueOf(amfld.f_Value));
                                    } else if (assignmentfieldDesc.getType() == Schema.DisplayType.INTEGER) {
                                        tempAssignmentManager.put(amfld.f_Api,  Integer.valueOf(amfld.f_Value));
                                    } else if (assignmentfieldDesc.getType() == Schema.DisplayType.DATE) {
                                        tempAssignmentManager.put(amfld.f_Api,  Date.valueOf(amfld.f_Value));
                                    } else if (assignmentfieldDesc.getType() == Schema.DisplayType.DATETIME) {
                                        tempAssignmentManager.put(amfld.f_Api,  Datetime.valueOf(amfld.f_Value));
                                    } else if (assignmentfieldDesc.getType() == Schema.DisplayType.BOOLEAN) {
                                        tempAssignmentManager.put(amfld.f_Api,  Boolean.valueOf(amfld.f_Value));
                                    } else {
                                        tempAssignmentManager.put(amfld.f_Api,  amfld.f_Value);
                                    }
                                }                          
                            }
                            oldAssignmentManagerIdwithRecordMap.put(amAnsjson.assignment_ManagerId, tempAssignmentManager); 
                        }
                    }
                    // End Assignment Manager creation logic

                    if (oldAssignmentManagerIdwithRecordMap.size() > 0) {
                        accessForobj.assertAuthorizedToCreate(Schema.getGlobalDescribe().get('exam__IssueRequest_Life_Cycle__c'), fieldslistforinsert);
                        insert oldAssignmentManagerIdwithRecordMap.values();//permission checked above
                        List<Questionnaire_Response__c> insertAnswerList = new List<Questionnaire_Response__c>();
                        for (Assignment_ManagerClass amAns : amAndAnsJSONList) {  

                            for (AnswerValueClass ansV : amAns.answers) {
                                if (ansV.q_ExternalId != null && ansV.q_ExternalId != '' 
                                    && externalQusIdwithQusIdMap != null && externalQusIdwithQusIdMap.size() > 0
                                    && externalQusIdwithQusIdMap.containskey(ansV.q_ExternalId)) {

                                    Questionnaire_Response__c quesResp = new Questionnaire_Response__c();
                                    quesResp.Response__c = ansV.response;
                                    quesResp.Comment__c = ansV.comment;                                     
                                    quesResp.Priority__c = ansV.priority;
                                    quesResp.Question_Weight__c = ansV.questionWeight;
                                    quesResp.Weight_Response__c = ansV.weightResponse;
                                    quesResp.deficiency_status__c = ansV.deficiency_status;
                                    if (oldAssignmentManagerIdwithRecordMap.size() > 0 && oldAssignmentManagerIdwithRecordMap.containsKey(ansV.AM_Id)) {
                                        quesResp.Issue_Request__c = oldAssignmentManagerIdwithRecordMap.get(ansV.AM_Id).Id;
                                    }
                                    quesResp.Question_Template__c = externalQusIdwithQusIdMap.get(ansV.q_ExternalId);
                                    
                                    //quesResp. = ansV.answer_text;
                                    //quesResp. = ansV.responsible_Party; contact
                                    //Questionnaire_Taker_user__c
                                    insertAnswerList.add(quesResp);
                                }
                            }
                            
                        }
                        if (insertAnswerList != null && insertAnswerList.size() > 0) {
                            List<string> fieldsList5 = new List<string>{'ExAM__Response__c','ExAM__Comment__c','ExAM__Priority__c','ExAM__Question_Weight__c','ExAM__Weight_Response__c','ExAM__deficiency_status__c','ExAM__Issue_Request__c','ExAM__Question_Template__c'};
                            accessForobj.assertAuthorizedToCreate(Schema.getGlobalDescribe().get('exam__Questionnaire_Response__c'), fieldsList5);
                            insert insertAnswerList;
                            rescls.uploadedStatus = true;
                            rescls.resMsg = 'Upload process has completed successfully';
                            rescls.numberOfAssessableRecInserted = oldAssessmentObjIdwithRecordMap.size();
                            rescls.numberOfAssignmentManagerRecInserted = oldAssignmentManagerIdwithRecordMap.size();
                            rescls.numberOfAnswerRecInserted = insertAnswerList.size();
                        }
                    } 
                                        
                }                
            } catch (Exception ex) {
                //errorMessage += ex.getMessage() +'\n';
                errorMessage.add(ex.getMessage());                
                Database.rollback(sp);
            }
        }       
        rescls.errorMsgs = errorMessage; 
        //rescls.resMsg = errorMessage;
        return json.serialize(rescls);
    }
}