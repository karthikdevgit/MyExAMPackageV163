public with sharing class ImportAssessmentTemplateController {

    @RemoteAction
    public static Map<string, string> saveAssessmentTemplate(List<Main_questionaire__c> assTempList, List<string> oldTempIdList) {
        Map<string, string> oldTempIdwithassessmentTempIdMap = new Map<string, string>();           
        try {
            if (assTempList != null && assTempList.size() > 0 && oldTempIdList != null && oldTempIdList.size() > 0 && oldTempIdList.size() == oldTempIdList.size()) {
                SFDCAccessController accessForobj = ExAMUtilClass.AccessController;
                List<string> fieldsList = new List<string>{'ExAM__Description__c','ExAM__PublishPlace__c','ExAM__TemplateFlag__c','ExAM__Template_External_Id__c','ExAM__Available_in_Portal__c','ExAM__Assessment_Completed_URL__c','ExAM__Score_By_Section_Weight__c','ExAM__Weight_Template__c','ExAM__Public_Assessment_Page_Footer__c','ExAM__Public_Assessment_Page_Header__c','ExAM__Show_Image_Upload_Icon__c','ExAM__Show_Notes_Icon__c',
                                                                'ExAM__Show_Refresh_Icon__c','ExAM__URL__c','ExAM__Modal_Window_Text__c','ExAM__Decision_Tree__c','ExAM__Show_Modal_Window__c','ExAM__Google_Analytics_Script__c','ExAM__Static_Resource_Name__c','ExAM__SRFile_Path__c','ExAM__Show_Question_Number__c','ExAM__Hide_Section_Titles__c','ExAM__Public_Assessment_Single_Question_Mode__c','ExAM__Context_Questions_Mapping__c',
                                                                'ExAM__Enable_Survey_Overlay__c','ExAM__Generate_Case_Or_Lead__c','ExAM__One_Time_Assessment__c','ExAM__Survey_Overlay_button_Text__c','ExAM__Survey_Overlay_Header_Text__c','ExAM__Survey_Overlay_Text__c','ExAM__Watchlist_Of_Words__c','ExAM__Web_Intercept_Header__c','ExAM__Web_Intercept_PA_Resource_File_Path__c','ExAM__Web_Intercept_PA_Static_Resource_Name__c',
                                                                'ExAM__Web_Intercept_Static_Resource_Name__c','ExAM__Web_Intercept_File_Path__c','ExAM__Auto_Submit__c','ExAM__Execute_Field_Mapping_On_AM__c','ExAM__isArchive__c','ExAM__Enable_Section_Description__c','ExAM__Enable_Survey_Intro_Text__c','ExAM__Public_Assessment_Viewer_Tab_Icon__c','ExAM__Public_Assessment_Viewer_Title__c','ExAM__Template_Group__c','ExAM__Web_Intercept_Header_color__c',
                                                                'ExAM__Result_Question_Button_Text__c','ExAM__Render_Next_Question_Automatically__c'};
                accessForobj.assertAuthorizedToCreate(Schema.getGlobalDescribe().get('exam__Main_questionaire__c'), fieldsList);
                insert assTempList;
                for (integer i = 0; i < assTempList.size(); i++) {
                    oldTempIdwithassessmentTempIdMap.put(oldTempIdList[i], assTempList[i].Id);
                }
            }
        }
        catch (Exception ex) {
            oldTempIdwithassessmentTempIdMap.put('error',ex.getMessage());
        }                
        return oldTempIdwithassessmentTempIdMap;
    }

    @RemoteAction
    public static Map<string, string> saveSectionTemplate(List<Section_Template__c> secTempList, List<string> oldSectIdList) {
        Map<string, string> oldSecIdwithsectIdMap = new Map<string, string>();
        try {
            if (secTempList != null && secTempList.size() > 0 && oldSectIdList != null && oldSectIdList.size() > 0 && oldSectIdList.size() == oldSectIdList.size()) {
                SFDCAccessController accessForobj = ExAMUtilClass.AccessController;
                List<string> fieldsList = new List<string>{'ExAM__Section_label__c','ExAM__Order_No__c','ExAM__Section_Description__c','ExAM__Section_Weight__c','ExAM__Questionnaire_Section__c','ExAM__Section_External_Id__c','ExAM__Subsectionlabel__c','ExAM__SuperSection__c','ExAM__status__c','ExAM__isArchive__c','ExAM__Random_Display_Count__c'};
                accessForobj.assertAuthorizedToCreate(Schema.getGlobalDescribe().get('exam__Section_Template__c'), fieldsList);
                insert secTempList;
                for (integer i = 0; i < secTempList.size(); i++) {
                    oldSecIdwithsectIdMap.put(oldSectIdList[i], secTempList[i].Id);
                }
            }
        }
        catch (Exception ex) {
            oldSecIdwithsectIdMap.put('error',ex.getMessage());
        }
        return oldSecIdwithsectIdMap;
    }

    @RemoteAction
    public static Map<string, Map<String, String>> saveQuestionTemplate(List<Question_Template__c> queTempList, List<string> oldquesIdList) {
        Map<string, string> oldQueIdwithqueIdMap = new Map<string, string>();
        Map<String, Map<String, String>> resultMap = new Map<String, Map<String, String>>();
        try {
            if (queTempList != null && queTempList.size() > 0 && oldquesIdList != null && oldquesIdList.size() > 0 && oldquesIdList.size() == oldquesIdList.size()) {
                SFDCAccessController accessForobj = ExAMUtilClass.AccessController;
                List<string> fieldsList = new List<string>{'ExAM__Question_Label__c','ExAM__Question_Type__c','ExAM__Question_Order_No__c','ExAM__Weight_Of_Question__c','ExAM__Subquestion_Label__c','ExAM__SubSection_label__c','ExAM__Weight_of_Answer__c','ExAM__Focus_category__c','ExAM__Next_Question__c','ExAM__Dependent_Question__c','ExAM__HelpText__c',
                                                    'ExAM__Question_External_Id__c','ExAM__Do_Not_Create_Answer__c','ExAM__Is_Mandatory__c','ExAM__Decision_Tree__c','ExAM__Field_Length__c','ExAM__Has_Picture__c','ExAM__Is_Dependent__c','ExAM__Knowledge_Article_Link__c','ExAM__Hotspot_Image_Properties__c','ExAM__Video_URL__c','ExAM__Default_Value__c',
                                                    'ExAM__Question_Restricted_Length__c','ExAM__Disabled__c','ExAM__Question_Short_Name__c','ExAM__Single_Next_Question__c'};
                accessForobj.assertAuthorizedToCreate(Schema.getGlobalDescribe().get('exam__Question_Template__c'), fieldsList);
                insert queTempList;
                for (integer i = 0; i < queTempList.size(); i++) {
                    oldQueIdwithqueIdMap.put(oldquesIdList[i], queTempList[i].Id);
                }
                resultMap.put('newQuesNameMap',oldQueIdwithqueIdMap);
            }
        }
        catch (Exception ex) {
            oldQueIdwithqueIdMap.put('error',ex.getMessage());
            resultMap.put('error',oldQueIdwithqueIdMap);
        }
        return resultMap;
    }

    @RemoteAction
    public static Map<string, string> saveAnswerOptions(List<Answer_Option__c> answerOptList, List<string> oldAnsOptIdList) {
        Map<string, string> oldAnsOptIdwithAnsOptIdMap = new Map<string, string>();
        try {
            if (answerOptList != null && answerOptList.size() > 0 && oldAnsOptIdList != null && oldAnsOptIdList.size() > 0 ) {
                SFDCAccessController accessForobj = ExAMUtilClass.AccessController;
                List<string> fieldsList = new List<string>{'ExAM__Weight__c','ExAM__Help_Text__c','ExAM__Next_Question__c','ExAM__Dependent_Question__c','ExAM__Order_No__c','ExAM__Question_Template__c'};
                accessForobj.assertAuthorizedToCreate(Schema.getGlobalDescribe().get('exam__Answer_Option__c'), fieldsList);
                insert answerOptList;
                for (integer i = 0; i < answerOptList.size(); i++) {
                    oldAnsOptIdwithAnsOptIdMap.put(oldAnsOptIdList[i], answerOptList[i].Id);
                }
            }
        }
        catch (Exception ex) {
            oldAnsOptIdwithAnsOptIdMap.put('error',ex.getMessage());
        }
        return oldAnsOptIdwithAnsOptIdMap;
    }

    @RemoteAction
    public static string decisionTreeQuestionUpdate(List<string> templateIdList, Map<string, string> questionNamewithNewIdMap, Map<String, String> oldQuesNameAndSingleQuesNameMap) {
        string responseMsg = '';
        try{
            if (templateIdList != null && templateIdList.size() > 0 && questionNamewithNewIdMap != null && questionNamewithNewIdMap.size() > 0) {
                List<Question_Template__c> updatedList = new List<Question_Template__c>();

                SFDCAccessController accessForobj = ExAMUtilClass.AccessController;
                List<string> fieldsList = new List<string>{'ExAM__Dependent_Question__c','ExAM__Next_Question__c','ExAM__Section_Question__c','ExAM__Single_Next_Question__c'};
                accessForobj.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Question_Template__c'), fieldsList);

                Map<Id, Question_Template__c> updatableRecordMap = new Map<Id, Question_Template__c>([SELECT Id,Name, Dependent_Question__c,  Next_Question__c, Section_Question__c, Section_Question__r.Questionnaire_Section__c, 
                                                        Single_Next_Question__c,Single_Next_Question__r.Name
                                                        FROM Question_Template__c
                                                        WHERE Section_Question__r.Questionnaire_Section__c IN :templateIdList]);

                for (string qtId : updatableRecordMap.keySet()) {
                    Question_Template__c qt = updatableRecordMap.get(qtId);
                    string newDependQuestion = '';
                    string newNextQuestion = '';
                    Question_Template__c qTemp = new Question_Template__c();
                    
                    if( oldQuesNameAndSingleQuesNameMap != null && oldQuesNameAndSingleQuesNameMap.size() > 0 ){
                        for( String oldname :oldQuesNameAndSingleQuesNameMap.keyset() ){
                            if( qtId == questionNamewithNewIdMap.get(oldname) ){
                                if( oldQuesNameAndSingleQuesNameMap.get(oldname) != null && oldQuesNameAndSingleQuesNameMap.get(oldname) != '' && 
                                    questionNamewithNewIdMap.containsKey(oldQuesNameAndSingleQuesNameMap.get(oldname)) ){
                                    qTemp.Id = qtId;
                                    qTemp.Single_Next_Question__c = questionNamewithNewIdMap.get(oldQuesNameAndSingleQuesNameMap.get(oldname));
                                }
                                break;
                            }
                        }
                    }
                    if((qt.Next_Question__c != null && qt.Next_Question__c != '' && qt.Next_Question__c.contains('Q-'))
                        || (qt.Dependent_Question__c != null && qt.Dependent_Question__c != '' && qt.Dependent_Question__c.contains('Q-'))
                    ) {

                        if(qt.Next_Question__c != null && qt.Next_Question__c != '' && qt.Next_Question__c.contains('Q-') ) {

                            for (string oldQName : qt.Next_Question__c.split('~')) {
                                oldQName = oldQName.trim();
                                if (questionNamewithNewIdMap.containsKey(oldQName) && updatableRecordMap.containsKey(questionNamewithNewIdMap.get(oldQName))) {
                                    if (newNextQuestion != '') {
                                        newNextQuestion += '~'+updatableRecordMap.get(questionNamewithNewIdMap.get(oldQName)).Name;
                                    } else {
                                        newNextQuestion += updatableRecordMap.get(questionNamewithNewIdMap.get(oldQName)).Name;
                                    }             
                                } else {
                                    if ( newNextQuestion != '' ){
                                        newNextQuestion += '~'+oldQName;
                                    } else {
                                        newNextQuestion += oldQName;
                                    }
                                }
                            }
                        } 
                        if(qt.Dependent_Question__c != null && qt.Dependent_Question__c != '' && qt.Dependent_Question__c.contains('Q-') ) {

                            for (string oldDependent : qt.Dependent_Question__c.split('~')) {
                                oldDependent = oldDependent.trim();
                                if (questionNamewithNewIdMap.containsKey(oldDependent) && updatableRecordMap.containsKey(questionNamewithNewIdMap.get(oldDependent))) {
                                    if (newDependQuestion != '') {
                                        newDependQuestion += '~'+updatableRecordMap.get(questionNamewithNewIdMap.get(oldDependent)).Name;
                                    } else {
                                        newDependQuestion += updatableRecordMap.get(questionNamewithNewIdMap.get(oldDependent)).Name;
                                    }             
                                } else {
                                    if ( newDependQuestion != '' ){
                                        newDependQuestion += '~'+oldDependent;
                                    } else {
                                        newDependQuestion += oldDependent;
                                    }
                                }
                            }
                        }
                        qTemp.Id = qtId;
                        if(newNextQuestion != '') {
                            qTemp.Next_Question__c = newNextQuestion;
                        }
                        if(newDependQuestion != '') {
                            qTemp.Dependent_Question__c = newDependQuestion;
                        }
                        
                     }
                     if( qTemp != null && qTemp.Id != null ){
                         updatedList.add(qTemp); 
                     }
                }
                if (updatedList != null && updatedList.size() > 0 ) {
                    accessForobj.assertAuthorizedToUpdate(Schema.getGlobalDescribe().get('exam__Question_Template__c'), fieldsList);
                    update updatedList;
                    responseMsg = 'success';
                }     
            }
        }
        catch(Exception ex) {
            responseMsg = ex.getMessage();
        }
        return responseMsg;
    }

    @RemoteAction 
    public static string deleteTemplate(Map<string, string> oldTemplateIdwithNewTemplateIdMap) {
        string returnmsg='';
        if (oldTemplateIdwithNewTemplateIdMap != null && oldTemplateIdwithNewTemplateIdMap.size() > 0 
            && oldTemplateIdwithNewTemplateIdMap.values() != null && oldTemplateIdwithNewTemplateIdMap.values().size() > 0) {
            
            Set<string> deleteTemplateIds = new Set<string>();
            
            deleteTemplateIds.addAll(oldTemplateIdwithNewTemplateIdMap.values());
            List<Main_questionaire__c> deleteTempList = new List<Main_questionaire__c>();
            for (string tempId :deleteTemplateIds) {
                Main_questionaire__c temp = new Main_questionaire__c(Id = tempId);
                deleteTempList.add(temp);
            }
            SFDCAccessController accessForSSdelete = ExAMUtilClass.AccessController;
            if (deleteTempList != null && deleteTempList.size() > 0) {
                if(accessForSSdelete.isAuthorizedToDelete(Schema.getGlobalDescribe().get('exam__Main_questionaire__c'))){
                    delete deleteTempList;
                    //returnmsg = 'Assessment Template Deleted Successfully';
                } else{
                    returnmsg = 'You don\'t have access to delete Assessment Template';
                }
            }
        }
        return returnmsg;
    }

    @RemoteAction
    public static string contextQuestionMapFieldsUpdate(List<string> templateIdList, Map<string, string> questionNamewithNewIdMap, Map<string, string> oldtempIdAndnewTempIdMap) {

        string responseMsg = '';
        Set<Id> newTempId = new Set<Id>();
        List<Main_questionaire__c> assTempList = new List<Main_questionaire__c>();
        List<Main_questionaire__c> updateAssTempList = new List<Main_questionaire__c>();

        try{

            if(templateIdList.size() > 0) {
                for(string oldTempId : templateIdList) {
                    if(oldtempIdAndnewTempIdMap.containsKey(oldTempId)) {
                        newTempId.add(oldtempIdAndnewTempIdMap.get(oldTempId));
                    }
                }
            }
            if(newTempId.size() > 0 ) {
                
                SFDCAccessController accessForobj = ExAMUtilClass.AccessController;
                List<string> fieldsList = new List<string>{'ExAM__Context_Questions_Mapping__c'};
                accessForobj.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Main_questionaire__c'), fieldsList);

                assTempList = [SELECT Id, Context_Questions_Mapping__c FROM Main_questionaire__c WHERE Id IN :newTempId];
                
                if(assTempList.size() > 0) {
                    for(Main_questionaire__c assTemp : assTempList) {
                       if(assTemp.Context_Questions_Mapping__c != null && assTemp.Context_Questions_Mapping__c != '') {
                            List<string> contextQuesList = assTemp.Context_Questions_Mapping__c.split(':');
                            List<string> qNameContainContextQues = new List<string>();
                            
                            for(string conQues : contextQuesList) {
                               if(questionNamewithNewIdMap.containsKey(conQues.split('~')[0])) {
                                   qNameContainContextQues.add(questionNamewithNewIdMap.get(conQues.split('~')[0])+'~'+conQues.split('~')[1]);
                               }
                            }
                            Main_questionaire__c atemp = new Main_questionaire__c(Id = assTemp.Id ,Context_Questions_Mapping__c = string.join(qNameContainContextQues,':'));
                            updateAssTempList.add(atemp);
                        }
                    }
                }
                if (updateAssTempList != null && updateAssTempList.size() > 0 ) {
                    accessForobj.assertAuthorizedToUpdate(Schema.getGlobalDescribe().get('exam__Main_questionaire__c'), fieldsList);
                    update updateAssTempList;
                    responseMsg = 'success';
                }
            }
        }
        catch(Exception ex) {
            responseMsg = ex.getMessage();
        }
        return responseMsg;
    }
}