@isTest

private class TestAssessableFieldQuestionMappingCtr {
    
    @testSetup
    static void createTestRecordsForAssessableFieldMapping() {

        Account acc = new Account();
        acc.Name = 'Test';
        insert acc;

        Main_questionaire__c assessmentTemplate = new Main_questionaire__c();
        assessmentTemplate.Template_Name__c = 'Test Template';
        insert assessmentTemplate;

        Section_Template__c sectionTemplate = new Section_Template__c();
        sectionTemplate.Questionnaire_Section__c = assessmentTemplate.Id;
        sectionTemplate.Section_label__c = 'Test Section';
        insert sectionTemplate;

        Question_Template__c qtnTemplate = new Question_Template__c();
        qtnTemplate.Section_Question__c = sectionTemplate.Id;
        qtnTemplate.Question_Label__c = 'How is your experience with our service?';
        qtnTemplate.Subquestion_Label__c = 'Very Satisfied~Satisfied~Not Satisfied';
        qtnTemplate.Weight_of_Answer__c = '10~50~40';
        qtnTemplate.Question_Type__c = 'RadioPicklist';
        qtnTemplate.Weight_Of_Question__c = 10;
        insert qtnTemplate;

        IssueRequest_Life_Cycle__c managerRecord = new IssueRequest_Life_Cycle__c();
        managerRecord.investigationType__c = assessmentTemplate.Id;
        managerRecord.Facility_Name__c = acc.Id;
        managerRecord.scheduled_start_date__c = Date.today()-5;
        managerRecord.Show_Configuration_Options_in_Viewer__c = True;
        insert managerRecord;

        Questionnaire_Response__c answer = new Questionnaire_Response__c();
        answer.Question_Template__c = qtnTemplate.Id;
        answer.Issue_Request__c = managerRecord.Id;
        answer.Response__c = 'Satisfied';
        insert answer;

        List<Questionnaire_Response__c> answerList = new List<Questionnaire_Response__c>([SELECT Id, Name FROM Questionnaire_Response__c LIMIT 1]);
        system.assertEquals(answerList.size(), 1);
    }

    static testMethod void method1() {

        AssessableFieldQuestionMappingController fieldMappingCtrller = new AssessableFieldQuestionMappingController();

        AssessableFieldQuestionMappingController.assessableFields('Account');

        List<Main_questionaire__c> assessmentTemplateList = new List<Main_questionaire__c>([SELECT Id, Name, Template_Name__c FROM Main_questionaire__c WHERE Template_Name__c = 'Test Template' LIMIT 1]);

        if (!assessmentTemplateList.isEmpty() ) {

            string assessmentTemplateId = assessmentTemplateList[0].Id;

            AssessableFieldQuestionMappingController.getQuestionRecords( assessmentTemplateId );

            List<Question_Template__c> qtnTemplateList = new List<Question_Template__c>([SELECT Id, Name, Section_Question__c, Section_Question__r.Questionnaire_Section__c FROM Question_Template__c WHERE Section_Question__r.Questionnaire_Section__c = :assessmentTemplateId LIMIT 1]);

            if (!qtnTemplateList.isEmpty() ) {

                AssessableFieldQuestionMappingController.AssessableMappingClass fieldMappingInstance1 = new AssessableFieldQuestionMappingController.AssessableMappingClass();
                fieldMappingInstance1.assessableFieldsApi = 'Type';
                fieldMappingInstance1.questionId = qtnTemplateList[0].Id;
                fieldMappingInstance1.MappingRecordId = null;
                fieldMappingInstance1.storeAnswerResponseOrWeight = 'Response';
                fieldMappingInstance1.mappedFrom = 'Answer';
                fieldMappingCtrller.assMappingResponseList.add( fieldMappingInstance1 );

                AssessableFieldQuestionMappingController.AssessableMappingClass fieldMappingInstance2 = new AssessableFieldQuestionMappingController.AssessableMappingClass();
                fieldMappingInstance2.assessableFieldsApi = 'ExAM__Adequate_Lighting_Score__c';
                fieldMappingInstance2.questionId = qtnTemplateList[0].Id;
                fieldMappingInstance2.MappingRecordId = null;
                fieldMappingInstance2.storeAnswerResponseOrWeight = 'Score';
                fieldMappingInstance2.mappedFrom = 'Answer';
                fieldMappingCtrller.assMappingResponseList.add( fieldMappingInstance2 );

                AssessableFieldQuestionMappingController.AssessableMappingClass fieldMappingInstance3 = new AssessableFieldQuestionMappingController.AssessableMappingClass();
                fieldMappingInstance3.assessableFieldsApi = 'ExAM__Status__c';
                fieldMappingInstance3.MappingRecordId = null;
                fieldMappingInstance3.mappedFrom = 'Assignment Manager';
                fieldMappingInstance3.amFieldAPI = 'ExAM__Status__c';
                fieldMappingCtrller.assMappingResponseList.add( fieldMappingInstance3 );

                AssessableFieldQuestionMappingController.saveFieldMapping('Account', fieldMappingCtrller.assMappingResponseList, assessmentTemplateId, false);

                string existingAFMRecord = AssessableFieldQuestionMappingController.existingFieldMapping('Account', assessmentTemplateId, false);
                if (string.isNotBlank(existingAFMRecord) ) {

                    AssessableFieldQuestionMappingController.AFMDetail existingAFMObj = (AssessableFieldQuestionMappingController.AFMDetail)JSON.deserialize(existingAFMRecord, AssessableFieldQuestionMappingController.AFMDetail.class);
                    String existingAFMListStr = existingAFMObj.afms;
                    
                    List<AssessableFieldQuestionMappingController.AssessableMappingClass> existingAFMList = (List<AssessableFieldQuestionMappingController.AssessableMappingClass>)JSON.deserialize(existingAFMListStr,List<AssessableFieldQuestionMappingController.AssessableMappingClass>.class);
                    
                    if (!existingAFMList.isEmpty() && existingAFMObj.errorMsg != null && existingAFMObj.errorMsg != '' ) {
                        
                        system.assertNotEquals(existingAFMList[0].MappingRecordId, assessmentTemplateId);

                        fieldMappingCtrller.assMappingResponseList = new List<AssessableFieldQuestionMappingController.AssessableMappingClass>();

                        AssessableFieldQuestionMappingController.AssessableMappingClass fieldMappingInstance4 = new AssessableFieldQuestionMappingController.AssessableMappingClass();
                        fieldMappingInstance4.assessableFieldsApi = 'ExAM__UpsellOpportunity__c';
                        fieldMappingInstance4.MappingRecordId = existingAFMList[0].MappingRecordId;
                        fieldMappingInstance4.mappedFrom = 'Assignment Manager';
                        fieldMappingInstance4.amFieldAPI = 'ExAM__Status__c';
                        fieldMappingCtrller.assMappingResponseList.add( fieldMappingInstance4 );

                        AssessableFieldQuestionMappingController.saveFieldMapping('Account', fieldMappingCtrller.assMappingResponseList, assessmentTemplateId, false);

                        AssessableFieldQuestionMappingController.deleteMappingRecord( existingAFMList[0].MappingRecordId );

                        AssessableFieldQuestionMappingController.deleteMappingRecord( 'Tobe Deleted Record Id' );


                        fieldMappingCtrller.assMappingResponseList = new List<AssessableFieldQuestionMappingController.AssessableMappingClass>();

                        AssessableFieldQuestionMappingController.AssessableMappingClass fieldMappingInstance5 = new AssessableFieldQuestionMappingController.AssessableMappingClass();
                        fieldMappingInstance5.assessableFieldsApi = 'ExAM__UpsellOpportunity__c';
                        fieldMappingInstance5.MappingRecordId = 'DUMMY ASSESSABLE FIELD MAPPING RECORD ID';
                        fieldMappingInstance5.mappedFrom = 'Assignment Manager';
                        fieldMappingInstance5.amFieldAPI = 'ExAM__Status__c';
                        fieldMappingCtrller.assMappingResponseList.add( fieldMappingInstance5 );

                        String savedResponse = AssessableFieldQuestionMappingController.saveFieldMapping('Account', fieldMappingCtrller.assMappingResponseList, assessmentTemplateId, false);

                        Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(savedResponse);
                        if (responseMap != null) {
                            system.assertEquals(responseMap.get('status'), false);
                            system.assertEquals(responseMap.get('resultMsg'), 'Invalid id: DUMMY ASSESSABLE FIELD MAPPING RECORD ID');
                        }
                    }
                }
            }
        }
    }
}