@isTest
public class TestExportAnswerCSVController {

    @testSetUp
    public static void testSetUp() {
    
        Account acc = new Account();
        acc.Name = 'Test';
        insert acc;
        
        contact con = new contact();
        con.AccountId=acc.id;
        con.LastName ='testCon';
        insert con;
    
        Viewer_Custom_Configuration__c viewerRec = new Viewer_Custom_Configuration__c();
        insert viewerRec;
            
        List<Main_questionaire__c> asstempList = new List<Main_questionaire__c> {
                                                 new Main_questionaire__c (Template_name__c = 'Unit Template',Viewer_Configuration__c = viewerRec.Id, One_Time_Assessment__c = true),
                                                 new Main_questionaire__c (Template_name__c = 'Site Template',Viewer_Configuration__c = viewerRec.Id, Decision_Tree__c = 'Pictures:true:false:1~External_Id__c:false:false:2~Priority__c:true:false:3~Comment__c:true:false:4~Response__c:true:false:5~Test_text_field__c:true:false:6~deficiency_status__c:true:false:7')};
        insert asstempList;                                         
                                                 
        List<Section_Template__c> secTempList = new List<Section_Template__c>{
                                                new Section_Template__c(Questionnaire_Section__c = asstempList[0].Id, Section_label__c = 'UT Section'),
                                                new Section_Template__c(Questionnaire_Section__c = asstempList[0].Id, Section_label__c = 'ST Section')};
        insert secTempList;
        List<Question_Template__c> quesTempList = new List<Question_Template__c>{
            new Question_Template__c(Subquestion_Label__c='test q1', Section_Question__c=secTempList[0].Id, Question_Label__c = 'test Question_Label__c')
        };
        insert quesTempList;
        
        Datetime dt = System.today()+5;
        
        List<IssueRequest_Life_Cycle__c> amList = new List<IssueRequest_Life_Cycle__c>{
                                                  new IssueRequest_Life_Cycle__c(Facility_Name__c = acc.id,Site_Contact__c = con.id,Date_Assigned__c = system.today(),Status__c='open',Priority__c = 'high',InvestigationType__c =assTempList[0].id,Assessment_Form_Completion__c = 'complete',Assessment_Date_Time__c = system.today(),Show_Configuration_Options_in_Viewer__c = true, Date_Completed__c = dt ),
                                                  new IssueRequest_Life_Cycle__c(Facility_Name__c = acc.id,Site_Contact__c = con.id,Date_Assigned__c = system.today(),Status__c='open',Priority__c = 'high',InvestigationType__c =assTempList[0].id,Assessment_Form_Completion__c = 'complete',Assessment_Date_Time__c = system.today(),Show_Configuration_Options_in_Viewer__c = true, Date_Completed__c = dt )};
        insert amList;
        
        List<Questionnaire_Response__c> dependAnsList = new  list<Questionnaire_Response__c>{
                                                        new Questionnaire_Response__c(Question_Template__c=quesTempList[0].Id,Response__c='N/A',Issue_Request__c=amList[0].Id),
                                                        new Questionnaire_Response__c(Question_Template__c=quesTempList[0].Id,Response__c='optA1',Issue_Request__c=amList[0].Id)};
        insert dependAnsList;
        
        System.assert(dependAnsList[0].Id != null);
    }                                                                                                  
    
    public static testMethod void testExportAnswers(){
    
        List<Main_questionaire__c> asstempList = [SELECT Id FROM Main_questionaire__c]; 
        
        Datetime yourDate = Datetime.now();
        String startdate = yourDate.format('MM/dd/yyyy');
        Datetime yourDate1 = System.today()+3;
        String endDate = yourDate1.format('MM/dd/yyyy');
        
        Datetime yourCompDate1 = System.today()+4;
        String startComdate = yourDate.format('MM/dd/yyyy');
        Datetime yourComDate2 = System.today()+6;
        String endComDate = yourDate1.format('MM/dd/yyyy');
        ExportAnswerCSVController eCSVcntrlr = new ExportAnswerCSVController();
       
        String response1 = ExportAnswerCSVController.exportAnswers(startdate,endDate , null, startComdate, endComDate);
        System.assertEquals('Empty Response', response1); 
        
        String response2 = ExportAnswerCSVController.exportAnswers(startdate,endDate , assTempList[0].Id, startComdate, endComDate);
        String response4 = ExportAnswerCSVController.exportAnswers(startdate,endDate , assTempList[0].Id,'', '');
        System.debug('::::::::Json:::::'+response4);
        List<Questionnaire_Response__c> ansList = new List<Questionnaire_Response__c>();
        ansList = (List<Questionnaire_Response__c>) JSON.deserialize(response4, List<Questionnaire_Response__c>.class);
        System.debug('::ansList::'+ansList);
        System.assertEquals(2, ansList.size()); 
        
        String response3 = ExportAnswerCSVController.exportAnswers(null, null, assTempList[0].Id, startComdate, endComDate);
        System.assertEquals('Empty Response', response3);
         
        String response5 = ExportAnswerCSVController.exportAnswers(null, null, null, startComdate, endComDate);
        System.assertEquals('No Assessment Template', response5);
    }
}