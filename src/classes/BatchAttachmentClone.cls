public with sharing class BatchAttachmentClone implements Database.Batchable<sObject>, Database.Stateful {
    public String query;
    public Map<Id,Id> oldIdWthNewId;
    public Boolean AttachmentCloneByQuestion = false;
    Set<Id> parentIds;
    set<Id> newQuestionIds = new set<Id>();
    
    public BatchAttachmentClone(Map<Id,Id> oldIdWthNewIdByClone, Boolean CloneByQuestion){
        oldIdWthNewId = oldIdWthNewIdByClone; 
        AttachmentCloneByQuestion = CloneByQuestion;
        parentIds = oldIdWthNewId.keySet();
        query = 'SELECT Id, Name, Body, ParentId FROM Attachment WHERE ParentId IN :parentIds ORDER BY Name'; 
    }
    
    public BatchAttachmentClone(Map<Id,Id> oldIdWthNewIdByClone){
        oldIdWthNewId = oldIdWthNewIdByClone; 
        parentIds = oldIdWthNewId.keySet();
        query = 'SELECT Id, Name, Body, ParentId FROM Attachment WHERE ParentId IN :parentIds AND Name = \'Question-Image\' ORDER BY Name'; 
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        
        try{
            String fields = 'Name, Body, ParentId';
            FieldLevelSecurity.checkFieldAccessByCriteria(fields, 'view', 'Attachment');
            return Database.getQueryLocator(query);
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
        
    }
    
    public void execute(Database.BatchableContext BC, List<Attachment> attachments){
        
        List<Answer_Option__c> answerOptions;
        Map<Id,List<Answer_Option__c>> newQuestionIdWthAnswerOptions;
        
        // clone By Question 
        if(AttachmentCloneByQuestion){
            for(Attachment attach : attachments){
                newQuestionIds.add(oldIdWthNewId.get(attach.ParentId)); // get new QuestionIds
            }
            // get AnswerOptions by NewQuestionIds 
            try{
                String fields = 'Name, Question_Template__c, Order_No__c';
                FieldLevelSecurity.checkFieldAccessByCriteria(fields, 'view', 'Answer_Option__c');
                answerOptions = [SELECT Id, Name, Question_Template__c, Order_No__c FROM Answer_Option__c WHERE Question_Template__c IN :newQuestionIds ORDER BY Order_No__c]; 
            }catch(Exception e){
                throw new AuraHandledException(e.getMessage());
            }
            
            // Initialize the map 
            newQuestionIdWthAnswerOptions = new Map<Id,List<Answer_Option__c>>();
            for(Answer_Option__c answer : answerOptions){
                if(!newQuestionIdWthAnswerOptions.containsKey(answer.Question_Template__c)){ // map contains newQuestionId
                    newQuestionIdWthAnswerOptions.put(answer.Question_Template__c, new List<Answer_Option__c>{answer}); // if not contains put map value
                }else{
                    newQuestionIdWthAnswerOptions.get(answer.Question_Template__c).add(answer); // if contains add value in list 
                }
            }
        }
        
        List<Attachment> copyAttachment = new List<Attachment>();
        
        for(Integer i = 0; i < attachments.size(); i++){
            String parentId = attachments[i].ParentId; // get Attachment ParentId
            Attachment attachment = attachments[i].clone(false,true,false,false);
            // clone by Question 
            if(AttachmentCloneByQuestion){
                Id questionId = oldIdWthNewId.get(parentId); // get new QuestionId
                
                for(Answer_Option__c answerOpt : newQuestionIdWthAnswerOptions.get(questionId)){
                    String titles = attachments[i].Name.substringBefore('.'); // get titles
                    
                    if(answerOpt.Order_No__c == Integer.valueOf(titles) ){
                        attachment.ParentId = answerOpt.Id;
                        break;
                    }
                    
                }
            }else{			// clone by AnswerOptions 
                attachment.ParentId = oldIdWthNewId.get(parentId);
            }
            
            copyAttachment.add(attachment);
        }
        
        if(!copyAttachment.isEmpty()){
            try{
                String fields = 'Name, Body, ParentId';
                FieldLevelSecurity.checkFieldAccessByCriteria(fields, 'create', 'Attachment');
                insert copyAttachment;
            }catch(Exception e){
                throw new AuraHandledException(e.getMessage());
            }
            
        }
        
    }
    
    public void finish(Database.BatchableContext BC){
       
        AsyncApexJob apexJob = [Select Id, Status, ExtendedStatus, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email from AsyncApexJob where Id =:BC.getJobId()];
    	Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {apexJob.CreatedBy.Email};
        mail.setToAddresses(toAddresses);
        mail.setSubject('Match Merge Batch ' + apexJob.Status);
        mail.setPlainTextBody('records processed ' + apexJob.TotalJobItems + ' with ' + apexJob.NumberOfErrors + ' failures.');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
    
}