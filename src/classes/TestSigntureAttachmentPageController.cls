@isTest
public class TestSigntureAttachmentPageController {

    static testMethod void method1(){

        List<Account> accList = new List<Account>{
            new Account(Name = 'account1')
        };
        insert accList;    

        List<IssueRequest_Life_Cycle__c> managerList = new List<IssueRequest_Life_Cycle__c> {
            new IssueRequest_Life_Cycle__c(Facility_Name__c = accList[0].Id)
        };
        insert managerList;    

        List<Attachment> attList = new List<Attachment>{
            new Attachment(Name = 'Signature1', Body = Blob.valueOf('test'), ParentId = managerList[0].Id)
        };
        insert attList;    
        
        String asMId = String.valueOf(managerList[0].Id);
        String getterString = SigntureAttachmentPageController.attachmentGetter(asMId);

        System.assert(getterString.contains(attList[0].Name));
        
        String deleteString = SigntureAttachmentPageController.attachmentDeleter(attList);
        System.assertEquals('Deleted', deleteString);
    }
}