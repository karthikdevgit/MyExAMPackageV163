@isTest
private class TestPublicAssessmentModalController {
    static testMethod void method1() {
        Account acc = new Account();
        acc.Name = 'Test';
        insert acc;
        
        Viewer_Custom_Configuration__c viewerRec = new Viewer_Custom_Configuration__c();
        insert viewerRec;
        
        Main_questionaire__c assTemp = new Main_questionaire__c();
        assTemp.Viewer_Configuration__c = viewerRec.Id;
        insert assTemp;
        
        Section_Template__c secTemp = new Section_Template__c();
        secTemp.Questionnaire_Section__c = assTemp.Id;
        insert secTemp;
        
        List<Question_Template__c> quesTempList = new List<Question_Template__c> {
            new Question_Template__c(Section_Question__c = secTemp.id, Question_Label__c = 'test Question0', Question_Order_No__c = 1, Question_Type__c = 'Text', Focus_category__c = 'CCTV', Weight_of_Answer__c = '4',Subquestion_Label__c='opt1~opt2'),
            new Question_Template__c(Section_Question__c = secTemp.id, Question_Label__c = 'Test Question1', Question_Order_No__c = 2, Question_Type__c = 'RadioPicklist',Subquestion_Label__c='opt1~opt2'),
            new Question_Template__c(Section_Question__c = secTemp.id, Question_Label__c = 'Test Question2', Question_Order_No__c = 2, Question_Type__c = 'RadioPicklist',Subquestion_Label__c='opt1~opt2'),
            new Question_Template__c(Section_Question__c = secTemp.id, Question_Label__c = 'Test Question3', Question_Order_No__c = 2, Question_Type__c = 'RadioPicklist',Subquestion_Label__c='opt1~opt2')
        };
        insert quesTempList;
        List<Question_Template__c> updateQuesTempList = new List<Question_Template__c> {
           new Question_Template__c(Id=quesTempList[1].Id,Next_Question__c=quesTempList[2].Name),
           new Question_Template__c(Id=quesTempList[2].Id,Next_Question__c=quesTempList[3].Name)
        };
        update updateQuesTempList;
        
        IssueRequest_Life_Cycle__c assManager = new IssueRequest_Life_Cycle__c();
        assManager.investigationType__c = assTemp.Id;
        assManager.Facility_Name__c = acc.Id;
        assManager.Show_Configuration_Options_in_Viewer__c = True;
        insert assManager;
        
        List<Questionnaire_Response__c> dependAnsList = new  list<Questionnaire_Response__c>{
            new Questionnaire_Response__c(Question_Template__c=quesTempList[1].Id,Response__c='opt2',Issue_Request__c=assManager.Id),
            new Questionnaire_Response__c(Question_Template__c=quesTempList[2].Id,Response__c='opt1',Issue_Request__c=assManager.Id),
            new Questionnaire_Response__c(Question_Template__c=quesTempList[3].Id,Response__c='opt2',Issue_Request__c=assManager.Id)
        };
        insert dependAnsList;

        List<PublicAssessmentModalController.AssessableRecordClass> recordClassList = new List<PublicAssessmentModalController.AssessableRecordClass>();

        PublicAssessmentModalController.AssessableRecordClass recordClass = new PublicAssessmentModalController.AssessableRecordClass();
        recordClass.RecordName = 'Test';
        recordClass.RecordId = acc.Id;
        recordClassList.add( recordClass );
        
        PublicAssessmentModalController.AssessableQueryResultClass assResultError = new PublicAssessmentModalController.AssessableQueryResultClass();
        assResultError.assessableRecords = recordClassList;
        assResultError.success = 'success';
        assResultError.error = '';

        string recordClassStr = Json.serialize( assResultError );


        Test.startTest();
        
            PublicAssessmentModalController pa = new PublicAssessmentModalController();
            string response = PublicAssessmentModalController.queryAssessableRecords('test','Account');
            system.assertEquals(recordClassStr, response);
        Test.stopTest();
    }

    static testMethod void method2() {
    
        contact con = new contact();
        con.FirstName = 'TestCon';
        con.LastName = 'TestCon';
        insert con;
        
        Test.startTest();
            List<contact> conList = new List<contact>();
            conList = [SELECT Id,FirstName,Lastname FROM contact where Lastname = 'TestCon'];
            System.assertEquals(1,conList.size());

            List<PublicAssessmentModalController.AssessableRecordClass> recordClassList = new List<PublicAssessmentModalController.AssessableRecordClass>();

            PublicAssessmentModalController.AssessableRecordClass recordClass = new PublicAssessmentModalController.AssessableRecordClass();
            recordClass.RecordName = conList[0].FirstName+' '+conList[0].Lastname;
            recordClass.RecordId = conList[0].Id;
            recordClassList.add( recordClass );
            
            PublicAssessmentModalController.AssessableQueryResultClass assResultError = new PublicAssessmentModalController.AssessableQueryResultClass();
            assResultError.assessableRecords = recordClassList;
            assResultError.success = 'success';
            assResultError.error = '';
            string recordClassStr = Json.serialize( assResultError );

            PublicAssessmentModalController pa = new PublicAssessmentModalController();
            string response = PublicAssessmentModalController.queryAssessableRecords('test','contact');
            system.assertEquals(recordClassStr, response);
        Test.stopTest();
    }

    static testMethod void method3() {
    
        case c = new case();
        c.status ='working';
        c.origin ='Email';
        insert c;
        
        Test.startTest();

            List<case> caseList = new List<case>([SELECT Id,CaseNumber From Case]);
            System.assertEquals(1,caseList.size());

            List<PublicAssessmentModalController.AssessableRecordClass> recordClassList = new List<PublicAssessmentModalController.AssessableRecordClass>();

            PublicAssessmentModalController.AssessableRecordClass recordClass = new PublicAssessmentModalController.AssessableRecordClass();
            recordClass.RecordName = caseList[0].caseNumber;
            recordClass.RecordId = caseList[0].Id;
            recordClassList.add( recordClass );
            
            PublicAssessmentModalController.AssessableQueryResultClass assResultError = new PublicAssessmentModalController.AssessableQueryResultClass();
            assResultError.assessableRecords = recordClassList;
            assResultError.success = 'success';
            assResultError.error = '';
            
            string recordClassStr = Json.serialize( assResultError );
            
            PublicAssessmentModalController pa = new PublicAssessmentModalController();
            string response = PublicAssessmentModalController.queryAssessableRecords(caseList[0].caseNumber,'case');
            system.assertEquals(recordClassStr, response);
        Test.stopTest();
    }
}