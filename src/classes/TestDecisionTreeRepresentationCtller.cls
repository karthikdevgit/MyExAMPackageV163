@isTest
public class TestDecisionTreeRepresentationCtller {

    public class RequestClass {
        public string isAnswer;
        public string entity;
    }

    static testmethod void method1() {

        Set<Id> qtnIdSet = new Set<Id>();

        String errorResponse = '';
        Id qtnRecordId;
        DecisionTreeRepresentationController.ResponseClass resp;
        Question_Template__c qtUpdateRec;
        List<Question_Template__c> qtUpdateList = new List<Question_Template__c>();
        Map<String, String> questionLabelAndNameMap = new Map<String, String>();



        resp = new DecisionTreeRepresentationController.ResponseClass('ERROR', 'Assessment Template Id not defined');
        errorResponse = JSON.serialize(resp);

        DecisionTreeRepresentationController dtRepresentationCtrller1 = new DecisionTreeRepresentationController();
        system.assertEquals(dtRepresentationCtrller1.jsonData, errorResponse);

        Account accObj = new Account();
        accObj.Name = 'TestAccount';
        insert accObj;
        
        Account acc = new Account();
        acc.parentId = accObj.Id;
        acc.Name = 'TestAcc';
        insert acc;
        
        Viewer_Custom_Configuration__c vcc = new Viewer_Custom_Configuration__c( Answer_Options__c = true, Data_Management__c = true);
        insert vcc;
        
        Main_questionaire__c templateTestRecord = new Main_questionaire__c();
        templateTestRecord.Template_name__c = 'Unit Template';
        templateTestRecord.Viewer_Configuration__c = vcc.Id;
        insert templateTestRecord;

        resp = new DecisionTreeRepresentationController.ResponseClass('ERROR', 'No Records Exists');
        errorResponse = JSON.serialize(resp);

        ApexPages.CurrentPage().getParameters().put('tempId', templateTestRecord.Id);
        DecisionTreeRepresentationController dtRepresentationCtrller2 = new DecisionTreeRepresentationController();
        system.assertNotEquals(dtRepresentationCtrller2.jsonData, errorResponse);

        Section_Template__c sectionTestRecord = new Section_Template__c(Questionnaire_Section__c = templateTestRecord.id, Section_label__c = 'Test Section');
        insert sectionTestRecord;

        Question_Template__c[] questionTemplates = new List<Question_Template__c> {
            new Question_Template__c(Section_Question__c = sectionTestRecord.id, Subquestion_Label__c = 'Satisfied~Very Satisfied', Question_Label__c = 'How satisfied you are with our service?', Question_Order_No__c = 1, Question_Type__c = 'RadioPicklist', Weight_of_Answer__c = '40~60'),
            new Question_Template__c(Section_Question__c = sectionTestRecord.id, Subquestion_Label__c = 'User Login~Transaction', Question_Label__c = 'Which part of service will you suggest to improve?', Question_Order_No__c = 2, Question_Type__c = 'RadioPicklist', Weight_of_Answer__c = '30~70'),
            new Question_Template__c(Section_Question__c = sectionTestRecord.id, Subquestion_Label__c = 'Strongly Support~Likely to Support', Question_Label__c = 'How you refer us to your friends/collegues?', Question_Order_No__c = 3, Question_Type__c = 'RadioPicklist', Weight_of_Answer__c = '65~35'),
            new Question_Template__c(Section_Question__c = sectionTestRecord.id, Question_Label__c = 'Tell us your valuable suggestion to serve you better?', Question_Order_No__c = 4, Question_Type__c = 'Result')
        };
        insert questionTemplates;

        for (Question_Template__c qt : [SELECT Id, Name, Subquestion_Label__c, Question_Label__c FROM Question_Template__c WHERE Id IN :questionTemplates]) {
            if (!questionLabelAndNameMap.containsKey(qt.Question_Label__c)) {
                questionLabelAndNameMap.put(qt.Question_Label__c, qt.Name);
            }
            qtnIdSet.add( qt.Id );
            qtnRecordId = qt.Id;
        }

        for (Question_Template__c qt : questionTemplates) {

            if (qt.Question_Label__c == 'How satisfied you are with our service?') {

                String nxtQtn = questionLabelAndNameMap.get('Which part of service will you suggest to improve?')+'~'+questionLabelAndNameMap.get('How you refer us to your friends/collegues?');
                qtUpdateRec = new Question_Template__c(Id = qt.Id, Next_Question__c = nxtQtn);
                qtUpdateList.add( qtUpdateRec );
            }
            else if (qt.Question_Label__c == 'Which part of service will you suggest to improve?') {

                String nxtQtn = questionLabelAndNameMap.get('Tell us your valuable suggestion to serve you better?')+'~'+questionLabelAndNameMap.get('Tell us your valuable suggestion to serve you better?');
                qtUpdateRec = new Question_Template__c(Id = qt.Id, Next_Question__c = nxtQtn);
                qtUpdateList.add( qtUpdateRec );
            }
            else if (qt.Question_Label__c == 'How you refer us to your friends/collegues?') {

                String nxtQtn = questionLabelAndNameMap.get('Tell us your valuable suggestion to serve you better?')+'~'+questionLabelAndNameMap.get('Tell us your valuable suggestion to serve you better?');
                qtUpdateRec = new Question_Template__c(Id = qt.Id, Next_Question__c = nxtQtn);
                qtUpdateList.add( qtUpdateRec );
            }
        }

        if (qtUpdateList != null && qtUpdateList.size() > 0) {
            update qtUpdateList;
        }

        ApexPages.CurrentPage().getParameters().put('tempId', templateTestRecord.Id);
        DecisionTreeRepresentationController dtRepresentationCtrller3 = new DecisionTreeRepresentationController();
        system.assertNotEquals(dtRepresentationCtrller3.jsonData, errorResponse);

        String response = DecisionTreeRepresentationController.prepareQuestionTemplates( qtnIdSet );

        JSONGenerator new_gen = JSON.createGenerator(true);
        JSONGenerator response_gen = DecisionTreeRepresentationController.prepareAnswerOption( qtnRecordId, new_gen );

        JSONGenerator new_gen1 = JSON.createGenerator(true);
        DecisionTreeRepresentationController.preparePaginationNodes(null, 1300, 0, true, new Map<Integer, Integer>(), new_gen1, 'Section Templates');

        JSONGenerator new_gen2 = JSON.createGenerator(true);
        DecisionTreeRepresentationController.prepareNextQtn(qtnRecordId, 0, new_gen2);

        RequestClass rqt1 = new RequestClass();
        rqt1.isAnswer = 'false';
        rqt1.entity = 'Section Templates';
        string request1 = JSON.serialize(rqt1);
        DecisionTreeRepresentationController.constructNextQuestionsSet(request1);

        RequestClass rqt2 = new RequestClass();
        rqt2.isAnswer = 'false';
        rqt2.entity = 'Question Templates';
        string request2 = JSON.serialize(rqt2);
        DecisionTreeRepresentationController.constructNextQuestionsSet(request2);

        try {
            RequestClass rqt3 = new RequestClass();
            rqt3.isAnswer = 'false';
            string request3 = JSON.serialize(rqt3);
            DecisionTreeRepresentationController.constructNextQuestionsSet(request3);
        }
        catch(Exception exp) {
            system.assertEquals(exp.getMessage(), 'Section templates not exists below this assessment template');
        }

        RequestClass rqt4 = new RequestClass();
        rqt4.isAnswer = 'true';
        rqt4.entity = 'Section Templates';
        string request4 = JSON.serialize(rqt4);
        DecisionTreeRepresentationController.constructNextQuestionsSet(request4);

        RequestClass rqt5 = new RequestClass();
        rqt5.isAnswer = 'true';
        rqt5.entity = 'Question Templates';
        string request5 = JSON.serialize(rqt5);
        DecisionTreeRepresentationController.constructNextQuestionsSet(request5);

        RequestClass rqt6 = new RequestClass();
        rqt6.isAnswer = 'true';
        string request6 = JSON.serialize(rqt6);
        DecisionTreeRepresentationController.constructNextQuestionsSet(request6);
    }
    static testMethod void method2(){
        /*
Main_questionaire__c mn=  new Main_questionaire__c();
mn.Account__c*/
        Account acc = new Account();
        acc.Name = 'test';
        insert acc; 
        Main_questionaire__c[] tempList = new Main_questionaire__c[]{
            new Main_questionaire__c(Account__c = acc.Id)
                };
                    insert tempList;    
        Section_Template__c[] st = new Section_Template__c[]{
            new Section_Template__c(Questionnaire_Section__c = tempList[0].Id,Section_Label__c = 'test label')
                };
                    insert st; 
        Question_Template__c[] qt = new Question_Template__c[]{
            new Question_Template__c(Question_Label__c='test question1',Section_Question__c = st[0].Id,
                                     Subquestion_Label__c = 'subques1~subques2',//Next_Question__c = 'q1~q2',
                                     Question_Type__c = 'Result',Decision_Tree__c = 'key1:question1 label~key2:question2 label' 
                                    ),
                new Question_Template__c(Question_Label__c='test question2',Section_Question__c = st[0].Id,
                                         Subquestion_Label__c = 'subques1~subques2',//Next_Question__c = 'q1~q2',
                                         Question_Type__c = 'Result',Decision_Tree__c = 'key1:question1 label~key2:question2 label' 
                                        )    
                }; 
                    insert qt;
        qt = [SELECT Name, Next_Question__c FROM Question_Template__c];
        qt[1].Next_Question__c = qt[0].Name+'~'+qt[1].Name;
        qt[0].Next_Question__c = qt[1].Name+'~'+qt[0].Name;
        update qt;
        System.debug('qt'+qt);
        ApexPages.currentPage().getParameters().put('tempId',tempList[0].Id);    
        DecisionTreeRepresentationController dtrc = new DecisionTreeRepresentationController();
        String dTreeres = dtrc.getDecisionTreeQuestions();
        System.debug('dTreeres'+dTreeres);
        String mainObj = '{"recordId":"test","isAnswer":"false","entity":"Section Templates",';
        mainObj = mainObj+'"sectionIdQTPaginationMap":{"test":{"test":["'+acc.Id+'","'+acc.Id+'"]}}}'; 
        DecisionTreeRepresentationController.constructNextQuestionsSet(mainObj);
        JSONGenerator gen = JSON.createGenerator(true);
        Set<Id> sectionIdSet = new Set<Id>();
        sectionIdSet.add(st[0].Id);
        Set<Id> qtnIdset = new Set<Id>();
        qtnIdset.add(qt[0].Id);
        DecisionTreeRepresentationController.prepareSectionTemplates(gen, sectionIdSet);
        DecisionTreeRepresentationController.prepareQuestionTemplates(qtnIdset); 
        Main_questionaire__c[] tempList1 = new Main_questionaire__c[]{
            new Main_questionaire__c(Account__c = acc.Id)
                };
                    insert tempList1;     
        ApexPages.currentPage().getParameters().put('tempId','');    
        DecisionTreeRepresentationController dtrc1 = new DecisionTreeRepresentationController();
        String dTreeres1 = dtrc1.getDecisionTreeQuestions();
        System.debug('dTreeres1'+dTreeres1);
        DecisionTreeRepresentationController.prepareAnswerOption(qt[0].Id, gen);
        DecisionTreeRepresentationController.prepareNextQtn(qt[1].Id, 1, gen);
        List<SObject> sObjList = new List<SObject>();
        for(Integer i=0;i<26;i++){
            sObjList.add(qt[0]);
            sObjList.add(qt[1]);
            sObjList.add(st[0]);    
        }
        
        String forWhichEntity = 'Section Templates'; 
        dtrc1.preparePaginationMap(sObjList, forWhichEntity);
        forWhichEntity = 'Question Templates'; 
        dtrc1.preparePaginationMap(sObjList, forWhichEntity);      
        Map<Integer, Integer> paginationRangeAndTotalmap = new Map<Integer, Integer>();
        
        DecisionTreeRepresentationController.preparePaginationNodes(tempList[0].Id, 26, 2, true, paginationRangeAndTotalmap, gen, 'entity');
        Question_Template__c qtn = new Question_Template__c();
        DecisionTreeRepresentationController.saveNextQuestion(String.valueOf(qt[0].Id), qtn);
        Question_Template__c qtn1 = new Question_Template__c(
            Question_Label__c='test question1',Section_Question__c = st[0].Id,
            Subquestion_Label__c = 'subques1~subques2',//Next_Question__c = 'q1~q2',
            Question_Type__c = 'Result',Decision_Tree__c = 'key1:question1 label~key2:question2 label'
        );
        string response = DecisionTreeRepresentationController.saveNextQuestion(String.valueOf(qt[0].Id), qtn1);
        system.assertEquals(response, 'Record Upserted Successfully');
    }
}