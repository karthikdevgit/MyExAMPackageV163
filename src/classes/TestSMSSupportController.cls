@isTest
public class TestSMSSupportController {
    
    static testmethod void smssurvey() {
        Public_Assessment__c pa = new Public_Assessment__c(Short_Code__c = 'xyz123');
        insert pa;
        
        String siteurl ='';
        Public_Assessment_Configuration__c pac = Public_Assessment_Configuration__c.getInstance( UserInfo.getOrganizationId() );
        if (pac != null) {

            siteurl = pac.Site_URL__c;
        } else {
            siteurl = 'https://test12345.com/customerFeedback';
            pac.Site_URL__c = siteurl;
            upsert pac;
        }
        
        
        Account acc = new Account();
        acc.Name = 'TestAcc';
        insert acc;
        
        contact con = new contact();
        con.AccountId=acc.id;
        con.LastName ='testCon';
        insert con;
        
        Main_questionaire__c[] templateList = new Main_questionaire__c[] {
            new Main_questionaire__c(Template_name__c = 'General Safety'),
            new Main_questionaire__c(Template_name__c = 'Fire Safety')
        };
        insert templateList;

        Section_Template__c[] sectionTemplateList = new Section_Template__c[] {
            new Section_Template__c(Questionnaire_Section__c = templateList[0].Id, Section_label__c = 'Section Template 1'),
            new Section_Template__c(Questionnaire_Section__c = templateList[0].Id, Section_label__c = 'Section Template 2'),
            new Section_Template__c(Questionnaire_Section__c = templateList[1].Id, Section_label__c = 'Section Template 3'),
            new Section_Template__c(Questionnaire_Section__c = templateList[1].Id, Section_label__c = 'Section Template 4')
        };
        insert sectionTemplateList; 

        Question_Template__c[] qtList = new Question_Template__c[] {
            new Question_Template__c(Question_Type__c = 'Text', Question_Label__c = 'What is your name?', Section_Question__c = sectionTemplateList[0].Id, Question_Order_No__c = 4),
            new Question_Template__c(Question_Type__c = 'Date', Question_Label__c = 'Your DOB?', Section_Question__c = sectionTemplateList[0].Id, Question_Order_No__c = 3),
            new Question_Template__c(Subquestion_Label__c = 'Cricket~Basket ball~Volley ball', Question_Type__c = 'MultiselectPicklist', Question_Label__c = 'What are your hobbies?', Section_Question__c = sectionTemplateList[1].Id, Question_Order_No__c = 2),
            new Question_Template__c(Subquestion_Label__c = 'Male~Female', Question_Type__c = 'RadioPicklist', Question_Label__c = 'Gender?', Section_Question__c = sectionTemplateList[1].Id,Question_Order_No__c = 1),
            new Question_Template__c(Subquestion_Label__c = 'before 5 years~before 10 years', Question_Type__c = 'RadioPicklist', Question_Label__c = 'When did you joined this company?', Section_Question__c = sectionTemplateList[1].Id,Next_question__c='Q-1~Q-2'),
            new Question_Template__c(Subquestion_Label__c = 'before 1 year~before 2 years', Question_Type__c = 'RadioPicklist', Question_Label__c = 'When did you joined this project?', Section_Question__c = sectionTemplateList[1].Id),
            new Question_Template__c(Subquestion_Label__c = 'result', Question_Type__c = 'Result', Question_Label__c = 'Result Question?', Section_Question__c = sectionTemplateList[1].Id),
            new Question_Template__c(Subquestion_Label__c = '< 5~> 5 but < 10~> 10', Question_Type__c = 'RadioPicklist', Question_Label__c = 'How many years of IT experience do you have?', Section_Question__c = sectionTemplateList[1].Id),
            new Question_Template__c(Subquestion_Label__c = '1~2~3~4~5', Question_Type__c = 'Dropdown Picklist', Question_Label__c = 'How satisfield you are with our service?', Section_Question__c = sectionTemplateList[2].Id, Question_Order_No__c = 5),
            new Question_Template__c(Subquestion_Label__c = '1~2~3~4~5', Question_Type__c = 'RadioPicklist', Question_Label__c = 'How is your overall experience?', Section_Question__c = sectionTemplateList[3].Id),
            new Question_Template__c(Question_Type__c = 'Text', Question_Label__c = 'Where did you completed your schooling', Section_Question__c = sectionTemplateList[3].Id),
            new Question_Template__c(Question_Type__c = 'Text', Question_Label__c = 'Where did you completed your schooling', Section_Question__c = sectionTemplateList[3].Id,Question_Order_No__c = 12),
            new Question_Template__c(Subquestion_Label__c = '1~2~3~4~5', Question_Type__c = 'RadioPicklist', Question_Label__c = 'How is your overall experience?', Section_Question__c = sectionTemplateList[3].Id,Question_Order_No__c = 13)
        };
        insert qtList;
        
        List<Question_Template__c> queryList1 = [SELECT id, Name FROM Question_Template__c WHERE Id IN (:qtList[0].Id,:qtList[2].Id)];
        System.debug(':::queryList1:::'+queryList1);
        if (queryList1 != null && queryList1.size() > 1) {
            Question_Template__c q = new Question_Template__c(id = qtList[5].Id, Next_question__c=queryList1[0].Name+'~'+queryList1[1].Name);
            upsert q;        
        }
        RestRequest req1 = new RestRequest(); 
        RestResponse res1 = new RestResponse();
        
        req1.requestURI = siteurl+'/services/apexrest/smssupport';  
        req1.httpMethod = 'GET';
        req1.params.put('From','1234567890');
        req1.params.put('Body','ABCD123');
        
        RestContext.request = req1;
        RestContext.response = res1;
        SMSSupportController.processRequest();
        
        
        Visitor_Register__c vReg = new Visitor_Register__c();
        //vReg.Visitor__c = 'John';
        //vReg.Visitor_Last_Name__c = 'Honnay';
        vReg.Mobile_Number__c = '1234567890';
        vReg.Status__c = 'started';
        vReg.Question_Template__c = qtList[3].Id;
        insert vReg;
        
        
        IssueRequest_Life_Cycle__c am = new IssueRequest_Life_Cycle__c();
        am.OwnerId = UserInfo.getUserId();
        am.Facility_Name__c = acc.id;
        am.Site_Contact__c = con.id;
        am.Date_Assigned__c = system.today();
        am.Status__c='open';
        am.Priority__c = 'high';
        am.InvestigationType__c =templateList[0].id;
        am.Assessment_Form_Completion__c = 'complete';
        am.Assessment_Date_Time__c = system.today();
        am.Visitor_Register__c = vReg.Id;
        insert am;
        
        
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = siteurl+'/services/apexrest/smssupport';  
        req.httpMethod = 'GET';
        req.params.put('From','1234567890');
        req.params.put('Body','1');
        RestContext.request = req;
        RestContext.response = res;
        SMSSupportController.processRequest();
        
        Visitor_Register__c vReg3 = new Visitor_Register__c();
        //vReg3.Visitor__c = 'Chris';
        //vReg3.Visitor_Last_Name__c = 'Harrison';
        vReg3.Mobile_Number__c = '123456';
        vReg3.Status__c = 'started';
        vReg3.Question_Template__c = qtList[3].Id;
        insert vReg3;
        
        RestRequest req2 = new RestRequest(); 
        RestResponse res2 = new RestResponse();
        req2.requestURI = siteurl+'/services/apexrest/smssupport';  
        req2.httpMethod = 'GET';
        req2.params.put('From','123456');
        req2.params.put('Body','1');
        RestContext.request = req2;
        RestContext.response = res2;
        SMSSupportController.processRequest();
        
        Visitor_Register__c vReg4 = new Visitor_Register__c(Mobile_Number__c = '123456', Status__c = 'started', Question_Template__c = qtList[4].Id);//, Visitor__c = 'George', Visitor_Last_Name__c = 'Bailey'
        insert vReg4;
        
        RestRequest req4 = new RestRequest(); 
        RestResponse res4 = new RestResponse();
        req4.requestURI = siteurl+'/services/apexrest/smssupport';  
        req4.httpMethod = 'GET';
        req4.params.put('From','123456');
        req4.params.put('Body','2');
        RestContext.request = req4;
        RestContext.response = res4;
        SMSSupportController.processRequest();
        
        Visitor_Register__c vReg5 = new Visitor_Register__c(Mobile_Number__c = '123456', Status__c = 'started', Question_Template__c = qtList[5].Id);//, Visitor__c = 'Peter', Visitor_Last_Name__c = 'Shankar'
        insert vReg5;
        
        RestRequest req5 = new RestRequest(); 
        RestResponse res5 = new RestResponse();
        req5.requestURI = siteurl+'/services/apexrest/smssupport';  
        req5.httpMethod = 'GET';
        req5.params.put('From','123456');
        req5.params.put('Body','2');
        RestContext.request = req5;
        RestContext.response = res5;
        SMSSupportController.processRequest();
        
        Visitor_Register__c vReg6 = new Visitor_Register__c(Mobile_Number__c = '1234567', Status__c = 'started', Question_Template__c = qtList[7].Id);//, Visitor__c = 'Kevin', Visitor_Last_Name__c = 'Peterson'
        insert vReg6;
        
        RestRequest req6 = new RestRequest(); 
        RestResponse res6 = new RestResponse();
        req6.requestURI = siteurl+'/services/apexrest/smssupport';  
        req6.httpMethod = 'GET';
        req6.params.put('From','1234567');
        req6.params.put('Body','3');
        RestContext.request = req6;
        RestContext.response = res6;
        SMSSupportController.processRequest();
        
        
        Visitor_Register__c vReg7 = new Visitor_Register__c(Mobile_Number__c = '1234567', Status__c = 'started', Question_Template__c = qtList[8].Id);//, Visitor__c = 'Simon', Visitor_Last_Name__c = 'Jones'
        insert vReg7;
        
        RestRequest req7 = new RestRequest(); 
        RestResponse res7 = new RestResponse();
        req7.requestURI = siteurl+'/services/apexrest/smssupport';  
        req7.httpMethod = 'GET';
        req7.params.put('From','1234567');
        req7.params.put('Body','5');
        RestContext.request = req7;
        RestContext.response = res7;
        SMSSupportController.processRequest();
        
        Visitor_Register__c vReg8 = new Visitor_Register__c(Mobile_Number__c = '1234567', Status__c = 'started', Question_Template__c = qtList[0].Id);//, Visitor__c = 'Ian', Visitor_Last_Name__c = 'Bishop'
        insert vReg8;
        
        RestRequest req8 = new RestRequest(); 
        RestResponse res8 = new RestResponse();
        req8.requestURI = siteurl+'/services/apexrest/smssupport';  
        req8.httpMethod = 'GET';
        req8.params.put('From','1234567');
        req8.params.put('Body','5');
        RestContext.request = req8;
        RestContext.response = res8;
        SMSSupportController.processRequest();
        
        Visitor_Register__c vReg9 = new Visitor_Register__c(Mobile_Number__c = '1234567', Status__c = 'started', Question_Template__c = qtList[1].Id);//, Visitor__c = 'Mohammed', Visitor_Last_Name__c = 'Adams'
        insert vReg9;
        
        RestRequest req9 = new RestRequest(); 
        RestResponse res9 = new RestResponse();
        req9.requestURI = siteurl+'/services/apexrest/smssupport';  
        req9.httpMethod = 'GET';
        req9.params.put('From','1234567');
        req9.params.put('Body','5');
        RestContext.request = req9;
        RestContext.response = res9;
        SMSSupportController.processRequest();
        
        Visitor_Register__c vReg10 = new Visitor_Register__c(Mobile_Number__c = '1234567', Status__c = 'started', Question_Template__c = qtList[10].Id);//, Visitor__c = 'Test', Visitor_Last_Name__c = 'Visitor'
        insert vReg10;
        
        RestRequest req10 = new RestRequest(); 
        RestResponse res10 = new RestResponse();
        req10.requestURI = siteurl+'/services/apexrest/smssupport';  
        req10.httpMethod = 'GET';
        req10.params.put('From','1234567');
        req10.params.put('Body','5');
        RestContext.request = req10;
        RestContext.response = res10;
        SMSSupportController.processRequest();
        
        Visitor_Register__c vReg11 = new Visitor_Register__c(Mobile_Number__c = '1234567', Status__c = 'started', Question_Template__c = qtList[11].Id);//, Visitor__c = 'Test', Visitor_Last_Name__c = 'Visitor 1'
        insert vReg11;
        
        RestRequest req11 = new RestRequest(); 
        RestResponse res11 = new RestResponse();
        req11.requestURI = siteurl+'/services/apexrest/smssupport';  
        req11.httpMethod = 'GET';
        req11.params.put('From','1234567');
        req11.params.put('Body','5');
        RestContext.request = req11;
        RestContext.response = res11;
        SMSSupportController.processRequest();
        
        Visitor_Register__c vReg12 = new Visitor_Register__c(Mobile_Number__c = '1234567', Status__c = 'started', Question_Template__c = qtList[12].Id);//, Visitor__c = 'Test', Visitor_Last_Name__c = 'Visitor 2'
        insert vReg12;
        
        RestRequest req12 = new RestRequest(); 
        RestResponse res12 = new RestResponse();
        req12.requestURI = siteurl+'/services/apexrest/smssupport';  
        req12.httpMethod = 'GET';
        req12.params.put('From','1234567');
        req12.params.put('Body','5');
        RestContext.request = req12;
        RestContext.response = res12;
        SMSSupportController.processRequest();
        
        Visitor_Register__c vReg13 = new Visitor_Register__c(Mobile_Number__c = '1234567', Status__c = 'started');//, Visitor__c = 'Test', Visitor_Last_Name__c = 'Visitor 3'
        insert vReg13;
        
        RestRequest req13 = new RestRequest(); 
        RestResponse res13 = new RestResponse();
        req13.requestURI = siteurl+'/services/apexrest/smssupport';  
        req13.httpMethod = 'GET';
        req13.params.put('From','1234567');
        req13.params.put('Body','5');
        RestContext.request = req13;
        RestContext.response = res13;
        SMSSupportController.processRequest();
        
        Public_Assessment__c pa2 = new Public_Assessment__c(Short_Code__c = 'Shortxyz123',Facility_Name__c = acc.Id,Assessment_Template__c = templateList[0].Id, Assessible_Object_ID__c = ''+acc.Id);
        insert pa2;
        RestRequest req14 = new RestRequest(); 
        RestResponse res14 = new RestResponse();
        req14.requestURI = siteurl+'/services/apexrest/smssupport';  
        req14.httpMethod = 'GET';
        req14.params.put('From','100000123');
        req14.params.put('Body','Shortxyz123');
        RestContext.request = req14;
        RestContext.response = res14;
        SMSSupportController.processRequest();
        system.assertNotEquals(RestContext.response.responseBody, Blob.valueOf('test'));
    }
    static testmethod void smssupport() {
        
        Public_Assessment__c pa = new Public_Assessment__c(Short_Code__c = 'xyz123');
        insert pa;
        
        String siteurl ='';
        Public_Assessment_Configuration__c pac = Public_Assessment_Configuration__c.getInstance( UserInfo.getOrganizationId() );
        if (pac != null) {

            siteurl = pac.Site_URL__c;
        } else {
            siteurl = 'https://test12345.com/customerFeedback';
            pac.Site_URL__c = siteurl;
            upsert pac;
        }
        
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = siteurl+'/services/apexrest/smssupport';  
        req.httpMethod = 'GET';
        req.params.put('From','1234567890');
        req.params.put('Body','xyz123');
        
        RestContext.request = req;
        RestContext.response = res;
        SMSSupportController.processRequest();
        
        List<Public_Assessment__c> palist = [SELECT id, name, Short_Code__c, Public_Assessment_URL__c 
                                                FROM Public_Assessment__c 
                                                WHERE Short_Code__c = 'xyz123' 
                                                LIMIT 1];
        system.assert(palist[0].Public_Assessment_URL__c != null);
        
        
        RestRequest req2 = new RestRequest(); 
        RestResponse res2 = new RestResponse();
        
        req2.params.put('From','1234567890');
        req2.params.put('Body','x');
        
        RestContext.request = req2;
        RestContext.response = res2;
        
        SMSSupportController.processRequest();
        
        RestRequest req3 = new RestRequest(); 
        RestResponse res3 = new RestResponse();
        
        req3.params.put('From','1234567890');
        req3.params.put('Body','');
        
        RestContext.request = req3;
        RestContext.response = res3;
        
        SMSSupportController.processRequest();
        
        system.assertEquals(palist.size(), 1);
    }
    static testmethod void smssupport2() {
        
        Public_Assessment__c pa = new Public_Assessment__c(Short_Code__c = 'xyz123');
        insert pa;
        
        String siteurl ='';
        Public_Assessment_Configuration__c pac = Public_Assessment_Configuration__c.getInstance( UserInfo.getOrganizationId() );
        if (pac != null) {

            siteurl = pac.Site_URL__c;
        } else {
            siteurl = 'https://test12345.com/customerFeedback';
            pac.Site_URL__c = siteurl;
            upsert pac;
        }
        
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = siteurl+'/services/apexrest/smssupport';  
        req.httpMethod = 'GET';
        req.params.put('From','1234567890');
        req.params.put('Body','get xyz123');
        
        RestContext.request = req;
        RestContext.response = res;
        SMSSupportController.processRequest();
        
        List<Public_Assessment__c> palist = [SELECT id, name, Short_Code__c, Public_Assessment_URL__c 
                                                FROM Public_Assessment__c 
                                                WHERE Short_Code__c = 'xyz123' 
                                                LIMIT 1];
        system.assert(palist[0].Public_Assessment_URL__c != null);
        
        
        RestRequest req2 = new RestRequest(); 
        RestResponse res2 = new RestResponse();
        
        req2.requestURI = siteurl+'/services/apexrest/smssupport';  
        req2.httpMethod = 'GET';
        req2.params.put('From','1234567890');
        req2.params.put('Body','get x');
        
        RestContext.request = req2;
        RestContext.response = res2;
        
        SMSSupportController.processRequest();
        
        RestRequest req3 = new RestRequest(); 
        RestResponse res3 = new RestResponse();
        
        req3.requestURI = siteurl+'/services/apexrest/smssupport';  
        req3.httpMethod = 'GET';
        req3.params.put('From','1234567890');
        req3.params.put('Body','get ');
        
        RestContext.request = req3;
        RestContext.response = res3;
        
        SMSSupportController.processRequest();
        system.assertEquals(palist.size(), 1);
    }
}