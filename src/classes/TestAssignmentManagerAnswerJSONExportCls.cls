@isTest
private class TestAssignmentManagerAnswerJSONExportCls {
    
    @istest
    static void allTheDataForThisTestClass() {
        ExAM_Configuration__c exConfig = new ExAM_Configuration__c();
        exConfig.Name = 'Configuration';
        exConfig.Data_Management_Tab_Filter__c = 'opt1,opt2';
        insert exConfig;
        
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
        
        Section_Template__c sec = new Section_Template__c();
        sec.Questionnaire_Section__c  = temp.Id;
        insert sec;
        
        List<Question_Template__c> qtList = new List<Question_Template__c>();
        Question_Template__c q1 = new Question_Template__c();
        q1.Question_Type__c = 'TEXT';
        q1.Section_Question__c = sec.Id;
        q1.Subquestion_Label__c = 'NA~N/A';
        qtList.add(q1);
        
        Question_Template__c q3 = new Question_Template__c();
        q3.Question_Type__c = 'RadioPicklist';
        q3.Weight_of_Answer__c = '0~100~0';
        q3.Subquestion_Label__c = 'NA~N/A~subquestion2';
        q3.Section_Question__c = sec.Id;
        qtList.add(q3);
        
        Question_Template__c q4 = new Question_Template__c();
        q4.Question_Type__c = 'RadioPicklist';
        q4.Weight_of_Answer__c = '0~100~0';
        q4.Subquestion_Label__c = 'N/A~NA~subquestion2';
        q4.Section_Question__c = sec.Id;
        qtList.add(q4);
        insert qtList;
        
        List<Questionnaire_Response__c> qrList = new List<Questionnaire_Response__c>{
            new Questionnaire_Response__c(Question_Template__c = q4.Id,
                                          Issue_Request__c = assM.Id,
                                          Response__c = 'AnswerTest1',
                                          Comment__c = 'Good'
                                         ),
            new Questionnaire_Response__c(Question_Template__c = q3.Id,
                                          Issue_Request__c = assM.Id,
                                          Response__c = 'AnswerTest1',
                                          Comment__c = 'Good'
                                         )
        };
        insert qrList;
        
        Report_Builder_Configuration__c rbc = new Report_Builder_Configuration__c();
        rbc.Output_Format__c = 'JSON';
        rbc.Name = 'rbc1';
        rbc.Assessment_Data_Config__c = '{"Comments":true,"Pictures":true}';
        rbc.Assignment_Manager_position__c = '[{"position":1,"labelName":"Account Name","apiName":"ExAM__Facility_Name__c"},{"position":2,"labelName":"Record ID","apiName":"Id"},{"position":3,"labelName":"Priority","apiName":"ExAM__Priority__c"},{"position":4,"labelName":"Actual Start Time","apiName":"ExAM__Field_Start_Time__c"},{"position":5,"labelName":"Actual End Time","apiName":"ExAM__Field_End_Time__c"}]';
        rbc.Choosed_Assignment_manager__c = assM.Id;
        rbc.Start_Date_Range__c = 'November 12, 2016 1:16:22 PM GMT';
        rbc.End_Date_Range__c = 'November 22, 2017 1:16:22 PM GMT';
        rbc.Assessment_Template__c = temp.Id;
        insert rbc;    
        
        System.currentPageReference().getParameters().put('reportbuilderid', rbc.Id);
        
        String id=  apexPages.currentPage().getParameters().get('reportbuilderid');
        System.debug(id);
        
        
        
        AssignmentManagerAnswerJSONExportCtrl.assignmentManagerRecord amrec = new AssignmentManagerAnswerJSONExportCtrl.assignmentManagerRecord();
        AssignmentManagerAnswerJSONExportCtrl.assignmentManagerFieldValue amfld = new AssignmentManagerAnswerJSONExportCtrl.assignmentManagerFieldValue();
        
        amrec.amName = 'test';
        amrec.amId = null;
        amrec.amFieldValues = null;
        
        amfld.apiName = 'ExAM__Facility_Name__c';
        amfld.labelName = 'Account';
        amfld.position = 1;
        amfld.fieldvalue = 'Test';
        amfld.apiName2 = 'ExAM__Priority__c';
        amfld.labelName2 ='Priority';
        amfld.position2 = 2;
        amfld.fieldvalue2 = 'Open';
        
        AssignmentManagerAnswerJSONExportCtrl amajec = new AssignmentManagerAnswerJSONExportCtrl();
        system.assertNotEquals(amajec.jsonString, null);
    }    
}