public with sharing class GeneralConfigController {
    
    public static SF_sub_domain__c sfsubdomain { get; set; }
    public static String ObjStr {get;set;}
    public Static Set<String> alreadyCreateFieldSet;
    public Static Map<String, String> objectAPILabelMap = new Map<String, String>();
    public Static Boolean errorMsg ;

    //Google Map API
    public Static GoogleMapsAPIKey__c gleMapAPI{ get;set; }
    
    public Boolean skipAnswerForDecisionTreeSteps { get; set; }
    public Boolean RelateDecisionTreeonContinueButton { get; set; } // added this for RelateDecisionTreeonContinueButton on 29 nov 2017
    public Boolean fieldMappingConfiguration { get; set; }
    public string siteurl { get; set; }

    public string weburl { get; set; }

    public string sfsubdomainEndPointUrl { get; set; }
    public string googleMapAPIKey { get; set; }
    public string googleMapAPIKey1 { get; set; }

    public GeneralConfigController() {
    
        //Google Map Configuration
        ObjStr = '';
        try{
            SFDCAccessController accessObj = ExAMUtilClass.AccessController;
            /*List<String> fieldsListGM = new List<String>{'ExAM__API_Key__c'};
            accessObj.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__GoogleMapsAPIKey__c'), fieldsListGM);*/
            
            List<GoogleMapsAPIKey__c> qryList = new List<GoogleMapsAPIKey__c>();
            gleMapAPI = new GoogleMapsAPIKey__c();
            gleMapAPI.Name = 'GoogleMapsAPIKey';
            googleMapAPIKey = '';
            googleMapAPIKey1 = 'API KEY NOT DEFINED';
            qryList = [SELECT Name,API_Key__c FROM GoogleMapsAPIKey__c WHERE Name = 'GoogleMapsAPIKey' LIMIT 1];
            if(qryList != null && qryList.size()>0){
                gleMapAPI = qryList[0];
                googleMapAPIKey = qryList[0].API_Key__c;
                if ( string.isNotBlank(qryList[0].API_Key__c) ) {
                    googleMapAPIKey1 = qryList[0].API_Key__c;
                }
            }
            
            //General configuration
            sfsubdomain = new SF_sub_domain__c();
            sfsubdomain.Name = 'EndPointURL';
            sfsubdomainEndPointUrl = '';
            alreadyCreateFieldSet = new Set<String>();
            
            /*List<String> fieldsListSFS = new List<String>{'ExAM__EndPointURL__c'};
            accessObj.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__SF_sub_domain__c'), fieldsListSFS);*/
            
            List<SF_sub_domain__c> sfsubdomainList = [SELECT Id, Name, EndPointURL__c FROM SF_sub_domain__c WHERE Name = 'EndPointURL'];
            if (sfsubdomainList != null && sfsubdomainList.size() > 0) {
                sfsubdomain = sfsubdomainList[0];
                sfsubdomainEndPointUrl = sfsubdomain.EndPointURL__c;
            }
            
            List<String> fieldsListEC = new List<String>{'ExAM__Primary_Assessment_Type_Template__c','ExAM__Related_Assessment_Type_1_Template__c','ExAM__Related_Assessment_Type_2_Template__c',
                                                        'ExAM__Related_Assessment_Type_3_Template__c','ExAM__Skip_Answer_For_Decision_Tree_Steps__c','ExAM__Is_Field_Mapping__c'};
            accessObj.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__ExAM_Configuration__c'), fieldsListEC);
            List<ExAM_Configuration__c> examConfigList = [
                SELECT Hours__c, Id, Name, Primary_Assessment_Type_Template__c, Related_Assessment_Type_1_Template__c, 
                       Related_Assessment_Type_2_Template__c, Related_Assessment_Type_3_Template__c, Skip_Answer_For_Decision_Tree_Steps__c,
                       Is_Field_Mapping__c,ExAM__Relate_Decision_Tree_on_Continue_Button__c                                       // added this for RelateDecisionTreeonContinueButton on 29 nov 2017
                FROM   ExAM_Configuration__c ORDER BY CreatedDate DESC LIMIT 1
            ];
              
            if (examConfigList != null && examConfigList.size() > 0) {    
                skipAnswerForDecisionTreeSteps = examConfigList[0].Skip_Answer_For_Decision_Tree_Steps__c; 
                RelateDecisionTreeonContinueButton = examConfigList[0].ExAM__Relate_Decision_Tree_on_Continue_Button__c;  //added this for RelateDecisionTreeonContinueButton on 29 nov 2017
                fieldMappingConfiguration = examConfigList[0].Is_Field_Mapping__c;
            }
            
            Public_Assessment_Configuration__c pac = Public_Assessment_Configuration__c.getInstance( UserInfo.getOrganizationId() );
            if (pac != null) {
    
                siteurl = pac.Site_URL__c;
            }
    
            Web_Intercept_Configuration__c wic = Web_Intercept_Configuration__c.getInstance( UserInfo.getOrganizationId() );
            if (wic != null) {
    
                weburl = wic.Web_URL__c;
            }
    
            errorMsg = false;
            alreadyCreatedFields();
            loadObjects();
        } catch( Exception e ){
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()) );
        }
    }
    
    @RemoteAction 
    public static string saveGoogleAPI(string apiKey) {
        if (apiKey != null && apiKey != '') {
            gleMapAPI = new GoogleMapsAPIKey__c();
            try {
                /*SFDCAccessController accessObj = ExAMUtilClass.AccessController;
                List<String> fieldsGM = new List<String>{'ExAM__API_Key__c'};
                accessObj.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__GoogleMapsAPIKey__c'), fieldsGM);*/
                
                List<GoogleMapsAPIKey__c > googleapikeyList = [SELECT Id, Name, API_Key__c FROM GoogleMapsAPIKey__c  WHERE Name = 'GoogleMapsAPIKey'];
                if (googleapikeyList != null && googleapikeyList.size() > 0) {
                    gleMapAPI.Id = googleapikeyList[0].Id;
                }
                gleMapAPI.Name = 'GoogleMapsAPIKey';
                gleMapAPI.API_Key__c = apiKey;    
                
                //accessObj.assertAuthorizedToCreate(Schema.getGlobalDescribe().get('exam__GoogleMapsAPIKey__c'), fieldsGM);
                
                upsert gleMapAPI;
            } catch (exception ex) {
                return ex.getMessage();
            }
        }        
        return null;
    
    }
    
    public void alreadyCreatedFields() {
        Map<String, Schema.SObjectField> schemaFieldMap = Schema.SObjectType.ExAM__IssueRequest_Life_Cycle__c.fields.getMap();
        alreadyCreateFieldSet = new Set<String>();
        
        for (Schema.SObjectField fld : schemaFieldMap.values()) {
            Schema.DescribeFieldResult res = fld.getdescribe();
            if (String.valueOf(res.getType()).touppercase() == 'REFERENCE' && res.isCustom() && res.getLocalName().startsWithIgnoreCase('AM_')) {
                alreadyCreateFieldSet.add( res.getLocalName().toUpperCase() );
            }                
        }
    }
    
    @RemoteAction
    public static string saveEndpointUrl(String endpoint) {

        String pageMsg = '';
        try {
            
            if (endpoint != null && endpoint != '') {
                //List<SF_sub_domain__c> sfsubdomainList = new List<SF_sub_domain__c>();
                /*SFDCAccessController accessObj = ExAMUtilClass.AccessController;
                List<String> fieldsListSFS = new List<String>{'ExAM__EndPointURL__c'};
                accessObj.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__SF_sub_domain__c'), fieldsListSFS);*/
                
                sfsubdomain = new SF_sub_domain__c();
                List<SF_sub_domain__c> sfsubdomainList = [SELECT Id, Name, EndPointURL__c FROM SF_sub_domain__c WHERE Name = 'EndPointURL'];
                if (sfsubdomainList != null && sfsubdomainList.size() > 0) {
                    sfsubdomain.Id = sfsubdomainList[0].Id;
                }
                sfsubdomain.Name = 'EndPointURL';
                sfsubdomain.EndPointURL__c = endpoint;    
                
                //accessObj.assertAuthorizedToCreate(Schema.getGlobalDescribe().get('exam__SF_sub_domain__c'), fieldsListSFS);
                upsert sfsubdomain;
                pageMsg = 'Success';
            } 
        } catch( Exception e ){       
            pageMsg = e.getMessage();
        }
        return pageMsg;
    }
    
    
    public static void loadObjects() {
        List<SelectListOptions>  Objes = new List<SelectListOptions>();

        List<SelectListOptions> options = new List<SelectListOptions>();
        if( !alreadyCreateFieldSet.contains(('AM_Contact__c').toUpperCase()) ) {
            options.add(new SelectListOptions('Contact', 'Contact'));
        }
        if( !alreadyCreateFieldSet.contains(('AM_User__c').toUpperCase()) ) {
            options.add(new SelectListOptions('User', 'User'));
        } 
        if( !alreadyCreateFieldSet.contains(('AM_Opportunity__c').toUpperCase()) ) {
            options.add(new SelectListOptions('Opportunity', 'Opportunity'));
        }
        if( !alreadyCreateFieldSet.contains(('AM_Lead__c').toUpperCase()) ) {
            options.add(new SelectListOptions('Lead', 'Lead'));
        } 
        if( !alreadyCreateFieldSet.contains(('AM_Case__c').toUpperCase()) ) {
            options.add(new SelectListOptions('Case', 'Case'));
        }
        if( !alreadyCreateFieldSet.contains(('AM_Product2__c').toUpperCase()) ) {
            options.add(new SelectListOptions('Product2', 'Product'));
        }
        objectAPILabelMap.put('User','User');
        objectAPILabelMap.put('Contact','Contact');
        objectAPILabelMap.put('Opportunity','Opportunity');
        objectAPILabelMap.put('Lead','Lead');
        objectAPILabelMap.put('Case','Case');
        objectAPILabelMap.put('Product2','Product');
        Map<String, Schema.SObjectType> gd = schema.getGlobalDescribe();
        set<string> objectSet = new Set<String>();
        
        for(SObjectType sObj : gd.values()) {

            Schema.DescribeSObjectResult objDescription = sObj.getDescribe();
            if( objDescription.isCustom() == true && objDescription.customSetting == false ) {
                
                //String lookupFieldName = namespace+'AM_'+objDescription.getLocalName();
                String lookupFieldName = 'AM_'+objDescription.getLocalName();
                
                if( !alreadyCreateFieldSet.contains(lookupFieldName.toUpperCase()) ) {
                    options.add(new SelectListOptions(objDescription.getName(), objDescription.getLabel()));    
                }                
                
                
                objectAPILabelMap.put(objDescription.getName(),objDescription.getLabel());
            }
        }
        Objes = options;
        ObjStr = JSON.serialize(Objes);
    }
    
    @RemoteAction
    public static string createLookupField(String selectedObj)
    {

        String resultMessage = '';
        try {
            String createdFieldApiName = '';
            //errorMsg = false;
            if( selectedObj != null && selectedObj != '' ) {
                MetadataService.MetadataPort service = new MetadataService.MetadataPort();
                service.SessionHeader = new MetadataService.SessionHeader_element();
                service.SessionHeader.sessionId = UserInfo.getSessionId();

                MetadataService.CustomField customField = new MetadataService.CustomField();                
                MetadataService.CustomField answerCustomField = new MetadataService.CustomField();
                MetadataService.CustomField assessmentGroupJunctionCustomField = new MetadataService.CustomField();
                MetadataService.CustomField paCustomField = new MetadataService.CustomField();
                    
                String relationshipName = selectedObj != null ? selectedObj : '';
                
                //String selectedObjLocalName = selectedObj.replaceFirst(namespace,'');
                String selectedObjLocalName = selectedObj;
                if (selectedObj.countMatches('__') == 2) {
                    selectedObjLocalName = selectedObj.substringAfter('__');
                }
                
                if( selectedObjLocalName.contains('__c') ) {
                    relationshipName = selectedObjLocalName.replace('__c','');
                    //createdFieldApiName = namespace+'AM_'+selectedObjLocalName;
                    createdFieldApiName = 'AM_'+selectedObjLocalName;
                    customField.fullName = 'ExAM__IssueRequest_Life_Cycle__c.AM_'+selectedObjLocalName;
                    answerCustomField.fullName = 'ExAM__Questionnaire_Response__c.ANS_'+selectedObjLocalName;
                    assessmentGroupJunctionCustomField.fullName = 'ExAM__Assessment_Group_Junction__c.AGJ_'+selectedObjLocalName;
                    paCustomField.fullName = 'ExAM__Public_Assessment__c.PA_'+selectedObjLocalName;
                    
                } else {
                    customField.fullName = 'ExAM__IssueRequest_Life_Cycle__c.AM_'+selectedObjLocalName+'__c';
                    //createdFieldApiName = namespace+'AM_'+selectedObjLocalName+'__c';
                    createdFieldApiName = 'AM_'+selectedObjLocalName+'__c';
                    answerCustomField.fullName = 'ExAM__Questionnaire_Response__c.ANS_'+selectedObjLocalName+'__c';
                    assessmentGroupJunctionCustomField.fullName = 'ExAM__Assessment_Group_Junction__c.AGJ_'+selectedObjLocalName+'__c';
                    paCustomField.fullName = 'ExAM__Public_Assessment__c.PA_'+selectedObjLocalName+'__c';
                }
                
                if(objectAPILabelMap != null && objectAPILabelMap.keySet() != null && objectAPILabelMap.containsKey(selectedObj) ) {
                    customField.label = objectAPILabelMap.get(selectedObj);
                    answerCustomField.label = objectAPILabelMap.get(selectedObj);
                    assessmentGroupJunctionCustomField.label = objectAPILabelMap.get(selectedObj);
                    paCustomField.label = objectAPILabelMap.get(selectedObj);
                } else {
                    customField.label = relationshipName;
                    answerCustomField.label = relationshipName;
                    assessmentGroupJunctionCustomField.label = relationshipName;
                    paCustomField.label = relationshipName;
                }

                customField.type_x = 'Lookup';
                answerCustomField.type_x = 'Lookup';
                assessmentGroupJunctionCustomField.type_x = 'Lookup';
                paCustomField.type_x = 'Lookup';

                customField.relationshipLabel = 'Assignment Managers';
                answerCustomField.relationshipLabel = 'Answers';
                assessmentGroupJunctionCustomField.relationshipLabel = 'Assessment Group Junctions';
                paCustomField.relationshipLabel = 'Public Assessments';

                customField.relationshipName = 'AM_'+relationshipName;
                answerCustomField.relationshipName = 'ANS_'+relationshipName;
                assessmentGroupJunctionCustomField.relationshipName = 'AGJ_'+relationshipName;
                paCustomField.relationshipName = 'PA_'+relationshipName;

                customField.referenceTo = selectedObj;
                answerCustomField.referenceTo = selectedObj;
                assessmentGroupJunctionCustomField.referenceTo = selectedObj;
                paCustomField.referenceTo = selectedObj;
                
                //GeoLocation Field Creation Code
                MetadataService.CustomField locationField;
                if (selectedObj != 'User') {

                    locationField = new MetadataService.CustomField();
                    locationField.fullName = selectedObj+'.EX_Location__c';     
                    locationField.label = 'Location';       
                    locationField.type_x = 'Location';      
                    locationField.scale = 6;        
                    //locationField.displayFormat = 'decimal';      
                    locationField.displayLocationInDecimal = true;
                }
                
                List<MetadataService.SaveResult> results = new List<MetadataService.SaveResult>();
                if (!Test.isRunningTest()) { 

                    if (selectedObj != 'User') {
                        results = service.createMetadata( new MetadataService.Metadata[] { customField,answerCustomField, assessmentGroupJunctionCustomField, paCustomField, locationField });
                    }
                    else {
                        results = service.createMetadata( new MetadataService.Metadata[] { customField,answerCustomField, assessmentGroupJunctionCustomField, paCustomField });
                    }
                }
                if (results != null && results.size() > 0 ) {

                    for (MetadataService.SaveResult result : results) {
                        resultMessage = 'successfully created';
                        if (!result.success) {
                            if (result.errors != null && result.errors.size() > 0 ) {
                                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, result.errors[0].message));  
                                errorMsg = true;  
                                resultMessage = result.errors[0].message;  
                                break;  
                            }
                        }
                    }                
                }
            }            
        } catch(Exception e) {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Please check salesforce Domain Name and Remote Site Setting values' );
            ApexPages.addMessage(msg);
            resultMessage = 'Please check salesforce Domain Name and Remote Site Setting values';  
        }
        return resultMessage;
    }

    @RemoteAction
    public static ExamConfigurationAndAssessmentTemplateDetails queryExamConfigRecordAndAllAssessmentTemplates() {

        List<ExAM_Configuration__c> examConfigurationList = new List<ExAM_Configuration__c>();
        List<Main_questionaire__c> questionaireList = new List<Main_questionaire__c>();
        ExAM_Configuration__c examConfigurationRecord = new ExAM_Configuration__c();
        Map<Id, Main_questionaire__c> qMap = new  Map<Id, Main_questionaire__c>();
        String exceptMsg = '';
        ExamConfigurationAndAssessmentTemplateDetails examConfigAndTemplateDetail;
        try{
            SFDCAccessController accessObj = ExAMUtilClass.AccessController;
            
            List<String> fieldsListEC = new List<String>{'ExAM__DTV_Question_Display_Text__c','ExAM__Hide_AM_List_Tab__c','ExAM__Hide_Assessable_Record_Tab__c','ExAM__Hide_Data_Viewer_Tab__c',
                                                    'ExAM__Hide_Knowledge_Article_Tab__c','ExAM__Hide_Related_Assignment_Manager1_Tab__c','ExAM__Hide_Related_Assignment_Manager2_Tab__c','ExAM__Hide_Related_Assignment_Manager3_Tab__c',
                                                    'ExAM__Hide_Related_Assignment_Manager4_Tab__c','ExAM__Hide_Save_Button__c','ExAM__Hours__c','ExAM__Primary_Assessment_Type_Template__c',
                                                    'ExAM__Related_Assessment_Type_1_Template__c','ExAM__Related_Assessment_Type_2_Template__c','ExAM__Related_Assessment_Type_3_Template__c','ExAM__Related_Assessment_Type_4_Template__c',
                                                    'ExAM__Overall_Status_on_Submit__c','ExAM__Assignment_Manager_List_Status_Filter__c','ExAM__Data_Management_Tab_Filter__c','ExAM__Knowledge_Article_Type_Name__c',
                                                    'ExAM__Knowledge_Article_Content_Field_Name__c'};
            accessObj.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__ExAM_Configuration__c'), fieldsListEC);
            
            examConfigurationList = [
                SELECT DTV_Question_Display_Text__c, Hide_AM_List_Tab__c, Hide_Assessable_Record_Tab__c,
                       Hide_Data_Viewer_Tab__c, Hide_Knowledge_Article_Tab__c, Hide_Related_Assignment_Manager1_Tab__c,
                       Hide_Related_Assignment_Manager2_Tab__c, Hide_Related_Assignment_Manager3_Tab__c,
                       Hide_Related_Assignment_Manager4_Tab__c, Hide_Save_Button__c, Hours__c, Id, Name,
                       Primary_Assessment_Type_Template__c, Related_Assessment_Type_1_Template__c,
                       Related_Assessment_Type_2_Template__c, Related_Assessment_Type_3_Template__c,
                       Related_Assessment_Type_4_Template__c, Overall_Status_on_Submit__c,
                       Assignment_Manager_List_Status_Filter__c, Data_Management_Tab_Filter__c,
                       Knowledge_Article_Type_Name__c, Knowledge_Article_Content_Field_Name__c
                FROM   ExAM_Configuration__c ORDER BY CreatedDate DESC LIMIT 1
            ];
            
            List<String> fieldsListAT = new List<String>{'ExAM__Template_Name__c'};
            accessObj.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Main_questionaire__c'), fieldsListAT);
            questionaireList = [SELECT Id, Name, Template_Name__c FROM Main_questionaire__c LIMIT 49999];
            Map<Id, Main_questionaire__c> questionaireMap = new  Map<Id, Main_questionaire__c>( questionaireList );
    
            if ((examConfigurationList != null && examConfigurationList.size() > 0) ) {
    
                examConfigurationRecord = examConfigurationList[0];
            }
            examConfigAndTemplateDetail = new ExamConfigurationAndAssessmentTemplateDetails(examConfigurationRecord, questionaireList, questionaireMap,exceptMsg);
        } catch(Exception e){
            examConfigAndTemplateDetail = new ExamConfigurationAndAssessmentTemplateDetails(examConfigurationRecord, questionaireList, qMap,e.getMessage());
            
        }
        return examConfigAndTemplateDetail;
    }

    @RemoteAction
    public static string saveSelectedTemplateIdsIntoExamConfigurationRecord(ExAM_Configuration__c examConfig) {

        string responseMsg = '';

        try {
            SFDCAccessController accessObj = ExAMUtilClass.AccessController;
            List<String> fieldsEC = new List<String>{'ExAM__Primary_Assessment_Type_Template__c','ExAM__Related_Assessment_Type_1_Template__c',
                                                    'ExAM__Related_Assessment_Type_2_Template__c','ExAM__Related_Assessment_Type_3_Template__c','ExAM__Related_Assessment_Type_4_Template__c'};
            if (examConfig != null) {
                accessObj.assertAuthorizedToCreate(Schema.getGlobalDescribe().get('exam__ExAM_Configuration__c'), fieldsEC);
                accessObj.assertAuthorizedToUpdate(Schema.getGlobalDescribe().get('exam__ExAM_Configuration__c'), fieldsEC);
                upsert examConfig;
                responseMsg = 'success'+'@@'+examConfig.Id;
            }
        }
        catch(Exception exp) {

            if (exp.getTypeName() == 'System.DMLException') {

                responseMsg = exp.getDmlMessage(0);
            }
            else {

                responseMsg = exp.getMessage();
            }
        }    
        return responseMsg;
    }

    public class ExamConfigurationAndAssessmentTemplateDetails {

        public ExAM_Configuration__c examConfigRecord;
        public List<Main_questionaire__c> questionaireRecordsList;
        public Map<Id, Main_questionaire__c> questionaireMap;
        public String exceptionMessage;

        public ExamConfigurationAndAssessmentTemplateDetails(ExAM_Configuration__c exConfig, List<Main_questionaire__c> assessmentList, Map<Id, Main_questionaire__c> assessmentTemplateMap,String exceptMsg) {

            this.examConfigRecord = exConfig;
            this.questionaireRecordsList = assessmentList;
            this.questionaireMap = assessmentTemplateMap;
            this.exceptionMessage = exceptMsg;
        }
    }
    @RemoteAction 
    public static String updateExamConfig(Boolean isSkip, Boolean relateDecision) { // here added Boolean relateDecision on 29 nov 2017.

        String errorMessage = '';
        try {
            SFDCAccessController accessObj = ExAMUtilClass.AccessController;
            List<String> fieldsEC = new List<String>{'ExAM__Primary_Assessment_Type_Template__c','ExAM__Related_Assessment_Type_1_Template__c','ExAM__Related_Assessment_Type_2_Template__c',
                                                    'ExAM__Related_Assessment_Type_3_Template__c','ExAM__Skip_Answer_For_Decision_Tree_Steps__c'};
            accessObj.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__ExAM_Configuration__c'), fieldsEC);
            List<ExAM_Configuration__c> examConfigList = [
                SELECT Hours__c, Id, Name, Primary_Assessment_Type_Template__c, Related_Assessment_Type_1_Template__c, 
                       Related_Assessment_Type_2_Template__c, Related_Assessment_Type_3_Template__c, Skip_Answer_For_Decision_Tree_Steps__c 
                FROM   ExAM_Configuration__c ORDER BY CreatedDate DESC LIMIT 1
            ];
              
            
            ExAM_Configuration__c updateExamConfig = new ExAM_Configuration__c();
            updateExamConfig.Name = 'Configuration';
            if (examConfigList != null && examConfigList.size() > 0) {    
                updateExamConfig.Id = examConfigList[0].Id;
            }
            updateExamConfig.Skip_Answer_For_Decision_Tree_Steps__c = isSkip;
            updateExamConfig.ExAM__Relate_Decision_Tree_on_Continue_Button__c = relateDecision; // added for ExAM__Relate_Decision_Tree_on_Continue_Button__c  on 29 nov 2017
            accessObj.assertAuthorizedToCreate(Schema.getGlobalDescribe().get('exam__ExAM_Configuration__c'), fieldsEC);
            accessObj.assertAuthorizedToUpdate(Schema.getGlobalDescribe().get('exam__ExAM_Configuration__c'), fieldsEC);
            upsert updateExamConfig;
            errorMessage = 'success@@'+updateExamConfig.Id;
        } catch( exception ex) {
            errorMessage = ex.getMessage();
        }        
        return errorMessage;
    }
    @RemoteAction
    public static List<String> getOverallStatusList() {
        
        List<String> statusList = new List<String>();
        
        Schema.DescribeFieldResult fieldResult = IssueRequest_Life_Cycle__c.Status__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
        for( Schema.PicklistEntry f : ple) {
            statusList.add(f.getValue());
        }       
        return statusList;        
    }
    @RemoteAction
    public static string saveStatusinExamConfig(String statusVal) {

        String returnMsg = '';
        try {
            
            SFDCAccessController accessObj = ExAMUtilClass.AccessController;
            List<String> fieldsEC = new List<String>{'ExAM__Overall_Status_on_Submit__c'};
            accessObj.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__ExAM_Configuration__c'), fieldsEC);
            List<ExAM_Configuration__c> exConfigList = [SELECT Id, Overall_Status_on_Submit__c FROM ExAM_Configuration__c ORDER BY CreatedDate DESC LIMIT 1];
                    
            ExAM_Configuration__c upsertConfig = new ExAM_Configuration__c();
            upsertConfig.Name = 'Configuration';   
            if (exConfigList != null && exConfigList.size() > 0) {
                upsertConfig.id = exConfigList[0].Id;
            }
            upsertConfig.Overall_Status_on_Submit__c = statusVal;
            accessObj.assertAuthorizedToCreate(Schema.getGlobalDescribe().get('exam__ExAM_Configuration__c'), fieldsEC);
            accessObj.assertAuthorizedToUpdate(Schema.getGlobalDescribe().get('exam__ExAM_Configuration__c'), fieldsEC);
            upsert upsertConfig;      
            returnMsg = 'Successfully updated exam configuration';
        } catch (Exception ex) {
            returnMsg = ex.getMessage();
        }        
        return returnMsg;
        
    }
    @RemoteAction
    public static string saveAssignmentManagerListFilterInExamConfig(String statusVal) {

        String returnMsg = '';
        SFDCAccessController accessObj = ExAMUtilClass.AccessController;
        List<String> fieldsEC = new List<String>{'ExAM__Overall_Status_on_Submit__c','ExAM__Assignment_Manager_List_Status_Filter__c'};
        accessObj.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__ExAM_Configuration__c'), fieldsEC);
        List<ExAM_Configuration__c> exConfigList = [SELECT Id, Assignment_Manager_List_Status_Filter__c, Overall_Status_on_Submit__c FROM ExAM_Configuration__c ORDER BY CreatedDate DESC LIMIT 1];
        try {
                    
            ExAM_Configuration__c upsertConfig = new ExAM_Configuration__c();    
            upsertConfig.Name = 'Configuration';   
            if (exConfigList != null && exConfigList.size() > 0) {
                upsertConfig.id = exConfigList[0].Id;
            }
            upsertConfig.Assignment_Manager_List_Status_Filter__c  = statusVal;
            
            accessObj.assertAuthorizedToCreate(Schema.getGlobalDescribe().get('exam__ExAM_Configuration__c'), fieldsEC);
            accessObj.assertAuthorizedToUpdate(Schema.getGlobalDescribe().get('exam__ExAM_Configuration__c'), fieldsEC);    
            upsert upsertConfig;      
            returnMsg = 'Successfully updated exam configuration';
        } catch (Exception ex) {
            returnMsg = ex.getMessage();
        }        
        return returnMsg;
        
    }    

    @RemoteAction
    public static string doSaveSelectedSiteUrl(String siteURL) {

        String returnMsg = '';
        try {
                    
            String orgId = UserInfo.getOrganizationId();

            Public_Assessment_Configuration__c pac = Public_Assessment_Configuration__c.getInstance( orgId );
            if (pac != null) {

                pac.Site_URL__c = siteURL;
            }
            else {

                pac.SetupOwnerId = orgId;
                pac.Site_URL__c = siteURL;
            }
            if (pac != null && String.isNotBlank(pac.Site_URL__c)) {
                
                upsert pac;      
                returnMsg = 'Public Site Assessment URL Configured Successfully';
            }

        } catch (Exception ex) {
            returnMsg = ex.getMessage();
        }        
        return returnMsg;
    }
    @RemoteAction
    public static string doSaveSelectedWebUrl(String webURL) {

        String returnMsg = '';

        try {
                    
            String orgId = UserInfo.getOrganizationId();

            Web_Intercept_Configuration__c wic = Web_Intercept_Configuration__c.getInstance( orgId );
            if (wic != null) {
                wic.Web_URL__c = webURL;
            }
            else {
                wic.SetupOwnerId = orgId;
                wic.Web_URL__c = webURL;
            }
            if (wic != null && String.isNotBlank(wic.Web_URL__c)) {
                upsert wic;      
                returnMsg = 'Web Intercept URL Configured Successfully';
            }

        } catch (Exception ex) {
            returnMsg = ex.getMessage();
        }        
        return returnMsg;
    }
    @RemoteAction 
    public static String savefieldMappping(Boolean isFieldMap) {
        String errorMessage = '';
        try{
            SFDCAccessController accessObj = ExAMUtilClass.AccessController;
            List<String> fieldsEC = new List<String>{'ExAM__Primary_Assessment_Type_Template__c','ExAM__Related_Assessment_Type_1_Template__c',
                                                     'ExAM__Related_Assessment_Type_2_Template__c','ExAM__Related_Assessment_Type_3_Template__c',
                                                     'ExAM__Skip_Answer_For_Decision_Tree_Steps__c','ExAM__Is_Field_Mapping__c'};
            accessObj.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__ExAM_Configuration__c'), fieldsEC);
            
            List<ExAM_Configuration__c> examConfigList = [
                SELECT Hours__c, Id, Name, Primary_Assessment_Type_Template__c, Related_Assessment_Type_1_Template__c, 
                       Related_Assessment_Type_2_Template__c, Related_Assessment_Type_3_Template__c, Skip_Answer_For_Decision_Tree_Steps__c,
                       Is_Field_Mapping__c 
                FROM   ExAM_Configuration__c ORDER BY CreatedDate DESC LIMIT 1
            ];
              
            ExAM_Configuration__c updateExamConfig = new ExAM_Configuration__c();
            updateExamConfig.Name = 'Configuration';
            if (examConfigList != null && examConfigList.size() > 0) {    
                updateExamConfig.Id = examConfigList[0].Id;
            }
            updateExamConfig.Is_Field_Mapping__c = isFieldMap;
            
            accessObj.assertAuthorizedToCreate(Schema.getGlobalDescribe().get('exam__ExAM_Configuration__c'), fieldsEC);
            accessObj.assertAuthorizedToUpdate(Schema.getGlobalDescribe().get('exam__ExAM_Configuration__c'), fieldsEC);
            upsert updateExamConfig;
            errorMessage = 'success@@'+updateExamConfig.Id;
        } catch( exception ex) {
            errorMessage = ex.getMessage();
        }        
        return errorMessage;
    }
    @RemoteAction
    public static string getAllQuestionTypes() {

        List<String> typeList = new List<String>();

        Schema.DescribeFieldResult dfr = ExAM__Question_Template__c.ExAM__Question_Type__c.getDescribe();
        for (Schema.PicklistEntry ple : dfr.getPickListValues()) {
            typeList.add( ple.getValue() );
        }
        return Json.serialize(typeList);
    }
    @RemoteAction 
    public static String saveSelectedQuestionTypesFilter(ExAM_Configuration__c configRecord) {
        String responseMsg = '';
        try {
            SFDCAccessController accessObj = ExAMUtilClass.AccessController;
            List<String> fieldsEC = new List<String>{'ExAM__Data_Management_Tab_Filter__c'};
            accessObj.assertAuthorizedToCreate(Schema.getGlobalDescribe().get('exam__ExAM_Configuration__c'), fieldsEC);
            accessObj.assertAuthorizedToUpdate(Schema.getGlobalDescribe().get('exam__ExAM_Configuration__c'), fieldsEC);
            List<ExAM_Configuration__c> exConfigList = [SELECT Id FROM ExAM_Configuration__c ORDER BY CreatedDate DESC LIMIT 1];
            ExAM_Configuration__c upsertConfig = new ExAM_Configuration__c();    
            if (exConfigList != null && exConfigList.size() > 0) {
                configRecord.id = exConfigList[0].Id;
            }
            upsert configRecord;
            responseMsg = JSON.serialize( new SuccessClass(configRecord.Id, 'Exam Configuration updated successfully') );
        } catch( exception ex) {
            String msg = (ex.getTypeName() != 'System.DMLException') ? ex.getMessage() : ex.getDMLMessage(0);
            responseMsg = JSON.serialize( new ErrorClass(ex.getTypeName(), msg) );
        }        
        return responseMsg;
    }
    public class SuccessClass {
        public String recId;
        public String successMsg;
        public SuccessClass(String Id, String msg) {
            this.recId = Id;
            this.successMsg = msg;
        }
    }
    public class ErrorClass {
        public String errType;
        public String errMsg;
        public ErrorClass(String type, String msg) {
            this.errType = type;
            this.errMsg = msg;
        }
    }
    public class SelectListOptions {
        public String Label;
        public String Value;
        
        public SelectListOptions(String v,String l) {
            this.Value = v;
            this.Label = l;
        }
    }
    
}