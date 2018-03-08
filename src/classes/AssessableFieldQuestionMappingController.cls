public with sharing class AssessableFieldQuestionMappingController {
    
    public string assessableObjectJSON { get; set; }
    public string assessmentTemplateJSON { get; set; }    
    public string assessableMappingList { get; set; }
    public string assMappingResponseListJSON { get; set; }
    public string amFieldsListJSON { get; set; }
    public string accessViolationMsg { get; set; }

    public List<AssessableMappingClass> assMappingResponseList { get; set; } 

    public class AssessableObjectClass {
        public string objectApi;
        public string objectLabel;
    }
    
    public class FieldClass {
        public string fieldApi;
        public string fieldLabel;
        public string fieldType;
    }
    
    public class AssessableMappingClass {
        public string assessableFieldsApi;
        public string questionId;
        public string MappingRecordId;
        public string storeAnswerResponseOrWeight;
        public string mappedFrom;
        public string amFieldAPI;
        public string entity;
        public Boolean isDisableFlag;
    }

    public class AFMSaveResponseClass {
        public Boolean status;
        public string resultMsg;
        public String assMappingFields;
    }

    public class AssessableFieldsDetail {
        public List<FieldClass> fieldsDetail;
        public string errorMsg;
    }

    public class AFMDetail {
        public string afms;
        public string errorMsg;
    }

    public class QuestionsDetail {
        public List<Question_Template__c> questions;
        public string errorMsg;
    }
    
    public AssessableFieldQuestionMappingController() {
        
        try {

            assessableObjectJSON = '';
            assessmentTemplateJSON = '';
            amFieldsListJSON = '';

            List<AssessableObjectClass> assessableObjectList = new List<AssessableObjectClass>();

            assMappingResponseList = new List<AssessableMappingClass>();
            assMappingResponseListJSON = JSON.serialize(assMappingResponseList);
            AssessableObjectClass assclss = new AssessableObjectClass();
            assclss.objectApi = '';
            assclss.objectLabel = '--None--';
            assessableObjectList.add(assclss);
        
            List<FieldClass> amFieldClassList = new List<FieldClass>();

            ExAMUtilClass.AssessableObjectDetails objectDetails = ExAMUtilClass.getAssessableObjectDetails('ExAM__IssueRequest_Life_Cycle__c');
            for (string objectAPIName : objectDetails.objectAPIAndLabelMap.keySet()) {

                AssessableObjectClass asscls = new AssessableObjectClass();
                asscls.objectApi = objectAPIName;
                asscls.objectLabel = objectDetails.objectAPIAndLabelMap.get(objectAPIName);
                assessableObjectList.add(asscls);
            }

            Map<string, Schema.SObjectField> assignmentManagerFieldNameAPIMap = ExAMUtilClass.getSObjectFieldsMap('ExAM__IssueRequest_Life_Cycle__c');
            for (Schema.SObjectField eachSObjField : assignmentManagerFieldNameAPIMap.Values()) {

                Schema.DescribeFieldResult dfr = eachSObjField.getDescribe();

                FieldClass fcls = new FieldClass();     
                fcls.fieldApi = dfr.getName();      
                fcls.fieldLabel = dfr.getLabel();       
                fcls.fieldType = string.valueOf(dfr.getType());     
                amFieldClassList.add(fcls);    
            }
            if (assessableObjectList.size() > 0) {
                assessableObjectJSON = JSON.serialize(assessableObjectList);
            }
            if (amFieldClassList.size() > 0) {      
                amFieldsListJSON = JSON.serialize(amFieldClassList);
            }

            SFDCAccessController accessAT = ExAMUtilClass.AccessController;
            List<string> fieldsListAT = new List<string>{'ExAM__Template_name__c'};
            accessAT.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Main_questionaire__c'), fieldsListAT);

            //get Assessment Template list 
            List<Main_questionaire__c> assTemplateList = [SELECT Id, Name, Template_Name__c FROM Main_questionaire__c ORDER BY LastModifiedDate DESC LIMIT 1000];
            if (assTemplateList != null && assTemplateList.size() > 0) {
                assessmentTemplateJSON = JSON.serialize(assTemplateList);
            }
        }
        catch(Exception e) {
            accessViolationMsg = e.getMessage();
        }
    }
    
    @RemoteAction
    public static string assessableFields(string objectName) {

        string response = '';
        AssessableFieldsDetail fieldsDtl;
        try {

            List<FieldClass> FieldClassList = new List<FieldClass>();

            Map<string, Schema.SObjectField> fieldMap = ExAMUtilClass.getSObjectFieldsMap( objectName );
            for (Schema.SObjectField assField : fieldMap.Values()) {

                Schema.DescribeFieldResult fieldDesc = assField.getDescribe();
                if (!fieldDesc.isCalculated()  && !(fieldDesc.getType() == Schema.DisplayType.REFERENCE) && fieldDesc.isCreateable() && fieldDesc.isUpdateable()  
                        && (fieldDesc.getType() == Schema.DisplayType.string || fieldDesc.getType() == Schema.DisplayType.TEXTAREA 
                            || fieldDesc.getType() == Schema.DisplayType.PICKLIST || fieldDesc.getType() == Schema.DisplayType.DATETIME
                            || fieldDesc.getType() == Schema.DisplayType.DATE || fieldDesc.getType() == Schema.DisplayType.DOUBLE
                            || fieldDesc.getType() == Schema.DisplayType.EMAIL || fieldDesc.getType() == Schema.DisplayType.PHONE
                            || fieldDesc.getType() == Schema.DisplayType.INTEGER )) {

                    FieldClass fcls = new FieldClass();
                    fcls.fieldApi = fieldDesc.getName();
                    fcls.fieldLabel = fieldDesc.getLabel();
                    fcls.fieldType = string.valueOf(fieldDesc.getType());
                    FieldClassList.add(fcls);
                }        
            }
            if (FieldClassList != null && FieldClassList.size() > 0) {
                fieldsDtl = new AssessableFieldsDetail();
                fieldsDtl.fieldsDetail = FieldClassList;
                fieldsDtl.errorMsg = '';
                response = JSON.serialize(fieldsDtl);
            }
        }
        catch(Exception e) {
            fieldsDtl = new AssessableFieldsDetail();
            fieldsDtl.fieldsDetail = new List<FieldClass>();
            fieldsDtl.errorMsg = e.getMessage();
            response = JSON.serialize(fieldsDtl);
        }
        return response;
    }

    @RemoteAction
    public static string existingFieldMapping(string selectedobj, string selectedTemp, Boolean isCaseResponse) {    

        string response = '';
        AFMDetail afmDtl;
        try {

            List<string> entityList = new List<string>{'Case', 'Lead'};

            SFDCAccessController accessAFM = ExAMUtilClass.AccessController;
            List<string> fieldsListAFM = new List<string>{'ExAM__Assessable_Object_API__c', 'ExAM__Assessable_Object_Field_API__c', 'ExAM__Question_Template__c', 'ExAM__Assessment_Template__c', 'ExAM__Entity__c', 'ExAM__Is_Case_Response__c', 'ExAM__Store_Answer_Response_Or_Score__c', 'ExAM__Mapped_From__c', 'ExAM__Assignment_Manager_Field_API__c'};
            accessAFM.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Assessable_Fields_Mapping__c'), fieldsListAFM);

            string SELECT_CLAUSE = 'Assessable_Object_API__c, Assessable_Object_Field_API__c, Question_Template__c,';
            SELECT_CLAUSE += ' Assessment_Template__c, Entity__c, Id, Is_Case_Response__c, Store_Answer_Response_Or_Score__c,';
            SELECT_CLAUSE += ' Mapped_From__c, Assignment_Manager_Field_API__c';

            string FROM_CLAUSE = 'Assessable_Fields_Mapping__c';

            string WHERE_CLAUSE = (isCaseResponse) ? 'Assessable_Object_API__c IN :entityList' : 'Assessable_Object_API__c = :selectedobj';
            WHERE_CLAUSE += ' AND Assessment_Template__c = :selectedTemp';
            WHERE_CLAUSE += ' AND Assessable_Object_Field_API__c != null';
            WHERE_CLAUSE += ' AND ((Question_Template__c != null) OR (Assignment_Manager_Field_API__c != null))';
            WHERE_CLAUSE += ' AND Is_Case_Response__c = :isCaseResponse';

            if (isCaseResponse) {
                WHERE_CLAUSE += ' AND ((Entity__c = null) OR (Entity__c IN :entityList))';
            }

            string QUERYstring = 'SELECT '+SELECT_CLAUSE+' FROM '+FROM_CLAUSE+' WHERE '+WHERE_CLAUSE+' ORDER BY LastModifiedDate DESC';
            system.debug(':::::QUERYstring:::::'+QUERYstring);

            List<AssessableMappingClass> resultMappingList = new List<AssessableMappingClass>();
            for (Assessable_Fields_Mapping__c existMapping : Database.query(QUERYstring) ) {
            
                AssessableMappingClass exMapping = new AssessableMappingClass();
                exMapping.assessableFieldsApi = existMapping.Assessable_Object_Field_API__c;
                exMapping.questionId = existMapping.Question_Template__c;
                exMapping.MappingRecordId = existMapping.Id;
                exMapping.storeAnswerResponseOrWeight = (string.isNotBlank(existMapping.Store_Answer_Response_Or_Score__c) ) ? existMapping.Store_Answer_Response_Or_Score__c : 'Response';
                exMapping.mappedFrom = (string.isNotBlank(existMapping.Mapped_From__c) ) ? existMapping.Mapped_From__c : 'Answer';
                exMapping.amFieldAPI = (string.isNotBlank(existMapping.Assignment_Manager_Field_API__c) ) ? existMapping.Assignment_Manager_Field_API__c : '';
                exMapping.entity = (string.isNotBlank(existMapping.Entity__c) ) ? existMapping.Entity__c : (isCaseResponse) ? 'Case' : 'Other';
                exMapping.isDisableFlag = true;
                resultMappingList.add(exMapping);            
            }
            String returnStr = '';
            if(resultMappingList.size() > 0 ) {
                returnStr = JSON.serialize(resultMappingList);
            }
            afmDtl = new AFMDetail();
            afmDtl.afms = returnStr;
            afmDtl.errorMsg = '';
            response = JSON.serialize(afmDtl);
        }
        catch(Exception e) {
            afmDtl = new AFMDetail();
            afmDtl.afms = '';//new List<AssessableMappingClass>();
            afmDtl.errorMsg = e.getMessage();
            response = JSON.serialize(afmDtl);
        }
        return response;
    }

    @RemoteAction
    public static string getQuestionRecords(string templateId) {        

        string response = '';
        QuestionsDetail qtnDetail;
        try {

            SFDCAccessController accessST = ExAMUtilClass.AccessController;
            List<string> fieldsListST = new List<string>{'ExAM__Questionnaire_Section__c', 'ExAM__Section_label__c'};
            accessST.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Section_Template__c'), fieldsListST);

            SFDCAccessController accessQT = ExAMUtilClass.AccessController;
            List<string> fieldsListQT = new List<string>{'ExAM__Question_Label__c', 'ExAM__Question_Type__c', 'ExAM__Section_Question__c'};
            accessQT.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Question_Template__c'), fieldsListQT);

            List<Question_Template__c> quesList =  [
                SELECT   Id, Name, Question_Label__c, Section_Question__c, Question_Type__c,
                         Section_Question__r.Name, Section_Question__r.Section_label__c, Section_Question__r.Questionnaire_Section__c  
                FROM     Question_Template__c
                WHERE    Section_Question__c !=null
                         AND Section_Question__r.Questionnaire_Section__c =:templateId
                ORDER BY Section_Question__c ASC NULLS LAST
            ];    
            if (quesList != null && quesList.size() > 0) {
                qtnDetail = new QuestionsDetail();
                qtnDetail.questions = quesList;
                qtnDetail.errorMsg = '';
                response = JSON.serialize(qtnDetail);
            }
        }
        catch(Exception e) {
            qtnDetail = new QuestionsDetail();
            qtnDetail.questions = new List<Question_Template__c>();
            qtnDetail.errorMsg = e.getMessage();
            response = JSON.serialize(qtnDetail);
        }
        return response;
    }
    
    @RemoteAction
    public static string saveFieldMapping( string assObjName, List<AssessableMappingClass> mapping, string AssessmentTempId, Boolean isCaseResponse) {

        string response = '';
        AFMSaveResponseClass res;
        try {

            if ((assObjName != '' && assObjName != null)
                && (AssessmentTempId != null && AssessmentTempId != '')
                && (mapping != null && mapping.size() > 0)
            ) {

                List<Assessable_Fields_Mapping__c> upsertRecordList = new List<Assessable_Fields_Mapping__c>();
                for (AssessableMappingClass amc : mapping) {

                    Assessable_Fields_Mapping__c mappingRecord = new Assessable_Fields_Mapping__c();
                    if (amc.MappingRecordId != null && amc.MappingRecordId != '') {
                        mappingRecord.Id = amc.MappingRecordId;
                    }
                    mappingRecord.Assessable_Object_API__c = assObjName;
                    mappingRecord.Assessable_Object_Field_API__c = amc.AssessableFieldsApi;
                    mappingRecord.Assessment_Template__c = AssessmentTempId;
                    mappingRecord.Is_Case_Response__c = isCaseResponse;
                    mappingRecord.Mapped_From__c = (string.isNotBlank(amc.mappedFrom) ) ? amc.mappedFrom : 'Answer';
                    if (mappingRecord.Mapped_From__c == 'Answer') {     
                        mappingRecord.Question_Template__c = amc.questionId;        
                        mappingRecord.Store_Answer_Response_Or_Score__c = (string.isNotBlank(amc.storeAnswerResponseOrWeight) ) ? amc.storeAnswerResponseOrWeight : 'Response';     
                    }       
                    else if (mappingRecord.Mapped_From__c == 'Assignment Manager') {        
                        mappingRecord.Assignment_Manager_Field_API__c = (string.isNotBlank(amc.amFieldAPI) ) ? amc.amFieldAPI : '';     
                    }
                    mappingRecord.Entity__c = (string.isNotBlank(amc.entity) ) ? amc.entity : 'Other';
                    upsertRecordList.add(mappingRecord);
                } 
            
                if (upsertRecordList != null && upsertRecordList.size() > 0) {

                    SFDCAccessController accessAFM = ExAMUtilClass.AccessController;
                    List<string> fieldsListAFM = new List<string>{'ExAM__Assessable_Object_API__c', 'ExAM__Assessable_Object_Field_API__c', 'ExAM__Question_Template__c', 'ExAM__Assessment_Template__c', 'ExAM__Entity__c', 'ExAM__Is_Case_Response__c', 'ExAM__Store_Answer_Response_Or_Score__c', 'ExAM__Mapped_From__c', 'ExAM__Assignment_Manager_Field_API__c'};
                    accessAFM.assertAuthorizedToCreate(Schema.getGlobalDescribe().get('exam__Assessable_Fields_Mapping__c'), fieldsListAFM);
                    accessAFM.assertAuthorizedToupdate(Schema.getGlobalDescribe().get('exam__Assessable_Fields_Mapping__c'), fieldsListAFM);

                    upsert upsertRecordList;

                    /*List<AssessableMappingClass> responselist = new List<AssessableMappingClass>();
                    for (Assessable_Fields_Mapping__c afm : upsertRecordList) {
                        AssessableMappingClass amc = new AssessableMappingClass();
                        amc.assessableFieldsApi = afm.Assessable_Object_Field_API__c;
                        amc.questionId = afm.Question_Template__c; 
                        amc.MappingRecordId = afm.Id;
                        amc.storeAnswerResponseOrWeight = afm.Store_Answer_Response_Or_Score__c;
                        amc.mappedFrom = afm.Mapped_From__c;
                        amc.amFieldAPI = afm.Assignment_Manager_Field_API__c;
                        amc.entity = (string.isNotBlank(afm.Entity__c) ) ? afm.Entity__c : 'Other';
                        responselist.add(amc);
                    }*/
                    res = new AFMSaveResponseClass();
                    res.status = true;
                    res.resultMsg = 'Saved field mapping.';
                    //res.assMappingList = responselist;
                    res.assMappingFields = existingFieldMapping(assObjName,AssessmentTempId,isCaseResponse);
                    
                }
            }
            else {
                res = new AFMSaveResponseClass();
                res.status = false;
                res.resultMsg = 'Please select Assessable Entity, Assessment Template and configure field mapping.';
                //res.assMappingList = new List<AssessableMappingClass>();
                res.assMappingFields = '';
            }
        }
        catch(Exception e) {
            res = new AFMSaveResponseClass();
            res.status = false;
            res.resultMsg = e.getMessage();
            //res.assMappingList = new List<AssessableMappingClass>();
            res.assMappingFields = '';
            
        }
        response = JSON.serialize( res );
        return response;
    }

    @RemoteAction
    public static void deleteMappingRecord(string mappingId) {
        string deleteResponseMsg = '';
        try {
            SFDCAccessController accessAFM = ExAMUtilClass.AccessController;
            if(accessAFM.isAuthorizedToDelete(Schema.getGlobalDescribe().get('exam__Assessable_Fields_Mapping__c'))){
                Assessable_Fields_Mapping__c afm = new Assessable_Fields_Mapping__c(Id = mappingId);
                delete afm;
            }
            else {
                deleteResponseMsg = 'You don\'t have permission to delete Assessable Field Mapping record';
            }
        } catch(Exception ex) {
            deleteResponseMsg = ex.getMessage();
        }
    }

    @RemoteAction
    public static string deleteExistingAFMs(List<Assessable_Fields_Mapping__c> existingAFMs) {
        string deleteResponseMsg = '';
        try {
            if (!existingAFMs.isEmpty()) {
                SFDCAccessController accessAFM = ExAMUtilClass.AccessController;
                if(accessAFM.isAuthorizedToDelete(Schema.getGlobalDescribe().get('exam__Assessable_Fields_Mapping__c'))){
                    delete existingAFMs;
                    deleteResponseMsg = 'Existing records deleted successfully';
                }
                else {
                    deleteResponseMsg = 'You don\'t have permission to delete Assessable Field Mapping record';
                }
            }
        } catch(Exception ex) {
            deleteResponseMsg = ex.getMessage();
        }
        return deleteResponseMsg;
    }
}