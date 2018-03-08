public with sharing class AssessmentService {
    
    public static String sObjectName = 'Main_questionaire__c';
    
    
    public static List<Main_questionaire__c> getAssessmentsByCurrentUser(String selectView){
        
        try{            
            String fields = 'Template_name__c, isArchive__c';
            FieldLevelSecurity.checkFieldAccessByCriteria(fields, 'view', sObjectName); 
            String query_str = 'SELECT Id, Template_name__c, CreatedDate, LastModifiedDate, isArchive__c FROM Main_questionaire__c WHERE isArchive__c = false';
            
            if(selectView == 'Current_User'){
                query_str += ' AND OwnerId = \''+UserInfo.getUserId()+'\'';
            }
            
            query_str += ' ORDER BY LastModifiedDate DESC';
            List<Main_questionaire__c> assessmentTemp = Database.query(query_str);
            
            return assessmentTemp;
        }
        
        catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
        
    }
    
    public static Main_questionaire__c archieveAssessment(Main_questionaire__c selAssessment){
        List<Main_questionaire__c> assessmentsTemplates = new List<Main_questionaire__c>();
        assessmentsTemplates.add(selAssessment);
        
        try{
            String fields = 'isArchive__c';
            FieldLevelSecurity.checkFieldAccessByCriteria(fields, 'update', sObjectName); 
            
            update assessmentsTemplates;    
        }
        
        catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
        
        return assessmentsTemplates[0];
    }
    
    public static Main_questionaire__c createNewAssessment(Main_questionaire__c assessmentTemp, String selectView){
        List<Main_questionaire__c> assessmentTemplates = new List<Main_questionaire__c>();
        assessmentTemplates.add(assessmentTemp);
        
        try{
            String fields = 'Template_name__c';
            FieldLevelSecurity.checkFieldAccessByCriteria(fields, 'create', sObjectName);
            insert assessmentTemplates;
        }
        
        catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
        
        assessmentTemplates = getAssessmentsByCurrentUser(selectView);
        return assessmentTemplates[0];
    }
    
    public static void updateAssessmentDueToChildUpdates(String assessmentId){
        try{
            Main_questionaire__c assessmentTemplate = new Main_questionaire__c();
            assessmentTemplate.Id = assessmentId;
            update assessmentTemplate;
        }
        catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
}