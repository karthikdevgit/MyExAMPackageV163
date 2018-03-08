@IsTest
private class TestMobileAppUtill {
    @testSetUp
    public static void testSetUp() {
       
        Account acc = new Account();
        acc.Name = 'Test';
        insert acc;
        
        contact con = new contact();
        con.AccountId=acc.id;
        con.LastName ='testCon';
        insert con;
        
        Lead l = new Lead();
        l.LastName = 'testLead';
        l.Company = 'acc.Id';
        insert l;
            
        Viewer_Custom_Configuration__c viewerRec = new Viewer_Custom_Configuration__c();
        insert viewerRec;
            
        List<Main_questionaire__c> asstempList = new List<Main_questionaire__c> {
                                                 new Main_questionaire__c (Template_name__c = 'Unit Template',Viewer_Configuration__c = viewerRec.Id, One_Time_Assessment__c = true),
                                                 new Main_questionaire__c (Template_name__c = 'Site Template',Viewer_Configuration__c = viewerRec.Id, Decision_Tree__c = 'Pictures:true:false:1~External_Id__c:false:false:2~Priority__c:true:false:3~Comment__c:true:false:4~Response__c:true:false:5~Test_text_field__c:true:false:6~deficiency_status__c:true:false:7'),
                                                 new Main_questionaire__c (Template_name__c = 'Common Template',Viewer_Configuration__c = viewerRec.Id, Decision_Tree__c = 'Pictures:true:false:1~External_Id__c:false:false:2~Priority__c:true:false:3~Comment__c:true:false:4~Response__c:true:false:5~Test_text_field__c:true:true:6~deficiency_status__c:true:false:7'),
                                                 new Main_questionaire__c (Template_name__c = 'System Template',Viewer_Configuration__c = viewerRec.Id,Decision_Tree__c = 'Pictures:true:false:1~External_Id__c:false:false:2~Priority__c:true:false:3~Comment__c:true:false:4~Response__c:true:false:5~Test_text_field__c:true:false:6~deficiency_status__c:true:false:7'),
                                                 new Main_questionaire__c (Template_name__c = 'Exterior Template',Viewer_Configuration__c = viewerRec.Id, Decision_Tree__c = 'Pictures:true:false:1~External_Id__c:false:false:2~Priority__c:true:false:3~Comment__c:true:false:4~Response__c:true:false:5~Test_text_field__c:true:false:6~deficiency_status__c:true:false:7'),
                                                 new Main_questionaire__c (Template_name__c = 'Exterior Template',Viewer_Configuration__c = viewerRec.Id, Decision_Tree__c = 'Pictures:true:false:1'),
                                                 new Main_questionaire__c (Template_name__c = 'Exterior Template',Viewer_Configuration__c = viewerRec.Id, Decision_Tree__c = 'Pictures:true:false:1')
        };
        insert asstempList;
    
        List<Section_Template__c> secTempList = new List<Section_Template__c>{
                                                new Section_Template__c(Questionnaire_Section__c = asstempList[0].id, Section_label__c = 'UT Section'),
                                                new Section_Template__c(Questionnaire_Section__c = asstempList[1].id, Section_label__c = 'ST Section'),
                                                new Section_Template__c(Questionnaire_Section__c = asstempList[0].id, Section_label__c = 'CT Section'),
                                                new Section_Template__c(Questionnaire_Section__c = asstempList[3].id, Section_label__c = 'SysT Section'),
                                                new Section_Template__c(Questionnaire_Section__c = asstempList[4].id, Section_label__c = 'ET Section')
                                                
        };
        insert secTempList;
    
        List<Question_Template__c> quesTempList = new List<Question_Template__c> {
                                                  new Question_Template__c(Section_Question__c = secTempList[0].id, Question_Label__c = 'test Question0', Question_Order_No__c = 1, Question_Type__c = 'Text', Focus_category__c = 'CCTV', Weight_of_Answer__c = '4'),
                                                  new Question_Template__c(Section_Question__c = secTempList[2].id, Question_Label__c = 'Test Question1', Question_Order_No__c = 2, Question_Type__c = 'RadioPicklist',Subquestion_Label__c='optA1~optA2',Weight_of_Answer__c ='100~50',Do_Not_Create_Answer__c=false),
                                                  new Question_Template__c(Section_Question__c = secTempList[2].id, Question_Label__c = 'Test Question2', Question_Order_No__c = 3, Question_Type__c = 'Dropdown Picklist',Subquestion_Label__c='optB1~optB2',Weight_of_Answer__c ='100~50'),
                                                  new Question_Template__c(Section_Question__c = secTempList[0].id, Question_Label__c = 'Test Question3', Question_Order_No__c = 4, Question_Type__c = 'Button',Subquestion_Label__c='optC1~optC2',Weight_of_Answer__c ='100~50'),
                                                  new Question_Template__c(Section_Question__c = secTempList[0].id, Question_Label__c = 'Test Question4', Question_Order_No__c = 5, Question_Type__c = 'Button',Subquestion_Label__c='optD1~optD2',Weight_of_Answer__c ='100~50',Do_Not_Create_Answer__c=true),
                                                  new Question_Template__c(Section_Question__c = secTempList[0].id, Question_Label__c = 'Test Question4', Question_Order_No__c = 5, Question_Type__c = 'File Question - Answer',Subquestion_Label__c='optD1~optD2',Weight_of_Answer__c ='100~50',Do_Not_Create_Answer__c=true),
                                                  new Question_Template__c(Section_Question__c = secTempList[0].id, Question_Label__c = 'Test Question4', Question_Order_No__c = 5, Question_Type__c = 'Signature',Subquestion_Label__c='optD1~optD2',Weight_of_Answer__c ='100~50',Do_Not_Create_Answer__c=true),
                                                  new Question_Template__c(Section_Question__c = secTempList[0].id, Question_Label__c = 'Test Question3', Question_Order_No__c = 4, Question_Type__c = 'MultiselectPicklist',Subquestion_Label__c='optC1~optC2',Weight_of_Answer__c ='100~50'),
                                                   new Question_Template__c(Section_Question__c = secTempList[0].id, Question_Label__c = 'Test Question3', Question_Order_No__c = 4, Question_Type__c = 'MultiselectPicklist',Subquestion_Label__c='optC1~optC2',Weight_of_Answer__c ='100~50')
        };
        insert quesTempList;
       
        List<Question_Template__c> quesTempList1 = [SELECT Id,Name FROM Question_Template__c];
        
        quesTempList1[0].Next_Question__c = '~Hello';
        quesTempList1[2].Next_Question__c = 'Hello';
        quesTempList1[1].Next_Question__c = quesTempList1[0].Name; 
        
        update quesTempList1;
        
        List<Answer_Option__c> ansoptions = new List<Answer_Option__c> {
                                            new Answer_Option__c(Question_Template__c = quesTempList[0].Id, Order_No__c = 1, Name = 'N/A', Weight__c = 100, Next_Question__c = quesTempList[1].Id ),
                                            new Answer_Option__c(Question_Template__c = quesTempList[0].Id, Order_No__c = 4, Name = 'optD2', Weight__c = 100, Next_Question__c = quesTempList[2].Id),
                                            new Answer_Option__c(Question_Template__c = quesTempList[0].Id, Order_No__c = 5, Name = 'N/A', Weight__c = 100, Next_Question__c = quesTempList[3].Id),
                                            new Answer_Option__c(Question_Template__c = quesTempList[1].Id, Order_No__c = 2, Name = 'optD2', Weight__c = 100),
                                            new Answer_Option__c(Question_Template__c = quesTempList[2].Id, Order_No__c = 3, Name = 'N/A', Weight__c = 100),
                                            new Answer_Option__c(Question_Template__c = quesTempList[7].Id, Order_No__c = 6, Name = 'N/A', Weight__c = 100) ,
                                            new Answer_Option__c(Question_Template__c = quesTempList[3].Id, Order_No__c = 6, Name = 'N/A', Weight__c = 100) };
        insert ansoptions;                                    
                                            
            
        List<IssueRequest_Life_Cycle__c> amList = new List<IssueRequest_Life_Cycle__c>{
                                                  new IssueRequest_Life_Cycle__c(Facility_Name__c = acc.id,Site_Contact__c = con.id,Date_Assigned__c = system.today(),Status__c='open',Priority__c = 'high',InvestigationType__c =assTempList[0].id,Assessment_Form_Completion__c = 'complete',Assessment_Date_Time__c = system.today(),Show_Configuration_Options_in_Viewer__c = true),
                                                  new IssueRequest_Life_Cycle__c(Facility_Name__c = acc.id,Site_Contact__c = con.id,Date_Assigned__c = system.today(),Status__c='open',Priority__c = 'high',InvestigationType__c =assTempList[1].id,Assessment_Form_Completion__c = 'complete',Assessment_Date_Time__c = system.today(),Show_Configuration_Options_in_Viewer__c = true),
                                                  new IssueRequest_Life_Cycle__c(Facility_Name__c = acc.id,Site_Contact__c = con.id,Date_Assigned__c = system.today(),Status__c='open',Priority__c = 'high',InvestigationType__c =assTempList[2].id,Assessment_Form_Completion__c = 'complete',Assessment_Date_Time__c = system.today(),Show_Configuration_Options_in_Viewer__c = true),
                                                  new IssueRequest_Life_Cycle__c(Facility_Name__c = acc.id,Site_Contact__c = con.id,Date_Assigned__c = system.today(),Status__c='open',Priority__c = 'high',InvestigationType__c =assTempList[3].id,Assessment_Form_Completion__c = 'complete',Assessment_Date_Time__c = system.today(),Show_Configuration_Options_in_Viewer__c = true),
                                                  new IssueRequest_Life_Cycle__c(Facility_Name__c = acc.id,Site_Contact__c = con.id,Date_Assigned__c = system.today(),Status__c='open',Priority__c = 'high',InvestigationType__c =assTempList[4].id,Assessment_Form_Completion__c = 'complete',Assessment_Date_Time__c = system.today(),Show_Configuration_Options_in_Viewer__c = true),
                                                  new IssueRequest_Life_Cycle__c(Facility_Name__c = acc.id,Site_Contact__c = con.id,Date_Assigned__c = system.today(),Status__c='open',Priority__c = 'high',InvestigationType__c =assTempList[4].id,Assessment_Form_Completion__c = 'complete',Assessment_Date_Time__c = system.today(),Show_Configuration_Options_in_Viewer__c = true),
                                                  new IssueRequest_Life_Cycle__c(Facility_Name__c = null,Site_Contact__c = con.id,Date_Assigned__c = system.today(),Status__c='open',Priority__c = 'high',InvestigationType__c =assTempList[4].id,Assessment_Form_Completion__c = 'complete',Assessment_Date_Time__c = system.today(),Show_Configuration_Options_in_Viewer__c = true)};
                                                  
                                                   
        insert amList;
        List<IssueRequest_Life_Cycle__c> amList1 = new List<IssueRequest_Life_Cycle__c> {    
                                                   new IssueRequest_Life_Cycle__c(Facility_Name__c = acc.Id,Site_Contact__c = con.id,Date_Assigned__c = system.today(),Status__c='open',Priority__c = 'high',InvestigationType__c =assTempList[6].id,Assessment_Form_Completion__c = 'complete',Assessment_Date_Time__c = system.today(),Show_Configuration_Options_in_Viewer__c = true, Related_Assignment_Manager1__c=amList[1].Id, Related_Assignment_Manager2__c=amList[2].Id, Related_Assignment_Manager3__c=amList[3].Id, Related_Assignment_Manager4__c=amList[4].Id)};
                                                   insert amList1;
            
        List<Questionnaire_Response__c> dependAnsList = new  list<Questionnaire_Response__c>{
                                                        new Questionnaire_Response__c(Question_Template__c=quesTempList[0].Id,Response__c='N/A',Issue_Request__c=amList[0].Id),
                                                        new Questionnaire_Response__c(Question_Template__c=quesTempList[1].Id,Response__c='optA1',Issue_Request__c=amList[0].Id),
                                                        new Questionnaire_Response__c(Question_Template__c=quesTempList[2].Id,Response__c='N/A',Issue_Request__c=amList[0].Id),
                                                        new Questionnaire_Response__c(Question_Template__c=quesTempList[3].Id,Response__c='optD2',Issue_Request__c=amList[0].Id),
                                                        new Questionnaire_Response__c(Question_Template__c=quesTempList[4].Id,Response__c='optD2',Issue_Request__c=amList[0].Id, Decision_Tree_Launched_Question__c = quesTempList[5].Id),
                                                        new Questionnaire_Response__c(Question_Template__c=quesTempList[5].Id,Response__c='optD2',Issue_Request__c=amList[0].Id),
                                                        new Questionnaire_Response__c(Question_Template__c=quesTempList[6].Id,Response__c='optD2',Issue_Request__c=amList[0].Id, Decision_Tree_Launched_Question__c = quesTempList[5].Id),
                                                        new Questionnaire_Response__c(Question_Template__c=quesTempList[7].Id,Response__c='optD2',Issue_Request__c=amList[0].Id, Decision_Tree_Launched_Question__c = quesTempList[4].Id),
                                                        new Questionnaire_Response__c(Question_Template__c=quesTempList[8].Id,Response__c='optD2',Issue_Request__c=amList[0].Id, Decision_Tree_Launched_Question__c = quesTempList[4].Id)
        };
        insert dependAnsList;
        System.assert(dependAnsList[0].Id != Null);
    }
        
    public static testMethod void testSetAnswerWeight() {
       
        List<Account> acc = [SELECT Id FROM Account];
        List<Questionnaire_Response__c> dependAnsList = [SELECT Id, Question_Template__c, Response__c FROM Questionnaire_Response__c];
        List<Question_Template__c> quesTempList = [SELECT Id,Weight_of_Answer__c, Subquestion_Label__c FROM Question_Template__c];
        List<Question_Template__c> quesTempList1 = [SELECT Id,Weight_of_Answer__c, Subquestion_Label__c,(SELECT Id,Name, Question_Template__c, Weight__c FROM Answer_Options__r) FROM Question_Template__c];
        List<IssueRequest_Life_Cycle__c> amList = [SELECT Id FROM IssueRequest_Life_Cycle__c];    
        Map<Id, Question_Template__c> quesIdwithQuestionMap = new Map<Id, Question_Template__c>();
        quesIdwithQuestionMap.put(quesTempList[0].Id,quesTempList[0]);
        quesIdwithQuestionMap.put(quesTempList[1].Id,quesTempList[1]);
        quesIdwithQuestionMap.put(quesTempList[2].Id,quesTempList[2]);
        quesIdwithQuestionMap.put(quesTempList[3].Id,quesTempList[3]);
        
        Map<Id, Question_Template__c> quesIdwithQuestionMap1 = new Map<Id, Question_Template__c>();
        quesIdwithQuestionMap.put(quesTempList1[0].Id,quesTempList1[0]);
        quesIdwithQuestionMap.put(quesTempList1[1].Id,quesTempList1[1]);
        quesIdwithQuestionMap.put(quesTempList1[2].Id,quesTempList1[2]);
        quesIdwithQuestionMap.put(quesTempList1[3].Id,quesTempList1[3]);
            
        List<string> fieldList = new List<string>();
        fieldList.add('Account_to_Response__c');
        fieldList.add('Issue_Request__c');
        fieldList.add('UPCS_V_Pass_or_Fail__c');
            
        Test.startTest();
            
            List<Questionnaire_Response__c> returnAns = MobileAppUtill.setAnswerWeight(dependAnsList, quesIdwithQuestionMap);
            System.assertEquals(4, returnAns.size()); 
            
            List<Questionnaire_Response__c> returnAns2 = MobileAppUtill.setAnswerWeight(dependAnsList, quesIdwithQuestionMap1);
            System.assertEquals(0, returnAns2.size()); 
            
            List<Questionnaire_Response__c> returnAns1 = MobileAppUtill.setAnswerWeight(dependAnsList, null);
            System.debug('returned answers::'+returnAns1);
            System.assert(returnAns1.size() == 0);
            
            String rtVal = MobileAppUtill.saveDecisionTreeAnswerRecords(dependAnsList);
            System.assert(rtVal != Null);
            
            String rtVal1 = MobileAppUtill.saveDecisionTreeAnswerRecords(null);
            System.assert(rtVal1 != Null);
                
            String returnValue = MobileAppUtill.returnASM('ExAM__Questionnaire_Response__c',fieldList,acc[0].Id);
            System.assert(returnValue != Null);
            
           // List<IssueRequest_Life_Cycle__c> amList = [SELECT Id FROM IssueRequest_Life_Cycle__c];
            String asmFieldsetval = MobileAppUtill.returnASMFieldset(amList[0].Id);
            System.assert(asmFieldsetval != Null);
                
        Test.stopTest();
    }
        
    static testMethod void testSaveAnswerRecords() {
           
        List<IssueRequest_Life_Cycle__c> amList = [SELECT Id FROM IssueRequest_Life_Cycle__c];
        List<Question_Template__c> quesTempList = [SELECT Id,Weight_of_Answer__c, Subquestion_Label__c, Next_Question__c FROM Question_Template__c];
        List<Questionnaire_Response__c> dependAnsList = [SELECT Id,Question_Template__c,Response__c FROM Questionnaire_Response__c];
        List<Main_questionaire__c> assTempList = [SELECT Id FROM Main_questionaire__c];
        List<Id> tempIdList = new  List<Id>();
            for(Main_questionaire__c assTemp : assTempList) {
                tempIdList.add(assTemp.Id);
            }
        System.debug('::::'+quesTempList[0].Next_Question__c);
        Map<Id, Id> quesIdAnsIdMap = new Map<Id, Id>();
        quesIdAnsIdMap.put(quesTempList[0].Id,dependAnsList[0].Id);
        quesIdAnsIdMap.put(quesTempList[1].Id,dependAnsList[1].Id);
        quesIdAnsIdMap.put(quesTempList[2].Id,dependAnsList[2].Id);
        quesIdAnsIdMap.put(quesTempList[3].Id,dependAnsList[3].Id);
        quesIdAnsIdMap.put(quesTempList[4].Id,dependAnsList[4].Id);
            
        Map<Id, Question_Template__c> quesIdwithQuestionMap = new Map<Id, Question_Template__c>();
        quesIdwithQuestionMap.put(quesTempList[0].Id,quesTempList[0]);
        quesIdwithQuestionMap.put(quesTempList[1].Id,quesTempList[1]);
        quesIdwithQuestionMap.put(quesTempList[2].Id,quesTempList[2]);
        quesIdwithQuestionMap.put(quesTempList[3].Id,quesTempList[3]);
                   
        ExAM_Configuration__c ec = new ExAM_Configuration__c();
        ec.Name = 'Configuration';
        ec.Decision_Tree__c = 'Response__c~Priority__c~Comment__c~Pictures';
        ec.Hours__c = 50;
        ec.Primary_Assessment_Type_Template__c = assTempList[0].Id;
        ec.Related_Assessment_Type_1_Template__c = assTempList[1].Id;
        ec.Related_Assessment_Type_2_Template__c = assTempList[2].Id;
        ec.Related_Assessment_Type_3_Template__c = assTempList[3].Id;
        ec.Related_Assessment_Type_4_Template__c = assTempList[4].Id;
        ec.Hide_Related_Assignment_Manager1_Tab__c = false;
        ec.Hide_Related_Assignment_Manager2_Tab__c = false;
        ec.Hide_Related_Assignment_Manager3_Tab__c = false;
        ec.Hide_Related_Assignment_Manager4_Tab__c = false;
        ec.Hide_Data_Viewer_Tab__c = false;
        ec.Hide_AM_List_Tab__c = false;
        ec.Hide_Assessable_Record_Tab__c = false;
        ec.Hide_Knowledge_Article_Tab__c = false;
        ec.Hide_Save_Button__c = false;
        ec.Overall_Status_on_Submit__c = 'Completed';
        ec.Mobile_Sync_Additional_Templates__c = assTempList[0].Id+'~'+assTempList[1].Id+'~'+assTempList[2].Id;
        ec.Mobile_Sync_Assignment_Manager_Statuses__c = 'Completed~open';
        ec.Mobile_Sync_Last_X_Days__c = 20;
        insert ec;
    
        List<RestSaveAnswerRecords.AnswerRecordClass> ansList = new List<RestSaveAnswerRecords.AnswerRecordClass>();
        RestSaveAnswerRecords.AnswerRecordClass ans1 = new RestSaveAnswerRecords.AnswerRecordClass();
        ans1.questiontemplateId = quesTempList[1].Id;
        ans1.assignmentManagerId = amList[1].Id;
        ans1.response ='AnswerTest';
        ans1.comment = 'Good';
        ansList.add(ans1);
           
        RestSaveAnswerRecords.AnswerRecordClass ans2 = new RestSaveAnswerRecords.AnswerRecordClass();
        ans2.questiontemplateId = quesTempList[2].Id;
        ans2.assignmentManagerId = amList[4].Id;
        ans2.response = '20';
        ans2.comment = 'Excellent';
        ansList.add(ans2);
            
        RestSaveAnswerRecords.AnswerRecordClass ans3 = new RestSaveAnswerRecords.AnswerRecordClass();
        ans3.questiontemplateId = quesTempList[3].Id;
        ans3.assignmentManagerId = amList[4].Id;
        ans3.response = '40';
        ans3.comment = 'vG';
        ansList.add(ans3);
        List<Question_Template__c> quesTempList1 = [SELECT Id,Weight_of_Answer__c, Subquestion_Label__c,(SELECT Id, Name,  Question_Template__c, Weight__c FROM Answer_Options__r) FROM Question_Template__c];
                
        Map<Id, Question_Template__c> quesIdwithQuestionMap1 = new Map<Id, Question_Template__c>();
        quesIdwithQuestionMap.put(quesTempList1[0].Id,quesTempList1[0]);
        quesIdwithQuestionMap.put(quesTempList1[1].Id,quesTempList1[1]);
        quesIdwithQuestionMap.put(quesTempList1[2].Id,quesTempList1[2]);
        quesIdwithQuestionMap.put(quesTempList1[3].Id,quesTempList1[3]);
           
        Test.startTest();
            String rtnValue = MobileAppUtill.getAssignmentManagers(tempIdList,'Rest');
            System.assert(rtnValue != Null);
                
            String rtnAnsVal = MobileAppUtill.saveAnswerRecords(ansList,asstempList[1].Id,amList[1].Id,true,'32',quesIdAnsIdMap);
            String rtnAnsVal1 = MobileAppUtill.saveAnswerRecords(ansList,asstempList[5].Id,amList[1].Id,true,'32',quesIdAnsIdMap);
            String rtnAnsVal2 = MobileAppUtill.saveAnswerRecords(ansList,asstempList[0].Id,amList[1].Id,true,'32',quesIdAnsIdMap);
            System.assert(rtnAnsVal != Null);
                
            List<Questionnaire_Response__c> returnAns = MobileAppUtill.setAnswerWeight(dependAnsList,quesIdwithQuestionMap);
            List<Questionnaire_Response__c> returnAns2 = MobileAppUtill.setAnswerWeight(dependAnsList, quesIdwithQuestionMap1);
            System.assertEquals(0, returnAns2.size()); 
        Test.stopTest();
    }
        
    static testMethod void method2a() {
           
        List<IssueRequest_Life_Cycle__c> amList = [SELECT Id FROM IssueRequest_Life_Cycle__c];
        List<Question_Template__c> quesTempList = [SELECT Id,Weight_of_Answer__c, Subquestion_Label__c FROM Question_Template__c];
        List<Questionnaire_Response__c> dependAnsList = [SELECT Id,Question_Template__c,Response__c FROM Questionnaire_Response__c];
        List<Main_questionaire__c> assTempList = [SELECT Id FROM Main_questionaire__c];
        List<Id> tempIdList = new  List<Id>();
        for(Main_questionaire__c assTemp : assTempList) {
            tempIdList.add(assTemp.Id);
        }
        ExAM_Configuration__c ec = new ExAM_Configuration__c();
            ec.Name = 'Configuration';
            ec.Decision_Tree__c = 'Response__c~Priority__c~Comment__c~Pictures';
            ec.Hours__c = 50;
            ec.Primary_Assessment_Type_Template__c = assTempList[0].Id;
            ec.Related_Assessment_Type_1_Template__c = assTempList[1].Id;
            ec.Related_Assessment_Type_2_Template__c = assTempList[2].Id;
            ec.Related_Assessment_Type_3_Template__c = assTempList[3].Id;
            ec.Related_Assessment_Type_4_Template__c = assTempList[4].Id;
            ec.Hide_Related_Assignment_Manager1_Tab__c = false;
            ec.Hide_Related_Assignment_Manager2_Tab__c = false;
            ec.Hide_Related_Assignment_Manager3_Tab__c = false;
            ec.Hide_Related_Assignment_Manager4_Tab__c = false;
            ec.Hide_Data_Viewer_Tab__c = false;
            ec.Hide_AM_List_Tab__c = false;
            ec.Hide_Assessable_Record_Tab__c = false;
            ec.Hide_Knowledge_Article_Tab__c = false;
            ec.Hide_Save_Button__c = false;
            ec.Overall_Status_on_Submit__c = null;
            ec.Mobile_Sync_Additional_Templates__c = assTempList[0].Id+'~'+assTempList[1].Id+'~'+assTempList[2].Id;
            ec.Mobile_Sync_Assignment_Manager_Statuses__c = 'Completed~open';
            ec.Mobile_Sync_Last_X_Days__c = 20;
            insert ec;
            
        Map<Id, Id> quesIdAnsIdMap = new Map<Id, Id>();
        quesIdAnsIdMap.put(quesTempList[0].Id,dependAnsList[0].Id);
        quesIdAnsIdMap.put(quesTempList[1].Id,dependAnsList[1].Id);
        quesIdAnsIdMap.put(quesTempList[2].Id,dependAnsList[2].Id);
        quesIdAnsIdMap.put(quesTempList[3].Id,dependAnsList[3].Id);
        quesIdAnsIdMap.put(quesTempList[4].Id,dependAnsList[4].Id);
            
        Map<Id, Question_Template__c> quesIdwithQuestionMap = new Map<Id, Question_Template__c>();
        quesIdwithQuestionMap.put(quesTempList[0].Id,quesTempList[0]);
        quesIdwithQuestionMap.put(quesTempList[1].Id,quesTempList[1]);
        quesIdwithQuestionMap.put(quesTempList[2].Id,quesTempList[2]);
        quesIdwithQuestionMap.put(quesTempList[3].Id,quesTempList[3]);
                   
        List<RestSaveAnswerRecords.AnswerRecordClass> ansList = new List<RestSaveAnswerRecords.AnswerRecordClass>();
        RestSaveAnswerRecords.AnswerRecordClass ans1 = new RestSaveAnswerRecords.AnswerRecordClass();
        ans1.questiontemplateId = quesTempList[1].Id;
        ans1.assignmentManagerId = amList[1].Id;
        ans1.response ='AnswerTest';
        ans1.comment = 'Good';
        ansList.add(ans1);
           
        RestSaveAnswerRecords.AnswerRecordClass ans2 = new RestSaveAnswerRecords.AnswerRecordClass();
        ans2.questiontemplateId = quesTempList[2].Id;
        ans2.assignmentManagerId = amList[4].Id;
        ans2.response = '20';
        ans2.comment = 'Excellent';
        ansList.add(ans2);
            
        RestSaveAnswerRecords.AnswerRecordClass ans3 = new RestSaveAnswerRecords.AnswerRecordClass();
        ans3.questiontemplateId = quesTempList[3].Id;
        ans3.assignmentManagerId = amList[4].Id;
        ans3.response = '40';
        ans3.comment = 'vG';
        ansList.add(ans3);
           
        Test.startTest();
            String rtnValue = MobileAppUtill.getAssignmentManagers(tempIdList,'Rest');
            System.assert(rtnValue != Null);
            
            String rtnValue4 = MobileAppUtill.getAssignmentManagersNew(tempIdList,'Rest');
            System.assert(rtnValue4 != Null);
                
            String rtnValue1 = MobileAppUtill.getAssignmentManagers(tempIdList,'');
            System.assert(rtnValue1 != Null);
                
            String rtnAnsVal = MobileAppUtill.saveAnswerRecords(ansList,asstempList[1].Id,amList[1].Id,true,'32',quesIdAnsIdMap);
            String rtnAnsVal1 = MobileAppUtill.saveAnswerRecords(ansList,asstempList[5].Id,amList[1].Id,true,'32',quesIdAnsIdMap);
            String rtnAnsVal2 = MobileAppUtill.saveAnswerRecords(ansList,asstempList[5].Id,asstempList[1].Id,true,'32',quesIdAnsIdMap);
            String rtnAnsVal3 = MobileAppUtill.saveAnswerRecords(ansList,asstempList[5].Id,amList[1].Id,true,'32',null);
            System.assert(rtnAnsVal != Null);
                
            List<Questionnaire_Response__c> returnAns = MobileAppUtill.setAnswerWeight(dependAnsList,quesIdwithQuestionMap);
               
        Test.stopTest();
    }

    static testMethod void method3() {
           
        List<Main_questionaire__c> assTempList = [SELECT Id FROM Main_questionaire__c];
        List<IssueRequest_Life_Cycle__c> amList = [SELECT Id FROM IssueRequest_Life_Cycle__c];
        ExAM_Configuration__c ec = new ExAM_Configuration__c();
            ec.Name = 'Configuration';
            ec.Decision_Tree__c = 'Response__c~Priority__c~Comment__c~Pictures';
            ec.Hours__c = 50;
            ec.Primary_Assessment_Type_Template__c = assTempList[0].Id;
            ec.Related_Assessment_Type_1_Template__c = assTempList[1].Id;
            ec.Related_Assessment_Type_2_Template__c = assTempList[2].Id;
            ec.Related_Assessment_Type_3_Template__c = assTempList[3].Id;
            ec.Related_Assessment_Type_4_Template__c = assTempList[4].Id;
            ec.Hide_Related_Assignment_Manager1_Tab__c = false;
            ec.Hide_Related_Assignment_Manager2_Tab__c = false;
            ec.Hide_Related_Assignment_Manager3_Tab__c = false;
            ec.Hide_Related_Assignment_Manager4_Tab__c = false;
            ec.Hide_Data_Viewer_Tab__c = false;
            ec.Hide_AM_List_Tab__c = false;
            ec.Hide_Assessable_Record_Tab__c = false;
            ec.Hide_Knowledge_Article_Tab__c = false;
            ec.Hide_Save_Button__c = false;
            ec.Overall_Status_on_Submit__c = 'Completed';
            ec.Data_Management_Tab_Filter__c = 'Button,RadioPicklist,Text,TextArea,Dropdown Picklist';
            ec.Mobile_Sync_Additional_Templates__c = assTempList[0].Id+'~'+assTempList[1].Id+'~'+assTempList[2].Id;
            ec.Mobile_Sync_Assignment_Manager_Statuses__c = 'Completed~open';
            ec.Mobile_Sync_Last_X_Days__c = 20;
            ec.Mobile_Assessable_Object__c = '{"Account":"ExAM__Facility_Name__c"}';
        insert ec;
        IssueRequest_Life_Cycle__c assManager = new IssueRequest_Life_Cycle__c(Id=amList[0].Id,Related_Assignment_Manager1__c=amList[1].Id, Related_Assignment_Manager2__c=amList[2].Id, Related_Assignment_Manager3__c=amList[3].Id, Related_Assignment_Manager4__c=amList[4].Id);
        update assManager;
            
        IssueRequest_Life_Cycle__c assManager1 = new IssueRequest_Life_Cycle__c(Id=amList[2].Id,Related_Assignment_Manager1__c=amList[5].Id);
        update assManager1;
            
        List<Question_Template__c> quesTempList = [SELECT Id,Weight_of_Answer__c, Subquestion_Label__c FROM Question_Template__c];
        List<Questionnaire_Response__c> quesResList = [SELECT Id,Question_Template__c,Response__c FROM Questionnaire_Response__c];
        Map<Id, Id> quesIdAnsIdMap = new Map<Id, Id>();
        quesIdAnsIdMap.put(quesTempList[0].Id,quesResList[0].Id);
        Attachment attach = new Attachment();
        attach.ParentId = quesResList[4].Id;
        attach.Name = 'Test Attach';
        attach.body=Blob.valueOf('Testing');
        insert attach;
        List<Id>assTempIdList = new List<Id>();
        List<string> tempStringList = new List<string>();
        for(Main_questionaire__c assTemp : assTempList) {
            tempStringList.add(assTemp.Id);
            assTempIdList.add(assTemp.Id);
        }
        List<RestSaveAnswerRecords.AnswerRecordClass> ansList = new List<RestSaveAnswerRecords.AnswerRecordClass>();
        List<Account> acc = [SELECT Id FROM Account]; 
        List<string> stList = new List<string>();
            stList.add('Id');
            stList.add('Name');
            stList.add('ExAM__Response__c');
        List<Id> amIdList = new  List<Id>();
        for(IssueRequest_Life_Cycle__c am : amList) {
            amIdList.add(am.Id);
        }
        Test.startTest();
            String rutnVal = MobileAppUtill.getDecisionTree(tempStringList);
            System.assert(rutnVal != Null);
            System.debug(rutnVal);
                
            String rutnVal3 = MobileAppUtill.getDecisionTree(null);
            System.assert(rutnVal3 != Null);
            System.debug(rutnVal3);
            
                
            String rtnAnsVal = MobileAppUtill.saveAnswerRecords(ansList,asstempList[4].Id,amList[4].Id,true,'7',quesIdAnsIdMap);
            System.assert(rtnAnsVal != Null);
            System.debug(rtnAnsVal);
                
            String returnVal = MobileAppUtill.queryAllAnswerRecords(amList[0].Id,true);
            System.assert(returnVal != Null);
            System.debug(returnVal);
                
            String returnVal1 = MobileAppUtill.queryAllAnswerRecords(assTempList[0].Id,true);
            System.assert(returnVal1 != Null);
            System.debug(returnVal1);
                
            String returnVal2 = MobileAppUtill.queryAllAnswerRecords(null,true);
            System.assert(returnVal2 != Null);
            System.debug(returnVal1);
                
            List<ExAM_Configuration__c> ecList = [SELECT Id, Data_Management_Tab_Filter__c FROM  ExAM_Configuration__c];
            ecList[0].Data_Management_Tab_Filter__c = 'Button';
            update ecList;
                
            String returnVal3 = MobileAppUtill.queryAllAnswerRecords(amList[0].Id,true);
            System.assert(returnVal3 != Null);
            System.debug(returnVal3);
                
            String assRecVal = MobileAppUtill.returnAssessableRecord(amList[0].Id);
            System.assert(assRecVal != Null);
            System.debug(assRecVal);
                
            String assRecVal1 = MobileAppUtill.returnAssessableRecord(amList[6].Id);
            System.assert(assRecVal != Null);
            System.debug(assRecVal1);
                
            String asmFieldsetval = MobileAppUtill.returnASMFieldset(amList[0].Id);
            System.assert(asmFieldsetval != Null);
            System.debug(asmFieldsetval);
                
            String asmFieldsetval1 = MobileAppUtill.returnASMFieldset(null);
            System.assert(asmFieldsetval1 != Null);
            System.debug(asmFieldsetval1);
                
            String returnASMVal = MobileAppUtill.returnASM('ExAM_Questionnaire_Response__c',stList,acc[0].Id);
            System.assert(returnASMVal != Null);
            System.debug(returnASMVal);
            String str = MobileAppUtill.getAssignmentManagersNew(assTempIdList, 'Rest');
            System.debug(str);
            //String str1 = MobileAppUtill.getAssignmentManagersNew(assTempIdList, '');
           // System.debug(str1);
        Test.stopTest();
    }

    static testMethod void method4() {
        
        List<Question_Template__c> quesTempList = [SELECT Id,Weight_of_Answer__c, Subquestion_Label__c FROM Question_Template__c];
        List<IssueRequest_Life_Cycle__c> amList = [SELECT Id FROM IssueRequest_Life_Cycle__c];
        List<Main_questionaire__c> assTempList = [SELECT Id FROM Main_questionaire__c];
        ExAM_Configuration__c ec = new ExAM_Configuration__c();
            ec.Name = 'Configuration';
            ec.Decision_Tree__c = 'Response__c~Priority__c~Comment__c~Pictures';
            ec.Hours__c = 50;
            ec.Primary_Assessment_Type_Template__c = assTempList[0].Id;
            ec.Related_Assessment_Type_1_Template__c = assTempList[1].Id;
            ec.Related_Assessment_Type_2_Template__c = assTempList[2].Id;
            ec.Related_Assessment_Type_3_Template__c = assTempList[3].Id;
            ec.Related_Assessment_Type_4_Template__c = assTempList[4].Id;
            ec.Hide_Related_Assignment_Manager1_Tab__c = false;
            ec.Hide_Related_Assignment_Manager2_Tab__c = false;
            ec.Hide_Related_Assignment_Manager3_Tab__c = false;
            ec.Hide_Related_Assignment_Manager4_Tab__c = false;
            ec.Hide_Data_Viewer_Tab__c = false;
            ec.Hide_AM_List_Tab__c = false;
            ec.Hide_Assessable_Record_Tab__c = false;
            ec.Hide_Knowledge_Article_Tab__c = false;
            ec.Hide_Save_Button__c = false;
            ec.Overall_Status_on_Submit__c = 'Completed';
            ec.Data_Management_Tab_Filter__c = 'Button,RadioPicklist,Text,TextArea,Dropdown Picklist';
            ec.Mobile_Sync_Additional_Templates__c = assTempList[0].Id+'~'+assTempList[1].Id+'~'+assTempList[2].Id;
            ec.Mobile_Sync_Assignment_Manager_Statuses__c = 'Completed~open';
            
            ec.Mobile_Sync_Last_X_Days__c = 20;
       insert ec;
       IssueRequest_Life_Cycle__c assManager = new IssueRequest_Life_Cycle__c(Id=amList[0].Id,Related_Assignment_Manager1__c=amList[1].Id, Related_Assignment_Manager2__c=amList[2].Id, Related_Assignment_Manager3__c=amList[3].Id, Related_Assignment_Manager4__c=amList[4].Id);
       update assManager;
       
       List<string> stList = new List<string>();
           stList.add('Id');
           stList.add('Name');
           stList.add('ExAM__Response__c');
            
       List<Questionnaire_Response__c>res = new  list<Questionnaire_Response__c>{
                new Questionnaire_Response__c(Question_Template__c=quesTempList[0].Id,Response__c='test',Issue_Request__c=amList[0].Id)
       };
       Test.startTest();
           String rVal = MobileAppUtill.queryAllAnswerRecords(amList[4].Id,true);
           System.debug('rVal:::'+rVal);
           System.assert(rVal != Null);
           String rtVal = MobileAppUtill.saveDecisionTreeAnswerRecords(res);
           System.debug('rtVal:::'+rtVal);
           System.assert(rtVal != Null);
       Test.stopTest();
    }
    public static testMethod void testGetAnsForOneTimeAss() {
        
        List<Main_questionaire__c> assTempList = [SELECT Id FROM Main_questionaire__c];
        List<IssueRequest_Life_Cycle__c> amList = [SELECT Id FROM IssueRequest_Life_Cycle__c];
        List<Questionnaire_Response__c> dependAnsList = [SELECT Id FROM Questionnaire_Response__c];
        ExAM_Configuration__c ec = new ExAM_Configuration__c();
            ec.Name = 'Configuration';
            ec.Decision_Tree__c = 'Response__c~Priority__c~Comment__c~Pictures';
            ec.Hours__c = 50;
            ec.Primary_Assessment_Type_Template__c = assTempList[0].Id;
            ec.Related_Assessment_Type_1_Template__c = assTempList[1].Id;
            ec.Related_Assessment_Type_2_Template__c = assTempList[2].Id;
            ec.Related_Assessment_Type_3_Template__c = assTempList[3].Id;
            ec.Related_Assessment_Type_4_Template__c = assTempList[4].Id;
            ec.Hide_Related_Assignment_Manager1_Tab__c = false;
            ec.Hide_Related_Assignment_Manager2_Tab__c = false;
            ec.Hide_Related_Assignment_Manager3_Tab__c = false;
            ec.Hide_Related_Assignment_Manager4_Tab__c = false;
            ec.Hide_Data_Viewer_Tab__c = false;
            ec.Hide_AM_List_Tab__c = false;
            ec.Hide_Assessable_Record_Tab__c = false;
            ec.Hide_Knowledge_Article_Tab__c = false;
            ec.Hide_Save_Button__c = false;
            ec.Overall_Status_on_Submit__c = 'open';
            ec.Mobile_Sync_Additional_Templates__c = assTempList[0].Id+'~'+assTempList[1].Id+'~'+assTempList[2].Id;
            ec.Mobile_Sync_Assignment_Manager_Statuses__c = 'Completed~open';
            ec.Mobile_Sync_Last_X_Days__c = 20;
        insert ec;
        Attachment attach = new Attachment();
        attach.ParentId = dependAnsList[5].Id;
        attach.Name = 'Test Attach';
        attach.body=Blob.valueOf('Testing');
        insert attach;
        String str = MobileAppUtill.getAnswersForOneTimeAssesment(assTempList[0].Id, amList[0].Id);
        System.assert(str != null);
        System.debug(':::str::'+str);
    } 
    
    public static testMethod void testreturnAnswersCount() {
        RestGetAnswersCount.AnswerWeightWrapper ins = new RestGetAnswersCount.AnswerWeightWrapper();
        List<Id> tempIdList = new  List<Id>();
        List<Main_questionaire__c> assTempList = [SELECT Id FROM Main_questionaire__c];
            for(Main_questionaire__c assTemp : assTempList) {
                tempIdList.add(assTemp.Id);
            }
        ins.templateIdList = tempIdList;
        String str = MobileAppUtill.returnAnswersCount(ins);
        System.assert(str != null);
        System.debug(':::Str:::'+str);
          
    } 
    
    public static testMethod void testsaveDecisionTreeAnswerRecordsNew() {
        RestSaveDecisionTreeAnswerRecordsNew.DecisionTreeResponseClass ins = new RestSaveDecisionTreeAnswerRecordsNew.DecisionTreeResponseClass();
        List<Main_questionaire__c> assTempList = [SELECT Id FROM Main_questionaire__c];
        List<Questionnaire_Response__c> dependAnsList = [SELECT Id FROM Questionnaire_Response__c];
        ins.dtResponseList = dependAnsList;
        ins.oneTimeAss = true;
        ins.startQuestion = 'What is ur Fav IceCream?';
        ins.templateId = assTempList[0].Id;
        string str = MobileAppUtill.saveDecisionTreeAnswerRecordsNew(ins);
        RestSaveDecisionTreeAnswerRecordsNew.DecisionTreeResponseClass ins1 = new RestSaveDecisionTreeAnswerRecordsNew.DecisionTreeResponseClass();
        ins1.dtResponseList = null;
        ins1.oneTimeAss = false;
        ins1.startQuestion = 'What is ur Fav IceCream?';
        ins1.templateId = assTempList[0].Id;
        string str1 = MobileAppUtill.saveDecisionTreeAnswerRecordsNew(ins1);
        System.assert(str1 != null);
        System.debug('::::::::::'+str1); 
    } 
    
    public static testMethod void testsaveFeedbackAnswers() {
    
    RestGetFeedbackQuestions.FeedbackQuestionsClass ins = new  RestGetFeedbackQuestions.FeedbackQuestionsClass();
    List<Main_questionaire__c> assTempList = [SELECT Id FROM Main_questionaire__c];
    ExAM_Configuration__c ec = new ExAM_Configuration__c();
            ec.Name = 'Configuration';
            ec.Decision_Tree__c = 'Response__c~Priority__c~Comment__c~Pictures';
            ec.Hours__c = 50;
            ec.Primary_Assessment_Type_Template__c = assTempList[0].Id;
            ec.Related_Assessment_Type_1_Template__c = assTempList[1].Id;
            ec.Related_Assessment_Type_2_Template__c = assTempList[2].Id;
            ec.Related_Assessment_Type_3_Template__c = assTempList[3].Id;
            ec.Related_Assessment_Type_4_Template__c = assTempList[4].Id;
            ec.Hide_Related_Assignment_Manager1_Tab__c = false;
            ec.Hide_Related_Assignment_Manager2_Tab__c = false;
            ec.Hide_Related_Assignment_Manager3_Tab__c = false;
            ec.Hide_Related_Assignment_Manager4_Tab__c = false;
            ec.Hide_Data_Viewer_Tab__c = false;
            ec.Hide_AM_List_Tab__c = false;
            ec.Hide_Assessable_Record_Tab__c = false;
            ec.Hide_Knowledge_Article_Tab__c = false;
            ec.Hide_Save_Button__c = false;
            ec.Overall_Status_on_Submit__c = 'Completed';
            ec.Data_Management_Tab_Filter__c = 'Button,RadioPicklist,Text,TextArea,Dropdown Picklist';
            ec.Mobile_Sync_Additional_Templates__c = assTempList[0].Id+'~'+assTempList[1].Id+'~'+assTempList[2].Id;
            ec.Mobile_Sync_Assignment_Manager_Statuses__c = 'Completed~open';
            ec.Mobile_Sync_Last_X_Days__c = 20;
            ec.Feedback_Template__c = assTempList[0].Id;
            insert ec;
    string str = MobileAppUtill.saveFeedbackAnswers(ins);
    System.assert(str != null);
    System.debug('::str::'+str);
    }
    public static testMethod void testsaveFeedbackAnswers1() {
        List<Main_questionaire__c> assTempList = [SELECT Id FROM Main_questionaire__c];
        List<IssueRequest_Life_Cycle__c> amList = [SELECT Id FROM IssueRequest_Life_Cycle__c];
        IssueRequest_Life_Cycle__c assManager = new IssueRequest_Life_Cycle__c(Id=amList[0].Id,Related_Assignment_Manager1__c=amList[1].Id, Related_Assignment_Manager2__c=amList[2].Id, Related_Assignment_Manager3__c=amList[3].Id, Related_Assignment_Manager4__c=amList[4].Id);
        update assManager;
        List<Questionnaire_Response__c> dependAnsList = [SELECT Id FROM Questionnaire_Response__c];
        List<Question_Template__c> quesTempList = [SELECT Id,Weight_of_Answer__c, Subquestion_Label__c FROM Question_Template__c];
        RestSaveFeedbackAnswers.FeedbackAnswersClass ins = new RestSaveFeedbackAnswers.FeedbackAnswersClass();
        ins.answerList = dependAnsList;
        ins.decisionTreeQuestionId = quesTempList[0].Id;
        ins.screenName = 'Mirror';
        ins.userId = UserInfo.getUserId();
        string str = MobileAppUtill.saveFeedbackAnswers(ins);
        
        ExAM_Configuration__c ec = new ExAM_Configuration__c();
            ec.Name = 'Configuration';
            ec.Decision_Tree__c = 'Response__c~Priority__c~Comment__c~Pictures';
            ec.Hours__c = 50;
            ec.Primary_Assessment_Type_Template__c = assTempList[0].Id;
            ec.Related_Assessment_Type_1_Template__c = assTempList[1].Id;
            ec.Related_Assessment_Type_2_Template__c = assTempList[2].Id;
            ec.Related_Assessment_Type_3_Template__c = assTempList[3].Id;
            ec.Related_Assessment_Type_4_Template__c = assTempList[4].Id;
            ec.Hide_Related_Assignment_Manager1_Tab__c = false;
            ec.Hide_Related_Assignment_Manager2_Tab__c = false;
            ec.Hide_Related_Assignment_Manager3_Tab__c = false;
            ec.Hide_Related_Assignment_Manager4_Tab__c = false;
            ec.Hide_Data_Viewer_Tab__c = false;
            ec.Hide_AM_List_Tab__c = false;
            ec.Hide_Assessable_Record_Tab__c = false;
            ec.Hide_Knowledge_Article_Tab__c = false;
            ec.Hide_Save_Button__c = false;
            ec.Overall_Status_on_Submit__c = 'Completed';
            ec.Data_Management_Tab_Filter__c = 'Button,RadioPicklist,Text,TextArea,Dropdown Picklist';
            ec.Mobile_Sync_Additional_Templates__c = assTempList[0].Id+'~'+assTempList[1].Id+'~'+assTempList[2].Id;
            ec.Mobile_Sync_Assignment_Manager_Statuses__c = 'Completed~open';
            ec.Mobile_Sync_Last_X_Days__c = 20;
            ec.Feedback_Template__c = assTempList[0].Id;
            insert ec;
        
                
        string str2 = MobileAppUtill.saveFeedbackAnswers(ins);
        System.assert(str2 != null);
        System.debug(':::str2::'+str2);
        
        RestGetFeedbackQuestions.FeedbackQuestionsClass ins1 = new RestGetFeedbackQuestions.FeedbackQuestionsClass();
        string str1 = MobileAppUtill.saveFeedbackAnswers(ins1);
        System.assert(str1 != null);
        System.debug(':::str1:::'+str1);
    }    
}