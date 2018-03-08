public with sharing class ExportAnswersPerAMController {
   
    public String assessmentTemplateJSON {get;set;}
    public String assessibleFieldListStr { get; set; }
    Public Boolean addResponseScore { get; set; }
    Public String exConfigId { get; set; }
    
    public ExportAnswersPerAMController() {
    
        DateTime createdStartDate, createdEndDate;
        List<String> assessibleFieldList = new List<String>();
        addResponseScore = false;
        exConfigId = '';
        try{
            SFDCAccessController accessForobj = ExAMUtilClass.AccessController;
            List<string> examconfigfieldsList = new List<string>{'ExAM__Add_Response_Score__c'};
            accessForobj.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__ExAM_Configuration__c'), examconfigfieldsList);
            List<ExAM_Configuration__c> exConfigList = [SELECT Id, Add_Response_Score__c FROM ExAM_Configuration__c LIMIT 1];
            if(exConfigList != null && exConfigList.size() > 0){
                exConfigId = exConfigList[0].Id;
                addResponseScore = exConfigList[0].Add_Response_Score__c;
            }
            ExAMUtilClass.AssessableObjectDetails objectDetails = ExAMUtilClass.getAssessableObjectDetails('ExAM__IssueRequest_Life_Cycle__c');
            if (objectDetails != null && objectDetails.assessableFieldInAMMap != null && objectDetails.assessableFieldInAMMap.size() > 0) {
                assessibleFieldList.addAll( objectDetails.assessableFieldInAMMap.keySet() );
                assessibleFieldListStr = JSON.serialize(assessibleFieldList);
            }
            List<String> fieldsList = new List<String>{'ExAM__PublishPlace__c','ExAM__Template_name__c'};
            accessForobj.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Main_questionaire__c'), fieldsList);
            
            assessmentTemplateJSON = '';
              
        
            List<Main_questionaire__c> templateList = [SELECT Id,Name,PublishPlace__c, Template_name__c
                                      FROM Main_questionaire__c ORDER BY CreatedDate DESC Limit 10000];
            if (templateList != null && templateList.size() > 0) {
                assessmentTemplateJSON = JSON.serialize(templateList);
            }
        }catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        }
    
    }
    
    @RemoteAction
    public static string saveExAMConfiguration(Id id, String addResScore){
        try{
            SFDCAccessController accessForobj = ExAMUtilClass.AccessController;
            List<string> fieldsList = new List<string>{'ExAM__Add_Response_Score__c'};
            accessForobj.assertAuthorizedToCreate(Schema.getGlobalDescribe().get('exam__ExAM_Configuration__c'), fieldsList);
            accessForobj.assertAuthorizedToUpdate(Schema.getGlobalDescribe().get('exam__ExAM_Configuration__c'), fieldsList);
            
            List<ExAM_Configuration__c> exConfList = new List<ExAM_Configuration__c>();
            ExAM_Configuration__c exConfig = new ExAM_Configuration__c();
            if (string.isNotBlank(id)) {
                exConfig.Id = id;
            }
            else {
                exConfig.Name = 'Configuration';
            }
            exConfig.Add_Response_Score__c = Boolean.valueOf(addResScore);
            exConfList.add(exConfig);
            upsert exConfList;
            
            return 'Success';
        } catch(Exception e){
            return 'Exception -'+e.getmessage();
        }
    }
    
    @RemoteAction
    public static WrapperClass exportAnswersRecords(String startCreatedDate, String endCreatedDate, String assTempId, List<String> assessibleFieldArray, string startCompletedDate, string endCompletedDate ) {
        
        try{
            if (assTempId != null || startCreatedDate != null || endCreatedDate != null ) {
                List<answerClass> answerObjList = new List<answerClass>();
                Set<String> questionLabelList = new Set<String>();
                List<Questionnaire_Response__c> answerList = new List<Questionnaire_Response__c>();
                List<Main_questionaire__c> assTempList = new List<Main_questionaire__c> ();
                Map<Id,String> asObjIdAndsObjectMap = new Map<Id,String>();
                List<IssueRequest_Life_Cycle__c> amList = new List<IssueRequest_Life_Cycle__c>();
                Datetime createdStartDate, createdEndDate, completedStartDate, completedEndDate ;
                List<String> questionIdList = new List<String>();
                
                String assTempQuery  = 'SELECT Id, Name';
                assTempQuery += ' FROM ExAM__Main_questionaire__c';
                
                if(assTempId != null && assTempId != '' ) {
                    assTempQuery +=' WHERE Id = :assTempId LIMIT 1';
                }
                
                assTempList = database.query(assTempQuery);
                
                SFDCAccessController accessForobj = ExAMUtilClass.AccessController;
                List<string> configfieldsList = new List<string>{'ExAM__Add_Response_Score__c'};
                accessForobj.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__ExAM_Configuration__c'), configfieldsList);
                List<ExAM_Configuration__c> examConfigList = [SELECT Id, Add_Response_Score__c FROM ExAM_Configuration__c LIMIT 1];
                List<String> fieldsList = new List<String>{'ExAM__InvestigationType__c'};
                accessForobj.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__IssueRequest_Life_Cycle__c'), fieldsList);
                    
                String amQuery = 'SELECT Id, ExAM__InvestigationType__c';
                
                if( assessibleFieldArray != null && assessibleFieldArray.size() > 0 ){
                    for( String aObj :assessibleFieldArray){
                        amQuery += ', '+aObj;
                    }
                }
                
                amQuery += ' FROM ExAM__IssueRequest_Life_Cycle__c';
                amQuery += ' WHERE ExAM__InvestigationType__c = :assTempId';            
                amList = Database.query(amQuery);
                
                
                if( startCreatedDate != null && startCreatedDate != '' && startCreatedDate.split('/').size() == 3){
                    String[] dateStr = startCreatedDate.split('/');
                    createdStartDate = dateTime.newinstance( Integer.valueOf(dateStr[2]), Integer.valueOf(dateStr[0]), Integer.valueOf(dateStr[1]) );
                } 
                
                if( endCreatedDate != null && endCreatedDate != '' && endCreatedDate.split('/').size() == 3 ){
                    String[] dateStr2 = endCreatedDate.split('/');
                    createdEndDate = date.newinstance( Integer.valueOf(dateStr2[2]), Integer.valueOf(dateStr2[0]), Integer.valueOf(dateStr2[1]) );
                    createdEndDate = createdEndDate.addDays(1);
                } 
                
                if( startCompletedDate != null && startCompletedDate != '' && startCompletedDate.split('/').size() == 3){
                    string[] dateStr1 = startCompletedDate.split('/');
                    completedStartDate = dateTime.newinstance( Integer.valueOf(dateStr1[2]), Integer.valueOf(dateStr1[0]), Integer.valueOf(dateStr1[1]) );
                } 
                
                if( endCompletedDate != null && endCompletedDate != '' && endCompletedDate.split('/').size() == 3 ){
                    string[] dateStr3 = endCompletedDate.split('/');
                    completedEndDate = date.newinstance( Integer.valueOf(dateStr3[2]), Integer.valueOf(dateStr3[0]), Integer.valueOf(dateStr3[1]) );
                    completedEndDate = completedEndDate.addDays(1);
                }
                if( amList != null && amList.size() > 0 ){
                    for(IssueRequest_Life_Cycle__c am :amList){
                        for( String aObj :assessibleFieldArray){
                            if( am.get(aObj)!= null ){
                                String objName = ''; 
                                if( aObj.equalsIgnoreCase('ExAM__Facility_Name__c')){
                                    objName = 'Account';
                                } else{
                                    objName = aObj.replace('AM_','');
                                    objName = objName.replace('__c','');
                                }
                                String idObjNameStr = am.get(aObj)+'~'+objName;
                                asObjIdAndsObjectMap.put(am.Id,idObjNameStr);
                            }
                        }
                    }
                }
                if (assTempList != null && assTempList.size() > 0) {
                    // SFDCAccessController accessForobj = ExAMUtilClass.AccessController;
                    List<String> fieldsList1 = new List<String>{'ExAM__Issue_Request__c', 'ExAM__Question_Template__c','ExAM__Total_Score__c','ExAM__Response__c'};
                    accessForobj.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Questionnaire_Response__c'), fieldsList1);
                    
                    List<String> fieldsList2 = new List<String>{'ExAM__Status__c', 'ExAM__Total_Score__c','ExAM__Date_Completed__c'};
                    accessForobj.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__IssueRequest_Life_Cycle__c'), fieldsList2);
                    
                    List<String> fieldsList3 = new List<String>{'ExAM__Section_Question__c', 'ExAM__Question_Label__c','ExAM__Question_Short_Name__c'};
                    accessForobj.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Question_Template__c'), fieldsList3);
                    
                    List<String> fieldsList4 = new List<String>{'ExAM__Questionnaire_Section__c'};
                    accessForobj.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Section_Template__c'), fieldsList4);
                    
                    String answerQuery = 'SELECT ExAM__Issue_Request__c, ID, Name, ExAM__Question_Template__r.ExAM__Section_Question__r.ExAM__Questionnaire_Section__c, ';
                    answerQuery += 'CreatedDate, ExAM__Issue_Request__r.ExAM__Status__c, ExAM__Question_Template__c,ExAM__Question_Template__r.ExAM__Question_Label__c, ExAM__Total_Score__c, ExAM__Question_Template__r.ExAM__Question_Short_Name__c, ';
                    answerQuery += 'ExAM__Response__c,ExAM__Issue_Request__r.ExAM__Total_Score__c, ExAM__Issue_Request__r.CreatedDate, ExAM__Issue_Request__r.LastModifiedDate, ExAM__Issue_Request__r.ExAM__Date_Completed__c';
                    answerQuery += ' FROM ExAM__Questionnaire_Response__c';
                    answerQuery += ' WHERE  ExAM__Issue_Request__c != null AND ExAM__Issue_Request__r.ExAM__InvestigationType__c != null ';
                    
                    if( createdStartDate != null && createdEndDate != null ){
                        answerQuery += ' AND CreatedDate >= :createdStartDate  AND CreatedDate <= :createdEndDate ';
                    }
                    if( completedStartDate != null && completedEndDate != null ){
                        answerQuery += ' AND ExAM__Issue_Request__r.ExAM__Date_Completed__c >= :completedStartDate  AND ExAM__Issue_Request__r.ExAM__Date_Completed__c <= :completedEndDate ';
                    }
                    answerQuery += ' AND ExAM__Issue_Request__r.ExAM__InvestigationType__c = :assTempId ORDER BY LastModifiedDate ASC';
                    answerList = Database.query(answerQuery);
                    if( answerList != null && answerList.size() > 0 ){
                        answerObjList = new List<answerClass>();
                        for( Questionnaire_Response__c ans :answerList){
                            answerClass ansObj = new answerClass();
                            ansObj.assignmentManagerId = ans.Issue_Request__c;
                            ansObj.assessmentTemplateId = ans.Question_Template__r.Section_Question__r.Questionnaire_Section__c;
                            ansObj.assessmentCompletedDate = (ans.Issue_Request__r.Date_Completed__c != null) ? String.valueOf(Date.valueOf(ans.Issue_Request__r.Date_Completed__c).format()) : '';
                            ansObj.assmgrCreatedDate = String.valueOf(Date.valueOf(ans.Issue_Request__r.CreatedDate).format());
                            ansObj.assmgrLastModifiedDate = String.valueOf(Date.valueOf(ans.Issue_Request__r.LastModifiedDate).format());
                            String assIdNameStr = asObjIdAndsObjectMap.get(ans.Issue_Request__c);
                            String []assObj = assIdNameStr.split('~');
                            ansObj.assessibleObjectId = assObj[0];
                            ansObj.assessibleObjectName = assObj[1];
                            ansObj.status = ans.Issue_Request__r.Status__c;
                            if ( ans.Question_Template__r.Question_Short_Name__c != null && 
                                ans.Question_Template__r.Question_Short_Name__c != '' ){
                                String replacedQuesShortName = ans.Question_Template__r.Question_Short_Name__c.replaceAll('\\<.*?\\>','');
                                ansObj.questionShortName = replacedQuesShortName.escapeCsv();
                            } else {
                                ansObj.questionShortName = ans.Question_Template__r.Question_Short_Name__c;
                            }
                            if ( ans.Question_Template__r.Question_Label__c != null && 
                                ans.Question_Template__r.Question_Label__c != '' ){
                                String replacedQuesLabel = ans.Question_Template__r.Question_Label__c.replaceAll('\\<.*?\\>','');
                                ansObj.questionLabel = replacedQuesLabel.escapeCsv();
                            } else {
                                ansObj.questionLabel = ans.Question_Template__r.Question_Label__c;
                            }
                            ansObj.questionId = ans.Question_Template__c;
                            if ( ans.Response__c != null ){
                                String replacedResponse = ans.Response__c.replaceAll('\\<.*?\\>','');
                                ansObj.response = replacedResponse.escapeCsv();
                            } else {
                                ansObj.response = ans.Response__c;
                            }
                            ansObj.score = ans.Total_Score__c;
                            ansObj.totalScore = ans.Issue_Request__r.Total_Score__c;
                            answerObjList.add(ansObj);
                        }
                    }
                    
                      //permision for this query checked  above   
                    for( Question_Template__c quesObj :[SELECT Id, Question_Label__c, Question_Short_Name__c FROM Question_Template__c WHERE Section_Question__r.Questionnaire_Section__c = :assTempId]){
                        if( !questionLabelList.contains(quesObj.Question_Short_Name__c) && !questionLabelList.contains(quesObj.Question_Label__c) ){
                            questionIdList .add(quesObj.Id);
                            if( examConfigList[0].Add_Response_Score__c ){
                                String quesIdStr = quesObj.Id+'-Score';
                                questionIdList.add(quesIdStr);
                            }
                            if ( quesObj.Question_Short_Name__c != null && quesObj.Question_Short_Name__c != '' ){                            
                                String regExpRemovedQuesShortName = quesObj.Question_Short_Name__c.replaceAll('\\<.*?\\>','');
                                String escapedQuesShortName = regExpRemovedQuesShortName.escapeCsv();
                                questionLabelList.add(escapedQuesShortName);
                                if( examConfigList[0].Add_Response_Score__c ){
                                    escapedQuesShortName = regExpRemovedQuesShortName+'-Score';
                                    questionLabelList.add(escapedQuesShortName.escapeCsv());
                                }
                                
                            } else if ( quesObj.Question_Label__c != null && quesObj.Question_Label__c != '' ){                            
                                String regExpRemovedQues = quesObj.Question_Label__c.replaceAll('\\<.*?\\>','');
                                String escapedQues = regExpRemovedQues.escapeCsv();
                                questionLabelList.add(escapedQues);
                                if( examConfigList[0].Add_Response_Score__c ){
                                    escapedQues = regExpRemovedQues+'-Score';
                                    questionLabelList.add(escapedQues.escapeCsv());
                                }
                                
                            } else {
                                questionLabelList.add(quesObj.Id);
                                if( examConfigList[0].Add_Response_Score__c ){
                                    String quesLabel = quesObj.Id+'-Score';
                                    questionLabelList.add(quesLabel.escapeCsv());
                                }
                            }
                        }
                    }
                    
                }
                if( questionLabelList != null && questionLabelList.size() > 0 && answerList != null ){
                    WrapperClass wc = new WrapperClass();
                    wc.quesList = questionLabelList;
                    wc.quesIdList = questionIdList;
                    wc.ansList = answerObjList;
                    wc.status = 'OK';
                    wc.ansLength = answerList.size();
                    wc.length = questionLabelList.size();
                    wc.addResScore = examConfigList[0].Add_Response_Score__c;
                    return wc;
                } else {
                    WrapperClass wcWithNull = new WrapperClass();
                    wcWithNull.status = 'FAIL';
                    wcWithNull.ansList = null;
                    wcWithNull.quesList = null;
                    wcWithNull.quesIdList = null;
                    if( questionLabelList != null ){
                        wcWithNull.length = questionLabelList.size();
                    } else {
                        wcWithNull.length = 0;
                    }
                    return wcWithNull;
                }
            }
            return null;
        }catch(Exception e){
            WrapperClass wrpcls = new WrapperClass();
            wrpcls.status = 'Exception -'+e.getmessage();
            return wrpcls;
        }
    }
    public class answerClass {
        public Id assignmentManagerId;
        public Id assessmentTemplateId;
        public String assessmentCompletedDate;
        public String assmgrCreatedDate;
        public String assmgrLastModifiedDate;
        public String assessibleObjectId;
        public String assessibleObjectName;
        public String status;
        public String questionLabel;
        public String questionShortName;
        public Id questionId;
        public String response;
        public Decimal score;
        public Decimal totalScore;
    }
    public class WrapperClass {
        public Set<String> quesList;
        public List<String> quesIdList;
        public List<answerClass> ansList;
        public String status;
        public Integer length;
        public Integer ansLength;
        public Boolean addResScore;
    }
}