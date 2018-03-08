@isTest 
private class TestRestGetAttachmentBlob {
    static testMethod void method1() {
        IssueRequest_Life_Cycle__c am = new IssueRequest_Life_Cycle__c();
        insert am;
        
        Blob b = Blob.valueOf('Test Data');  
        Attachment attachment = new Attachment();  
        attachment.ParentId = am.Id;  
        attachment.Name = 'Test Attachment for Parent';  
        attachment.Body = b;  
        insert attachment;  
        
        Test.startTest();
            String returnValue = RestGetAttachmentBlob.getAttachmentBlob1(attachment.Id);
            system.assert(returnValue != null);
        Test.stopTest();
        
    }

}