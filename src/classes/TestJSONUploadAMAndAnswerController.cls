@isTest
public class TestJSONUploadAMAndAnswerController {
  
    static testMethod void method(){
      
        Account acc = new Account(Name = 'TestAccount');
        insert acc;
        
        Main_questionaire__c temp = new Main_questionaire__c();//Template creation
        temp.Template_name__c = 'Template1';
        temp.Template_External_Id__c = 'test_test_testclass';
        insert temp;
        
        IssueRequest_Life_Cycle__c assM = new IssueRequest_Life_Cycle__c();//AssignmentManager creation
        assM.InvestigationType__c = temp.Id;
        assM.Facility_Name__c = acc.Id;
        insert assM;
        
        Section_Template__c sec = new Section_Template__c();
        sec.Questionnaire_Section__c  = temp.Id;
        insert sec;
        
        Question_Template__c q3 = new Question_Template__c();
        q3.Question_Type__c = 'RadioPicklist';
        q3.Weight_of_Answer__c = '0~100~0';
        q3.Subquestion_Label__c = 'NA~N/A~subquestion2';
        q3.Section_Question__c = sec.Id;
        q3.Question_External_Id__c = 'test_test_class';
        insert q3;
        
        Questionnaire_Response__c qr = new Questionnaire_Response__c(Question_Template__c = q3.Id,
                                          Issue_Request__c = assM.Id,
                                          Response__c = 'AnswerTest1',
                                          Comment__c = 'Good'
                                         );
        insert qr;
        
      String amAndAnsJSONListStr = '[{"assignmentManagerValue":[{"f_Value":"2016-10-13 15:39:38","f_Api":"exam__scheduled_start_date__c"}'
                                  + '],"assignment_ManagerName":"AM-51554  10-13-2016","assignment_ManagerId":"'+assM.Id+'",'
                                  + '"assessmentTemplateName":"My VA Survey","assessmentTemplateId":"'+temp.Id+'","assessmentTemplateExternalId"'
                                  + ':"test_test_testclass","assessableRecordId":"'+acc.Id+'","assessableRecord":{"assessableValue":'
                                  + '[{"ass_f_Value":"Dickenson plc","ass_f_Api":"Name"}]},"assessableObject":"Account","assessableFieldAPI"'
                                  + ':"exam__facility_name__c","answers":[{"weightResponse":null,"responsible_Party":null,"response":"Yes"'
                                  + ',"questionWeight":0,"questionName":"Q-33948","questionnaire_Taker_user":null,"questionId":"'+q3.Id+'"'
                                  + ',"q_ExternalId":"test_test_class","priority":"Routine","maxScore":null,"deficiency_status":"Open",'
                                  + '"comment":null,"assessableFieldValue":null,"assessableApi":null,"answerId":"'+qr.Id+'","answer_text"'
                                  + ':null,"AM_Id":"'+assM.Id+'"}]}]'; 
       String rescls = JSONUploadAMAndAnswerController.saveRecords(amAndAnsJSONListStr);
        System.assert(rescls.contains('Upload process has completed successfully'));
        System.debug('rescls'+rescls);
    }
    static testMethod void method1(){
      
        Account acc = new Account(Name = 'TestAccount');
        insert acc;
        
        Main_questionaire__c temp = new Main_questionaire__c();//Template creation
        temp.Template_name__c = 'Template1';
        temp.Template_External_Id__c = 'test_test_testclass';
        insert temp;
        
        IssueRequest_Life_Cycle__c assM = new IssueRequest_Life_Cycle__c();//AssignmentManager creation
        assM.InvestigationType__c = temp.Id;
        assM.Facility_Name__c = acc.Id;
        insert assM;
        
        Section_Template__c sec = new Section_Template__c();
        sec.Questionnaire_Section__c  = temp.Id;
        insert sec;
        
        Question_Template__c q3 = new Question_Template__c();
        q3.Question_Type__c = 'RadioPicklist';
        q3.Weight_of_Answer__c = '0~100~0';
        q3.Subquestion_Label__c = 'NA~N/A~subquestion2';
        q3.Section_Question__c = sec.Id;
        q3.Question_External_Id__c = 'test_test_class';
        insert q3;
        
        Questionnaire_Response__c qr = new Questionnaire_Response__c(Question_Template__c = q3.Id,
                                          Issue_Request__c = assM.Id,
                                          Response__c = 'AnswerTest1',
                                          Comment__c = 'Good'
                                         );
        insert qr;
        
      String amAndAnsJSONListStr = '[{"assignmentManagerValue":[{"f_Value":"2016-10-13 15:39:38","f_Api":"exam__scheduled_start_date__c"}'
                                   + ',{"f_Value":"100.00","f_Api":"exam__Max_Score__c"},{"f_Value":"True","f_Api"'
                                   + ':"exam__Show_Configuration_Options_in_Viewer__c"},{"f_Value":"True","f_Api":"exam__URL_String__c"}]'
                                   + ',"assignment_ManagerName":"AM-51554  10-13-2016","assignment_ManagerId":"'+assM.Id+'",'
                                   + '"assessmentTemplateName":"My VA Survey","assessmentTemplateId":"'+temp.Id+'",'
                                   + '"assessmentTemplateExternalId":null,"assessableRecordId":"'+acc.Id+'","assessableRecord"'
                                   + ':{"assessableValue":[{"ass_f_Value":"Dickenson plc","ass_f_Api":"Name"},{"ass_f_Value":'
                                   + '"2016-10-13 15:39:38","ass_f_Api":"exam__scheduled_start_date__c"},{"ass_f_Value":"100.00",'
                                   + '"ass_f_Api":"exam__Max_Score__c"},{"ass_f_Value":"True","ass_f_Api":'
                                   + '"exam__Show_Configuration_Options_in_Viewer__c"}]},"assessableObject":"Account","assessableFieldAPI"'
                                   + ':"exam__facility_name__c","answers":[{"weightResponse":null,"responsible_Party":null,"response":"Yes"'
                                   + ',"questionWeight":0,"questionName":"Q-33948","questionnaire_Taker_user":null,"questionId":"'+q3.Id+'",'
                                   + '"q_ExternalId":null,"priority":"Routine","maxScore":null,"deficiency_status":"Open","comment":null,'
                                   + '"assessableFieldValue":null,"assessableApi":null,"answerId":"'+qr.Id+'","answer_text":null,'
                                   + '"AM_Id":"'+assM.Id+'"}]}]'; 
       String rescls = JSONUploadAMAndAnswerController.saveRecords(amAndAnsJSONListStr);
        System.assert(rescls.contains('Template does not have external Id value'));
        System.debug('rescls'+rescls);
    }
}