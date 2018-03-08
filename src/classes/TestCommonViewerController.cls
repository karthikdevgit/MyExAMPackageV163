@isTest
public class TestCommonViewerController {

    @testSetUp
    public static void testSetUp() {
    
        List<Account> acList = new List<Account> {
                               new Account(Name = 'TestAcc1') };
        insert acList;

        Viewer_Custom_Configuration__c viewerRec = new Viewer_Custom_Configuration__c();
        insert viewerRec;                        
        
        List<Main_questionaire__c> asstempList = new List<Main_questionaire__c> {
                                                 new Main_questionaire__c (Template_name__c = 'Unit Template',Viewer_Configuration__c = viewerRec.Id, Decision_Tree__c = 'Pictures:true:false:1~External_Id__c:false:false:2~Priority__c:true:false:3~Comment__c:true:false:4~Response__c:true:false:5~Test_text_field__c:true:false:6~deficiency_status__c:true:false:7', One_Time_Assessment__c = true, Assessment_Completed_URL__c = 'https://examdev-dev-ed.my.salesforce.com', Watchlist_Of_Words__c = 'text response~textarea response', ExAM__Generate_Case_Or_Lead__c = 'Case'),//WatchList_Of_words & ExAM__Generate_Case_Or_Lead__c = 'Case' for AMTH
                                                 new Main_questionaire__c (Template_name__c = 'Unit Template',Viewer_Configuration__c = viewerRec.Id, Decision_Tree__c = 'Pictures:true:false:1~External_Id__c:false:false:2~Priority__c:true:false:3~Comment__c:true:false:4~Response__c:true:false:5~Test_text_field__c:true:false:6~deficiency_status__c:true:false:7', One_Time_Assessment__c = true, Assessment_Completed_URL__c = 'www.gmail.com', Watchlist_Of_Words__c = 'text response~textarea response')};
        insert asstempList;
        
        List<IssueRequest_Life_Cycle__c> amList = new List<IssueRequest_Life_Cycle__c>{
                                                  new IssueRequest_Life_Cycle__c(InvestigationType__c = assTempList[0].Id, Facility_Name__c = acList[0].Id, Status__c = 'Open', Field_Start_Time__c = null, Total_Score__c = 70 )};
        insert amList;
        
        List<Section_Template__c> secTempList = new List<Section_Template__c>{
                                                new Section_Template__c(Questionnaire_Section__c = asstempList[0].id, Section_label__c = 'UT Section', Random_Display_Count__c = 1),
                                                new Section_Template__c(Questionnaire_Section__c = asstempList[0].id, Section_label__c = 'UT Section', Random_Display_Count__c = 1),
                                                new Section_Template__c(Questionnaire_Section__c = asstempList[1].id, Section_label__c = 'UT Section', Random_Display_Count__c = 1)};
        insert secTempList;
        
        List<Question_Template__c> quesTempList = new List<Question_Template__c> {
            new Question_Template__c(Section_Question__c = secTempList[0].id, Question_Label__c = 'Test Question1', 
                Question_Order_No__c = 1, Question_Type__c = 'RadioPicklist',Subquestion_Label__c='optA~optB', Weight_of_Answer__c  = '10'),
            new Question_Template__c(Section_Question__c = secTempList[0].id, Question_Label__c = 'Test Question1', 
                Question_Order_No__c = 2, Question_Type__c = 'Hidden',Subquestion_Label__c='optA~optB', Default_Value__c = 'Ans for HiddenQues'),
            new Question_Template__c(Section_Question__c = secTempList[0].id, Question_Label__c = 'Test Question1', Disabled__c = false, Is_Dependent__c = true,
                Question_Order_No__c = 3, Question_Type__c = 'Text',Subquestion_Label__c='optA~optB', Dependent_Question__c = 'Is it ur dependent Ques?', Weight_of_Answer__c  = '10'),
            new Question_Template__c(Section_Question__c = secTempList[0].id, Question_Label__c = 'Test Question1', 
                Question_Order_No__c = 4, Question_Type__c = 'Image',Subquestion_Label__c='optA~optB', Weight_of_Answer__c  = '10'),
            new Question_Template__c(Section_Question__c = secTempList[0].id, Question_Label__c = 'Test Question1', 
                Question_Order_No__c = 5, Question_Type__c = 'Image',Subquestion_Label__c='optA~optB', Has_Picture__c = true, Weight_of_Answer__c  = '10'),
            new Question_Template__c(Section_Question__c = secTempList[0].id, Question_Label__c = 'Test Question1', 
                Question_Order_No__c = 6, Question_Type__c = 'File Question - Answer',Subquestion_Label__c='optA~optB', Weight_of_Answer__c  = '10'),
            new Question_Template__c(Section_Question__c = secTempList[0].id, Question_Label__c = 'Test Question1', 
                Question_Order_No__c = 7, Question_Type__c = 'Result',Subquestion_Label__c='optA~optB', Decision_Tree__c = 'Pictures:true:false:1~Priority__c:true:false:3~Comment__c:true:false:4~Response__c:true:false:5', Disabled__c = false, Weight_of_Answer__c  = '10'),
            new Question_Template__c(Section_Question__c = secTempList[0].id, Question_Label__c = 'Test Question1', 
                Question_Order_No__c = 8, Question_Type__c = 'Result',Subquestion_Label__c='optA~optB', Weight_of_Answer__c  = '10'),
            new Question_Template__c(Section_Question__c = secTempList[0].id, Question_Label__c = 'Test Question1', 
                Question_Order_No__c = 9, Question_Type__c = 'Text',Subquestion_Label__c='optA~optB', Next_Question__c = 'Is it ur next Ques?', Weight_of_Answer__c  = '10'),
            new Question_Template__c(Section_Question__c = secTempList[0].id, Question_Label__c = 'Test Question1', 
                Question_Order_No__c = 10, Question_Type__c = 'Textarea',Subquestion_Label__c='optA~optB', Next_Question__c = '~Is it ur next Ques?', Weight_of_Answer__c  = '10'),
            new Question_Template__c(Section_Question__c = secTempList[0].id, Question_Label__c = 'Test Question1', 
                Question_Order_No__c = 11, Question_Type__c = 'Text',Subquestion_Label__c='optA~optB', Dependent_Question__c = '~Is it ur dependent Ques?', Weight_of_Answer__c  = '10'),
            new Question_Template__c(Section_Question__c = secTempList[0].id, Question_Label__c = 'Test Question1', 
                Question_Order_No__c = 12, Question_Type__c = 'File Question - Answer',Subquestion_Label__c='optA~optB', Weight_of_Answer__c  = '10'),
            new Question_Template__c(Section_Question__c = secTempList[0].id, Question_Label__c = 'Test Question1', 
                Question_Order_No__c = 13, Question_Type__c = 'Signature',Subquestion_Label__c='optA~optB'),
            new Question_Template__c(Section_Question__c = secTempList[0].id, Question_Label__c = 'Test Question1', 
                Question_Order_No__c = 14, Question_Type__c = 'MultiselectPicklist',Subquestion_Label__c='optA~optB', Disabled__c = false),
            new Question_Template__c(Section_Question__c = secTempList[0].id, Question_Label__c = 'Test Question1', 
                Question_Order_No__c = 15, Question_Type__c = 'MultiselectPicklist',Subquestion_Label__c='optA~optB', Disabled__c = false),
            new Question_Template__c(Section_Question__c = secTempList[0].id, Question_Label__c = 'Case Test Question1', 
                Question_Order_No__c = 16, Question_Type__c = 'Date', Disabled__c = false),
            new Question_Template__c(Section_Question__c = secTempList[0].id, Question_Label__c = 'Test Question1', 
                Question_Order_No__c = 17, Question_Type__c = 'Hidden', Default_Value__c = 'Ans for HiddenQues2'),
            new Question_Template__c(Section_Question__c = secTempList[1].id, Question_Label__c = 'Case Test Question1', 
                Question_Order_No__c = 18, Question_Type__c = 'RadioPicklist',Subquestion_Label__c='optA~optB', Disabled__c = false),
            new Question_Template__c(Section_Question__c = secTempList[2].id, Question_Label__c = 'Case Test Question1', 
                Question_Order_No__c = 19, Question_Type__c = 'RadioPicklist',Subquestion_Label__c='optA~optB', Disabled__c = false),
            new Question_Template__c(Section_Question__c = secTempList[2].id, Question_Label__c = 'Case Test Question1', 
                Question_Order_No__c = 20, Question_Type__c = 'Case', Disabled__c = false),
            new Question_Template__c(Section_Question__c = secTempList[2].id, Question_Label__c = 'Case Test Question1', 
                Question_Order_No__c = 21, Question_Type__c = 'Case', Disabled__c = false),
            new Question_Template__c(Section_Question__c = secTempList[2].id, Question_Label__c = 'Number Type Test Question1', 
                Question_Order_No__c = 22, Question_Type__c = 'Number', Disabled__c = false),
            new Question_Template__c(Section_Question__c = secTempList[2].id, Question_Label__c = 'Text Question', 
                Question_Order_No__c = 23, Question_Type__c = 'Text', Disabled__c = false),
            new Question_Template__c(Section_Question__c = secTempList[2].id, Question_Label__c = 'Textarea', 
                Question_Order_No__c = 24, Question_Type__c = 'Textarea', Disabled__c = false),
            new Question_Template__c(Section_Question__c = secTempList[2].id, Question_Label__c = 'Textarea', 
                Question_Order_No__c = 25, Question_Type__c = 'Date', Disabled__c = false),
            new Question_Template__c(Section_Question__c = secTempList[2].id, Question_Label__c = 'Textarea', 
                Question_Order_No__c = 26, Question_Type__c = 'Number', Disabled__c = false),
            new Question_Template__c(Section_Question__c = secTempList[0].id, Question_Label__c = 'Case Test Question1', 
                Question_Order_No__c = 27, Question_Type__c = 'Case', Disabled__c = false)
            };
        insert quesTempList;
        
        List<Question_Template__c> quesTempList1 = new List<Question_Template__c> {
            new Question_Template__c(Section_Question__c = secTempList[0].id, Question_Label__c = 'Test Question1', 
                Question_Order_No__c = 1, Question_Type__c = 'Text',Subquestion_Label__c='optA~optB', Single_Next_Question__c = quesTempList[0].Id)};
        insert quesTempList1;                                               
        List<Answer_Option__c> ansoptions1 = new List<Answer_Option__c> {
            new Answer_Option__c(Question_Template__c = quesTempList[0].Id, Order_No__c = 1, Name = 'optA', Weight__c = 50, Next_Question__c = quesTempList[4].Id),
            new Answer_Option__c(Question_Template__c = quesTempList[0].Id, Order_No__c = 2, Name = 'optB', Weight__c = 50, Next_Question__c  = quesTempList[5].Id),
            new Answer_Option__c(Question_Template__c = quesTempList[4].Id, Order_No__c = 3, Name = 'optA', Weight__c = 50, Dependent_Question__c = quesTempList[4].Id),
            new Answer_Option__c(Question_Template__c = quesTempList[4].Id, Order_No__c = 4, Name = 'optB', Weight__c = 50, Dependent_Question__c = quesTempList[5].Id),
            new Answer_Option__c(Question_Template__c = quesTempList[5].Id, Order_No__c = 5, Name = 'optA', Weight__c = 50),
            new Answer_Option__c(Question_Template__c = quesTempList[5].Id, Order_No__c = 6, Name = 'optB', Weight__c = 50),
            new Answer_Option__c(Question_Template__c = quesTempList[6].Id, Order_No__c = 7, Name = 'optA', Weight__c = 50),
            new Answer_Option__c(Question_Template__c = quesTempList[6].Id, Order_No__c = 8, Name = 'optB', Weight__c = 50),
            new Answer_Option__c(Question_Template__c = quesTempList[13].Id, Order_No__c = 9, Name = 'optA', Weight__c = 50),
            new Answer_Option__c(Question_Template__c = quesTempList[13].Id, Order_No__c = 10, Name = 'multiPickValAns', Weight__c = 50),
            new Answer_Option__c(Question_Template__c = quesTempList[17].Id, Order_No__c = 1, Name = 'optA', Weight__c = 50, Next_Question__c = quesTempList[4].Id),
            new Answer_Option__c(Question_Template__c = quesTempList[17].Id, Order_No__c = 2, Name = 'optB', Weight__c = 50, Next_Question__c  = quesTempList[5].Id)};
        insert ansoptions1;
        
        //Throws Error while giving NextQues from Some other Template
        List<Answer_Option__c> ansoptions2 = new List<Answer_Option__c> {
            new Answer_Option__c(Question_Template__c = quesTempList[18].Id, Order_No__c = 1, Name = 'optA', Weight__c = 50, Next_Question__c = quesTempList[4].Id),
            new Answer_Option__c(Question_Template__c = quesTempList[18].Id, Order_No__c = 2, Name = 'optB', Weight__c = 50, Next_Question__c  = quesTempList[5].Id)};
        try {    
            insert ansoptions2;
        }catch(Exception e) {
            System.assert(e.getMessage().contains('Please provide same template\'s next question for Answer Option Record'));
        } 
        
        //Throws Error While updating MultiQuesType With many NextQues 
        List<Question_Template__c> quesTempList3 = [SELECT Id, Name FROM Question_Template__c];
        quesTempList3[13].Next_Question__c = 'quesTempList3[0].Name ~ quesTempList3[1].Name';
        try {
            update quesTempList3;
        }catch(Exception ex) {
            System.assert(ex.getMessage().contains('Please set only one Next Question for MultiselectPicklist question type'));
        } 
        
        quesTempList3[13].Next_Question__c = 'quesTempList3[0].Name ';
        update quesTempList3; 
       
        //Throws Error While Changing Qt to MultiQuesType With ansoptions having different nextQuestions
        quesTempList3[0].Next_Question__c = 'quesTempList2[0].Name';
        quesTempList3[0].Question_Type__c = 'MultiselectPicklist';
        try{
            update quesTempList3;
        }catch(Exception ex) {
            System.assert(ex.getMessage().contains('All Answer Options should point to the same Next Question for MultiselectPicklist question type'));              
        }        
        
        DateTime d = System.now();
        //Date d = System.now();
        String dateStr =  d.format('MM/dd/YYYY');
       
 
        List<Questionnaire_Response__c> dependAnsList = new  list<Questionnaire_Response__c>{
            new Questionnaire_Response__c(Question_Template__c=quesTempList[0].Id,Response__c='optA',Issue_Request__c=amList[0].Id,
                Weight_Response__c = 50),
            new Questionnaire_Response__c(Question_Template__c=quesTempList[2].Id,Response__c='optA',Issue_Request__c=amList[0].Id,
                Weight_Response__c = 50),
            new Questionnaire_Response__c(Question_Template__c=quesTempList[3].Id,Response__c='Ans4',Issue_Request__c=amList[0].Id,
                Weight_Response__c = 50),
           // new Questionnaire_Response__c(Question_Template__c=quesTempList[4].Id,Response__c='optB',Issue_Request__c=amList[0].Id,
                //Weight_Response__c = 50),
            new Questionnaire_Response__c(Question_Template__c=quesTempList[5].Id,Response__c='optA',Issue_Request__c=amList[0].Id,
                Weight_Response__c = 50),
           // new Questionnaire_Response__c(Question_Template__c=quesTempList[6].Id,Response__c='optA',Issue_Request__c=amList[0].Id,
               // Weight_Response__c = 50, Decision_Tree_Launched_Question__c = quesTempList[0].Id),
            new Questionnaire_Response__c(Question_Template__c=quesTempList[7].Id,Response__c='Ans8Res',Issue_Request__c=amList[0].Id,
                Weight_Response__c = 50, Decision_Tree_Launched_Question__c = quesTempList[0].Id),
            new Questionnaire_Response__c(Question_Template__c=quesTempList[11].Id,Response__c='File Q&A',Issue_Request__c=amList[0].Id,
                Weight_Response__c = 50),
            new Questionnaire_Response__c(Question_Template__c=quesTempList[12].Id,Response__c='Sign',Issue_Request__c=amList[0].Id,
                Weight_Response__c = 50),
            new Questionnaire_Response__c(Question_Template__c=quesTempList[13].Id,Response__c='multiPickValAns',Issue_Request__c=amList[0].Id,
                Weight_Response__c = 50),
            new Questionnaire_Response__c(Question_Template__c=quesTempList[14].Id,Response__c='multiPickValAns2',Issue_Request__c=amList[0].Id,
                Weight_Response__c = 50),
            new Questionnaire_Response__c(Question_Template__c=quesTempList[1].Id,Response__c='Hidden Ans',Issue_Request__c=amList[0].Id,
                Weight_Response__c = 50),
            new Questionnaire_Response__c(Question_Template__c=quesTempList[15].Id,Response__c=string.valueOf(datestr),Issue_Request__c=amList[0].Id,
                Weight_Response__c = 50),
            new Questionnaire_Response__c(Question_Template__c=quesTempList[21].Id,Response__c='145',Issue_Request__c=amList[0].Id,
                Weight_Response__c = 50),
            new Questionnaire_Response__c(Question_Template__c=quesTempList[26].Id,Response__c='caseResponse',Issue_Request__c=amList[0].Id,
                Weight_Response__c = 50)
        };
        insert dependAnsList;
        
 
        List<Question_Template__c> quesTempList2 = [SELECT Id, Name FROM Question_Template__c];
         List<Attachment> attachList = new List<Attachment> {
            new Attachment(ParentId = quesTempList[3].Id, ContentType = 'Image', Name = String.valueof('attachment1'), Body = Blob.valueof('attached')),
            new Attachment(ParentId = quesTempList[4].Id, ContentType = 'Image', Name = String.valueof('Qt('+quesTempList[4].Name+')'), Body = Blob.valueof('attached')),
            new Attachment(ParentId = ansoptions1[2].Id, ContentType = 'Image', Name = String.valueof('Qt('+quesTempList[0].Name+')'), Body = Blob.valueof('attached')),
            new Attachment(ParentId = ansoptions1[3].Id, ContentType = 'Image',Name = String.valueof('Qt('+quesTempList2[4].Name+')'), Body = Blob.valueof('attached')),
            new Attachment(ParentId = dependAnsList[5].Id, ContentType = 'Image',Name = String.valueof('Qt('+quesTempList[11].Name+')'), Body = Blob.valueof('attached10')),
            new Attachment(ParentId = dependAnsList[6].Id, ContentType = 'Image',Name = String.valueof('Qt('+quesTempList[12].Name+')'), Body = Blob.valueof('attached100')),
            new Attachment(ParentId = amList[0].Id, ContentType = 'Image',Name = String.valueof('Qt('+quesTempList2[11].Name+')'), Body = Blob.valueof('attached')),
            new Attachment(ParentId = acList[0].Id, ContentType = 'Image',Name =  String.valueof('Qt('+quesTempList2[12].Name+')'), Body = Blob.valueof('attached')),
            new Attachment(ParentId = dependAnsList[4].Id, ContentType = 'Image',Name =  String.valueof('Qt('+quesTempList2[12].Name+')'), Body = Blob.valueof('attached'))};
        insert attachList;
        
        
        List<Assessable_Fields_Mapping__c> assFieldMappingList = new List<Assessable_Fields_Mapping__c>{
            new Assessable_Fields_Mapping__c(Assessable_Object_API__c = 'Account', Assessment_Template__c = assTempList[0].Id, Question_Template__c = quesTempList[24].Id, Assignment_Manager_Field_API__c = null, Is_Case_Response__c = false, Mapped_From__c = 'Answer', Store_Answer_Response_Or_Score__c = 'Response', Assessable_Object_Field_API__c = 'SLAExpirationDate__c'),
            new Assessable_Fields_Mapping__c(Assessable_Object_API__c = 'Account', Assessment_Template__c = assTempList[0].Id, Question_Template__c = quesTempList[24].Id, Assignment_Manager_Field_API__c = null, Is_Case_Response__c = false, Mapped_From__c = 'Answer', Store_Answer_Response_Or_Score__c = 'Response', Assessable_Object_Field_API__c = 'Test_Datetime__c'),
           // new Assessable_Fields_Mapping__c(Assessable_Object_API__c = 'Account', Assessment_Template__c = assTempList[0].Id, Question_Template__c = quesTempList[0].Id, Assignment_Manager_Field_API__c = null, Is_Case_Response__c = false, Mapped_From__c = 'Answer', Store_Answer_Response_Or_Score__c = 'Response', Assessable_Object_Field_API__c = 'Name'),
            new Assessable_Fields_Mapping__c(Assessable_Object_API__c = 'Account', Assessment_Template__c = assTempList[0].Id, Question_Template__c = quesTempList[24].Id, Assignment_Manager_Field_API__c = null, Is_Case_Response__c = false, Mapped_From__c = 'Answer', Store_Answer_Response_Or_Score__c = 'Response', Assessable_Object_Field_API__c = 'AccountSource'),
            new Assessable_Fields_Mapping__c(Assessable_Object_API__c = 'case', Assessment_Template__c = assTempList[0].Id, Question_Template__c = quesTempList[15].Id, Assignment_Manager_Field_API__c = null, Is_Case_Response__c = true, Mapped_From__c = 'Answer', Store_Answer_Response_Or_Score__c = 'Response', Assessable_Object_Field_API__c = 'ContactId'),
            new Assessable_Fields_Mapping__c(Assessable_Object_API__c = 'case', Assessment_Template__c = assTempList[0].Id, Question_Template__c = quesTempList[19].Id, Assignment_Manager_Field_API__c = null, Is_Case_Response__c = true, Mapped_From__c = 'Answer', Store_Answer_Response_Or_Score__c = 'Response', Assessable_Object_Field_API__c = 'ContactId'),
            new Assessable_Fields_Mapping__c(Assessable_Object_API__c = 'case', Assessment_Template__c = assTempList[0].Id, Question_Template__c = quesTempList[15].Id, Assignment_Manager_Field_API__c = null, Is_Case_Response__c = true, Mapped_From__c = 'Answer', Store_Answer_Response_Or_Score__c = 'Response', Assessable_Object_Field_API__c = 'Test_Date__c'),
            new Assessable_Fields_Mapping__c(Assessable_Object_API__c = 'case', Assessment_Template__c = assTempList[0].Id, Question_Template__c = quesTempList[15].Id, Assignment_Manager_Field_API__c = null, Is_Case_Response__c = true, Mapped_From__c = 'Answer', Store_Answer_Response_Or_Score__c = 'Response', Assessable_Object_Field_API__c = 'Test_Date_Time__c'),
            new Assessable_Fields_Mapping__c(Assessable_Object_API__c = 'Account', Assessment_Template__c = assTempList[0].Id, Question_Template__c = quesTempList[24].Id, Assignment_Manager_Field_API__c = null, Is_Case_Response__c = false, Mapped_From__c = 'Answer', Store_Answer_Response_Or_Score__c = 'Response', Assessable_Object_Field_API__c = 'Name'),
            new Assessable_Fields_Mapping__c(Assessable_Object_API__c = 'Account', Assessment_Template__c = assTempList[0].Id, Question_Template__c = quesTempList[25].Id, Assignment_Manager_Field_API__c = null, Is_Case_Response__c = false, Mapped_From__c = 'Answer', Store_Answer_Response_Or_Score__c = 'Response', Assessable_Object_Field_API__c = 'AnnualRevenue'),
            new Assessable_Fields_Mapping__c(Assessable_Object_API__c = 'Account', Assessment_Template__c = assTempList[0].Id, Question_Template__c = quesTempList[25].Id, Assignment_Manager_Field_API__c = null, Is_Case_Response__c = false, Mapped_From__c = 'Answer', Store_Answer_Response_Or_Score__c = 'Response', Assessable_Object_Field_API__c = 'Adequate_Lighting_Score__c '),
            new Assessable_Fields_Mapping__c(Assessable_Object_API__c = 'Account', Assessment_Template__c = assTempList[0].Id, Question_Template__c = quesTempList[25].Id, Assignment_Manager_Field_API__c = null, Is_Case_Response__c = false, Mapped_From__c = 'Answer', Store_Answer_Response_Or_Score__c = 'Response', Assessable_Object_Field_API__c = 'TickerSymbol'),
            new Assessable_Fields_Mapping__c(Assessable_Object_API__c = 'Account', Assessment_Template__c = assTempList[0].Id, Question_Template__c = quesTempList[25].Id, Assignment_Manager_Field_API__c = null, Is_Case_Response__c = false, Mapped_From__c = 'Answer', Store_Answer_Response_Or_Score__c = 'Response', Assessable_Object_Field_API__c = 'Adequate_Lighting_Score__c '),
            new Assessable_Fields_Mapping__c(Assessable_Object_API__c = 'Account', Assessment_Template__c = assTempList[0].Id, Question_Template__c = quesTempList[25].Id, Assignment_Manager_Field_API__c = null, Is_Case_Response__c = false, Mapped_From__c = 'Answer', Store_Answer_Response_Or_Score__c = 'Response', Assessable_Object_Field_API__c = 'NumberOfEmployees'),
            new Assessable_Fields_Mapping__c(Assessable_Object_API__c = 'Account', Assessment_Template__c = assTempList[0].Id, Question_Template__c = quesTempList[21].Id, Assignment_Manager_Field_API__c = null, Is_Case_Response__c = false, Mapped_From__c = 'Answer', Store_Answer_Response_Or_Score__c = 'Response', Assessable_Object_Field_API__c = 'AnnualRevenue'),
            new Assessable_Fields_Mapping__c(Assessable_Object_API__c = 'Account', Assessment_Template__c = assTempList[0].Id, Question_Template__c = quesTempList[21].Id, Assignment_Manager_Field_API__c = null, Is_Case_Response__c = false, Mapped_From__c = 'Answer', Store_Answer_Response_Or_Score__c = 'Response', Assessable_Object_Field_API__c = 'AccountSource'),
            new Assessable_Fields_Mapping__c(Assessable_Object_API__c = 'Account', Assessment_Template__c = assTempList[0].Id, Question_Template__c = quesTempList[21].Id, Assignment_Manager_Field_API__c = null, Is_Case_Response__c = false, Mapped_From__c = 'Answer', Store_Answer_Response_Or_Score__c = 'Response', Assessable_Object_Field_API__c = 'TickerSymbol'),
            new Assessable_Fields_Mapping__c(Assessable_Object_API__c = 'Account', Assessment_Template__c = assTempList[0].Id, Question_Template__c = quesTempList[21].Id, Assignment_Manager_Field_API__c = null, Is_Case_Response__c = false, Mapped_From__c = 'Answer', Store_Answer_Response_Or_Score__c = 'Response', Assessable_Object_Field_API__c = 'SLAExpirationDate__c')};
           
        insert assFieldMappingList;  
        
        List<Contact> conList = new List<Contact> {
                                new Contact(LastName = 'Casess2', Email = 'contact345@gmail.com')};
        insert conList;  
        
        ExAM_Configuration__c ec = new ExAM_Configuration__c();
        ec.Name = 'Configuration';
        ec.Decision_Tree__c = 'Response__c~Priority__c~Comment__c~Pictures';
        ec.Hours__c = 50;
        ec.Primary_Assessment_Type_Template__c = assTempList[0].Id;
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
       // ec.Mobile_Sync_Additional_Templates__c = assTempList[0].Id+'~'+assTempList[1].Id+'~'+assTempList[2].Id;
        ec.Mobile_Sync_Assignment_Manager_Statuses__c = 'Completed~open';
        ec.Mobile_Sync_Last_X_Days__c = 20;
        ec.Is_Field_Mapping__c = false; // for AM TriggerHandler
        insert ec; 
        
        List<Distribution__c> distributionList = new List<Distribution__c>{
            new Distribution__c(Name='test Distribution1', Landing_Page__c = 'www.google.com'),
            new Distribution__c(Name='test Distribution1', Landing_Page__c = 'https://www.google.com')
        }; 
        insert distributionList;   
        
        List<Public_Assessment__c> paList = new List<Public_Assessment__c> {
            new Public_Assessment__c(Facility_Name__c = acList[0].Id),
            new Public_Assessment__c(Facility_Name__c = acList[0].Id, distribution__c = distributionList[0].Id),
            new Public_Assessment__c(Facility_Name__c = acList[0].Id, distribution__c = distributionList[1].Id)
        };
        insert paList;
        
        List<ExAM__Fact_Score_Data__c> factScoreList = new List<ExAM__Fact_Score_Data__c> {
                                                 new ExAM__Fact_Score_Data__c(ExAM__Assessment_Template__c = assTempList[0].Id, ExAM__Assessment_Completed_URL_JSON__c = '[{"fromScore":"0","toScore":"100","urlStr":"https://www.facebook.com"}]'),
                                                 new ExAM__Fact_Score_Data__c(ExAM__Assessment_Template__c= assTempList[0].Id, ExAM__Assessment_Completed_URL_JSON__c = '[{"fromScore":"0","toScore":"100","urlStr":"www.google.com"}]')};
        insert factScoreList; 
        System.assert(factScoreList.size() != null);                                                                                                                                                       
    }

    public static testMethod void testreturnSectionAndQuestionTemplate() {
        
        List<Main_questionaire__c> asstempList = [ SELECT Id, Name, Show_Image_Upload_Icon__c, Show_Notes_Icon__c, 
                               Show_Question_Number__c, Show_Refresh_Icon__c,
                               Context_Questions_Mapping__c, One_Time_Assessment__c,
                               Auto_Submit__c,Modal_Window_Text__c,Show_Modal_Window__c
                               FROM   Main_questionaire__c];
        List<IssueRequest_Life_Cycle__c> amList = [SELECT Id FROM IssueRequest_Life_Cycle__c];
        List<Section_Template__c> secTempList = [SELECT Id FROM Section_Template__c];
        List<Question_Template__c> quesTempList = [SELECT Id FROM Question_Template__c];
        
        CommonViewerController.ReturnViewerRecordsParamClass retViewRec = new CommonViewerController.ReturnViewerRecordsParamClass();
        retViewRec.assessmentTemplateId = assTempList[0].Id;
        retViewRec.createdASMId = amList[0].Id;
        retViewRec.viewerName = 'lens';
        
        CommonViewerController cvc = new CommonViewerController();
        
        //Case 1: With Decision_Tree__c contains '~'
        string str = CommonViewerController.returnSectionAndQuestionTemplate(retViewRec);
        CommonViewerController.ViewerRecordsClass retStr = (CommonViewerController.ViewerRecordsClass)JSON.deserialize(str, CommonViewerController.ViewerRecordsClass.class);
        
        System.assertEquals(13,retStr.answeredRecord.size());
        System.assertEquals(assTempList[0],retStr.assessmentTemplateRecord);
        System.assertEquals(18,retStr.questionNamewithQuestionTemplate.size());
        System.assertEquals(2,retStr.resultQuestionNamewithQuestionTemplate.size());
        System.assertEquals(1,retStr.dependentQuestionNamewithQuestionTemplate.size());
        System.assertEquals(4,retStr.parentIdAndArrayOfPictureIdMap.size());
        System.assertEquals(11,retStr.quesIdANDAnsIdMap.size());
        System.assertEquals(2,retStr.sectionAndQuestionTemplate.size());
        System.assertEquals(2,retStr.quesIdAndAnsweredAttId.size());
       
        asstempList[0].Decision_Tree__c = 'Pictures:true:false:1';
        update asstempList;
       
        //case 2: Decision_Tree__c without '~'
        string str1 = CommonViewerController.returnSectionAndQuestionTemplate(retViewRec);
        CommonViewerController.ViewerRecordsClass retStr1 = (CommonViewerController.ViewerRecordsClass)JSON.deserialize(str1, CommonViewerController.ViewerRecordsClass.class);
        
        //System.assertEquals(assTempList[0],retStr1.assessmentTemplateRecord);
        System.assertEquals(13,retStr1.answeredRecord.size());
        System.assertEquals(1,retStr1.quesIdAndResponseCount.size());
        
        //case 3: getting caseQueslist
        CommonViewerController.ReturnViewerRecordsParamClass retViewRec1 = new CommonViewerController.ReturnViewerRecordsParamClass();
        retViewRec1.assessmentTemplateId = assTempList[1].Id;
        retViewRec1.createdASMId = amList[0].Id;
        retViewRec1.viewerName = 'lens';
        string str2 = CommonViewerController.returnSectionAndQuestionTemplate(retViewRec1);
        CommonViewerController.ViewerRecordsClass retStr2 = (CommonViewerController.ViewerRecordsClass)JSON.deserialize(str2, CommonViewerController.ViewerRecordsClass.class);
        
        System.assertEquals(assTempList[1],retStr2.assessmentTemplateRecord);
        System.assertEquals(13,retStr2.answeredRecord.size());
        System.assertEquals(1,retStr2.quesIdAndResponseCount.size());
        
        // For testing  AT with OneTimeAssessment = True throws error while having paList (cover AT TriggerHandler) 
        
        List<Main_questionaire__c> asstempList1 = new List<Main_questionaire__c> {
                                                 new Main_questionaire__c (Template_name__c = 'Test Template',  One_Time_Assessment__c = false)};
        insert asstempList1;
        
        List<Public_Assessment__c> paList = new List<Public_Assessment__c> {
                                            new Public_Assessment__c( ExAM__Assessment_Template__c = asstempList1[0].Id )};
        insert paList;                                         
        
        asstempList1[0].One_Time_Assessment__c = true;
        try {
            update asstempList1;
        }catch(Exception ex) {
            System.assert(ex.getMessage().contains('One Time Assessment cannot be set as true since this template has existing public assessments below it'));
        }         
    }
    public static testMethod void testsaveDecisionTreeAnswerRecords() {
        
        List<Main_questionaire__c> asstempList = [SELECT Id FROM Main_questionaire__c];
        List<IssueRequest_Life_Cycle__c> amList = [SELECT Id FROM IssueRequest_Life_Cycle__c];
        List<Question_Template__c> quesTempList = [SELECT Id FROM Question_Template__c];
        List<Questionnaire_Response__c> dependAnsList = [SELECT Id, Question_Template__c, Decision_Tree_Launched_Question__c  FROM Questionnaire_Response__c];
        List<Account> acList = [SELECT Id FROM Account];
        Map<String, String> quesAndAnsMap = new Map<String, String>();
        for(Integer i = 0; i<dependAnsList.size();i++) {
            quesAndAnsMap.put(dependAnsList[i].Id, dependAnsList[i].Question_Template__c);
        } 
        List<Questionnaire_Response__c> dependAnsList1 = new List<Questionnaire_Response__c>{
            new Questionnaire_Response__c(Question_Template__c=quesTempList[4].Id, Response__c='optB',Issue_Request__c=amList[0].Id,
                Weight_Response__c = 50),
            new Questionnaire_Response__c(Question_Template__c=quesTempList[6].Id,Response__c='optA',Issue_Request__c=amList[0].Id,
                Weight_Response__c = 50, Decision_Tree_Launched_Question__c = quesTempList[0].Id)};
            
        dependAnsList1.add(dependAnsList[0]);
        
        //Case1 : with amId, assObjId, assTempId & viewername = 'lens'   
        CommonViewerController.DTSaveParamClass dtSave = new CommonViewerController.DTSaveParamClass();
        dtSave.tempId = asstempList[0].Id;
        dtSave.assessibleObjId = acList[0].Id;
        dtSave.createdAMId = amList[0].Id;
        dtSave.viewerName = 'lens';
        dtSave.decisionTreeAnsList = dependAnsList1;
        dtSave.quesIdANDAnsIdMap = quesAndAnsMap;
        System.debug(':::dtSave1:::'+dtSave);
        string str = CommonViewerController.saveDecisionTreeAnswerRecords(dtSave);
        
        //Case1 :with assobjName without assessibleObjId & amId 
        dtSave.assessibleObjId = '';
        dtSave.createdAMId = '';
        dtSave.assessibleObjName = 'Account';
        string str1 = CommonViewerController.saveDecisionTreeAnswerRecords(dtSave);
        CommonViewerController.DTSaveSuccessClass retstr = (CommonViewerController.DTSaveSuccessClass)JSON.deserialize(str1, CommonViewerController.DTSaveSuccessClass.class);
        System.assertEquals('', retstr.createdAMId);
        System.assertEquals('', retstr.assessableObjId);
        System.assertEquals(3, retstr.questioIdWithCreatedAnswerId.size());
        System.assertEquals(3, retstr.templateIdAndResponsesCount.size());
        
        //Case2 :with assobjName & assessibleObjId
        dtSave.assessibleObjId = acList[0].Id;
        System.debug(':::dtSave1:::'+dtSave);
        string str2 = CommonViewerController.saveDecisionTreeAnswerRecords(dtSave);
        CommonViewerController.DTSaveSuccessClass retstr1 = (CommonViewerController.DTSaveSuccessClass)JSON.deserialize(str2, CommonViewerController.DTSaveSuccessClass.class);
        System.assertEquals(acList[0].Id, retstr1.assessableObjId);
        System.assert( retstr1.createdAMId != null);
        System.assertEquals(3, retstr1.questioIdWithCreatedAnswerId.size());
        System.assertEquals(3, retstr1.templateIdAndResponsesCount.size());
        
        //Case3 :without assobjName with assessibleObjId 
        dtSave.assessibleObjId = '';
        System.debug(':::dtSave1:::'+dtSave);
        string str3 = CommonViewerController.saveDecisionTreeAnswerRecords(dtSave);
        CommonViewerController.DTSaveSuccessClass retstr2 = (CommonViewerController.DTSaveSuccessClass)JSON.deserialize(str3, CommonViewerController.DTSaveSuccessClass.class);
        System.assertEquals('', retstr2.createdAMId);
        System.assertEquals('', retstr2.assessableObjId);
        System.assertEquals(3, retstr2.questioIdWithCreatedAnswerId.size());
        System.assertEquals(3, retstr2.templateIdAndResponsesCount.size());
        System.assert(str3 != null);
        
        CommonViewerController.DTSaveParamClass dtSave1 = new CommonViewerController.DTSaveParamClass();
        dtSave1.tempId = asstempList[0].Id;
        dtSave1.assessibleObjId = acList[0].Id;
        dtSave1.createdAMId = '';
        dtSave1.viewerName = 'lens';
        dtSave1.decisionTreeAnsList = dependAnsList;
        dtSave1.quesIdANDAnsIdMap = quesAndAnsMap;
        dtSave1.assessibleObjName = 'Account';
        string str4 = CommonViewerController.saveDecisionTreeAnswerRecords(dtSave1);
        System.debug(':::dtSave1:::'+dtSave1);
        CommonViewerController.DTSaveSuccessClass retstr4 = (CommonViewerController.DTSaveSuccessClass)JSON.deserialize(str4, CommonViewerController.DTSaveSuccessClass.class);
        System.assert(retstr4.createdAMId != null);
    }
    public static testMethod void testsaveAttachment() {
       
       List<Attachment> attachList = [SELECT Id, ParentId FROM Attachment];
       List<Questionnaire_Response__c> dependAnsList = [SELECT Id, Response__c, Question_Template__c FROM Questionnaire_Response__c];
       System.debug(':::attachList::::'+attachList);
       List<CommonViewerController.AttachmentDetails> AttachmentDetailslist = new List<CommonViewerController.AttachmentDetails>();
       
        List<String> strList = new List<String>();
       
        strList.add(attachList[4].Id);
        strList.add(attachList[5].Id);
        strList.add(attachList[8].Id);
        CommonViewerController.AttachmentDetails attachdet1 = new CommonViewerController.AttachmentDetails();
        attachdet1.isPrivate = true;
        attachdet1.fileNameStr = attachList[0].Id;
        attachdet1.cType = attachList[0].Id;
        attachdet1.parentIdStr = dependAnsList[4].Id;
        attachdet1.imgContent = 'Content123';
        AttachmentDetailslist.add(attachdet1);
        
        CommonViewerController.SaveAttParamClass SaveAttParamcls = new CommonViewerController.SaveAttParamClass();
        SaveAttParamcls.attachDetailList = AttachmentDetailslist;
        SaveAttParamcls.answeredAttIdList = strList;
        
        string str = CommonViewerController.saveAttachment(SaveAttParamcls);
        System.assertEquals('success', str);
        List<String> strList1 = new List<String>();
        for(Integer i=0;i<attachList.size()-1;i++) {
            strList1.add(attachList[i].Id);    
        }
        strList1.add(attachList[4].Id);
        strList1.add(attachList[5].Id);
        CommonViewerController.SaveAttParamClass SaveAttParamcls1 = new CommonViewerController.SaveAttParamClass();
        SaveAttParamcls1.attachDetailList = AttachmentDetailslist;
        SaveAttParamcls1.answeredAttIdList = strList1;
        System.debug('::attachDetailList::'+AttachmentDetailslist);
        string str1 = CommonViewerController.saveAttachment(SaveAttParamcls1);
        System.debug('::attachDetailList::'+AttachmentDetailslist);
        System.assertEquals('success', str1);
        
        List<String> strList2 = new List<String>();
        CommonViewerController.SaveAttParamClass SaveAttParamcls2 = new CommonViewerController.SaveAttParamClass();
        SaveAttParamcls2.attachDetailList = AttachmentDetailslist;
        SaveAttParamcls2.answeredAttIdList = strList2;
        string str2 = CommonViewerController.saveAttachment(SaveAttParamcls2);
        //System.assertEquals('Hai', str2);
        System.assertEquals('success', str2); 
        System.assert(str2 != null);
        
        //For Exception Block
        List<String> strList3 = new List<String>();
        for(Integer i=0;i<attachList.size();i++) {
            strList3.add(attachList[i].Id);    
        }
        
       List<CommonViewerController.AttachmentDetails> AttachmentDetailslist1 = new List<CommonViewerController.AttachmentDetails>();
       for(Integer i=0;i<attachList.size();i++) {
           
           CommonViewerController.AttachmentDetails attachdet = new CommonViewerController.AttachmentDetails();
           attachdet.attId = attachList[i].Id;
           attachdet.fileNameStr = attachList[i].Id;
           attachdet.cType = attachList[i].Id;
           attachdet.parentIdStr = attachList[i].ParentId;
           attachdet.isPrivate = true;
           AttachmentDetailslist1.add(attachdet);
        }
        CommonViewerController.SaveAttParamClass SaveAttParamcls3 = new CommonViewerController.SaveAttParamClass();
        SaveAttParamcls3.attachDetailList = AttachmentDetailslist1;
        SaveAttParamcls3.answeredAttIdList = strList3;
        string str3 = CommonViewerController.saveAttachment(SaveAttParamcls3);
        System.assertEquals('entity is deleted',str3);
    }
    
     
    public static testMethod void testquery() {

        List<Account> accList = new List<Account>([SELECT Id FROM Account]);

        //CASE1
        String soql = 'SELECT Id FROM Account';
        String str = CommonViewerController.query(soql);
        Map<string, Object> result = (Map<String, Object>) JSON.deserializeUntyped(str);
        Integer i  = Integer.valueof(result.get('totalSize'));
        //Integer i = Integer.valueof(result.get('totalSize'));
        System.assertEquals(1, i);
        
        //CASE2
        String soql1 = 'SELECT';
        String str1 = CommonViewerController.query(soql1);
        System.assert(str1 != null);
    }  
    
    //case 1: without assobjId,amId & with assobjName,TempId,anslist
    public static testMethod void testsaveAnswerRecord1() {
       
        List<Main_questionaire__c> asstempList = [SELECT Id FROM Main_questionaire__c];
        List<Question_Template__c> quesTempList = [SELECT Id FROM Question_Template__c];
        List<Account> acList = [SELECT Id FROM Account];
        List<Questionnaire_Response__c> dependAnsList = [SELECT Id, Response__c, Question_Template__c FROM Questionnaire_Response__c];
        
        List<CommonViewerController.AnswerRecordClass> ansRecClsList = new List<CommonViewerController.AnswerRecordClass>();
        CommonViewerController.AnswerRecordClass ansRecCls1 = new CommonViewerController.AnswerRecordClass();
        ansRecCls1.questionTemp = quesTempList[22];
        ansRecCls1.quesResponse = new Questionnaire_Response__c(Response__c='text response');
        ansRecClsList.add(ansRecCls1);
    
        CommonViewerController.AnswerRecordClass ansRecCls2 = new CommonViewerController.AnswerRecordClass();
        ansRecCls2.questionTemp = quesTempList[23];
        ansRecCls2.quesResponse = new Questionnaire_Response__c(Response__c='textarea response');
        ansRecClsList.add(ansRecCls2);
        
        CommonViewerController.AnswerRecordClass ansRecCls3 = new CommonViewerController.AnswerRecordClass();
        ansRecCls3.questionTemp = quesTempList[24];
        ansRecCls3.quesResponse = new Questionnaire_Response__c(Response__c='27/12/2017');
        ansRecClsList.add(ansRecCls3);
        
        CommonViewerController.AnswerRecordClass ansRecCls4 = new CommonViewerController.AnswerRecordClass();
        ansRecCls4.questionTemp = quesTempList[25];
        ansRecCls4.quesResponse = new Questionnaire_Response__c(Response__c='123');
        ansRecClsList.add(ansRecCls4);
        
        CommonViewerController.SaveAnswerRecordParamClass saveAnsParamCls = new CommonViewerController.SaveAnswerRecordParamClass();
        saveAnsParamCls.tempId = asstempList[0].Id;
        saveAnsParamCls.assessibleObjName = 'Account';
        saveAnsParamCls.viewerName = 'public';
        saveAnsParamCls.answerList = ansRecClsList;
        
        String saveResponse = CommonViewerController.saveAnswerRecord(saveAnsParamCls);
        CommonViewerController.saveResponseClass saveresp1 = (CommonViewerController.saveResponseClass)JSON.deserialize(saveResponse, CommonViewerController.saveResponseClass.class);
        List<Account> accList = [SELECT Id , Name,  SLAExpirationDate__c, Adequate_Lighting_Score__c, AnnualRevenue, AccountSource FROM Account];
        List<IssueRequest_Life_Cycle__c> amList = [SELECT Id, InvestigationType__c, Facility_Name__c FROM IssueRequest_Life_Cycle__c];
        //System.assertEquals(null, accList);
        System.assertEquals(asstempList[0].Id,amList[1].InvestigationType__c); 
        System.assertEquals('27/12/2017',accList[1].Name);
       // System.assert(accList[1].SLAExpirationDate__c != null);
       // System.assertEquals(123,accList[1].Adequate_Lighting_Score__c);
        System.assertEquals('27/12/2017',accList[1].AccountSource);
        System.assertEquals(123,accList[1].AnnualRevenue);
        System.assertEquals(0,saveResp1.quesIdwithAnsIdMap.size());
        System.assertEquals(accList[1].Id,saveResp1.assessableObjectId);
        System.assertEquals('Assignment Manager updated successfully.',saveresp1.successMsg);
        
        //For saveAnswerRecord Exception
        List<CommonViewerController.AnswerRecordClass> ansRecClsList2 = new List<CommonViewerController.AnswerRecordClass>();
        CommonViewerController.AnswerRecordClass ansRecCls5 = new CommonViewerController.AnswerRecordClass();
        ansRecCls5.questionTemp = quesTempList[20];
        ansRecCls5.quesResponse = new Questionnaire_Response__c(Response__c='text response');
        ansRecClsList2.add(ansRecCls5);
        saveAnsParamCls.answerList = ansRecClsList2;
        
        String saveResponse1 = CommonViewerController.saveAnswerRecord(saveAnsParamCls);
        CommonViewerController.saveResponseClass saveresp2 = (CommonViewerController.saveResponseClass)JSON.deserialize(saveResponse1, CommonViewerController.saveResponseClass.class);
    }

    //Case 2: Without amId & with assObjId , assObjRefForAmCreation
    public static testMethod void testsaveAnswerRecord2() {
    
        List<Main_questionaire__c> asstempList = [SELECT Id FROM Main_questionaire__c];
        List<Question_Template__c> quesTempList = [SELECT Id FROM Question_Template__c];
        List<Account> acList = [SELECT Id FROM Account];
    
        List<CommonViewerController.AnswerRecordClass> ansRecClsList = new List<CommonViewerController.AnswerRecordClass>();
        CommonViewerController.AnswerRecordClass ansRecCls1 = new CommonViewerController.AnswerRecordClass();
        ansRecCls1.questionTemp = quesTempList[22];
        ansRecCls1.quesResponse = new Questionnaire_Response__c(Response__c='text response');
        ansRecClsList.add(ansRecCls1);
    
        CommonViewerController.AnswerRecordClass ansRecCls2 = new CommonViewerController.AnswerRecordClass();
        ansRecCls2.questionTemp = quesTempList[23];
        ansRecCls2.quesResponse = new Questionnaire_Response__c(Response__c='textarea response');
        ansRecClsList.add(ansRecCls2);
    
        CommonViewerController.SaveAnswerRecordParamClass saveAnsParamCls = new CommonViewerController.SaveAnswerRecordParamClass();
        saveAnsParamCls.tempId = asstempList[0].Id;
        saveAnsParamCls.assessibleObjName = 'Account';
        saveAnsParamCls.assessibleObjId  = acList[0].Id;
        saveAnsParamCls.viewerName = 'public';
        saveAnsParamCls.answerList = ansRecClsList;

        String saveResponse = CommonViewerController.saveAnswerRecord(saveAnsParamCls);
        CommonViewerController.saveResponseClass saveresp1 = (CommonViewerController.saveResponseClass)JSON.deserialize(saveResponse, CommonViewerController.saveResponseClass.class);
        List<IssueRequest_Life_Cycle__c> amList = [SELECT Id, InvestigationType__c, Facility_Name__c FROM IssueRequest_Life_Cycle__c];
        System.assertEquals(asstempList[0].Id,amList[1].InvestigationType__c); 
        System.assertEquals('Assignment Manager updated successfully.',saveresp1.successMsg);
    }
    
    //case 3: With amId
    public static testMethod void testsaveAnswerRecord3() {
        
        List<Main_questionaire__c> asstempList = [SELECT Id FROM Main_questionaire__c];
        List<Question_Template__c> quesTempList = [SELECT Id FROM Question_Template__c];
        List<Account> acList = [SELECT Id FROM Account];
        List<IssueRequest_Life_Cycle__c> amList = [SELECT Id, Total_Score__c FROM IssueRequest_Life_Cycle__c];
        List<Questionnaire_Response__c> dependAnsList = [SELECT Id, Response__c, Question_Template__c FROM Questionnaire_Response__c];
        Map<Id, Id> quesIdAnsIdMap = new Map<Id, Id>();
        for(Integer i = 0; i< dependAnsList.size();i++) {
            quesIdAnsIdMap .put(dependAnsList[i].Question_Template__c ,dependAnsList[i].Id);
        }
        
        List<CommonViewerController.AnswerRecordClass> ansRecClsList = new List<CommonViewerController.AnswerRecordClass>();
        CommonViewerController.AnswerRecordClass ansRecCls1 = new CommonViewerController.AnswerRecordClass();
        ansRecCls1.questionTemp = quesTempList[22];
        ansRecCls1.quesResponse = new Questionnaire_Response__c(Response__c='text response');
        ansRecClsList.add(ansRecCls1);
    
        CommonViewerController.AnswerRecordClass ansRecCls2 = new CommonViewerController.AnswerRecordClass();
        ansRecCls2.questionTemp = quesTempList[23];
        ansRecCls2.quesResponse = new Questionnaire_Response__c(Response__c='textarea response');
        ansRecClsList.add(ansRecCls2);
        
        CommonViewerController.AnswerRecordClass ansRecCls3 = new CommonViewerController.AnswerRecordClass();
        ansRecCls3.questionTemp = quesTempList[0];
        ansRecCls3.quesResponse = dependAnsList[0];
        ansRecClsList.add(ansRecCls3);
        
        CommonViewerController.SaveAnswerRecordParamClass saveAnsParamCls = new CommonViewerController.SaveAnswerRecordParamClass();
        saveAnsParamCls.tempId = asstempList[0].Id;
        saveAnsParamCls.assessibleObjName = 'Account';
        saveAnsParamCls.assessibleObjId  = acList[0].Id;
        saveAnsParamCls.viewerName = 'public';
        saveAnsParamCls.answerList = ansRecClsList;
        saveAnsParamCls.amId = amList[0].Id; 
        saveAnsParamCls.quesIdANDAnsIdMap = quesIdAnsIdMap;

        String saveResponse = CommonViewerController.saveAnswerRecord(saveAnsParamCls);
        CommonViewerController.saveResponseClass saveresp1 = (CommonViewerController.saveResponseClass)JSON.deserialize(saveResponse, CommonViewerController.saveResponseClass.class);
        List<Account> accList = [SELECT Id , Name FROM Account];
        
        System.assertEquals(1,saveResp1.quesIdwithAnsIdMap.size());
        System.assertEquals(accList[0].Id,saveResp1.assessableObjectId);
        System.assertEquals('Assignment Manager updated successfully.',saveresp1.successMsg);
    }
    //Case 4 : with ViewerName = 'Public', paId
     public static testMethod void testsaveAnswerRecord4() {
        
        List<Main_questionaire__c> asstempList = [SELECT Id FROM Main_questionaire__c];
        List<Question_Template__c> quesTempList = [SELECT Id FROM Question_Template__c];
        List<Account> acList = [SELECT Id FROM Account];
        List<IssueRequest_Life_Cycle__c> amList = [SELECT Id, Total_Score__c FROM IssueRequest_Life_Cycle__c];
        List<Public_Assessment__c> paList = [SELECT Id FROM Public_Assessment__c];
        List<Questionnaire_Response__c> dependAnsList = [SELECT Id, Response__c, Question_Template__c FROM Questionnaire_Response__c];
        Map<Id, Id> quesIdAnsIdMap = new Map<Id, Id>();
        for(Integer i = 0; i< dependAnsList.size();i++) {
            quesIdAnsIdMap .put(dependAnsList[i].Question_Template__c ,dependAnsList[i].Id);
        }
        
        List<CommonViewerController.AnswerRecordClass> ansRecClsList = new List<CommonViewerController.AnswerRecordClass>();
        CommonViewerController.AnswerRecordClass ansRecCls1 = new CommonViewerController.AnswerRecordClass();
        ansRecCls1.questionTemp = quesTempList[22];
        ansRecCls1.quesResponse = new Questionnaire_Response__c(Response__c='text response');
        ansRecClsList.add(ansRecCls1);
    
        CommonViewerController.AnswerRecordClass ansRecCls2 = new CommonViewerController.AnswerRecordClass();
        ansRecCls2.questionTemp = quesTempList[23];
        ansRecCls2.quesResponse = new Questionnaire_Response__c(Response__c='textarea response');
        ansRecClsList.add(ansRecCls2);
        
        CommonViewerController.AnswerRecordClass ansRecCls3 = new CommonViewerController.AnswerRecordClass();
        ansRecCls3.questionTemp = quesTempList[0];
        ansRecCls3.quesResponse = dependAnsList[0];
        ansRecClsList.add(ansRecCls3);
        
        CommonViewerController.AnswerRecordClass ansRecCls4 = new CommonViewerController.AnswerRecordClass();
        ansRecCls4.questionTemp = quesTempList[15];
        ansRecCls4.quesResponse = dependAnsList[10];
        ansRecClsList.add(ansRecCls4);
        
        CommonViewerController.SaveAnswerRecordParamClass saveAnsParamCls = new CommonViewerController.SaveAnswerRecordParamClass();
        saveAnsParamCls.tempId = asstempList[0].Id;
        saveAnsParamCls.assessibleObjName = 'Account';
        saveAnsParamCls.assessibleObjId  = acList[0].Id;
        saveAnsParamCls.viewerName = 'public';
        saveAnsParamCls.answerList = ansRecClsList;
        saveAnsParamCls.amId = amList[0].Id; 
        saveAnsParamCls.quesIdANDAnsIdMap = quesIdAnsIdMap;
        saveAnsParamCls.publicAssessmentId = paList[0].Id;
        saveAnsParamCls.startTimeStr = String.valueOf(System.now());

        String saveResponse = CommonViewerController.saveAnswerRecord(saveAnsParamCls);
        CommonViewerController.saveResponseClass saveresp1 = (CommonViewerController.saveResponseClass)JSON.deserialize(saveResponse, CommonViewerController.saveResponseClass.class);
        List<Account> accList = [SELECT Id , Name FROM Account];
        
        System.assertEquals(2,saveResp1.quesIdwithAnsIdMap.size());
        System.assertEquals(accList[0].Id,saveResp1.assessableObjectId);
        System.assertEquals('Assignment Manager updated successfully.',saveresp1.successMsg);
        
        test.startTest();
        //without https in AT Url
        saveAnsParamCls.tempId = asstempList[1].Id;
        String saveResponse1 = CommonViewerController.saveAnswerRecord(saveAnsParamCls);
        CommonViewerController.saveResponseClass saveresp2 = (CommonViewerController.saveResponseClass)JSON.deserialize(saveResponse1, CommonViewerController.saveResponseClass.class);
        List<Account> accList1 = [SELECT Id , Name FROM Account];
        
        System.assertEquals(2,saveResp2.quesIdwithAnsIdMap.size());
        System.assertEquals(accList1[0].Id,saveResp2.assessableObjectId);
        System.assertEquals('Assignment Manager updated successfully.',saveresp2.successMsg);
        System.assertEquals('https://www.gmail.com',saveresp2.returnURL);
        
        //without https in Factscore Url
        List<Fact_Score_Data__c> factScoreList = [SELECT Id,  Assessment_Completed_URL_JSON__c  FROM Fact_Score_Data__c];
        factScoreList[0].Assessment_Completed_URL_JSON__c = '[{"fromScore":"0","toScore":"100","urlStr":"www.google.com"}]';
        update factScoreList[0];
        
        saveAnsParamCls.tempId = asstempList[0].Id;
        String saveResponse3 = CommonViewerController.saveAnswerRecord(saveAnsParamCls);
        CommonViewerController.saveResponseClass saveresp3 = (CommonViewerController.saveResponseClass)JSON.deserialize(saveResponse3, CommonViewerController.saveResponseClass.class);
        List<Account> accList2 = [SELECT Id , Name FROM Account];
        
        System.assertEquals(2,saveResp3.quesIdwithAnsIdMap.size());
        System.assertEquals(accList2[0].Id,saveResp3.assessableObjectId);
        System.assertEquals('Assignment Manager updated successfully.',saveresp3.successMsg);
        System.assertEquals('https://www.gmail.com',saveresp2.returnURL);
       
         //without https in Factscore Url
        List<Fact_Score_Data__c> factScoreList1 = [SELECT Id,  Assessment_Completed_URL_JSON__c  FROM Fact_Score_Data__c];
        factScoreList1[0].Assessment_Completed_URL_JSON__c = '[{"fromScore":"as34","toScore":"-100","urlStr":"www.google.com"}]';
        update factScoreList1[0];
        
        saveAnsParamCls.tempId = asstempList[0].Id;
        String saveResponse4 = CommonViewerController.saveAnswerRecord(saveAnsParamCls);
        CommonViewerController.saveResponseClass saveresp4 = (CommonViewerController.saveResponseClass)JSON.deserialize(saveResponse4, CommonViewerController.saveResponseClass.class);
        List<Account> accList3 = [SELECT Id , Name FROM Account];
        test.stopTest();
        
        System.assertEquals(2,saveResp4.quesIdwithAnsIdMap.size());
        System.assertEquals(accList3[0].Id,saveResp4.assessableObjectId);
        System.assertEquals('Assignment Manager updated successfully.',saveresp4.successMsg);
        
        saveAnsParamCls.publicAssessmentId = paList[1].Id;
        String saveResponse5 = CommonViewerController.saveAnswerRecord(saveAnsParamCls);
        CommonViewerController.saveResponseClass saveresp5 = (CommonViewerController.saveResponseClass)JSON.deserialize(saveResponse5, CommonViewerController.saveResponseClass.class);
        System.assertEquals('https://www.google.com',saveresp5.returnURL);
        
        saveAnsParamCls.publicAssessmentId = paList[2].Id;
        String saveResponse6 = CommonViewerController.saveAnswerRecord(saveAnsParamCls);
        CommonViewerController.saveResponseClass saveresp6 = (CommonViewerController.saveResponseClass)JSON.deserialize(saveResponse6, CommonViewerController.saveResponseClass.class);
        System.assertEquals('https://www.google.com',saveresp5.returnURL);
    }
    //Case 5: With case creation, viewer Lens
    
    public static testMethod void testsaveAnswerRecord5() {
        
        List<Main_questionaire__c> asstempList = [SELECT Id FROM Main_questionaire__c];
        List<Question_Template__c> quesTempList = [SELECT Id FROM Question_Template__c];
        List<Account> acList = [SELECT Id FROM Account];
        List<IssueRequest_Life_Cycle__c> amList = [SELECT Id, Total_Score__c FROM IssueRequest_Life_Cycle__c];
        List<Public_Assessment__c> paList = [SELECT Id FROM Public_Assessment__c];
        List<Questionnaire_Response__c> dependAnsList = [SELECT Id, Response__c, Question_Template__c FROM Questionnaire_Response__c];
        Map<Id, Id> quesIdAnsIdMap = new Map<Id, Id>();
        for(Integer i = 0; i< dependAnsList.size();i++) {
            quesIdAnsIdMap .put(dependAnsList[i].Question_Template__c ,dependAnsList[i].Id);
        }
        
        CommonViewerController.CaseRecordClass caseRecCls = new CommonViewerController.CaseRecordClass();
        caseRecCls.isCheck = true;
        caseRecCls.Name = 'Casesss1';
        caseRecCls.Email = 'casessss1@gmail.com';
        caseRecCls.Subject = 'Case creation reg';
        caseRecCls.Descrip = 'Case creation reg';
    
        Map<String, CommonViewerController.CaseRecordClass> caseMap = new Map<String, CommonViewerController.CaseRecordClass>();
        caseMap.put(questempList[19].Id, caseRecCls);

        List<CommonViewerController.AnswerRecordClass> ansRecClsList = new List<CommonViewerController.AnswerRecordClass>();
        CommonViewerController.AnswerRecordClass ansRecCls1 = new CommonViewerController.AnswerRecordClass();
        ansRecCls1.questionTemp = quesTempList[22];
        ansRecCls1.quesResponse = new Questionnaire_Response__c(Response__c='text response');
        ansRecClsList.add(ansRecCls1);
    
        CommonViewerController.AnswerRecordClass ansRecCls2 = new CommonViewerController.AnswerRecordClass();
        ansRecCls2.questionTemp = quesTempList[23];
        ansRecCls2.quesResponse = new Questionnaire_Response__c(Response__c='textarea response');
        ansRecClsList.add(ansRecCls2);
        
        CommonViewerController.AnswerRecordClass ansRecCls3 = new CommonViewerController.AnswerRecordClass();
        ansRecCls3.questionTemp = quesTempList[0];
        ansRecCls3.quesResponse = dependAnsList[0];
        ansRecClsList.add(ansRecCls3);
        
        CommonViewerController.AnswerRecordClass ansRecCls5 = new CommonViewerController.AnswerRecordClass();
        ansRecCls5.questionTemp = quesTempList[15];
        ansRecCls5.quesResponse = dependAnsList[10];
        ansRecClsList.add(ansRecCls5);
        
        CommonViewerController.AnswerRecordClass ansRecCls4 = new CommonViewerController.AnswerRecordClass();
        ansRecCls4.questionTemp = quesTempList[19];
        ansRecCls4.quesResponse = new Questionnaire_Response__c(Response__c='textarea response');
        ansRecClsList.add(ansRecCls4);
        
        CommonViewerController.SaveAnswerRecordParamClass saveAnsParamCls = new CommonViewerController.SaveAnswerRecordParamClass();
        saveAnsParamCls.tempId = asstempList[0].Id;
        saveAnsParamCls.assessibleObjName = 'Account';
        saveAnsParamCls.assessibleObjId  = acList[0].Id;
        saveAnsParamCls.viewerName = 'lens';
        saveAnsParamCls.answerList = ansRecClsList;
        saveAnsParamCls.amId = amList[0].Id; 
        saveAnsParamCls.quesIdANDAnsIdMap = quesIdAnsIdMap;
        saveAnsParamCls.publicAssessmentId = paList[0].Id;
        saveAnsParamCls.startTimeStr = String.valueOf(System.now());
        saveAnsParamCls.caseRec = caseMap;

        String saveResponse = CommonViewerController.saveAnswerRecord(saveAnsParamCls);
        CommonViewerController.saveResponseClass saveresp1 = (CommonViewerController.saveResponseClass)JSON.deserialize(saveResponse, CommonViewerController.saveResponseClass.class);
        List<Account> accList = [SELECT Id , Name FROM Account];
        List<Contact> conlist = [SELECT Id, Name, Email FROM Contact];
        List<Case> caseList = [SELECT Id, ContactEmail,ContactId FROM Case WHERE ContactId = :conList[1].Id ]; 
        System.assertEquals('casessss1@gmail.com', conlist[1].Email);
       // System.assertEquals(null, caseList[0].Test_Date__c);
        //System.assert( caseList[0].Test_Date_Time__c != null);
        System.assertEquals(1, caseList.size());
        System.assertEquals(2,saveResp1.quesIdwithAnsIdMap.size());
        System.assertEquals('Answers created successfully.',saveresp1.successMsg);
    }
    
    //case creation under an existing contact
    public static testMethod void testsaveAnswerRecord6() {
        
        
        List<Main_questionaire__c> asstempList = [SELECT Id FROM Main_questionaire__c];
        List<Question_Template__c> quesTempList = [SELECT Id FROM Question_Template__c];
        List<Account> acList = [SELECT Id FROM Account];
        List<IssueRequest_Life_Cycle__c> amList = [SELECT Id, Total_Score__c FROM IssueRequest_Life_Cycle__c];
        List<Public_Assessment__c> paList = [SELECT Id FROM Public_Assessment__c];
        List<Questionnaire_Response__c> dependAnsList = [SELECT Id, Response__c, Question_Template__c FROM Questionnaire_Response__c];
        Map<Id, Id> quesIdAnsIdMap = new Map<Id, Id>();
        for(Integer i = 0; i< dependAnsList.size();i++) {
            quesIdAnsIdMap .put(dependAnsList[i].Question_Template__c ,dependAnsList[i].Id);
        }
        
        System.debug(':::::::Contact::::::::'+ [SELECT Id, Email FROM Contact]);
        
        
        CommonViewerController.CaseRecordClass caseRecCls = new CommonViewerController.CaseRecordClass();
        caseRecCls.isCheck = true;
        caseRecCls.Name = 'Casesss1';
        caseRecCls.Email = 'contact345@gmail.com';
        caseRecCls.Subject = 'Case creation reg';
        caseRecCls.Descrip = 'Case creation reg';
    
        Map<String, CommonViewerController.CaseRecordClass> caseMap = new Map<String, CommonViewerController.CaseRecordClass>();
        caseMap.put(questempList[19].Id, caseRecCls);
        caseMap.put(questempList[15].Id, caseRecCls);

        List<CommonViewerController.AnswerRecordClass> ansRecClsList = new List<CommonViewerController.AnswerRecordClass>();    
        CommonViewerController.AnswerRecordClass ansRecCls4 = new CommonViewerController.AnswerRecordClass();
        ansRecCls4.questionTemp = quesTempList[19];
        ansRecCls4.quesResponse = new Questionnaire_Response__c(Response__c='textarea response');
        ansRecClsList.add(ansRecCls4);
        
        List<Questionnaire_Response__c> dependAnsList1 = new  list<Questionnaire_Response__c>{
              new Questionnaire_Response__c(Question_Template__c=quesTempList[6].Id,Response__c='optA',Issue_Request__c=amList[0].Id,
                Weight_Response__c = 50, Decision_Tree_Launched_Question__c = quesTempList[0].Id),
               new Questionnaire_Response__c(Question_Template__c=quesTempList[4].Id,Response__c='optB',Issue_Request__c=amList[0].Id,
                Weight_Response__c = 50, Decision_Tree_Launched_Question__c = quesTempList[0].Id)};
        insert dependAnsList1;        
             
        
        Map<String, String> decisionTreeMap = new Map<String,String>();
        decisionTreeMap.put(quesTempList[4].Id, dependAnsList1[1].Id);
        decisionTreeMap.put(quesTempList[0].Id, dependAnsList[0].Id);
        decisionTreeMap.put(quesTempList[6].Id, dependAnsList1[0].Id);
        
        
        CommonViewerController.SaveAnswerRecordParamClass saveAnsParamCls = new CommonViewerController.SaveAnswerRecordParamClass();
        saveAnsParamCls.tempId = asstempList[0].Id;
        saveAnsParamCls.assessibleObjName = 'Account';
        saveAnsParamCls.assessibleObjId  = acList[0].Id;
        saveAnsParamCls.viewerName = 'lens';
        saveAnsParamCls.answerList = ansRecClsList;
        saveAnsParamCls.amId = amList[0].Id; 
        saveAnsParamCls.quesIdANDAnsIdMap = quesIdAnsIdMap;
        saveAnsParamCls.publicAssessmentId = paList[0].Id;
        saveAnsParamCls.startTimeStr = String.valueOf(System.now());
        saveAnsParamCls.caseRec = caseMap;
        saveAnsParamCls.decisionTreeQuesIdAnsId = decisionTreeMap;

        String saveResponse = CommonViewerController.saveAnswerRecord(saveAnsParamCls);
        CommonViewerController.saveResponseClass saveresp1 = (CommonViewerController.saveResponseClass)JSON.deserialize(saveResponse, CommonViewerController.saveResponseClass.class);
        List<Account> accList = [SELECT Id , Name FROM Account];
        List<Contact> conList = [SELECT Id, Name, Email FROM Contact];
        List<Case> caseList = [SELECT Id, ContactEmail,ContactId FROM Case WHERE ContactId = :conList[0].Id ]; 
        //System.assertEquals(null,caseList[0].Test_Date__c);
        //System.assert(caseList[0].Test_Date_Time__c != null);
        System.assertEquals(2, caseList.size());
       // System.assertEquals(null,saveResp1);
        //System.assertEquals(2,saveResp1.quesIdwithAnsIdMap.size());
        System.assertEquals('Answers created successfully.',saveresp1.successMsg);
    }
}