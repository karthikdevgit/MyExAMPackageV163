global class CreateAMAndAnswersController {

    public String tempId { get; set; }
    public String objId { get; set; }
    public String amId { get; set; }
    public String PARecordId { get; set; }
    public String ipAddress { get; set; } 
    public String assessbleObjAPI {get;set;}
    public String headerStr { get; set; }
    public String footerStr { get; set; }
    public String customScriptConfigured { get; set; }
    public String srName {get;set;}
    public String startTime {get; set;}
    public String tabIconSRName {get; set;}
    public String tabTitle {get; set;}
    public String errHandler {get;set;}
    public String imgURl {get;set;}
    public String headerText {get;set;}
    public String basicStyle {get;set;}
    public String headerFilePath {get;set;}
    public String footerFilePath {get;set;}
    public String scriptFilePath {get;set;}
    public String overlayDetailStr {get;set;}
    public String tqMessageStr {get;set;}
    public String startDate {get;set;}
    
    public Boolean hideSectionTitles {get;set;}
    public Boolean moveforward {get;set;}
    public Boolean singleQuestionMode {get;set;}
    public Boolean webIntercept {get;set;}
    public Boolean showIntroText {get;set;}
    public Boolean showSecDesc {get;set;}
    public Boolean hasLinkExpired {get;set;}
    public Boolean hasLinkNotValid {get;set;}
    public Boolean hasAssessableObj {get;set;}
    public Boolean autoSubmit {get;set;}
    
    public List<string> pathList {get;set;}
    
    public CreateAMAndAnswersController() {
    
       try {
            //Boolean varaibles
            hasAssessableObj = false;
            webIntercept = false;
            moveforward = true;
            hideSectionTitles = false;
            singleQuestionMode = false;
            hasLinkExpired = false;
            hasLinkNotValid = false;
            
            //parameter varaibles 
            PARecordId = ApexPages.currentPage().getParameters().get('paId');
            ipAddress = ApexPages.currentPage().getHeaders().get('X-Salesforce-SIP');
            if(ApexPages.currentPage().getParameters().get('WebIntercept') != null && ApexPages.currentPage().getParameters().get('WebIntercept') !='') {
                webIntercept = Boolean.valueOf(ApexPages.currentPage().getParameters().get('WebIntercept'));
            }
            Public_Assessment_Configuration__c publicConfig = Public_Assessment_Configuration__c.getOrgDefaults();
            
            //String variables
            tempId = '';
            objId = '';
            amId = '';
            errHandler = '';
            startTime = System.now().format('yyyy-MM-dd HH:mm:ss');
            imgURl = '';
            headerText = '';
            basicStyle = '';
            headerFilePath = '';
            footerFilePath = '';
            scriptFilePath = '';
            assessbleObjAPI = '';
            overlayDetailStr = '';
            tqMessageStr = '';
            String siteStr = publicConfig.Site_URL__c;
            String path;
            Map<string,string> overlayDetailMap  = new Map<string,string>();
            List<Distribution__c> disList = new List<Distribution__c>();
            
            if (string.isNotBlank(PARecordId)) {
            
                List<Public_Assessment__c> paList = new List<Public_Assessment__c>();
                paList = [SELECT Id,Name,Assessable_Object_API__c,Assessible_Object_ID__c,
                                 Assessment_Template__c, Assignment_Manager__c, Expiration_Date__c, Facility_Name__c,
                                 Distribution__c
                          FROM Public_Assessment__c
                          WHERE Id = :PARecordId];
                if (paList == null || paList.size() == 0) {
                    moveforward = false;
                }
                else {
                    if(paList[0].Distribution__c != null) {
                        disList = [SELECT Id, Name, Start_Date__c, Expiration_Date__c, Pre_Assessment_Message__c, Post_Assessment_Message__c, Status__c
                                   FROM   Distribution__c
                                   WHERE  Id = :paList[0].Distribution__c
                        ];
                        if(disList.size() > 0) {
                            if(disList[0].Status__c != NULL && disList[0].Status__c == 'Completed') {
                                moveforward = false;
                                hasLinkExpired = true;
                            } else if(disList[0].Status__c != NULL && disList[0].Status__c == 'Not Started') {
                                moveforward = false;
                                hasLinkNotValid = true;
                                startDate = String.valueOf(disList[0].Start_Date__c);
                            } else {
                                if( disList[0].Pre_Assessment_Message__c != null && disList[0].Pre_Assessment_Message__c != '' ) {
                                    overlayDetailMap.put('Body',disList[0].Pre_Assessment_Message__c);
                                }
                                if(disList[0].Post_Assessment_Message__c != null && disList[0].Post_Assessment_Message__c != '') {
                                    tqMessageStr = disList[0].Post_Assessment_Message__c;
                                }
                            }
                        }
                    } else {
                    
                        if (paList[0].Expiration_Date__c != NULL && paList[0].Expiration_Date__c < Date.today()) {
                            moveforward = false;
                            hasLinkExpired = true;
                        }
                    }
                    if (moveforward && !hasLinkExpired && !hasLinkNotValid) {
    
                        showIntroText = false;
                        showSecDesc = false;
                        tabIconSRName = '';
                        tabTitle = '';
                        String sObjName = '';
                        
                        if(paList[0].Assignment_Manager__c != null) {

                            amId = paList[0].Assignment_Manager__c;
                            
                            string select_clause = 'Id, ExAM__InvestigationType__c, Name, ExAM__InvestigationType__r.ExAM__One_Time_Assessment__c,ExAM__Status__c';
                            string from_clause = 'ExAM__IssueRequest_Life_Cycle__c';
                            string where_clause = 'Id = \'' + string.EscapeSingleQuotes(amId) + '\' LIMIT 1';

                            ExAMUtilClass.AssessableObjectDetails objectDetail = ExAMUtilClass.getAssessableObjectDetails('ExAM__IssueRequest_Life_Cycle__c');
                            Map<string, string> fieldsAPIMap = objectDetail.assessableObjectAPIMap;
                            if (fieldsAPIMap != null && fieldsAPIMap.size() > 0) {
                                List<string> referenceFieldsList = new List<string>();
                                referenceFieldsList.addAll( fieldsAPIMap.keySet() );
                                select_clause += ', ';
                                select_clause += string.join(referenceFieldsList, ', ');
                            }

                            string query_str = 'SELECT '+select_clause+' FROM '+from_clause+' WHERE '+where_clause;
                            List<SObject> amSobjList = new List<SObject>();
                            amSobjList = Database.query( query_str );
                            if (amSobjList != null && amSobjList.size() > 0) {

                                ExAMUtilClass.AssessableObjectInAMClass assessableObjectDetails = ExAMUtilClass.getAssessableObjectDetailsFromAM( amSobjList );
                                tempId = assessableObjectDetails.managerIdWithAssessmentTemplateIdMap.get( amSobjList.get(0).Id );
                                objId = assessableObjectDetails.managerIdWithAssessableObjectIdMap.get( amSobjList.get(0).Id );
                                Id recordId = (Id)objId;
                                assessbleObjAPI = recordId.getSObjectType().getDescribe().getName();
                                if ( objId != null && objId != '' ) {
                                    hasAssessableObj = true;
                                }
                            }

                        } else if (paList[0].Assessible_Object_ID__c != null && paList[0].Assessible_Object_ID__c != ''
                                  && paList[0].Assessment_Template__c != null) {
                                hasAssessableObj = true;
                                tempId = (string)paList[0].Assessment_Template__c;
                                objId = (string)paList[0].Assessible_Object_ID__c;
                                Id recordId = (Id)objId;
                                assessbleObjAPI = recordId.getSObjectType().getDescribe().getName();

                        } else if(paList[0].Assessable_Object_API__c != null && paList[0].Assessable_Object_API__c != ''
                                  && paList[0].Assessment_Template__c != null) {
                            hasAssessableObj = true;
                            assessbleObjAPI = paList[0].Assessable_Object_API__c;
                            tempId = (string)paList[0].Assessment_Template__c;
                        }

                        if (objId != '') {
                            Schema.DescribeSObjectResult dsor = Id.valueOf(objId).getSObjectType().getDescribe();
                            sObjName = (dsor.isCustom() ) ? dsor.getLocalName() : dsor.getName();
                        } 

                        if (string.isNotBlank(tempId)) {
                            List<Main_questionaire__c> templateList = new List<Main_questionaire__c>();
                            
                            templateList = [
                                SELECT Id, Google_Analytics_Script__c, Modal_Window_Text__c,
                                       Name, Public_Assessment_Page_Footer__c, Public_Assessment_Page_Header__c,
                                       Static_Resource_Name__c, SRFile_Path__c, Template_name__c, Hide_Section_titles__c,
                                       Public_Assessment_Single_Question_Mode__c,Auto_Submit__c,Web_Intercept_PA_Resource_File_Path__c,
                                       Web_Intercept_PA_Static_Resource_Name__c, Public_Assessment_Viewer_Tab_Icon__c,
                                       Public_Assessment_Viewer_Title__c,PA_Header_and_Button_Background_Color__c,PA_Header_and_Button_Text_Color__c,
                                       PA_Template_Heading_Text__c,Enable_Section_Description__c,Enable_Survey_Intro_Text__c,
                                       Enable_Survey_Overlay__c, Survey_Overlay_Header_Text__c, Survey_Overlay_Text__c,
                                       Survey_Overlay_button_Text__c
                                FROM   Main_questionaire__c
                                WHERE  Id = :tempId
                            ];

                            if (templateList != null && templateList.size() > 0) {
                                customScriptConfigured = templateList[0].Google_Analytics_Script__c;
                                if(customScriptConfigured != null && customScriptConfigured !='' &&(customScriptConfigured.contains('<script>')||customScriptConfigured.contains('</script>'))) {
                                    customScriptConfigured=customScriptConfigured.replaceAll('<script>','') ;
                                    customScriptConfigured=customScriptConfigured.replaceAll('</script>','');
                                } 
                                headerStr = templateList[0].Public_Assessment_Page_Header__c; //This text changed as survey intro text in V1.56
                                singleQuestionMode = templateList[0].Public_Assessment_Single_Question_Mode__c;
                                hideSectionTitles = templateList[0].Hide_Section_titles__c;
                                autoSubmit = templateList[0].Auto_Submit__c;
                                showSecDesc = templateList[0].Enable_Section_Description__c;
                                showIntroText = templateList[0].Enable_Survey_Intro_Text__c;
                                    
                                if (string.isNotBlank(templateList[0].Public_Assessment_Viewer_Tab_Icon__c)) {
                                    List<StaticResource> srList = new List<StaticResource>([SELECT ContentType, Body FROM StaticResource WHERE Name = :templateList[0].Public_Assessment_Viewer_Tab_Icon__c]);
                                    if (srList != null && srList.size() > 0) {
                                        tabIconSRName = 'data:'+srList[0].ContentType+';base64,'+EncodingUtil.base64Encode(srList[0].Body);
                                    }
                                }
                                if (string.isNotBlank(templateList[0].Public_Assessment_Viewer_Title__c)) {
                                    tabTitle = templateList[0].Public_Assessment_Viewer_Title__c;
                                }
                                
                                if( templateList[0].Enable_Survey_Overlay__c ) { 
                                    overlayDetailMap.put('isEnable',string.valueOf(templateList[0].Enable_Survey_Overlay__c));
                                    if(string.isNotBlank(templateList[0].Survey_Overlay_Header_Text__c)) {
                                        overlayDetailMap.put('Header',templateList[0].Survey_Overlay_Header_Text__c);
                                    }
                                    if(string.isNotBlank(templateList[0].Survey_Overlay_Text__c) && !overlayDetailMap.containsKey('Body')) {
                                        overlayDetailMap.put('Body',templateList[0].Survey_Overlay_Text__c);
                                    }
                                    if(string.isNotBlank(templateList[0].Survey_Overlay_button_Text__c)) {
                                        overlayDetailMap.put('ButtonText',templateList[0].Survey_Overlay_button_Text__c);
                                    }
                                    overlayDetailStr = JSON.serialize(overlayDetailMap);
                                }
                                
                                /** Start dynamic css AfterV1.58 **/
                                if (webIntercept != null && webIntercept){
                                    srName = templateList[0].Web_Intercept_PA_Static_Resource_Name__c;
                                    path = templateList[0].Web_Intercept_PA_Resource_File_Path__c;
                                } else {
                                    srName = templateList[0].Static_Resource_Name__c;
                                    path = templateList[0].SRFile_Path__c;
                                }
                                List<Attachment> attachmentList = new List<Attachment>([SELECT Id FROM Attachment WHERE ParentId = :templateList[0].Id AND Name = 'userLogo' ORDER BY LastModifiedDate DESC LIMIT 1]);
                                if(attachmentList.size() > 0) {
                                    imgURl = siteStr+'/servlet/servlet.FileDownload?file='+attachmentList[0].Id;
                                }
                                if(string.isNotBlank(templateList[0].PA_Template_Heading_Text__c)) {
                                    if(templateList[0].PA_Template_Heading_Text__c.contains('{') && templateList[0].PA_Template_Heading_Text__c.contains('}')) {
                                        integer strIndex = (templateList[0].PA_Template_Heading_Text__c.indexOf('{'))+1;
                                        string assObjField = templateList[0].PA_Template_Heading_Text__c.substring(strIndex,templateList[0].PA_Template_Heading_Text__c.indexOf('}'));
                                        boolean isassObjField = false;
                                        if(string.isNotBlank(sObjName)) {
                                            Map <string, Schema.SObjectField> assObjFieldMap = Schema.getGlobalDescribe().get(sObjName).getDescribe().fields.getMap();
                                            if(assObjFieldMap != null && assObjFieldMap.size() > 0 ) {
                                                for (Schema.SObjectField assField : assObjFieldMap.Values()) {
                                                    Schema.DescribeFieldResult fieldDesc = assField.getDescribe();
                                                    if(assObjField==fieldDesc.getName()) {
                                                        isassObjField = true;
                                                    }
                                                }
                                            }
                                            if(isassObjField && objId != '' ) {
                                                string assObjQuery = 'SELECT Id, '+string.EscapeSingleQuotes(assObjField)+' FROM '+string.EscapeSingleQuotes(sObjName)+' WHERE Id = :objId LIMIT 1';
                                                List<sObject> assObjList = Database.query(assObjQuery);
                                                if(assObjList != Null && assObjList.size() > 0) {
                                                    string targetStr = '{'+assObjField+'}';
                                                    string replaceStr = string.valueOf(assObjList[0].get(assObjField));
                                                    headerText = templateList[0].PA_Template_Heading_Text__c.replace(targetStr,replaceStr);
                                                }
                                            } else {
                                                headerText = templateList[0].PA_Template_Heading_Text__c;
                                            }
                                        }
                                    } else {
                                        headerText = templateList[0].PA_Template_Heading_Text__c;
                                    }
                                }
                                
                                if (srName != null && srName !='') {
        
                                    List<StaticResource> resourceList = [
                                       SELECT Id, Name, Body, NamespacePrefix, SystemModStamp
                                       FROM StaticResource
                                       WHERE Name = :srName
                                    ];
                                    
                                    if (resourceList.size() == 1) {
                                       string namespace = resourceList[0].NamespacePrefix;
        
                                       if(siteStr != null && siteStr != '') {
                                           srName = siteStr+'/resource/'
                                              + resourceList[0].SystemModStamp.getTime() + '/'
                                              + (namespace != null && namespace != '' ? namespace + '__' : '')
                                              + srName;
                                       } else {
                                           srName = '/resource/'
                                              + resourceList[0].SystemModStamp.getTime() + '/'
                                              + (namespace != null && namespace != '' ? namespace + '__' : '')
                                              + srName;
                                       }
                                    }
                                    if(path != null && path != '') {
                                        pathList = new List<string>();
                                        pathList = path.split('~');
                                    }
                                    if(pathList != null && pathList.size() > 0) {
                                        Integer j = 0;
                                        while (j < pathList.size()) {
                                            if(pathList[j].indexOf('header.html') > 0) {
                                                headerFilePath = srName + pathList[j];
                                                pathList.remove(j);
                                            } else if(pathList[j].indexOf('footer.html') > 0) {
                                                footerFilePath = srName + pathList[j];
                                                pathList.remove(j);
                                            } else if(pathList[j].indexOf('script.js') > 0) {
                                                scriptFilePath = srName + pathList[j];
                                                pathList.remove(j);
                                            } else {
                                                j++;
                                            } 
                                        }
                                    }
                                    System.debug(':headerFilePath:::'+headerFilePath);
                                    System.debug('::footerFilePath::'+footerFilePath);
                                    System.debug('::scriptFilePath::'+scriptFilePath);
                                } else {
                                    String bgColor = templateList[0].PA_Header_and_Button_Background_Color__c;
                                    String color = templateList[0].PA_Header_and_Button_Text_Color__c;
                                    if(String.isNotBlank(bgColor) && String.isNotBlank(color)) {
                                        basicStyle = '.header-wrap { background-color: '+bgColor+' !important;color: '+color+' !important; }.slds .slds-card__header { background-color: '+bgColor+' !important;color: '+color+' !important; }';
                                        basicStyle += '.slds .slds-button--brand { background-color: '+bgColor+' !important; color: '+color+' !important; }';
                                    } else if(string.isNotBlank(bgColor)) {
                                        basicStyle = '.header-wrap { background-color: '+bgColor+' !important;}.slds .slds-card__header { background-color: '+bgColor+' !important; }';
                                        basicStyle += '.slds .slds-button--brand { background-color: '+bgColor+' !important; }';
                                    } else if(string.isNotBlank(color)) {
                                        basicStyle = '.header-wrap { color: '+color+' !important; }.slds .slds-card__header { color: '+color+' !important; }';
                                        basicStyle += '.slds .slds-button--brand { color: '+color+' !important; }';
                                    }
                                    footerStr = templateList[0].Public_Assessment_Page_Footer__c;
                                }
                                /** End dynamic css **/
                            }
                        }
                    } 
                }
            }
        } catch (Exception e){
            errHandler = JSON.serialize(new ErrorClass(e.getTypeName(),e.getMessage()));
            System.debug(':::errHandler:::'+errHandler);
        }
    }//end constructor
    
    public class ErrorClass {
        public string errType{get; set;}
        public string errMsg{get; set;}
        
        public ErrorClass(){}
        public ErrorClass(string etype, string eMsg) {

            this.errType = etype;
            this.errMsg = eMsg; 
        }
    }
    //All are below code was not used (on 16-12-2017) for "Restructure Question type"
    @RemoteAction
    global static string returnSectionAndQuestionTemplate(string assessmentTemplateId, Boolean isSingleQuestionMode) {
        return null;
    }
    @RemoteAction
    global static string saveAnswerRecords(List<AnswerRecordClass> answerList,Map<Id,Map<string,string>> responseFile, 
                                            string tempId, string assessibleObjId, string assessibleFieldApiName, 
                                            string amReqdStatus, string assessibleObjReferenceForAnsCreation, string amId,
                                            string publicAssessmentId, string ipAddress, List<Questionnaire_Response__c> resultQuestionAnswers,
                                            string startTimeStr, Map<string, CaseRecordClass> caseRec, Map<string, string> decisionTreeQuesIdAnsId) {
        
        return null;
    }
    @RemoteAction
    global static string saveAnswerRecord(List<AnswerRecordClass> answerList,Map<Id,Map<string,string>> responseFile, 
                                            string tempId, string assessibleObjId, string assessibleFieldApiName, 
                                            string amReqdStatus, string assessibleObjReferenceForAnsCreation, string amId,
                                            string publicAssessmentId, string ipAddress, List<Questionnaire_Response__c> resultQuestionAnswers,
                                            string startTimeStr, Map<string, CaseRecordClass> caseRec, Map<string, string> decisionTreeQuesIdAnsId, Map<Id,Id> quesIdANDAnsIdMap) {
        return null;
    }
    @RemoteAction
    global static string saveDecisionTreeAnswerRecords(List<Questionnaire_Response__c> decisionTreeAnsList, string tempId, string assessibleObjId, string assessibleFieldApiName, string amReqdStatus, string assessibleObjReferenceForAnsCreation, string createdAMId) {
        return null;
    }
    @RemoteAction
    global static string saveAttachments(List<AttachmentDetails> attDtlObj) {
        return null;
    }
    @RemoteAction       
    global static string saveAttachment(List<AttachmentDetails> attDtlObj,List<string> alreadyAnsweredId) {
        return null;
    }
    @RemoteAction
    global static string query(string soql) {
        return null;
    }
    @RemoteAction
    global static List<IssueRequest_Life_Cycle__c> modalPopupRec(string assmngrId) {
        return null;
    }
    @RemoteAction
    global static Map<string,string> modalPopupRec1(string tempId,string assmngrId) {
        return null;
    }
    global static string makeError(string message, string errorCode) {
        return null;
    }
    global class attachmentClass {}
    global class AnswerRecordClass {}
    global class AttachmentDetails {}
    global class CaseRecordClass {}
    
}