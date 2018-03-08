@isTest

public class TestRestSaveDecisionTreeAnswerRecords {

    static testmethod void method(){
        
        List<Questionnaire_Response__c> decisionTreeAnsList = new List<Questionnaire_Response__c>();
        Account acc = new Account();
        acc.Name = 'Accname';
        insert acc;
        
        Main_questionaire__c temp = new Main_questionaire__c();//Template creation
        temp.Template_name__c = 'Template1';
        insert temp;
        
         IssueRequest_Life_Cycle__c assM = new IssueRequest_Life_Cycle__c();//AssignmentManager creation
        assM.InvestigationType__c = temp.Id;
        assM.Facility_Name__c = acc.Id;
        insert assM;
        IssueRequest_Life_Cycle__c assM1 = new IssueRequest_Life_Cycle__c();//AssignmentManager creation
        assM1.InvestigationType__c = temp.Id;
        assM1.Facility_Name__c = acc.Id;
        insert assM1;
        
        Section_Template__c sec = new Section_Template__c();
        sec.Questionnaire_Section__c = temp.Id;
        insert sec;
        
        Question_Template__c q1 = new Question_Template__c();
        q1.Question_Type__c = 'RadioPicklist';
        q1.Do_Not_Create_Answer__c = True;
        q1.Section_Question__c = sec.Id;
        insert q1;
        Question_Template__c q2 = new Question_Template__c();
        q2.Question_Type__c = 'RadioPicklist';
        q2.Section_Question__c = sec.Id;
        insert q2;

        Questionnaire_Response__c qr1 = new Questionnaire_Response__c();
        qr1.Question_Template__c = q1.Id;
        qr1.Issue_Request__c = assM.Id;
        qr1.Response__c = 'Answer1';
        //insert qr1;
        Questionnaire_Response__c qr2 = new Questionnaire_Response__c();
        qr2.Question_Template__c = q2.Id;
        qr2.Issue_Request__c = assM1.Id;
        qr2.Response__c = 'Answer2';
        //insert qr2;
        
        decisionTreeAnsList.add(qr1);
        decisionTreeAnsList.add(qr2);
        
        String ret = RestSaveDecisionTreeAnswerRecords.saveDecisionTreeAnswerRecords(decisionTreeAnsList);
        System.assert(ret != Null);
        system.debug('++++++++++'+qr1); 
        system.debug('++++++++++'+qr2);
        
    }
}