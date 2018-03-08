@isTest
public class TestRestCreateEntities {

    @testSetUp
    static void testData() {

        ExAM__Main_questionaire__c TemplateTestData = new ExAM__Main_questionaire__c(ExAM__Template_name__c = 'Test Template');
        insert TemplateTestData;

        ExAM__Section_Template__c SectionTemplateTestData = new ExAM__Section_Template__c(ExAM__Questionnaire_Section__c = TemplateTestData.Id, ExAM__Section_label__c = 'Test Section');
        insert SectionTemplateTestData;

        ExAM__Question_Template__c QtnTemplateTestData1 = new ExAM__Question_Template__c(ExAM__Section_Question__c = SectionTemplateTestData.Id, ExAM__Question_Type__c = 'Text', ExAM__Question_Label__c = 'What is your name?');
        insert QtnTemplateTestData1;

        ExAM__Question_Template__c QtnTemplateTestData2 = new ExAM__Question_Template__c(ExAM__Section_Question__c = SectionTemplateTestData.Id, ExAM__Question_Type__c = 'Checkbox', ExAM__Question_Label__c = 'Do you like this product?');
        insert QtnTemplateTestData2;

        ExAM__Question_Template__c QtnTemplateTestData3 = new ExAM__Question_Template__c(ExAM__Section_Question__c = SectionTemplateTestData.Id, ExAM__Question_Type__c = 'RadioPicklist', ExAM__Question_Label__c = 'How do you rate this product?');
        insert QtnTemplateTestData3;

        ExAM__Answer_Option__c[] AnswerOptionsTestData = new ExAM__Answer_Option__c[] {
            new ExAM__Answer_Option__c(ExAM__Question_Template__c = QtnTemplateTestData3.Id, ExAM__Weight__c = 0, ExAM__Order_No__c = 1, Name = 'Bad'),
            new ExAM__Answer_Option__c(ExAM__Question_Template__c = QtnTemplateTestData3.Id, ExAM__Weight__c = 40, ExAM__Order_No__c = 2, Name = 'Good'),
            new ExAM__Answer_Option__c(ExAM__Question_Template__c = QtnTemplateTestData3.Id, ExAM__Weight__c = 60, ExAM__Order_No__c = 3, Name = 'Excellent')
        };
        insert AnswerOptionsTestData;
    }

    static testmethod void method1() {

        List<ExAM__Main_questionaire__c> TemplateTestData = new List<ExAM__Main_questionaire__c>([SELECT Id, Name, ExAM__Template_name__c FROM ExAM__Main_questionaire__c]);
        string templateId = TemplateTestData[0].Id;

        List<ExAM__Question_Template__c> QtnTemplateTestData1 = new List<ExAM__Question_Template__c>([SELECT Id, Name, ExAM__Question_Type__c FROM ExAM__Question_Template__c WHERE ExAM__Question_Type__c = 'Text' LIMIT 1]);
        string qtntemplate1Id = QtnTemplateTestData1[0].Id;

        List<ExAM__Question_Template__c> QtnTemplateTestData2 = new List<ExAM__Question_Template__c>([SELECT Id, Name, ExAM__Question_Type__c FROM ExAM__Question_Template__c WHERE ExAM__Question_Type__c = 'Checkbox' LIMIT 1]);
        string qtntemplate2Id = QtnTemplateTestData2[0].Id;

        List<ExAM__Question_Template__c> QtnTemplateTestData3 = new List<ExAM__Question_Template__c>([SELECT Id, Name, ExAM__Question_Type__c FROM ExAM__Question_Template__c WHERE ExAM__Question_Type__c = 'RadioPicklist' LIMIT 1]);
        string qtntemplate3Id = QtnTemplateTestData3[0].Id;

        DateTime strDate = DateTime.Now();
        DateTime endDate = DateTime.Now().addDays(1);
        Date expirationDate1 = Date.today().addYears(1);
        Date expirationDate2 = Date.today().addYears(2);
        Date expirationDate3 = Date.today().addYears(3);
        Date expirationDate4 = Date.today().addYears(4);
        Date expirationDate5 = Date.today().addYears(5);

        List<string> accData1 = new List<string>{'Account', 'Test Account 1', 'ACC0001', 'Hot', 'Prospect', '100', 'true', string.valueOf(expirationDate1), ''};
        List<string> accData2 = new List<string>{'Account', 'Test Account 2', 'ACC0002', 'Warm', 'Technology Partner', '200', 'false', string.valueOf(expirationDate2), ''};
        List<string> accData3 = new List<string>{'Account', 'Test Account 3', 'ACC0003', 'Cold', 'Other', '300', 'true', string.valueOf(expirationDate3), ''};
        List<string> accData4 = new List<string>{'Account', 'Test Account 4', 'ACC0004', 'Warm', 'Technology Partner', '400', 'false', string.valueOf(expirationDate4), 'ACC0001'};
        List<string> accData5 = new List<string>{'Account', 'Test Account 5', 'ACC0005', 'Cold', 'Other', '500', 'true', string.valueOf(expirationDate5), 'ACC0002'};

        RestCreateEntities.AssessableObjectDetails objectDetail = new RestCreateEntities.AssessableObjectDetails();
        objectDetail.saveExternalIds = 1;
        objectDetail.fields = new List<string>{'objName', 'name', 'externalId', 'Rating', 'Type', 'NumberOfEmployees', 'ExAM__Create_Survey__c', 'ExAM__SLAExpirationDate__c', 'parentExtId'};
        objectDetail.data = new List<List<string>>{accData1, accData2, accData3, accData4, accData5};

        List<string> amData1 = new List<string>{templateId, 'ACC0001', 'Open', string.valueOf(strDate), string.valueOf(endDate), 'AM0101', string.valueOf(strDate), 'true', 'AM0102', 'AM0103', 'AM0104', 'AM0105'};
        List<string> amData2 = new List<string>{templateId, 'ACC0002', 'In Progress', string.valueOf(strDate), string.valueOf(endDate), 'AM0102', string.valueOf(strDate), 'true', '', '', '', ''};
        List<string> amData3 = new List<string>{templateId, 'ACC0003', 'Scheduled', string.valueOf(strDate), string.valueOf(endDate), 'AM0103', string.valueOf(strDate), 'true', '', '', '', ''};
        List<string> amData4 = new List<string>{templateId, 'ACC0002', 'On Hold', string.valueOf(strDate), string.valueOf(endDate), 'AM0104', string.valueOf(strDate), 'true', '', '', '', ''};
        List<string> amData5 = new List<string>{templateId, 'ACC0003', 'Open', string.valueOf(strDate), string.valueOf(endDate), 'AM0105', string.valueOf(strDate), 'true', '', '', '', ''};
        List<string> amData6 = new List<string>{templateId, 'ACC0003', 'Open', string.valueOf(strDate), string.valueOf(endDate), 'AM0106', string.valueOf(strDate), 'true', 'XYZ-AM0102', 'XYZ-AM0103', 'XYZ-AM0104', 'XYZ-AM0105'};

        RestCreateEntities.AssignmentManagerDetails amDetail = new RestCreateEntities.AssignmentManagerDetails();
        amDetail.saveExternalIds = 1;
        amDetail.fields = new List<string>{'assessmentTemplateId', 'parentObjExtId', 'overallStatus', 'scheduledStartDate', 'scheduledEndDate', 'externalId', 'ExAM__Date_Assigned__c', 'ExAM__Show_Configuration_Options_in_Viewer__c', 'relatedAM1ExtId', 'relatedAM2ExtId', 'relatedAM3ExtId', 'relatedAM4ExtId'};
        amDetail.data = new List<List<string>>{amData1, amData2, amData3, amData4, amData5, amData6};

        List<string> ansData1 = new List<string>{'John Howard', qtntemplate1Id, 'AM0101', 'ANS1001', 'Comment 1', 'Routine', string.valueOf(0)};
        List<string> ansData2 = new List<string>{'true', qtntemplate2Id, 'AM0102', 'ANS1002', 'Comment 2', 'High', string.valueOf(0)};
        List<string> ansData3 = new List<string>{'Excellent', qtntemplate3Id, 'XYZ-AM0103', 'ANS1003', 'Comment 3', 'Emergency', string.valueOf(60)};

        RestCreateEntities.AnswerDetails answerDetail = new RestCreateEntities.AnswerDetails();
        answerDetail.saveExternalIds = 1;
        answerDetail.fields = new List<string>{'response', 'questionTemplateId', 'amExtId', 'externalId', 'comments', 'priority', 'ExAM__Weight_Response__c'};
        answerDetail.data = new List<List<string>>{ansData1, ansData2, ansData3};

        RestCreateEntities.UserDataInput userData = new RestCreateEntities.UserDataInput();
        userData.uniquePrefix = 'XYZ';
        userData.objDetails = objectDetail;
        userData.amDetails = amDetail;
        userData.answerDetails = answerDetail;

        string jsonInput = Json.serialize( userData );
        Blob b = Blob.valueOf(jsonInput);

        RestRequest req = new RestRequest();
        req.requestBody = b;

        RestContext.request = req;

        RestCreateEntities.ResponseClass response = RestCreateEntities.createEntities();
        system.assertEquals(response.code, 200);
        system.assertEquals(response.status, 'SUCCESS');
        system.assertEquals(response.message, 'Records saved successfully');
    }

}