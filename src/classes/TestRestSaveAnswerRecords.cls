@isTest
public class TestRestSaveAnswerRecords {
    @testSetup 
    static void createRecords() {
        Main_questionaire__c assTemp = new Main_questionaire__c();
        insert assTemp;
        
        Section_Template__c sec = new Section_Template__c();
        sec.Questionnaire_Section__c  = assTemp.Id;
        insert sec;
        
        IssueRequest_Life_Cycle__c m1 = new IssueRequest_Life_Cycle__c();
        m1.InvestigationType__c = assTemp.Id;
        insert m1;
        
        Question_Template__c q1 = new Question_Template__c();
        q1.Question_Type__c = 'TEXT';
        q1.Section_Question__c = sec.Id;
        insert q1;
        Question_Template__c q2 = new Question_Template__c();
        q2.Question_Type__c = 'TEXT';
        q2.Section_Question__c = sec.Id;
        insert q2;
        Question_Template__c q3 = new Question_Template__c();
        q3.Question_Type__c = 'TEXT';
        q3.Section_Question__c = sec.Id;
        insert q3;
        
        Questionnaire_Response__c answer = new Questionnaire_Response__c();
        answer.Question_Template__c = q1.Id;
        answer.Issue_Request__c = m1.Id;
        answer.Response__c = 'Satisfied';
        insert answer;
    }
    static testMethod void method1() {
        List<Main_questionaire__c> assTempList = new List<Main_questionaire__c>([SELECT Id,Name FROM Main_questionaire__c LIMIT 1]);
        System.assertEquals(assTempList.size(),1);
        List<IssueRequest_Life_Cycle__c> assManagerList =  new List<IssueRequest_Life_Cycle__c>([SELECT Id,Name FROM IssueRequest_Life_Cycle__c LIMIT 1]);
        System.assertEquals(assManagerList.size(),1);
        List<Question_Template__c> quesTempList = new List<Question_Template__c>([SELECT Id,Name FROM Question_Template__c]);
        System.assertEquals(quesTempList.size(),3);
        List<Questionnaire_Response__c> ansList =  new List<Questionnaire_Response__c>([SELECT Id,Name FROM Questionnaire_Response__c LIMIT 1]);
        System.assertEquals(ansList.size(),1);
        
        RestSaveAnswerRecords.AnswerRecordClass ans1 = new RestSaveAnswerRecords.AnswerRecordClass();
        ans1.questiontemplateId = quesTempList[0].Id;
        ans1.assignmentManagerId = assManagerList[0].Id;
        ans1.response = 'AnswerTest';
        ans1.comment = 'Good';
        RestSaveAnswerRecords.AnswerRecordClass ans2 = new RestSaveAnswerRecords.AnswerRecordClass();
        ans2.questiontemplateId = quesTempList[1].Id;
        ans2.assignmentManagerId = assManagerList[0].Id;
        ans2.response = 'AnswerTest';
        ans2.comment = 'Good';
        RestSaveAnswerRecords.AnswerRecordClass ans3 = new RestSaveAnswerRecords.AnswerRecordClass();
        ans3.questiontemplateId = quesTempList[2].Id;
        ans3.assignmentManagerId = assManagerList[0].Id;
        ans3.response = 'AnswerTest';
        ans3.comment = 'Good';
        
        List<RestSaveAnswerRecords.AnswerRecordClass> answerList = new List<RestSaveAnswerRecords.AnswerRecordClass>();
        answerList.add(ans1);
        answerList.add(ans2);
        answerList.add(ans3);
        
        Map<Id,Id> quesIdAndAnsIdMap = new Map<Id,Id>();
        quesIdAndAnsIdMap.put(quesTempList[0].Id,ansList[0].Id);
        String tempStr = JSON.serialize(quesIdAndAnsIdMap);
        String tempId = assTempList[0].Id+'~'+'45~'+tempStr;
        
        RestSaveAnswerRecords classObj = new RestSaveAnswerRecords();
        String Result = RestSaveAnswerRecords.saveAnswerRecords(answerList, tempId, assManagerList[0].Id, TRUE);
        System.assert(Result != NULL);
    }
    static testMethod void method2() {
        List<Main_questionaire__c> assTempList = new List<Main_questionaire__c>([SELECT Id,Name FROM Main_questionaire__c LIMIT 1]);
        System.assertEquals(assTempList.size(),1);
        List<IssueRequest_Life_Cycle__c> assManagerList =  new List<IssueRequest_Life_Cycle__c>([SELECT Id,Name FROM IssueRequest_Life_Cycle__c LIMIT 1]);
        System.assertEquals(assManagerList.size(),1);
        List<Question_Template__c> quesTempList = new List<Question_Template__c>([SELECT Id,Name FROM Question_Template__c]);
        System.assertEquals(quesTempList.size(),3);
        List<Questionnaire_Response__c> ansList =  new List<Questionnaire_Response__c>([SELECT Id,Name FROM Questionnaire_Response__c LIMIT 1]);
        System.assertEquals(ansList.size(),1);
        
        RestSaveAnswerRecords.AnswerRecordClass ans1 = new RestSaveAnswerRecords.AnswerRecordClass();
        ans1.questiontemplateId = quesTempList[0].Id;
        ans1.assignmentManagerId = assManagerList[0].Id;
        ans1.response = 'AnswerTest';
        ans1.comment = 'Good';
        RestSaveAnswerRecords.AnswerRecordClass ans2 = new RestSaveAnswerRecords.AnswerRecordClass();
        ans2.questiontemplateId = quesTempList[1].Id;
        ans2.assignmentManagerId = assManagerList[0].Id;
        ans2.response = 'AnswerTest';
        ans2.comment = 'Good';
        RestSaveAnswerRecords.AnswerRecordClass ans3 = new RestSaveAnswerRecords.AnswerRecordClass();
        ans3.questiontemplateId = quesTempList[2].Id;
        ans3.assignmentManagerId = assManagerList[0].Id;
        ans3.response = 'AnswerTest';
        ans3.comment = 'Good';
        
        List<RestSaveAnswerRecords.AnswerRecordClass> answerList = new List<RestSaveAnswerRecords.AnswerRecordClass>();
        answerList.add(ans1);
        answerList.add(ans2);
        answerList.add(ans3);

        String tempId = assTempList[0].Id+'~'+'45';
        
        RestSaveAnswerRecords classObj = new RestSaveAnswerRecords();
        String Result = RestSaveAnswerRecords.saveAnswerRecords(answerList, tempId, assManagerList[0].Id, TRUE);
        System.assert(Result != NULL);
    }
    static testMethod void method3() {
        List<Main_questionaire__c> assTempList = new List<Main_questionaire__c>([SELECT Id,Name FROM Main_questionaire__c LIMIT 1]);
        System.assertEquals(assTempList.size(),1);
        List<IssueRequest_Life_Cycle__c> assManagerList =  new List<IssueRequest_Life_Cycle__c>([SELECT Id,Name FROM IssueRequest_Life_Cycle__c LIMIT 1]);
        System.assertEquals(assManagerList.size(),1);
        List<Question_Template__c> quesTempList = new List<Question_Template__c>([SELECT Id,Name FROM Question_Template__c]);
        System.assertEquals(quesTempList.size(),3);
        List<Questionnaire_Response__c> ansList =  new List<Questionnaire_Response__c>([SELECT Id,Name FROM Questionnaire_Response__c LIMIT 1]);
        System.assertEquals(ansList.size(),1);
        
        RestSaveAnswerRecords.AnswerRecordClass ans1 = new RestSaveAnswerRecords.AnswerRecordClass();
        ans1.questiontemplateId = quesTempList[0].Id;
        ans1.assignmentManagerId = assManagerList[0].Id;
        ans1.response = 'AnswerTest';
        ans1.comment = 'Good';
        RestSaveAnswerRecords.AnswerRecordClass ans2 = new RestSaveAnswerRecords.AnswerRecordClass();
        ans2.questiontemplateId = quesTempList[1].Id;
        ans2.assignmentManagerId = assManagerList[0].Id;
        ans2.response = 'AnswerTest';
        ans2.comment = 'Good';
        RestSaveAnswerRecords.AnswerRecordClass ans3 = new RestSaveAnswerRecords.AnswerRecordClass();
        ans3.questiontemplateId = quesTempList[2].Id;
        ans3.assignmentManagerId = assManagerList[0].Id;
        ans3.response = 'AnswerTest';
        ans3.comment = 'Good';
        
        List<RestSaveAnswerRecords.AnswerRecordClass> answerList = new List<RestSaveAnswerRecords.AnswerRecordClass>();
        answerList.add(ans1);
        answerList.add(ans2);
        answerList.add(ans3);

        RestSaveAnswerRecords classObj = new RestSaveAnswerRecords();
        String Result = RestSaveAnswerRecords.saveAnswerRecords(answerList, assTempList[0].Id, assManagerList[0].Id, TRUE);
        System.assert(Result != NULL);
    }
}