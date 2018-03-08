public with sharing class ExamFieldEditorController {
    
    public static sObject updateRecord(String ObjectName, String JSONStr){
        
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        Set<String> objectKeys = gd.keySet();
        sObject sObj;
        String assessmentId;
        if(objectKeys.contains(Objectname.toLowerCase()))
        {   
            
            System.debug('JSONStr:::'+JSONStr);
            
            Type sObjectType = Type.forName(ObjectName);
            sObj = (sObject)JSON.deserialize(JSONStr, sObjectType);
            
            try{
                //FieldLevelSecurity.checkFieldAccessByCriteria(sObj, 'update', ObjectName);
                update sObj;
                if(ObjectName != 'ExAM__Main_questionaire__c'){
                    if(ObjectName == 'ExAM__Section_Template__c'){
                        FieldLevelSecurity.checkFieldAccessByCriteria('ExAM__Questionnaire_Section__c', 'view', ObjectName);
                        Section_Template__c section = [SELECT Id, Questionnaire_Section__c FROM Section_Template__c WHERE Id =:sObj.Id];
                        assessmentId = section.Questionnaire_Section__c;
                    }else if(ObjectName == 'ExAM__Question_Template__c'){
                        FieldLevelSecurity.checkFieldAccessByCriteria('ExAM__Section_Question__c', 'view', ObjectName);
                        FieldLevelSecurity.checkFieldAccessByCriteria('ExAM__Questionnaire_Section__c', 'view', 'exam__Section_Template__c');
                        Question_Template__c question = [SELECT Id, Section_Question__c, Section_Question__r.Questionnaire_Section__c  FROM Question_Template__c WHERE Id =:sObj.Id];
                        assessmentId = question.Section_Question__r.Questionnaire_Section__c;
                    }
                }

                if(assessmentId != null && assessmentId != 'undefined'){
                    AssessmentService.updateAssessmentDueToChildUpdates(assessmentId);
                }
                
            }
            catch(Exception e){
                throw new AuraHandledException(e.getMessage());
            }
            
        }
        return sObj;
    }
    
    
    /*public static sObject updateRecord(String ObjectName, String id, String fieldName, String fieldVal){
        
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        Set<String> objectKeys = gd.keySet();
        sObject sObj;
        String assessmentId;
        if(objectKeys.contains(Objectname.toLowerCase()))
        {   
            //Creating a new sObject
            sObj = Schema.getGlobalDescribe().get(ObjectName).newSObject() ;
            sObj.put('id',id);
            sObj.put(fieldName,fieldVal);
            
            try{
                FieldLevelSecurity.checkFieldAccessByCriteria(fieldName, 'update', ObjectName);
                update sObj;
                if(ObjectName != 'Main_questionaire__c'){
                    if(ObjectName == 'Section_Template__c'){
                        FieldLevelSecurity.checkFieldAccessByCriteria('Questionnaire_Section__c', 'view', ObjectName);
                        Section_Template__c section = [SELECT Id, Questionnaire_Section__c FROM Section_Template__c WHERE Id =:sObj.Id];
                        assessmentId = section.Questionnaire_Section__c;
                    }else if(ObjectName == 'Question_Template__c'){
                        FieldLevelSecurity.checkFieldAccessByCriteria('Section_Question__c', 'view', ObjectName);
                        FieldLevelSecurity.checkFieldAccessByCriteria('Questionnaire_Section__c', 'view', 'Section_Template__c');
                        Question_Template__c question = [SELECT Id, Section_Question__c, Section_Question__r.Questionnaire_Section__c  FROM Question_Template__c WHERE Id =:sObj.Id];
                        assessmentId = question.Section_Question__r.Questionnaire_Section__c;
                    }
                }
                
                if(assessmentId != null && assessmentId != 'undefined'){
                    AssessmentService.updateAssessmentDueToChildUpdates(assessmentId);
                }
            }
            catch(Exception e){
                throw new AuraHandledException(e.getMessage());
            }
            
        }
        return sObj;
    }*/
}