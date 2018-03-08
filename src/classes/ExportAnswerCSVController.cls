public with sharing class ExportAnswerCSVController {
    public List<Main_questionaire__c> assTempList {get;set;}
    public String assessmentTemplateJSON {get;set;}    
    public String answerRecords { get; set; }
    public List<Schema.FieldSetMember> answerObjFieldsList;
    public String answerFields;
    
    public class ErrorClass {
        public string errType{get; set;}
        public string errMsg{get; set;}

        public ErrorClass(string etype, string eMsg) {

            this.errType = etype;
            this.errMsg = eMsg; 
        }
    }
    
    public ExportAnswerCSVController() {
    
        String assTempQuery;
        String ansQuery; 
        DateTime createdStartDate, createdEndDate;
        assTempList = new List<Main_questionaire__c>();
        
        Id assTempId = ApexPages.currentPage().getParameters().get('asTempId');
        String startCreatedDate = ApexPages.currentPage().getParameters().get('startCreatedDate');
        String endCreatedDate = ApexPages.currentPage().getParameters().get('endCreatedDate');
        
        answerRecords = '';
        try{
            if (assTempId == null) {
                assessmentTemplateJSON = '';
                
                SFDCAccessController accessForobj = ExAMUtilClass.AccessController;
                List<String> fieldsList = new List<String>{'ExAM__PublishPlace__c','ExAM__Template_name__c'};
                accessForobj.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Main_questionaire__c'), fieldsList);
                
                List<Main_questionaire__c> templateList = [SELECT Id,Name,PublishPlace__c, Template_name__c
                                          FROM Main_questionaire__c ORDER BY CreatedDate DESC Limit 10000];
                if (templateList != null && templateList.size() > 0) {
                    assessmentTemplateJSON = JSON.serialize(templateList);
                }
            }  
        } catch (Exception e){
            assessmentTemplateJSON = JSON.serialize(new ErrorClass('Error',e.getMessage()));
        }
    }
    
    @RemoteAction
    public static string exportAnswers(String startCreatedDate, String endCreatedDate, String assTempId, String startCompletedDate, String endCompletedDate ) {
    
        try{
        String resultMsg = 'No Assessment Template';
        if (assTempId != null || startCreatedDate != null || endCreatedDate != null ) {
            String assTempQuery  = 'SELECT Id, Name';
            Datetime createdStartDate, createdEndDate, completedStartDate, completedEndDate ;
            List<Main_questionaire__c> assTempList = new List<Main_questionaire__c> ();
            assTempQuery += ' FROM Main_questionaire__c';
            
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
                String[] dateStr1 = startCompletedDate.split('/');
                completedStartDate = dateTime.newinstance( Integer.valueOf(dateStr1[2]), Integer.valueOf(dateStr1[0]), Integer.valueOf(dateStr1[1]) );
            } 
            
            if( endCompletedDate != null && endCompletedDate != '' && endCompletedDate.split('/').size() == 3 ){
                String[] dateStr3 = endCompletedDate.split('/');
                completedEndDate = date.newinstance( Integer.valueOf(dateStr3[2]), Integer.valueOf(dateStr3[0]), Integer.valueOf(dateStr3[1]) );
                completedEndDate = completedEndDate.addDays(1);
            }
            
            if(createdStartDate != null && createdEndDate != null ) {
                assTempQuery +=' WHERE CreatedDate >= :createdStartDate  AND CreatedDate <= :createdEndDate'; 
            } else if(assTempId != null) {
                assTempQuery +=' WHERE Id = :assTempId';
            }
            System.debug('assTempQuery::::::::::::::::'+assTempQuery);
            
            assTempList = database.query(assTempQuery);
            
            
            if (assTempList != null && assTempList.size() > 0) {
                Map<Id, Main_questionaire__c> assTempIdWithRecordMap = new Map<Id, Main_questionaire__c>();
                assTempIdWithRecordMap.putAll(assTempList);
                if (assTempIdWithRecordMap != null && assTempIdWithRecordMap.size() > 0) {
                    
                    Set<Id> templateIdSet = assTempIdWithRecordMap.keySet();
                    
                    SFDCAccessController accessForobj = ExAMUtilClass.AccessController;
                    List<String> fieldsList = new List<String>{'ExAM__Issue_Request__c','ExAM__Question_Template__c','ExAM__Response__c','ExAM__Total_Score__c'};
                    accessForobj.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Questionnaire_Response__c'), fieldsList);
                    
                    List<String> fieldsList1 = new List<String>{'ExAM__Status__c','ExAM__Date_Completed__c'};
                    accessForobj.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__IssueRequest_Life_Cycle__c'), fieldsList1);
                    
                    List<String> fieldsList2 = new List<String>{'ExAM__Question_Label__c','ExAM__Section_Question__c','ExAM__Question_Short_Name__c'};
                    accessForobj.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Question_Template__c'), fieldsList2);
                    
                    List<String> fieldsList3 = new List<String>{'ExAM__Questionnaire_Section__c'};
                    accessForobj.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Section_Template__c'), fieldsList3);
                    
                    String answerQuery = 'SELECT ExAM__Issue_Request__c, ID, Name, ExAM__Question_Template__r.ExAM__Section_Question__r.ExAM__Questionnaire_Section__c, ';
                    answerQuery += 'CreatedDate, ExAM__Issue_Request__r.ExAM__Status__c, ExAM__Question_Template__c, ExAM__Question_Template__r.ExAM__Question_Label__c, ExAM__Response__c,ExAM__Total_Score__c, ';
                    answerQuery += 'ExAM__Question_Template__r.ExAM__Question_Short_Name__c,ExAM__Issue_Request__r.ExAM__Date_Completed__c ';
                    answerQuery += 'FROM ExAM__Questionnaire_Response__c ';
                    answerQuery += 'WHERE ExAM__Issue_Request__c != null AND ExAM__Issue_Request__r.ExAM__InvestigationType__c != null ';
                    answerQuery += 'AND ExAM__Issue_Request__r.ExAM__InvestigationType__c IN:templateIdSet';
                    if(completedStartDate != null && completedEndDate != null){
                        answerQuery += ' AND ExAM__Issue_Request__r.ExAM__Date_Completed__c >= :completedStartDate  AND ExAM__Issue_Request__r.ExAM__Date_Completed__c <= :completedEndDate ';
                    }
                    List<Questionnaire_Response__c> responseList = Database.query(answerQuery);
                    if(responseList != null && responseList.size() > 0) {
                        for( Questionnaire_Response__c res :responseList){
                            if (res.Question_Template__r.Question_Label__c != null && res.Question_Template__r.Question_Label__c != '' ){
                                String replacedQues = res.Question_Template__r.Question_Label__c.replaceAll('\\<.*?\\>','');
                                res.Question_Template__r.Question_Label__c = replacedQues;
                            }
                            if (res.Question_Template__r.Question_Short_Name__c != null && res.Question_Template__r.Question_Short_Name__c != '' ){
                                String replacedQues = res.Question_Template__r.Question_Short_Name__c.replaceAll('\\<.*?\\>','');
                                res.Question_Template__r.Question_Short_Name__c = replacedQues;
                            }
                            if ( res.Response__c != null && res.Response__c != ''){
                                String replacedRes = res.Response__c.replaceAll('\\<.*?\\>','');
                                res.Response__c = replacedRes;
                            }
                        }
                        resultMsg = JSON.serialize(responseList);
                    } else {
                        resultMsg = 'Empty Response';
                    }
                    return resultMsg;
                    
                 }
            }
        }
        return resultMsg;
        
    }catch(Exception ex){
        return  'Exception -'+ex.getmessage();
    }
    
    }
}