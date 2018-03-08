@RestResource(urlMapping='/smssupport')
global class SMSSupportController {

    @HttpGET
    global static void processRequest() {
        
        String inputCode='', mobileNumber='';
        
        String responseString = '';
        
        RestRequest req = RestContext.request;
        RestResponse restResp = RestContext.response;
        
        mobileNumber = req.params.get('From');
        inputCode = req.params.get('Body');    // send public assessable Id value ie. 'PA'
        
        system.debug('::mobileNumber:::'+mobileNumber);
        system.debug('::inputCode:::'+inputCode);
        try {

            if (String.isNotBlank(inputCode)) {            
                if (String.isNotBlank(mobileNumber)) {                
                    if (inputCode.startswithIgnoreCase('get ')) {
                        inputCode = inputCode.removeStartIgnoreCase('get ');
                        inputCode = inputCode.trim();
                        System.debug(':::inputCod:::'+inputCode);
                        if (inputCode != null && inputCode != '') {

                            List<Public_Assessment__c> pubAssList = [
                                SELECT Assessible_Object_ID__c, Assessment_Template__c, Facility_Name__c, ID, Public_Assessment_URL__c, Short_Code__c
                                FROM   Public_Assessment__c
                                WHERE  Public_Assessment_URL__c != null AND Public_Assessment_URL__c != '' AND Short_Code__c = :inputCode LIMIT 1
                            ];
                    
                            if (pubAssList != null && pubAssList.size() > 0) {
                                responseString = pubAssList[0].Public_Assessment_URL__c;
                            } else {
                                responseString = 'Invalid code';
                            }
                        } else {
                            responseString = 'Please send valid format';// <get> <code> 
                        }
                    } else {

                        //Start IVR SMS
                        List<RecordType> reportTypeList = [
                            SELECT DeveloperName, Id, SObjectType 
                            FROM   RecordType
                            WHERE  SObjectType = 'ExAM__Visitor_Register__c' AND DeveloperName ='SMS_Survey' LIMIT 1
                        ];
                        inputCode = inputCode.trim();
                        string amid = '';

                        List<Visitor_Register__c> visRegList = [
                            SELECT Id, Mobile_Number__c,Question_Template__c, //mobile, question
                                   Question_Template__r.Question_Label__c, Question_Template__r.Subquestion_Label__c,
                                   Question_Template__r.Next_Question__c, Question_Template__r.Section_Question__c,
                                   Question_Template__r.Section_Question__r.Questionnaire_Section__c,
                                   Question_Template__r.Question_Order_No__c, Status__c
                            FROM   Visitor_Register__c 
                            WHERE  Mobile_Number__c = :mobileNumber ORDER BY createddate DESC LIMIT 1                        
                        ];
                        if (visRegList != null && !visRegList.isEmpty() && visRegList[0].Status__c != 'Completed' ) {

                            List<IssueRequest_Life_Cycle__c> queryAMList = [SELECT Id, Visitor_Register__c FROM IssueRequest_Life_Cycle__c WHERE Visitor_Register__c = :visRegList[0].Id LIMIT 1];

                            Map<Id,Question_Template__c> quesIdWithRecMap = new Map<Id,Question_Template__c>([
                                SELECT Id, Next_Question__c, Subquestion_Label__c,
                                       (SELECT Dependent_Question__c, Dependent_Question__r.Name, Help_Text__c, Id, Name, Next_Question__c, Next_Question__r.Name, Weight__c FROM Answer_Options__r)
                                FROM   Question_Template__c
                                WHERE  Id = :visRegList[0].Question_Template__c]);

                            if (queryAMList != NULL && queryAMList.size() > 0) {
                                amid = queryAMList[0].Id; 
                            } else {
                                if (visRegList[0].Question_Template__c != null) {

                                    IssueRequest_Life_Cycle__c newAssignManager = new IssueRequest_Life_Cycle__c();
                                    newAssignManager.Visitor_Register__c = visRegList[0].Id;
                                    newAssignManager.InvestigationType__c = visRegList[0].Question_Template__r.Section_Question__r.Questionnaire_Section__c;
                                    insert newAssignManager;
                                    amid = newAssignManager.Id;
                                }
                            }
                            if ( (visRegList[0].Question_Template__c != NULL && visRegList[0].Question_Template__r.Subquestion_Label__c != null)
                                 || (quesIdWithRecMap != NULL && visRegList[0].Question_Template__c != NULL && 
                                     quesIdWithRecMap.containsKey(visRegList[0].Question_Template__c) && 
                                     quesIdWithRecMap.get(visRegList[0].Question_Template__c).Answer_Options__r.size() > 0)
                            ) {
                                if (inputCode.isNumeric()) {
                                    integer inputVal = integer.valueOf(inputCode);
                                    List<String> answerOptionList = new List<String>();
                                    if( quesIdWithRecMap.values().size() > 0 ){
                                        if ( quesIdWithRecMap.get(visRegList[0].Question_Template__c).Answer_Options__r.size() == 0 ){
                                            answerOptionList = visRegList[0].Question_Template__r.Subquestion_Label__c.split('~');
                                        }
                                        else {
                                            for( Answer_Option__c ansOpt :quesIdWithRecMap.get(visRegList[0].Question_Template__c).Answer_Options__r ){
                                                if ( ansOpt != null && ansOpt.Name != null && ansOpt.Name != '' ){
                                                    answerOptionList.add(ansOpt.Name);
                                                }
                                            }
                                        }
                                    }
                                    if (inputVal > 0 && answerOptionList.size() >= inputVal) {

                                        List<Questionnaire_Response__c> answerInsert = new List<Questionnaire_Response__c> {
                                            new Questionnaire_Response__c(Issue_Request__c = amid, Question_Template__c = visRegList[0].Question_Template__c, Response__c = answerOptionList.get(inputVal - 1))
                                        };
                                        insert answerInsert;
                                        if (visRegList[0].Question_Template__r.Next_Question__c != null || quesIdWithRecMap.get(visRegList[0].Question_Template__c).Answer_Options__r.size() > 0 ) {
                                            String questionName = '';
                                            if ( quesIdWithRecMap.get(visRegList[0].Question_Template__c).Answer_Options__r.size() == 0 ){
                                                if (visRegList[0].Question_Template__r.Next_Question__c.split('~').size() >= inputVal) {
                                                    
                                                    questionName = visRegList[0].Question_Template__r.Next_Question__c.split('~').get(inputVal-1);
                                                } else {
                                                    questionName = visRegList[0].Question_Template__r.Next_Question__c.split('~').get(0);
                                                }
                                            } else {
                                                List<String> nextList = new List<String>();
                                                for( Answer_Option__c ansOpt :quesIdWithRecMap.get(visRegList[0].Question_Template__c).Answer_Options__r ){
                                                    if ( ansOpt != null ){
                                                        nextList.add(ansOpt.Next_Question__r.Name);
                                                    }
                                                }
                                                if ( nextList.size() >= inputVal ){
                                                    questionName = nextList.get(inputVal-1);
                                                } else {
                                                    questionName = nextList.get(0);
                                                }
                                            }

                                            List<Question_Template__c> qustionList = [
                                                SELECT Id, Name, Question_Label__c, Question_Order_No__c, Subquestion_Label__c, Next_Question__c,
                                                       Section_Question__c, Section_Question__r.Questionnaire_Section__c,
                                                       (SELECT Id,Name,Help_Text__c,Weight__c FROM Answer_Options__r)
                                                FROM   Question_Template__c
                                                WHERE  Name = :questionName LIMIT 1
                                            ];
        
                                            if (qustionList != null && !qustionList.isEmpty()) {
                                                responseString = qustionList[0].Question_Label__c;
                                                if ( (qustionList[0].Subquestion_Label__c != null && qustionList[0].Answer_Options__r.size() == 0) 
                                                     || qustionList[0].Answer_Options__r.size() > 0 ) {
                                                    integer i = 1;
                                                    List<String> optlist = new List<String>();
                                                    if ( qustionList[0].Answer_Options__r.size() == 0 ){
                                                        optlist = qustionList[0].Subquestion_Label__c.split('~');
                                                    } else {
                                                        for( Answer_Option__c ansOpt :qustionList[0].Answer_Options__r ){
                                                            if ( ansOpt != null && ansOpt.Name != null && ansOpt.Name != '' ){
                                                                optList.add(ansOpt.Name);
                                                            }
                                                        }
                                                    }
                                                    if ( optlist.size() > 0 ){
                                                        for (String question :optlist ) {
                                                            responseString += '\n'+i+'. '+question;
                                                            i++;
                                                        }
                                                    }
                                                    responseString += '\n(Please type only the number)';
                                                }

                                                List<Visitor_Register__c> vrlist = new List<Visitor_Register__c> {
                                                    new Visitor_Register__c(Id = visRegList[0].Id, Status__c = 'In Progress', Mobile_Number__c = mobileNumber, Question_Template__c = qustionList[0].Id )
                                                };
                                                if (reportTypeList != null && reportTypeList.size() > 0) {
                                                    vrlist[0].RecordTypeId = reportTypeList[0].Id;
                                                }
                                                upsert vrlist;
                                            } else {
                                                responseString = 'Thank you'; //Do not have next question.

                                                List<Visitor_Register__c> vrlist = new List<Visitor_Register__c> {
                                                    new Visitor_Register__c(Id = visRegList[0].Id, Status__c = 'Completed', Mobile_Number__c = mobileNumber)
                                                };
                                                if (reportTypeList != null && reportTypeList.size() > 0) {
                                                    vrlist[0].RecordTypeId = reportTypeList[0].Id;
                                                }
                                                upsert vrlist;
                                            }

                                        } else if( visRegList[0].Question_Template__r.Question_Order_No__c != null) {

                                            List<Question_Template__c> qustionList = [
                                                SELECT   Id, Next_Question__c, Question_Label__c, Question_Order_No__c, 
                                                         Subquestion_Label__c, Section_Question__c, Section_Question__r.Questionnaire_Section__c,
                                                         (SELECT Id,Name,Help_Text__c,Weight__c FROM Answer_Options__r)
                                                FROM     Question_Template__c
                                                WHERE    Section_Question__r.Questionnaire_Section__c =:visRegList[0].Question_Template__r.Section_Question__r.Questionnaire_Section__c            
                                                         AND Question_Order_No__c >:visRegList[0].Question_Template__r.Question_Order_No__c
                                                ORDER BY Question_Order_No__c ASC NULLS LAST LIMIT 1
                                            ];
        
                                            if (qustionList != null && !qustionList.isEmpty()) {
                                                responseString = qustionList[0].Question_Label__c;
                                                if ( (qustionList[0].Subquestion_Label__c != null && qustionList[0].Answer_Options__r.size() == 0) 
                                                     || qustionList[0].Answer_Options__r.size() > 0 ) {
                                                    integer i = 1;
                                                    List<String> optlist = new List<String>();
                                                    if ( qustionList[0].Answer_Options__r.size() == 0 ){
                                                        optlist = qustionList[0].Subquestion_Label__c.split('~');
                                                    } else {
                                                        for( Answer_Option__c ansOpt :qustionList[0].Answer_Options__r ){
                                                            if ( ansOpt != null && ansOpt.Name != null && ansOpt.Name != '' ){
                                                                optList.add(ansOpt.Name);
                                                            }
                                                        }
                                                    }
                                                    if ( optlist.size() > 0 ){
                                                        for (String question :optlist ) {
                                                            responseString += '\n'+i+'. '+question;        
                                                            i++;
                                                        }
                                                    }
                                                    responseString += '\n(Please type only the number)';

                                                }

                                                List<Visitor_Register__c> vrlist = new List<Visitor_Register__c> {
                                                    new Visitor_Register__c(Id = visRegList[0].Id, Status__c = 'In Progress', Mobile_Number__c = mobileNumber,Question_Template__c = qustionList[0].Id )
                                                };
                                                if (reportTypeList != null && reportTypeList.size() > 0) {
                                                    vrlist[0].RecordTypeId = reportTypeList[0].Id;
                                                }
                                                upsert vrlist;
                                            } else { // Do not have next question complete the survey

                                                List<Visitor_Register__c> vrlist = new List<Visitor_Register__c> {
                                                    new Visitor_Register__c(Id = visRegList[0].Id, Status__c = 'Completed', Mobile_Number__c = mobileNumber)
                                                };
                                                if (reportTypeList != null && reportTypeList.size() > 0) {
                                                    vrlist[0].RecordTypeId = reportTypeList[0].Id;
                                                }
                                                upsert vrlist;
                                                responseString = 'Thank you';
                                            }

                                        } else {

                                            List<Visitor_Register__c> vrlist = new List<Visitor_Register__c> {
                                                new Visitor_Register__c(Id = visRegList[0].Id, Status__c = 'Completed', Mobile_Number__c = mobileNumber)
                                            };
                                            if (reportTypeList != null && reportTypeList.size() > 0) {
                                                vrlist[0].RecordTypeId = reportTypeList[0].Id;
                                            }
                                            upsert vrlist;
                                            responseString = 'Thank you';
                                        }  
                                    } else {
                                        responseString = 'Please send correct answer';
                                    }
                                } else {
                                    responseString = 'Please type only the number';
                                }
                            //Do not have question's answer option but sent the next ordered question.
                            } else if( (visRegList[0].Question_Template__c != NULL && visRegList[0].Question_Template__r.Subquestion_Label__c == null) || 
                                        (visRegList[0].Question_Template__c != NULL && visRegList[0].Question_Template__r.Answer_Options__r.size() == 0) ) {          

                                List<Questionnaire_Response__c> answerInsert = new List<Questionnaire_Response__c> {
                                         new Questionnaire_Response__c(Issue_Request__c = amid, Question_Template__c = visRegList[0].Question_Template__c,
                                                                         Response__c = inputCode)
                                 };
                                insert answerInsert;
                                if (visRegList[0].Question_Template__r.Question_Order_No__c != null) {

                                    List<Question_Template__c> qustionList = [
                                        SELECT   Id, Question_Label__c, Question_Order_No__c, 
                                                 Subquestion_Label__c, Next_Question__c,
                                                 Section_Question__c, Section_Question__r.Questionnaire_Section__c,
                                                 (SELECT Id,Name,Help_Text__c,Weight__c FROM Answer_Options__r)
                                        FROM     Question_Template__c
                                        WHERE    Section_Question__r.Questionnaire_Section__c =:visRegList[0].Question_Template__r.Section_Question__r.Questionnaire_Section__c
                                                 AND Question_Order_No__c >:visRegList[0].Question_Template__r.Question_Order_No__c
                                        ORDER BY Question_Order_No__c ASC NULLS LAST LIMIT 1
                                    ];
                                
                                    if (qustionList != null && !qustionList.isEmpty()) {
                                        responseString = qustionList[0].Question_Label__c;
                                        if ( (qustionList[0].Subquestion_Label__c != null && qustionList[0].Answer_Options__r.size() == 0)
                                             || qustionList[0].Answer_Options__r.size() > 0 ) {
                                            integer i = 1;
                                            List<String> optlist = new List<String>();
                                            if ( qustionList[0].Answer_Options__r.size() == 0 ){
                                                optlist = qustionList[0].Subquestion_Label__c.split('~');
                                            } else {
                                                for( Answer_Option__c ansOpt :qustionList[0].Answer_Options__r ){
                                                    if ( ansOpt != null && ansOpt.Name != null && ansOpt.Name != '' ){
                                                        optList.add(ansOpt.Name);
                                                    }
                                                }
                                            }
                                            if ( optlist.size() > 0 ){
                                                for (String question :optlist ) {
                                                    responseString += '\n'+i+'. '+question;        
                                                    i++;
                                                }
                                            }
                                            responseString += '\n(Please type only the number)';
                                         }

                                        List<Visitor_Register__c> vrlist = new List<Visitor_Register__c> {
                                            new Visitor_Register__c(Id = visRegList[0].Id, Status__c = 'In Progress', Mobile_Number__c = mobileNumber,Question_Template__c = qustionList[0].Id )
                                        };
                                        if (reportTypeList != null && reportTypeList.size() > 0) {
                                            vrlist[0].RecordTypeId = reportTypeList[0].Id;
                                        }
                                        upsert vrlist;
                                    } else { // Do not have next question complete the survey

                                        List<Visitor_Register__c> vrlist = new List<Visitor_Register__c> {
                                            new Visitor_Register__c(Id = visRegList[0].Id, Status__c = 'Completed', Mobile_Number__c = mobileNumber)
                                        };
                                        if (reportTypeList != null && reportTypeList.size() > 0) {
                                            vrlist[0].RecordTypeId = reportTypeList[0].Id;
                                        }
                                        upsert vrlist;
                                        responseString = 'Thank you';
                                    }
                                
                                } else {

                                    List<Visitor_Register__c> vrlist = new List<Visitor_Register__c> {
                                        new Visitor_Register__c(Id = visRegList[0].Id, Status__c = 'Completed', Mobile_Number__c = mobileNumber)
                                    };
                                    if (reportTypeList != null && reportTypeList.size() > 0) {
                                        vrlist[0].RecordTypeId = reportTypeList[0].Id;
                                    }
                                    upsert vrlist;
                                    responseString = 'Thank you';
                                }
                            } else {

                                responseString = 'Mismatch your answer please retake survey from first';

                                List<Visitor_Register__c> vrlist = new List<Visitor_Register__c> {
                                    new Visitor_Register__c(Id = visRegList[0].Id, Status__c = 'Completed', Mobile_Number__c = mobileNumber)
                                };
                                if (reportTypeList != null && reportTypeList.size() > 0) {
                                    vrlist[0].RecordTypeId = reportTypeList[0].Id;
                                }
                                upsert vrlist;
                            }
    
                        } else {   // find the assessment template using template short code

                            Map<string,string> objectAPIInPAAndAMMap = new Map<string,string>();

                            string queryStr = 'SELECT Assessible_Object_ID__c, Assessment_Template__c, ID, Public_Assessment_URL__c, Short_Code__c';

                            ExAMUtilClass.AssessableObjectDetails objectDetail = ExAMUtilClass.getAssessableObjectDetails('ExAM__Public_Assessment__c');
                            Map<string, string> fieldsAPIMap = objectDetail.assessableObjectAPIMap;
                            if (fieldsAPIMap != null && fieldsAPIMap.size() > 0) {

                                for (string referenceFieldAPIInPA : fieldsAPIMap.keySet()) {
                                    string referenceFieldAPIInAM = (referenceFieldAPIInPA != 'ExAM__Facility_Name__c') ? referenceFieldAPIInPA.replaceFirst('PA_', 'AM_') : referenceFieldAPIInPA;
                                    objectAPIInPAAndAMMap.put(referenceFieldAPIInPA, referenceFieldAPIInAM);
                                }

                                List<string> referenceFieldsList = new List<string>();
                                referenceFieldsList.addAll( fieldsAPIMap.keySet() );

                                queryStr += ', ';
                                queryStr += string.join(referenceFieldsList, ', ');
                            }
                            queryStr += ' FROM Public_Assessment__c WHERE Short_Code__c =:inputCode LIMIT 1';

                            List<Public_Assessment__c> queryPublicAssList = Database.query(queryStr);

                            if ( queryPublicAssList != null && queryPublicAssList.size() > 0) {
                                if (queryPublicAssList[0].Assessment_Template__c != null) {

                                    List<Question_Template__c> qustionList = [
                                        SELECT      Id, Question_Label__c, Question_Order_No__c, 
                                                    Subquestion_Label__c, Next_Question__c,
                                                    Section_Question__c, Section_Question__r.Questionnaire_Section__c,
                                                    (SELECT Id,Name,Help_Text__c,Weight__c FROM Answer_Options__r)
                                        FROM        Question_Template__c
                                        WHERE       Section_Question__r.Questionnaire_Section__c =:queryPublicAssList[0].Assessment_Template__c
                                        ORDER BY    Question_Order_No__c ASC NULLS LAST LIMIT 1
                                    ];
                                                
                                    if (qustionList != null && !qustionList.isEmpty()) {
                                        responseString = qustionList[0].Question_Label__c;
                                        if ( (qustionList[0].Subquestion_Label__c != null && qustionList[0].Answer_Options__r.size() == 0)
                                             || qustionList[0].Answer_Options__r.size() > 0 ) {
                                            integer i = 1;
                                            List<String> optlist = new List<String>();
                                            if ( qustionList[0].Answer_Options__r.size() == 0 ){
                                                optlist = qustionList[0].Subquestion_Label__c.split('~');
                                            } else {
                                                for( Answer_Option__c ansOpt :qustionList[0].Answer_Options__r ){
                                                    if ( ansOpt != null && ansOpt.Name != null && ansOpt.Name != '' ){
                                                        optList.add(ansOpt.Name);
                                                    }
                                                }
                                            }
                                            if ( optlist.size() > 0 ){
                                                for (String question :optlist ) {
                                                    responseString += '\n'+i+'. '+question;        
                                                    i++;
                                                }
                                            }
                                            responseString += '\n(Please type only the number)';
                                        }   

                                        List<Visitor_Register__c> vrlist = new List<Visitor_Register__c> {
                                                new Visitor_Register__c(Name = mobileNumber, Status__c = 'Started',  Mobile_Number__c = mobileNumber, 
                                                                        Question_Template__c = qustionList[0].Id )
                                        };
                                        if (reportTypeList != null && reportTypeList.size() > 0) {
                                            vrlist[0].RecordTypeId = reportTypeList[0].Id;
                                        }
                                        Savepoint sp = Database.setSavepoint();
                                        try {
                                            insert vrlist;

                                            IssueRequest_Life_Cycle__c AMRecord = new IssueRequest_Life_Cycle__c(InvestigationType__c = queryPublicAssList[0].Assessment_Template__c, Visitor_Register__c = vrList[0].Id);

                                            for (string fd : objectAPIInPAAndAMMap.keySet()) {
                                                if (queryPublicAssList[0].get(fd) != null && queryPublicAssList[0].Assessible_Object_ID__c != null
                                                    && (queryPublicAssList[0].get(fd) == queryPublicAssList[0].Assessible_Object_ID__c)) {
                                                
                                                    AMRecord.put(objectAPIInPAAndAMMap.get(fd), queryPublicAssList[0].get(fd));
                                                }
                                            }
                                            insert AMRecord;

                                        } catch(Exception ex) {
                                            responseString = ex.getMessage();
                                            Database.rollback(sp);
                                        }
                                    }

                                } else {
                                    responseString = 'The "' +inputCode +'" does not have any question'; //'Do not have assessment template'
                                }
                            } else {
                                responseString = 'Please send valid code';
                            }
                        }
                        //End IVR SMS
                    }
                } else {
                    responseString = 'Mobile number empty';
                }
            } else {
            
                responseString = 'Please send correct code';
            }
        }
        catch(Exception e) {
            responseString = e.getMessage();
        }
        
        DOM.Document doc = new DOM.Document();
        dom.XmlNode envelope = doc.createRootElement('Response',null,null);
        dom.XmlNode body = envelope.addChildElement('Message',null,null).addTextNode(responseString);
        
        System.debug(':::'+responseString);
        
        restResp.addHeader('Content-Type', 'text/xml');
        restResp.responseBody = Blob.valueOf(doc.toXmlString());
        restResp.statusCode = 200;
    }
}