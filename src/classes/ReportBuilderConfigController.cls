public with sharing class ReportBuilderConfigController {
    
    public String savedReportsJSON { get; set; }
    public String assessmentTemplateJSON { get; set; }
    public String reportBuilderListJSON { get; set; }
    public String amPositionJSON { get; set; }
    public String dataConfigJSON { get; set; }
    public String assessibleFieldDetailsJSON { get; set; }
    
    public String assObswithFieldsJSON { get; set; }

    public class assignmentManagerPositionCls {
        public String apiName;
        public String labelName;
        public Integer position;
        public assignmentManagerPositionCls(String api1, String label1, Integer position1) {
            apiName = api1;
            labelName = label1;
            position = position1;
        } 
    }
    
    //Start Assessable Object field select functionality.
    public class assessableObjFieldPositionCls {
        public String apiName;
        public String labelName;
        public Integer position;
        public assessableObjFieldPositionCls(String api1, String label1, Integer position1) {
            apiName = api1;
            labelName = label1;
            position = position1;
        } 
    }

    public List<assessableobjectwithFieldsClass> assessableObjNamewithFieldsList ; 

    public class assessableobjectwithFieldsClass {
        public String assessableObjectLabel;
        public String assessableObjectAPI;
        public String assignmentManagerApi;
        public List<assessableObjFieldPositionCls> assessablefields;
    }
    //End Assessable Object field select functionality.

    public List<AssessibleFieldDetails> assessibleFieldDtls;

    public class AssessibleFieldDetails {
        public string assessibleFieldApiName;
        public string assessibleFieldLabel;

        public AssessibleFieldDetails(String fieldApi, String fieldLabel) {
            this.assessibleFieldApiName = fieldApi;
            this.assessibleFieldLabel = fieldLabel;
        }
    }

    public class responseClass {
        public string resultMsg;
        public string recordId; 
    }

    public ReportBuilderConfigController() {

        try {

            savedReportsJSON = '';
            assessmentTemplateJSON = '';
            amPositionJSON = '';
            assessibleFieldDetailsJSON = '';
            dataConfigJSON = '';
            assessibleFieldDtls = new List<AssessibleFieldDetails>();
            List<assignmentManagerPositionCls> amPositionList = new List<assignmentManagerPositionCls>();
            List<Main_questionaire__c> templateList = new List<Main_questionaire__c>();
        
            assessableObjNamewithFieldsList = new List<assessableobjectwithFieldsClass> ();
            assObswithFieldsJSON = '';

            SFDCAccessController accessForAT = ExAMUtilClass.AccessController;
            List<String> fieldsListAT = new List<String>{'ExAM__Template_name__c'};
            accessForAT.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Main_questionaire__c'), fieldsListAT);

            templateList = [SELECT CreatedDate, Id, Name, Template_name__c FROM Main_questionaire__c ORDER BY CreatedDate DESC LIMIT 1000];
            if (templateList != null && templateList.size() > 0) {
                assessmentTemplateJSON = JSON.serialize(templateList);
            }

            SFDCAccessController accessForRBC = ExAMUtilClass.AccessController;
            List<String> fieldsListRBC = new List<String>{'ExAM__Assessment_Data_Config__c', 'ExAM__Assessable_Object_Field_Position__c', 'ExAM__Assessment_Template__c', 'ExAM__Assignment_Manager_position__c',
                                                            'ExAM__End_Date_Range__c', 'ExAM__Is_Temporary__c', 'ExAM__Output_Format__c', 'ExAM__Overall_Status__c', 'ExAM__Selected_Sections__c', 'ExAM__Start_Date_Range__c', 'ExAM__Choosed_Assignment_manager__c'};
            accessForRBC.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Report_Builder_Configuration__c'), fieldsListRBC);

            List<Report_Builder_Configuration__c> reportBuilderList = new List<Report_Builder_Configuration__c> ();
            reportBuilderList = [
                SELECT   Assessment_Data_Config__c, Assessable_Object_Field_Position__c, Assessment_Template__c,
                         Assignment_Manager_position__c, Choosed_Assignment_manager__c, End_Date_Range__c, Id, Is_Temporary__c,
                         Name, Output_Format__c, Overall_Status__c, Selected_Sections__c, Start_Date_Range__c
                FROM     Report_Builder_Configuration__c
                WHERE    Is_Temporary__c = false
                ORDER BY Createddate ASC LIMIT 1000
            ];
            if (reportBuilderList != null && reportBuilderList.size() > 0) {
                reportBuilderListJSON = JSON.serialize(reportBuilderList);
            }

            for (Schema.SObjectField amfield : ExAMUtilClass.getSObjectFieldsMap('ExAM__IssueRequest_Life_Cycle__c').values()) {
            
                Schema.DescribeFieldResult res = amfield.getdescribe();
                System.debug('::::Name::::'+res.getName());
                if (res.isCustom() || res.getName().equalsIgnoreCase('Name') || res.getName().equalsIgnoreCase('Id')) {
                    amPositionList.add(new assignmentManagerPositionCls(res.getName(), res.getLabel(),null));

                    if (res.getName().equalsIgnoreCase('ExAM__Status__c')) {

                        for(Schema.PickListEntry pklstentry : res.getPicklistValues()) {
                            assessibleFieldDtls.add( new AssessibleFieldDetails(pklstentry.getValue(), pklstentry.getLabel()) );
                        }
                    }

                    if (res.getType() == Schema.DisplayType.REFERENCE && ( res.getLocalName().startsWithIgnoreCase('AM_') || res.getLocalName().equalsIgnoreCase('Facility_Name__c')) ) {
                        List<Schema.SObjectType> s = res.getReferenceTo();
                        Schema.DescribeSObjectResult objResult = s[0].getDescribe();
                        assessableobjectwithFieldsClass assessableObj = new assessableobjectwithFieldsClass();
                        assessableObj.assessableObjectLabel = objResult.getLabel();
                        assessableObj.assessableObjectAPI = objResult.getName();
                        assessableObj.assignmentManagerApi = res.getName();
                        Map<string, Schema.SObjectField> assessableObjectFieldApiMap = Schema.getGlobalDescribe().get(objResult.getName()).getDescribe().fields.getMap();
                    
                        assessableObj.assessablefields = new List<assessableObjFieldPositionCls>();
                        for (Schema.SObjectField assfield : assessableObjectFieldApiMap.values()) {
                            Schema.DescribeFieldResult assDesfldRes = assfield.getdescribe();
                            System.debug('::::Name::::'+assDesfldRes.getName());
                            if (assDesfldRes.isCustom() || assDesfldRes.getName().equalsIgnoreCase('Name') || assDesfldRes.getName().equalsIgnoreCase('Id')) {
                                assessableObj.assessablefields.add(new assessableObjFieldPositionCls(assDesfldRes.getName(), assDesfldRes.getLabel(),null));
                            }
                        }
                        assessableObjNamewithFieldsList.add(assessableObj);
                        System.debug('::::assessableObjNamewithFieldsList::::'+assessableObjNamewithFieldsList);
                        assObswithFieldsJSON = JSON.serialize(assessableObjNamewithFieldsList);
                    }
                }            
            }
            System.debug(':::::amPositionList:::::'+amPositionList);
            if (amPositionList != null && amPositionList.size() > 0) {
                amPositionJSON = JSON.serialize(amPositionList);
            }

            System.debug(':::::assessibleFieldDtls:::::'+assessibleFieldDtls);
            if (assessibleFieldDtls != null && assessibleFieldDtls.size() > 0) {
                assessibleFieldDetailsJSON = JSON.serialize(assessibleFieldDtls);
            }
        
            List<String> dataConfigList = new List<String>();
            //dataConfigList.add('Questions');
            //dataConfigList.add('Answers');
            dataConfigList.add('Comments');
            dataConfigList.add('Pictures'); 
            dataConfigJSON  = JSON.serialize(dataConfigList);
        }
        catch(Exception e) {
            ApexPages.addMessage( new Apexpages.Message(ApexPages.Severity.ERROR, e.getMessage()) );
        }
    }

    @RemoteAction
    public static String queryAssignmentManagers(String searchName, String assTempId, String startDate, String endDate) {

        system.debug('::::::assTempId:::::'+assTempId);
        Date startTime;
        Date endTime ;
        string queryString = '';
        string response = '';

        try {

            List<IssueRequest_Life_Cycle__c> amList = new List<IssueRequest_Life_Cycle__c> ();
            if (searchName != null && searchName != '') {

                SFDCAccessController accessForAM = ExAMUtilClass.AccessController;
                List<String> fieldsListAM = new List<String>{'ExAM__Assessment_Template_Type__c', 'ExAM__Facility_Name__c', 'ExAM__InvestigationType__c', 'ExAM__Priority__c', 'ExAM__Scheduled_Start_Date__c', 'ExAM__Status__c'};
                accessForAM.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__IssueRequest_Life_Cycle__c'), fieldsListAM);

                queryString += 'SELECT Assessment_Template_Type__c, Facility_Name__c, Facility_Name__r.Name, Id, InvestigationType__c, Name, Priority__c, Scheduled_Start_Date__c, Status__c';
                queryString += ' FROM IssueRequest_Life_Cycle__c ';
                queryString += ' WHERE Name Like \''+searchName+'%\'';
                if (assTempId != null && assTempId != '') {
                    queryString += ' AND InvestigationType__c =:assTempId ';
                }
                if (startDate != null && startDate != '') {
                    List<String> dateStr = startDate.split('/');
                    if (dateStr != null && dateStr.size() >= 3) {
                        startTime = date.newinstance( Integer.valueOf(dateStr[2]), Integer.valueOf(dateStr[0]), Integer.valueOf(dateStr[1]) );
                        queryString += ' AND Scheduled_Start_Date__c >= :startTime';
                    }
                }
                if (endDate != null && endDate != '') {
                    List<String> dateStr = endDate.split('/');
                    
                    if (dateStr != null && dateStr.size() >= 3) {
                        endTime = date.newinstance( Integer.valueOf(dateStr[2]), Integer.valueOf(dateStr[0]), Integer.valueOf(dateStr[1]) );            
                        queryString += ' AND Scheduled_Start_Date__c <= :endTime';
                    }
                }
                queryString += ' ORDER BY CreatedDate DESC LIMIT 1000';
                System.debug(':::::queryString:::::'+queryString);
                amList = Database.query(queryString); //permission checked above            
                
            }
            response = JSON.serialize( amList );
        }
        catch(Exception e) {
            response = JSON.serialize( e.getMessage() );
        }
        return response;
    }
    @RemoteAction
    public static String querySectionTemplate(String assTempId) {

        string response = '';

        try {
            system.debug('::::::assTempId:::::'+assTempId);
        
            SFDCAccessController accessForST = ExAMUtilClass.AccessController;
            List<String> fieldsListST = new List<String>{'ExAM__Order_No__c', 'ExAM__Questionnaire_Section__c', 'ExAM__Section_label__c'};
            accessForST.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Section_Template__c'), fieldsListST);

            List<Section_Template__c> secList = new List<Section_Template__c> ();
            if (assTempId != null && assTempId != '') {
                secList = [
                    SELECT Id, Name, Order_No__c, Questionnaire_Section__c, Section_label__c
                    FROM   Section_Template__c 
                    WHERE  Questionnaire_Section__c =:assTempId ORDER BY Order_No__c ASC LIMIT 1000
                ]; 
            }
            response = JSON.serialize(secList);
        }
        catch(Exception e) {
            response = JSON.serialize( e.getMessage() );
        }
        return response;
    }
    
    @RemoteAction
    public static String saveReportBuilderConfig(String selectedReportValue, String selectedTemp, String reportBuilderName, String startdate, 
                            String enddate, String selectFormat,  String selectedAssignmentManager, String positionResult, 
                            String sectionSelectResult, Boolean isTemporary, String dataConfigResult, String assessableFieldConfig, String status) {
                    
        system.debug('::reportBuilderName:::'+reportBuilderName);
        system.debug('::startdate:::'+startdate);
        system.debug('::enddate:::'+enddate);
        system.debug('::selectFormat:::'+selectFormat);
        system.debug('::selectedAssignmentManager:::'+selectedAssignmentManager);
        system.debug('::positionResult:::'+positionResult);
        system.debug('::sectionSelectResult::'+sectionSelectResult);
        system.debug('::dataConfigResult::'+dataConfigResult);
        system.debug('::status::'+status);
        
        String resultMsg = '';
        
        try {

            if ( reportBuilderName != null && reportBuilderName != '') {

                SFDCAccessController access = ExAMUtilClass.AccessController;
                List<String> fieldsList = new List<String>{'ExAM__Is_Temporary__c', 'ExAM__Assessment_Template__c', 'ExAM__Output_Format__c', 'ExAM__Start_Date_Range__c', 'ExAM__End_Date_Range__c', 'ExAM__Choosed_Assignment_manager__c', 'ExAM__Assignment_Manager_position__c', 'ExAM__Selected_Sections__c', 'ExAM__Assessment_Data_Config__c', 'ExAM__Assessable_Object_Field_Position__c', 'ExAM__Overall_Status__c'};
                access.assertAuthorizedToCreate(Schema.getGlobalDescribe().get('exam__Report_Builder_Configuration__c'), fieldsList);
                access.assertAuthorizedToUpdate(Schema.getGlobalDescribe().get('exam__Report_Builder_Configuration__c'), fieldsList);

                Report_Builder_Configuration__c reportBuilderInsert = new Report_Builder_Configuration__c();
                if (selectedReportValue != null && selectedReportValue != '') {
                    reportBuilderInsert.Id = Id.valueOf(selectedReportValue);
                } else {
                    reportBuilderInsert.Name = reportBuilderName;
                    reportBuilderInsert.Is_Temporary__c = isTemporary;
                }
                reportBuilderInsert.Assessment_Template__c = selectedTemp != null && selectedTemp != '' ? Id.valueOf(selectedTemp) : null;
                reportBuilderInsert.Output_Format__c = selectFormat; 
                reportBuilderInsert.Start_Date_Range__c = startdate;
                reportBuilderInsert.End_Date_Range__c = enddate;
                reportBuilderInsert.Choosed_Assignment_manager__c = selectedAssignmentManager != null && selectedAssignmentManager != '' ? Id.valueof(selectedAssignmentManager) : null;
                reportBuilderInsert.Assignment_Manager_position__c = positionResult;
                reportBuilderInsert.Selected_Sections__c = sectionSelectResult; 
                reportBuilderInsert.Assessment_Data_Config__c = dataConfigResult;
                if (assessableFieldConfig != null && assessableFieldConfig != '') {
                    reportBuilderInsert.Assessable_Object_Field_Position__c = assessableFieldConfig;
                }
                reportBuilderInsert.Overall_Status__c = status;
                upsert reportBuilderInsert;

                responseClass res = new responseClass();
                res.resultMsg = 'success';
                res.recordId = reportBuilderInsert.Id; 
                resultMsg = JSON.serialize(res);
            }
            else {
                responseClass res = new responseClass();
                res.resultMsg = 'Please enter a name to save record';
                res.recordId = ''; 
                resultMsg = JSON.serialize(res);
            }
        } catch (Exception ex) {
            system.debug(':::::ex::::'+ex.getMessage());
            responseClass res = new responseClass();
            res.resultMsg = 'Error : '+ex.getMessage();
            res.recordId = ''; 

            resultMsg = JSON.serialize(res);
        }
        return resultMsg;
    } 
    
    @RemoteAction
    public static String queryAssignmentManager(String amId) {

        string response = '';

        try {
            SFDCAccessController accessForAM = ExAMUtilClass.AccessController;
            if (amId != null && amId != 'null' && amId != '') {

                List<String> fieldsListAM = new List<String>{'ExAM__Assessment_Template_Type__c', 'ExAM__Facility_Name__c', 'ExAM__InvestigationType__c', 'ExAM__Priority__c', 'ExAM__Status__c', 'ExAM__Scheduled_Start_Date__c'};
                accessForAM.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__IssueRequest_Life_Cycle__c'), fieldsListAM);

                List<IssueRequest_Life_Cycle__c> amList = [
                    SELECT Assessment_Template_Type__c, Facility_Name__c, Facility_Name__r.Name, Id, InvestigationType__c,
                           Name, Priority__c, Status__c, Scheduled_Start_Date__c
                    FROM   IssueRequest_Life_Cycle__c
                    WHERE  Id = :amId LIMIT 1
                ];
                if (amList != null && amList.size() > 0) {
                    response = JSON.serialize( amList[0] );
                }
            }
            else {
                response = JSON.serialize( 'Please provide a valid assignment manager id' );
            }
        }
        catch(Exception e) {
            response = JSON.serialize( e.getMessage() );
        }
        return response;
    }   

    @RemoteAction
    public static string deleteReportBuilderConfig(String deletedIdJSON) {

        string response = '';

        try {

            system.debug(':::::deletedIdJSON::::'+deletedIdJSON);
            Map<String, Boolean> deleteReportIdwithIsSelectedMap = (Map<String, Boolean>)System.JSON.deserialize(deletedIdJSON,Map<String, Boolean>.class);
            List<Report_Builder_Configuration__c> deleteList = new List<Report_Builder_Configuration__c>();
            SFDCAccessController accessForRBCDel = ExAMUtilClass.AccessController;
            for (string idval : deleteReportIdwithIsSelectedMap.keySet()) {
                if (deleteReportIdwithIsSelectedMap.get(idval)) {
                    deleteList.add(new Report_Builder_Configuration__c(Id = idval));
                }
            }
            if (deleteList != null && deleteList.size() > 0) {
                
                if ( accessForRBCDel.isAuthorizedToDelete(Schema.getGlobalDescribe().get('exam__Report_Builder_Configuration__c')) ) {

                    delete deleteList;

                    List<String> fieldsListRBC = new List<String>{'ExAM__Assignment_Manager_position__c', 'ExAM__Assessment_Template__c', 'ExAM__Assessment_Data_Config__c', 'ExAM__Choosed_Assignment_manager__c', 'ExAM__End_Date_Range__c', 'ExAM__Is_Temporary__c', 'ExAM__Output_Format__c', 'ExAM__Selected_Sections__c', 'ExAM__Start_Date_Range__c'};
                    accessForRBCDel.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Report_Builder_Configuration__c'), fieldsListRBC);

                    List<Report_Builder_Configuration__c> reportBuilderList = new List<Report_Builder_Configuration__c>();
                    reportBuilderList = [
                        SELECT Assignment_Manager_position__c, Assessment_Template__c, Assessment_Data_Config__c,
                               Choosed_Assignment_manager__c, End_Date_Range__c, Id, Is_Temporary__c, Name,
                               Output_Format__c, Selected_Sections__c, Start_Date_Range__c
                        FROM   Report_Builder_Configuration__c WHERE Is_Temporary__c = false ORDER BY Createddate ASC LIMIT 1000
                    ];
                    if (reportBuilderList != null && reportBuilderList.size() > 0) {
                        response = JSON.serialize(reportBuilderList);
                    }
                }
                else {
                    response = JSON.serialize( 'You do not have access to delete Report Builder Configuration records' );
                }
            }
        }
        catch(Exception e) {
            response = JSON.serialize( e.getMessage() );
        }
        return response;
    }
}