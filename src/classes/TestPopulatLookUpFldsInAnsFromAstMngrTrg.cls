@isTest
public class TestPopulatLookUpFldsInAnsFromAstMngrTrg {
    
    static testmethod void method1() {
        
        DateTime strTime = DateTime.Now();
        DateTime endTime = DateTime.Now().addHours(2);
        Date rightNow = Date.Today();
        
        Id loggedInUsrId = UserInfo.getUserId();
        
        Account acct = new Account(Name = 'Test Account');
        insert acct;
        
        Contact con = new Contact(AccountId = acct.Id, FirstName = 'John', LastName = 'Doe');
        insert con;
        
        Opportunity opp = new Opportunity(AccountId = acct.Id, CloseDate = rightNow.addYears(1), Name = 'Test Opp', StageName = 'Prospecting');
        insert opp;
        
        ExAM__Section_Group__c sectionGrpTestRecord = new ExAM__Section_Group__c(ExAM__Group_External_Id__c = 'Test12', ExAM__Group_Name__c = 'Test Group');
        insert sectionGrpTestRecord;
        
        ExAM__IssueRequest_Life_Cycle__c amTestRecord1 = new ExAM__IssueRequest_Life_Cycle__c();
        amTestRecord1.ExAM__Location__c = 'School';
        amTestRecord1.ExAM__Facility_Name__c = acct.Id;
        amTestRecord1.ExAM__Field_End_Time__c = endTime;
        amTestRecord1.ExAM__Field_Start_Time__c = strTime;
        amTestRecord1.ExAM__Assessor_Resource__c = loggedInUsrId;
        amTestRecord1.ExAM__Section_Group__c = sectionGrpTestRecord.Id;
        amTestRecord1.ExAM__Responder__c = loggedInUsrId;
        amTestRecord1.ExAM__Service_Organization__c = acct.Id;
        amTestRecord1.ExAM__Site_Contact__c = con.Id;
        insert amTestRecord1;
        
        ExAM__IssueRequest_Life_Cycle__c amTestRecord2 = new ExAM__IssueRequest_Life_Cycle__c();
        amTestRecord2.ExAM__Location__c = 'School';
        amTestRecord2.ExAM__Facility_Name__c = acct.Id;
        amTestRecord2.ExAM__Field_End_Time__c = endTime;
        amTestRecord2.ExAM__Field_Start_Time__c = strTime;
        amTestRecord2.ExAM__Assessor_Resource__c = loggedInUsrId;
        amTestRecord2.ExAM__Section_Group__c = sectionGrpTestRecord.Id;
        amTestRecord2.ExAM__Responder__c = loggedInUsrId;
        amTestRecord2.ExAM__Service_Organization__c = acct.Id;
        amTestRecord2.ExAM__Site_Contact__c = con.Id;
        insert amTestRecord2;
        
        ExAM__Main_questionaire__c questionaireTestRecord = new ExAM__Main_questionaire__c();
        questionaireTestRecord.ExAM__Account__c = acct.Id;
        questionaireTestRecord.ExAM__Assignment_ID_Name__c = amTestRecord1.Id;
        questionaireTestRecord.ExAM__ContactOrganization__c = con.Id;
        questionaireTestRecord.ExAM__Description__c = 'Test Main Questionaire';
        questionaireTestRecord.ExAM__User__c = loggedInUsrId;
        insert questionaireTestRecord;
        
        ExAM__Section_Template__c sectionTemplateTestRecord = new ExAM__Section_Template__c(ExAM__Questionnaire_Section__c = questionaireTestRecord.Id);
        insert sectionTemplateTestRecord;
        
        ExAM__Question_Template__c questionTempalateTestRecord = new ExAM__Question_Template__c();
        questionTempalateTestRecord.ExAM__Section_Question__c = sectionTemplateTestRecord.Id;
        questionTempalateTestRecord.ExAM__Subquestion_Label__c = 'Test';    
        insert questionTempalateTestRecord;
        
        ExAM__Questionnaire_Response__c[] questResponseTestRecords = new ExAM__Questionnaire_Response__c[] {
            new ExAM__Questionnaire_Response__c(ExAM__Issue_Request__c = amTestRecord1.Id, ExAM__Question_Template__c = questionTempalateTestRecord.Id),
            new ExAM__Questionnaire_Response__c(ExAM__Issue_Request__c = amTestRecord1.Id, ExAM__Question_Template__c = questionTempalateTestRecord.Id),
            new ExAM__Questionnaire_Response__c(ExAM__Issue_Request__c = amTestRecord2.Id, ExAM__Question_Template__c = questionTempalateTestRecord.Id),
            new ExAM__Questionnaire_Response__c(ExAM__Issue_Request__c = amTestRecord2.Id, ExAM__Question_Template__c = questionTempalateTestRecord.Id)
        };
        insert questResponseTestRecords;
        
        Set<Id> amIdSet = new Set<Id>{amTestRecord1.Id, amTestRecord2.Id};
        
        List<ExAM__Questionnaire_Response__c> questionaireRespAfterInsert = new List<ExAM__Questionnaire_Response__c>();
        questionaireRespAfterInsert = [SELECT ExAM__Account_to_Response__c, ExAM__Issue_Request__c, ExAM__Questionnaire_Taker_user__c, ExAM__Responsible_Party__c FROM ExAM__Questionnaire_Response__c WHERE ExAM__Issue_Request__c IN :amIdSet];
        
        if(questionaireRespAfterInsert != NULL && questionaireRespAfterInsert.size() > 0) {
            System.assertEquals(1, 1);
            
            questResponseTestRecords[0].ExAM__Issue_Request__c = amTestRecord2.Id;
            update questResponseTestRecords[0];
        }
    }
}