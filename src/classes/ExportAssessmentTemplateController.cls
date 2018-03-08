public with sharing class ExportAssessmentTemplateController {

    public List<Main_questionaire__c> assTempList {get;set;}
    public String assessmentTemplateJSON {get;set;}
    
    public Map<Id,List<Section_Template__c>> assIdAndSecTempMap {get;set;}
    public Map<Id,List<Question_Template__c>> secIdAndQuestempMap {get;set;}
    public Map<Id,List<Answer_Option__c>> quesIdAndAnsOptMap {get;set;}
    public String errorMsg {get;set;}
    public List<errorClass> errorList {get;set;}
    
    public class errorClass {
        public string errorText{get;set;}
        
    }
    public ExportAssessmentTemplateController() {
    
        try{
            errorList = new List<errorClass>();
            String assTempQuery;
            DateTime createdStartDate, createdEndDate;
            assTempList = new List<Main_questionaire__c>();
            assIdAndSecTempMap = new Map<Id,List<Section_Template__c>>();
            secIdAndQuestempMap = new Map<Id,List<Question_Template__c>>();
            quesIdAndAnsOptMap = new Map<Id,List<Answer_Option__c>>();
            
            Id assTempId = ApexPages.currentPage().getParameters().get('asTempId');
            String startCreatedDate = ApexPages.currentPage().getParameters().get('startCreatedDate');
            String endCreatedDate = ApexPages.currentPage().getParameters().get('endCreatedDate');
            
            //Added for context question mapping values change from quesId to quesName
            Map<Id,String> changedContextQuesMap = new Map<Id,String>();
            Map<Id,String> assTempIdAndContextQuesValueMap = new Map<Id,String>();
            Map<Id,Question_Template__c> quesIdAndQuestTempMap;
            Map<string, Schema.SObjectField> assTempFieldsMap = new Map<string, Schema.SObjectField>();
            Map<string, Schema.SObjectField> secTempFieldsMap = new Map<string, Schema.SObjectField>();
            Map<string, Schema.SObjectField> quesTempFieldsMap = new Map<string, Schema.SObjectField>();
            Map<string, Schema.SObjectField> ansOptFieldsMap = new Map<string, Schema.SObjectField>();
            SFDCAccessController accessForobj = ExAMUtilClass.AccessController;
            if (assTempId == null) {
                assessmentTemplateJSON = '';
                
                List<String> fieldsList = new List<String>{'ExAM__PublishPlace__c','ExAM__Template_name__c'};
                accessForobj.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Main_questionaire__c'), fieldsList);
                List<Main_questionaire__c> templateList = [SELECT Id,Name,PublishPlace__c, Template_name__c, CreatedDate
                                          FROM Main_questionaire__c ORDER BY CreatedDate DESC Limit 1000];
                if (templateList != null && templateList.size() > 0) {
                    assessmentTemplateJSON = JSON.serialize(templateList);
                }
            }
            
            if (assTempId != null || startCreatedDate != null || endCreatedDate != null ) {
                
                assTempQuery ='SELECT Id,Name,PublishPlace__c, Template_name__c,Account__c, Description__c, '
                                    +'Assignment_ID_Name__c,Weight_Template__c, Score_By_Section_Weight__c, Template_External_Id__c, '
                                    +'TemplateFlag__c, Available_in_Portal__c,Assessment_Completed_URL__c, '
                                    +'Viewer_Configuration__c, Public_Assessment_Page_Header__c,Public_Assessment_Page_Footer__c, '
                                    +'Show_Notes_Icon__c, Show_Image_Upload_Icon__c, Show_Refresh_Icon__c, URL__c, Modal_Window_Text__c,'
                                    +'Show_Modal_Window__c, Decision_Tree__c,Google_Analytics_Script__c,'
                                    +'Show_Question_Number__c,Static_Resource_Name__c,Public_Assessment_Viewer_Tab_Icon__c,'
                                    +'Hide_Section_Titles__c,SRFile_Path__c,Public_Assessment_Single_Question_Mode__c,Context_Questions_Mapping__c,'
                                    +'Enable_Survey_Overlay__c,Generate_Case_Or_Lead__c,One_Time_Assessment__c,Template_Group__c,'
                                    +'Survey_Overlay_button_Text__c,Survey_Overlay_Header_Text__c,Survey_Overlay_Text__c,Watchlist_Of_Words__c,'
                                    +'Web_Intercept_Header__c,Web_Intercept_PA_Resource_File_Path__c,isArchive__c,Public_Assessment_Viewer_Title__c,'
                                    +'Web_Intercept_PA_Static_Resource_Name__c,Web_Intercept_Static_Resource_Name__c,Web_Intercept_File_Path__c,'
                                    +'Render_Next_Question_Automatically__c,Result_Question_Button_Text__c,Enable_Survey_Intro_Text__c,'
                                    +'PA_Header_and_Button_Background_Color__c,PA_Header_and_Button_Text_Color__c,PA_Template_Heading_Text__c,'
                                    +'Web_Intercept_Header_color__c,Auto_Submit__c,Execute_Field_Mapping_On_AM__c,Enable_Section_Description__c'
                                    +' FROM Main_questionaire__c';
                if( startCreatedDate != null && startCreatedDate != '' && startCreatedDate.split('/').size() == 3){
                    String[] dateStr = startCreatedDate.split('/');
                    createdStartDate = dateTime.newinstance( Integer.valueOf(dateStr[2]), Integer.valueOf(dateStr[0]), Integer.valueOf(dateStr[1]) );
                } 
                
                if( endCreatedDate != null && endCreatedDate != '' && endCreatedDate.split('/').size() == 3 ){
                    String[] dateStr2 = endCreatedDate.split('/');
                    createdEndDate = date.newinstance( Integer.valueOf(dateStr2[2]), Integer.valueOf(dateStr2[0]), Integer.valueOf(dateStr2[1]) );
                    createdEndDate = createdEndDate.addDays(1);
                } 
                
                if(createdStartDate != null && createdEndDate != null) {
                    assTempQuery +=' WHERE CreatedDate >= :createdStartDate  AND CreatedDate <= :createdEndDate'; 
                } else if(assTempId != null) {
                    assTempQuery +=' WHERE Id = :assTempId';
                }
                
                List<String> fieldsList1 = new List<String>{'ExAM__PublishPlace__c','ExAM__Template_name__c','ExAM__Account__c', 'ExAM__Description__c','ExAM__Assignment_ID_Name__c','ExAM__Public_Assessment_Viewer_Title__c',
                                                    'ExAM__Weight_Template__c','ExAM__Score_By_Section_Weight__c','ExAM__Template_External_Id__c','ExAM__TemplateFlag__c','ExAM__Available_in_Portal__c','ExAM__Assessment_Completed_URL__c',
                                                    'ExAM__Viewer_Configuration__c','ExAM__Public_Assessment_Page_Header__c','ExAM__Public_Assessment_Page_Footer__c','ExAM__Show_Notes_Icon__c','ExAM__Show_Image_Upload_Icon__c','ExAM__Template_Group__c',
                                                    'ExAM__Show_Refresh_Icon__c','ExAM__URL__c','ExAM__Modal_Window_Text__c','ExAM__Show_Modal_Window__c','ExAM__Decision_Tree__c','ExAM__Google_Analytics_Script__c','ExAM__Public_Assessment_Viewer_Tab_Icon__c',
                                                    'ExAM__Show_Question_Number__c','ExAM__Static_Resource_Name__c','ExAM__Hide_Section_Titles__c','ExAM__SRFile_Path__c','ExAM__Public_Assessment_Single_Question_Mode__c','ExAM__Context_Questions_Mapping__c',
                                                    'ExAM__Enable_Survey_Overlay__c','ExAM__Generate_Case_Or_Lead__c','ExAM__One_Time_Assessment__c','ExAM__Survey_Overlay_button_Text__c','ExAM__Survey_Overlay_Header_Text__c','ExAM__Survey_Overlay_Text__c',
                                                    'ExAM__Watchlist_Of_Words__c','ExAM__Web_Intercept_Header__c','ExAM__Web_Intercept_PA_Resource_File_Path__c','ExAM__Web_Intercept_PA_Static_Resource_Name__c','ExAM__Web_Intercept_Static_Resource_Name__c',
                                                    'ExAM__Web_Intercept_File_Path__c','ExAM__Render_Next_Question_Automatically__c','ExAM__Result_Question_Button_Text__c','ExAM__Enable_Section_Description__c','ExAM__Enable_Survey_Intro_Text__c','ExAM__isArchive__c',
                                                    'ExAM__PA_Header_and_Button_Background_Color__c','ExAM__PA_Header_and_Button_Text_Color__c','ExAM__PA_Template_Heading_Text__c','ExAM__Web_Intercept_Header_color__c','ExAM__Auto_Submit__c','ExAM__Execute_Field_Mapping_On_AM__c'};
                accessForobj.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Main_questionaire__c'), fieldsList1);
                assTempList = database.query(assTempQuery);
                
                
                if(assTempList != null && assTempList.size() > 0) {
                    assTempFieldsMap = ExAMUtilClass.getSObjectFieldsMap('ExAM__Main_questionaire__c');
                    secTempFieldsMap = ExAMUtilClass.getSObjectFieldsMap('ExAM__Section_Template__c');
                    quesTempFieldsMap = ExAMUtilClass.getSObjectFieldsMap('ExAM__Question_Template__c');
                    ansOptFieldsMap = ExAMUtilClass.getSObjectFieldsMap('ExAM__Answer_Option__c');
                    for (Main_questionaire__c assTemp : assTempList) {
                        for (Schema.SObjectField eachATfield : assTempFieldsMap.Values()) {
                            Schema.DescribeFieldResult dfr = eachATfield.getDescribe();
                            if ( dfr.isCustom() && !dfr.isAutoNumber() && ( (dfr.getType() == Schema.DisplayType.STRING) || (dfr.getType() == Schema.DisplayType.TEXTAREA) ) ) {
                                try {
                                    if( assTemp.get(eachATfield) != null && assTemp.get(eachATfield) != '' ){
                                        String assTempField = String.valueOf(assTemp.get(eachATfield));
                                        assTemp.put(eachATfield, assTempField.replaceAll('\\<.*?\\>',''));
                                    }
                                } catch ( Exception e ){
                                    continue;
                                }
                            }
                        }
                        if(assTemp.Context_Questions_Mapping__c != null && assTemp.Context_Questions_Mapping__c != '') {
                            if(!assTempIdAndContextQuesValueMap.containsKey(assTemp.Id)) {
                                assTempIdAndContextQuesValueMap.put(assTemp.Id,assTemp.Context_Questions_Mapping__c);
                            }
                        }
                        assIdAndSecTempMap.put(assTemp.Id,new List<Section_Template__c>());
                    }    
                     
                     List<String> fieldsList2 = new List<String>{'ExAM__Questionnaire_Section__c','ExAM__Order_No__c','ExAM__Section_Description__c','ExAM__Section_label__c','ExAM__Subsectionlabel__c','ExAM__isArchive__c',
                                             'ExAM__SuperSection__c','ExAM__status__c','ExAM__No_of_Questions_Section__c','ExAM__No_of_response_per_section_per_user__c','ExAM__Section_Weight__c','ExAM__Section_External_Id__c',
                                             'ExAM__Random_Display_Count__c'};
                     accessForobj.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Section_Template__c'), fieldsList2);
                     for(Section_Template__c sec : [SELECT Id,Name, Questionnaire_Section__c,Order_No__c, Section_Description__c, Section_label__c, Subsectionlabel__c,
                                                  SuperSection__c, status__c,isArchive__c, No_of_Questions_Section__c, No_of_response_per_section_per_user__c, Section_Weight__c, 
                                                  Section_External_Id__c, Random_Display_Count__c
                                                    FROM Section_Template__c WHERE Questionnaire_Section__c = :assIdAndSecTempMap.Keyset()]) {
                        for (Schema.SObjectField eachSecfield : secTempFieldsMap.Values()) {
                            Schema.DescribeFieldResult dfr = eachSecfield.getDescribe();
                            if ( dfr.isCustom() && !dfr.isAutoNumber() && ( (dfr.getType() == Schema.DisplayType.STRING) || (dfr.getType() == Schema.DisplayType.TEXTAREA) ) ) {
                                try {
                                    if( sec.get(eachSecfield) != null && sec.get(eachSecfield) != '' ){
                                        String secTempField = String.valueOf(sec.get(eachSecfield));
                                        sec.put(eachSecfield, secTempField.replaceAll('\\<.*?\\>',''));
                                    }
                                } catch ( Exception e ){
                                    continue;
                                }
                            }
                        }
                        if(assIdAndSecTempMap.containsKey(sec.Questionnaire_Section__c)) {
                            assIdAndSecTempMap.get(sec.Questionnaire_Section__c).add(sec);
                        }
                        secIdAndQuestempMap.put(sec.Id,new List<Question_Template__c>());
                     }
                    
                     List<String> fieldsList4 = new List<String>{'ExAM__Help_Text__c','ExAM__Weight__c', 'ExAM__Dependent_Question__c', 'ExAM__Next_Question__c','ExAM__Order_No__c'};
                     accessForobj.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Answer_Option__c'), fieldsList4);
                    
                     List<String> fieldsList3 = new List<String>{'ExAM__Section_Question__c', 'ExAM__Question_Label__c','ExAM__Subquestion_Label__c','ExAM__Weight_of_Answer__c',
                                             'ExAM__Count_of_Responses__c','ExAM__Count_Questions__c' ,'ExAM__Do_Not_Create_Answer__c','ExAM__Focus_category__c',
                                             'ExAM__HelpText__c','ExAM__Is_Mandatory__c','ExAM__Next_Question__c','ExAM__Question_Order_No__c','ExAM__Question_Type__c',
                                             'ExAM__SubSection_label__c','ExAM__Weight_Of_Question__c','ExAM__Question_External_Id__c','ExAM__Decision_Tree__c',
                                             'ExAM__Field_Length__c','ExAM__Has_Picture__c','ExAM__Is_Dependent__c','ExAM__Knowledge_Article_Link__c','ExAM__Question_Restricted_Length__c',
                                             'ExAM__Dependent_Question__c','ExAM__Video_URL__c','ExAM__Default_Value__c',
                                             'ExAM__Disabled__c','ExAM__Question_Short_Name__c','ExAM__Single_Next_Question__c'};
                     accessForobj.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Question_Template__c'), fieldsList3);
                    
                     quesIdAndQuestTempMap = new Map<Id,Question_Template__c>([SELECT Id,Name,Subquestion_Label__c,Weight_of_Answer__c,Question_Type__c,
                                    Count_of_Responses__c,Count_Questions__c ,Do_Not_Create_Answer__c,Focus_category__c,HelpText__c,Is_Mandatory__c,
                                    Next_Question__c,Question_Label__c,Question_Order_No__c,SubSection_label__c,Weight_Of_Question__c,Section_Question__c,
                                    Question_External_Id__c, Decision_Tree__c,Field_Length__c,Has_Picture__c,Is_Dependent__c,Knowledge_Article_Link__c,
                                    Dependent_Question__c,Video_URL__c,Default_Value__c,Question_Restricted_Length__c,
                                    Disabled__c, Question_Short_Name__c, Single_Next_Question__c, Single_Next_Question__r.Name,
                                    (SELECT Id,Name,Help_Text__c,Weight__c,Dependent_Question__r.Name,Next_Question__r.Name,Question_Template__r.Name,Order_No__c FROM ExAM__Answer_Options__r)
                                    FROM Question_Template__c WHERE Section_Question__c = :secIdAndQuestempMap.Keyset()]);
                    
                     for(Question_Template__c ques : quesIdAndQuestTempMap.values()) { 
                        for (Schema.SObjectField eachQuesfield : quesTempFieldsMap.Values()) {
                            Schema.DescribeFieldResult dfr = eachQuesfield.getDescribe();
                            if ( dfr.isCustom() && !dfr.isAutoNumber() && ( (dfr.getType() == Schema.DisplayType.STRING) || (dfr.getType() == Schema.DisplayType.TEXTAREA) ) ) {
                                try {
                                    if( ques.get(eachQuesfield) != null && ques.get(eachQuesfield) != '' ){
                                        String quesTempField = String.valueOf(ques.get(eachQuesfield));
                                        ques.put(eachQuesfield, quesTempField.replaceAll('\\<.*?\\>',''));
                                    }
                                } catch ( Exception e ){
                                    continue;
                                }
                            }
                        }
                        if(secIdAndQuestempMap.containsKey(ques.Section_Question__c))  {
                            List<Answer_Option__c> ansOptList = new List<Answer_Option__c>();
                            for( Answer_Option__c ansOpt :ques.ExAM__Answer_Options__r ){
                                
                                // This for loop is used to replace special characters in all fields of Answer option object
                                for (Schema.SObjectField eachAnsOptfield : ansOptFieldsMap.Values()) {
                                    Schema.DescribeFieldResult dfr = eachAnsOptfield.getDescribe();
                                    //here isCustom does not checked, because Answer options have stored in Standard Name field
                                    if ( !dfr.isAutoNumber() && ( (dfr.getType() == Schema.DisplayType.STRING) || (dfr.getType() == Schema.DisplayType.TEXTAREA) ) ) {
                                        try {
                                            if( ansOpt.get(eachAnsOptfield) != null && ansOpt.get(eachAnsOptfield) != '' ){
                                                String ansOptField = String.valueOf(ansOpt.get(eachAnsOptfield));
                                                ansOpt.put(eachAnsOptfield, ansOptField.replaceAll('\\<.*?\\>',''));
                                            }
                                        } catch ( Exception e ){
                                            continue;
                                        }
                                    }
                                }
                                ansOptList.add(ansOpt);
                            }
                            quesIdAndAnsOptMap.put(ques.Id,ansOptList);
                            secIdAndQuestempMap.get(ques.Section_Question__c).add(ques);
                        }
                     }
                    
                    
                    if(assTempIdAndContextQuesValueMap.size() > 0) {
                       for(Id assessmentTempId : assTempIdAndContextQuesValueMap.keySet()) {
                           String contextQues = assTempIdAndContextQuesValueMap.get(assessmentTempId);
                           List<String> contextQuesList = contextQues.split(':');
                           List<String> qNameContainContextQues = new List<String>();
                           
                           for(String conQues : contextQuesList) {
                               if(quesIdAndQuestTempMap.containsKey(conQues.split('~')[0])) {
                                   qNameContainContextQues.add(quesIdAndQuestTempMap.get(conQues.split('~')[0]).Name+'~'+conQues.split('~')[1]);
                               }
                           }
                           changedContextQuesMap.put(assessmentTempId,String.join(qNameContainContextQues,':'));
                       }   
                   } 
                   for (Integer i= 0; i<assTempList.size();i++) {
                       if(changedContextQuesMap.containsKey(assTempList[i].Id)) {
                           assTempList[i].Context_Questions_Mapping__c = changedContextQuesMap.get(assTempList[i].Id);
                       }
                   }
                }
            }
        }catch(Exception ex){
            errorClass e = new errorClass();
            e.errorText = ex.getMessage();
            errorList.add(e);
        }
    }
}