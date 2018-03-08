global class CommonViewerController {

    public static Boolean hasAssessableObj { get; set; }
    
    public CommonViewerController() {
        hasAssessableObj = false;
    }

    @RemoteAction
    global static string returnSectionAndQuestionTemplate(ReturnViewerRecordsParamClass returnViewerRec) {
        String assessmentTemplateId = '';
        String createdASMId = '';
        String viewerName = '';
        String assObjId = '';
        
        Set<String> questionTemplateNameSet = new Set<String>();
        Set<Id> ansQuesTempId = new Set<Id>();
        Set<Id> quesTempIdSet = new Set<Id>();
        Set<Id> pictureQuestionIdSet = new Set<Id>();
        Set<Id> imagesInQuesSet = new Set<Id>();
        
        List<Questionnaire_Response__c> responseList = new List<Questionnaire_Response__c>();       
        List<IssueRequest_Life_Cycle__c> assignmentManagerList = new List<IssueRequest_Life_Cycle__c>();        
        List<AnswerRecordClass> ansRecList = new List<AnswerRecordClass>(); 
        List<Main_questionaire__c> templateList = new List<Main_questionaire__c>();
        List<SectionAndQuestionTemplateClass> secAnsQuesTemArrClassList = new List<SectionAndQuestionTemplateClass>();
        
        Map<Id,Id> quesIdANDAnsIdMap = new Map<Id,Id>(); 
        Map<Id,Answer_Option__c> ansOptIdWithanswerMap = new Map<Id,Answer_Option__c>();
        Map<Id,Integer> templateIdAndResponsesCountMap = new Map<Id, Integer>();
        Map<String,Question_Template__c> quesNameWithQuesMap = new Map<String,Question_Template__c>();
        Map<Id,Question_Template__c> quesIdWithQuesMap = new Map<Id,Question_Template__c>();
        Map<Id,Section_Template__c> sectionTemplateMap = new Map<Id, Section_Template__c>();
        Map<Id,List<Question_Template__c>> sectionTemplateIdAndQuestionTemplateListMap = new Map<Id, List<Question_Template__c>>();
        Map<Id,List<Attachment>> parentIdwithArrayOfAttachmentIdMap = new Map<Id,List<Attachment>>();
        Map<String,Question_Template__c> dependentQuesNamewithQuesTempMap = new Map<String,Question_Template__c>();
        Map<Id,Question_Template__c> resultQuesIdwithQuesTemp = new Map<Id,Question_Template__c>();
        Map<Id,Map<String,String>> resultQuestionIdDefaultValueMap = new Map<Id,Map<String,String>>();
        Map<Id,List<Id>> quesIdAndAnsweredAttIdMap = new Map<Id,List<Id>>();
        DecisionTreeClass DTConfiguration = new DecisionTreeClass();
        ViewerRecordsClass viewerRec = new ViewerRecordsClass();
        
        SFDCAccessController accessQR = ExAMUtilClass.AccessController;
        
        if(returnViewerRec != null) {
            if(returnViewerRec.assessmentTemplateId != null && returnViewerRec.assessmentTemplateId != '') {
                assessmentTemplateId = returnViewerRec.assessmentTemplateId ;
            }
            if(returnViewerRec.createdASMId != null && returnViewerRec.createdASMId != '') {
                createdASMId = returnViewerRec.createdASMId;
            }
            if(returnViewerRec.viewerName != null && returnViewerRec.viewerName != '') {
                viewerName = returnViewerRec.viewerName;
            }
        }
        try {
            if((string.isNotBlank(createdASMId) && (viewerName == 'lens'||viewerName == 'standard')) || viewerName == 'public')  {
                
                if(viewerName == 'lens'||viewerName == 'standard') {
                    List<String> fieldsListQT = new List<String>{'ExAM__Question_Type__c', 'ExAM__Do_Not_Create_Answer__c', 'ExAM__Dependent_Question__c', 'ExAM__HelpText__c', 'ExAM__Default_Value__c',
                                                                'ExAM__Is_Dependent__c', 'ExAM__Is_Mandatory__c', 'ExAM__Next_Question__c', 'ExAM__Question_Label__c', 'ExAM__Question_Order_No__c', 'ExAM__Disabled__c',
                                                                'ExAM__Section_Question__c', 'ExAM__SubSection_label__c', 'ExAM__Video_URL__c', 'ExAM__Subquestion_Label__c', 'ExAM__Weight_Of_Question__c',
                                                                'ExAM__Knowledge_Article_Link__c', 'ExAM__Has_Picture__c', 'ExAM__Field_Length__c', 'ExAM__Hotspot_Image_Properties__c','ExAM__Single_Next_Question__c'};
                    accessQR.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Question_Template__c'), fieldsListQT);
                    
                    List<String> fieldsListQR = new List<String>{'ExAM__Decision_Tree_Launched_Question__c', 'ExAM__Question_Template__c', 'ExAM__Response__c', 'ExAM__Issue_Request__c'};
                    accessQR.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Questionnaire_Response__c'), fieldsListQR);
                
                    List<String> fieldsListAT = new List<String>{'ExAM__One_Time_Assessment__c', 'ExAM__Show_Question_Number__c', 'ExAM__Show_Image_Upload_Icon__c', 
                                                            'ExAM__Show_Notes_Icon__c', 'ExAM__Show_Refresh_Icon__c', 'ExAM__Context_Questions_Mapping__c'};
                    accessQR.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Main_questionaire__c'), fieldsListAT);
                    
                    List<String> fieldsListAM = new List<String>{'ExAM__InvestigationType__c', 'ExAM__Status__c','ExAM__Field_Start_Time__c'};
                    accessQR.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__IssueRequest_Life_Cycle__c'), fieldsListAM);
    
                    List<String> fieldsListEC = new List<String>{'ExAM__Overall_Status_on_Submit__c'};
                    accessQR.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__ExAM_Configuration__c'), fieldsListEC);
                    
                    List<String> fieldsListAnsOpt = new List<String>{'ExAM__Help_Text__c', 'ExAM__Weight__c', 'ExAM__Order_No__c','ExAM__Dependent_Question__c','ExAM__Next_Question__c'};
                    accessQR.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Answer_Option__c'), fieldsListAnsOpt);
                    
                    List<String> fieldsListAMUpdate = new List<String>{'ExAM__Field_Start_Time__c'};
                    accessQR.assertAuthorizedToUpdate(Schema.getGlobalDescribe().get('exam__IssueRequest_Life_Cycle__c'), fieldsListAMUpdate);
                
                }
                if( assessmentTemplateId != '') {
                    templateList = [
                        SELECT Id, Name, Show_Image_Upload_Icon__c, Show_Notes_Icon__c, 
                               Show_Question_Number__c, Show_Refresh_Icon__c,
                               Context_Questions_Mapping__c, One_Time_Assessment__c,
                               Auto_Submit__c,Modal_Window_Text__c,Show_Modal_Window__c
                        FROM   Main_questionaire__c
                        WHERE  Id = :assessmentTemplateId LIMIT 1
                    ]; 
                }
                if( createdASMId != '' )  {
                    
                    Map<string,string> assignmentManagerFieldAnswerFieldMap = new Map<string,string>();
                    
                    if( viewerName != 'public' || ( viewerName == 'public' && !templateList[0].Auto_Submit__c ) ) {
                        for(Questionnaire_Response__c ansObj : [SELECT Decision_Tree_Launched_Question__c, Id, Name,
                                                                       Question_Template__c, Response__c,
                                                                       Question_Template__r.Question_Type__c,
                                                                       Question_Template__r.Subquestion_Label__c,
                                                                       Question_Template__r.Name
                                                                FROM   Questionnaire_Response__c
                                                                WHERE  Issue_Request__c = :createdASMId ORDER BY LastModifiedDate DESC]) {
        
                            
                            responseList.add(ansObj);
                            if(viewerName == 'lens') {
                                ansQuesTempId.add(ansObj.Question_Template__c);                     
                                if (ansObj.Decision_Tree_Launched_Question__c != null) {
                                    if ( !templateIdAndResponsesCountMap.containsKey(ansObj.Decision_Tree_Launched_Question__c) ) {
                                        templateIdAndResponsesCountMap.put(ansObj.Decision_Tree_Launched_Question__c, 0);
                                    }
                                    Integer responseCount = templateIdAndResponsesCountMap.get(ansObj.Decision_Tree_Launched_Question__c);
                                    responseCount++;
                                    templateIdAndResponsesCountMap.put(ansObj.Decision_Tree_Launched_Question__c, responseCount);
                                }
                                if(templateIdAndResponsesCountMap.size() > 0) {
                                     viewerRec.quesIdAndResponseCount = templateIdAndResponsesCountMap;
                                }
                            }
                        }  
                    }
                    ExAMUtilClass.AssessableObjectDetails objectDetailsANS = ExAMUtilClass.getAssessableObjectDetails('ExAM__IssueRequest_Life_Cycle__c');
                    if (objectDetailsANS != null && objectDetailsANS.assessableObjectAPIMap != null && objectDetailsANS.assessableObjectAPIMap.size() > 0) {
                        assignmentManagerFieldAnswerFieldMap = objectDetailsANS.assessableObjectAPIMap;
                    }
                    
                    String amQuery = 'SELECT Id, ExAM__Status__c, ExAM__InvestigationType__c, Name, ExAM__InvestigationType__r.ExAM__One_Time_Assessment__c';
                    
                    for (string assessableFieldapi : assignmentManagerFieldAnswerFieldMap.keySet()) { 
                        amQuery += ' ,'+assessableFieldapi;
                    }
                    amQuery += ' FROM ExAM__IssueRequest_Life_Cycle__c WHERE Id = :createdASMId LIMIT 1';
                    assignmentManagerList = Database.Query(amQuery);
                    
                    List<ExAM_Configuration__c> configList = [SELECT Overall_Status_on_Submit__c, Id FROM ExAM_Configuration__c WHERE Overall_Status_on_Submit__c != null ORDER BY CreatedDate DESC LIMIT 1];
                    ExAMUtilClass.AssessableObjectInAMClass assessableObjectDetailsFrmAM = ExAMUtilClass.getAssessableObjectDetailsFromAM( assignmentManagerList );
                    for (string amId : assessableObjectDetailsFrmAM.managerIdWithAssessableObjectIdMap.keySet()) {
                        assObjId = assessableObjectDetailsFrmAM.managerIdWithAssessableObjectIdMap.get(amId);
                        viewerRec.assObjId = assObjId;
                    }
                }
            }
            DTConfiguration = constructDecisionTreeResultQuestion(new ConstructDTResultQuestionParamClass(assessmentTemplateId,viewerName));
            if( DTConfiguration != null ) {
                viewerRec.DTConfiguration = DTConfiguration;
            }
            
            if(templateList.size() > 0) {
                viewerRec.assessmentTemplateRecord = templateList[0];
                sectionTemplateMap = new Map<Id, Section_Template__c>(
                    [
                        SELECT Id, Name, No_of_Questions_Section__c, No_of_response_per_section_per_user__c, Order_No__c,
                               Questionnaire_Section__c, Section_Description__c, Section_label__c, Section_Weight__c,
                               Status__c, Subsectionlabel__c, SuperSection__c, Random_Display_Count__c
                        FROM   Section_Template__c
                        WHERE  Questionnaire_Section__c = :assessmentTemplateId ORDER BY Order_No__c ASC
                    ]
                );
                if(sectionTemplateMap.size() > 0) {
                    sectionTemplateIdAndQuestionTemplateListMap = new Map<Id, List<Question_Template__c>>();
                    for(Question_Template__c qt : [SELECT Id,Do_Not_Create_Answer__c, Dependent_Question__c, HelpText__c,Default_Value__c,
                                                          Is_Dependent__c, Is_Mandatory__c, Name, Next_Question__c, Single_Next_Question__c, Single_Next_Question__r.Name,
                                                          Question_Label__c, Question_Order_No__c, Question_Type__c, Disabled__c, Decision_Tree__c,
                                                          Subquestion_Label__c, Section_Question__c, SubSection_label__c, Video_URL__c,
                                                          Weight_Of_Question__c, Knowledge_Article_Link__c, Has_Picture__c,Field_Length__c,Hotspot_Image_Properties__c,
                                                          (SELECT Id,Name,Order_No__c,Question_Template__c,Help_Text__c,Weight__c,Dependent_Question__r.Name,Next_Question__r.Name FROM Answer_Options__r ORDER BY Order_No__c ASC)
                                                   FROM   Question_Template__c
                                                   WHERE  Section_Question__c IN :sectionTemplateMap.keySet() ORDER BY Question_Order_No__c ASC NULLS LAST]) {
                        if(!qt.Disabled__c) {
                            quesIdWithQuesMap.put(qt.Id,qt);
                            if( qt.Question_Type__c == 'Hidden') {
                                //quesIdWithHiddenResMap.put(qt.Id,qt.Default_Value__c);
                            } else {
                                quesNameWithQuesMap.put(qt.Name,qt);
                                if(qt.Is_Dependent__c) {
                                    dependentQuesNamewithQuesTempMap.put(qt.Name,qt);
                                }
                                if(qt.Question_Type__c == 'Result') {
                                    resultQuesIdwithQuesTemp.put(qt.Id,qt);
                                    Map<String,String> answerFieldApiNamewithValueMap = new Map<String,String>();
                                    if (qt.Answer_Options__r.size()== 0 && qt.Subquestion_Label__c != null && qt.Subquestion_Label__c != '') {
                                        answerFieldApiNamewithValueMap.put('ExAM__Response__c',qt.Subquestion_Label__c);
                                    } else {
                                        if(qt.Answer_Options__r.size() > 0) {
                                            answerFieldApiNamewithValueMap.put('ExAM__Response__c',qt.Answer_Options__r[0].Name);
                                        }
                                    }
                                    if (DTConfiguration.decisionTreeResultList != null && qt.Decision_Tree__c != null && qt.Decision_Tree__c != '') {
                                        List<String> answerFieldApiNameWithDefaultValueList = qt.Decision_Tree__c.split('~');
                                        for(DecisionTreeResultClass DTResult : DTConfiguration.decisionTreeResultList) {
                                            if(DTResult.hasEnabled) {
                                                Integer b = 0;
                                                while(b < answerFieldApiNameWithDefaultValueList.size()) {
                                                    if(DTResult.fieldAPIName.toLowerCase() == answerFieldApiNameWithDefaultValueList[b].split(':')[0].toLowerCase()) {
                                                        answerFieldApiNamewithValueMap.put(DTResult.fieldAPIName,answerFieldApiNameWithDefaultValueList[b].split(':')[1]);
                                                        answerFieldApiNameWithDefaultValueList.remove(b);
                                                        break;
                                                    } else {
                                                        b++;
                                                    }
                                                }
                                            }
                                        }
                                        if(!resultQuestionIdDefaultValueMap.containsKey(qt.Id)) {
                                            resultQuestionIdDefaultValueMap.put(qt.Id,answerFieldApiNamewithValueMap);
                                        }
                                    }
                                }
                                if (!sectionTemplateIdAndQuestionTemplateListMap.containsKey(qt.Section_Question__c)) {
                                    sectionTemplateIdAndQuestionTemplateListMap.put(qt.Section_Question__c, new List<Question_Template__c>());
                                }
                                sectionTemplateIdAndQuestionTemplateListMap.get(qt.Section_Question__c).add( qt );
                                //Adding question image attachment and image question type attachement
                                if (qt.Has_Picture__c || qt.Question_Type__c == 'Image') {
                                    if(qt.Question_Type__c == 'Image' && 
                                        qt.Answer_Options__r.size() == 0 ) {
                                        imagesInQuesSet.add(qt.Id);
                                        pictureQuestionIdSet.add(qt.Id);
                                    } else if(qt.Question_Type__c == 'Image' && 
                                              qt.Answer_Options__r.size() > 0 ) { 
                                        for( Answer_Option__c ansOption : qt.Answer_Options__r ){
                                            ansOptIdWithanswerMap.put(ansOption.Id,ansOption);
                                            pictureQuestionIdSet.add(ansOption.Id);
                                        }
                                    } 
                                    pictureQuestionIdSet.add(qt.Id);
                                }
                            }
                        } 
                        
                        if( qt.Single_Next_Question__c != null && qt.Single_Next_Question__r.Name != '' ){
                            questionTemplateNameSet.add(qt.Single_Next_Question__r.Name);
                        } else {
                            if ( qt.Answer_Options__r.size() == 0 && (String.isNotBlank(qt.Next_Question__c) || String.isNotBlank(qt.Dependent_Question__c) )){
                                if(String.isNotBlank(qt.Dependent_Question__c)) {   
                                    if (qt.Dependent_Question__c.contains('~')) {
                                        questionTemplateNameSet.addAll( trimAnswerOption(qt.Dependent_Question__c) );
                                    }
                                    else {
                                        questionTemplateNameSet.add( qt.Dependent_Question__c.trim() );
                                    }
                                } else {
                                    if (qt.Next_Question__c.contains('~')) {
                                        questionTemplateNameSet.addAll( trimAnswerOption(qt.Next_Question__c) );
                                    }
                                    else {
                                        questionTemplateNameSet.add( qt.Next_Question__c.trim() );
                                    }
                                }
                            } else {                            
                                for( Answer_Option__c ansOpt :qt.Answer_Options__r ){
                                    if( ansOpt.Next_Question__r.Name != null && ansOpt.Next_Question__r.Name != '' ){
                                        questionTemplateNameSet.add(ansOpt.Next_Question__r.Name);
                                    } else if( ansOpt.Dependent_Question__r.Name != null && ansOpt.Dependent_Question__r.Name != '' ){
                                        questionTemplateNameSet.add(ansOpt.Dependent_Question__r.Name);
                                    }
                                }
                            }
                        }
                    }
                }   
                if(quesNameWithQuesMap.size() > 0 ) {
                    viewerRec.questionNamewithQuestionTemplate = quesNameWithQuesMap;
                }
                if(quesIdWithQuesMap.size() > 0 ) {
                    viewerRec.quesIdWithQuestionTemplate = quesIdWithQuesMap;
                }
                if(resultQuesIdwithQuesTemp.size() > 0) {
                    viewerRec.resultQuestionNamewithQuestionTemplate = resultQuesIdwithQuesTemp;
                }
                if(resultQuestionIdDefaultValueMap.size() > 0) {
                    viewerRec.resultQuestionIdDefaultValueObj = resultQuestionIdDefaultValueMap;
                }
                if(dependentQuesNamewithQuesTempMap.size() > 0) {
                    viewerRec.dependentQuestionNamewithQuestionTemplate = dependentQuesNamewithQuesTempMap;
                }
                Map<Id,Map<String,Attachment>> quesIdAndAttachmentArr = new Map<Id,Map<String,Attachment>>();
                if(pictureQuestionIdSet.size() > 0) {
                    for (Attachment att:[SELECT Id, Name, ParentId, ContentType FROM Attachment WHERE ParentId IN:pictureQuestionIdSet AND ContentType Like 'image%']) {
                        if(imagesInQuesSet.contains(att.ParentId)) {
                            if(!quesIdAndAttachmentArr.containsKey(att.ParentId)) {
                                quesIdAndAttachmentArr.put(att.ParentId,new Map<String,Attachment>());
                            }
                            Map<String,Attachment> tempMap = quesIdAndAttachmentArr.get(att.ParentId);
                            tempMap.put(att.Name,att);
                            quesIdAndAttachmentArr.put(att.ParentId,tempMap);
                        } else {
                            String parentId = att.ParentId;
                            if(ansOptIdWithanswerMap.containsKey(parentId)) {
                                String ansParentId = ansOptIdWithanswerMap.get(parentId).Question_Template__c;
                                if(!quesIdAndAttachmentArr.containsKey(ansParentId)) {
                                    quesIdAndAttachmentArr.put(ansParentId,new Map<String,Attachment>());
                                }
                                Map<String,Attachment> tempMap= quesIdAndAttachmentArr.get(ansParentId);
                                tempMap.put(String.valueOf(ansOptIdWithanswerMap.get(parentId).Order_No__c),att);
                                quesIdAndAttachmentArr.put(parentId,tempMap);
                            } else {
                                if(!quesIdAndAttachmentArr.containsKey(att.ParentId)) {
                                    quesIdAndAttachmentArr.put(att.ParentId,new Map<String,Attachment>());
                                }
                                Map<String,Attachment> tempMap= quesIdAndAttachmentArr.get(att.ParentId);
                                tempMap.put(att.Name,att);
                                quesIdAndAttachmentArr.put(att.ParentId,tempMap);
                            }
                        }
                    }
                    if(quesIdAndAttachmentArr.size() > 0) {
                        for( String qId: quesIdAndAttachmentArr.keySet()) {
                            Map<String,Attachment> temMap = quesIdAndAttachmentArr.get(qId);
                            List<String> orderedList = new List<String>();
                            orderedList.addAll(temMap.keySet());
                            orderedList.sort();
                            if(orderedList.size() > 0 ) {
                                for(String str : orderedList) {
                                    if(!parentIdwithArrayOfAttachmentIdMap.containskey(qId) ) {
                                        parentIdwithArrayOfAttachmentIdMap.put(qId, new List<Attachment>());
                                    }
                                    parentIdwithArrayOfAttachmentIdMap.get(qId).add(temMap.get(str));
                                }
                            }
                        }
                    }
                    if( parentIdwithArrayOfAttachmentIdMap.size() > 0 ) {
                        viewerRec.parentIdAndArrayOfPictureIdMap = parentIdwithArrayOfAttachmentIdMap;
                    }
                }
                if(sectionTemplateIdAndQuestionTemplateListMap.size() > 0) {
                    for(Section_Template__c sectionTemplateRecord : sectionTemplateMap.values()) {
                        List<Question_Template__c> primaryQuesList = new List<Question_Template__c>();
                        List<Question_Template__c> caseQuesList = new List<Question_Template__c>();
                        if(sectionTemplateIdAndQuestionTemplateListMap.containsKey(sectionTemplateRecord.Id) &&
                            sectionTemplateIdAndQuestionTemplateListMap.get( sectionTemplateRecord.Id ).size() > 0
                        ) {
        
                            for(Question_Template__c questionTemplateRecord : sectionTemplateIdAndQuestionTemplateListMap.get(sectionTemplateRecord.Id) ) {
        
                                if (questionTemplateRecord.Question_Type__c != 'Result' 
                                    && ((questionTemplateNameSet.size() == 0)
                                        || (questionTemplateNameSet.size() > 0 
                                        && !questionTemplateNameSet.contains( questionTemplateRecord.Name )))
                                ) {
                                    if( questionTemplateRecord.Question_Type__c != 'Case' ){
                                        primaryQuesList.add(questionTemplateRecord);
                                    } else {
                                        caseQuesList.add(questionTemplateRecord);
                                    }
                                }
                            }
                            
                            if( viewerName != 'standard' && sectionTemplateRecord.Random_Display_Count__c != null && sectionTemplateRecord.Random_Display_Count__c > 0 && primaryQuesList.size() > 0 && sectionTemplateRecord.Random_Display_Count__c <= primaryQuesList.size() ){
                                primaryQuesList = ExAMUtilClass.sectionRandomizationFunc(primaryQuesList,Integer.valueOf(sectionTemplateRecord.Random_Display_Count__c));
                            }
                            primaryQuesList.addAll(caseQuesList);
                        }
                        secAnsQuesTemArrClassList.add( new SectionAndQuestionTemplateClass(sectionTemplateRecord,primaryQuesList));
                    }
                    if(secAnsQuesTemArrClassList.size() > 0) {
                        viewerRec.sectionAndQuestionTemplate = secAnsQuesTemArrClassList;
                    }
                }
                //Start - update answer submit time in "Start time" 01-07-2016
                if(String.isNotBlank(createdASMId) && secAnsQuesTemArrClassList.size() > 0 
                        && secAnsQuesTemArrClassList[0].questionTemplateRecords != null
                        && secAnsQuesTemArrClassList[0].questionTemplateRecords.size() > 0 
                        && viewerName == 'lens') {
                    
                    List<IssueRequest_Life_Cycle__c> amActualStartTimeNullList = [SELECT Id, Field_Start_Time__c FROM IssueRequest_Life_Cycle__c WHERE Id = :createdASMId AND Field_Start_Time__c = null LIMIT 1];
                    if (amActualStartTimeNullList != null && amActualStartTimeNullList.size() > 0) {
                        
                        IssueRequest_Life_Cycle__c updateStartTimeAssignmentManager = new IssueRequest_Life_Cycle__c(Id = amActualStartTimeNullList[0].Id, Field_Start_Time__c = System.now());
                        update updateStartTimeAssignmentManager;
                    }        
                }
                //End - update answer submit time in "Start time" 01-07-2016
                 
                //Added - populate default answer
                
                if(assignmentManagerList.size() > 0
                   && assignmentManagerList[0].InvestigationType__c != null
                   && assignmentManagerList[0].InvestigationType__r.One_Time_Assessment__c ) {       
                            
                   Set<Id> attachAnsId = new Set<Id>();
                   Map<Id,Id> quesIdandAnsIdAttMap = new Map<Id,Id>();   
                   Map<Id,List<String>> quesIdWithAnsOptRecordMap = new Map<Id,List<String>>();
                   if(responseList.size() > 0) {        
                        
                        List<Attachment> attachmentList = new List<Attachment>();  
                        if(questionTemplateNameSet.size() > 0) {
                            Integer i = 0;
                            while(i < responseList.size()) {
                                for(String dtques : questionTemplateNameSet) {
                                    if(dtques == responseList[i].Question_Template__r.Name) {
                                        responseList.remove(i);
                                        i--;
                                        break;
                                    } 
                                }
                                i++;
                            }
                        }
                            
                        for(Questionnaire_Response__c res:responseList) {  
                            /*if( quesIdWithHiddenResMap.containsKey(res.Question_Template__c) ) {
                                quesIdWithHiddenResMap.remove(res.Question_Template__c);
                            }*/
                            quesTempIdSet.add(res.Question_Template__c);
                            if(res.Question_Template__r.Question_Type__c == 'File Question - Answer'){  
                               if(!quesIdandAnsIdAttMap.containsKey(res.Question_Template__c)) {
                                   quesIdandAnsIdAttMap.put(res.Question_Template__c,res.Id);
                               } 
                            } else if( res.Question_Template__r.Question_Type__c == 'Signature') {
                                if(!quesIdandAnsIdAttMap.containsKey(res.Question_Template__c)) {
                                   quesIdandAnsIdAttMap.put(res.Question_Template__c,res.Id);
                               } 
                            }       
                            if(!quesIdANDAnsIdMap.containsKey(res.Question_Template__c)) {      
                                quesIdANDAnsIdMap.put(res.Question_Template__c,res.Id);     
                            }       
                        }
                        if(quesIdANDAnsIdMap.size() > 0) {
                            viewerRec.quesIdANDAnsIdMap = quesIdANDAnsIdMap;
                        }
                        // added on 06-05-2017 for replacing subquestion label in question type, multiselectPicklist.                        
                        if ( quesTempIdSet.size() > 0 ){
                            for( Question_Template__c ques : [SELECT Id, Disabled__c, Single_Next_Question__c, Decision_Tree__c, 
                                                                 (SELECT Id,Name,Help_Text__c,Weight__c,
                                                                         Dependent_Question__r.Name,
                                                                         Next_Question__r.Name 
                                                                 FROM Answer_Options__r 
                                                                 ORDER BY Order_No__c ASC) 
                                                             FROM Question_Template__c 
                                                             WHERE Id IN :quesTempIdSet AND Question_Type__c = 'MultiselectPicklist' AND Disabled__c = false] ){
                                List<String> ansOptList = new List<String>();
                                for( Answer_Option__c ansOpt :ques.Answer_Options__r){
                                    ansOptList.add(ansOpt.Name);
                                }
                                quesIdWithAnsOptRecordMap.put(ques.Id,ansOptList);
                            }
                        }
                            
                        if(quesIdandAnsIdAttMap.size() > 0) {
                            for(Id resId :quesIdandAnsIdAttMap.keySet()) {
                                attachAnsId.add(quesIdandAnsIdAttMap.get(resId));
                            }
                        }      
                        attachAnsId.add(createdASMId);
                        attachAnsId.add(assObjId);
                        if(attachAnsId.size() > 0) {        
                            attachmentList = [SELECT Body, ContentType, Id, IsPrivate, Name, ParentId FROM Attachment WHERE ParentId IN :attachAnsId ORDER BY LastModifiedDate DESC];     
                        }    
                        //this for looping only for AM and assessable attachment
                        Set<String> attachedQuesName = new Set<String>();
                        for(Attachment att :attachmentList) {   
                            
                            if( ( att.ParentId == assignmentManagerList[0].Id || att.ParentId == assObjId ) && att.Name.contains('Qt(') && att.Name.contains('Q-')){
                                
                                String quesName = att.Name;                        
                                quesName = quesName.substringAfter('Qt(');
                                quesName = quesName.substringBefore(')');  
                                if(!attachedQuesName.contains(quesName)) { 
                                    attachedQuesName.add(quesName);                     
                                    if( quesNameWithQuesMap.containsKey(quesName) && quesNameWithQuesMap.get(quesName).Question_Type__c != 'Hidden'){
                                        AnswerRecordClass ans = new AnswerRecordClass();
                                        List<attachmentClass> attachClassList = new List<attachmentClass>();
                                        //ans.response = '';  
                                        ans.quesResponse = new Questionnaire_Response__c();
                                        ans.questionTemp = quesNameWithQuesMap.get(quesName);
                                        //ans.questiontemplateId = quesNameWithQuesMap.get(quesName).Id; 
                                        //ans.questionType = quesNameWithQuesMap.get(quesName).Question_Type__c;
                                        attachmentClass attCls = new attachmentClass();    
                                            attCls.contenttype = att.contentType;
                                            attCls.name = att.Name.remove('Qt('+quesName+')');
                                            attCls.id = att.Id;
                                            attachClassList.add(attCls);
                                        //ans.attachmentId = att.Id;
                                        ans.attachmentMap = attachClassList;
                                        ansRecList.add(ans); 
                                    }
                                }  
                            }
                        }  
                              
                        for(Questionnaire_Response__c ansRec : responseList) {
                        
                            List<attachmentClass> attClassList = new List<attachmentClass>();
                            List<id> attIdList = new List<Id>();
                            
                            if( quesIdANDAnsIdMap.get(ansRec.Question_Template__c) == ansRec.Id ) {
                                AnswerRecordClass ans = new AnswerRecordClass();   
                                ans.quesResponse = new Questionnaire_Response__c(Response__c=ansRec.Response__c);
                                ans.questionTemp = quesIdWithQuesMap.get(ansRec.Question_Template__c);     
                                //ans.response = ansRec.Response__c;      
                                //ans.questiontemplateId = ansRec.Question_Template__c;       
                                //ans.questionType = ansRec.Question_Template__r.Question_Type__c;        
                                if(attachAnsId.contains(ansRec.Id)) {
                                    Integer count = 0;      
                                    for(Attachment att :attachmentList) {       
                                        attachmentClass attCls = new attachmentClass();
                                        if(att.ParentId == ansRec.Id){
                                            attIdList.add(att.Id);
                                            attCls.contenttype = att.contentType;
                                            attCls.name = att.Name;
                                            attCls.id = att.Id;
                                            attCls.serialNum = count;
                                            attClassList.add(attCls);
                                            count++;
                                        }   
                                    }   
                                    if(attClassList.size() > 0) {
                                        ans.attachmentMap = attClassList;
                                    } 
                                    if(attIdList.size() > 0) {
                                        quesIdAndAnsweredAttIdMap.put(ansRec.Question_Template__c,attIdList);
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
                                }       
                                ansRecList.add(ans);
                            }        
                        }     
                    }       
                } 
                if(quesIdAndAnsweredAttIdMap.size() > 0) {
                    viewerRec.quesIdAndAnsweredAttId = quesIdAndAnsweredAttIdMap;
                }
                /*if ( quesIdWithHiddenResMap.size() > 0 ){
                    for(Id quesId :quesIdWithHiddenResMap.keySet()){
                        AnswerRecordClass ans = new AnswerRecordClass();   
                        ans.quesResponse = new Questionnaire_Response__c(Response__c=quesIdWithHiddenResMap.get(quesId));
                        ans.questionTemp = quesIdWithQuesMap.get(quesId);     
                        //AnswerRecordClass ans = new AnswerRecordClass();        
                        //ans.response = quesIdWithHiddenResMap.get(quesId);      
                        //ans.questiontemplateId = quesId;
                        ansRecList.add(ans);
                    } 
                }*/
                if(ansRecList.size() > 0) {     
                    viewerRec.answeredRecord = ansRecList;      
                } 
            } //end if Check templateList size > 0
        }catch(Exception exp) {

            string errType = exp.getTypeName();
            string errMsg = (exp.getTypeName() != 'System.DMLException') ? exp.getMessage() : exp.getDMLMessage(0);
            viewerRec  = new ViewerRecordsClass(new ErrorClass(errType, errMsg));
        }
        return Json.serialize( viewerRec );
    }
    @RemoteAction
    global static DecisionTreeClass constructDecisionTreeResultQuestion(ConstructDTResultQuestionParamClass configuredRecs) {
        
        Boolean isPictureConfig = false;
        String decisionTreeResultStr = '';
        String fields = '';
        String viewerName = '';
        String configuredTemplateId = '';
        List<DecisionTreeResultClass> decisionTreeResultList = new List<DecisionTreeResultClass>();
        List<ExAM_Configuration__c> configRecordList = new List<ExAM_Configuration__c>();
        Set<String> fieldSet = new Set<String>();
        Map<String, String> fieldApiNameAndAvailableValueMap = new Map<String, String>();
        Map<String, String> fieldApiNameAndHiddenValueMap = new Map<String, String>();
        
        //Added on 20-07-2017 for Auto next in decision tree and custom result ques button text
        DecisionTreeClass dTRWCobj = new DecisionTreeClass();
        dTRWCobj.resultQuesButtonText = '';
        dTRWCobj.renderNextQuesAuto = false;
        dTRWCobj.decisionTreeResultList = new List<DecisionTreeResultClass>();
        dTRWCobj.skipDTpath = false;
        
        SFDCAccessController accessForAT = ExAMUtilClass.AccessController;
        if(configuredRecs != null && configuredRecs.assTempId != null && configuredRecs.viewerName != null ) {
            configuredTemplateId = configuredRecs.assTempId;
            viewerName = configuredRecs.viewerName;
        }  
        configRecordList = [
            SELECT Id, Overall_Status_on_Submit__c, Name, skip_Answer_For_Decision_Tree_Steps__c
            FROM ExAM_Configuration__c LIMIT 1
        ];

        if (configRecordList != null && configRecordList.size() > 0) {

            dTRWCobj.skipDTpath = configRecordList[0].skip_Answer_For_Decision_Tree_Steps__c;
        }
        if (String.isNotBlank(configuredTemplateId) ) {
        
            if(viewerName != '' && viewerName != 'public') {
                List<String> fieldsListAT = new List<String>{'ExAM__Decision_Tree__c','ExAM__Render_Next_Question_Automatically__c','ExAM__Result_Question_Button_Text__c','ExAM__One_Time_Assessment__c'};
                accessForAT.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Main_questionaire__c'), fieldsListAT);
            }        
            List<Main_questionaire__c> templateList = new List<Main_questionaire__c>();
            templateList = [SELECT Decision_Tree__c, Id, One_Time_Assessment__c, Name, Render_Next_Question_Automatically__c, Result_Question_Button_Text__c 
                            FROM Main_questionaire__c 
                            WHERE Id = :configuredTemplateId LIMIT 1
            ];
            
            if (templateList != null && templateList.size() > 0) {
                
                dTRWCobj.resultQuesButtonText = templateList[0].Result_Question_Button_Text__c != null ? templateList[0].Result_Question_Button_Text__c : '';
                dTRWCobj.renderNextQuesAuto = templateList[0].Render_Next_Question_Automatically__c;
            
                if (String.isNotBlank( templateList[0].Decision_Tree__c ) ) {

                    List<String> fieldListTemp = new List<String>();

                    if (templateList[0].Decision_Tree__c.contains('~')) {

                        fieldListTemp = templateList[0].Decision_Tree__c.split('~');
                    }
                    else {

                        fieldListTemp.add( templateList[0].Decision_Tree__c );
                    }
            
                    for(String f : fieldListTemp) {

                        String fieldApiName = f.split(':')[0];
                        String hasEnabled = f.split(':')[1];
                        String isHidden = f.split(':')[2];

                        if (fieldApiName != 'Pictures' && fieldApiName.contains('__c')) {
                            fieldApiNameAndAvailableValueMap.put(fieldApiName, hasEnabled);
                            fieldApiNameAndHiddenValueMap.put(fieldApiName, isHidden);
                        } else if (fieldApiName == 'Pictures') {
                            isPictureConfig = true;
                            fieldApiNameAndAvailableValueMap.put(fieldApiName, hasEnabled);
                            fieldApiNameAndHiddenValueMap.put(fieldApiName, isHidden);
                        }
                    }

                    Map <string, Schema.SObjectField> answerFieldNameAPIMap = Schema.SObjectType.Questionnaire_Response__c.fields.getMap();
                    for (String fieldName: fieldApiNameAndAvailableValueMap.keySet()) {
                        if (fieldName == 'Pictures') {
                            decisionTreeResultList.add( 
                                new DecisionTreeResultClass(
                                    'Picture',
                                    '',
                                    'PICTURE',
                                    new List<String>(),
                                    Boolean.valueOf( fieldApiNameAndAvailableValueMap.get('Pictures') ),
                                    Boolean.valueOf( fieldApiNameAndHiddenValueMap.get('Pictures') )
                                )
                            );
                        } else if(answerFieldNameAPIMap != null && answerFieldNameAPIMap.containsKey(fieldName)) {
                            Schema.SObjectField ansfield = answerFieldNameAPIMap.get(fieldName);
                            Schema.DescribeFieldResult res = ansfield.getdescribe();
                            
                            List<String> picklistvalueTempList = new List<String>();
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
                                    Boolean.valueOf( fieldApiNameAndAvailableValueMap.get(fieldName) ),
                                    Boolean.valueOf( fieldApiNameAndHiddenValueMap.get(fieldName) )
                                )
                            );
                        }
                    }
                    if (decisionTreeResultList != null && decisionTreeResultList.size() > 0) {
                        dTRWCobj.decisionTreeResultList = decisionTreeResultList;
                    }
                }// end if Decision Tree in Templatae not blank codn check
            }// end if templateList size check
            //decisionTreeResultStr = JSON.serialize(dTRWCobj);
        }// end if configuredTemplateId not blank codn check
        return dTRWCobj;
    }
    @RemoteAction
    global static string saveAnswerRecord(SaveAnswerRecordParamClass ansRec) {

        List<AnswerRecordClass> answerList = ansRec.answerList != null ? ansRec.answerList : new List<AnswerRecordClass>();
        String tempId = ansRec.tempId != null ? ansRec.tempId : '' ;
        String assessibleObjId = ansRec.assessibleObjId != null ? ansRec.assessibleObjId : '' ;
        String assessibleObjName = ansRec.assessibleObjName != null ? ansRec.assessibleObjName : '' ;
        String amId = ansRec.amId != null ? ansRec.amId : '' ;
        String publicAssessmentId = ansRec.publicAssessmentId != null ? ansRec.publicAssessmentId : '' ;
        String ipAddress = ansRec.ipAddress != null ? ansRec.ipAddress : '' ;
        String startTimeStr = ansRec.startTimeStr != null ? ansRec.startTimeStr : '' ;
        String viewerName = ansRec.viewerName != null ? ansRec.viewerName : '' ;
        Map<string, CaseRecordClass> caseRec = ansRec.caseRec != null ? ansRec.caseRec : new Map<string, CaseRecordClass>();
        Map<string, string> decisionTreeQuesIdAnsId = ansRec.decisionTreeQuesIdAnsId != null ? ansRec.decisionTreeQuesIdAnsId : new Map<string, string>();
        Map<Id,Id> quesIdANDAnsIdMap = ansRec.quesIdANDAnsIdMap != null ? ansRec.quesIdANDAnsIdMap : new Map<Id,Id>();
        Boolean isSubmit = ansRec.isSubmit != null ? ansRec.isSubmit : False ;
        String secId = ansRec.secId != null ? ansRec.secId : '';
        Boolean isSingleQuestionMode = ansRec.isSingleQuestionMode;
        string amName = '';
        string resultMsg = JSON.serialize( new ErrorClass('Error', 'No Answer records to save'));
        SObject newASMRecord;
        String assessibleObjReferenceForAnsCreation = '';
        String assessibleObjReferenceForAMCreation = '';
        List<Questionnaire_Response__c> upsertAnswerList = new List<Questionnaire_Response__c>();
        List<IssueRequest_Life_Cycle__c> amList = new List<IssueRequest_Life_Cycle__c>();
        List<Questionnaire_Response__c> hiddenAnswerList = new List<Questionnaire_Response__c>();
        Map<Id, Question_Template__c> quesIdwithQuestionMap = new Map<Id, Question_Template__c>();
        Map<Id,Id> updateAnsIdAndQuesIdMap = new Map<Id,Id>();
        Set<Id> quesIdSet = new Set<Id>();
        String returnPageURL = '';
        
        saveResponseClass saveResp = new saveResponseClass();
        SFDCAccessController accessForobj = ExAMUtilClass.AccessController;
        try {
            if( ansRec != null ) {
                if(assessibleObjName != '') {
                    assessibleObjReferenceForAnsCreation = assessableFieldApiName('ExAM__Questionnaire_Response__c',assessibleObjName);
                    assessibleObjReferenceForAMCreation = assessableFieldApiName('ExAM__IssueRequest_Life_Cycle__c',assessibleObjName);
                }
                if(viewerName != 'public') {
                    
                    List<String> fieldsListAT = new List<String>{'ExAM__One_Time_Assessment__c'};
                    accessForobj.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Main_questionaire__c'), fieldsListAT);
                    
                    List<String> fieldsListAM = new List<String>{'ExAM__InvestigationType__c', 'ExAM__Status__c'};
                    accessForobj.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__IssueRequest_Life_Cycle__c'), fieldsListAM);
        
                    List<String> fieldsListEC = new List<String>{'ExAM__Overall_Status_on_Submit__c'};
                    accessForobj.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__ExAM_Configuration__c'), fieldsListEC);
                        
                    List<String> fieldsListAMUpdate = new List<String>{'ExAM__Status__c'};
                    accessForobj.assertAuthorizedToUpdate(Schema.getGlobalDescribe().get('exam__IssueRequest_Life_Cycle__c'), fieldsListAMUpdate);
                    
                    List<string> fieldsListAns = new List<string>{'ExAM__Question_Template__c','ExAM__Response__c','ExAM__Weight_Response__c'};
                    accessForobj.assertAuthorizedToCreate(Schema.getGlobalDescribe().get('exam__Questionnaire_Response__c'), fieldsListAns);
                    List<string> fieldsListAns1 = new List<string>{'ExAM__Response__c','ExAM__Weight_Response__c'};
                    accessForobj.assertAuthorizedToUpdate(Schema.getGlobalDescribe().get('exam__Questionnaire_Response__c'), fieldsListAns1);
                }
                
                if( String.isBlank(assessibleObjId) && viewerName == 'public') {
                   hiddenAnswerList = ExAMUtilClass.prepareAnswers(tempId, null, null, false);
                   if( String.isNotBlank(tempId) 
                       && String.isNotBlank(assessibleObjName)
                       && string.isBlank(amId) 
                       && ( answerList.size() > 0 || hiddenAnswerList.size() > 0 ) ) {
                   
                        List<Questionnaire_Response__c> questionnarieResList = new List<Questionnaire_Response__c>();
                        if(answerList.size() > 0) {
                            for(AnswerRecordClass ans: answerList) {
                                if(ans.quesResponse != null) {
                                    ans.quesResponse.Question_Template__c = ans.questionTemp.Id;
                                    questionnarieResList.add(ans.quesResponse);
                                }
                            } 
                        } 
                        if( hiddenAnswerList.size() > 0 ) {
                            questionnarieResList.addAll(hiddenAnswerList);
                        }
                        if(questionnarieResList.size() > 0) {
                            SObject sobj = sObjectRecCreation(assessibleObjName,tempId,questionnarieResList);
                            if(sobj != null) {
                                assessibleObjId = sobj.Id;
                            }
                        }
                    }
                }
                if( viewerName == 'public' && string.isBlank(amId) && string.isNotBlank(assessibleObjId) && string.isNotBlank(assessibleObjReferenceForAMCreation)) {
                    newASMRecord = new IssueRequest_Life_Cycle__c();
                    newASMRecord.put('ExAM__InvestigationType__c', tempId);
                    newASMRecord.put(assessibleObjReferenceForAMCreation, assessibleObjId);
                    insert newASMRecord;
                    amId = newASMRecord.Id;
                } else {
                    List<IssueRequest_Life_Cycle__c> am = [SELECT Id,Name,Status__c,InvestigationType__r.One_Time_Assessment__c FROM IssueRequest_Life_Cycle__c WHERE Id = :amId];
                    
                    if(am != null && am.size() > 0 && am[0].InvestigationType__r.One_Time_Assessment__c) {
                        amName = am[0].Name;
                        updateAM(amId);
                    }
                }
                if( string.isNotBlank(amId) ) {
                    saveResp.amId = amId;
                    saveResp.assessableObjectId = assessibleObjId;
                    saveResp.successMsg = 'Files saved successfully.';
                    hiddenAnswerList = new List<Questionnaire_Response__c>();
                    if( viewerName == 'lens' || viewerName == 'public' ){
                        hiddenAnswerList = ExAMUtilClass.prepareAnswers(tempId, null, amId, false);
                    } else if( viewerName == 'standard' ){
                        hiddenAnswerList = ExAMUtilClass.prepareAnswers(tempId, secId, amId, isSingleQuestionMode);
                    }
                    if( answerList != null 
                        && answerList.size() > 0 ) {
                  
                        if (tempId != null && tempId != '') {  
        
                            quesIdwithQuestionMap = new Map<Id, Question_Template__c>([ 
                                SELECT Id, Subquestion_Label__c, Weight_of_Answer__c,   HelpText__c, Section_Question__c, 
                                       Section_Question__r.Questionnaire_Section__c, Question_Label__c, Question_Order_No__c,
                                       Question_Type__c, Do_Not_Create_Answer__c,
                                       (SELECT Id,Name,Help_Text__c,Weight__c,Dependent_Question__r.Name,Next_Question__r.Name FROM Answer_Options__r ORDER BY Order_No__c ASC)
                                FROM   Question_Template__c
                                WHERE  (Section_Question__r.Questionnaire_Section__c = :tempId AND Do_Not_Create_Answer__c = false  AND Disabled__c = false) ORDER BY Question_Order_No__c ASC NULLS LAST
                            ]);
                        }

                        for (AnswerRecordClass anscls : answerList) {
                            if( quesIdwithQuestionMap != null && quesIdwithQuestionMap.size() > 0 && 
                                (anscls != null && anscls.questionTemp != null && anscls.questionTemp.Id != null) &&
                                (quesIdwithQuestionMap.containskey(anscls.questionTemp.Id) && 
                                 quesIdwithQuestionMap.get(anscls.questionTemp.Id) != null) ) { 
                                 
                                Questionnaire_Response__c ans = new Questionnaire_Response__c();
                                ans = anscls.quesResponse;
                                if( quesIdANDAnsIdMap != null && quesIdANDAnsIdMap.size() > 0 && 
                                    quesIdANDAnsIdMap.containsKey(anscls.questionTemp.Id) ) {
                                    
                                    ans.Id = quesIdANDAnsIdMap.get(anscls.questionTemp.Id);   
                                    updateAnsIdAndQuesIdMap.put(ans.Id,anscls.questionTemp.Id);   
                                    quesIdSet.add(anscls.questionTemp.Id);       
                                } else {        
                                    ans.Question_Template__c = anscls.questionTemp.Id;       
                                    quesIdSet.add(anscls.questionTemp.Id);       
                                }
                                ans.Issue_Request__c = amId;                      
                                ans.Questionnaire_Taker_user__c = UserInfo.getUserId();
                                upsertAnswerList.add(ans); 
                            }
                        }
                    }   
                    if( upsertAnswerList.size() > 0 || hiddenAnswerList.size() > 0 ) {
                        if( upsertAnswerList.size() > 0 ) {
                            upsertAnswerList = setAnswerWeight(upsertAnswerList, quesIdwithQuestionMap,updateAnsIdAndQuesIdMap);
                        }
                        upsertAnswerList.addAll(hiddenAnswerList);
                        
                        upsert upsertAnswerList;
                        Map<Id,Id> quesIdwithAnsIdMapTemp = new Map<Id,Id>();
                        if(quesIdSet.size() > 0) {
                            string upsertAnsQuery = 'SELECT Id,Name,ExAM__Question_Template__c, ExAM__Issue_Request__c,ExAM__Response__c,ExAM__comment__c';
                            
                            if( assessibleObjReferenceForAnsCreation != null && assessibleObjReferenceForAnsCreation != '' ){
                                upsertAnsQuery += ','+assessibleObjReferenceForAnsCreation;
                            }
                            upsertAnsQuery += ' FROM ExAM__Questionnaire_Response__c WHERE ExAM__Issue_Request__c = :amId AND ExAM__Question_Template__c IN :quesIdSet ORDER BY LastModifiedDate DESC';
                            for (Questionnaire_Response__c ans : Database.Query(upsertAnsQuery)) {
                                if (!quesIdwithAnsIdMapTemp.containskey(ans.Question_Template__c)) {
                                    quesIdwithAnsIdMapTemp.put(ans.Question_Template__c,ans.Id);
                                }
                            }
                        }
                        saveResp.quesIdwithAnsIdMap = quesIdwithAnsIdMapTemp;
                        saveResp.successMsg = 'Answers created successfully.';
                    } else {
                        resultMsg = JSON.serialize( new ErrorClass('AnswerNotCreated', 'No Answers created since all answered questions has Do Not Create Answer flag checked') );
                    }
                        
                    //Start of Case create 
                    //new variable for case 03-11-2016 
                    Map<Id, string> questionIdwithQuestionResponse = new Map<Id, string>();
                    if (caseRec != null && caseRec.size() > 0) {
                    
                        Map<string, Contact> questionIdwithConMap = new Map<string, Contact>();
                        List<Case> caseList = new List<Case>();
                        List<string> emailList = new List<string>();
                        Map<string,Id> conIdAndEmailMap = new Map<string,Id>();
                        Map<Id,Id> questionIdAndExistConIdMap = new Map<Id,Id>();
                        for (string qId :caseRec.KeySet()) {
                            if (caseRec.get(qId).Email != null && caseRec.get(qId).Email != '') {
                                emailList.add(caseRec.get(qId).Email);
                            }
                        }
                        
                        for(Contact con :[SELECT Id,Email FROM Contact WHERE Email IN :emailList]) {
                            conIdAndEmailMap.put(con.Email,con.Id);
                        }
                        for (string qId :caseRec.KeySet()) {
                            if (caseRec.get(qId).Name != null && caseRec.get(qId).Name != '') {
                                if(conIdAndEmailMap.ContainsKey(caseRec.get(qId).Email)) {
                                    Id conId = conIdAndEmailMap.get(caseRec.get(qId).Email);                                    
                                    questionIdAndExistConIdMap.put(qId,conId);
                                } else {
                                    questionIdwithConMap.put(qId, new Contact(LastName = caseRec.get(qId).Name, Email = caseRec.get(qId).Email));
                                }
                            }
                        }
                        if (questionIdwithConMap != null && questionIdwithConMap.size() > 0) {
                            if(viewerName !='public') {
                                List<string> fieldsListContact = new List<string>{'Email','Lastname'};
                                accessForobj.assertAuthorizedToCreate(Schema.getGlobalDescribe().get('Contact'), fieldsListContact);
                            }
                            insert questionIdwithConMap.values(); 
                        }   
                        if ((questionIdwithConMap != null && questionIdwithConMap.size() > 0)
                            ||(questionIdAndExistConIdMap != null && questionIdAndExistConIdMap.size() > 0)
                        ) {
                            Set<Id> answerIdSet = new Set<Id> ();
                            for (Questionnaire_Response__c upsertAns : upsertAnswerList) {
                                answerIdSet.add(upsertAns.Id);
                            }
                            
                            if (decisionTreeQuesIdAnsId != null && decisionTreeQuesIdAnsId.size() > 0) {
                                string ansprefix = Questionnaire_Response__c.sObjectType.getDescribe().getkeyPrefix();
                                for (string decisionAnswerId : decisionTreeQuesIdAnsId.values()) {
                                    if (decisionAnswerId.startsWithIgnoreCase(ansprefix)) {
                                        answerIdSet.add(Id.valueOf(decisionAnswerId));
                                    }
                                }
                            }
                            Map<Id, string> questionIdwithCaseMappingFieldMap = new Map<Id, string>();
                            Map<string, Schema.SObjectField> caseSchemaFieldMap = Schema.SObjectType.Case.fields.getMap();
                            Map<Id, Question_Template__c> caseQuestionTemplateMap; 
                            if (answerIdSet.size() > 0) {
        
                                for( Questionnaire_Response__c ans : [SELECT Id, Response__c, Question_Template__c, Issue_Request__c
                                                                        FROM Questionnaire_Response__c 
                                                                        WHERE Issue_Request__c != null
                                                                        AND Id IN:answerIdSet ] ) {
                                    if (!questionIdwithQuestionResponse.containsKey(ans.Question_Template__c)) {
                                        questionIdwithQuestionResponse.put(ans.Question_Template__c, ans.Response__c);
                                    }
                                }
                                if(viewerName != 'public') {
                                    List<string> fieldsList = new List<string>{'ExAM__Assessable_Object_API__c','ExAM__Assessable_Object_Field_API__c','ExAM__Assessment_Template__c','ExAM__Question_Template__c','ExAM__Is_Case_Response__c'};
                                    accessForobj.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Assessable_Fields_Mapping__c'), fieldsList);
                                }
                                for (Assessable_Fields_Mapping__c afm : [ SELECT Id, Assessable_Object_API__c, Assessable_Object_Field_API__c, Assessment_Template__c, 
                                                                                Question_Template__c,Is_Case_Response__c 
                                                                         FROM Assessable_Fields_Mapping__c
                                                                         WHERE Assessable_Object_API__c != null
                                                                         AND Assessment_Template__c != null
                                                                         AND Question_Template__c != null
                                                                         AND Assessable_Object_Field_API__c != null 
                                                                         AND Assessable_Object_API__c = 'Case'
                                                                         AND Assessment_Template__c =:tempId
                                                                         AND Is_Case_Response__c = true
                                                                         AND Question_Template__c IN:questionIdwithQuestionResponse.keySet()]) {
        
                                    questionIdwithCaseMappingFieldMap.put(afm.Question_Template__c, afm.Assessable_Object_Field_API__c.toLowerCase());
                                    //assesableFieldAPINameSet.add(afm.Assessable_Object_Field_API__c.toLowerCase());
                                }
                                if (questionIdwithCaseMappingFieldMap != null && questionIdwithCaseMappingFieldMap.size() > 0) {
        
                                    caseQuestionTemplateMap = new Map<Id, Question_Template__c>([SELECT Id, Question_Type__c FROM Question_Template__c WHERE Id IN:questionIdwithCaseMappingFieldMap.keySet() ]);
                                }
                            }
                            List<string> fieldsListCase = new List<string>{'ContactId', 'Description', 'Subject'};
                            for (string qId :caseRec.KeySet()) {
                                Case caseOb = new Case();
                                caseOb.put('Subject','Case from '+amName+' : '+caseRec.get(qId).Subject);
                                if (questionIdwithConMap.containskey(qId)) {
                                    caseOb.put('ContactId', questionIdwithConMap.get(qId).Id);
                                } else if(questionIdAndExistConIdMap.containskey(qId)) {
                                    caseOb.put('ContactId', questionIdAndExistConIdMap.get(qId));
                                }
                                caseOb.put('Description',caseRec.get(qId).Descrip);
                                if (questionIdwithCaseMappingFieldMap != null && questionIdwithCaseMappingFieldMap.size() > 0 && questionIdwithQuestionResponse != null && questionIdwithQuestionResponse.size() > 0) {
                                    for (Id questionId :questionIdwithCaseMappingFieldMap.keySet()) {
                                        if(caseSchemaFieldMap != null) {
                                            if (caseSchemaFieldMap.containskey(questionIdwithCaseMappingFieldMap.get(questionId))) {
                                                fieldsListCase.add(questionIdwithCaseMappingFieldMap.get(questionId));
                                                if (caseQuestionTemplateMap != null && caseQuestionTemplateMap.size() > 0 && caseQuestionTemplateMap.get(questionId).Question_Type__c == 'Date') {
                                                    string fieldType = string.valueOf(caseSchemaFieldMap.get(questionIdwithCaseMappingFieldMap.get(questionId)).getDescribe().getType());
                                                    if (fieldType.equalsIgnoreCase('DATE')) {
                                                        if((questionIdwithQuestionResponse.get(questionId)).split('/').size() == 3){
                                                            string[] dateStr = (questionIdwithQuestionResponse.get(questionId)).split('/');
                                                            Date response = Date.newinstance( Integer.valueOf(dateStr[2]), Integer.valueOf(dateStr[1]), Integer.valueOf(dateStr[0]));
                                                            caseOb.put(questionIdwithCaseMappingFieldMap.get(questionId), response);
                                                        }
                                                    } else if(fieldType.equalsIgnoreCase('DATETIME')) {
                                                        if((questionIdwithQuestionResponse.get(questionId)).split('/').size() == 3){
                                                            string[] dateStr = (questionIdwithQuestionResponse.get(questionId)).split('/');
                                                            Datetime response = Datetime.newinstance( Integer.valueOf(dateStr[2]), Integer.valueOf(dateStr[1]), Integer.valueOf(dateStr[0]));
                                                            caseOb.put(questionIdwithCaseMappingFieldMap.get(questionId), response);
                                                        }
                                                    } 
                                                } else {
                                                    caseOb.put(questionIdwithCaseMappingFieldMap.get(questionId), questionIdwithQuestionResponse.get(questionId));
                                                }
                                            }                                       
                                        }
                                    }
                                }
                                caseList.add(caseOb); 
                            }
                            if (caseList.size() > 0) {
                                accessForobj.assertAuthorizedToCreate(Schema.getGlobalDescribe().get('Case'), fieldsListCase);
                                insert caseList;
                            }
                        }
                    }
                    //End of Case create 
                    if ( viewerName == 'public' || ( viewerName != 'public' && isSubmit )) {
                        IssueRequest_Life_Cycle__c amUpdate;
                        List<ExAM_Configuration__c> configList = [SELECT Overall_Status_on_Submit__c, Id FROM ExAM_Configuration__c WHERE Overall_Status_on_Submit__c != null ORDER BY CreatedDate DESC LIMIT 1];
                        if (configList != null && configList.size() > 0) {
                            amUpdate = new IssueRequest_Life_Cycle__c(Id =Id.valueOf(amId), Status__c = configList[0].Overall_Status_on_Submit__c, Field_End_Time__c = System.now()); 
                        } else {
                            amUpdate = new IssueRequest_Life_Cycle__c(Id =Id.valueOf(amId), Status__c = 'Completed', Field_End_Time__c = System.now());
                        }
                        update amUpdate;
                        saveResp.successMsg = 'Assignment Manager updated successfully.';
                        if(viewerName == 'public') {
                            List<RecordType> recordTypeList = [SELECT Id, Name, DeveloperName, SObjectType FROM RecordType WHERE DeveloperName = 'Public_Assessment' AND SObjectType ='ExAM__Visitor_Register__c' LIMIT 1];
                            Visitor_Register__c vr = new Visitor_Register__c (Assignment_Manager__c = ID.ValueOf(amId));
                            if ( recordTypeList != null && recordTypeList.size() > 0) {
                                vr.recordTypeId = recordTypeList[0].Id;
                            }
                            if (publicAssessmentId != null && publicAssessmentId != '' && publicAssessmentId != 'null') {
                                vr.Public_Assessment__c = Id.ValueOf(publicAssessmentId); 
                            }
                            if (ipAddress != null && ipAddress != '') {
                                vr.IP_Address__c = ipAddress;
                            }
                            if (startTimeStr != null && startTimeStr != '' && startTimeStr.contains(' ') && startTimeStr.contains('-') && startTimeStr.contains(':')) {
                                List<string> splitDateAndTime = startTimeStr.split(' ');
                                if (splitDateAndTime != null && splitDateAndTime.size() == 2) {
                                    List<string> splitDate = splitDateAndTime[0].split('-');
                                    List<string> splitTime = splitDateAndTime[1].split(':');
                                    if (splitDate != null && splitTime != null && splitDate.size() == 3 && splitTime.size() == 3) {
                                        vr.Date_and_TimeIN__c = DateTime.newInstance(Integer.valueOf(splitDate[0]),Integer.valueOf(splitDate[1]),Integer.valueOf(splitDate[2]),Integer.valueOf(splitTime[0]),Integer.valueOf(splitTime[1]),Integer.valueOf(splitTime[2]));
                                        
                                    }
                                }   
                            }
                            vr.Date_and_Time_Out__c = System.now();
                            insert vr;
                        
                            List<Main_questionaire__c> templateList = new List<Main_questionaire__c>();
                            List<Distribution__c> distributionList = new List<Distribution__c>();
                            List<Public_Assessment__c> paList = new List<Public_Assessment__c>();
                            paList = [SELECT Id,Distribution__c FROM Public_Assessment__c WHERE Id=:publicAssessmentId];
                            if( paList.size() > 0 ) {
                                distributionList = [SELECT Id,Landing_Page__c FROM Distribution__c WHERE Id =: paList[0].Distribution__c];
                            }
                            if(distributionList.size() > 0 
                               && distributionList[0].Landing_Page__c != null 
                               && distributionList[0].Landing_Page__c != '') {
                                    returnPageURL = distributionList[0].Landing_Page__c;
                            } else {
                                templateList = [SELECT Assessment_Completed_URL__c, Id, Name FROM Main_questionaire__c WHERE Id = :tempId AND Assessment_Completed_URL__c != NULL LIMIT 1];
                                if (templateList.size() > 0 && templateList[0].Assessment_Completed_URL__c != null && templateList[0].Assessment_Completed_URL__c != '' ) {
                                    returnPageURL = templateList[0].Assessment_Completed_URL__c;
                                }
                                
                                List<IssueRequest_Life_Cycle__c> amScoreQueryList = [SELECT Id, Total_Score__c FROM IssueRequest_Life_Cycle__c WHERE Id =:amId];
                                if (amScoreQueryList != null && amScoreQueryList.size() > 0 && amScoreQueryList[0].Total_Score__c != null) {
        
                                    List<Fact_Score_Data__c> scoreList = [  SELECT Id, Assessment_Template__c, Assessment_Completed_URL_JSON__c, LastModifiedDate  
                                                                            FROM Fact_Score_Data__c
                                                                            WHERE Assessment_Template__c != null
                                                                        AND Assessment_Template__c =:tempId Order by LastModifiedDate Desc];

                                    if (scoreList != null && scoreList.size() > 0 && scoreList[0].Assessment_Completed_URL_JSON__c != null 
                                        && scoreList[0].Assessment_Completed_URL_JSON__c != '') {
        
                                        List<scoreURLClass> scoreUrlList = (List<scoreURLClass>) JSON.deserialize(scoreList[0].Assessment_Completed_URL_JSON__c, List<scoreURLClass>.class);
                                        for (scoreURLClass scrUrl : scoreUrlList ) {
                                            Boolean isValidDecimal = false;
                                            if(scrUrl.fromScore != null && scrUrl.toScore != null){
                                                
                                                try{
                                                    Decimal.valueOf(scrUrl.fromScore);
                                                    Decimal.valueOf(scrUrl.toScore);
                                                }
                                                catch(TypeException e){
                                                   isValidDecimal = true; 
                                                }
                                                if ( !isValidDecimal && Decimal.valueOf(scrUrl.fromScore)  <= amScoreQueryList[0].Total_Score__c 
                                                     && Decimal.valueOf(scrUrl.toScore) >= amScoreQueryList[0].Total_Score__c) {
            
                                                    if (scrUrl.urlStr != null && scrUrl.urlStr != '') { 
                                                        returnPageURL =  scrUrl.urlStr;
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            if( String.isNotBlank(returnPageURL) ) {
                                if (returnPageURL.startsWithIgnoreCase('http://') || returnPageURL.startsWithIgnoreCase('https://')) {
                                    saveResp.returnURL = returnPageURL;    
                                } else {
                                    saveResp.returnURL = 'https://'+returnPageURL;
                                }
                            }
                        }
                    }
                    resultMsg = JSON.serialize(saveResp);
                }
            }
        } catch (Exception exCase) {
           resultMsg = JSON.serialize( new ErrorClass(exCase.getTypeName(), (exCase.getTypeName() != 'System.DMLException') ? exCase.getMessage() : exCase.getDMLMessage(0)) );
        }
        return resultMsg;
    } 
    
    @RemoteAction
    global static string saveDecisionTreeAnswerRecords(DTSaveParamClass DTRecDetails) {
        SObject newASMRecord;
        String resultMsg = JSON.serialize(new ErrorClass('Error', 'DecisionTree Answer have not save'));
        Map<Id, Id> questionIdWithCreatedAnswerMap = new Map<Id, Id>();
        Map<Id,Id> updateAnsIdAndQuesIdMap = new Map<Id,Id>();
        Map<Id, Integer> templateIdAndResponsesCountMap = new Map<Id, Integer>();
        Set<Id> launchedQtnIdSet = new Set<Id>();
        
        Map<String,String> assessedAnsIdANDQuesId = DTRecDetails != null && DTRecDetails.quesIdANDAnsIdMap != null ? DTRecDetails.quesIdANDAnsIdMap: new Map<String,String>() ;
        List<Questionnaire_Response__c> decisionTreeAnsList = DTRecDetails != null && DTRecDetails.decisionTreeAnsList != null ? DTRecDetails.decisionTreeAnsList : new List<Questionnaire_Response__c>();
        String tempId =  DTRecDetails != null && DTRecDetails.tempId != null ? DTRecDetails.tempId : '';
        String assessibleObjId = DTRecDetails != null && DTRecDetails.assessibleObjId != null ? DTRecDetails.assessibleObjId : '';
        String assessibleObjName = DTRecDetails != null && DTRecDetails.assessibleObjName != null ? DTRecDetails.assessibleObjName : '';
        String createdAMId = DTRecDetails != null && DTRecDetails.createdAMId != null ? DTRecDetails.createdAMId : '';
        String viewerName = DTRecDetails != null && DTRecDetails.viewerName != null ? DTRecDetails.viewerName : '';
        String assessibleObjReferenceForAnsCreation = '';
        String assessibleObjReferenceForAMCreation = '';
        
        DTSaveSuccessClass dtSaveSuc = new DTSaveSuccessClass();
        dtSaveSuc.assessableObjId = assessibleObjId;
        dtSaveSuc.questioIdWithCreatedAnswerId = questionIdWithCreatedAnswerMap;
        dtSaveSuc.templateIdAndResponsesCount = templateIdAndResponsesCountMap;
        dtSaveSuc.createdAMId = createdAMId;
        
        SFDCAccessController accessForObj = ExAMUtilClass.AccessController;
        try {
            assessibleObjReferenceForAnsCreation = assessableFieldApiName('ExAM__Questionnaire_Response__c',assessibleObjName);
            assessibleObjReferenceForAMCreation = assessableFieldApiName('ExAM__IssueRequest_Life_Cycle__c',assessibleObjName);
            
            if (string.isBlank(createdAMId) && string.isNotBlank(assessibleObjName) && string.isNotBlank(assessibleObjId)
                && string.isNotBlank(assessibleObjReferenceForAMCreation)) {
                newASMRecord = new IssueRequest_Life_Cycle__c();
                newASMRecord.put('ExAM__InvestigationType__c', tempId);
                newASMRecord.put(assessibleObjReferenceForAMCreation, assessibleObjId);
                insert newASMRecord;
                createdAMId = newASMRecord.Id;
                dtSaveSuc.createdAMId = createdAMId;
            }
            if(viewerName != 'public') {
                List<String> fieldsListST = new List<String>{'ExAM__Questionnaire_Section__c'};
                accessForObj.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Section_Template__c'), fieldsListST);
                
                List<String> fieldsListAnsOpt = new List<String>{'ExAM__Help_Text__c','ExAM__Weight__c','ExAM__Dependent_Question__c','ExAM__Next_Question__c','ExAM__Order_No__c'};
                accessForObj.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Answer_Option__c'), fieldsListAnsOpt);
                
                List<String> fieldsListQT = new List<String>{'ExAM__Do_Not_Create_Answer__c','ExAM__Subquestion_Label__c','ExAM__Weight_of_Answer__c','ExAM__HelpText__c',
                                                            'ExAM__Section_Question__c','ExAM__Question_Label__c','ExAM__Question_Order_No__c','ExAM__Question_Type__c',
                                                            'ExAM__Single_Next_Question__c'};
                accessForObj.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Question_Template__c'), fieldsListQT);
                
                List<String> fieldsListQRCreate = new List<String>{'ExAM__Weight_Response__c'};
                accessForObj.assertAuthorizedToCreate(Schema.getGlobalDescribe().get('exam__Questionnaire_Response__c'), fieldsListQRCreate);
            }

            if (decisionTreeAnsList != null && decisionTreeAnsList.size() > 0) {
                Map<Id, Questionnaire_Response__c> questionIdwithAnswerMap = new Map<Id, Questionnaire_Response__c>();
                for (Questionnaire_Response__c ans : decisionTreeAnsList ) {

                    Questionnaire_Response__c answerNewIns = new Questionnaire_Response__c();
                    answerNewIns = ans;
                    if (string.isNotBlank(createdAMId)) {
                        answerNewIns.Issue_Request__c = createdAMId;
                    }
                    if (string.isNotBlank(assessibleObjReferenceForAnsCreation) ) {
                        answerNewIns.put(assessibleObjReferenceForAnsCreation, assessibleObjId);
                    }
                    
                    if( answerNewIns.Question_Template__c != null ) {
                        questionIdwithAnswerMap.put(answerNewIns.Question_Template__c, answerNewIns);      
                        templateIdAndResponsesCountMap.put(answerNewIns.Question_Template__c, 0);
                    } else if( assessedAnsIdANDQuesId != null && assessedAnsIdANDQuesId.containsKey(answerNewIns.Id) ) {
                        questionIdwithAnswerMap.put(assessedAnsIdANDQuesId.get(answerNewIns.Id), answerNewIns);
                        updateAnsIdAndQuesIdMap.put(answerNewIns.Id,assessedAnsIdANDQuesId.get(answerNewIns.Id)); 
                        templateIdAndResponsesCountMap.put(assessedAnsIdANDQuesId.get(answerNewIns.Id), 0);
                    }
                    if( answerNewIns.Decision_Tree_Launched_Question__c != null ) {
                        launchedQtnIdSet.add( answerNewIns.Decision_Tree_Launched_Question__c );
                    }
                }

                for (Question_Template__c questionTemp : [SELECT Id, Do_Not_Create_Answer__c FROM Question_Template__c WHERE Id IN:questionIdwithAnswerMap.keySet() AND Do_Not_Create_Answer__c = true]) {
                    if(questionIdwithAnswerMap.containsKey(questionTemp.Id)) {
                        questionIdwithAnswerMap.remove(questionTemp.Id); 
                    }            
                } 
                if (questionIdwithAnswerMap != null && questionIdwithAnswerMap.size() > 0) {

                    Map<Id, Question_Template__c> qtnIdRecordMap = new Map<Id, Question_Template__c>(
                                                                    [SELECT Id, Question_Type__c, Subquestion_Label__c, 
                                                                            Weight_of_Answer__c,
                                                                        (SELECT Id,Name,Help_Text__c,Weight__c,
                                                                            Dependent_Question__r.Name,Next_Question__r.Name 
                                                                        FROM Answer_Options__r 
                                                                        ORDER BY Order_No__c ASC) 
                                                                    FROM Question_Template__c 
                                                                    WHERE Id IN :questionIdwithAnswerMap.keySet() AND Disabled__c = false
                                                                    ORDER BY Question_Order_No__c ASC NULLS LAST
                                                                    ]);

                    decisionTreeAnsList = setAnswerWeight(questionIdwithAnswerMap.values(), qtnIdRecordMap,updateAnsIdAndQuesIdMap);                    
                    upsert decisionTreeAnsList;
                    
                    for (Questionnaire_Response__c res : decisionTreeAnsList) {
                        if(res.Question_Template__c != null) {
                            questionIdWithCreatedAnswerMap.put(res.Question_Template__c, res.Id);
                        } else if(assessedAnsIdANDQuesId != null && assessedAnsIdANDQuesId.containsKey(res.Id)) {
                            questionIdWithCreatedAnswerMap.put(assessedAnsIdANDQuesId.get(res.Id), res.Id);
                        }
                    }
                    if(viewerName == 'lens') {
                        for (Questionnaire_Response__c res : [SELECT Decision_Tree_Launched_Question__c, Id, Issue_Request__c, Question_Template__c 
                                                              FROM Questionnaire_Response__c 
                                                              WHERE Decision_Tree_Launched_Question__c IN :launchedQtnIdSet AND Issue_Request__c = :createdAMId]) {
                            if ( !templateIdAndResponsesCountMap.containsKey(res.Decision_Tree_Launched_Question__c) ) {
                                templateIdAndResponsesCountMap.put(res.Decision_Tree_Launched_Question__c, 0);
                            }
                            Integer responseCount = templateIdAndResponsesCountMap.get(res.Decision_Tree_Launched_Question__c);
                            responseCount++;
                            templateIdAndResponsesCountMap.put(res.Decision_Tree_Launched_Question__c, responseCount);
                        }
                    }
                    dtSaveSuc.questioIdWithCreatedAnswerId = questionIdWithCreatedAnswerMap;
                    dtSaveSuc.templateIdAndResponsesCount = templateIdAndResponsesCountMap;
                    resultMsg =  JSON.serialize(dtSaveSuc);
                }
            }
        }
        catch(Exception exp) {
            string errType = (exp.getTypeName() != 'System.DMLException') ? 'Error' : 'System.DMLException';
            string errMsg = (exp.getTypeName() != 'System.DMLException') ? exp.getMessage() : exp.getDMLMessage(0);

            resultMsg = JSON.serialize(new ErrorClass(errType, errMsg));
        }
        return resultMsg;
    }  
     
    @RemoteAction       
    global static string saveAttachment(SaveAttParamClass attDetails) {
        
        List<AttachmentDetails> attDtlObj;
        List<string> alreadyAnsweredId;
        string attSaveResponse = '';
        List<Attachment> attList = new List<Attachment>();
        List<Attachment> deleteAttList = new List<Attachment>();
        
        try {
            if(attDetails != null) {
            
                attDtlObj = attDetails.attachDetailList != null ? attDetails.attachDetailList : new List<AttachmentDetails>();
                alreadyAnsweredId = attDetails.answeredAttIdList != null ? attDetails.answeredAttIdList : new List<String>();
                List<Attachment> updateAttList = new List<Attachment>();
                updateAttList = [SELECT Id,ParentId FROM Attachment  WHERE Id IN:alreadyAnsweredId AND (NOT Name Like '%Question-image%') ORDER BY CreatedDate DESC];
                if ( attDtlObj != null ) {
                    for(AttachmentDetails attRec : attDtlObj) {
                        Attachment att = new Attachment();
                        if(attRec.attId == null) {
                            att.Body = EncodingUtil.Base64Decode(attRec.imgContent);
                            att.Name = attRec.fileNameStr;
                            att.ContentType = attRec.cType;
                            att.ParentId = attRec.parentIdStr;
                            att.IsPrivate = attRec.isPrivate;
                            attList.add( att );
                            Integer count =0;
                            if(updateAttList.size() > 0) {
                                for(Attachment attach : updateAttList) {        
                                    if(attach.ParentId == attRec.parentIdStr){      
                                        //att.Id = attach.Id;
                                        att = new Attachment();
                                        att.id = attach.Id;
                                        deleteAttList.add(att);
                                        updateAttList.remove(count);     
                                        break;  
                                    } else {
                                        att.ParentId = attRec.parentIdStr;
                                    } 
                                    count++;     
                                }
                            } else {
                                att.ParentId = attRec.parentIdStr;
                            }
                            
                        } else {
                            att.id = attRec.attId;
                            deleteAttList.add(att);
                        }
                    }
                    if ( attList.size() > 0 ) {
                        upsert attList;
                        attSaveResponse = 'success';
                    }
                    if(deleteAttList.size() > 0) {
                        delete deleteAttList;
                    }
                }
            }
        }
        catch(DMLException dmlexp) {
            attSaveResponse = dmlexp.getDMLMessage(0);
        }
        catch(Exception exp) {
            attSaveResponse = exp.getMessage();
        }
        return attSaveResponse;
    }
    @RemoteAction
    global static string query(string soql) {
        List<sObject> records;
        try {
            records = Database.query(soql);
        } catch (QueryException qe) {
            return makeError(qe.getMessage(), 'INVALID_QUERY');
        }
        
        Map<string, Object> result = new Map<string, Object>();
        result.put('records', records);
        result.put('totalSize', records.size());
        result.put('done', true);
        return JSON.serialize(result);
    }
    // This method used to creating a Assessable Object record
    public static SObject sObjectRecCreation(String assessibleFieldApiName,String tempId, List<Questionnaire_Response__c> answerList) {
        
        Set<String> assFieldAndQuesIdSet = new Set<String>();
        String assObName = assessibleFieldApiName.split('~')[0];
        SObject sob;

        if(assessibleFieldApiName != null && assessibleFieldApiName != ''
           && tempId != null && tempId != ''
           && answerList != null && answerList.size() > 0 ) {
            Id templateId = tempId;
            List<Assessable_Fields_Mapping__c> assFieldMappingList = [SELECT Id, Assessable_Object_API__c, Assessable_Object_Field_API__c,
                Assessment_Template__c, Question_Template__c,
                Is_Case_Response__c, Store_Answer_Response_Or_Score__c,
                Mapped_From__c, Assignment_Manager_Field_API__c
            FROM   Assessable_Fields_Mapping__c
            WHERE  Assessable_Object_API__c != null
                AND Assessment_Template__c != null
                AND Question_Template__c != null
                AND Assignment_Manager_Field_API__c = null
                AND Assessable_Object_Field_API__c != null 
                AND Assessable_Object_API__c = :assObName
                AND Assessment_Template__c = :templateId
                AND Is_Case_Response__c = false
                AND Mapped_From__c = 'Answer'
                AND Store_Answer_Response_Or_Score__c = 'Response'
            ORDER BY LastModifiedDate DESC];
            if(assFieldMappingList != null && assFieldMappingList.size() > 0 ) {
            
                sob = Schema.getGlobalDescribe().get(assObName).newSObject();
                Map <String, Schema.SObjectField> assObjFieldMap = Schema.getGlobalDescribe().get(assObName).getDescribe().fields.getMap();
                for(Assessable_Fields_Mapping__c afm : assFieldMappingList) {
                    assFieldAndQuesIdSet.add(afm.Assessable_Object_Field_API__c+afm.Question_Template__c);
                }
                if(assObjFieldMap != null && assObjFieldMap.size() > 0 && assFieldAndQuesIdSet.size() > 0 ) {
                    for(Questionnaire_Response__c answeredRec : answerList)  {
                        for (Schema.SObjectField assField : assObjFieldMap.Values()) {
                            Schema.DescribeFieldResult fieldDesc = assField.getDescribe();
                            String AFM = fieldDesc.getName()+answeredRec.Question_Template__c;
                            if(assFieldAndQuesIdSet.contains(AFM)){
                                Schema.DisplayType fieldType = fieldDesc.getType();
                                if (fieldType == Schema.DisplayType.DATETIME) {
                                    if( (answeredRec.Response__c).split('/').size() == 3){
                                        string[] dateStr = (answeredRec.Response__c).split('/');
                                        Datetime response = dateTime.newinstance( Integer.valueOf(dateStr[2]), Integer.valueOf(dateStr[1]), Integer.valueOf(dateStr[0]) );
                                        sob.put(fieldDesc.getName(), response);
                                    }
                                } else if (fieldType == Schema.DisplayType.DATE) {
                                    if( (answeredRec.Response__c).split('/').size() == 3){
                                        string[] dateStr = (answeredRec.Response__c).split('/');
                                        Date response = date.newinstance( Integer.valueOf(dateStr[2]), Integer.valueOf(dateStr[1]), Integer.valueOf(dateStr[0]) );
                                        sob.put(fieldDesc.getName(), response);
                                    }                                         
                                } else if ((fieldType == Schema.DisplayType.DOUBLE) || (fieldType == Schema.DisplayType.INTEGER) || (fieldType == Schema.DisplayType.CURRENCY)) {
                                    if (answeredRec.Response__c.isNumeric()) {
                                        if(fieldType == Schema.DisplayType.INTEGER) {
                                            Integer d = Integer.valueOf(answeredRec.Response__c);
                                            sob.put(fieldDesc.getName(), d);
                                        } else if(fieldType == Schema.DisplayType.DOUBLE) {
                                            DOUBLE d = DOUBLE.valueOf(answeredRec.Response__c);
                                            sob.put(fieldDesc.getName(), d);
                                        } else {        
                                            Decimal d = Decimal.valueOf(answeredRec.Response__c);
                                            sob.put(fieldDesc.getName(), d);
                                        }
                                    }
                                } else {
                                    sob.put(fieldDesc.getName(), answeredRec.Response__c);
                                }
                            }
                        }
                    }
                    insert sob;
                }
            }

        }
        return sob;
    }
    
    public static void updateAM(String amId) {

        //Added for update Am records when set as one time assessment
        List<IssueRequest_Life_Cycle__c> amList = new List<IssueRequest_Life_Cycle__c>();
        amList = [SELECT Id,Name,Status__c,InvestigationType__r.One_Time_Assessment__c FROM IssueRequest_Life_Cycle__c WHERE Id = :amId LIMIT 1];

        List<ExAM_Configuration__c> configList = new List<ExAM_Configuration__c>();
        configList = [SELECT Overall_Status_on_Submit__c, Id FROM ExAM_Configuration__c WHERE Overall_Status_on_Submit__c != null ORDER BY CreatedDate DESC LIMIT 1];

        if ((amList != null && amList.size() > 0)
            && (configList != null && configList.size() > 0)
            && (amList[0].InvestigationType__r.One_Time_Assessment__c) 
            && ((amList[0].Status__c == configList[0].Overall_Status_on_Submit__c)
                || ((configList[0].Overall_Status_on_Submit__c == NULL || configList[0].Overall_Status_on_Submit__c == '')
                   && amList[0].Status__c == 'Completed')
               )
        ) {

            IssueRequest_Life_Cycle__c amUpdate = new IssueRequest_Life_Cycle__c(Id = amList[0].Id, Status__c = 'In Progress');
            update amUpdate;                
        } //end
    }
    public static List<Questionnaire_Response__c> setAnswerWeight(List<Questionnaire_Response__c> ansList, Map<Id, Question_Template__c> quesIdwithQuestionMap,Map<Id,Id> updateAnsIdAndQuesIdMap) {

        List<Questionnaire_Response__c> answerList = new List<Questionnaire_Response__c>();

        for (Questionnaire_Response__c ans : ansList) {
            Id quesTempalteId;
            if (ans.Id != null && updateAnsIdAndQuesIdMap != null && updateAnsIdAndQuesIdMap.containsKey(ans.Id) && updateAnsIdAndQuesIdMap.get(ans.Id) != null) {
                quesTempalteId = updateAnsIdAndQuesIdMap.get(ans.Id);
            }
            Questionnaire_Response__c answerRecord = new Questionnaire_Response__c();
            answerRecord = ans;
            //calculate answer weight 
            if(quesIdwithQuestionMap != null //String.isNotBlank(ans.Response__c)
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
                            if ( answerOptions[i] != null && ans.Response__c != null && ans.Response__c.equalsIgnoreCase(answerOptions.get(i))) {
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
                            if ( ansOptList[i] != null && ans.Response__c != null && ans.Response__c.equalsIgnoreCase(ansOptList.get(i))) {
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
    public static string assessableFieldApiName( String sobjName, String assObjName ) {
        String fieldApiName = '';
        ExAMUtilClass.AssessableObjectDetails objectDetail = ExAMUtilClass.getAssessableObjectDetails(sobjName);                            
        Map<string, string> objApiwithfieldsAPIMap = objectDetail.objectAndFieldAPIMap;

        if(objApiwithfieldsAPIMap != null && objApiwithfieldsAPIMap.size() > 0 
           && objApiwithfieldsAPIMap.containsKey(assObjName)) {
            fieldApiName = objApiwithfieldsAPIMap.get(assObjName);
        }
        return fieldApiName;
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
    
    global static string makeError(string message, string errorCode) {
        JSONGenerator gen = JSON.createGenerator(false);
        gen.writeStartArray();
        gen.writeStartObject();
        gen.writeStringField('message', message);
        gen.writeStringField('errorCode', errorCode);
        gen.writeEndObject();
        gen.writeEndArray();
        
        return gen.getAsString();
    }
    public class ViewerRecordsClass { 
        public String assObjId;
        public Main_questionaire__c assessmentTemplateRecord; 
        public List<SectionAndQuestionTemplateClass> sectionAndQuestionTemplate;  
        public Map<Id,List<Attachment>> parentIdAndArrayOfPictureIdMap; 
        public Map<Id,Integer> quesIdAndResponseCount;
        public Map<String,Question_Template__c> questionNamewithQuestionTemplate;
        public Map<Id,Question_Template__c> resultQuestionNamewithQuestionTemplate;
        public Map<Id,Map<String,String>> resultQuestionIdDefaultValueObj;
        public Map<String,Question_Template__c> dependentQuestionNamewithQuestionTemplate;
        public List<AnswerRecordClass> answeredRecord; 
        public Map<Id,Id> quesIdANDAnsIdMap;
        public DecisionTreeClass DTConfiguration;
        public ErrorClass error; 
        public Map<Id,List<Id>> quesIdAndAnsweredAttId;
        public Map<Id,Question_Template__c> quesIdWithQuestionTemplate;
        public ViewerRecordsClass() {}
        public ViewerRecordsClass(ErrorClass err) {
            this.error = err;
        }
    }
    public class SectionAndQuestionTemplateClass {
        public Section_Template__c sectionTemplateRecord;
        public List<Question_Template__c> questionTemplateRecords;
        public SectionAndQuestionTemplateClass(Section_Template__c secRec,List<Question_Template__c> quesTempRec) {
            this.sectionTemplateRecord = secRec;
            this.questionTemplateRecords = quesTempRec;
        }
    }
    global class ReturnViewerRecordsParamClass {
        public String assessmentTemplateId; 
        public String createdASMId; 
        public String viewerName;
    }
    global class ConstructDTResultQuestionParamClass {
        public String assTempId;
        public String viewerName;
        public ConstructDTResultQuestionParamClass(String tempId, String viewerName) {
            this.assTempId = tempId;
            this.viewerName = viewerName;
        }
    }
    public class AnswerRecordClass {
        public Question_Template__c questionTemp;
        public Map<String,Boolean> multiselectObj;
        public List<AttachmentClass> attachmentMap;
        public Questionnaire_Response__c quesResponse;
    }
    public class ErrorClass {
        public String errType{get; set;}
        public String errMsg{get; set;}
        public ErrorClass() {}
        public ErrorClass(string etype, string eMsg) {
            this.errType = etype;
            this.errMsg = eMsg; 
        }
    }
    public class AttachmentClass { 
        public String name;
        public String contenttype;
        public String id;
        public Integer serialNum;
    }
    global class DecisionTreeClass {
        public List<DecisionTreeResultClass> decisionTreeResultList;
        public String resultQuesButtonText;
        public Boolean renderNextQuesAuto;
        public Boolean skipDTpath;
    }
    global class DecisionTreeResultClass {
        public String fieldLabelName{get;set;}
        public String fieldAPIName{get;set;}
        public String fieldType{get;set;}
        public List<String> picklistValues{get;set;}
        public Boolean hasEnabled { get; set; }
        public Boolean isHidden { get; set; }

        public DecisionTreeResultClass(String fieldLabel, String fieldAPI, String fieldType, List<String> pklstValuesList, Boolean enableField, Boolean isHiddenField) {

            this.fieldLabelName = fieldLabel;
            this.fieldAPIName = fieldAPI;        
            this.fieldType = fieldType;
            this.picklistValues = pklstValuesList;        
            this.hasEnabled = enableField;
            this.isHidden = isHiddenField;
        }
    } 
    global class SaveAnswerRecordParamClass {
        public String tempId;
        public String assessibleObjId;
        public String amId;
        public String publicAssessmentId;
        public String assessibleObjName;
        public String ipAddress;
        public String startTimeStr;
        public Map<String, String> decisionTreeQuesIdAnsId;
        public Map<Id,Id> quesIdANDAnsIdMap;
        public List<AnswerRecordClass> answerList;
        public Map<String, CaseRecordClass> caseRec;
        public Boolean isSubmit;
        public String viewerName;
        public String secId;
        public Boolean isSingleQuestionMode;
    }
    global class CaseRecordClass {
        public Boolean isCheck;
        public String Name;
        public String Email;
        public String Subject;
        public String Descrip;
    }
    global class saveResponseClass {
        public Map<Id,Id> quesIdwithAnsIdMap;
        public String returnURL;
        public String amId;
        public String assessableObjectId;
        public String successMsg;
    }
    global class scoreURLClass {
        public String fromScore;
        public String toScore;
        public String urlStr;
    }
    global class SaveAttParamClass {
        public List<AttachmentDetails> attachDetailList;
        public List<String> answeredAttIdList;
    }
    global class AttachmentDetails {
        public Id attId;
        public String fileNameStr;
        public String imgContent;
        public String cType;
        public String parentIdStr;
        public Boolean isPrivate;        
    }
    global class DTSaveParamClass {
        public String tempId;
        public String assessibleObjId;
        public String createdAMId;
        public String assessibleObjName;
        public String viewerName;
        public List<Questionnaire_Response__c> decisionTreeAnsList;
        public Map<String,String> quesIdANDAnsIdMap;
    }
    global class DTSaveSuccessClass {
        public String createdAMId;
        public String assessableObjId;
        public Map<Id,Id> questioIdWithCreatedAnswerId;
        public Map<Id,Integer> templateIdAndResponsesCount;
    }
}