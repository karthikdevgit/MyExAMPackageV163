public with sharing class AssignmentManagerAnswerJSONExportCtrl {

    //start variable declaration
    string amqueryStr;
    public string jsonString { get; set; }
    public string templateName { get; set;}
    public string templateId { get; set; }
    public string headerStr { get; set; }
    public string footerStr { get; set; }
    public string headerUrl { get; set; }
    public string footerUrl { get; set; }
    public string head { get; set; }
    public string headSize { get; set; }

    public Boolean isCommentShow { get; set; }
    public Boolean isPictureShow { get; set; }
    public Boolean isRenderAspdf { get; set; }

    public Report_Builder_Configuration__c rbc;
    public ExAM_Configuration__c examConfig { get; set; } 

    public SelectedAssessableObjField assObjPosition = new SelectedAssessableObjField();

    public List<assignmentManagerPositionCls> amPositionList = new List<assignmentManagerPositionCls>();
    public List<IssueRequest_Life_Cycle__c> AMList = new List<IssueRequest_Life_Cycle__c>();
    public List<assignmentManagerRecord> amrecordList { get; set; }
    public List<Assignment_ManagerClass> Assignment_ManagerList;

    public Set<Id> assignmentManagerIdSet ;
    
    public Map<string, Boolean> sectionIdwithIsSelectedMap = new Map<string, Boolean>();
    public Map<string,List<ID>> ansIdwithListOfAttIdMap { get; set; }
    public Map<Id, IssueRequest_Life_Cycle__c> amIdwithAssignmentManagerMap;
    public Map<Id, List<Questionnaire_Response__c>> amIdwithListOfAnswerMap ;
    //End variable declaration
    
    public class Assignment_ManagerClass {
        public string assignment_ManagerId;
        public string assignment_ManagerName;
        public string assessmentTemplateId;
        public string assessmentTemplateExternalId;
        public string assessmentTemplateName;
        public List<AssignmentManagerValueClass> assignmentManagerValue;
        public string assessableRecordId;
        public string assessableObject;
        public string assessableFieldAPI;
        public AssessableRecordClass assessableRecord;
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
        public Double maxScore;       
        public Double questionWeight;
        public Double weightResponse;
        public string deficiency_status;
        public string answer_text;
        public string assessableFieldValue;
        public string assessableApi; 
        public string questionnaire_Taker_user;
        public string responsible_Party;
        //public List<answerAssessableApiClass> assessableRecordValues;
    }
    /*public class answerAssessableApiClass {
        public string assessableApi;
        public string assessableValue;        
    }*/
    //Start Report Builder JSON Structure    
    public Class assignmentManagerPositionCls {
        public string apiName;
        public string labelName;
        public Integer position;
    }    
    public Class assignmentManagerRecord {
        public string amName {get; set; }
        public string amId { get; set; }
        public List<assignmentManagerFieldValue> amFieldValues {get; set;}
    }
    public Class assignmentManagerFieldValue {
        public string apiName {get; set;}
        public string labelName {get; set;}
        public Integer position {get; set;}
        public string fieldvalue {get; set;}
        public string apiName2 {get; set;}
        public string labelName2 {get; set;}
        public Integer position2 {get; set;}
        public string fieldvalue2 {get; set;}
    }
    public Class sectionClass {
        public string sectionIdorAll;
        public Boolean isSelectedSection;
    }
    public Class SelectedAssessableObjField {
        public string assessableObjectLabel;
        public string assessableObjectAPI;
        public string assignmentManagerApi;
        public List<assignmentManagerPositionCls> assessablefields;
    }
    //End Report Builder JSON Structure
    
    public AssignmentManagerAnswerJSONExportCtrl() {
        try {
            jsonString = '';
            
            string reportBuilderConfigId = apexPages.currentPage().getParameters().get('reportbuilderid');
            rbc = new Report_Builder_Configuration__c();
            
            amrecordList = new List<assignmentManagerRecord> ();
            templateName = '';
            
            assignmentManagerIdSet = new Set<Id>();    
            amIdwithListofAnswerMap = new Map<Id, List<Questionnaire_Response__c>> ();
            
            headerStr = '';
            footerStr = '';    
            examConfig = new ExAM_Configuration__c();
            
            headerUrl = '';
            footerUrl = '';
            ansIdwithListOfAttIdMap = new Map<string, List<ID>>();  
            isCommentShow = false;
            isPictureShow = false;
            
            amIdwithAssignmentManagerMap = new Map<Id, IssueRequest_Life_Cycle__c> ();
            amIdwithListOfAnswerMap = new Map<Id, List<Questionnaire_Response__c>>();
            if (reportBuilderConfigId != null && reportBuilderConfigId != '') {
                
                SFDCAccessController accessEC = ExAMUtilClass.AccessController;
                List<String> fieldsListEC = new List<String>{'ExAM__Report_Builder_Page_Footer__c', 'ExAM__Report_Builder_Page_Header__c'};
                accessEC.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__ExAM_Configuration__c'), fieldsListEC);
    
                List<ExAM_Configuration__c> exConfigList = [
                    SELECT Id, Name, Report_Builder_Page_Header__c, Report_Builder_Page_Footer__c 
                    FROM   ExAM_Configuration__c
                    WHERE  Name = 'Configuration' LIMIT 1
                ];
                if (exConfigList != null && exConfigList.size() > 0) {
                    examConfig = exConfigList[0];
                }
    
                SFDCAccessController accessAT = ExAMUtilClass.AccessController;
                List<String> fieldsListAT = new List<String>{'ExAM__Template_Name__c'};
                accessAT.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Main_questionaire__c'), fieldsListAT);
    
                SFDCAccessController accessAM = ExAMUtilClass.AccessController;
                List<String> fieldsListAM = new List<String>{'ExAM__InvestigationType__c'};
                accessAM.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__IssueRequest_Life_Cycle__c'), fieldsListAM);
    
                SFDCAccessController accessRBC = ExAMUtilClass.AccessController;
                List<String> fieldsListRBC = new List<String>{'ExAM__Assessment_Data_Config__c', 'ExAM__Assignment_Manager_position__c', 'ExAM__Assessable_Object_Field_Position__c', 'ExAM__Assessment_Template__c', 'ExAM__Choosed_Assignment_manager__c', 'ExAM__End_Date_Range__c', 'ExAM__Output_Format__c', 'ExAM__Selected_Sections__c', 'ExAM__Start_Date_Range__c'};
                accessRBC.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Report_Builder_Configuration__c'), fieldsListRBC);
    
                List<Report_Builder_Configuration__c> repBuilderList = [
                    SELECT Assessment_Data_Config__c, Assignment_Manager_position__c, Assessable_Object_Field_Position__c,
                           Assessment_Template__c, Assessment_Template__r.Template_Name__c, Choosed_Assignment_manager__c,
                           Choosed_Assignment_manager__r.InvestigationType__c,
                           Choosed_Assignment_manager__r.InvestigationType__r.Template_Name__c, End_Date_Range__c, Id,
                           Name, Output_Format__c, Selected_Sections__c, Start_Date_Range__c
                    FROM   Report_Builder_Configuration__c
                    WHERE  Id =:reportBuilderConfigId LIMIT 1
                ];
                
                if (repBuilderList != null && repBuilderList.size() > 0) {
                    rbc = repBuilderList[0];
                    if (rbc.Assessment_Template__c != null || rbc.Choosed_Assignment_manager__c != null) {
                        if (rbc.Assessment_Template__c != null) {
                            templateName = rbc.Assessment_Template__r.Template_Name__c; 
                            templateId = rbc.Assessment_Template__c;
                        } else if (rbc.Choosed_Assignment_manager__c != null) {
                            if (rbc.Choosed_Assignment_manager__r.InvestigationType__c != null) {
                                templateName = rbc.Choosed_Assignment_manager__r.InvestigationType__r.Template_Name__c;
                            }
                            templateId = rbc.Choosed_Assignment_manager__r.InvestigationType__c;
                            system.debug('::::templateName::::'+templateName);
                            system.debug('::::templateId::::'+templateId);
                            
                        }                   
                            
                        if (rbc.Output_Format__c == 'PDF' ) {
                            isRenderAspdf = true;
                        }
                        if (rbc.Assessment_Data_Config__c != null && rbc.Assessment_Data_Config__c != '') {
                            Map<string, Boolean> dataConfigNameWithIsShow = (Map<string, Boolean>)System.JSON.deserialize(rbc.Assessment_Data_Config__c , Map<string, Boolean>.class);
                            //{"Questions":false,"Answers":true,"Comments":false,"Pictures":true}
                            if (dataConfigNameWithIsShow != null && dataConfigNameWithIsShow.size() > 0 ) {
                                if( dataConfigNameWithIsShow.containskey('Comments') && dataConfigNameWithIsShow.get('Comments')) {
                                    isCommentShow = true;
                                }
                                if (dataConfigNameWithIsShow.containskey('Pictures') && dataConfigNameWithIsShow.get('Pictures')) {
                                    isPictureShow = true;
                                }
                            }
                        }
                        
                        if (rbc.Assignment_Manager_position__c != null && rbc.Assignment_Manager_position__c != '') {
                            //Map<string, string> lookupfieldwithObjectMap = new Map<string, string>();
                            Map<string, string> assessableLookupfieldwithObjectMap = new Map<string, string>();
                            Map<string, Set<string>> objectApiwithListOfRecIdsMap = new Map<string, Set<string>>();
                            Map<string, Set<string>> assessableObjwithSetOfFieldsMap = new Map<string, Set<string>>();//{'Account',['Name','Id']}
                            Map<Id, SObject> assessableObjectIdwithRecordMap = new Map<Id, SObject>();
                            
                            List<string> amFieldList = new List<string>();
                            Set<string> fieldSet = new Set<string>();
                           
                            if(rbc.Assignment_Manager_position__c != null && rbc.Assignment_Manager_position__c != '') {
                                amPositionList = (List<assignmentManagerPositionCls>)System.JSON.deserialize(rbc.Assignment_Manager_position__c, List<assignmentManagerPositionCls>.class);
                            }
                            //System.debug('::::::amPositionList::::'+amPositionList);
                            if(rbc.Assessable_Object_Field_Position__c != null && rbc.Assessable_Object_Field_Position__c != '') {
                                assObjPosition = (SelectedAssessableObjField)System.JSON.deserialize(rbc.Assessable_Object_Field_Position__c,SelectedAssessableObjField.class);
                            }
                            //System.debug('::::assObjPosition::::'+assObjPosition);
                            
                            fieldSet.add('name');
                            fieldSet.add('id');
                            fieldSet.add('exam__scheduled_start_date__c');
                            fieldSet.add('exam__investigationtype__c');
                            
                            Set<string> accountOmittedFields = new Set<string> {'Active__c','CustomerPriority__c', 
                                                                                'NumberofLocations__c', 'SLA__c', 
                                                                                'SLAExpirationDate__c', 'SLASerialNumber__c', 
                                                                                'UpsellOpportunity__c'};
                            
                            ExAMUtilClass.AssessableObjectDetails objectDetail = ExAMUtilClass.getAssessableObjectDetails('ExAM__IssueRequest_Life_Cycle__c');
                            if (objectDetail != null) {

                                Map<string, string> fieldsMap = objectDetail.assessableObjectAPIMap;
                                assessableLookupfieldwithObjectMap = fieldsMap;
                                fieldSet.addAll( assessableLookupfieldwithObjectMap.keySet() );
                            }
                            for (assignmentManagerPositionCls amp : amPositionList) {
                            
                                if (amp.apiName != null && amp.apiName != '') {
                                    string apiLowercase = amp.apiName.toLowerCase();
                                    fieldSet.add(apiLowercase);
                                }
                            }
                            //This code for Assessable object api name and list of assessable fields api get.
                            if (assessableLookupfieldwithObjectMap != null && assessableLookupfieldwithObjectMap.size() > 0) {
                                for (string assessableOb :assessableLookupfieldwithObjectMap.values()) {
                                    if(assObjPosition != null && assessableOb == assObjPosition.assessableObjectAPI) {
                                        List<assignmentManagerPositionCls> selectedAssFieldList = new List<assignmentManagerPositionCls>();
                                        selectedAssFieldList.addAll(assObjPosition.assessablefields);
                                        
                                        if(!assessableObjwithSetOfFieldsMap.containskey(assessableOb)) {
                                            assessableObjwithSetOfFieldsMap.put(assessableOb, new Set<string>());
                                        } 
                                        if(selectedAssFieldList != null &&  selectedAssFieldList.size() > 0) {
                                            for(assignmentManagerPositionCls fieldapi : selectedAssFieldList) {
                                                if(fieldapi.apiName != '') {
                                                    assessableObjwithSetOfFieldsMap.get(assessableOb).add(fieldapi.apiName);
                                                    //assessableObjwithSetOfFieldsMap.get(assessableOb).add(assObjPosition.assessablefields.apiName);
                                                }
                                            }
                                        }
                                        break;
                                    System.debug('::heap Size3::::'+limits.getHeapSize());  
                                    } else {
                                        Map <string, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(assessableOb).getDescribe().fields.getMap();
                                        for (Schema.SObjectField assField : fieldMap.Values()) {
                                            Schema.DescribeFieldResult fieldDesc = assField.getDescribe();
                                            if (!fieldDesc.isCalculated() && fieldDesc.getType() != Schema.DisplayType.REFERENCE) {
                                                
                                                if (!assessableObjwithSetOfFieldsMap.containskey(assessableOb)) {
                                                    assessableObjwithSetOfFieldsMap.put(assessableOb, new Set<string>());
                                                }
                                                assessableObjwithSetOfFieldsMap.get(assessableOb).add(fieldDesc.getName());
                                            }
                                        }
                                        System.debug('::heap Size4::::'+limits.getHeapSize());
                                    }
                                }                        
                            }
                            system.debug('::::assessableObjwithSetOfFieldsMap:::'+assessableObjwithSetOfFieldsMap);
    
                            SFDCAccessController accessAT1 = ExAMUtilClass.AccessController;
                            List<String> fieldsListAT1 = new List<String>{'ExAM__Template_External_Id__c', 'ExAM__Template_Name__c'};
                            accessAT1.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Main_questionaire__c'), fieldsListAT1);
    
                            SFDCAccessController accessAM1 = ExAMUtilClass.AccessController;
                            List<String> fieldsListAM1 = new List<String>();
    
                            amqueryStr = 'SELECT ExAM__InvestigationType__r.ExAM__Template_External_Id__c, ExAM__InvestigationType__r.ExAM__Template_name__c,';                                
    
                            amFieldList.addAll(fieldSet);
                            fieldsListAM1.addAll(fieldSet);
    
                            amqueryStr += string.join(amFieldList,', ');
                            
                            string assTempId = rbc.Assessment_Template__c;
                            amqueryStr += ' FROM ExAM__IssueRequest_Life_Cycle__c WHERE Id != null '; 
    
                            if (assTempId != null) {
                                amqueryStr += ' AND ExAM__InvestigationType__c = :assTempId'; 
                            }
                            if (rbc.Choosed_Assignment_manager__c != null) {
                                string assManagerId = rbc.Choosed_Assignment_manager__c;
                                System.debug('::::assManagerId::::'+assManagerId);
                                amqueryStr += ' AND Id = :assManagerId'; 
                            }
                            if (rbc.Start_Date_Range__c != null && rbc.Start_Date_Range__c != '') {
                                List<string> dateStr = rbc.Start_Date_Range__c.split('/');
                                if (dateStr != null && dateStr.size() == 3) {
                                    Date startTime = date.newinstance( Integer.valueOf(dateStr[2]), Integer.valueOf(dateStr[0]), Integer.valueOf(dateStr[1]) );
                                    amqueryStr += ' AND ExAM__Scheduled_Start_Date__c >=:startTime'; 
                                }
                            }                        
                            if (rbc.End_Date_Range__c != null && rbc.End_Date_Range__c != '') {
                                List<string> dateStr = rbc.End_Date_Range__c.split('/');
                                if (dateStr != null && dateStr.size() == 3) {
                                    Date endTime = date.newinstance( Integer.valueOf(dateStr[2]), Integer.valueOf(dateStr[0]), Integer.valueOf(dateStr[1]) );
                                    amqueryStr += ' AND ExAM__Scheduled_Start_Date__c <=:endTime'; 
                                }
                            }
                            
                            System.debug(':::::string query::::'+amqueryStr);
    
                            accessAM1.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__IssueRequest_Life_Cycle__c'), fieldsListAM1);
    
                            List<IssueRequest_Life_Cycle__c> amQueryList = new List<IssueRequest_Life_Cycle__c> ();
                            amQueryList = Database.query(amqueryStr);
                            system.debug(':::amQueryList ::::'+amQueryList );
                            if (amQueryList != null && amQueryList.size() > 0) {
                                for (IssueRequest_Life_Cycle__c tempAM : amQueryList) {
                                    for (string assessableFieldapi :assessableLookupfieldwithObjectMap.keySet()) {
                                        if (tempAM.get(assessableFieldapi) != null) {
                                            if (!objectApiwithListOfRecIdsMap.containsKey(assessableLookupfieldwithObjectMap.get(assessableFieldapi))) {
                                                objectApiwithListOfRecIdsMap.put(assessableLookupfieldwithObjectMap.get(assessableFieldapi), new Set<string>());
                                            }
                                            objectApiwithListOfRecIdsMap.get(assessableLookupfieldwithObjectMap.get(assessableFieldapi)).add(string.valueOf(tempAM.get(assessableFieldapi)));
                                            break;
                                        }
                                    }
                                } 
                                system.debug(':::objectApiwithListOfRecIdsMap::::'+objectApiwithListOfRecIdsMap);
                            
                                if (objectApiwithListOfRecIdsMap != null && objectApiwithListOfRecIdsMap.size() > 0 
                                    && assessableObjwithSetOfFieldsMap != null && assessableObjwithSetOfFieldsMap.size() > 0) {
                                    
                                    for (string assobj : objectApiwithListOfRecIdsMap.keySet()) {
                                        if (assessableObjwithSetOfFieldsMap.containskey(assobj)) {
                                            Set<string> idsSet = objectApiwithListOfRecIdsMap.get(assObj);
                                            Set<string> fieldsSet = assessableObjwithSetOfFieldsMap.get(assObj);
                                            fieldsSet.add('Id');
                                            List<string> listOfAssessableFields = new List<string>();
                                            listOfAssessableFields.addAll(fieldsSet);
                                            string assQuery = 'SELECT '+ string.join(listOfAssessableFields,',')+' FROM '+ assobj +' WHERE Id IN:idsSet ';
                                            List<SObject> tempAssessableList = Database.query(assQuery);
                                            Map<Id, SObject> assessableIdwithRecordMap = new Map<Id, SObject> (tempAssessableList );
                                            if (assessableIdwithRecordMap != null && assessableIdwithRecordMap.size() > 0) {
                                                assessableObjectIdwithRecordMap.putAll(assessableIdwithRecordMap); 
                                            }
                                        }
                                    }
                                    
                                    System.debug('::::assessableObjectIdwithRecordMap:::::'+assessableObjectIdwithRecordMap);
                                
                                }
                                
                                amIdwithAssignmentManagerMap = new Map<Id, IssueRequest_Life_Cycle__c> (amQueryList );
                                system.debug(':::::::amIdwithAssignmentManagerMap :::'+amIdwithAssignmentManagerMap );
                                
                                //find assessable record field
                                List<String> fieldsListAnswer = new List<String>{'ExAM__Response__c', 'ExAM__Question_Template__c', 'ExAM__Issue_Request__c', 'ExAM__deficiency_status__c', 'ExAM__Comment__c', 'ExAM__Priority__c', 'ExAM__Questionnaire_Taker_user__c', 'ExAM__Question_Weight__c', 'ExAM__Weight_Response__c', 'ExAM__Responsible_Party__c'};
                                List<string> ansAssessableApiSet = new List<string>();
                                ExAMUtilClass.AssessableObjectDetails objectDetailANS = ExAMUtilClass.getAssessableObjectDetails('ExAM__Questionnaire_Response__c');
                                if (objectDetailANS != null) {
                                    ansAssessableApiSet.addAll( objectDetailANS.assessableObjectAPIMap.keySet() );
                                }
                                
                                string answerAssessableApi = '';
                                if (ansAssessableApiSet != null && ansAssessableApiSet.size() > 0) {
                                    answerAssessableApi = string.join(ansAssessableApiSet,',');
                                    answerAssessableApi =', '+answerAssessableApi; 
                                    for(string fieldApi : objectDetailANS.assessableObjectAPIMap.keySet()) {
                                        fieldsListAnswer.add( fieldApi );
                                    }
                                }
                                Set<Id> assignmentmanagerIdSet = amIdwithAssignmentManagerMap.keySet();
    
                                SFDCAccessController accessQT = ExAMUtilClass.AccessController;
                                List<String> fieldsListQT = new List<String>{'ExAM__Question_External_Id__c'};
                                accessQT.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Question_Template__c'), fieldsListQT);
    
                                SFDCAccessController accessAnswer = ExAMUtilClass.AccessController;
                                accessAnswer.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Questionnaire_Response__c'), fieldsListAnswer);
    
                                string answerQueryStr = 'SELECT Id, ExAM__Response__c, ExAM__Question_Template__c, ExAM__Question_Template__r.Name, ExAM__Question_Template__r.ExAM__Question_External_Id__c, ExAM__Issue_Request__c,'
                                                        +' ExAM__deficiency_status__c, ExAM__Comment__c, ExAM__Priority__c, ExAM__Questionnaire_Taker_user__c, '
                                                        +' ExAM__Question_Weight__c, ExAM__Weight_Response__c, ExAM__Responsible_Party__c '+answerAssessableApi 
                                                        +' FROM ExAM__Questionnaire_Response__c '
                                                        +' WHERE ExAM__Issue_Request__c IN: assignmentmanagerIdSet ';
                                                        
                                System.debug(':::answerQueryStr::::'+answerQueryStr);
                                //List<Questionnaire_Response__c > queriedAnswerList = Database.Query(answerQueryStr);
                                
                                for( Questionnaire_Response__c ans : Database.Query(answerQueryStr)) {
                                
                                    if (!amIdwithListofAnswerMap.containsKey(ans.Issue_Request__c)) {
                                        amIdwithListofAnswerMap.put(ans.Issue_Request__c, new List<Questionnaire_Response__c>()); 
                                    }
                                    amIdwithListofAnswerMap.get(ans.Issue_Request__c).add(ans);                                    
                                }
                                
                                Assignment_ManagerList = new List<Assignment_ManagerClass>();
                                
                                for (IssueRequest_Life_Cycle__c am1 : amQueryList) {
                                    Assignment_ManagerClass amRecord = new Assignment_ManagerClass();
                                    amRecord.assignment_ManagerId = am1.Id;
                                    amRecord.assignment_ManagerName = am1.Name;
                                    amRecord.assessmentTemplateId = am1.InvestigationType__c;
                                    if (am1.InvestigationType__c != null) {
                                        amRecord.assessmentTemplateExternalId = am1.InvestigationType__r.Template_External_Id__c;
                                        amRecord.assessmentTemplateName = am1.InvestigationType__r.Template_name__c;
                                    }
                                    amRecord.assignmentManagerValue = new List<AssignmentManagerValueClass>(); 
                                        
                                    for (string amfld : fieldSet ) {
                                        if (amfld.startswithIgnoreCase('AM_') || amfld.endsWithIgnoreCase('exam__facility_name__c')) {
                                            if (am1.get(amfld) != null) {
                                                amRecord.assessableRecord = new AssessableRecordClass(); 
                                                string assRecId = string.valueOf(am1.get(amfld));   
                                                amRecord.assessableRecordId = assRecId;
                                                amRecord.assessableFieldAPI = amfld;
                                                string assessableObjectApiName = '';
                                                if (assessableLookupfieldwithObjectMap != null && assessableLookupfieldwithObjectMap.containskey(amfld)) {
                                                    assessableObjectApiName = assessableLookupfieldwithObjectMap.get(amfld);
                                                    amRecord.assessableObject = assessableObjectApiName;
                                                }    
                                                List<AssessableValueClass> tempAssVal = new List<AssessableValueClass>();
                                                if (assessableObjectApiName != '' && assessableObjwithSetOfFieldsMap != null && assessableObjwithSetOfFieldsMap.containsKey(assessableObjectApiName)
                                                    && assessableObjectIdwithRecordMap != null && assessableObjectIdwithRecordMap.containskey(assRecId)) {
                                                    for (string assField: assessableObjwithSetOfFieldsMap.get(assessableObjectApiName)) {
                                                        if (assessableObjectIdwithRecordMap.get(assRecId).get(assField) != null) {
                                                            AssessableValueClass tempAssFieldVal = new AssessableValueClass();
                                                            tempAssFieldVal.ass_f_Api = assField;
                                                            tempAssFieldVal.ass_f_Value = string.valueOf(assessableObjectIdwithRecordMap.get(assRecId).get(assField));                                                        
                                                            tempAssVal.add(tempAssFieldVal);
                                                        }
                                                    }
                                                }
                                                amRecord.assessableRecord.assessableValue = tempAssVal;
                                                
                                            }
                                        
                                        } else if (amfld != 'name' && amfld != 'id' && amfld != 'exam__investigationtype__c') { 
                                            AssignmentManagerValueClass tempAssignmentManager = new AssignmentManagerValueClass();
                                            tempAssignmentManager.f_Api = amfld;
                                            tempAssignmentManager.f_Value = string.valueOf(am1.get(amfld));
                                            amRecord.assignmentManagerValue.add(tempAssignmentManager);
                                        }
                                    }
                                    amRecord.answers = new List<AnswerValueClass>();
                                    if (amIdwithListofAnswerMap != null && amIdwithListofAnswerMap.size() > 0 && amIdwithListofAnswerMap.containsKey(am1.Id)) {
                                        
                                        for (Questionnaire_Response__c ansRes : amIdwithListofAnswerMap.get(am1.Id)) {
                                            AnswerValueClass answerTemp = new AnswerValueClass ();
                                            answerTemp.answerId = ansRes.Id;
                                            answerTemp.response = ansRes.Response__c;
                                            answerTemp.questionId = ansRes.Question_Template__c;
                                            answerTemp.questionName = ansRes.Question_Template__r.Name;
                                            answerTemp.q_ExternalId = ansRes.Question_Template__r.Question_External_Id__c;
                                            answerTemp.AM_Id = ansRes.Issue_Request__c;
                                            answerTemp.deficiency_status = ansRes.deficiency_status__c;
                                            answerTemp.comment = ansRes.Comment__c; 
                                            answerTemp.priority = ansRes.Priority__c; 
                                            answerTemp.questionnaire_Taker_user = ansRes.Questionnaire_Taker_user__c;
                                            answerTemp.questionWeight = ansRes.Question_Weight__c;
                                            answerTemp.weightResponse = ansRes.Weight_Response__c; 
                                            answerTemp.responsible_Party = ansRes.Responsible_Party__c; 
                                            
                                            if (ansRes.Account_to_Response__c != null) {
                                                answerTemp.assessableFieldValue = ansRes.Account_to_Response__c;
                                                answerTemp.assessableApi = 'ExAM__Account_to_Response__c';                                                
                                            } else {
                                                for (string ansAss :ansAssessableApiSet) {
                                                    if (ansRes.get(ansAss) != null) {
                                                        answerTemp.assessableFieldValue = string.valueOf(ansRes.get(ansAss));
                                                        answerTemp.assessableApi = ansAss;  
                                                        break;
                                                    }
                                                }
                                            }
                                            /*List<answerAssessableApiClass> tempAssAnsVals = new List<answerAssessableApiClass>();
                                            for (string ansAss :ansAssessableApiSet) {
                                                answerAssessableApiClass ansAssTemp = new answerAssessableApiClass();
                                                ansAssTemp.assessableApi = ansAss ;
                                                ansAssTemp.assessableValue = string.valueOf(ansRes.get(ansAss));
                                                tempAssAnsVals.add(ansAssTemp);
                                            }
                                            answerTemp.assessableRecordValues = tempAssAnsVals;
                                            */
                                            
                                            amRecord.answers.add(answerTemp);
                                        }   
                                    
                                    }                                        
                                    Assignment_ManagerList.add(amRecord); 
                                }//Assignment manager for loop
                                system.debug(':::::Assignment_ManagerList::::'+Assignment_ManagerList);
                                //system.debug('::::::Assignment_ManagerList string:::::'+JSON.serialize(Assignment_ManagerList));
                                jsonString = JSON.serialize(Assignment_ManagerList);                            
                            }
                        }
                    }
                }
            }        
        } catch( Exception e) {
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()) );
        }
    }
}