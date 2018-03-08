public with sharing class ReportBuilderController {

    public List<assignmentManagerPositionCls> amPositionList = new List<assignmentManagerPositionCls>();
    public List<IssueRequest_Life_Cycle__c> AMList = new List<IssueRequest_Life_Cycle__c>();
    
    String amqueryStr;
    
    public List<assignmentManagerRecord> amrecordList { get; set; }
    public String templateName { get; set;}
    public String templateId { get; set; }
    public Set<Id> assignmentManagerIdSet ;
    public Map<String, List<Questionnaire_Response__c>> amIdwithListofAnswerMap { get; set; }
    
    public Map<String, Boolean> sectionIdwithIsSelectedMap = new Map<String, Boolean>();
    public Boolean isRenderAspdf { get; set; }
    
    public Report_Builder_Configuration__c rbc;
    
    public string headerStr { get; set; }
    public string footerStr { get; set; }
    
    public ExAM_Configuration__c examConfig { get; set; } 
    
    public string headerUrl { get; set; }
    public string footerUrl { get; set; }
    
    public string head { get; set; }
    public String headSize { get; set; }
    
    public Map<String,List<ID>> ansIdwithListOfAttIdMap { get; set; }
    public Boolean isCommentShow { get; set; }
    public Boolean isPictureShow { get; set; }
    
    public ReportBuilderController() {
    }
    
    public Class assignmentManagerPositionCls {
        public String apiName;
        public String labelName;
        public Integer position;
    }
    
    public Class assignmentManagerRecord {
        public String amName {get; set; }
        public String amId { get; set; }
        public List<assignmentManagerFieldValue> amFieldValues {get; set;}
        public String assessableObjName { get; set; }
        public List<AssessableObjectFields> assessableObjectFieldsList {get; set;}
    }
    
    public class AssessableObjectFields {
        public String field1ApiName {get; set; }
        public String field2ApiName {get; set; }
        public String field1LabelName {get; set; }
        public String field2LabelName {get; set; }
        public Integer field1Position {get; set; }
        public Integer field2Position {get; set; }
        public Object field1Value {get; set; }
        public Object field2Value {get; set; }
    }

    public Class assignmentManagerFieldValue {

        public String apiName {get; set;}
        public String labelName {get; set;}
        public Integer position {get; set;}
        public String fieldvalue {get; set;}
        
        public String apiName2 {get; set;}
        public String labelName2 {get; set;}
        public Integer position2 {get; set;}
        public String fieldvalue2 {get; set;}
        
    }
    
    public Class sectionClass {
        public String sectionIdorAll;
        public Boolean isSelectedSection;
    }

    public class AssessableObjectDetails {
        public String assessableObjectAPI {get; set;}
        public String assessableObjectLabel {get; set;}
        public String assignmentManagerApi {get; set;}
        public List<AssessableObjectFieldDetails> assessablefields {get; set;}
    }

    public class AssessableObjectFieldDetails {
        public Integer position {get; set;}
        public String labelName {get; set;}
        public String apiName {get; set;}
    }

    public void headerAction() {
        try{
            SFDCAccessController accessForEC = ExAMUtilClass.AccessController;
            List<String> fieldsListEC = new List<String>{'ExAM__Report_Builder_Page_Header__c'};
            accessForEC.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__ExAM_Configuration__c'), fieldsListEC);
            List<ExAM_Configuration__c> examConfigList = [ SELECT Id, Name, Report_Builder_Page_Header__c
                                                   FROM ExAM_Configuration__c 
                                                   WHERE Name = 'Configuration' Limit 1];
        
            if (examConfigList != null && examConfigList.size() > 0 && examConfigList[0].Report_Builder_Page_Header__c != null ) {
                head = examConfigList[0].Report_Builder_Page_Header__c;
                head = string.EscapeSingleQuotes( head );
            }
        } catch(Exception e){
            ApexPages.addMessage( new Apexpages.Message(ApexPages.Severity.ERROR, e.getMessage()) );
        }    
    }
    
   
    public pageReference pageRedirectMethod () {
        
        String reportBuilderConfigId = apexPages.currentPage().getParameters().get('reportbuilderid');
        headSize = ApexPages.currentpage().getparameters().get('headerSize');
        System.debug('::::::headSize:::::'+headSize);
        
        if(headSize == null)
            headSize = '90';
        PageReference ReportBuilderPDFPage = new PageReference('/apex/ExAM__ReportBuilderPDF?reportbuilderid='+reportBuilderConfigId+'&headerSize=' +  headSize);
        ReportBuilderPDFPage.setRedirect(true); 
        return ReportBuilderPDFPage;
    }
    public void ReportBuilderControllerAction() {
        try {
            isRenderAspdf = false;    
            amqueryStr = '';
            String reportBuilderConfigId = apexPages.currentPage().getParameters().get('reportbuilderid');
            rbc = new Report_Builder_Configuration__c();
            
            amrecordList = new List<assignmentManagerRecord> ();
            templateName = '';
            
            assignmentManagerIdSet = new Set<Id>();    
            amIdwithListofAnswerMap = new Map<String, List<Questionnaire_Response__c>> ();
            
            headerStr = '';
            footerStr = '';    
            examConfig = new ExAM_Configuration__c();
            
            headerUrl = '';
            footerUrl = '';
            ansIdwithListOfAttIdMap = new Map<String, List<ID>>();  
            isCommentShow = false;
            isPictureShow = false;
    
            Set<String> assessableFieldSet = new Set<String>();
            Set<Id> assessableObjectIdSet = new Set<Id>();
            Map<Id, Id> amIdAssessableObjectIdMap = new Map<Id, Id>();

            SFDCAccessController accessForEC = ExAMUtilClass.AccessController;
            
            List<String> fieldsListEC = new List<String>{'ExAM__Report_Builder_Page_Header__c','ExAM__Report_Builder_Page_Footer__c'};
            accessForEC.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__ExAM_Configuration__c'), fieldsListEC);
            
            List<ExAM_Configuration__c> exConfigList = [ SELECT Id, Name, Report_Builder_Page_Header__c, Report_Builder_Page_Footer__c 
                                                   FROM ExAM_Configuration__c 
                                                   WHERE Name = 'Configuration' Limit 1];
        
            if (exConfigList != null && exConfigList.size() > 0) {
                examConfig = exConfigList[0];
                
                if(exConfigList[0].Report_Builder_Page_Header__c != null ) {
                    headerStr = exConfigList[0].Report_Builder_Page_Header__c;
                    headerStr = string.EscapeSingleQuotes( headerStr );
                } 
                
                if (exConfigList[0].Report_Builder_Page_Footer__c != null ) {
                    footerStr = exConfigList[0].Report_Builder_Page_Footer__c;
                    footerStr = string.EscapeSingleQuotes( footerStr );
                }

            }
            
            List<String> fieldsListAT = new List<String>{'ExAM__Template_Name__c'};
            accessForEC.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Main_questionaire__c'), fieldsListAT);
            
            List<String> fieldsListRBC = new List<String>{'ExAM__Assessment_Data_Config__c','ExAM__Assignment_Manager_position__c',
                                                        'ExAM__Assessable_Object_Field_Position__c','ExAM__Assessment_Template__c','ExAM__Choosed_Assignment_manager__c',
                                                        'ExAM__End_Date_Range__c','ExAM__Output_Format__c','ExAM__Overall_Status__c','ExAM__Selected_Sections__c','ExAM__Selected_Sections__c'};
            accessForEC.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Report_Builder_Configuration__c'), fieldsListRBC);
            List<Report_Builder_Configuration__c> repBuilderList = new List<Report_Builder_Configuration__c>();
            repBuilderList = [
                SELECT Assessment_Data_Config__c, Assignment_Manager_position__c,
                       Assessable_Object_Field_Position__c, Assessment_Template__c,
                       Assessment_Template__r.Template_Name__c, Choosed_Assignment_manager__c,
                       End_Date_Range__c, Id, Name, Output_Format__c, Overall_Status__c,
                       Selected_Sections__c, Start_Date_Range__c
                FROM   Report_Builder_Configuration__c
                WHERE  Id = :reportBuilderConfigId LIMIT 1
            ];

            if (repBuilderList != null && repBuilderList.size() > 0) {

                rbc = repBuilderList[0];

                if (rbc.Assessment_Template__c != null) {
                    templateName = rbc.Assessment_Template__r.Template_Name__c; 
                    templateId = rbc.Assessment_Template__c;
                    if (rbc.Output_Format__c == 'HTML' || rbc.Output_Format__c == 'PDF' ) {

                        if (rbc.Output_Format__c == 'PDF' ) {
                            isRenderAspdf = true;
                        }
                        if (rbc.Assessment_Data_Config__c != null && rbc.Assessment_Data_Config__c != '') {
                            Map<String, Boolean> dataConfigNameWithIsShow = (Map<String, Boolean>)System.JSON.deserialize(rbc.Assessment_Data_Config__c , Map<String, Boolean>.class);
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

                        AssessableObjectDetails assessableObjDetails = new AssessableObjectDetails();
                        if (rbc.Assessable_Object_Field_Position__c != null && rbc.Assessable_Object_Field_Position__c != '') {

                            assessableObjDetails = (AssessableObjectDetails)Json.deserialize( rbc.Assessable_Object_Field_Position__c, AssessableObjectDetails.class );

                            for (AssessableObjectFieldDetails field : assessableObjDetails.assessablefields) {
                                if(field.apiName != '') {
                                    assessableFieldSet.add( field.apiName );
                                }
                            }
                        }

                        if (rbc.Assignment_Manager_position__c != null && rbc.Assignment_Manager_position__c != '') {
                            amPositionList = (List<assignmentManagerPositionCls>)System.JSON.deserialize(rbc.Assignment_Manager_position__c, List<assignmentManagerPositionCls>.class);
                            System.debug('::::::amPositionList::::'+amPositionList);

                            Set<String> amFieldsSet = new Set<String>();
                            List<String> amFieldList = new List<String>();
                            Set<String> fieldSet = new Set<String>();

                            fieldSet.add('name');
                            fieldSet.add('id');
                            fieldSet.add('exam__scheduled_start_date__c');
                            amFieldsSet.add('exam__scheduled_start_date__c');
                            
                            if ( string.isNotBlank(assessableObjDetails.assignmentManagerApi) ) {
                                fieldSet.add( assessableObjDetails.assignmentManagerApi.toLowerCase() );
                                amFieldsSet.add( assessableObjDetails.assignmentManagerApi.toLowerCase() );
                            }

                            Map <string, Schema.SObjectField> amfieldapiSchemaFieldMap = Schema.SObjectType.IssueRequest_Life_Cycle__c.fields.getMap();
                            Set<String> lookupFieldAPISet = new Set<String>();
                            Map<String, String> lookupfieldwithObjectMap = new Map<String, String>();

                            for ( Schema.SObjectField fld : amfieldapiSchemaFieldMap.values() ) {
                                Schema.DescribeFieldResult res = fld.getDescribe();
                                System.debug('::::res:::'+res);
                                if (String.valueOf(res.getType()).touppercase() == 'REFERENCE' && res.isCustom()) {
                                    lookupFieldAPISet.add(res.getName().toLowerCase()); 
                                    lookupfieldwithObjectMap.put(res.getName().toLowerCase(),  String.valueOf(res.getReferenceTo().get(0)));                                 
                                }
                            }
                            for (assignmentManagerPositionCls amp : amPositionList) {
                            
                                if (amp.apiName != null && amp.apiName != '') {
                                        String apiLowercase = amp.apiName.toLowerCase();
                                        fieldSet.add(apiLowercase);
                                        amFieldsSet.add(apiLowercase);
                                        if (lookupFieldAPISet != null && lookupFieldAPISet.contains(apiLowercase) && apiLowercase.length() > 2) {
                                            if (lookupfieldwithObjectMap.get(apiLowercase).equalsIgnoreCase('Contact')) {
                                                
                                                String fName = apiLowercase.substring(0, apiLowercase.length() - 1) +'r.firstname';
                                                fieldSet.add(fName);
                                                String lName = apiLowercase.substring(0, apiLowercase.length() - 1) +'r.lastname';
                                                fieldSet.add(lName);
                                                
                                            } else {
                                                apiLowercase = apiLowercase.substring(0, apiLowercase.length() - 1) +'r.name';
                                                fieldSet.add(apiLowercase);
                                            }
                                        }
                                        //amFieldList.add(amp.apiName);
                                }
                            }
                            
                            List<String> fieldsListAM = new List<String>();
                            fieldsListAM.addAll( amFieldsSet );
                            system.debug('::::fieldsListAM:::::'+fieldsListAM);
                            accessForEC.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__IssueRequest_Life_Cycle__c'), fieldsListAM);
                            
                            amqueryStr = 'SELECT ';                                
                            amFieldList.addAll(fieldSet);
                           
                            amqueryStr += String.join(amFieldList,', ');
                            String assTempId = rbc.Assessment_Template__c;
                            amqueryStr += ' FROM IssueRequest_Life_Cycle__c WHERE InvestigationType__c = :assTempId';
                            System.debug('::::::amqueryStr::::::'+amqueryStr);

                            if (rbc.Choosed_Assignment_manager__c != null) {
                                String assManagerId = rbc.Choosed_Assignment_manager__c;
                                amqueryStr += ' AND Id = :assManagerId'; 
                            }
                            if (rbc.Start_Date_Range__c != null && rbc.Start_Date_Range__c != '') {
                                List<String> dateStr = rbc.Start_Date_Range__c.split('/');
                                if (dateStr != null && dateStr.size() == 3) {
                                    Date startTime = date.newinstance( Integer.valueOf(dateStr[2]), Integer.valueOf(dateStr[0]), Integer.valueOf(dateStr[1]) );
                                    amqueryStr += ' AND Scheduled_Start_Date__c >=:startTime'; 
                                }
                            }

                            if (rbc.End_Date_Range__c != null && rbc.End_Date_Range__c != '') {
                                List<String> dateStr = rbc.End_Date_Range__c.split('/');
                                if (dateStr != null && dateStr.size() == 3) {
                                    Date endTime = date.newinstance( Integer.valueOf(dateStr[2]), Integer.valueOf(dateStr[0]), Integer.valueOf(dateStr[1]) );
                                    amqueryStr += ' AND Scheduled_Start_Date__c <=:endTime'; 
                                }
                            }

                            if (rbc.Overall_Status__c != null && rbc.Overall_Status__c != '') {
                                List<String> statusList = rbc.Overall_Status__c.split(',');
                                amqueryStr += ' AND Status__c IN :statusList';
                            }

                            System.debug(':::::string query::::'+amqueryStr);
                            List<IssueRequest_Life_Cycle__c> amQueryList = new List<IssueRequest_Life_Cycle__c> ();
                            amQueryList = Database.query(amqueryStr);
                            
                            for (IssueRequest_Life_Cycle__c am :amQueryList) {

                                assignmentManagerRecord amr = new assignmentManagerRecord();
                                amr.amName = am.Name;
                                amr.amId = am.Id;
                                assignmentManagerIdSet.add(am.Id);
                                amIdwithListofAnswerMap.put(am.Id, new List<Questionnaire_Response__c>());
                                List<assignmentManagerFieldValue> amfields = new List<assignmentManagerFieldValue>(); 
                                integer i = 1;
                                assignmentManagerFieldValue amf;
                                for (assignmentManagerPositionCls amp : amPositionList) {
                                    if ( math.mod(i,2) == 1) {
                                        amf = new assignmentManagerFieldValue();  
                                    
                                        amf.apiName = amp.apiName;
                                        amf.labelName = amp.labelName;
                                        amf.position = amp.position;
                                        if (amp.apiName != null && amp.apiName != '') {
                                            system.debug('::::lookupfieldwithObjectMap::::'+lookupfieldwithObjectMap);
                                            if (lookupFieldAPISet != null && lookupFieldAPISet.contains(amp.apiName.toLowerCase()) ) {
                                                String relatedfieldName = amp.apiName.toLowerCase().subString(0,amp.apiName.toLowerCase().length()-1)+'r';//custom_field__r
                                                system.debug('::::relatedfieldName::::'+relatedfieldName);
                                                if (lookupfieldwithObjectMap != null && lookupfieldwithObjectMap.size() > 0 
                                                        && lookupfieldwithObjectMap.containsKey(amp.apiName.toLowerCase()) && lookupfieldwithObjectMap.get(amp.apiName.toLowerCase()).equalsIgnoreCase('Contact')) {
                                                
                                                    if (am.getSobject(relatedfieldName) != null && 
                                                            ( am.getSobject(relatedfieldName).get('firstname') != null ||
                                                              am.getSobject(relatedfieldName).get('lastname') != null ) ) {
                                                        
                                                        amf.fieldvalue = String.valueof(am.getSobject(relatedfieldName).get('firstname')) + ' '+
                                                                         String.valueof(am.getSobject(relatedfieldName).get('lastname'));    
                                                    }                                                 
                                                                     
                                                } else if (am.getSobject(relatedfieldName) != null) {
                                                    amf.fieldvalue = String.valueof(am.getSobject(relatedfieldName).get('name'));
                                                }
                                            } else {
                                                amf.fieldvalue = String.valueof(am.get(amp.apiName.tolowerCase()));
                                            }
                                        }
                                    } else {
                                        amf.apiName2 = amp.apiName;
                                        amf.labelName2 = amp.labelName;
                                        amf.position2 = amp.position;
                                        if (amp.apiName != null && amp.apiName != '') {
                                            if (lookupFieldAPISet != null && lookupFieldAPISet.contains(amp.apiName.toLowerCase()) ) {
                                                String relatedfieldName = amp.apiName.toLowerCase().subString(0,amp.apiName.toLowerCase().length()-1)+'r';//custom_field__r
                                                system.debug('::::relatedfieldName::::'+relatedfieldName);
                                                if (lookupfieldwithObjectMap != null && lookupfieldwithObjectMap.size() > 0 
                                                        && lookupfieldwithObjectMap.containsKey(amp.apiName.toLowerCase()) && lookupfieldwithObjectMap.get(amp.apiName.toLowerCase()).equalsIgnoreCase('Contact')) {
                                                
                                                    if (am.getSobject(relatedfieldName) != null && 
                                                            ( am.getSobject(relatedfieldName).get('firstname') != null ||
                                                              am.getSobject(relatedfieldName).get('lastname') != null ) ) {
                                                        
                                                        amf.fieldvalue2 = String.valueof(am.getSobject(relatedfieldName).get('firstname')) + ' '+
                                                                         String.valueof(am.getSobject(relatedfieldName).get('lastname'));    
                                                    }                                                 
                                                                     
                                                } else if (am.getSobject(relatedfieldName) != null) {
                                                    amf.fieldvalue2 = String.valueof(am.getSobject(relatedfieldName).get('name'));
                                                }
                                            } else {
                                                amf.fieldvalue2 = String.valueof(am.get(amp.apiName.tolowerCase()));
                                            }
                                        }
                                    } 
                                    if ( math.mod(i,2) == 0 || i >= amPositionList.size()) {
                                        amfields.add(amf);
                                    }
                                    i++;
                                }

                                if (string.isNotBlank(assessableObjDetails.assignmentManagerApi)) {

                                    Id assessableObjectId = (Id)am.get( assessableObjDetails.assignmentManagerApi );
                                    assessableObjectIdSet.add( assessableObjectId );
                                    amIdAssessableObjectIdMap.put(am.Id, assessableObjectId);
                                }

                                amr.amFieldValues = amfields;
                                amrecordList.add(amr);
                            }

                            if (string.isNotBlank(assessableObjDetails.assessableObjectAPI) && !assessableObjDetails.assessablefields.isEmpty()
                                && !assessableFieldSet.isEmpty() && !assessableObjectIdSet.isEmpty()
                            ) {

                                List<String> assessableFieldList = new List<String>();
                                Map<Id, SObject> objIdRecordMap;

                                assessableFieldSet.add('Id');
                                assessableFieldSet.add('Name');

                                String assessableObjQueryStr = 'SELECT ';
                                assessableFieldList.addAll(assessableFieldSet);

                                assessableObjQueryStr += String.join(assessableFieldList,', ');
                                assessableObjQueryStr += ' FROM '+assessableObjDetails.assessableObjectAPI+' WHERE Id IN :assessableObjectIdSet';
                                System.debug('::::::assessableObjQueryStr::::::'+assessableObjQueryStr);
                                
                                List<SObject> assessableObjectRecords = Database.query(assessableObjQueryStr);

                                if (!assessableObjectRecords.isEmpty()) {

                                    objIdRecordMap = new Map<Id, SObject>(assessableObjectRecords);

                                    for(assignmentManagerRecord am : amrecordList) {
                                        Id assessableObjectId = amIdAssessableObjectIdMap.get( am.amId );
                                        SObject sObj;
                                        if (objIdRecordMap.containsKey(assessableObjectId) && objIdRecordMap.get(assessableObjectId) != null) {
                                            sObj = objIdRecordMap.get(assessableObjectId);
                                            am.assessableObjName = (String)sObj.get('Name');
                                            am.assessableObjectFieldsList = new List<AssessableObjectFields>();
                                            Integer i = 1;
                                            AssessableObjectFields aof;
                                            Integer FieldsListSize = assessableObjDetails.assessablefields.size();
                                            for(AssessableObjectFieldDetails fieldDtl : assessableObjDetails.assessablefields) {
                                                if( fieldDtl.apiName !='') { //newly added on 19/04/2017
                                                    if ( math.mod(i,2) == 1) {
                                                        aof = new AssessableObjectFields();
                                                        aof.field1ApiName = fieldDtl.apiName;
                                                        aof.field1LabelName = fieldDtl.labelName;
                                                        aof.field1Position = fieldDtl.position;
                                                        aof.field1Value = sObj.get( fieldDtl.apiName );
                                                    }
                                                    else {
                                                        aof.field2ApiName = fieldDtl.apiName;
                                                        aof.field2LabelName = fieldDtl.labelName;
                                                        aof.field2Position = fieldDtl.position;
                                                        aof.field2Value = sObj.get( fieldDtl.apiName );
                                                    }
                                                    if ( math.mod(i,2) == 0 || i >= FieldsListSize) {
                                                        am.assessableObjectFieldsList.add(aof);
                                                    }
                                                    i++;
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            system.debug('::::amrecordList:::::'+amrecordList);
                            System.debug(':::assignmentManagerIdSet::::'+assignmentManagerIdSet);

                        } // assignment manager positions.

                        if (assignmentManagerIdSet != null && assignmentManagerIdSet.size() > 0 && templateId != null && templateId != '') {
                            
                            List<String> fieldsListQT = new List<String>{'ExAM__Question_Label__c','ExAM__Section_Question__c'};
                            accessForEC.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Question_Template__c'), fieldsListQT);
                            
                            List<String> fieldsListQR = new List<String>{'ExAM__Question_Template__c','ExAM__Response__c','ExAM__Comment__c','ExAM__Issue_Request__c'};
                            accessForEC.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Questionnaire_Response__c'), fieldsListQR);
                            
                            string answerQuery = 'SELECT Id, Name, Question_Template__c, Question_Template__r.Question_Label__c, Question_Template__r.Section_Question__c, Response__c, Comment__c, Issue_Request__c ';
                            answerQuery += ' FROM Questionnaire_Response__c WHERE Issue_Request__c IN:assignmentManagerIdSet';

                            System.debug(':::templateId:::'+templateId);
                            System.debug(':::assignmentManagerIdSet:::'+assignmentManagerIdSet);

                            if (rbc.Selected_Sections__c != null && rbc.Selected_Sections__c != '') {
                                sectionIdwithIsSelectedMap = (Map<String, Boolean>)System.JSON.deserialize(rbc.Selected_Sections__c,Map<String, Boolean>.class);
                                System.debug('::::sectionIdwithIsSelectedMap:::'+sectionIdwithIsSelectedMap);    
                                if (sectionIdwithIsSelectedMap != null && sectionIdwithIsSelectedMap.size() > 0) {

                                    if (sectionIdwithIsSelectedMap.ContainsKey('All') && sectionIdwithIsSelectedMap.get('All')) {
                                    } else {
                                        Set<String> sectionIdSet = new Set<String>();
                                        for (String seckey : sectionIdwithIsSelectedMap.keySet()) {
                                            if (!sectionIdwithIsSelectedMap.ContainsKey(seckey) && sectionIdwithIsSelectedMap.get(seckey)) {
                                                sectionIdSet.add(seckey);
                                            }
                                        }
                                        if (sectionIdSet != null && sectionIdSet.size() > 0) {
                                            answerQuery += ' AND Question_Template__r.Section_Question__c IN:sectionIdSet';
                                        }
                                    }
                                }
                            }
                            system.debug('::::answerQuery:::::'+answerQuery);
                            //sectionIdwithIsSelectedMap = 
                            //(rbc.Selected_Sections__c)
                            //{"All":true,"000000000000000000":true,"000000000000000000":true}
                            
                            List<Questionnaire_Response__c> answerList = new List<Questionnaire_Response__c>();

                            answerList = Database.query(answerQuery);
                            

                            for (Questionnaire_Response__c ans : answerList) {

                                ansIdwithListOfAttIdMap.put(ans.Id, new List<ID>());
                                if (!amIdwithListofAnswerMap.containsKey(ans.Issue_Request__c)) {
                                    amIdwithListofAnswerMap.put(ans.Issue_Request__c, new List<Questionnaire_Response__c>());
                                }
                                amIdwithListofAnswerMap.get(ans.Issue_Request__c).add(ans);
                            }
                            if (ansIdwithListOfAttIdMap != null && ansIdwithListOfAttIdMap.size() > 0 && isPictureShow) {
                                for (Attachment att : [SELECT Id, Name, ContentType, ParentId FROM Attachment WHERE ParentId IN: ansIdwithListOfAttIdMap.keySet() AND ContentType LIKE 'image/%']) {
                                    if (ansIdwithListOfAttIdMap != null && !ansIdwithListOfAttIdMap.containsKey(att.ParentId)) {
                                        ansIdwithListOfAttIdMap.put(att.ParentId, new List<ID>());
                                    }
                                    ansIdwithListOfAttIdMap.get(att.ParentId).add(att.Id);
                                }
                            }
                            system.debug(':::amIdwithListofAnswerMap::::'+amIdwithListofAnswerMap);
                        }
                    } // HTML formate
                }
            } //repBuilder List
        } catch(Exception e){
            ApexPages.addMessage( new Apexpages.Message(ApexPages.Severity.ERROR, e.getMessage()) );
        }   
    }
}