public with sharing class AssessmentViewerController {
    
    public string assignmentManagerId ;
    public string assessmentTempId;
    public string hierarchicalListJSON { get; set; }
    public string bannerId { get;set; }
    public string selectedViewerConfigJSON { get; set; }
    public Boolean Show_Configuration_Options_in_Viewer { get; set; }
    public Boolean show_Question_Name_on_Decision_Tree { get; set; }
    
    //Added on 08-11-2017 for No assessable obj mapped.
    public Boolean hasAssessableObj { get; set; }
        
    public AssessmentViewerController() {
    
        assignmentManagerId = apexPages.currentPage().getparameters().get('amid');
        assessmentTempId = apexPages.currentPage().getParameters().get('asstempid');
        hierarchicalListJSON = '';
        hasAssessableObj = false;
        selectedViewerConfigJSON = JSON.serialize(new Viewer_Custom_Configuration__c ());
        
        List<IssueRequest_Life_Cycle__c> assignmentManagerList = new List<IssueRequest_Life_Cycle__c>();
        Show_Configuration_Options_in_Viewer = false;
        
        try{
            /* Start - Show the Question Label as link in the decision tree modal window 19-09-2016 */
            show_Question_Name_on_Decision_Tree = false;
            Admin_Configuration__c adminConf = Admin_Configuration__c.getInstance(UserInfo.getUserId());
            if (adminConf != null && adminConf.Show_Question_Name_on_Decision_Tree__c != null ) {
                show_Question_Name_on_Decision_Tree = adminConf.Show_Question_Name_on_Decision_Tree__c;
            }
            
            /* End - Show the Question Label as link in the decision tree modal window 19-09-2016 */
            /* Start Find Hierarchy viewer object */
    
            ExAMUtilClass.AssessableObjectDetails objectDetailAM = ExAMUtilClass.getAssessableObjectDetails('ExAM__IssueRequest_Life_Cycle__c');
            Map<string, string> fieldsMapAM = objectDetailAM.assessableObjectAPIMap;
    
            ExAMUtilClass.AssessableObjectDetails objectDetailANS = ExAMUtilClass.getAssessableObjectDetails('ExAM__Questionnaire_Response__c');
            Map<string, string> fieldsMapANS = objectDetailANS.assessableObjectAPIMap;
    
            Map<string,string> assignmentManagerFieldAnswerFieldMap = new Map<string,string>(); 
            assignmentManagerFieldAnswerFieldMap.put('ExAM__Facility_Name__c', 'ExAM__Account_to_Response__c');
    
            List<ExAMUtilClass.AssessableRecordsClass> AssessableRecords = new List<ExAMUtilClass.AssessableRecordsClass>();
            Set<string> decisionTreeQuestionSet =  new Set<string>();
            
            for (string ansfield : fieldsMapANS.keySet()) {
            
                string AssessableObjectNameInANS = fieldsMapANS.get(ansfield);
                for (string amfield : fieldsMapAM.keySet()) {
    
                    string AssessableObjectNameInAM = fieldsMapAM.get(amfield);
                    if (AssessableObjectNameInANS == AssessableObjectNameInAM) {
    
                        assignmentManagerFieldAnswerFieldMap.put(amfield, ansfield);
                        break;
                    }
                }
            }
            /* End Find Hierarchy viewer object */
            
            if (assessmentTempId != null && assessmentTempId != '' && assignmentManagerId != null && assignmentManagerId != '') {
                string amQuery = 'SELECT Id, ExAM__Show_Configuration_Options_in_Viewer__c, ExAM__Status__c, ';
                amQuery += 'ExAM__InvestigationType__c, ExAM__InvestigationType__r.ExAM__Viewer_Configuration__c, ExAM__InvestigationType__r.ExAM__One_Time_Assessment__c,ExAM__InvestigationType__r.ExAM__Context_Questions_Mapping__c';
                
                for (string fldName : assignmentManagerFieldAnswerFieldMap.keySet()) {
                    amQuery += ' ,' + fldName;
                }
                amQuery += ' FROM ExAM__IssueRequest_Life_Cycle__c WHERE Id = :assignmentManagerId LIMIT 1';
                system.debug('::::amQuery:::'+amQuery);
                
                SFDCAccessController accessForobj = ExAMUtilClass.AccessController;
                List<string> fieldsList = new List<string>{'ExAM__Show_Configuration_Options_in_Viewer__c', 'ExAM__Status__c','ExAM__InvestigationType__c'};
                accessForobj.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__IssueRequest_Life_Cycle__c'), fieldsList);
                
                List<string> fieldsList1 = new List<string>{'ExAM__Viewer_Configuration__c', 'ExAM__One_Time_Assessment__c','ExAM__Context_Questions_Mapping__c'};
                accessForobj.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Main_questionaire__c'), fieldsList1);
                assignmentManagerList = Database.query(amQuery );
    
                if (assignmentManagerList != null && assignmentManagerList.size() > 0 ) {
                    
                    AssessableRecords = ExAMUtilClass.getAssessableRecords(assignmentManagerList, true);
                    if( AssessableRecords != null && AssessableRecords.size() > 0 ){
                        hasAssessableObj = true;
                    }
    
                }
                hierarchicalListJSON = JSON.serialize( AssessableRecords );
                List<string> fieldsList3 = new List<string>{'ExAM__Subquestion_Label__c', 'ExAM__Weight_of_Answer__c', 'ExAM__HelpText__c','ExAM__Section_Question__c','ExAM__Question_Label__c', 'ExAM__Question_Order_No__c','ExAM__Question_Type__c',
                                                    'ExAM__Next_Question__c', 'ExAM__Is_Mandatory__c', 'ExAM__Do_Not_Create_Answer__c','ExAM__Video_URL__c','ExAM__Default_Value__c', 'ExAM__Is_Dependent__c', 'ExAM__Dependent_Question__c', 
                                                    'ExAM__Has_Picture__c', 'ExAM__Field_Length__c', 'ExAM__Hotspot_Image_Properties__c','ExAM__Disabled__c','ExAM__Single_Next_Question__c'};
                accessForobj.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Question_Template__c'), fieldsList3);
                
                List<string> fieldsList4 = new List<string>{'ExAM__Order_No__c','ExAM__Help_Text__c','ExAM__Weight__c'};
                accessForobj.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Answer_Option__c'), fieldsList4);
                Map<Id, Question_Template__c> questionsMap = new Map<Id, Question_Template__c> ([ SELECT Id, Name, Subquestion_Label__c, Weight_of_Answer__c, HelpText__c, 
                                                                Section_Question__c, Section_Question__r.Questionnaire_Section__c, Question_Label__c, Question_Order_No__c, 
                                                                Question_Type__c, Next_Question__c, Is_Mandatory__c, Do_Not_Create_Answer__c, Video_URL__c,Default_Value__c,Single_Next_Question__r.Name,
                                                                Is_Dependent__c, Dependent_Question__c, has_Picture__c, Field_Length__c, Hotspot_Image_Properties__c,Disabled__c,Single_Next_Question__c,
                                                                (SELECT Id,Name,Order_No__c,Help_Text__c,Weight__c,Dependent_Question__r.Name,Next_Question__r.Name FROM Answer_Options__r ORDER BY Order_No__c ASC)
                                                            FROM Question_Template__c 
                                                            WHERE Section_Question__r.Questionnaire_Section__c =:assessmentTempId AND Is_Dependent__c = false
                                                            ORDER BY Question_Order_No__c ASC NULLS LAST]);           
                
                List<Question_Template__c> questionTempList = new List<Question_Template__c>();
                for (Question_Template__c quesTm : questionsMap.Values()) {
                    if( quesTm.Single_Next_Question__c != null && quesTm.Single_Next_Question__r.Name != '' ){
                        decisionTreeQuestionSet.add(quesTm.Single_Next_Question__r.Name);
                    } else {
                        if( quesTm.Answer_Options__r.size() == 0 ) {
                            if (quesTm.Next_Question__c != null ) {
                                 List<string> questionNameSplit = new List<string>();
                                if(quesTm.Next_Question__c.contains('~')){
                                    questionNameSplit = CommonViewerController.trimAnswerOption(quesTm.Next_Question__c);
                                } else {
                                    questionNameSplit.add(quesTm.Next_Question__c);
                                }
                                if (questionNameSplit != null && questionNameSplit.size() > 0) {
                                    decisionTreeQuestionSet.addAll(questionNameSplit);
                                }
                            }
                        } else {
                            List<string> nextQuestionsList = new List<string>();
                            for( Answer_Option__c ansOpt : quesTm.Answer_Options__r ){
                                nextQuestionsList.add(ansOpt.Next_Question__r.Name);
                            }
                            if ( nextQuestionsList != null && nextQuestionsList.size() > 0 ) {
                                decisionTreeQuestionSet.addAll(nextQuestionsList);
                            }                        
                        }
                    }
                }
    
                system.debug('<<<<questionsMap>>>>'+questionsMap);
                for (Question_Template__c quesTm : questionsMap.Values()) {
                    if ( !quesTm.Disabled__c && (decisionTreeQuestionSet == null || (decisionTreeQuestionSet != null && !decisionTreeQuestionSet.contains(quesTm.Name) && quesTm.Question_Type__c != 'Result')) && quesTm.Question_Type__c != 'Hidden' ) {
                        questionTempList.add(quesTm);
                        
                    }
                }
                system.debug('<<<<questionTempList>>>>'+questionTempList);
                
                Map<Id, string> questionIdwithAttIdMap = new map<Id, string>();
    
                for(Attachment  att : [SELECT Id, Name, ParentId, ContentType FROM Attachment WHERE ParentId IN :questionsMap.keySet() AND ContentType LIKE 'image%' AND Name Like '%Question-image%' ORDER BY Name]) {
                    questionIdwithAttIdMap.put(att.ParentId, att.Id);
                }
                
                List<Attachment> attlist = [SELECT Id, name, ParentId FROM Attachment WHERE Name LIKE 'banner%' AND ParentId =: assessmentTempId Limit 1];
                if (attlist != null && attlist.size() > 0) {
                    bannerId = attlist[0].id;
                }
                
                if (assignmentManagerList != null && assignmentManagerList.size() > 0 && assignmentManagerList[0].InvestigationType__c != null && assignmentManagerList[0].InvestigationType__r.Viewer_Configuration__c != null) {
                    List<string> FieldsList5 = new List<string>{'ExAM__Answer_Options__c','ExAM__Data_Management__c','ExAM__Hierarchical_Object__c','ExAM__Single_Question_Mode__c','ExAM__Assignment_Manager__c','ExAM__Assignment_Manager_List__c'};
                    accessForobj.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Viewer_Custom_Configuration__c'), fieldsList5);
                    List<Viewer_Custom_Configuration__c> viewerConfigList = [ SELECT Id, Answer_Options__c, Data_Management__c, Hierarchical_Object__c, Single_Question_Mode__c, Assignment_Manager__c, Assignment_Manager_List__c 
                                                                              FROM Viewer_Custom_Configuration__c 
                                                                              WHERE Id =: assignmentManagerList[0].InvestigationType__r.Viewer_Configuration__c
                                                                              LIMIT 1];
                    if (viewerConfigList != null && viewerConfigList.size() > 0) {
                        selectedViewerConfigJSON = JSON.serialize(viewerConfigList[0]);
                    }
                    Show_Configuration_Options_in_Viewer = assignmentManagerList[0].Show_Configuration_Options_in_Viewer__c;
                }
            }
            
        }catch (Exception e){
            system.debug('<<<<e>>>>'+e.getMessage());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        }
    }
}