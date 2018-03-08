public with sharing class DataManagementController {

    public Boolean isFromLensViewer{ get; set; }
    
    public class AnswerDetails {
        public List<Schema.FieldSetMember> configuredAnswerFieldsJson { get; set; }
        public List<AnswerClass> answerList { get; set; }
    }

    public class AnswerClass {
        public Questionnaire_Response__c answer { get; set; }
        public String hasAttached { get; set; }
    }

    public class ErrorClass {
        public string errType { get; set; }
        public string errMsg { get; set; }
    }
    
    public DataManagementController() {

        isFromLensViewer = false;

        String assignmentManagerId = '';
        String answerResponseListStr = '';

        assignmentManagerId = ApexPages.currentPage().getParameters().get('amid');

        if (string.isNotBlank(assignmentManagerId) && assignmentManagerId != 'null') {
            answerResponseListStr = queryAllAnswerRecords(assignmentManagerId, isFromLensViewer);
        }
    }

    @RemoteAction
    public static String queryAllAnswerRecords(String assignmentManagerId, Boolean isFromLensViewer) {

        String answerResponse = '';
        AnswerDetails ansDtls = new AnswerDetails();
        ErrorClass errClass;
        List<AnswerClass> answerResponseList = new List<AnswerClass> ();
        Set<Id> attHadAssignmentManagerIDSet = new Set<Id>();
        Set<Id> amIdSet = new Set<Id>();
        List<String> questionTypeList = new List<String>();
        
        try{
        
        SFDCAccessController accessForobj = ExAMUtilClass.AccessController;
        List<String> fieldsList = new List<String>{'ExAM__Data_Management_Tab_Filter__c'};
        accessForobj.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Exam_Configuration__c'), fieldsList);

        List<Exam_Configuration__c> exConfigRecordList = new List<Exam_Configuration__c>([SELECT Id, Name, ExAM__Data_Management_Tab_Filter__c FROM ExAM_Configuration__c LIMIT 1]);
        if (exConfigRecordList != null && exConfigRecordList.size() > 0) {
            Exam_Configuration__c exConfigRecord = exConfigRecordList[0];
            if (string.isNotBlank(exConfigRecord.ExAM__Data_Management_Tab_Filter__c) ) {
                if (exConfigRecord.ExAM__Data_Management_Tab_Filter__c.contains(',') ) {
                    for (String type : exConfigRecord.ExAM__Data_Management_Tab_Filter__c.split(',') ) {
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

        if (String.isNotBlank(assignmentManagerId)) {
            
                List<String> fieldsList1 = new List<String>{'ExAM__Related_Assignment_Manager1__c','ExAM__Related_Assignment_Manager2__c','ExAM__Related_Assignment_Manager3__c','ExAM__Related_Assignment_Manager4__c'};
                accessForobj.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__IssueRequest_Life_Cycle__c'), fieldsList1);
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

                    String answerObj_Select_Clause = 'Id, ExAM__Question_Template__c, ExAM__Question_Template__r.ExAM__Question_Type__c, ExAM__Question_Template__r.ExAM__Question_Label__c, ExAM__Question_Template__r.ExAM__Section_Question__c, ExAM__Question_Template__r.ExAM__Section_Question__r.ExAM__Section_label__c, ';
                    String answerObj_From_Clause = 'ExAM__Questionnaire_Response__c';
                    String answerObj_Where_Clause = 'ExAM__Issue_Request__c IN :amIdSet';
                    if (questionTypeList.size() > 0) {
                        answerObj_Where_Clause += ' AND ExAM__Question_Template__r.ExAM__Question_Type__c IN :questionTypeList';
                    }
                    String answerObj_Orderby_Clause = 'CreatedDate DESC';

                    for(Schema.FieldSetMember f : answerFieldsList) {
                        answerObj_Select_Clause += f.getFieldPath() + ', ';
                    }
                    if (answerObj_Select_Clause.endsWith(', ')) {
                        answerObj_Select_Clause = answerObj_Select_Clause.substring(0, answerObj_Select_Clause.length()-2);
                    }
                    String answerObj_Query_Str = 'SELECT '+answerObj_Select_Clause+' FROM '+answerObj_From_Clause+' WHERE '+answerObj_Where_Clause+' ORDER BY '+answerObj_Orderby_Clause;

                    
                        List<String> fieldsList2 = new List<String>{'ExAM__Question_Template__c'};
                        accessForobj.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Questionnaire_Response__c'), fieldsList2);
                        
                        List<String> fieldsList3 = new List<String>{'ExAM__Question_Type__c','ExAM__Question_Label__c','ExAM__Section_Question__c'};
                        accessForobj.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Question_Template__c'), fieldsList3);
                        
                        List<String> fieldsList4 = new List<String>{'ExAM__Section_label__c'};
                        accessForobj.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Section_Template__c'), fieldsList4);

                        List<Questionnaire_Response__c> answerList = new List<Questionnaire_Response__c>();
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
                            ansDtls = new AnswerDetails();
                            ansDtls.configuredAnswerFieldsJson = answerFieldsList;//JSON.serialize(answerFieldsList);
                            ansDtls.answerList = answerResponseList;
                            return JSON.serialize(ansDtls);
                        }
                        else {
                            errClass = new ErrorClass();
                            errClass.errType = 'RecordsNotAvailable';
                            errClass.errMsg = 'Exception-Answer records not exists';
                            answerResponse = JSON.serialize(errClass);
                        }
                    
                }          
                else {
                    errClass = new ErrorClass();
                    errClass.errType = 'RecordsNotAvailable';
                    errClass.errMsg = 'No Assignment Manager exists with given Id';
                    answerResponse = JSON.serialize(errClass);
                }
            
        }
        else {
            errClass = new ErrorClass();
            errClass.errType = 'IdNotDefined';
            errClass.errMsg = 'Assignment Manager Id not defined';
            answerResponse = JSON.serialize(errClass);
        }
        }catch(Exception e){
                errClass = new ErrorClass();
                errClass.errType = 'PermissionIssue';
                errClass.errMsg = e.getmessage();
                answerResponse = JSON.serialize(errClass);
        }
        return answerResponse;
    }
    @RemoteAction 
    public static String deleteAnswerRecord(String answerId) {
        String resultMsg = '';
        try {
            if (answerId != null && answerId != '') {
                Questionnaire_Response__c delAns = new Questionnaire_Response__c(Id = Id.ValueOf(answerId ));
                SFDCAccessController accessForobj = ExAMUtilClass.AccessController;
                if(accessForobj.isAuthorizedToDelete(Schema.getGlobalDescribe().get('exam__Questionnaire_Response__c'))){
                    Delete delAns;
                    resultMsg = 'success';
                }else{
                    resultMsg = 'You don\'t have access to delete Answer record';
                }
            }
        } catch(Exception e) {
            resultMsg = e.getMessage();
        }
        return resultMsg;
    }
}