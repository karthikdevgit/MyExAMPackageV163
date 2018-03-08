public with sharing class MultipleInspectionAssessmentViewCtrller {

    public String currentASMId{get; set;}
    public String currentASMNameString{get; set;}
    public String currentASMAssessmentTemplateId{get; set;}
    public Boolean hasAnswersAvailableForUnitTemplate{get; set;}
    public String currentASMAssessmentTemplateName {get; set;}
    public String assessableRecordName { get; set; }
    public String assessableRecordId { get; set; }
    
    public String assRecClsListJSON { get; set; }
    public String assessableFieldAPIName { get; set; }
    
    //new changes 07-04-2016
    public string template_type { get; set; }
    public Boolean isRelatedAM { get; set; }
    public Boolean isLensViewerTemplate { get; set; }
    public Boolean isNoExamConfig { get; set; }
    public String primaryAMListStr { get; set; }
    
    public String assessableField_API { get; set; }
    public String primaryTemplateId { get; set; }

    //Added on 01-07-2016
    public Boolean hideRAMTab1 { get; set; }
    public Boolean hideRAMTab2 { get; set; }
    public Boolean hideRAMTab3 { get; set; }
    public Boolean hideRAMTab4 { get; set; }
    public Boolean hideDataViewerTab { get; set; }
    public Boolean hideAMListTab { get; set; }
    public Boolean hideAssessableRecordTab { get; set; }
    public Boolean hideKnowledgeArticleTab { get; set; }
    public Boolean hideSaveBtn { get; set; }
    
    public Boolean show_Question_Name_on_Decision_Tree { get; set; }

    public string assessableObjectLabel { get; set; }
    public string assessableObjectName { get; set; }
    public Boolean hasAssessableObj { get; set; }
    public string objectReference { get; set; }

    public class MultipleInspectionViewerReqdInput {
        public String exceptionMsg;
        public ExAM_Configuration__c examConfigurationRecord;
        public List<Account> acctList;
        public List<IssueRequest_Life_Cycle__c> ASMListForUnitAssessmentTemplate;
        public List<IssueRequest_Life_Cycle__c> ASMListForSiteAssessmentTemplate;
        public List<IssueRequest_Life_Cycle__c> ASMListForSystemsAssessmentTemplate;
        public List<IssueRequest_Life_Cycle__c> ASMListForCommonAreasAssessmentTemplate;
        public List<IssueRequest_Life_Cycle__c> ASMListForExteriorAssessmentTemplate;
    }
    
    public class ErrorClass {
        public string errType{get; set;}
        public string errMsg{get; set;}

        public ErrorClass(string etype, string eMsg) {

            this.errType = etype;
            this.errMsg = eMsg; 
        }
    }

    public class SuccessClass {
        public string code{get; set;}
        public string msg{get; set;}

        public SuccessClass(string sCode, string sMsg) {

            this.code = sCode;
            this.msg = sMsg; 
        }
    }
    
    public MultipleInspectionAssessmentViewCtrller() {
        try{
            currentASMId = ApexPages.currentPage().getParameters().get('amid');
            hasAnswersAvailableForUnitTemplate = false;
            assRecClsListJSON = '';
            assessableFieldAPIName = '';
            assessableObjectLabel = '';
            assessableObjectName = '';
            hasAssessableObj = false;
            objectReference = '';
            
            //new changes 07-04-2016
            isRelatedAM = false;
            isLensViewerTemplate = true;
            isNoExamConfig = false;
            template_type = '';
            String childPrimaryAssignmentQuery = '';
            primaryAMListStr = '';        
            assessableField_API = '';
            primaryTemplateId = '';
    
            //Variable Intialization on 01-07-2016
            hideRAMTab1 = false;
            hideRAMTab2 = false;
            hideRAMTab3 = false;
            hideRAMTab4 = false;
            hideDataViewerTab = false;
            hideAMListTab = false;
            hideAssessableRecordTab = false;
            hideKnowledgeArticleTab = false;
            hideSaveBtn = false;
            
            show_Question_Name_on_Decision_Tree = false;
            Admin_Configuration__c adminConf = Admin_Configuration__c.getInstance(UserInfo.getUserId());
            
            if (adminConf != null && adminConf.Show_Question_Name_on_Decision_Tree__c != null ) {
                show_Question_Name_on_Decision_Tree = adminConf.Show_Question_Name_on_Decision_Tree__c;
            }
            
            SFDCAccessController accessForMulIns = ExAMUtilClass.AccessController;
            List<String> fieldsListEc = new List<String>{'ExAM__Hide_AM_List_Tab__c', 'ExAM__Hide_Assessable_Record_Tab__c', 'ExAM__Hide_Data_Viewer_Tab__c',
                       'ExAM__Hide_Knowledge_Article_Tab__c', 'ExAM__Hide_Related_Assignment_Manager1_Tab__c',
                       'ExAM__Hide_Related_Assignment_Manager2_Tab__c', 'ExAM__Hide_Related_Assignment_Manager3_Tab__c',
                       'ExAM__Hide_Related_Assignment_Manager4_Tab__c', 'ExAM__Primary_Assessment_Type_Template__c',
                       'ExAM__Related_Assessment_Type_1_Template__c', 'ExAM__Related_Assessment_Type_2_Template__c',
                       'ExAM__Related_Assessment_Type_3_Template__c', 'ExAM__Related_Assessment_Type_4_Template__c',
                       'ExAM__Hide_Save_Button__c'};
            accessForMulIns.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__ExAM_Configuration__c'), fieldsListEc);
            
            List<IssueRequest_Life_Cycle__c> childAssignmentManagersList = new List<IssueRequest_Life_Cycle__c> ();
            List<ExAM_Configuration__c> exConfigurationList = [
                SELECT Hide_AM_List_Tab__c, Hide_Assessable_Record_Tab__c, Hide_Data_Viewer_Tab__c,
                       Hide_Knowledge_Article_Tab__c, Hide_Related_Assignment_Manager1_Tab__c,
                       Hide_Related_Assignment_Manager2_Tab__c, Hide_Related_Assignment_Manager3_Tab__c,
                       Hide_Related_Assignment_Manager4_Tab__c, Id, Name, Primary_Assessment_Type_Template__c,
                       Related_Assessment_Type_1_Template__c, Related_Assessment_Type_2_Template__c,
                       Related_Assessment_Type_3_Template__c, Related_Assessment_Type_4_Template__c,
                       Hide_Save_Button__c
                FROM   ExAM_Configuration__c
                WHERE  Name = 'Configuration' limit 1
            ];
            if (exConfigurationList != null && exConfigurationList.size() > 0) {
                hideRAMTab1 = exConfigurationList[0].Hide_Related_Assignment_Manager1_Tab__c;
                hideRAMTab2 = exConfigurationList[0].Hide_Related_Assignment_Manager2_Tab__c;
                hideRAMTab3 = exConfigurationList[0].Hide_Related_Assignment_Manager3_Tab__c;
                hideRAMTab4 = exConfigurationList[0].Hide_Related_Assignment_Manager4_Tab__c;
                hideDataViewerTab = exConfigurationList[0].Hide_Data_Viewer_Tab__c;
                hideAMListTab = exConfigurationList[0].Hide_AM_List_Tab__c;
                hideAssessableRecordTab = exConfigurationList[0].Hide_Assessable_Record_Tab__c;
                hideKnowledgeArticleTab = exConfigurationList[0].Hide_Knowledge_Article_Tab__c;
                hideSaveBtn = exConfigurationList[0].Hide_Save_Button__c;
            }
            if (String.isNotBlank(currentASMId)) {
                
                Map<string,string> assignmentManagerFieldAnswerFieldMap = new Map<string,string>(); 
            
                ExAMUtilClass.AssessableObjectDetails objectDetailsANS = ExAMUtilClass.getAssessableObjectDetails('ExAM__IssueRequest_Life_Cycle__c');
                if (objectDetailsANS != null && objectDetailsANS.assessableObjectAPIMap != null && objectDetailsANS.assessableObjectAPIMap.size() > 0) {
                    assignmentManagerFieldAnswerFieldMap = objectDetailsANS.assessableObjectAPIMap;
                }
                
                List<String> fieldsListAT = new List<String>{'ExAM__Show_Image_Upload_Icon__c', 'ExAM__Show_Notes_Icon__c','ExAM__Show_Refresh_Icon__c',
                                                                'ExAM__Show_Question_Number__c','ExAM__One_Time_Assessment__c'};
                accessForMulIns.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Main_questionaire__c'), fieldsListAT);
                
                List<String> fieldsListAM = new List<String>{'ExAM__Assignment_Manager__c', 'ExAM__Facility_Name__c', 'ExAM__InvestigationType__c','ExAM__Related_Assignment_Manager1__c',
                                                                'ExAM__Related_Assignment_Manager2__c', 'ExAM__Related_Assignment_Manager2__c'};
                accessForMulIns.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__IssueRequest_Life_Cycle__c'), fieldsListAM);
                
                String amQuery = 'SELECT ExAM__Assignment_Manager__c, ExAM__Facility_Name__r.Name,';
                amQuery += ' Id, ExAM__InvestigationType__c, ExAM__InvestigationType__r.Name, Name,';
                amQuery += ' ExAM__InvestigationType__r.ExAM__Show_Image_Upload_Icon__c, ExAM__InvestigationType__r.ExAM__Show_Notes_Icon__c,';
                amQuery += ' ExAM__InvestigationType__r.ExAM__Show_Refresh_Icon__c, ExAM__InvestigationType__r.ExAM__Show_Question_Number__c,';
                amQuery += ' ExAM__InvestigationType__r.ExAM__One_Time_Assessment__c';
                for (String assessableFieldapi : assignmentManagerFieldAnswerFieldMap.keySet()) { 
                    amQuery += ' ,'+assessableFieldapi;
                }
                amQuery += ' FROM ExAM__IssueRequest_Life_Cycle__c WHERE  Id = :currentASMId AND ExAM__InvestigationType__c != null LIMIT 1';
                List<IssueRequest_Life_Cycle__c> currentASMList = Database.Query(amQuery);
    
                if (currentASMList != null && currentASMList.size() > 0) {
    
                    ExAMUtilClass.AssessableObjectDetails assessableObjectDetails = ExAMUtilClass.getAssessableObjectDetails( 'ExAM__IssueRequest_Life_Cycle__c' );
                    if (assessableObjectDetails != null) {
                
                        ExAMUtilClass.AssessableObjectInAMClass objectDetail = ExAMUtilClass.getAssessableObjectDetailsFromAM( currentASMList );
                        string objectAPIName = objectDetail.managerIdWithAssessableObjectAPINameMap.get( currentASMList[0].Id );
                        if( objectAPIName != null ){
                            assessableFieldAPIName = assessableObjectDetails.objectAndFieldAPIMap.get( objectAPIName );
                            assessableField_API = assessableObjectDetails.objectAndFieldAPIMap.get( objectAPIName );
                            assessableObjectLabel = objectDetail.managerIdWithAssessableObjectLabelMap.get( currentASMList[0].Id );
                            assessableObjectName = (assessableObjectLabel != 'Case') ? assessableFieldAPIName.replace('__c', '__r.Name') : assessableFieldAPIName.replace('__c', '__r.CaseNumber');
                            objectReference = assessableFieldAPIName.replace('__c', '__r');
                        }
                    }

                    //new changes 07-04-2016 start
                    if (exConfigurationList != null && exConfigurationList.size() > 0) {
                        
                        primaryTemplateId = exConfigurationList[0].Primary_Assessment_Type_Template__c;
                        if (currentASMList[0].InvestigationType__c != exConfigurationList[0].Primary_Assessment_Type_Template__c) {
                            
                            isRelatedAM = true;
                            childPrimaryAssignmentQuery  = 'SELECT Id, ExAM__InvestigationType__c,Name, '; 
                            childPrimaryAssignmentQuery += 'ExAM__Related_Assignment_Manager1__c, ExAM__Related_Assignment_Manager2__c, ExAM__Related_Assignment_Manager3__c, ExAM__Related_Assignment_Manager4__c';
                            if (string.isNotBlank(assessableFieldAPIName) && string.isNotBlank(assessableObjectName)) {
                                childPrimaryAssignmentQuery += ', '+assessableFieldAPIName+', '+assessableObjectName+' ';
                            }
                            childPrimaryAssignmentQuery += ' FROM ExAM__IssueRequest_Life_Cycle__c '; 
                            childPrimaryAssignmentQuery += 'WHERE ExAM__InvestigationType__c = \''+exConfigurationList[0].Primary_Assessment_Type_Template__c+'\''; 
                            if (currentASMList[0].InvestigationType__c == exConfigurationList[0].Related_Assessment_Type_1_Template__c) {
                                template_type = 'Related_Assessment_Type_1';            
                                childPrimaryAssignmentQuery += ' AND ExAM__Related_Assignment_Manager1__c = \''+currentASMList[0].Id+'\' Limit 1000';   
                            } else if (currentASMList[0].InvestigationType__c == exConfigurationList[0].Related_Assessment_Type_2_Template__c) {
                                template_type = 'Related_Assessment_Type_2';            
                                childPrimaryAssignmentQuery += ' AND ExAM__Related_Assignment_Manager2__c = \''+currentASMList[0].Id+'\' Limit 1000';   
                            } else if (currentASMList[0].InvestigationType__c == exConfigurationList[0].Related_Assessment_Type_3_Template__c) {
                                template_type = 'Related_Assessment_Type_3';
                                childPrimaryAssignmentQuery += ' AND ExAM__Related_Assignment_Manager3__c = \''+currentASMList[0].Id+'\' Limit 1000';   
                            } else if (currentASMList[0].InvestigationType__c == exConfigurationList[0].Related_Assessment_Type_4_Template__c) {
                                template_type = 'Related_Assessment_Type_4';
                                childPrimaryAssignmentQuery += ' AND ExAM__Related_Assignment_Manager4__c = \''+currentASMList[0].Id+'\' Limit 1000';   
                            } else {
                                template_type = '';
                                isLensViewerTemplate = false;
                                isRelatedAM = false;
                            }
                        } else {
                            template_type = 'Primary_Assessment_Type';
                            isRelatedAM = false;
                        }
                        
                        if (isLensViewerTemplate && isRelatedAM) {
                            System.debug('::childPrimaryAssignmentQuery::'+childPrimaryAssignmentQuery);
                            childAssignmentManagersList = Database.Query(childPrimaryAssignmentQuery);
                            System.debug('::childAssignmentManagersList ::'+childAssignmentManagersList);
    
                            if (childAssignmentManagersList != null && childAssignmentManagersList.size() > 0) {
                                primaryAMListStr = JSON.serialize(childAssignmentManagersList);
                            }
                        }
                    } else {
                        isNoExamConfig = true;
                    }
                    //new changes 07-04-2016 end
                    
                    currentASMNameString = currentASMList[0].Name;
                    currentASMAssessmentTemplateId = currentASMList[0].InvestigationType__c;

                    currentASMAssessmentTemplateName = currentASMList[0].InvestigationType__r.Name;
                    List<Questionnaire_Response__c> answersList = new List<Questionnaire_Response__c>();
                    
                    List<String> fieldsListST = new List<String>{'ExAM__Questionnaire_Section__c'};
                    accessForMulIns.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Section_Template__c'), fieldsListST);
                    
                    List<String> fieldsListQT = new List<String>{'ExAM__Section_Question__c', 'ExAM__Question_Type__c','ExAM__Subquestion_Label__c'};
                    accessForMulIns.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Question_Template__c'), fieldsListQT);
                    
                    List<String> fieldsListQR = new List<String>{'ExAM__Issue_Request__c', 'ExAM__Question_Template__c'};
                    accessForMulIns.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Questionnaire_Response__c'), fieldsListQR);
                    
                    answersList = [
                        SELECT Id, Name, Issue_Request__c, Question_Template__c, Question_Template__r.Section_Question__c,
                               Question_Template__r.Section_Question__r.Questionnaire_Section__c, Question_Template__r.Question_Type__c, Question_Template__r.Subquestion_Label__c
                        FROM   Questionnaire_Response__c
                        WHERE  Issue_Request__c = :currentASMId LIMIT 1
                    ];
        
                    if (answersList != null && answersList.size() > 0) {
        
                        hasAnswersAvailableForUnitTemplate = true;
                    }
    
                    List<ExAMUtilClass.AssessableRecordsClass> AssessableRecordsList = new List<ExAMUtilClass.AssessableRecordsClass>();
                    // start - new assessable object record with parent record values get logic code
                    ExAMUtilClass.AssessableRecordsClass arcNone = new ExAMUtilClass.AssessableRecordsClass();
                    arcNone.recordId = '';
                    arcNone.recordName = '--None--';
                    AssessableRecordsList.add(arcNone);
                    
                    string AssessableObjectAPIName = '';
                    Id AssessableObjectId;
                    string SELECT_CLAUSE = '';
                    string FROM_CLAUSE = '';
                    string WHERE_CLAUSE = '';
                    string ORDER_BY_CLAUSE = '';
                    string QUERY_STRING = '';
                    List<SObject> sObjectList = new List<SObject>();
                    
                    List<ExAMUtilClass.AssessableRecordsClass> AssessableRecords = new List<ExAMUtilClass.AssessableRecordsClass>();
                    ExAMUtilClass.AssessableObjectInAMClass assessableObjectDetailsFrmAM = ExAMUtilClass.getAssessableObjectDetailsFromAM( currentASMList );
                    AssessableObjectId = assessableObjectDetailsFrmAM.managerIdWithAssessableObjectIdMap.get(currentASMList[0].Id);
                    AssessableRecords = ExAMUtilClass.getAssessableRecords(currentASMList, false);
                    if (AssessableRecords != null && AssessableRecords.size() > 0) {
                        for (ExAMUtilClass.AssessableRecordsClass eachRecord : AssessableRecords) {
                            if (eachRecord.recordId == AssessableObjectId) {
                                assessableRecordId = eachRecord.recordId;
                                assessableRecordName = eachRecord.recordName;
                                break;
                            }
                        }
                    }
                    AssessableRecords = ExAMUtilClass.getAssessableRecords(currentASMList, true);
                    if (AssessableRecords != null && AssessableRecords.size() > 0) {
                        AssessableRecordsList.addAll(AssessableRecords);
                        assRecClsListJSON = JSON.serialize(AssessableRecordsList);
                        hasAssessableObj = true;
                    }
                }
                // End- new assessable object record with parent record values get logic code
            }
        } catch( Exception e ){
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()) );
        }
        
    }//end constructor

    @RemoteAction
    public static MultipleInspectionViewerReqdInput fetchRelatedAssignmentManagers(String currentManagerId, String assessableFieldAPIName1, String assessableRecList) {
        MultipleInspectionViewerReqdInput assignmentManagerDtl = new MultipleInspectionViewerReqdInput();
        try {
            Map<Id, List<IssueRequest_Life_Cycle__c>> assessmentTemplateIdAndAssignmentManagersMap = new Map<Id, List<IssueRequest_Life_Cycle__c>>();
            Map<Id, IssueRequest_Life_Cycle__c> managerIdRecordMap = new Map<Id, IssueRequest_Life_Cycle__c>();
            assignmentManagerDtl.exceptionMsg = '';
            
            Set<String> relatedAssessmentTemplateIdSet = new Set<String>();
            Set<Id> assessableRecordIdSet = new Set<Id>();
            
            SFDCAccessController accessAM = ExAMUtilClass.AccessController;
            
            List<String> fieldsListAM = new List<String>{'ExAM__Facility_Name__c', 'ExAM__InvestigationType__c', 'ExAM__Assignment_Manager__c', 'ExAM__Related_Assignment_Manager1__c', 
                                                        'ExAM__Related_Assignment_Manager2__c', 'ExAM__Related_Assignment_Manager3__c', 'ExAM__Related_Assignment_Manager4__c'};
            accessAM.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__IssueRequest_Life_Cycle__c'), fieldsListAM);
            
            List<IssueRequest_Life_Cycle__c> currentAmList = [
                SELECT CreatedDate, Facility_Name__c, Facility_Name__r.Name, Id, InvestigationType__c,
                       InvestigationType__r.Name, Name, Assignment_Manager__c, Related_Assignment_Manager1__c,
                       Related_Assignment_Manager1__r.Name, Related_Assignment_Manager2__c,
                       Related_Assignment_Manager2__r.Name, Related_Assignment_Manager3__c,
                       Related_Assignment_Manager3__r.Name, Related_Assignment_Manager4__c,
                       Related_Assignment_Manager4__r.Name
                FROM   IssueRequest_Life_Cycle__c
                WHERE  Id =:currentManagerId LIMIT 1
            ];
             
            if (currentAmList != null && currentAmList.size() > 0) {
                assignmentManagerDtl.ASMListForUnitAssessmentTemplate = currentAmList ;
            } 
            
            List<String> fieldsListEC = new List<String>{'ExAM__Decision_Tree__c', 'ExAM__Primary_Assessment_Type_Template__c', 'ExAM__Related_Assessment_Type_1_Template__c', 
                                                         'ExAM__Related_Assessment_Type_2_Template__c', 'ExAM__Related_Assessment_Type_3_Template__c', 'ExAM__Related_Assessment_Type_4_Template__c'};
            accessAM.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__ExAM_Configuration__c'), fieldsListEC);
            
            List<ExAM_Configuration__c> examConfigurationList = new List<ExAM_Configuration__c>([
                SELECT CreatedDate, Decision_Tree__c, Hours__c, Id, Name, Primary_Assessment_Type_Template__c,
                       Related_Assessment_Type_1_Template__c, Related_Assessment_Type_2_Template__c,
                       Related_Assessment_Type_3_Template__c, Related_Assessment_Type_4_Template__c
                FROM   ExAM_Configuration__c ORDER BY CreatedDate DESC LIMIT 1
            ]);
    
            if (examConfigurationList != null && examConfigurationList.size() > 0) {
    
                assignmentManagerDtl.examConfigurationRecord = examConfigurationList[0];
    
                DateTime dt = DateTime.Now().addHours( -1 );
    
                if (examConfigurationList[0].Hours__c != null) {
    
                    Integer i = Integer.valueOf(examConfigurationList[0].Hours__c) * -1;
                     dt = DateTime.Now().addHours( i );
                }
                List<ExAMUtilClass.AssessableRecordsClass> assRecList = (List<ExAMUtilClass.AssessableRecordsClass>)System.JSON.deserialize(assessableRecList, List<ExAMUtilClass.AssessableRecordsClass>.class);
                for (ExAMUtilClass.AssessableRecordsClass arc : assRecList) {
                    if (arc.recordId != null && arc.recordId != '') {
                        assessableRecordIdSet.add(arc.recordId);
                    }
                }                 
                
                if (examConfigurationList[0].Related_Assessment_Type_1_Template__c != null) {
                    relatedAssessmentTemplateIdSet.add(examConfigurationList[0].Related_Assessment_Type_1_Template__c);
                }
                if (examConfigurationList[0].Related_Assessment_Type_2_Template__c != null) {
                    relatedAssessmentTemplateIdSet.add(examConfigurationList[0].Related_Assessment_Type_2_Template__c);
                }
                if (examConfigurationList[0].Related_Assessment_Type_3_Template__c != null) {
                    relatedAssessmentTemplateIdSet.add(examConfigurationList[0].Related_Assessment_Type_3_Template__c);
                }
                if (examConfigurationList[0].Related_Assessment_Type_4_Template__c != null) {
                    relatedAssessmentTemplateIdSet.add(examConfigurationList[0].Related_Assessment_Type_4_Template__c);
                }
                String amQueryStr = 'SELECT CreatedDate, ExAM__Facility_Name__c, ExAM__Facility_Name__r.Name, Id, ExAM__InvestigationType__c, ExAM__InvestigationType__r.Name, Name, ExAM__Assignment_Manager__c, '+
                                            ' ExAM__Related_Assignment_Manager1__c, ExAM__Related_Assignment_Manager1__r.Name, ExAM__Related_Assignment_Manager2__c, '+
                                            ' ExAM__Related_Assignment_Manager2__r.Name, ExAM__Related_Assignment_Manager3__c, ExAM__Related_Assignment_Manager3__r.Name, ExAM__Related_Assignment_Manager4__c, ExAM__Related_Assignment_Manager4__r.Name ';
                if ( assessableFieldAPIName1 != null && assessableFieldAPIName1 != '' && assessableFieldAPIName1 != 'ExAM__Facility_Name__c') {
                    amQueryStr += ',' +assessableFieldAPIName1 ;
                    if (assessableFieldAPIName1 != 'ExAM__AM_Case__c') {
                        amQueryStr += ',' +assessableFieldAPIName1.replace('__c', '__r.Name') ;
                    }
                    else {
                        amQueryStr += ',' +assessableFieldAPIName1.replace('__c', '__r.CaseNumber') ;
                    }
                }                    
    
                amQueryStr += ' FROM ExAM__IssueRequest_Life_Cycle__c WHERE ExAM__InvestigationType__c != null AND CreatedDate >= :dt ';
                
                if (relatedAssessmentTemplateIdSet != null && relatedAssessmentTemplateIdSet.size() > 0) {
                    amQueryStr += ' AND ExAM__InvestigationType__c IN:relatedAssessmentTemplateIdSet';
                }
                if (assessableRecordIdSet != null && assessableRecordIdSet.size() > 0) {
                    amQueryStr += ' AND '+assessableFieldAPIName1+' IN:assessableRecordIdSet';
                }
                
                List<IssueRequest_Life_Cycle__c> allAssignmentManagerQueryList = Database.query(amQueryStr);
                
                for(IssueRequest_Life_Cycle__c asm : allAssignmentManagerQueryList) {
    
                    //Current Assignment Manager should not be added for search dropdown in corresponding tabs
                    if (asm.Id != currentManagerId) {
        
                        //Construct a map with key as Assessment Template Id and value as list of Assignment Managers
                        if(!assessmentTemplateIdAndAssignmentManagersMap.containsKey(asm.InvestigationType__c)) {
        
                            assessmentTemplateIdAndAssignmentManagersMap.put(asm.InvestigationType__c, new List<IssueRequest_Life_Cycle__c>());
                        }
                        assessmentTemplateIdAndAssignmentManagersMap.get( asm.InvestigationType__c ).add( asm );
                    }
                    managerIdRecordMap.put(asm.Id, asm);
                }
                ExAM_Configuration__c configurationRecord = examConfigurationList[0];
    
                if (assessmentTemplateIdAndAssignmentManagersMap.containsKey(configurationRecord.Related_Assessment_Type_1_Template__c) &&
                    assessmentTemplateIdAndAssignmentManagersMap.get(configurationRecord.Related_Assessment_Type_1_Template__c).size() > 0) {
    
                    assignmentManagerDtl.ASMListForSiteAssessmentTemplate = assessmentTemplateIdAndAssignmentManagersMap.get(configurationRecord.Related_Assessment_Type_1_Template__c);
                }
                if (assessmentTemplateIdAndAssignmentManagersMap.containsKey(configurationRecord.Related_Assessment_Type_2_Template__c) &&
                    assessmentTemplateIdAndAssignmentManagersMap.get(configurationRecord.Related_Assessment_Type_2_Template__c).size() > 0) {
    
                    assignmentManagerDtl.ASMListForSystemsAssessmentTemplate = assessmentTemplateIdAndAssignmentManagersMap.get(configurationRecord.Related_Assessment_Type_2_Template__c);
                }
                if (assessmentTemplateIdAndAssignmentManagersMap.containsKey(configurationRecord.Related_Assessment_Type_3_Template__c) &&
                    assessmentTemplateIdAndAssignmentManagersMap.get(configurationRecord.Related_Assessment_Type_3_Template__c).size() > 0) {
    
                    assignmentManagerDtl.ASMListForCommonAreasAssessmentTemplate = assessmentTemplateIdAndAssignmentManagersMap.get(configurationRecord.Related_Assessment_Type_3_Template__c);
                }
                if (assessmentTemplateIdAndAssignmentManagersMap.containsKey(configurationRecord.Related_Assessment_Type_4_Template__c) &&
                    assessmentTemplateIdAndAssignmentManagersMap.get(configurationRecord.Related_Assessment_Type_4_Template__c).size() > 0) {
    
                    assignmentManagerDtl.ASMListForExteriorAssessmentTemplate = assessmentTemplateIdAndAssignmentManagersMap.get(configurationRecord.Related_Assessment_Type_4_Template__c);
                }
            }
            
        } catch( Exception e ) {
            assignmentManagerDtl.exceptionMsg = e.getMessage();
        }
        return assignmentManagerDtl;
    }

    @RemoteAction
    public static string linkSelectedASMWithCurrentAssignmentManager(String tobeUpdatedAssignmentManagerArr) {

        String dmlResponseMsg = '';
        String tobeLinkedManagerId = '';
        List<String> asmIdArray = new List<String>();

        if (String.isNotBlank(tobeUpdatedAssignmentManagerArr)) {
    
            try {

                asmIdArray = (List<String>)System.JSON.deserialize(tobeUpdatedAssignmentManagerArr, List<String>.class);
                System.debug(':::asmIdArray:::'+asmIdArray);
                IssueRequest_Life_Cycle__c tobeUpdatedAssignmentManagerRecord = new IssueRequest_Life_Cycle__c();
                tobeUpdatedAssignmentManagerRecord.Id = asmIdArray[0];
                if (asmIdArray[2] == System.Label.Related_Assessment_Type_1) {

                    tobeUpdatedAssignmentManagerRecord.Related_Assignment_Manager1__c = asmIdArray[1];
                }else if (asmIdArray[2] == System.Label.Related_Assessment_Type_2) {

                    tobeUpdatedAssignmentManagerRecord.Related_Assignment_Manager2__c = asmIdArray[1];
                }else if (asmIdArray[2] == System.Label.Related_Assessment_Type_3) {

                    tobeUpdatedAssignmentManagerRecord.Related_Assignment_Manager3__c = asmIdArray[1];
                }else if (asmIdArray[2] == System.Label.Related_Assessment_Type_4) {

                    tobeUpdatedAssignmentManagerRecord.Related_Assignment_Manager4__c = asmIdArray[1];
                }
                
                SFDCAccessController accessAssMngr = ExAMUtilClass.AccessController;
                List<String> fieldsListAMUpdate = new List<String>{'ExAM__Related_Assignment_Manager1__c','ExAM__Related_Assignment_Manager2__c',
                                                                'ExAM__Related_Assignment_Manager3__c','ExAM__Related_Assignment_Manager4__c'};
                accessAssMngr.assertAuthorizedToUpdate(Schema.getGlobalDescribe().get('exam__IssueRequest_Life_Cycle__c'), fieldsListAMUpdate);
                
                update tobeUpdatedAssignmentManagerRecord;
                dmlResponseMsg = JSON.serialize( new SuccessClass('success', 'Related Assignment of this assignment manager updated successfully') );
            }catch(Exception exp) {
                dmlResponseMsg = JSON.serialize( new ErrorClass(exp.getTypeName(), (exp.getTypeName() != 'System.DMLException') ? exp.getMessage() : exp.getDMLMessage(0)) );
            }
        }
        return dmlResponseMsg;
    }

    @RemoteAction
    public static string createNewAssignmentManager(String tobeCreatedASMReqdInputArr) {

        string response;
        List<String> reqdInputIdArray = new List<String>();

        if (String.isNotBlank(tobeCreatedASMReqdInputArr)) {

            try {

                reqdInputIdArray = (List<String>)System.JSON.deserialize(tobeCreatedASMReqdInputArr, List<String>.class);

                /* Code creates a new Assignment Manger against the selected Account and Assessment Template which is displayed now */
                IssueRequest_Life_Cycle__c tobeCreatedASM = new IssueRequest_Life_Cycle__c();
                tobeCreatedASM.put(reqdInputIdArray[4],reqdInputIdArray[1]);
                tobeCreatedASM.InvestigationType__c = reqdInputIdArray[2];
                tobeCreatedASM.OwnerId = UserInfo.getUserId();
                
                SFDCAccessController accessAssMngr = ExAMUtilClass.AccessController;
                List<String> fieldsListAMCreate = new List<String>{'ExAM__InvestigationType__c'};
                accessAssMngr.assertAuthorizedToCreate(Schema.getGlobalDescribe().get('exam__IssueRequest_Life_Cycle__c'), fieldsListAMCreate);
                
                insert tobeCreatedASM;

                /* Added code to query the inserted manager to get its name which is needed in front end */
                IssueRequest_Life_Cycle__c newManagerRecord = [SELECT Id, Name, InvestigationType__c FROM IssueRequest_Life_Cycle__c WHERE Id = :tobeCreatedASM.Id LIMIT 1];

                /* Code below links current Assignment Manger with the newly created Manger based on tab from which this action is called */
                IssueRequest_Life_Cycle__c tobeUpdatedASM = new IssueRequest_Life_Cycle__c(Id = reqdInputIdArray[0]);
                if (reqdInputIdArray[3] == System.Label.Related_Assessment_Type_1) {

                    tobeUpdatedASM.Related_Assignment_Manager1__c = tobeCreatedASM.Id;
                }else if (reqdInputIdArray[3] == System.Label.Related_Assessment_Type_2) {

                    tobeUpdatedASM.Related_Assignment_Manager2__c = tobeCreatedASM.Id;
                }else if (reqdInputIdArray[3] == System.Label.Related_Assessment_Type_3) {

                    tobeUpdatedASM.Related_Assignment_Manager3__c = tobeCreatedASM.Id;
                }else if (reqdInputIdArray[3] == System.Label.Related_Assessment_Type_4) {

                    tobeUpdatedASM.Related_Assignment_Manager4__c = tobeCreatedASM.Id;
                }
                
                List<String> fieldsListAMUpdate = new List<String>{'ExAM__Related_Assignment_Manager1__c','ExAM__Related_Assignment_Manager2__c',
                                                                'ExAM__Related_Assignment_Manager3__c','ExAM__Related_Assignment_Manager4__c'};
                accessAssMngr.assertAuthorizedToUpdate(Schema.getGlobalDescribe().get('exam__IssueRequest_Life_Cycle__c'), fieldsListAMUpdate);
                
                update tobeUpdatedASM;
                response = JSON.serialize( new SuccessClass('success', JSON.serialize(newManagerRecord)) );
                
            }catch(Exception exp) {

                string errType = exp.getTypeName();
                string errMsg = (exp.getTypeName() != 'System.DMLException') ? exp.getMessage() : exp.getDMLMessage(0);
                response = JSON.serialize( new ErrorClass(errType, errMsg) );
            }
        }
        return response;
    }

    @RemoteAction
    public static string createNewPrimaryAM(String primaryTemplateIdVal, String template_typeVal, String relatedmanageridVal, String assessableField_APIVal, String assessableRecordIdVal ) {
    
        if (primaryTemplateIdVal != null && primaryTemplateIdVal != ''
             && template_typeVal != null && template_typeVal != ''
             && relatedmanageridVal != null && relatedmanageridVal != '' 
        ) {
            
            IssueRequest_Life_Cycle__c primaryAM = new IssueRequest_Life_Cycle__c( InvestigationType__c = primaryTemplateIdVal);
            if (template_typeVal == 'Related_Assessment_Type_1') {
                primaryAM.Related_Assignment_Manager1__c = relatedmanageridVal;
            } else if (template_typeVal == 'Related_Assessment_Type_2') {
                primaryAM.Related_Assignment_Manager2__c = relatedmanageridVal;
            } else if (template_typeVal == 'Related_Assessment_Type_3') {
                primaryAM.Related_Assignment_Manager3__c = relatedmanageridVal;
            } else if (template_typeVal == 'Related_Assessment_Type_4') {
                primaryAM.Related_Assignment_Manager4__c = relatedmanageridVal;
            }
            
            if (assessableField_APIVal != null && assessableField_APIVal != '' && assessableRecordIdVal != null && assessableRecordIdVal != '') {
                primaryAM.put(assessableField_APIVal, assessableRecordIdVal);
            }            
            try {
            
                SFDCAccessController accessForAMCreate = ExAMUtilClass.AccessController;
                List<String> fieldsListAMCreate = new List<String>{'ExAM__Related_Assignment_Manager1__c','ExAM__Related_Assignment_Manager2__c',
                                                                'ExAM__Related_Assignment_Manager3__c','ExAM__Related_Assignment_Manager4__c'};
                accessForAMCreate.assertAuthorizedToCreate(Schema.getGlobalDescribe().get('exam__IssueRequest_Life_Cycle__c'), fieldsListAMCreate);
                    
                insert primaryAM;
                return JSON.serialize( new SuccessClass('success', primaryAM.Id) );
            } catch(Exception exp) {
                return JSON.serialize( new ErrorClass(exp.getTypeName(), (exp.getTypeName() != 'System.DMLException') ? exp.getMessage() : exp.getDMLMessage(0)) );
            }
        }
        return null;
    }
}