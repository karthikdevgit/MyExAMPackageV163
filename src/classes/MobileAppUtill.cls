public with sharing class MobileAppUtill {
    
    public static Map<Id,Id> updateAnsIdAndQuesIdMap = new Map<Id,Id>();
    public static Set<Id> quesIdSet = new Set<Id>();
    
    public class DecisionTreeResultClass {
       
        public Boolean hasEnabled;
        public Integer questionOrder;
        public string fieldLabelName;
        public string fieldAPIName;
        public string fieldType;
        public string templateId;
        public List<string> picklistValues;

        public DecisionTreeResultClass(string fieldLabel, string fieldAPI, string fieldType, List<string> pklstValuesList, Boolean enableField,string templateId,Integer questionOrder) {

            this.fieldLabelName = fieldLabel;
            this.fieldAPIName = fieldAPI;        
            this.fieldType = fieldType;
            this.picklistValues = pklstValuesList;        
            this.hasEnabled = enableField;
            this.templateId = templateId;
            this.questionOrder = questionOrder;
        }
    }
    
    public class AnswerWeightClass {
        public Id ASMId;
        public Map<Id, Integer> answerCount = new Map<Id, Integer>();
        public Set<Id> isAnsweredArray;
        public AnswerWeightClass(Id ASMId, Map<Id, Integer> answerCount, Set<Id> isAnsweredArray) {

            this.ASMId = ASMId;
            this.isAnsweredArray = isAnsweredArray;
            this.answerCount = answerCount;  
        }
    }
      
      
    public class attachmentClass { 
        public String name;
        public String contenttype;
        public String id;
        public Integer serialNum;
    }
  
    public class AnswerRecordClass {
        public String questiontemplateId;
        public String assignmentManagerId;
        public String response;
        public String comment;
        public String questionType;     
        public String attachmentId;     
        public Map<String,Boolean> multiselectObj;
        public Map<String,String> buttonQuestObj;
        public List<attachmentClass> attachmentMap;
        public Questionnaire_Response__c quesResponse;
    }
  
  
    public class FilteredSectionAndQuestionTemplateAndAnswerClass {       
        public List<AnswerRecordClass> answerRecord {get;set;}      
        public Map<Id,Id> quesIdANDAnsIdMap {get;set;}   
        public ErrorClass error;   
        public FilteredSectionAndQuestionTemplateAndAnswerClass (List<AnswerRecordClass> answer,Map<Id,Id> qIdAndAnsID,  ErrorClass e) {       
            this.answerRecord = answer;     
            this.quesIdANDAnsIdMap = qIdAndAnsID;   
            this.error = e;    
        }        
    }
    
    public class ErrorClass {
        public string errType{get; set;}
        public string errMsg{get; set;}

        public ErrorClass(string etype, string eMsg) {

            this.errType = etype;
            this.errMsg = eMsg;
        }
    }

    public class ErrorClass1 {
        public string errType { get; set; }
        public string errMsg { get; set; }
    }

    public class SuccessClass {
        public string code{get; set;}
        public string msg{get; set;}
        public IssueRequest_Life_Cycle__c savedAssignmentManager{get; set;}

        public SuccessClass(string sCode, string sMsg, IssueRequest_Life_Cycle__c savedAssignmentManager) {

            this.code = sCode;
            this.msg = sMsg;
            this.savedAssignmentManager = savedAssignmentManager;
        }
    }

    public class AnswerClass {
        public Questionnaire_Response__c answer { get; set; }
        public string hasAttached { get; set; }
    }

    public class AnswerDetails {
        public List<Schema.FieldSetMember> configuredAnswerFieldsJson;
        public List<Map<string,string>> resultConfiguredAnswerFieldsJson;
        public List<AnswerClass> answerList;
        public Map<string,Boolean> isUpdatableMap;
        public Map<string,Map<string,string>> picklistValuesMap;
    }
    
    public class AssesableObjectFieldset{
        public List<Schema.FieldSetMember> fieldSet;
        public Map<string,Boolean> isUpdatableMap;
        public Map<string,Map<string,string>> picklistValuesMap;
        public Boolean hasFieldset;
        public String asmLookup;
    }
    
    public class ASMAndAssesableObjectFieldset {

        public List<Schema.FieldSetMember> ASMFieldSet;
        public Map<string, Boolean> ASMIsUpdatableMap;
        public Map<string, Map<string,string>> ASMPicklistValuesMap;
        public Map<string, AssesableObjectFieldset> AssesableObjectFieldset;
        public List<ExAM__IssueRequest_Life_Cycle__c> ASMData;
    }  
    
    public class AccAndAccountFieldset {
        public List<Schema.FieldSetMember> ASMFieldSet;
        public List<Schema.FieldSetMember> ACCFieldSet;
        public Map<string,Boolean> ASMIsUpdatableMap;
        public Map<string,Boolean> ACCIsUpdatableMap;
        public Map<string,Map<string,string>> ASMPicklistValuesMap;
        public Map<string,Map<string,string>> ACCPicklistValuesMap;
        public List<IssueRequest_Life_Cycle__c> ASMData;
        
    }
    public static List<Questionnaire_Response__c> setAnswerWeight(List<Questionnaire_Response__c> ansList, Map<Id, Question_Template__c> quesIdwithQuestionMap) {
        
        List<Questionnaire_Response__c> answerList = new List<Questionnaire_Response__c>();

        for (Questionnaire_Response__c ans : ansList) {
            Id quesTempalteId;
            if (ans.Id != null && updateAnsIdAndQuesIdMap.containsKey(ans.Id) && updateAnsIdAndQuesIdMap.get(ans.Id) != null) {
                quesTempalteId = updateAnsIdAndQuesIdMap.get(ans.Id);
            }
            Questionnaire_Response__c answerRecord = new Questionnaire_Response__c();
            answerRecord = ans;
            //calculate answer weight 
            if(quesIdwithQuestionMap != null 
                && (ans.Question_Template__c != null && quesIdwithQuestionMap.containsKey(ans.Question_Template__c))
                    ||(quesTempalteId != null && quesIdwithQuestionMap.containsKey(quesTempalteId))
              ) {
                if ((ans.Question_Template__c != null && quesIdwithQuestionMap.get(ans.Question_Template__c).Answer_Options__r.size() == 0 )|| 
                     (quesTempalteId != null && quesIdwithQuestionMap.get(quesTempalteId).Answer_Options__r.size() == 0 )
                 ) {
                    
                    if (((ans.Question_Template__c != null && quesIdwithQuestionMap.get(ans.Question_Template__c).Weight_of_Answer__c != null
                          && quesIdwithQuestionMap.get(ans.Question_Template__c).Subquestion_Label__c != null)
                          || (quesTempalteId != null && quesIdwithQuestionMap.get(quesTempalteId).Weight_of_Answer__c != null
                          && quesIdwithQuestionMap.get(quesTempalteId).Subquestion_Label__c != null) )
                    ) {
                    
                        List<String> answerWeightList = new List<String>();
                        List<String> answerOptions = new List<String>();
                        
                        if(quesTempalteId != null) {
                            answerWeightList = trimAnswerOption(quesIdwithQuestionMap.get(quesTempalteId).Weight_of_Answer__c);
                            answerOptions = trimAnswerOption(quesIdwithQuestionMap.get(quesTempalteId).Subquestion_Label__c);
                        } else {
                            answerWeightList = trimAnswerOption(quesIdwithQuestionMap.get(ans.Question_Template__c).Weight_of_Answer__c);
                            answerOptions = trimAnswerOption(quesIdwithQuestionMap.get(ans.Question_Template__c).Subquestion_Label__c);
                        }
                        for (integer i = 0 ; i < answerOptions.size() ; i++) {
                            if (ans.Response__c.equalsIgnoreCase(answerOptions.get(i))) {
                                if ((ans.Response__c).equalsIgnoreCase('N/A') || (ans.Response__c).equalsIgnoreCase('NA')) {
                                    answerRecord.Weight_Response__c = -1;
                                } else if( answerWeightList != null && answerWeightList.size() > i ) {
                                    answerRecord.Weight_Response__c = Decimal.valueOf(answerWeightList.get(i).trim());
                                }
                            }
                        }                          
                    }
                } else {
                    
                    List<String> ansOptList = new List<String>();
                    List<String> ansWtList = new List<String>();
                    Id quesTempId;
                    if ( ans.Question_Template__c != null ){
                        quesTempId = ans.Question_Template__c;
                    } else if ( quesTempalteId != null ) {
                        quesTempId = quesTempalteId;
                    }
                    if ( quesTempId != null ){
                        for(Answer_Option__c ansOpt :quesIdwithQuestionMap.get(quesTempId).Answer_Options__r){
                            if( ansOpt != null && ansOpt.Weight__c != null && ansOpt.Name != null ){
                                ansWtList.add(String.valueOf(ansOpt.Weight__c));
                                ansOptList.add(ansOpt.Name);
                            }
                        }
                    }
                    if ( ansOptList.size() > 0 && ansWtList.size() > 0 ){
                        for (integer i = 0 ; i < ansOptList.size() ; i++) {
                            if (ans.Response__c.equalsIgnoreCase(ansOptList.get(i))) {
                                if ((ans.Response__c).equalsIgnoreCase('N/A') || (ans.Response__c).equalsIgnoreCase('NA')) {
                                    answerRecord.Weight_Response__c = -1;
                                } else if( ansWtList != null && ansWtList.size() > i ) {
                                    answerRecord.Weight_Response__c = Decimal.valueOf(ansWtList[i].trim()); 
                                }
                            }
                        }
                    }
                }
                answerList.add( answerRecord );
            }
        }
        return answerList;
    }
    
    /*
    public static List<ExAM__Questionnaire_Response__c> setAnswerWeight(List<ExAM__Questionnaire_Response__c> ansList, Map<Id, Question_Template__c> quesIdwithQuestionMap) {

        List<ExAM__Questionnaire_Response__c> answerList = new List<ExAM__Questionnaire_Response__c>();

        for (ExAM__Questionnaire_Response__c ans : ansList) {
            
            Id quesTempalteId;
            if (ans.Id != null && updateAnsIdAndQuesIdMap.containsKey(ans.Id) && updateAnsIdAndQuesIdMap.get(ans.Id) != null) {
                quesTempalteId = updateAnsIdAndQuesIdMap.get(ans.Id);
            }
            
            ExAM__Questionnaire_Response__c answerRecord = new ExAM__Questionnaire_Response__c();
            answerRecord = ans;
            //calculate answer weight
            if (string.isNotBlank(ans.Response__c) && quesIdwithQuestionMap != null
                    && quesIdwithQuestionMap.containsKey(ans.Question_Template__c)
                    && quesIdwithQuestionMap.get(ans.Question_Template__c).Weight_of_Answer__c != null
                    && quesIdwithQuestionMap.get(ans.Question_Template__c).Subquestion_Label__c != null
                    && ( quesIdwithQuestionMap.get(ans.Question_Template__c).Question_Type__c == 'RadioPicklist' ||
                         quesIdwithQuestionMap.get(ans.Question_Template__c).Question_Type__c == 'Dropdown Picklist' ||
                         quesIdwithQuestionMap.get(ans.Question_Template__c).Question_Type__c == 'Button' )
            ) {

                List<string> answerWeightList = quesIdwithQuestionMap.get(ans.Question_Template__c).Weight_of_Answer__c.split('~');

                List<string> answerOptions = quesIdwithQuestionMap.get(ans.Question_Template__c).Subquestion_Label__c.split('~');

                for (integer i = 0 ; i < answerOptions.size() ; i++) {
                    if (ans.Response__c.equalsIgnoreCase(answerOptions.get(i))) {
                        if ((ans.Response__c).equalsIgnoreCase('N/A') || (ans.Response__c).equalsIgnoreCase('NA')) {
                            answerRecord.Weight_Response__c = -1;
                        } else if( answerWeightList != null && answerWeightList.size() > i ) {
                            answerRecord.Weight_Response__c = Decimal.valueOf(answerWeightList.get(i).trim());
                        }
                    }
                }                          
            }
            answerList.add( answerRecord );
        }
        return answerList;
    } */
    
    public static string getAssignmentManagers(List<Id> templateIdList,string Type) {

        Map <string, Schema.SObjectField> answerFieldNameAPIMap = Schema.SObjectType.Questionnaire_Response__c.fields.getMap();
        Map <string, Schema.SObjectField> assignmentManagerFieldNameAPIMap = Schema.SObjectType.IssueRequest_Life_Cycle__c.fields.getMap();
        Map<string,string> assignmentManagerFieldAnswerFieldMap = new Map<string,string>();
        List<IssueRequest_Life_Cycle__c> childAssignmentManagersList = new List<IssueRequest_Life_Cycle__c> ();
            
        SFDCAccessController accessForobj = ExAMUtilClass.AccessController;
        List<string> fieldsList = new List<string>{'ExAM__Decision_Tree__c', 'ExAM__Hours__c', 'ExAM__Primary_Assessment_Type_Template__c','ExAM__Related_Assessment_Type_1_Template__c', 'ExAM__Related_Assessment_Type_2_Template__c', 'ExAM__Related_Assessment_Type_3_Template__c', 'ExAM__Related_Assessment_Type_4_Template__c','ExAM__Mobile_Sync_Additional_Templates__c','ExAM__Mobile_Sync_Assignment_Manager_Statuses__c','ExAM__Mobile_Sync_Last_X_Days__c'};
                      
        accessForobj.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__ExAM_Configuration__c'), fieldsList);

        List<ExAM_Configuration__c> examConfigurationList = new List<ExAM_Configuration__c>([
            SELECT CreatedDate, Decision_Tree__c, Hours__c, Id, Name, Primary_Assessment_Type_Template__c,
                   Related_Assessment_Type_1_Template__c, Related_Assessment_Type_2_Template__c,
                   Related_Assessment_Type_3_Template__c, Related_Assessment_Type_4_Template__c,
                   Mobile_Sync_Additional_Templates__c,Mobile_Sync_Assignment_Manager_Statuses__c,
                   Mobile_Sync_Last_X_Days__c
            FROM   ExAM_Configuration__c ORDER BY CreatedDate DESC LIMIT 1
        ]);
        Set<string> relatedAssessmentTemplateIdSet = new Set<string>();
        Set<string> ASMStatusSet = new Set<string>();
        string returnString = '';
            
        //Adding Templates In Configuration
        if (examConfigurationList != null && examConfigurationList.size() > 0) {
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
            if (examConfigurationList[0].Primary_Assessment_Type_Template__c != null) {
                relatedAssessmentTemplateIdSet.add(examConfigurationList[0].Primary_Assessment_Type_Template__c);
            }
            if(examConfigurationList[0].Mobile_Sync_Additional_Templates__c != null){

                string[] spiltString= examConfigurationList[0].Mobile_Sync_Additional_Templates__c.split('~');           
                for(string s: spiltString)
                {
                    if(s != null){
                        relatedAssessmentTemplateIdSet.add(s);
                    }
                }
            }
            if(examConfigurationList[0].Mobile_Sync_Assignment_Manager_Statuses__c != null){
                string[] spiltString= examConfigurationList[0].Mobile_Sync_Assignment_Manager_Statuses__c.split('~');           
                for(string s: spiltString)
                {
                    if(s != null){
                        ASMStatusSet.add(s);
                    }
                }
            }
        }
            for (Schema.SObjectField ansfield : answerFieldNameAPIMap.values()) {
    
                Schema.DescribeFieldResult res = ansfield.getdescribe();
    
                if (string.valueOf(res.getType()).touppercase() == 'REFERENCE' && res.isCustom() && res.getName().startsWithIgnoreCase('ANS_')) {
    
                    string assignmentManagerField = res.getName().replaceFirst('ANS_','AM_');
                    if (assignmentManagerFieldNameAPIMap.containsKey(assignmentManagerField.toLowerCase())) {
    
                        assignmentManagerFieldAnswerFieldMap.put( assignmentManagerFieldNameAPIMap.get(assignmentManagerField.toLowerCase()).getdescribe().getName() , res.getName());
                    }
                }
            }
            string amQuery = 'SELECT ExAM__Assignment_Manager__c,ExAM__Scheduled_End_Date__c, ExAM__Scheduled_Start_Date__c, ExAM__Status__c , ExAM__Priority__c , ExAM__Facility_Name__c,ExAM__Assessor_Resource__c, ExAM__Facility_Name__r.Name,ExAM__Facility_Name__r.ParentId, ExAM__Facility_Name__r.Parent.Name , Id, ExAM__InvestigationType__c, ExAM__Assessment_Template_Type__c ,ExAM__InvestigationType__r.Name,ExAM__InvestigationType__r.ExAM__Show_Image_Upload_Icon__c,ExAM__InvestigationType__r.ExAM__Show_Notes_Icon__c,ExAM__InvestigationType__r.ExAM__Show_Refresh_Icon__c,ExAM__InvestigationType__r.ExAM__Show_Question_Number__c, Name,CreatedDate';
    
            for (string assessableFieldapi : assignmentManagerFieldAnswerFieldMap.keySet()) {
                amQuery += ' ,'+assessableFieldapi;
            }
            if(type == 'Rest'){
                amQuery += ', ExAM__Total_Time_on_Assessment__c, ExAM__Related_Assignment_Manager1__c, ExAM__Related_Assignment_Manager1__r.Name,ExAM__Related_Assignment_Manager1__r.ExAM__Total_Time_on_Assessment__c, ExAM__Related_Assignment_Manager2__c,ExAM__Related_Assignment_Manager2__r.Name,ExAM__Related_Assignment_Manager2__r.ExAM__Total_Time_on_Assessment__c, ExAM__Related_Assignment_Manager3__c, ExAM__Related_Assignment_Manager3__r.Name, ExAM__Related_Assignment_Manager3__r.ExAM__Total_Time_on_Assessment__c, ExAM__Related_Assignment_Manager4__c, ExAM__Related_Assignment_Manager4__r.Name, ExAM__Related_Assignment_Manager4__r.ExAM__Total_Time_on_Assessment__c FROM ExAM__IssueRequest_Life_Cycle__c';
                if(relatedAssessmentTemplateIdSet.size() > 0){
                     amQuery += ' WHERE  ExAM__InvestigationType__c IN : relatedAssessmentTemplateIdSet';
                }
                if(ASMStatusSet.size() > 0){
                    amQuery += ' AND ExAM__Status__c IN: ASMStatusSet';
                }
                if (examConfigurationList != null && examConfigurationList.size() > 0) {
                    if(examConfigurationList[0].Mobile_Sync_Last_X_Days__c != null){
                        amQuery += ' AND ExAM__Scheduled_Start_Date__c = LAST_N_DAYS : '+ examConfigurationList[0].Mobile_Sync_Last_X_Days__c;
                    }
                }
                returnString = amQuery;
            }else{
                amQuery += ' FROM ExAM__IssueRequest_Life_Cycle__c WHERE  Id IN : templateIdList AND ExAM__InvestigationType__c != null LIMIT 1';
            }
    
                Map<string,string> customLabelMap = new Map<string,string>();
                customLabelMap.put('Primary_Assessment_Type',Label.Primary_Assessment_Type);
                customLabelMap.put('Related_Assessment_Type_1',Label.Related_Assessment_Type_1);
                customLabelMap.put('Related_Assessment_Type_2',Label.Related_Assessment_Type_2);
                customLabelMap.put('Related_Assessment_Type_3',Label.Related_Assessment_Type_3);
                customLabelMap.put('Related_Assessment_Type_4',Label.Related_Assessment_Type_4);
                customLabelMap.put('Related_Decision_Tree_Chain_Button',Label.Related_Decision_Tree_Chain_Button);
                customLabelMap.put('Assessable_Record_Tab_Name',Label.Assessable_Record_Tab_Name);
                
                SFDCAccessController accessForobj2 = ExAMUtilClass.AccessController;
                List<string> fieldsList2 = new List<string>{'ExAM__Assignment_Manager__c','ExAM__Scheduled_End_Date__c', 'ExAM__Scheduled_Start_Date__c', 'ExAM__Status__c' , 'ExAM__Priority__c' , 'ExAM__Facility_Name__c','ExAM__Assessor_Resource__c','ExAM__InvestigationType__c', 'ExAM__Assessment_Template_Type__c'};
                          
                accessForobj2.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__IssueRequest_Life_Cycle__c'), fieldsList2);
                
                SFDCAccessController accessForobj1 = ExAMUtilClass.AccessController;
                List<string> fieldsList1 = new List<string>{'ExAM__Show_Image_Upload_Icon__c','ExAM__Show_Notes_Icon__c','ExAM__Show_Refresh_Icon__c','ExAM__Show_Question_Number__c' };
                accessForobj1.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Main_questionaire__c'), fieldsList1);
                childAssignmentManagersList = Database.Query(amQuery);
                returnString = JSON.serialize(childAssignmentManagersList) + '`' + JSON.serialize(customLabelMap) + '`' + JSON.serialize(assignmentManagerFieldAnswerFieldMap.keySet());

    
            return returnString;
    }
    //List<string> templateIdList
    public static string getAssignmentManagersNew(List<Id> templateIdList,string Type) {
            
        Map <string, Schema.SObjectField> assignmentManagerFieldNameAPIMap = Schema.SObjectType.IssueRequest_Life_Cycle__c.fields.getMap();
        Map<string,string> assignmentManagerFieldAnswerFieldMap = new Map<string,string>();
        List<IssueRequest_Life_Cycle__c> childAssignmentManagersList = new List<IssueRequest_Life_Cycle__c> ();
        
        SFDCAccessController accessForobj = ExAMUtilClass.AccessController;
        List<string> fieldsList = new List<string>{'ExAM__Decision_Tree__c', 'ExAM__Hours__c', 'ExAM__Primary_Assessment_Type_Template__c',
                                        'ExAM__Related_Assessment_Type_1_Template__c', 'ExAM__Related_Assessment_Type_2_Template__c', 
                                        'ExAM__Related_Assessment_Type_3_Template__c', 'ExAM__Related_Assessment_Type_4_Template__c',
                                        'ExAM__Mobile_Sync_Additional_Templates__c','ExAM__Mobile_Sync_Assignment_Manager_Statuses__c',
                                        'ExAM__Mobile_Sync_Last_X_Days__c', 'ExAM__Mobile_Sync_Future_X_Days__c'};
                  
        accessForobj.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__ExAM_Configuration__c'), fieldsList);
        List<ExAM_Configuration__c> examConfigurationList = new List<ExAM_Configuration__c>([
            SELECT CreatedDate, Decision_Tree__c, Hours__c, Id, Name, Primary_Assessment_Type_Template__c,
                   Related_Assessment_Type_1_Template__c, Related_Assessment_Type_2_Template__c,
                   Related_Assessment_Type_3_Template__c, Related_Assessment_Type_4_Template__c,
                   Mobile_Sync_Additional_Templates__c,Mobile_Sync_Assignment_Manager_Statuses__c,
                   Mobile_Sync_Last_X_Days__c, Mobile_Sync_Future_X_Days__c
            FROM ExAM_Configuration__c ORDER BY CreatedDate DESC LIMIT 1
        ]);
        Set<string> relatedAssessmentTemplateIdSet = new Set<string>();
        Set<string> ASMStatusSet = new Set<string>();
        string returnString = '';
        
        //Adding Templates In Configuration
        if (examConfigurationList != null && examConfigurationList.size() > 0) {
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
            if (examConfigurationList[0].Primary_Assessment_Type_Template__c != null) {
                relatedAssessmentTemplateIdSet.add(examConfigurationList[0].Primary_Assessment_Type_Template__c);
            }
            if(examConfigurationList[0].Mobile_Sync_Additional_Templates__c != null){
            
                string[] spiltString= examConfigurationList[0].Mobile_Sync_Additional_Templates__c.split('~');           
                for(string s: spiltString)
                {
                    if(s != null){
                        relatedAssessmentTemplateIdSet.add(s);
                    }
                }
            }
            if(examConfigurationList[0].Mobile_Sync_Assignment_Manager_Statuses__c != null){
                string[] spiltString= examConfigurationList[0].Mobile_Sync_Assignment_Manager_Statuses__c.split('~');           
                for(string s: spiltString)
                {
                    if(s != null){
                        ASMStatusSet.add(s);
                    }
                }
            }
        }
        string amQuery = 'SELECT ExAM__Assignment_Manager__c,ExAM__Scheduled_End_Date__c, ExAM__Scheduled_Start_Date__c, ExAM__Status__c , ExAM__Priority__c ,ExAM__Assessor_Resource__c, Id, ExAM__InvestigationType__c, ExAM__Assessment_Template_Type__c ,ExAM__InvestigationType__r.Name, Name,CreatedDate';
    
        ExAMUtilClass.AssessableObjectDetails assObjWrapperInstance = new ExAMUtilClass.AssessableObjectDetails();
        assObjWrapperInstance = ExAMUtilClass.getAssessableObjectDetails('ExAM__IssueRequest_Life_Cycle__c');
        
        for (string assessableFieldapi : assObjWrapperInstance.assessableObjectChildRelationshipMap.keySet()) {
            amQuery += ' ,'+assessableFieldapi;
            //Adding Assesable object and parent relationship fields to Assignment Manager
            String lookupFieldString = assObjWrapperInstance.assessableObjectChildRelationshipMap.get(assessableFieldapi);
            if(assessableFieldapi.contains('Case')){
                amQuery += ' ,'+lookupFieldString+'.CaseNumber';
                amQuery += ' ,'+lookupFieldString+'.ParentId';
                amQuery += ' ,'+lookupFieldString+'.Parent.CaseNumber';
            } else if (assessableFieldapi.contains('Facility')){
                amQuery += ' ,'+lookupFieldString+'.Name';
                amQuery += ' ,'+lookupFieldString+'.ParentId';
                amQuery += ' ,'+lookupFieldString+'.Parent.Name';
            } else {
                if (assessableFieldapi.contains('Lead') || assessableFieldapi.contains('Contact')){
                    amQuery += ' ,'+lookupFieldString+'.LastName';
                }else{
                    amQuery += ' ,'+lookupFieldString+'.Name';
                }
                Map<string, string> referenceMap = new Map<string, string>();
                String assesableObjectApiName = assObjWrapperInstance.assessableObjectAPIMap.get(assessableFieldapi);
                referenceMap = ExAMUtilClass.getParentReferenceMapFromSobject(assesableObjectApiName);
                if(referenceMap.size() > 0){
                    amQuery += ' ,'+lookupFieldString+'.'+referenceMap.get(assesableObjectApiName).substringBefore('__c')+'__r.Name';
                }
            }
        }
       
        if(type == 'Rest'){
            amQuery += ', ExAM__Total_Time_on_Assessment__c, ExAM__Related_Assignment_Manager1__c, ExAM__Related_Assignment_Manager1__r.Name,ExAM__Related_Assignment_Manager1__r.ExAM__Total_Time_on_Assessment__c, ExAM__Related_Assignment_Manager2__c,ExAM__Related_Assignment_Manager2__r.Name,ExAM__Related_Assignment_Manager2__r.ExAM__Total_Time_on_Assessment__c, ExAM__Related_Assignment_Manager3__c, ExAM__Related_Assignment_Manager3__r.Name, ExAM__Related_Assignment_Manager3__r.ExAM__Total_Time_on_Assessment__c, ExAM__Related_Assignment_Manager4__c, ExAM__Related_Assignment_Manager4__r.Name, ExAM__Related_Assignment_Manager4__r.ExAM__Total_Time_on_Assessment__c FROM ExAM__IssueRequest_Life_Cycle__c';
            if(relatedAssessmentTemplateIdSet.size() > 0){
                 amQuery += ' WHERE  ExAM__InvestigationType__c IN : relatedAssessmentTemplateIdSet';
            }
            
            if(ASMStatusSet.size() > 0){
                amQuery += ' AND ExAM__Status__c IN: ASMStatusSet';
            }
            if (examConfigurationList != null && examConfigurationList.size() > 0) {
                if(examConfigurationList[0].ExAM__Mobile_Sync_Last_X_Days__c != null && examConfigurationList[0].ExAM__Mobile_Sync_Future_X_Days__c != null){
                    amQuery += ' AND (ExAM__Scheduled_Start_Date__c = LAST_N_DAYS : '+ examConfigurationList[0].ExAM__Mobile_Sync_Last_X_Days__c + 'OR ExAM__Scheduled_Start_Date__c = NEXT_N_DAYS : '+ examConfigurationList[0].ExAM__Mobile_Sync_Future_X_Days__c+')';
                }else if(examConfigurationList[0].ExAM__Mobile_Sync_Future_X_Days__c != null){
                    amQuery +=  ' AND ExAM__Scheduled_Start_Date__c = NEXT_N_DAYS : '+ examConfigurationList[0].ExAM__Mobile_Sync_Future_X_Days__c;
                }else if(examConfigurationList[0].ExAM__Mobile_Sync_Last_X_Days__c != null){
                    amQuery +=  ' AND ExAM__Scheduled_Start_Date__c = LAST_N_DAYS : '+ examConfigurationList[0].ExAM__Mobile_Sync_Last_X_Days__c;
                }
            } 
            
        }else{
            amQuery += ' FROM ExAM__IssueRequest_Life_Cycle__c WHERE  Id IN : templateIdList AND ExAM__InvestigationType__c != null LIMIT 1';
        }
    
        amQuery += ' ORDER BY CreatedDate DESC';
        SFDCAccessController accessForobj2 = ExAMUtilClass.AccessController;
        List<string> fieldsList2 = new List<string>{'ExAM__Assignment_Manager__c','ExAM__Scheduled_End_Date__c', 'ExAM__Scheduled_Start_Date__c', 
                                                    'ExAM__Status__c' , 'ExAM__Priority__c' , 'ExAM__Facility_Name__c','ExAM__Assessor_Resource__c',
                                                    'ExAM__InvestigationType__c', 'ExAM__Assessment_Template_Type__c'};
                  
        accessForobj2.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__IssueRequest_Life_Cycle__c'), fieldsList2);
        
        SFDCAccessController accessForobj1 = ExAMUtilClass.AccessController;
        List<string> fieldsList1 = new List<string>{'ExAM__Show_Image_Upload_Icon__c','ExAM__Show_Notes_Icon__c','ExAM__Show_Refresh_Icon__c','ExAM__Show_Question_Number__c' };
        accessForobj1.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Main_questionaire__c'), fieldsList1);
        System.debug('::::::::::::amQuery:::::::::'+amQuery);
        childAssignmentManagersList = Database.Query(amQuery);
        System.debug(':::::childAssignmentManagersList::::'+childAssignmentManagersList);
        returnString = JSON.serialize(childAssignmentManagersList);
        
        return returnString;

    }

    public static string getDecisionTree(List<string> templateIdList) {

        string decisionTreeResultStr = '';
        Set<Id> templateIdSet = new Set<Id>();
        List<DecisionTreeResultClass> decisionTreeResultList = new List<DecisionTreeResultClass>();
        SFDCAccessController accessForobj = ExAMUtilClass.AccessController;
        if(templateIdList != null && templateIdList.size() > 0){
             List<string> fieldList = new List<string> {'ExAM__Decision_Tree__c'};              
             accessForobj.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Main_questionaire__c'), fieldList);
             for(Main_questionaire__c template : [SELECT Decision_Tree__c, Id, Name FROM Main_questionaire__c WHERE Id IN :templateIdList]) {
                Boolean isPictureConfig = false;
                string fields = '';

                List<ExAM_Configuration__c> configRecordList = new List<ExAM_Configuration__c>();
                Set<string> fieldSet = new Set<string>();
                Map<string, string> fieldApiNameAndValueMap = new Map<string, string>();
                Map<string, string> fieldOrderMap = new Map<string, string>();
                if (string.isNotBlank(template.Id) ) {

                    if (template != null) {

                        if (string.isNotBlank(template.Decision_Tree__c ) ) {

                            List<string> fieldListTemp = new List<string>();

                            if (template.Decision_Tree__c.contains('~')) {

                                fieldListTemp = template.Decision_Tree__c.split('~');
                            }
                            else {

                                fieldListTemp.add( template.Decision_Tree__c );
                            }
                            for(string f : fieldListTemp) {

                                string fieldApiName = f.split(':')[0];
                                string hasEnabled;
                                if(string.isNotBlank(f.split(':')[1]) && f.split(':')[1] == 'true'){
                                    if(string.isNotBlank(f.split(':')[2]) && f.split(':')[2] == 'true'){
                                        hasEnabled = 'false';
                                    }else{
                                        hasEnabled = 'true';
                                    }
                                }else{
                                    hasEnabled = 'false';
                                }
                                string questionOrder = '0';
                                List<string> orderList = new List<string>();
                                orderList = f.split(':');
                                if(orderList.size() >= 4){
                                    if(string.isNotBlank(f.split(':')[3])){
                                        questionOrder = f.split(':')[3];
                                    } 
                                }
                                if (fieldApiName == 'Pictures'){
                                    fieldOrderMap.put( fieldApiName , questionOrder );
                                }else{
                                    fieldOrderMap.put(fieldApiName.toLowerCase() , questionOrder);
                                }
                                

                                if (fieldApiName != 'Pictures' && fieldApiName.contains('__c')) {
                                    fieldApiNameAndValueMap.put(fieldApiName.toLowerCase(), hasEnabled);
                                } else if (fieldApiName == 'Pictures') {
                                    isPictureConfig = true;
                                    fieldApiNameAndValueMap.put(fieldApiName, hasEnabled);
                                }
                            }

                            Map <string, Schema.SObjectField> answerFieldNameAPIMap = Schema.SObjectType.Questionnaire_Response__c.fields.getMap();
                            for (string ansStr : answerFieldNameAPIMap.keySet()) {

                                Schema.SObjectField ansfield = answerFieldNameAPIMap.get(ansStr);
                                if (fieldApiNameAndValueMap != null && fieldApiNameAndValueMap.containsKey(ansStr.toLowerCase())) {    
                                    
                                    Schema.DescribeFieldResult res = ansfield.getdescribe();
                                    List<string> picklistvalueTempList = new List<string>();
                                    if (res.getType() == Schema.DisplayType.pickList) {

                                        List<Schema.PicklistEntry> ple = res.getPicklistValues();                        
                                        for( Schema.PicklistEntry f : ple) {
                                            picklistvalueTempList.add(f.getValue());
                                        }       
                                    }
                                    decisionTreeResultList.add(
                                        new DecisionTreeResultClass(
                                            res.getLabel(),
                                            res.getName().toLowerCase(),
                                            res.getType().name(),
                                            picklistvalueTempList,
                                            Boolean.valueOf( fieldApiNameAndValueMap.get(ansStr.toLowerCase()) ),
                                            template.Id,
                                            Integer.valueof( fieldOrderMap.get(ansStr.toLowerCase()) )
                                        )
                                    );
                                }// end if fieldSet contains the api name of current field in iteration
                            }// end answerFieldNameAPIMap fields map iteration

                            if (isPictureConfig) {
                                decisionTreeResultList.add(
                                    new DecisionTreeResultClass(
                                        'Picture',
                                        '',
                                        'PICTURE',
                                        new List<string>(),
                                        Boolean.valueOf( fieldApiNameAndValueMap.get('Pictures') ),
                                        template.Id,
                                        Integer.valueof( fieldOrderMap.get('Pictures') )
                                    )
                                );
                            }
                        }// end if Decision Tree in Templatae not blank codn check
                    }// end if template size check
                }// end if template.Id not blank codn check

             }
             decisionTreeResultStr = JSON.serialize(decisionTreeResultList);
        }else{
            decisionTreeResultStr = 'No Template Id';
        }
        return decisionTreeResultStr;

    }
    
    //Added on 20-07-2017 for delete decision tree old path by one time assessment
    public class DecisionTreeResponseClass {
        public List<Questionnaire_Response__c> dtResponseList;
        public Boolean oneTimeAss;
        public String startQuestion;
        public String templateId;
    }
    
    public static string saveDecisionTreeAnswerRecordsNew(RestSaveDecisionTreeAnswerRecordsNew.DecisionTreeResponseClass decisionTreeAnsListObj) {

        string resultMsg = 'DecisionTree Answer have not save';
        Map<Id, Id> questionIdwithansIdMap = new Map<Id, Id>();
        
        //Added on 20-07-2017 for delete decision tree old path by one time assessment
        List<Questionnaire_Response__c> decisionTreeAnsList = new List<Questionnaire_Response__c>();
        Boolean oneTimeAssess;
        String startQuestion = '';
        Id templateId;
          try {  
            //Added on 20-07-2017 for delete decision tree old path by one time assessment
            RestSaveDecisionTreeAnswerRecordsNew.DecisionTreeResponseClass dTRes = new RestSaveDecisionTreeAnswerRecordsNew.DecisionTreeResponseClass();
            dTRes = decisionTreeAnsListObj;
            System.debug('dTRes:::'+dTRes);
            decisionTreeAnsList = dTRes.dtResponseList;
            oneTimeAssess = dTRes.oneTimeAss;
            startQuestion = dTRes.startQuestion;
            templateId = Id.valueOf(dTRes.templateId);

            if (decisionTreeAnsList != null && decisionTreeAnsList.size() > 0) {
                Map<Id, Questionnaire_Response__c> questionIdwithAnswerMap = new Map<Id, Questionnaire_Response__c>();
                for (Questionnaire_Response__c ans : decisionTreeAnsList ) {
                    questionIdwithAnswerMap.put(ans.Question_Template__c, ans);
                }
                SFDCAccessController accessForobj = ExAMUtilClass.AccessController;
                List<string> fieldsList = new List<string>{'ExAM__Do_Not_Create_Answer__c'};
                accessForobj.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Question_Template__c'), fieldsList);
                
                for (Question_Template__c questionTemp : [SELECT Id, Do_Not_Create_Answer__c from Question_Template__c WHERE Id IN:questionIdwithAnswerMap.keySet() AND Do_Not_Create_Answer__c = true]) {
                    questionIdwithAnswerMap.remove(questionTemp.Id);             
                }
                Map<Id, Question_Template__c> quesIdwithQuestionMap = new Map<Id, Question_Template__c>([
                    SELECT Id, Subquestion_Label__c, Weight_of_Answer__c, HelpText__c, Section_Question__c,
                           Section_Question__r.Questionnaire_Section__c, Question_Label__c, Question_Order_No__c,
                           Question_Type__c, Do_Not_Create_Answer__c,
                           (SELECT Id,Name,Help_Text__c,Weight__c,Dependent_Question__r.Name,Next_Question__r.Name FROM Answer_Options__r ORDER BY Order_No__c ASC)
                    FROM   Question_Template__c 
                    WHERE  Id IN:questionIdwithAnswerMap.keySet()
                    ORDER BY Question_Order_No__c ASC NULLS LAST
                ]);
                
                if (questionIdwithAnswerMap != null && questionIdwithAnswerMap.size() > 0) {
                    decisionTreeAnsList = setAnswerWeight(questionIdwithAnswerMap.values(), quesIdwithQuestionMap);
                    
                    //Added on 20-07-2017 for delete decision tree old path by one time assessment
                  /*  if ( oneTimeAssess ){
                        
                        String resMsg = deleteOldDecisionTreePath(startQuestion,templateId);
                        if( resMsg != null && resMsg != '' && resMsg != 'Success' ){
                            return resMsg;
                        }else if ( resMsg == null || resMsg == '' ){
                            resMsg = 'Cant delete Answer records.';
                        }
                    }
                    */
                    SFDCAccessController accessForSSupsert = ExAMUtilClass.AccessController;
                    List<string> fieldsListSSupsert = new List<string>{'ExAM__Question_Template__c', 'ExAM__Questionnaire_Taker_user__c', 'ExAM__Comment__c','Exam__Issue_Request__c', 'ExAM__Response__c'};
                    accessForSSupsert.assertAuthorizedToCreate(Schema.getGlobalDescribe().get('exam__Questionnaire_Response__c'), fieldsListSSupsert);
                    
                    //decisionTreeAnsList = questionIdwithAnswerMap.values();
                    upsert decisionTreeAnsList;
                    resultMsg = 'Decision tree answer have saved successfully';

                    for (Questionnaire_Response__c res : decisionTreeAnsList) {
                        questionIdwithansIdMap.put(res.Question_Template__c, res.Id);
                    }
                    resultMsg = JSON.serialize(questionIdwithansIdMap);
                }
                else {
                    resultMsg = JSON.serialize( new ErrorClass('AnswerNotCreated', 'No Answers created since all answered Decision tree questions has Do Not Create Answer flag checked') );
                }
            }
        } catch(Exception exp) {      
            resultMsg = JSON.serialize( new ErrorClass(exp.getTypeName(), (exp.getTypeName() != 'System.DMLException') ? exp.getMessage() : exp.getDMLMessage(0)) );        
        }
        return resultMsg;
    }

    public static string saveDecisionTreeAnswerRecords(List<Questionnaire_Response__c> decisionTreeAnsList) {

        string resultMsg = 'DecisionTree Answer have not save';
        Map<Id, Id> questionIdwithansIdMap = new Map<Id, Id>();
          try {  
            if (decisionTreeAnsList != null && decisionTreeAnsList.size() > 0) {
                Map<Id, Questionnaire_Response__c> questionIdwithAnswerMap = new Map<Id, Questionnaire_Response__c>();
                for (Questionnaire_Response__c ans : decisionTreeAnsList ) {
                    questionIdwithAnswerMap.put(ans.Question_Template__c, ans);
                }
                SFDCAccessController accessForobj = ExAMUtilClass.AccessController;
                List<string> fieldsList = new List<string>{'ExAM__Do_Not_Create_Answer__c'};
                accessForobj.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Question_Template__c'), fieldsList);
                
                for (Question_Template__c questionTemp : [SELECT Id, Do_Not_Create_Answer__c from Question_Template__c WHERE Id IN:questionIdwithAnswerMap.keySet() AND Do_Not_Create_Answer__c = true]) {
                    questionIdwithAnswerMap.remove(questionTemp.Id);             
                }
                if (questionIdwithAnswerMap != null && questionIdwithAnswerMap.size() > 0) {
                    SFDCAccessController accessForSSupsert = ExAMUtilClass.AccessController;
                    List<string> fieldsListSSupsert = new List<string>{'ExAM__Question_Template__c', 'ExAM__Questionnaire_Taker_user__c', 'ExAM__Comment__c','Exam__Issue_Request__c', 'ExAM__Response__c'};
                    accessForSSupsert.assertAuthorizedToCreate(Schema.getGlobalDescribe().get('exam__Questionnaire_Response__c'), fieldsListSSupsert);
                    decisionTreeAnsList = questionIdwithAnswerMap.values();
                    insert decisionTreeAnsList;
                    resultMsg = 'Decision tree answer have saved successfully';

                    for (Questionnaire_Response__c res : decisionTreeAnsList) {
                        questionIdwithansIdMap.put(res.Question_Template__c, res.Id);
                    }
                    resultMsg = JSON.serialize(questionIdwithansIdMap);
                }
                else {
                    resultMsg = JSON.serialize( new ErrorClass('AnswerNotCreated', 'No Answers created since all answered Decision tree questions has Do Not Create Answer flag checked') );
                }
            }
        } catch(Exception exp) {      
            resultMsg = JSON.serialize( new ErrorClass(exp.getTypeName(), (exp.getTypeName() != 'System.DMLException') ? exp.getMessage() : exp.getDMLMessage(0)) );        
        }
        return resultMsg;
    }

    public static string saveAnswerRecords(List<RestSaveAnswerRecords.AnswerRecordClass> answerList, string tempId, string assignmentId, Boolean isSubmit,string totalAssesmentTime, Map<Id,Id> quesIdANDAnsIdMap) {

        string resultMsg = '';    
            try{   
                Map<Id, Questionnaire_Response__c> questionIdwithexistingAnswerMap = new Map<Id, Questionnaire_Response__c>();
                List<Questionnaire_Response__c> upsertAnswerList = new List<Questionnaire_Response__c>();
                Map<Id, Question_Template__c> quesIdwithQuestionMap = new Map<Id, Question_Template__c>();
                Map <string, Schema.SObjectField> answerFieldNameAPIMap = Schema.SObjectType.Questionnaire_Response__c.fields.getMap();
                Map <string, Schema.SObjectField> assignmentManagerFieldNameAPIMap = Schema.SObjectType.IssueRequest_Life_Cycle__c.fields.getMap();
                Map<string,string> assignmentManagerFieldAnswerFieldMap = new Map<string,string>();
        
                string hierarchyfieldAPIName = '';
                
                if (answerList != null && answerList.size() > 0) {
        
                    if ( assignmentId != null && assignmentId != '') {
                        
                        SFDCAccessController accessForobj = ExAMUtilClass.AccessController;
                        List<string> fieldsList = new List<string>{'ExAM__Question_Template__c','ExAM__Issue_Request__c'};
                        accessForobj.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Questionnaire_Response__c'), fieldsList);
                        for (Questionnaire_Response__c res : [SELECT Id, Question_Template__c, Issue_Request__c FROM Questionnaire_Response__c WHERE Issue_Request__c =:assignmentId]) {
                            questionIdwithexistingAnswerMap.put(res.Question_Template__c, res);
                        }
                    }
                    
                   SFDCAccessController accessForobj = ExAMUtilClass.AccessController;
                   List<string> fieldsList = new List<string>{'ExAM__Subquestion_Label__c', 'ExAM__Weight_of_Answer__c', 'ExAM__HelpText__c', 'ExAM__Section_Question__c','ExAM__Question_Label__c', 'ExAM__Question_Order_No__c','ExAM__Question_Type__c', 'ExAM__Do_Not_Create_Answer__c'};
                   accessForobj.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Question_Template__c'), fieldsList);
        
                    if (tempId != null && tempId != '') {            
                        quesIdwithQuestionMap = new Map<Id, Question_Template__c>([
                            SELECT Id, Subquestion_Label__c, Weight_of_Answer__c, HelpText__c, Section_Question__c,
                                   Section_Question__r.Questionnaire_Section__c, Question_Label__c, Question_Order_No__c,
                                   Question_Type__c, Do_Not_Create_Answer__c
                            FROM   Question_Template__c
                            WHERE  Section_Question__r.Questionnaire_Section__c =:tempId
                            ORDER BY Question_Order_No__c ASC NULLS LAST
                        ]);
                    }
                    system.debug(':::::tempId::::::'+tempId);
                    List<Questionnaire_Response__c> answerList2 = new List<Questionnaire_Response__c >();
                    
                    for (RestSaveAnswerRecords.AnswerRecordClass anscls : answerList) {
                        if (quesIdwithQuestionMap != null && quesIdwithQuestionMap.size() > 0 && quesIdwithQuestionMap.containskey(anscls.questiontemplateId) && !quesIdwithQuestionMap.get(anscls.questiontemplateId).Do_Not_Create_Answer__c) {
                            
                            Questionnaire_Response__c ans = new Questionnaire_Response__c();
                            Set<Id> quesIdSet = new Set<Id>();
                            system.debug(':::quesIdANDAnsIdMap::::'+quesIdANDAnsIdMap);
                            system.debug(':::anscls::::'+anscls);
                            if(quesIdANDAnsIdMap != null && quesIdANDAnsIdMap.size() > 0 && quesIdANDAnsIdMap.containsKey(anscls.questiontemplateId)) {
                                system.debug(':::::if::::');
                                ans.Id = quesIdANDAnsIdMap.get(anscls.questiontemplateId);  
                                updateAnsIdAndQuesIdMap.put(quesIdANDAnsIdMap.get(anscls.questiontemplateId),anscls.questiontemplateId);       
                            } else {        
                                ans.Question_Template__c = anscls.questiontemplateId;  
                            }
                            quesIdSet.add(anscls.questiontemplateId);
                            
                            //ans.Question_Template__c = anscls.questiontemplateId;
                            ans.Issue_Request__c = anscls.assignmentManagerId;
                            ans.Response__c = anscls.response;
                            ans.Comment__c = anscls.comment;
                            ans.Questionnaire_Taker_user__c = UserInfo.getUserId();
                            upsertAnswerList.add(ans);
                        }
                    }
                    system.debug('::::::::::::::before:upsertAnswerList::::'+upsertAnswerList);
                    upsertAnswerList = setAnswerWeight(upsertAnswerList, quesIdwithQuestionMap);
                    system.debug('::::::::::::::after:upsertAnswerList::::'+upsertAnswerList);
    
                        if (isSubmit && assignmentId != null && assignmentId != '') {
                            List<string> fieldList = new List<string> {'ExAM__Overall_Status_on_Submit__c'};
                            accessForobj.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__ExAM_Configuration__c'), fieldList);
                            List<ExAM_Configuration__c> configList = [SELECT Overall_Status_on_Submit__c, Id FROM ExAM_Configuration__c WHERE Overall_Status_on_Submit__c != null ORDER BY CreatedDate DESC LIMIT 1];
                            
                             
                            if (configList != null && configList.size() > 0) {
                                List<string> updatefieldList = new List<string> {'ExAM__Field_End_Time__c', 'ExAM__Status__c', 'ExAM__Total_Time_on_Assessment__c'};
                                accessForobj.assertAuthorizedToUpdate(Schema.getGlobalDescribe().get('exam__IssueRequest_Life_Cycle__c'), updatefieldList );
                                IssueRequest_Life_Cycle__c amUpdate = new IssueRequest_Life_Cycle__c(Field_End_Time__c = System.now(), Id = Id.valueOf(assignmentId), Status__c = configList[0].Overall_Status_on_Submit__c, Total_Time_on_Assessment__c = totalAssesmentTime); // update answer submit time in "End time" 01-07-2016
                                upsert amUpdate;
                            }
                        }
                        
                        if (upsertAnswerList != null && upsertAnswerList.size() > 0) {
                            SFDCAccessController accessForSSupsert = ExAMUtilClass.AccessController;
                            List<string> fieldsListSSupsert = new List<string>{'ExAM__Question_Template__c', 'ExAM__Questionnaire_Taker_user__c', 'ExAM__Comment__c','Exam__Issue_Request__c', 'ExAM__Response__c'};
                            accessForSSupsert.assertAuthorizedToCreate(Schema.getGlobalDescribe().get('exam__Questionnaire_Response__c'), fieldsListSSupsert);
                            upsert upsertAnswerList;
        
                            Map<Id,List<Id>> quesIdwithAnsIdMap = new Map<Id, List<Id>>();    
                            system.debug(':::::assignmentId:'+assignmentId);
                            system.debug(':::::quesIdSet:'+quesIdSet);
                            
                            String upsertAnsQuery = 'SELECT Id, Name, ExAM__Question_Template__c FROM ExAM__Questionnaire_Response__c WHERE ExAM__Issue_Request__c =:assignmentId AND ExAM__Question_Template__c IN :quesIdSet  ORDER BY LastModifiedDate DESC';
                            system.debug(':::::upsertAnsQuery:'+upsertAnsQuery);
                            for (Questionnaire_Response__c ans : Database.Query(upsertAnsQuery)) {
                                system.debug(':::upsertAnswerList::::'+ans); 
                                if (!quesIdwithAnsIdMap.containskey(ans.Question_Template__c)) {
                                    quesIdwithAnsIdMap.put(ans.Question_Template__c, new List<Id>());
                                }
                                quesIdwithAnsIdMap.get(ans.Question_Template__c).add(ans.Id);
                            }
                            resultMsg = JSON.serialize(quesIdwithAnsIdMap);
                        }
                        if ((answerList != null && answerList.size() > 0) && upsertAnswerList.size() == 0) {
                            resultMsg = JSON.serialize( new ErrorClass('AnswerNotCreated', 'No Answers created since all answered questions has Do Not Create Answer flag checked') );
                        }
    
                }else {
                    
                    if (isSubmit && assignmentId != null && assignmentId != '') {
                        
                        List<ExAM_Configuration__c> configList = [SELECT Overall_Status_on_Submit__c, Id FROM ExAM_Configuration__c WHERE Overall_Status_on_Submit__c != null ORDER BY CreatedDate DESC LIMIT 1];
                        string tempStatus;
                        if (configList != null && configList.size() > 0 && configList[0].Overall_Status_on_Submit__c != null) {
                           tempStatus = configList[0].Overall_Status_on_Submit__c;
                        }else{
                            tempStatus = 'Completed';
                        }
                        
                        IssueRequest_Life_Cycle__c amUpdate = new IssueRequest_Life_Cycle__c(Field_End_Time__c = System.now(), Id = Id.valueOf(assignmentId), Status__c = tempStatus); // update answer submit time in "End time" 01-07-2016
                        string ASMId = amUpdate.id;
                        for (Schema.SObjectField ansfield : answerFieldNameAPIMap.values()) {
        
                            Schema.DescribeFieldResult res = ansfield.getdescribe();
                
                            if (string.valueOf(res.getType()).touppercase() == 'REFERENCE' && res.isCustom() && res.getName().startsWithIgnoreCase('ANS_')) {
                
                                string assignmentManagerField = res.getName().replaceFirst('ANS_','AM_');
                                if (assignmentManagerFieldNameAPIMap.containsKey(assignmentManagerField.toLowerCase())) {
                
                                    assignmentManagerFieldAnswerFieldMap.put( assignmentManagerFieldNameAPIMap.get(assignmentManagerField.toLowerCase()).getdescribe().getName() , res.getName());
                                }
                            }
                        }
                        string amQuery = 'SELECT ExAM__Assignment_Manager__c,ExAM__Scheduled_End_Date__c, ExAM__Scheduled_Start_Date__c, ExAM__Status__c , ExAM__Priority__c , ExAM__Facility_Name__c,ExAM__Assessor_Resource__c, ExAM__Facility_Name__r.Name,ExAM__Facility_Name__r.ParentId, ExAM__Facility_Name__r.Parent.Name , Id, ExAM__InvestigationType__c, ExAM__Assessment_Template_Type__c ,ExAM__InvestigationType__r.Name, Name,CreatedDate';
                        
                        for (string assessableFieldapi : assignmentManagerFieldAnswerFieldMap.keySet()) {
                            amQuery += ' ,'+assessableFieldapi;
                        }
                        
                        amQuery += ', ExAM__Total_Time_on_Assessment__c, ExAM__Related_Assignment_Manager1__c, ExAM__Related_Assignment_Manager1__r.Name,ExAM__Related_Assignment_Manager1__r.ExAM__Total_Time_on_Assessment__c, ExAM__Related_Assignment_Manager2__c,ExAM__Related_Assignment_Manager2__r.Name,ExAM__Related_Assignment_Manager2__r.ExAM__Total_Time_on_Assessment__c, ExAM__Related_Assignment_Manager3__c, ExAM__Related_Assignment_Manager3__r.Name, ExAM__Related_Assignment_Manager3__r.ExAM__Total_Time_on_Assessment__c, ExAM__Related_Assignment_Manager4__c, ExAM__Related_Assignment_Manager4__r.Name, ExAM__Related_Assignment_Manager4__r.ExAM__Total_Time_on_Assessment__c FROM ExAM__IssueRequest_Life_Cycle__c WHERE id =: ASMId';
    
                            SFDCAccessController accessForSSInsert1 = ExAMUtilClass.AccessController;
                            List<string> fieldsListSSInsert1 = new List<string>{'ExAM__Field_End_Time__c', 'ExAM__Status__c'};
                            accessForSSInsert1.assertAuthorizedToCreate(Schema.getGlobalDescribe().get('exam__IssueRequest_Life_Cycle__c'), fieldsListSSInsert1);
                            accessForSSInsert1.assertAuthorizedToUpdate(Schema.getGlobalDescribe().get('exam__IssueRequest_Life_Cycle__c'), fieldsListSSInsert1);
                            upsert amUpdate;
                            SFDCAccessController accessForobj2 = ExAMUtilClass.AccessController;
                            List<string> fieldsList2 = new List<string>{'ExAM__Assignment_Manager__c','ExAM__Scheduled_End_Date__c', 'ExAM__Scheduled_Start_Date__c', 'ExAM__Status__c' , 'ExAM__Priority__c' , 'ExAM__Facility_Name__c','ExAM__Assessor_Resource__c','ExAM__InvestigationType__c', 'ExAM__Assessment_Template_Type__c','ExAM__Total_Time_on_Assessment__c', 'ExAM__Related_Assignment_Manager1__c','ExAM__Related_Assignment_Manager2__c','ExAM__Related_Assignment_Manager3__c','ExAM__Related_Assignment_Manager4__c'};
                                      
                            accessForobj2.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__IssueRequest_Life_Cycle__c'), fieldsList2);
                            
                            SFDCAccessController accessForobj1 = ExAMUtilClass.AccessController;
                            List<string> fieldsList1 = new List<string>{'ExAM__Show_Image_Upload_Icon__c','ExAM__Show_Notes_Icon__c','ExAM__Show_Refresh_Icon__c','ExAM__Show_Question_Number__c' };
                            accessForobj1.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Main_questionaire__c'), fieldsList1);
                            
                            amUpdate = Database.Query(amQuery);
                            resultMsg = JSON.serialize( new SuccessClass('success', 'update assignment manager',amUpdate) );
    
                    }
                }
            }catch(Exception exp) {                     
                resultMsg = JSON.serialize( new ErrorClass(exp.getTypeName(), (exp.getTypeName() != 'System.DMLException') ? exp.getMessage() : exp.getDMLMessage(0)) );
            }
            return resultMsg;

    }
    
    /*
    //Added on 20-07-2017 for delete decision tree old path by one time assessment
    
    public static Map<String,Question_Template__c> quesNameWithRecMap = new Map<String,Question_Template__c>();
    public static String deleteOldDecisionTreePath(String startQtn, Id templateId){
        
        List<String> nextQtnList = new List<String>();
        String resMsg = '';
        Question_Template__c ques = new Question_Template__c();

            SFDCAccessController accessForQR = ExAMUtilClass.AccessController;
            
            List<String> fieldsListAnsOpt = new List<String>{'ExAM__Next_Question__c','ExAM__Dependent_Question__c'};
            accessForQR.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Answer_Option__c'), fieldsListAnsOpt);
            
            List<String> fieldsListST = new List<String>{'ExAM__Questionnaire_Section__c'};
            accessForQR.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Section_Template__c'), fieldsListST);
            
            List<String> fieldsListQT = new List<String>{'ExAM__Next_Question__c','ExAM__Section_Question__c'};
            accessForQR.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Question_Template__c'), fieldsListQT);
            for( Question_Template__c question :[SELECT Id, Name, Next_Question__c, Question_Type__c, (SELECT Id, Name, Dependent_Question__r.Name,Next_Question__r.Name FROM Answer_Options__r)
                                                 FROM Question_Template__c WHERE Section_Question__r.Questionnaire_Section__c = :templateId]){
                quesNameWithRecMap.put(question.Name,question);
            }
            System.debug('startQtn::*~:'+startQtn);
            
            System.debug('startQtn::*:'+startQtn);
            if ( quesNameWithRecMap.containsKey(startQtn) ){
                ques = quesNameWithRecMap.get(startQtn);
            }
            if ( ques != null && ques.Next_Question__c != null && ques.Next_Question__c != '' && ques.Answer_Options__r.size() == 0 ){
                if ( ques.Next_Question__c.contains('~') ){
                    nextQtnList = trimAnswerOption(ques.Next_Question__c);
                } else {
                    nextQtnList.add(ques.Next_Question__c);
                }
            } else if ( ques != null && ques.Answer_Options__r != null && ques.Answer_Options__r.size() > 0 ){
                for( Answer_Option__c ansOpt :ques.Answer_Options__r ){
                    if ( ansOpt.Next_Question__c != null && ansOpt.Next_Question__r.Name != '' ){
                        nextQtnList.add(ansOpt.Next_Question__r.Name);
                    }
                }
            }
            if ( nextQtnList != null && nextQtnList.size() > 0 ){
                getNextQuestion(nextQtnList);
            }
            System.debug('::::quesIdSet;;;;'+quesIdSet);
            List<String> fieldsListQR = new List<String>{'ExAM__Question_Template__c'};
            accessForQR.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Questionnaire_Response__c'), fieldsListQR);
            List<Questionnaire_Response__c> decisionTreeResList = [ SELECT Id, Question_Template__c FROM Questionnaire_Response__c WHERE Question_Template__c IN :quesIdSet ];
            if ( decisionTreeResList != null && decisionTreeResList.size() > 0 ){
                System.debug('decisionTreeResList::*'+decisionTreeResList);
                if ( accessForQR.isAuthorizedToDelete(Schema.getGlobalDescribe().get('exam__Questionnaire_Response__c')) )
                delete decisionTreeResList;
                resMsg = 'Success';
            }

        return resMsg;
    }
     
    public static void getNextQuestion(List<String> nextQtnList){
        
        for( String nextQtn :nextQtnList ){
            Question_Template__c ques = new Question_Template__c();
            if ( quesNameWithRecMap.containsKey(nextQtn) ){
                ques = quesNameWithRecMap.get(nextQtn);
                quesIdSet.add(ques.Id);
            }
            if( ques.Question_Type__c == 'Result' && ((ques.Next_Question__c != null && ques.Next_Question__c != '') || 
                ques.Answer_Options__r != null && ques.Answer_Options__r.size() > 0 && ques.Answer_Options__r[0].Next_Question__r.Name != null && ques.Answer_Options__r[0].Next_Question__r.Name != '' ) ){
                break;
            }
            List<String> nextQuesList = new List<String>();
            if ( ques.Next_Question__c != null && ques.Next_Question__c != '' && ques.Answer_Options__r.size() == 0 ){
                if ( ques.Next_Question__c.contains('~') ){
                    nextQuesList = trimAnswerOption(ques.Next_Question__c);
                } else {
                    nextQuesList.add(ques.Next_Question__c);
                }
            } else if ( ques.Answer_Options__r != null && ques.Answer_Options__r.size() > 0 ){
                for( Answer_Option__c ansOpt :ques.Answer_Options__r ){
                    if ( ansOpt.Next_Question__c != null && ansOpt.Next_Question__r.Name != '' ){
                        nextQuesList.add(ansOpt.Next_Question__r.Name);
                    }
                }
            }
            if ( nextQuesList != null && nextQuesList.size() > 0 ){
                getNextQuestion(nextQuesList);
            }
        }
    }
    */
    public static string queryAllAnswerRecords(string assignmentManagerId, Boolean isFromLensViewer) {

        string answerResponse = '';
        AnswerDetails ansDtls = new AnswerDetails();
        ErrorClass1 errClass;
        List<AnswerClass> answerResponseList = new List<AnswerClass> ();
        Set<Id> attHadAssignmentManagerIDSet = new Set<Id>();
        Set<Id> amIdSet = new Set<Id>();
        List<string> questionTypeList = new List<string>();

        //Added 22/08/16 for editing answers in mobile
        Map<string,Boolean> isUpdatableMap = new Map<string,Boolean>();
        Map<string,Map<string,string>> picklistValuesMap = new Map<string,Map<string,string>>();
        SFDCAccessController accessForobj =  ExAMUtilClass.AccessController;
        try{
            List<string> fieldsList = new List<string>{'ExAM__Data_Management_Tab_Filter__c'};
                      
            accessForobj.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__ExAM_Configuration__c'), fieldsList);
            List<Exam_Configuration__c> exConfigRecordList = new List<Exam_Configuration__c>([SELECT Id, Name, ExAM__Data_Management_Tab_Filter__c FROM ExAM_Configuration__c LIMIT 1]);
            if (exConfigRecordList != null && exConfigRecordList.size() > 0) {
                Exam_Configuration__c exConfigRecord = exConfigRecordList[0];
                if (string.isNotBlank(exConfigRecord.ExAM__Data_Management_Tab_Filter__c) ) {
                    if (exConfigRecord.ExAM__Data_Management_Tab_Filter__c.contains(',') ) {
                        for (string type : exConfigRecord.ExAM__Data_Management_Tab_Filter__c.split(',') ) {
                            questionTypeList.add( type );
                        }
                    }
                    else {
                        questionTypeList.add( exConfigRecord.ExAM__Data_Management_Tab_Filter__c );
                    }
                }
            }
    
            List<Schema.FieldSetMember> answerFieldsList = new List<Schema.FieldSetMember>();
            answerFieldsList = SObjectType.ExAM__Questionnaire_Response__c.FieldSets.ExAM__Data_Viewer_FieldSet.getFields();
            List<Map<string,string>> resultConfiguredAnswerFieldsJson = new List<Map<string,string>>();
            
            Map<string, Schema.SObjectField> schemaFieldMap = Schema.SObjectType.ExAM__Questionnaire_Response__c.fields.getMap();
            
            if (string.isNotBlank(assignmentManagerId)) {
    
                    List<string> fieldsList2 = new List<string>{'ExAM__Related_Assignment_Manager1__c','ExAM__Related_Assignment_Manager2__c','ExAM__Related_Assignment_Manager3__c','ExAM__Related_Assignment_Manager4__c'};
                    accessForobj.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__IssueRequest_Life_Cycle__c'), fieldsList2);
                    
                    for(IssueRequest_Life_Cycle__c amRecord : [SELECT Id, Name, Related_Assignment_Manager1__c, Related_Assignment_Manager2__c, Related_Assignment_Manager3__c, Related_Assignment_Manager4__c FROM IssueRequest_Life_Cycle__c WHERE Id = :assignmentManagerId]) {
    
                        if (isFromLensViewer) {
    
                            if (amRecord.Related_Assignment_Manager1__c != null) {
                                amIdSet.add(amRecord.Related_Assignment_Manager1__c);
                            }
                            if (amRecord.Related_Assignment_Manager2__c != null) {
                                amIdSet.add(amRecord.Related_Assignment_Manager2__c);
                            }
                            if (amRecord.Related_Assignment_Manager3__c != null) {
                                amIdSet.add(amRecord.Related_Assignment_Manager3__c);
                            }
                            if (amRecord.Related_Assignment_Manager4__c != null) {
                                amIdSet.add(amRecord.Related_Assignment_Manager4__c);
                            }
                        }
                        amIdSet.add(amRecord.Id);
                    }
    
                    if (amIdSet != null && amIdSet.size() > 0)     {
    
                        string answerObj_Select_Clause = '(select Id,Name from Attachments ORDER BY CreatedDate DESC LIMIT 1),Id, CreatedDate, '
                                                        +'ExAM__Question_Template__c, ExAM__Question_Template__r.ExAM__Question_Type__c, '
                                                        +'ExAM__Question_Template__r.ExAM__Question_Label__c, ExAM__Question_Template__r.ExAM__Section_Question__c, '
                                                        +'ExAM__Question_Template__r.ExAM__Section_Question__r.ExAM__Section_label__c,'
                                                        +'ExAM__Question_Template__r.ExAM__Section_Question__r.ExAM__Questionnaire_Section__r.ExAM__Decision_Tree__c, ';
                        string answerObj_From_Clause = 'ExAM__Questionnaire_Response__c';
                        string answerObj_Where_Clause = 'ExAM__Issue_Request__c IN :amIdSet';
                        if (questionTypeList.size() > 0) {
                            answerObj_Where_Clause += ' AND ExAM__Question_Template__r.ExAM__Question_Type__c IN :questionTypeList';
                        }
                        Set<string> apiName= new Set<string>();
                        
                        string answerObj_Orderby_Clause = 'CreatedDate DESC';
                        string ObjectName = 'ExAM__Questionnaire_Response__c';
                        
                        for (Schema.SObjectField fld : schemaFieldMap.values()) {
                            
                            Schema.DescribeFieldResult f = fld.getdescribe();
                            if (f.isCustom() && f.getCalculatedFormula() == null && (string.valueOf(f.getType()).equalsIgnoreCase('picklist') || string.valueOf(f.getType()).equalsIgnoreCase('textarea') || string.valueOf(f.getType()).equalsIgnoreCase('string')) ) {
                                if(!answerObj_Select_Clause.contains( string.valueOf(f.getSobjectField()) )){
                                    apiName.add( string.valueOf(f.getSobjectField()) );
                                    answerObj_Select_Clause += f.getSobjectField() + ', ';
                                }
                                Map<string,string> tempMap = new Map<string,string>();
                                tempMap.put('label',f.getLabel());
                                tempMap.put('fieldPath',string.valueOf(f.getSobjectField()));
                                tempMap.put('type',string.valueOf( f.getType()) );
                                resultConfiguredAnswerFieldsJson.add(tempMap);
                                isUpdatableMap.put(string.valueOf(f.getSobjectField()),(f.isUpdateable()));
                                if(string.valueOf(f.getType()).equalsIgnoreCase('picklist')){
    
                                    Map<string,string> tempPicklistMap = new Map<string,string>();
                                    List<Schema.PicklistEntry> picklistEntry = f.getPicklistValues();
                                    for(Schema.PicklistEntry picklist : picklistEntry)
                                    {  
                                       tempPicklistMap.put(picklist.getLabel(), picklist.getValue());
                                    }  
                                    picklistValuesMap.put(string.valueOf(f.getSobjectField()),tempPicklistMap);
                                }
                            } 
                        }
                        
                        for(Schema.FieldSetMember f : answerFieldsList) {
                            if(!answerObj_Select_Clause.contains(f.getFieldPath())){
                                apiName.add(f.getFieldPath());
                                answerObj_Select_Clause += f.getFieldPath() + ', ';
                            }
                            
                            Schema.DescribeFieldResult fieldResult = Schema.getGlobalDescribe().get(ObjectName).getDescribe().fields.getMap().get(f.getFieldPath()).getDescribe();
    
                            if(string.valueOf(f.getType()).equalsIgnoreCase('picklist')){
    
                                Map<string,string> tempPicklistMap = new Map<string,string>();
                                List<Schema.PicklistEntry> picklistEntry = fieldResult.getPicklistValues();
                                for(Schema.PicklistEntry picklist : picklistEntry)
                                {  
                                   tempPicklistMap.put(picklist.getLabel(), picklist.getValue());
                                }  
                                picklistValuesMap.put(f.getFieldPath(),tempPicklistMap);
                            }
                            isUpdatableMap.put(f.getFieldPath(),(fieldResult.isUpdateable() && fieldResult.getCalculatedFormula() == null));
                        }
                        if (answerObj_Select_Clause.endsWith(', ')) {
                            answerObj_Select_Clause = answerObj_Select_Clause.substring(0, answerObj_Select_Clause.length()-2);
                        }
                        string answerObj_Query_Str = 'SELECT '+answerObj_Select_Clause+' FROM '+answerObj_From_Clause+' WHERE '+answerObj_Where_Clause+' ORDER BY '+answerObj_Orderby_Clause+' LIMIT 100';
    
                            List<Questionnaire_Response__c> answerList = new List<Questionnaire_Response__c>();
                            List<string> fieldList = new List<string> {'ExAM__Question_Template__c', 'ExAM__Question_Template__c'};
                            accessForobj.assertAuthorizedToView(Schema.getGlobalDescribe().get(answerObj_From_Clause), fieldList);
                            
                            List<string> fieldList2 = new List<string> {'ExAM__Question_Type__c', 'ExAM__Question_Label__c','ExAM__Section_Question__c'};
                            accessForobj.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Question_Template__c'), fieldList2);                            
                            
                            answerList = Database.query(answerObj_Query_Str);
    
                            if (answerList != null && answerList.size() > 0) {
    
                                Map<Id, Questionnaire_Response__c> answerMap = new Map<Id, Questionnaire_Response__c>(answerList);
    
                                if (answerMap!= null && answerMap.size() > 0) {
                                    for(Attachment att : [SELECT Id, ParentId FROM Attachment WHERE ParentId IN: answerMap.keySet()]) {
                                        attHadAssignmentManagerIDSet.add(att.ParentId);    
                                    }  
                                }
    
                                for (Id ansId : answerMap.keySet()) {
    
                                    AnswerClass anscls = new AnswerClass();
                                    anscls.answer = answerMap.get(ansId);
                                    if (attHadAssignmentManagerIDSet != null && attHadAssignmentManagerIDSet.contains(ansId)) {
                                        anscls.hasAttached = 'Yes';
                                    } else {
                                        anscls.hasAttached = 'No';
                                    }
                                    answerResponseList.add(anscls);
                                } 
                                
                                //answerList =  (List<ExAM__Questionnaire_Response__c>)Json.deserialize(temp, List<ExAM__Questionnaire_Response__c>.class);
                                ansDtls = new AnswerDetails();
                                ansDtls.resultConfiguredAnswerFieldsJson = resultConfiguredAnswerFieldsJson;
                                ansDtls.configuredAnswerFieldsJson = answerFieldsList;
                                ansDtls.answerList = answerResponseList;
                                ansDtls.isUpdatableMap = isUpdatableMap;
                                ansDtls.picklistValuesMap = picklistValuesMap;
                                string temp = JSON.serialize(ansDtls);
                                for(string str : apiName){
                                    temp = temp.replaceAll(str, str.toLowerCase());
                                }
                                return temp;
                            }
                            else {
                                errClass = new ErrorClass1();
                                errClass.errType = 'RecordsNotAvailable';
                                errClass.errMsg = 'Exception-Answer records not exists';
                                answerResponse = JSON.serialize(errClass);
                            }
                        
                        
                    }          
                    else {
                        errClass = new ErrorClass1();
                        errClass.errType = 'RecordsNotAvailable';
                        errClass.errMsg = 'No Assignment Manager exists with given Id';
                        answerResponse = JSON.serialize(errClass);
                    }
                
            }
            else {
                errClass = new ErrorClass1();
                errClass.errType = 'IdNotDefined';
                errClass.errMsg = 'Assignment Manager Id not defined';
                answerResponse = JSON.serialize(errClass);
            }
            return answerResponse;
        }catch(Exception exp) {     
            return exp.getMessage();        
        }

    }

    public class assessableRecordsClass {
        public string recordId;
        public string recordName;
    }

    public static string returnAssessableRecord(string assignmentManagerId) {

        Boolean section1 = true;
        Boolean section2 = false;
        string ObjectName;
        Map<string,Boolean> isUpdatableMap = new Map<string,Boolean>();
        Map<string,Map<string,string>> picklistValuesMap = new Map<string,Map<string,string>>();
        //Map<string,List<Map<string,string>>> picklistValuesMap = new Map<string,List<Map<string,string>>>();

        RestGetAssesableRecords AssRecCtrlr = new RestGetAssesableRecords();
        List<Schema.FieldSetMember> fields = new List<Schema.FieldSetMember>();
        SObject assessableRec = Schema.getGlobalDescribe().get('Account').newSObject() ;
        List<assessableRecordsClass> assRecClsList = new List<assessableRecordsClass>();
        Map<string,string> assignmentManagerFieldAnswerFieldMap = new Map<string,string>();
        Map <string, Schema.SObjectField> assignmentManagerFieldNameAPIMap = Schema.SObjectType.IssueRequest_Life_Cycle__c.fields.getMap();
        string returnString;

        for (Schema.SObjectField amfield : assignmentManagerFieldNameAPIMap.values()) {

            Schema.DescribeFieldResult res = amfield.getdescribe();
            if (string.valueOf(res.getType()).touppercase() == 'REFERENCE' && res.isCustom() && res.getName().startsWithIgnoreCase('AM_')) {

                assignmentManagerFieldAnswerFieldMap.put( res.getName() , res.getName());
            }
        } 
        
        SFDCAccessController accessForobj = ExAMUtilClass.AccessController;
        List<string> fieldsList = new List<string>{'ExAM__Assignment_Manager__c','ExAM__Facility_Name__c','ExAM__InvestigationType__c'};
        accessForobj.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__IssueRequest_Life_Cycle__c'), fieldsList);
        
        if ( assignmentManagerId != null && assignmentManagerId != '') {
            string amQuery = 'SELECT Assignment_Manager__c, Facility_Name__c, Facility_Name__r.Name, Id, InvestigationType__c, InvestigationType__r.Name, Name';
            for (string fldName : assignmentManagerFieldAnswerFieldMap.keySet()) {
                amQuery += ' ,' + fldName;
            }
            amQuery += ' FROM IssueRequest_Life_Cycle__c WHERE Id =:assignmentManagerId LIMIT 1';
            
            List<string> fieldsListAM = new List<string> {'ExAM__Assignment_Manager__c','ExAM__Facility_Name__c','ExAM__InvestigationType__c'};
            accessForobj.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__IssueRequest_Life_Cycle__c'), fieldsListAM);

            List<IssueRequest_Life_Cycle__c> assignmentManagerList = Database.query(amQuery );

            if (assignmentManagerList != null && assignmentManagerList.size() > 0 ) {

                if (assignmentManagerList[0].Facility_Name__c != null) {

                    ObjectName = 'Account';
                    Id assignmentAccVal = assignmentManagerList[0].Facility_Name__c ;
                    string qryStr = 'SELECT Id, Name, ParentId ';
                    List<string> queryFieldList = new List<string>();
                    Set<string> queryFieldSet = new Set<string>();
                    queryFieldSet.add('Id');
                    queryFieldSet.add('Name');
                    queryFieldSet.add('ParentId');
                    fields = AssRecCtrlr.readFieldSet('ViewerFieldSet_Account', 'Account');
                    for (Schema.FieldSetMember f  : fields) {

                        if (!queryFieldSet.contains(f.getFieldPath())) {
                            queryFieldList.add(f.getFieldPath());
                            queryFieldSet.add(f.getFieldPath());
                            Schema.DescribeFieldResult fieldResult = Schema.getGlobalDescribe().get(ObjectName).getDescribe().fields.getMap().get(f.getFieldPath()).getDescribe();

                            if(string.valueOf(f.getType()).equalsIgnoreCase('picklist')){

                                Map<string,string> tempPicklistMap = new Map<string,string>();
                                List<Schema.PicklistEntry> picklistEntry = fieldResult.getPicklistValues();
                                for(Schema.PicklistEntry picklist : picklistEntry)
                                {  
                                   tempPicklistMap.put(picklist.getLabel(), picklist.getValue());
                                }    
                                picklistValuesMap.put(f.getFieldPath(),tempPicklistMap);
                            }
                            isUpdatableMap.put(f.getFieldPath(),fieldResult.isUpdateable());
                        }
                    }
                    if (queryFieldList.size() > 0) {
                        qryStr += ', ';
                    }
                    qryStr += string.join(queryFieldList, ', ');
                    qryStr += ' FROM Account WHERE Id =:assignmentAccVal OR ParentId =:assignmentAccVal Order by Name ASC';
                    List<string> accountFields = new List<string> {'Name','ParentId'};
                    accessForobj.assertAuthorizedToView(Schema.getGlobalDescribe().get('Account'), accountFields);

                    List<Account> accList = Database.query(qryStr);
                    if (accList != null && accList.size() > 0) {
                        for (Account acc : accList) {
                            assessableRecordsClass arc = new assessableRecordsClass();
                            arc.recordId = acc.Id;
                            arc.recordName = acc.Name;
                            assRecClsList.add(arc);
                            if (acc.Id == assignmentAccVal) {
                                assessableRec = acc;
                            }
                        }                        
                    }
                } else {
                    for (string fldName : assignmentManagerFieldAnswerFieldMap.keySet()) {

                        if (assignmentManagerList[0].get(fldName ) != null) {

                            Id hierarchyId = (Id)assignmentManagerList[0].get(fldName);
                            string sObjName = hierarchyId.getSObjectType().getDescribe().getName();
                            ObjectName = sObjName;

                            if (!sObjName.equalsIgnoreCase('Case')) {
                                /* Start Self lookup find */
                                string parentfieldName = '';
                                List<DescribeSobjectResult> dsr = Schema.describeSObjects(new string[] {sObjName });
                                if (dsr != null && dsr.size() > 0) {
                                    DescribeSobjectResult d = dsr[0];
                                    Boolean breakflag = false;
                                    for (SObjectField f : d.fields.getMap().values()) {
                                        if (breakflag) {
                                            break;
                                        }
                                        DescribeFieldResult dfr  = f.getDescribe();
                                        if (dfr.getType() == DisplayType.Reference) {   
                                            for (Schema.sObjectType sObtype : dfr.getReferenceTo()) {    
                                                string refObjName = (string.valueOf(sObtype ));
                                                if (sObjName == refObjName) {
                                                    parentfieldName = dfr.getName();
                                                    breakflag = true;
                                                    break;
                                                }
                                            }
                                        }
                                    }
                                }
                                /* End Self lookup find */

                                string hierarchyObjQuery = 'SELECT Id, Name ';
                                if (parentfieldName != '') {
                                    hierarchyObjQuery +=','+ parentfieldName ;
                                }

                                //Start - new code for Assessable record

                                List<string> queryFieldList = new List<string>();
                                Set<string> queryFieldSet = new Set<string>();
                                queryFieldSet.add('Id');
                                queryFieldSet.add('Name');
                                if (parentfieldName != '') {
                                    queryFieldSet.add(parentfieldName);
                                }
                                string fieldSetName = 'ViewerFieldSet_'+sObjName.removeEnd('__c');
                                fields = AssRecCtrlr.readFieldSet(fieldSetName, sObjName);
                                for (Schema.FieldSetMember f  : fields) {
                                    if (!queryFieldSet.contains(f.getFieldPath())) {
                                        queryFieldList.add(f.getFieldPath());
                                        queryFieldSet.add(f.getFieldPath());

                                        Schema.DescribeFieldResult fieldResult = Schema.getGlobalDescribe().get(ObjectName).getDescribe().fields.getMap().get(f.getFieldPath()).getDescribe();

                                        if(string.valueOf(f.getType()).equalsIgnoreCase('picklist')){

                                            Map<string,string> tempPicklistMap = new Map<string,string>();
                                            List<Schema.PicklistEntry> picklistEntry = fieldResult.getPicklistValues();
                                            for(Schema.PicklistEntry picklist : picklistEntry)
                                            {  
                                               tempPicklistMap.put(picklist.getLabel(), picklist.getValue());
                                            }    
                                            picklistValuesMap.put(f.getFieldPath(),tempPicklistMap);
                                        }
                                        isUpdatableMap.put(f.getFieldPath(),fieldResult.isUpdateable());
                                    }
                                }
                                if (queryFieldList.size() > 0) {
                                    hierarchyObjQuery += ', ';
                                }
                                hierarchyObjQuery += string.join(queryFieldList, ', ');

                                //End - new code for Assessable record show

                                hierarchyObjQuery += ' FROM '+sObjName+' WHERE Id =:hierarchyId ';
                                if (parentfieldName != '') {
                                    hierarchyObjQuery += ' OR '+parentfieldName+'=:hierarchyId ' ;
                                }
                                hierarchyObjQuery += ' Order by Name ASC';
                                
                                List<string> objFields = new List<string> {'Name'};
                                accessForobj.assertAuthorizedToView(Schema.getGlobalDescribe().get(sObjName), objFields);
                                List<SObject> hierarchyRecords = Database.query(hierarchyObjQuery);
                                for (SObject sob : hierarchyRecords) {
                                    assessableRecordsClass arc = new assessableRecordsClass();
                                    arc.recordId = (string) sob.get('Id');
                                    arc.recordName = (string) sob.get('Name');
                                    assRecClsList.add(arc);
                                    if (arc.recordId == hierarchyId) {
                                        assessableRec = sob;
                                    }
                                }

                            } else if (sObjName.equalsIgnoreCase('Case')) {
                                string qryStr = 'SELECT Id, CaseNumber, ParentId ';
                                List<string> queryFieldList = new List<string>();
                                Set<string> queryFieldSet = new Set<string>();
                                queryFieldSet.add('Id');
                                queryFieldSet.add('CaseNumber');
                                queryFieldSet.add('ParentId');
                                fields = AssRecCtrlr.readFieldSet('ViewerFieldSet_Case', 'Case');
                                for (Schema.FieldSetMember f  : fields) {
                                    if (!queryFieldSet.contains(f.getFieldPath())) {
                                        queryFieldList.add(f.getFieldPath());
                                        queryFieldSet.add(f.getFieldPath());

                                        Schema.DescribeFieldResult fieldResult = Schema.getGlobalDescribe().get(ObjectName).getDescribe().fields.getMap().get(f.getFieldPath()).getDescribe();

                                        if(string.valueOf(f.getType()).equalsIgnoreCase('picklist')){

                                            Map<string,string> tempPicklistMap = new Map<string,string>();
                                            List<Schema.PicklistEntry> picklistEntry = fieldResult.getPicklistValues();
                                            for(Schema.PicklistEntry picklist : picklistEntry)
                                            {  
                                               tempPicklistMap.put(picklist.getLabel(), picklist.getValue());
                                            }    
                                            picklistValuesMap.put(f.getFieldPath(),tempPicklistMap);
                                        }
                                        isUpdatableMap.put(f.getFieldPath(),fieldResult.isUpdateable());
                                    }
                                }
                                if (queryFieldList.size() > 0) {
                                    qryStr += ', ';
                                }
                                qryStr += string.join(queryFieldList, ', ');
                                qryStr += ' FROM Case WHERE Id =:hierarchyId OR ParentId =:hierarchyId Order by CaseNumber ASC';
                                
                                List<string> objFields = new List<string> {'CaseNumber','ParentId'};
                                accessForobj.assertAuthorizedToView(Schema.getGlobalDescribe().get('Case'), objFields);
                                List<Case> caseList = Database.query(qryStr);

                                //List<Case> caseList = [ FROM Case WHERE Id =:hierarchyId OR ParentId =:hierarchyId Order by CaseNumber ASC];  
                                if (caseList != null && caseList.size() > 0) {
                                    for (Case case1 : caseList) {
                                        assessableRecordsClass arc = new assessableRecordsClass();
                                        arc.recordId = case1.Id;
                                        arc.recordName = case1.CaseNumber;
                                        assRecClsList.add(arc);
                                        if (case1.Id == hierarchyId) {
                                            assessableRec = case1;
                                        }
                                    }
                                }
                            }
                            break;
                        }
                    }
                }
            }
        }
        //assessableRec   
        System.debug(':::fields:::'+fields);
        returnString = JSON.serialize(assessableRec);  
        return returnString+'~~~'+JSON.serialize(fields)+'~~~'+JSON.serialize(isUpdatableMap)+'~~~'+JSON.serialize(picklistValuesMap)+'~~~'+ObjectName;     
    }  

    public static string returnASMFieldset(string ASMId) {

      RestGetAssesableRecords AssRecCtrlr = new RestGetAssesableRecords();
      List<Schema.FieldSetMember> ASMFieldSet = new List<Schema.FieldSetMember>();
      Map<string,Boolean> ASMIsUpdatableMap = new Map<string,Boolean>();
      Map<string,Map<string,string>> ASMPicklistValuesMap = new Map<string,Map<string,string>>();
      List<Schema.FieldSetMember> fieldSet = new List<Schema.FieldSetMember>();
      String ASMQuery = 'SELECT Id';
      List<AssesableObjectFieldset> temp = new List<AssesableObjectFieldset>();
      
      string ObjectName = 'ExAM__IssueRequest_Life_Cycle__c';
      ASMFieldSet = AssRecCtrlr.readFieldSet('ExAM__New_Assignment_Manager_Mobile', ObjectName);

      for (Schema.FieldSetMember f  : ASMFieldSet) {
          Schema.DescribeFieldResult fieldResult = Schema.getGlobalDescribe().get(ObjectName).getDescribe().fields.getMap().get(f.getFieldPath()).getDescribe();

          if(string.valueOf(f.getType()).equalsIgnoreCase('picklist')){

              Map<string,string> tempPicklistMap = new Map<string,string>();
              List<Schema.PicklistEntry> picklistEntry = fieldResult.getPicklistValues();
              for(Schema.PicklistEntry picklist : picklistEntry)
              {  
                 tempPicklistMap.put(picklist.getLabel(), picklist.getValue());
              }    
              ASMPicklistValuesMap.put(f.getFieldPath(),tempPicklistMap);
          }
          ASMIsUpdatableMap.put(f.getFieldPath(),fieldResult.isUpdateable());
          if(string.isNotBlank(ASMId)){
              ASMQuery += ', ' + f.getFieldPath();
          }
      }

      ASMAndAssesableObjectFieldset returnJSON = new ASMAndAssesableObjectFieldset();
      returnJSON.ASMFieldSet = ASMFieldSet;
      returnJSON.ASMIsUpdatableMap = ASMIsUpdatableMap;
      returnJSON.ASMPicklistValuesMap = ASMPicklistValuesMap;
      returnJSON.AssesableObjectFieldset = new Map<string, AssesableObjectFieldset>();
      if(string.isNotBlank(ASMId)){
          ASMQuery += ' FROM IssueRequest_Life_Cycle__c where Id =:ASMId';
          SFDCAccessController accessForobj = ExAMUtilClass.AccessController;
          List<string> fieldsList = new List<string>{'ExAM__Date_Assigned__c', 'ExAM__Issue_request__c', 'ExAM__Status__c', 'ExAM__Show_Configuration_Options_in_Viewer__c','ExAM__Priority__c', 'ExAM__Scheduled_Start_Date__c', 'ExAM__Facility_Name__c'};
          accessForobj.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__IssueRequest_Life_Cycle__c'), fieldsList);
          returnJSON.ASMData = Database.query(ASMQuery);
      } else{  
        Map<string, string> fieldsMap = getReferenceFieldMapInAM();
        List<ExAM__ExAM_Configuration__c> examConfigurationList = new List<ExAM__ExAM_Configuration__c>([
            SELECT Id, ExAM__Mobile_Assessable_Object__c
            FROM   ExAM__ExAM_Configuration__c ORDER BY CreatedDate DESC LIMIT 1
        ]);
        if(examConfigurationList.size() > 0 && examConfigurationList[0].ExAM__Mobile_Assessable_Object__c != null){
            fieldsMap =  (Map<string, string>)Json.deserialize(examConfigurationList[0].ExAM__Mobile_Assessable_Object__c, Map<string, string>.class);
        }
        if(fieldsMap.size() == 0){
            fieldsMap.put('Account', 'ExAM__Facility_Name__c');
            Map<string, Schema.SObjectField> amFieldsMap = ExAM__IssueRequest_Life_Cycle__c.sObjectType.getDescribe().fields.getMap();
            for (Schema.SObjectField eachfield : amFieldsMap.Values()) {
    
                Schema.DescribeFieldResult dfr = eachfield.getDescribe();
                if (dfr.isCustom() && (dfr.getType() == Schema.DisplayType.REFERENCE) && dfr.getName().startsWithIgnoreCase('AM_')) {
                    fieldsMap.put(dfr.getReferenceTo().get(0).getDescribe().getName(), dfr.getName());
                }
            }
        }
        if(fieldsMap != null && fieldsMap.size() > 0) {
            for(String ass:fieldsMap.keySet()){
              
              //Changes for Assesable Object Fieldset
              AssesableObjectFieldset assFieldset = new AssesableObjectFieldset();
              Map<string,Boolean> isUpdatableMap = new Map<string,Boolean>();
              Map<string,Map<string,string>> picklistValuesMap = new Map<string,Map<string,string>>();
              ObjectName = ass;
              string fieldSetName = 'ViewerFieldSet_'+ObjectName.removeEnd('__c');
              fieldSet = AssRecCtrlr.readFieldSet(fieldSetName, ObjectName);
    
              for (Schema.FieldSetMember f  : fieldSet) {
    
                  Schema.DescribeFieldResult fieldResult = Schema.getGlobalDescribe().get(ObjectName).getDescribe().fields.getMap().get(f.getFieldPath()).getDescribe();
    
                  if(string.valueOf(f.getType()).equalsIgnoreCase('picklist')){
    
                      Map<string,string> tempPicklistMap = new Map<string,string>();
                      List<Schema.PicklistEntry> picklistEntry = fieldResult.getPicklistValues();
                      for(Schema.PicklistEntry picklist : picklistEntry)
                      {  
                         tempPicklistMap.put(picklist.getLabel(), picklist.getValue());
                      }    
                      picklistValuesMap.put(f.getFieldPath(),tempPicklistMap);
                  }
                  isUpdatableMap.put(f.getFieldPath(),fieldResult.isUpdateable());
              }
              
              assFieldset.fieldSet = fieldSet;
              assFieldset.isUpdatableMap = isUpdatableMap;
              assFieldset.picklistValuesMap = picklistValuesMap;
              assFieldset.asmLookup = fieldsMap.get(ass);
              assFieldset.hasFieldset = fieldSet.size() > 0;
              returnJSON.AssesableObjectFieldset.put(ass,assFieldset);
            }
          }
      }
      return JSON.serialize(returnJSON);   

    }
    
    public static string returnASM(string objectName, List<string> fieldNameList,string IdValue){
      
      string returnString = 'true';
      string queryString = 'SELECT id';
      List<Sobject> sobjectList= new List<Sobject>();
     
      Map<string,Schema.SObjectType> gd = Schema.getGlobalDescribe(); 
      Schema.SObjectType sobjType = gd.get(objectName);
      System.debug('::::sobjType:::::'+ sobjType);
      if(sobjType != null ) {
          Schema.DescribeSObjectResult describeResult = sobjType.getDescribe(); 
          Map<string,Schema.SObjectField> fieldsMap = describeResult.fields.getMap();
          system.debug('::::fieldNameList:::'+fieldNameList);
          List<string> fieldsList = new List<string>();
          for(string fldStr : fieldNameList){
              if(!fieldsMap.containsKey(fldStr.toLowerCase()) && !fldStr.contains('.')){
                  returnString = 'false';
              }else{
                  queryString += ','+fldStr;
                  if (!fldStr.contains('.')) {
                      fieldsList.add( fldStr );
                  }
              }
          }
          system.debug('::::fieldsList:::'+fieldsList);
          if(returnString == 'true' && string.isNotEmpty(IdValue)){
              if(objectName == 'ExAM__Questionnaire_Response__c'){
          
                  queryString += ', (Select Id From NotesAndAttachments WHERE IsNote = false) FROM '+objectName+' where ExAM__Account_to_Response__c =: IdValue AND (UPCS_V_Pass_or_Fail__c = \'Fail\' OR UPCS_V_Pass_or_Fail__c = \'Pass\')';
                  //WHERE (UPCS_V_Pass_or_Fail__c = \'Fail\' OR UPCS_V_Pass_or_Fail__c = \'Pass\' ) AND ExAM__Account_to_Response__c = \'' + accountId + '\''
              
              }else{
                  queryString += ' FROM '+objectName+' where id =: IdValue';
              }
              SFDCAccessController accessForobj = ExAMUtilClass.AccessController;
             // List<string> fieldsList = new List<string>{'ExAM__Section_Group__c','ExAM__Default_Section__c','ExAM__Section_Active__c','ExAM__Section_Template__c'};
              accessForobj.assertAuthorizedToView(Schema.getGlobalDescribe().get(objectName), fieldsList); 
              sobjectList = Database.Query(queryString);
              returnString = JSON.serialize(sobjectList);
          }
        }               
      return returnString;
    
    }
  
    public static string getAnswersForOneTimeAssesment(String assessmentTemplateId, String ASMId) {
      
       //List<FilteredSectionAndQuestionTemplateAndAnswerClass> filteredInnerClassList = new List<FilteredSectionAndQuestionTemplateAndAnswerClass>();
       FilteredSectionAndQuestionTemplateAndAnswerClass filteredInnerClass;
       Set<Id> ansQuesTempId = new Set<Id>();
       List<Questionnaire_Response__c> responseList = new List<Questionnaire_Response__c>();  
       List<IssueRequest_Life_Cycle__c> assignmentManagerList = new List<IssueRequest_Life_Cycle__c>(); 
       Set<String> DtquesNameSet = new Set<String>();   
       Set<Id> quesTempIdSet = new Set<Id>();
       Map<Id,Id> quesIdANDAnsIdMap = new Map<Id,Id>();
       Map<Id,List<String>> quesIdWithAnsOptRecordMap = new Map<Id,List<String>>();   
       List<AnswerRecordClass> ansRecList = new List<AnswerRecordClass>();  
       Map<Id,List<String>> buttonQuestionOptionList = new Map<Id,List<String>>();    
    
            //Added on 30-06-2016 for Answered icon
            if(string.isNotBlank(ASMId) ) {
                List<Questionnaire_Response__c> AnswerList = new List<Questionnaire_Response__c>();
                AnswerList = [SELECT Id, Name, Question_Template__c,Response__c,Question_Template__r.Question_Type__c,Question_Template__r.Subquestion_Label__c,Question_Template__r.Name  FROM Questionnaire_Response__c WHERE Issue_Request__c = :ASMId ORDER BY LastModifiedDate DESC];
                for(Questionnaire_Response__c ansObj : AnswerList) {
                    ansQuesTempId.add(ansObj.Question_Template__c); 
                    responseList.add(ansObj);                    
                }     
                
                assignmentManagerList = [SELECT Id, InvestigationType__c, InvestigationType__r.One_Time_Assessment__c, Name, Status__c FROM IssueRequest_Life_Cycle__c WHERE Id = :ASMId];   
                List<ExAM_Configuration__c> configList = [SELECT Overall_Status_on_Submit__c, Id FROM ExAM_Configuration__c WHERE Overall_Status_on_Submit__c != null ORDER BY CreatedDate DESC LIMIT 1];
                
                if (configList != null && configList.size() > 0 
                    && assignmentManagerList[0].InvestigationType__r.One_Time_Assessment__c
                    && assignmentManagerList[0].Status__c == configList[0].Overall_Status_on_Submit__c) {
                        
                    IssueRequest_Life_Cycle__c amUpdate = new IssueRequest_Life_Cycle__c(Id = Id.valueOf(ASMId), Status__c ='In Progress');
                    update amUpdate;
                    
                }     
            }
            
            if(assignmentManagerList[0].InvestigationType__c != null && assignmentManagerList[0].InvestigationType__r.One_Time_Assessment__c) {     
               Set<Id> attachAnsId = new Set<Id>();
               Map<Id,Id> quesLabelandIdMap = new Map<Id,Id>();     
               if(responseList.size() > 0) {        
                    
                    List<Attachment> attachmentList = new List<Attachment>();  
                     Map<Id, Section_Template__c> sectionTemplateMap = new Map<Id, Section_Template__c>(
                        [
                            SELECT Id, Name, No_of_Questions_Section__c, No_of_response_per_section_per_user__c, Order_No__c,
                                   Questionnaire_Section__c, Section_Description__c, Section_label__c, Section_Weight__c,
                                   Status__c, Subsectionlabel__c, SuperSection__c
                            FROM   Section_Template__c
                            WHERE  Questionnaire_Section__c = :assessmentTemplateId ORDER BY Order_No__c ASC
                        ]
                    );
                        
                    for(Question_Template__c qt : [SELECT Do_Not_Create_Answer__c, Dependent_Question__c, HelpText__c,
                                                  Is_Dependent__c, Is_Mandatory__c, Name, Next_Question__c,
                                                  Question_Label__c, Question_Order_No__c, Question_Type__c,
                                                  Subquestion_Label__c, Section_Question__c, SubSection_label__c, Video_URL__c,
                                                  Weight_Of_Question__c, Knowledge_Article_Link__c, Has_Picture__c,Field_Length__c,Hotspot_Image_Properties__c,
                                                  (SELECT Id,Name,Help_Text__c,Weight__c,Dependent_Question__r.Name,Next_Question__r.Name FROM Answer_Options__r ORDER BY Order_No__c ASC)
                                           FROM   Question_Template__c
                                           WHERE  Section_Question__c IN :sectionTemplateMap.keySet() AND Is_Dependent__c = false ORDER BY Question_Order_No__c ASC NULLS LAST]) {
                    
                        if(qt.Next_Question__c != null && qt.Next_Question__c != '') {
                            if(qt.Next_Question__c.contains('~')) {
                                List<string> tempList = new List<string>();
                                tempList = qt.Next_Question__c.split('~');
                                for(string quesName : tempList) {
                                    DtquesNameSet.add(quesName);
                                }
                            } else {
                                DtquesNameSet.add(qt.Next_Question__c);
                            }
                        }
                    }
                    
                    if(DtquesNameSet.size() > 0) {
                        Integer i = 0;
                        while(i < responseList.size()) {
                            for(String dtques : DtquesNameSet) {
                                if(dtques == responseList[i].Question_Template__r.Name) {
                                    responseList.remove(i);
                                    i--;
                                    break;
                                } 
                            }
                            i++;
                        }
                    }
                    
                    for(Questionnaire_Response__c res: responseList) {       
                        quesTempIdSet.add(res.Question_Template__c);
                        if(res.Question_Template__r.Question_Type__c == 'File Question - Answer'){  
                           if(!quesLabelandIdMap.containsKey(res.Question_Template__c)) {
                               quesLabelandIdMap.put(res.Question_Template__c,res.Id);
                           } 
                        } else if( res.Question_Template__r.Question_Type__c == 'Signature') {
                            if(!quesLabelandIdMap.containsKey(res.Question_Template__c)) {
                               quesLabelandIdMap.put(res.Question_Template__c,res.Id);
                           } 
                        }       
                        if(!quesIdANDAnsIdMap.containsKey(res.Question_Template__c)) {      
                            quesIdANDAnsIdMap.put(res.Question_Template__c,res.Id);     
                        }       
                    }
                    
                    // added on 06-05-2017 for replacing subquestion label in question type, multiselectPicklist.                        
                    if ( quesTempIdSet.size() > 0 ){
                        for( Question_Template__c ques : [SELECT Id,Question_Type__c, (SELECT Id,Name,Help_Text__c,Weight__c,Dependent_Question__r.Name,Next_Question__r.Name FROM Answer_Options__r ORDER BY Order_No__c ASC) FROM Question_Template__c WHERE Id IN :quesTempIdSet AND (Question_Type__c = 'MultiselectPicklist' OR Question_Type__c = 'Button')] ){
                           if(ques.Question_Type__c != null && ques.Question_Type__c == 'MultiselectPicklist'){
                                List<String> ansOptList = new List<String>();
                                for( Answer_Option__c ansOpt :ques.Answer_Options__r){
                                    ansOptList.add(ansOpt.Name);
                                }
                                quesIdWithAnsOptRecordMap.put(ques.Id,ansOptList);
                           }else if(ques.Question_Type__c != null && ques.Question_Type__c == 'Button'){
                            /*   List<String> buttonOptList = new List<String>();
                               for( Answer_Option__c ansOpt :ques.Answer_Options__r){
                                    ansOptList.add(ansOpt.Name);
                                }
                                buttonQuestionOptionList.put(ques.Id,ansOptList); */
                           }
                        }
                    }
                        
                    if(quesLabelandIdMap.size() > 0) {
                        for(Id resId :quesLabelandIdMap.keySet()) {
                            attachAnsId.add(quesLabelandIdMap.get(resId));
                        }
                    }      
                    if(attachAnsId.size() > 0) {        
                        attachmentList = [SELECT Body, ContentType, Id, IsPrivate, Name, ParentId FROM Attachment WHERE ParentId IN :attachAnsId ORDER BY LastModifiedDate ASC];     
                    }       
                          
                    for(Questionnaire_Response__c ansRec : responseList) {
                    
                        List<attachmentClass> attClassList = new List<attachmentClass>();
                        
                        if( quesIdANDAnsIdMap.get(ansRec.Question_Template__c) == ansRec.Id ) {
                            AnswerRecordClass ans = new AnswerRecordClass();        
                            ans.response = ansRec.Response__c;      
                            ans.questiontemplateId = ansRec.Question_Template__c;       
                            ans.questionType = ansRec.Question_Template__r.Question_Type__c;        
                            if(attachAnsId.contains(ansRec.Id)) {
                                Integer count = 0;      
                                for(Attachment att :attachmentList) {       
                                    attachmentClass attCls = new attachmentClass();
                                    if(att.ParentId == ansRec.Id){
                                        attCls.contenttype = att.contentType;
                                        attCls.name = att.Name;
                                        attCls.id = att.Id;
                                        attCls.serialNum = count;
                                        attClassList.add(attCls);
                                        
                                        ans.attachmentId = att.Id;
                                        ans.attachmentMap = attClassList;
                                        count++;
                                    }   
                                }       
                            } else if(ansRec.Question_Template__r.Question_Type__c == 'MultiselectPicklist'){       
                                        
                                Map<string,boolean> tempMap = new Map<string,boolean>();
                                List<String> optList = new List<String>();
                                if ( quesIdWithAnsOptRecordMap.get(ansRec.Question_Template__c).size() == 0 ){
                                    optList = trimAnswerOption(ansRec.Question_Template__r.Subquestion_Label__c);
                                } else {
                                    optList = quesIdWithAnsOptRecordMap.get(ansRec.Question_Template__c);
                                }
                                List<String> answeredOptionList = trimAnswerOption(ansRec.Response__c);
                                for(String option : optList) {
                                    tempMap.put(option,false);
                                    for(String op : answeredOptionList) {
                                        if(option == op) {
                                            tempMap.put(option,true);
                                        } 
                                    }
                                }
                                ans.multiselectObj =  tempMap;
                            } else if(ansRec.Question_Template__r.Question_Type__c == 'Button'){  
                                //buttonQuestionOptionList
                                Map<string,string> tempMap = new Map<string,string>();
                                List<String> optList = new List<String>();
                                optList = trimAnswerOption(ansRec.Question_Template__r.Subquestion_Label__c);
                                List<String> answeredOptionList = trimAnswerOption(ansRec.Response__c);
                                String tempId;
                                //for(String option : optList) {
                                for(Integer i= 0;i < optList.size();i++) {
                                    for(String op : answeredOptionList) {
                                        if(optList[i] == op) {
                                            tempMap.put(ansRec.Question_Template__r.Id,''+i+ansRec.Question_Template__r.Id);
                                        } 
                                    }
                                }
                                ans.buttonQuestObj = tempMap;
                            }
                            ansRecList.add(ans);
                        }        
                    }       
                }
             }
            //
            if(ansRecList.size() > 0) {     
                filteredInnerClass = new FilteredSectionAndQuestionTemplateAndAnswerClass(ansRecList, quesIdANDAnsIdMap, new ErrorClass('', '') );      
            } else {        
                filteredInnerClass = new FilteredSectionAndQuestionTemplateAndAnswerClass(new List<AnswerRecordClass>(), new Map<Id,Id>(), new ErrorClass('', '') );
            }
    
      return Json.serialize( filteredInnerClass );
    }
  
    public static List<string> trimAnswerOption(String strOption) {
    
        List<String> optList = new List<String>();
        List<String> returnOptList = new List<String>();
        
        if (strOption != null && strOption != '' ) {
            optList = strOption.split('~');
            if(optList.size() > 0 ) {
                for(String opt : optList) {
                    returnOptList.add(opt.trim());
                }
            }
        } 
        return returnOptList;
    }
  
    public static string returnAnswersCount(RestGetAnswersCount.AnswerWeightWrapper wrapperValues){
      
      Map<Id, Map<Id, Integer>> templateIdAndResponsesCountMap = new Map<Id, Map<Id, Integer>>();
      List<AnswerWeightClass> decisionTreeResultList = new List<AnswerWeightClass>();
      Set<Id> asmTempIdSet = new Set<Id>();
      Set<Id> templateIdSet = new Set<Id>();
      List<ExAM__IssueRequest_Life_Cycle__c> asmList = new List<ExAM__IssueRequest_Life_Cycle__c>();
      Set<string> ASMStatusSet = new Set<string>();
      
      templateIdSet.addAll(wrapperValues.templateIdList);
     
      List<ExAM__ExAM_Configuration__c> examConfigurationList = new List<ExAM__ExAM_Configuration__c>([
            SELECT ExAM__Mobile_Sync_Assignment_Manager_Statuses__c,
                   ExAM__Mobile_Sync_Last_X_Days__c, ExAM__Mobile_Sync_Future_X_Days__c
            FROM ExAM__ExAM_Configuration__c ORDER BY CreatedDate DESC LIMIT 1
        ]);
      string amQuery = 'SELECT Id, ExAM__InvestigationType__c, ExAM__Related_Assignment_Manager1__c, ExAM__Related_Assignment_Manager2__c, ExAM__Related_Assignment_Manager3__c, ExAM__Related_Assignment_Manager4__c FROM ExAM__IssueRequest_Life_Cycle__c WHERE ExAM__InvestigationType__c IN : templateIdSet';
      
      if (examConfigurationList != null && examConfigurationList.size() > 0) {
          if(examConfigurationList[0].ExAM__Mobile_Sync_Last_X_Days__c != null && examConfigurationList[0].ExAM__Mobile_Sync_Future_X_Days__c != null){
              amQuery += ' AND (ExAM__Scheduled_Start_Date__c = LAST_N_DAYS : '+ examConfigurationList[0].ExAM__Mobile_Sync_Last_X_Days__c + 'OR ExAM__Scheduled_Start_Date__c = NEXT_N_DAYS : '+ examConfigurationList[0].ExAM__Mobile_Sync_Future_X_Days__c+')';
          }else if(examConfigurationList[0].ExAM__Mobile_Sync_Future_X_Days__c != null){
              amQuery +=  ' AND ExAM__Scheduled_Start_Date__c = NEXT_N_DAYS : '+ examConfigurationList[0].ExAM__Mobile_Sync_Future_X_Days__c;
          }else if(examConfigurationList[0].ExAM__Mobile_Sync_Last_X_Days__c != null){
              amQuery +=  ' AND ExAM__Scheduled_Start_Date__c = LAST_N_DAYS : '+ examConfigurationList[0].ExAM__Mobile_Sync_Last_X_Days__c;
          }
          if(examConfigurationList[0].ExAM__Mobile_Sync_Assignment_Manager_Statuses__c != null){
              string[] spiltString= examConfigurationList[0].ExAM__Mobile_Sync_Assignment_Manager_Statuses__c.split('~');           
              for(string s: spiltString)
              {
                  if(s != null){
                      ASMStatusSet.add(s);
                  }
              }
          }
          if(ASMStatusSet.size() > 0){
              amQuery += ' AND ExAM__Status__c IN: ASMStatusSet';
          }

      }
      asmList = Database.query(amQuery);
      for(ExAM__IssueRequest_Life_Cycle__c asmObj : asmList){
        asmTempIdSet.add(asmObj.Id);
        if (asmObj.ExAM__Related_Assignment_Manager1__c != null) {
            asmTempIdSet.add(asmObj.ExAM__Related_Assignment_Manager1__c);
        }
        if (asmObj.ExAM__Related_Assignment_Manager2__c != null) {
            asmTempIdSet.add(asmObj.ExAM__Related_Assignment_Manager2__c);
        }
        if (asmObj.ExAM__Related_Assignment_Manager3__c != null) {
            asmTempIdSet.add(asmObj.ExAM__Related_Assignment_Manager3__c);
        }
        if (asmObj.ExAM__Related_Assignment_Manager4__c != null) {
            asmTempIdSet.add(asmObj.ExAM__Related_Assignment_Manager4__c);
        }                                        
      } 
      
      for(Questionnaire_Response__c ansObj : [SELECT Decision_Tree_Launched_Question__c, Id, Name,
                                                       Question_Template__c, Response__c,
                                                       Question_Template__r.Question_Type__c,
                                                       Question_Template__r.Subquestion_Label__c,
                                                       Question_Template__r.Name,
                                                       ExAM__Issue_Request__c 
                                                FROM   Questionnaire_Response__c
                                                WHERE  Issue_Request__c IN : asmTempIdSet 
                                                AND Decision_Tree_Launched_Question__c != NULL ORDER BY LastModifiedDate DESC LIMIT 50000]) {
                  
            if (ansObj.Decision_Tree_Launched_Question__c != null) {
            
                Map<Id, Integer> tempMap = new Map<Id, Integer>();
                if(!templateIdAndResponsesCountMap.containsKey(ansObj.Issue_Request__c)){
                    tempMap.put(ansObj.Decision_Tree_Launched_Question__c, 0);
                    templateIdAndResponsesCountMap.put(ansObj.Issue_Request__c,tempMap);
                }else if(!templateIdAndResponsesCountMap.get(ansObj.Issue_Request__c).containsKey(ansObj.Decision_Tree_Launched_Question__c)){
                   
                    tempMap = templateIdAndResponsesCountMap.get(ansObj.Issue_Request__c);
                    tempMap.put(ansObj.Decision_Tree_Launched_Question__c, 0);
                    templateIdAndResponsesCountMap.put(ansObj.Issue_Request__c,tempMap);
                }
                tempMap = templateIdAndResponsesCountMap.get(ansObj.Issue_Request__c);
                Integer responseCount = tempMap.get(ansObj.Decision_Tree_Launched_Question__c);
                responseCount++;
                tempMap.put(ansObj.Decision_Tree_Launched_Question__c, responseCount);
                templateIdAndResponsesCountMap.put(ansObj.Issue_Request__c,tempMap);
            }
      }   
      
      for(Id asmId : templateIdAndResponsesCountMap.keySet()) {
      
          decisionTreeResultList.add(new AnswerWeightClass(asmId, templateIdAndResponsesCountMap.get(asmId), templateIdAndResponsesCountMap.get(asmId).keySet()));      
      }
      return JSON.serialize(decisionTreeResultList);
    }
  
    public static string saveFeedbackAnswers(RestSaveFeedbackAnswers.FeedbackAnswersClass feedbackAnswers){
      
      if(feedbackAnswers != null && feedbackAnswers.answerList.size() > 0){
          IssueRequest_Life_Cycle__c am = new IssueRequest_Life_Cycle__c();
          if(feedbackAnswers.userId != null){
              am.Assessor_Resource__c = feedbackAnswers.userId;
          }
          am.Mobile_App_Feedback_Screen_Name__c = feedbackAnswers.screenName;
          
          List<ExAM_Configuration__c> examConfigurationList = new List<ExAM_Configuration__c>([
            SELECT CreatedDate, Feedback_Template__c
            FROM   ExAM_Configuration__c ORDER BY CreatedDate DESC LIMIT 1
            ]);
            
            if(examConfigurationList.size() > 0){
                am.InvestigationType__c = examConfigurationList[0].Feedback_Template__c;
            }  
            if(feedbackAnswers.decisionTreeQuestionId != null){
                am.Mobile_Feedback_Decision_Tree_Question__c = feedbackAnswers.decisionTreeQuestionId;
            }
            
          insert am;
          for(Questionnaire_Response__c ans : feedbackAnswers.answerList) {
              ans.Issue_Request__c = am.Id;
          }
          upsert feedbackAnswers.answerList;
      }
      return '';
    }
    
    public static string saveFeedbackAnswers(RestGetFeedbackQuestions.FeedbackQuestionsClass feedbackQuestion){
      
      String returnString='';
      List<ExAM_Configuration__c> examConfigurationList = new List<ExAM_Configuration__c>([
            SELECT CreatedDate, Feedback_Template__c
            FROM   ExAM_Configuration__c ORDER BY CreatedDate DESC LIMIT 1
        ]);
        
      if(examConfigurationList.size() > 0){
      
          List<RestGetFeedbackQuestions.FeedbackQuestionTemplateClass> feedbackQuestionTemplateList = new List<RestGetFeedbackQuestions.FeedbackQuestionTemplateClass>();
          
          
          for(Question_Template__c questionTemplate : [SELECT Id, Section_Question__r.Section_label__c, Question_Label__c,
                                                              Section_Question__r.Questionnaire_Section__c, Is_Mandatory__c,
                                                              Question_Type__c, HelpText__c, Subquestion_Label__c
                                                              FROM Question_Template__c 
                                                              WHERE Section_Question__r.Questionnaire_Section__c =: examConfigurationList[0].Feedback_Template__c ]) {
               
               RestGetFeedbackQuestions.FeedbackQuestionTemplateClass qnTemplate = new RestGetFeedbackQuestions.FeedbackQuestionTemplateClass();
               qnTemplate.sectionName = questionTemplate.Section_Question__r.Section_label__c;
               qnTemplate.questionName = questionTemplate.Question_Label__c;
               qnTemplate.questionType = questionTemplate.Question_Type__c;
               qnTemplate.isMandatory = questionTemplate.Is_Mandatory__c;
               qnTemplate.helpText = questionTemplate.HelpText__c;
               qnTemplate.questionId = questionTemplate.Id;
               qnTemplate.answerOptions = questionTemplate.Subquestion_Label__c;
               
               feedbackQuestionTemplateList.add(qnTemplate);
          } 
          returnString = JSON.serialize(feedbackQuestionTemplateList);
      }
      return returnString;
    }
  
    /**
        Method which returns custom lookup field created using Metadata API in Assignment Manager object
    **/
    public static Map<string, string> getReferenceFieldMapInAM() {
    
        Map<string, string> fieldsMap = new Map<string, string>{'Account' => 'ExAM__Facility_Name__c'};
    
        Map<string, Schema.SObjectField> amFieldsMap = ExAM__IssueRequest_Life_Cycle__c.sObjectType.getDescribe().fields.getMap();
        for (Schema.SObjectField eachfield : amFieldsMap.Values()) {
    
            Schema.DescribeFieldResult dfr = eachfield.getDescribe();
            if (dfr.isCustom() && (dfr.getType() == Schema.DisplayType.REFERENCE) && dfr.getName().startsWithIgnoreCase('AM_')) {
                fieldsMap.put(dfr.getReferenceTo().get(0).getDescribe().getName(), dfr.getName());
            }
        }
        return fieldsMap;
    }
  
}