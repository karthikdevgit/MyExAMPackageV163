@isTest
public class TestUploadAnswerOptionImagesController {

    static testMethod void method1() {
        
        Account acc = new Account();
        acc.Name = 'Test';
        insert acc;
        
        contact con = new contact();
        con.AccountId=acc.id;
        con.FirstName = 'testcon';
        con.LastName ='testCon';
        insert con;
        
        Main_questionaire__c assTemp = new Main_questionaire__c();
        assTemp.Account__c = acc.Id;
        assTemp.ContactOrganization__c = con.Id;
        insert assTemp;
        
        List<Section_Template__c> secTempList = new List<Section_Template__c>{
            new Section_Template__c(Questionnaire_Section__c = assTemp.Id)
        };
        insert secTempList;
        
        List<Question_Template__c> quesTemplList = new List<Question_Template__c>{
            new Question_Template__c(Section_Question__c = secTempList[0].Id,Subquestion_Label__c = 'opt1~opt2~opt3')
            
        };
        insert quesTemplList;
        
        ApexPages.currentPage().getParameters().put('quesTempId',String.valueOf(quesTemplList[0].id));
        
        Test.startTest();
            UploadAnswerOptionImagesController  upload = new UploadAnswerOptionImagesController();
            
        Test.stopTest();
        
        System.assertEquals(upload.NoOfOptions,3);
    }

}