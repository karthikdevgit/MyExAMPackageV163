public with sharing class AttachmentService {
    public static String sObjectName = 'Attachment';
    public static String fields;
    
    public static List<Attachment> getAttachmentsByParentId(String parentId){
        
        try{
            fields = 'Name, ContentType';
            FieldLevelSecurity.checkFieldAccessByCriteria(fields, 'view', sObjectName);
            //check if any error in view review the code
            List<Attachment> attachments = [SELECT Id, Name, ContentType FROM Attachment WHERE ParentId = :parentId ORDER BY Name];
            return attachments;
        }
        catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
        
    }
    
    // get Question image 
    public static List<Attachment> getAttachmentsByQuestionIds(Set<Id> parentIds){
        
        try{
            fields = 'Name, ContentType';
            FieldLevelSecurity.checkFieldAccessByCriteria(fields, 'view', sObjectName);
            //check if any error in view review the code
            List<Attachment> attachments = [SELECT Id, Name, Body, ParentId, ContentType FROM Attachment WHERE ParentId IN :parentIds AND Name = 'Question-Image'];
            return attachments;
        }
        catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
        
    }
    
    public static Attachment saveAttachment(String attachmentId, String parentId, String fileName, String base64Data, String contentType){
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
        
        Attachment attachment = new Attachment();
        List<Attachment> attachments = new List<Attachment>();
        
        // already Attachment there ! 
        //we delete attachment 
        //becz update attachment does not reflect in view issue in lightning components
        
        if(attachmentId != NULL){     					
            
            List<Attachment> attachList = new List<Attachment>();
            attachList = [Select Id from Attachment where Id = :attachmentId];
            
            
            if(!attachList.isEmpty()) {
                
                try{
                    FieldLevelSecurity.checkObjectAccessByDelete(sObjectName);
                    delete attachList;
                }
                catch(Exception e){
                    throw new AuraHandledException(e.getMessage());
                }
                
            }
        }
        
        attachment.ParentId = parentId;
        attachment.Body = EncodingUtil.base64Decode(base64Data);
        attachment.Name = fileName;
        attachment.ContentType = contentType;
        attachments.add(attachment);
        attachments = createAttachments(attachments);
        return attachments[0];
    }
    
    public static List<Attachment> cloneAttachment(Map<String,Answer_Option__c> answerOldIdWthNewAnswer){
        Set<String> answerOldIds = answerOldIdWthNewAnswer.keySet();
        
        List<Attachment> attachments = getAttachmentsByParentIds(answerOldIds);
        
        List<Attachment> copyAttachment = new List<Attachment>();
        
        for(Attachment attach : attachments){
            String parentId = attach.ParentId;
            String newParentId = answerOldIdWthNewAnswer.get(parentId).Id;
            Attachment attachment = new Attachment(Name = attach.Name, ParentId = newParentId, Body = attach.Body, ContentType = attach.ContentType);
            copyAttachment.add(attachment);
        }
        
        
        copyAttachment = createAttachments(copyAttachment);
        return removeAttachmentBody(copyAttachment);
    }
    public static List<Attachment> cloneAttachmentByAssessment(Map<String,Main_questionaire__c> assessmentOldIdWthAssessment){
        Set<String> assessmentOldIds = assessmentOldIdWthAssessment.keySet();
        List<Attachment> attachments = getAttachmentsByParentIds(assessmentOldIds);
        List<Attachment> copyAttachment = new List<Attachment>();
        
        for(Attachment attach : attachments){
            
            if(attach.Name == 'userLogo'){
                String parentId = attach.ParentId;
                String newParentId = assessmentOldIdWthAssessment.get(parentId).Id;
                Attachment attachment = new Attachment(Name = attach.Name, ParentId = newParentId, Body = attach.Body, ContentType = attach.ContentType);
                copyAttachment.add(attachment);
            }
            
        }
        
        
        copyAttachment = createAttachments(copyAttachment);
        return removeAttachmentBody(copyAttachment);
    }
    
    public static List<Attachment> cloneAttachmentByQuestionIds(Map<String,String> OldIdWthNewId){
        Set<String> oldIds = OldIdWthNewId.keySet();
        
        List<Attachment> attachments = getAttachmentsByParentIds(oldIds);
        
        List<Attachment> copyAttachment = new List<Attachment>();
        
        for(Attachment attach : attachments){
            if(attach.Name != 'Question-Image'){ // add if condition 
                String parentId = attach.ParentId;
                String newParentId = OldIdWthNewId.get(parentId);
                Attachment attachment = new Attachment(Name = attach.Name, ParentId = newParentId, Body = attach.Body, ContentType = attach.ContentType);
                copyAttachment.add(attachment);
            }
        }
        
        
        copyAttachment = createAttachments(copyAttachment);
        return removeAttachmentBody(copyAttachment);
    }
    
    
    public static List<AssessmentTemplateController.WrapperAttachment> getAttachmentById(String sObjectId){
        List<AssessmentTemplateController.WrapperAttachment> attchment = new List<AssessmentTemplateController.WrapperAttachment>();
        List<Attachment> attachments;
        
        try{
            String fields = 'Name, ContentType';
            FieldLevelSecurity.checkFieldAccessByCriteria(fields, 'view', 'Attachment');
            attachments = [SELECT Id, Name, ContentType FROM Attachment WHERE ParentId = :sObjectId];
        }
        catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
        
        if(!attachments.isEmpty()){
            for(Attachment attch : attachments){
                if(attch.Name == 'userLogo'){
                    attchment.add(new AssessmentTemplateController.WrapperAttachment(attch.Name, attch.Id, attch.ContentType));
                }
            }
            
        }
        
        return attchment;
        
    }
    
    public static string saveFile(String parentId, String fileName, String base64Data, String contentType) {
        
        Map<String,Object> containWrapObject = new Map<String,Object>();
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
        Attachment attachment = new Attachment();
        List<Attachment> attachmentList = new List<Attachment>();
        List<Attachment> attachments;
        
        try{
            fields = 'Name,ParentId';
            FieldLevelSecurity.checkFieldAccessByCriteria(fields, 'view', sObjectName);
            attachments = [SELECT Id, Name, Body, ParentId FROM Attachment WHERE ParentId = :parentId and Name = :fileName];
        }
        catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
        
        
        if(!attachments.isEmpty()){
            
            attachments[0].Body = EncodingUtil.base64Decode(base64Data);
            attachments[0].ContentType = contentType;
            attachmentList.add(attachments[0]);
            attachmentList = updateAttachments(attachmentList);
            
        }else{
            attachment.ParentId = parentId;
            attachment.Body = EncodingUtil.base64Decode(base64Data);
            attachment.Name = fileName;
            attachment.ContentType = contentType;
            attachmentList.add(attachment);
            attachmentList = createAttachments(attachmentList);
        }
        
        List<WrapperAttachment> wrapperAttach = getAttachmentDetails(attachmentList[0].Name,attachmentList[0].Id, attachmentList[0].ContentType, attachmentList[0].ParentId);
        containWrapObject.put('attachment',wrapperAttach);
        return JSON.serialize(containWrapObject);
    }
    
    
    public static List<WrapperAttachment> getAttachmentDetails(String Name, String Id, String ContentType, String ParentId){
        List<WrapperAttachment> attachment = new List<WrapperAttachment>();
        attachment.add(new WrapperAttachment(Name, Id, ContentType, ParentId));
        return attachment;
    }
    
    public class WrapperAttachment{
        @AuraEnabled
        public String Name;
        @AuraEnabled
        public String Id;
        @AuraEnabled
        public String ContentType;
        @AuraEnabled
        public String ParentId;
        
        public WrapperAttachment(String Name, String Id, String ContentType, String ParentId){
            this.Name = Name;
            this.Id = Id;
            this.ContentType = ContentType;
            this.ParentId = ParentId;
        }
        
    }
    
    public static List<Attachment> copyAttachments(Map<String,Answer_Option__c> cloneAnswerOptions){
        
        Set<String> answerOldIds = cloneAnswerOptions.keySet();
        List<Attachment> attachments = getAttachmentsByParentIds(answerOldIds);
        List<Attachment> copyAttachment = new List<Attachment>();
        
        for(Attachment attach : attachments){
            String parentId = attach.ParentId;
            String newParentId = cloneAnswerOptions.get(parentId).Id;
            Attachment attachment = new Attachment(Name = attach.Name, ParentId = newParentId, Body = attach.Body, ContentType = attach.ContentType);
            copyAttachment.add(attachment);
        }
        
        
        copyAttachment = createAttachments(copyAttachment);
        
        
        return removeAttachmentBody(copyAttachment);
    }
    
    public static List<Attachment> copyAttachmentsByQuesId(Map<String,String> questionOldIdWthNewId){
        
        Set<String> questionOldIds = questionOldIdWthNewId.keySet();
        List<Attachment> attachments = getAttachmentsByParentIds(questionOldIds);
        List<Attachment> copyAttachment = new List<Attachment>();
        
        for(Attachment attach : attachments){
            if(attach.Name != 'Question-Image'){
                String parentId = attach.ParentId;
                Attachment attachment = attach.clone(false,true,false,false);
                attachment.ParentId = questionOldIdWthNewId.get(parentId);
                copyAttachment.add(attachment);
            }
        }
        
        
        
        if(!copyAttachment.isEmpty()){
            copyAttachment = createAttachments(copyAttachment);
        }
        
        return removeAttachmentBody(copyAttachment);
    }
    
    public static List<Attachment> copyQuestionImage(Map<String,String> questionOldIdWthNewId){
        
        Set<Id> questionOldIds = (Set<Id>)JSON.deserialize(JSON.serialize(questionOldIdWthNewId.keySet()), Set<Id>.class) ;
        List<Attachment> attachments = getAttachmentsByQuestionIds(questionOldIds);
        List<Attachment> copyAttachment = new List<Attachment>();
        
        for(Attachment attach : attachments){
            String parentId = attach.ParentId;
            Attachment attachment = attach.clone(false,true,false,false);
            attachment.ParentId = questionOldIdWthNewId.get(parentId);
            copyAttachment.add(attachment);
        }
        
        
        
        if(!copyAttachment.isEmpty()){
            copyAttachment = createAttachments(copyAttachment);
        }
        
        return removeAttachmentBody(copyAttachment);
    }
    
    public static List<Attachment> getAttachmentsByParentIds(Set<String> parentIds){
        
        try{
            fields = 'Name,ContentType,ParentId,Body';
            FieldLevelSecurity.checkFieldAccessByCriteria(fields, 'view', sObjectName);
            List<Attachment> attachments = [SELECT Id, Name, ContentType, ParentId, Body FROM Attachment WHERE ParentId IN :parentIds];
            return attachments;
        }
        catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
        
    }
    
    public static List<Attachment> createAttachments(List<Attachment> attachments){
        
        try{
            fields = 'Name,ContentType,ParentId,Body';
            FieldLevelSecurity.checkFieldAccessByCriteria(fields, 'create', sObjectName);
            insert attachments;
            return attachments;
        }
        catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
        
    }
    public static List<Attachment> updateAttachments(List<Attachment> attachments){
        
        try{
            fields = 'Body,ContentType';
            FieldLevelSecurity.checkFieldAccessByCriteria(fields, 'update', sObjectName);
            update attachments;
            return attachments;
        }
        catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
        
    }
    
    public static List<Attachment> removeAttachmentBody(List<Attachment> attachments){
        
        for(Attachment attach : attachments){
            attach.Body = null;
        }
        
        return attachments;
    }
    
}