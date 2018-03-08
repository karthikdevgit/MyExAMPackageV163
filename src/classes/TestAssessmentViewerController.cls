@isTest 
public class TestAssessmentViewerController {
    @testSetup
    public static void testSetUp() {
        
        List<Account> aclist = new List<Account> {
                               new Account(Name = 'TestAcc1')};
        insert acList;
        
        Viewer_Custom_Configuration__c viewerRec = new Viewer_Custom_Configuration__c();
        insert viewerRec;  
        
        List<Main_questionaire__c> asstempList = new List<Main_questionaire__c> {
                                                 new Main_questionaire__c (Template_name__c = 'Unit Template',Viewer_Configuration__c = viewerRec.Id, 
                                                     Decision_Tree__c = 'Pictures:true:false:1~External_Id__c:false:false:2~Priority__c:true:false:3~Comment__c:true:false:4~Response__c:true:false:5~Test_text_field__c:true:false:6~deficiency_status__c:true:false:7', One_Time_Assessment__c = true)};
        insert asstempList;
         
        List<IssueRequest_Life_Cycle__c> amList = new List<IssueRequest_Life_Cycle__c>{
                                                  new IssueRequest_Life_Cycle__c(InvestigationType__c = assTempList[0].Id, Facility_Name__c = acList[0].Id, Status__c = 'Open' )};
        insert amList;
        
        List<Section_Template__c> secTempList = new List<Section_Template__c>{
                                                new Section_Template__c(Questionnaire_Section__c = asstempList[0].id, Section_label__c = 'UT Section')};
        insert secTempList;
        
        List<Question_Template__c> quesTempList = new List<Question_Template__c> {
            new Question_Template__c(Section_Question__c = secTempList[0].id, Question_Label__c = 'Test Question4', Question_Order_No__c = 1,
                Question_Type__c = 'Text',Subquestion_Label__c='optD1~optD2',Weight_of_Answer__c ='100~50', Is_Dependent__c = false),
            new Question_Template__c(Section_Question__c = secTempList[0].id, Question_Label__c = 'Test Question4', Question_Order_No__c = 2,
                Question_Type__c = 'Text',Subquestion_Label__c='optD1~optD2',Weight_of_Answer__c ='100~50', Is_Dependent__c = false),
            new Question_Template__c(Section_Question__c = secTempList[0].id, Question_Label__c = 'Test Question4', Question_Order_No__c = 3,
                Question_Type__c = 'Text',Subquestion_Label__c='optD1~optD2',Weight_of_Answer__c ='100~50', Is_Dependent__c = false)};
       insert quesTempList;
        
        List<Question_Template__c> quesTempList1 = new List<Question_Template__c> {
            new Question_Template__c(Section_Question__c = secTempList[0].id, Question_Label__c = 'Test Question4', Question_Order_No__c = 4,
                Question_Type__c = 'Text',Subquestion_Label__c='optD1~optD2',Weight_of_Answer__c ='100~50', Is_Dependent__c = false,Single_Next_Question__c = quesTempList[0].Id),
            new Question_Template__c(Section_Question__c = secTempList[0].id, Question_Label__c = 'Test Question4', Question_Order_No__c = 5,
                Question_Type__c = 'Email',Subquestion_Label__c='optD1~optD2',Weight_of_Answer__c ='100~50', Is_Dependent__c = false, Next_Question__c = 'What is ur code coverage'),
            new Question_Template__c(Section_Question__c = secTempList[0].id, Question_Label__c = 'Test Question4', Question_Order_No__c = 6,
                Question_Type__c = 'RadioPicklist',Subquestion_Label__c='optD1~optD2',Weight_of_Answer__c ='100~50', Is_Dependent__c = false, Next_Question__c = '~What is ur code coverage'),
            new Question_Template__c(Section_Question__c = secTempList[0].id, Question_Label__c = 'Test Question4', Question_Order_No__c = 7,
                Question_Type__c = 'Image',Subquestion_Label__c='optD1~optD2',Weight_of_Answer__c ='100~50', Is_Dependent__c = false)};
        insert quesTempList1;
                
        List<Answer_Option__c> ansoptions1 = new List<Answer_Option__c> {
                                             new Answer_Option__c(Question_Template__c = quesTempList1[3].Id, Order_No__c = 1, Name = 'optA', Weight__c = 50, Next_Question__c = quesTempList[1].Id ), 
                                             new Answer_Option__c(Question_Template__c = quesTempList1[3].Id, Order_No__c = 2, Name = 'optB', Weight__c = 50, Next_Question__c = quesTempList[2].Id )};
        insert ansoptions1;
       
        List<Attachment> attachList = new List<Attachment> {
            new Attachment(ParentId = quesTempList1[3].Id, ContentType = 'Image', Name = String.valueof('Question-image'), Body = Blob.valueof('attached')),
            new Attachment(ParentId = quesTempList1[0].Id, ContentType = 'Image', Name = String.valueof('Question-image'), Body = Blob.valueof('attached')),
            new Attachment(ParentId = assTempList[0].Id, ContentType = 'Image', Name = String.valueof('banner'), Body = Blob.valueof('attached'))};
       insert attachList;               
    }
    public static testMethod void testAssessmentViewerController() {
        String selectedViewerConfigJSON = '';
        Boolean Show_Configuration_Options_in_Viewer = false;
        Boolean show_Question_Name_on_Decision_Tree = false;
        
        List<Main_questionaire__c> asstempList = [SELECT Id FROM Main_questionaire__c];
        List<IssueRequest_Life_Cycle__c> amList = [SELECT Id, Name, Facility_Name__c, Status__c, InvestigationType__c, Assessment_Form_Completion__c,
                                                     Assessment_Date_Time__c, Show_Configuration_Options_in_Viewer__c 
                                                     FROM IssueRequest_Life_Cycle__c];
        List<Viewer_Custom_Configuration__c> vccList = [SELECT Id, Answer_Options__c, Data_Management__c, Hierarchical_Object__c, Single_Question_Mode__c, Assignment_Manager__c, Assignment_Manager_List__c 
                                                          FROM Viewer_Custom_Configuration__c];
        
        Show_Configuration_Options_in_Viewer = amList[0].Show_Configuration_Options_in_Viewer__c;
        
        Admin_Configuration__c adminConf = Admin_Configuration__c.getInstance(UserInfo.getUserId());
        if ( adminConf != null && adminConf.Show_Question_Name_on_Decision_Tree__c != null ) {
            show_Question_Name_on_Decision_Tree = adminConf.Show_Question_Name_on_Decision_Tree__c;
        }
        
        List<Attachment> attList = [SELECT Id FROM Attachment WHERE Name like 'banner%' AND ParentId = :asstempList[0].Id LIMIT 1];
        String bannerId = attList[0].Id;
        apexPages.currentPage().getParameters().put('amid',amList[0].Id);
        apexPages.currentPage().getParameters().put('asstempid',asstempList[0].Id);
        AssessmentViewerController avc = new AssessmentViewerController();
        Viewer_Custom_Configuration__c view1 = (Viewer_Custom_Configuration__c)JSON.deserialize(avc.selectedViewerConfigJSON, Viewer_Custom_Configuration__c.class);
        
        System.debug('::avc.selectedViewerConfigJSON::'+avc.selectedViewerConfigJSON);
        System.assertEquals(vccList[0].Id, view1.Id); 
        System.assert(avc.selectedViewerConfigJSON != null);
        selectedViewerConfigJSON = JSON.serialize(vccList[0]);
        
        List<ExAMUtilClass.AssessableRecordsClass> AssessableRecords = new List<ExAMUtilClass.AssessableRecordsClass>();
        Boolean hasAssessableObj = false;
        AssessableRecords = ExAMUtilClass.getAssessableRecords(amList, true);
        if( AssessableRecords != null && AssessableRecords.size() > 0 ){
            hasAssessableObj = true;
        }
        
        String hierarchicalListJSON = JSON.serialize( AssessableRecords );
        system.assertEquals(avc.hierarchicalListJSON ,hierarchicalListJSON);
        system.assertEquals(avc.hasAssessableObj ,hasAssessableObj);
        system.assertEquals(avc.bannerId ,bannerId);
        system.assertEquals(avc.selectedViewerConfigJSON ,selectedViewerConfigJSON);
        system.assertEquals(avc.Show_Configuration_Options_in_Viewer ,Show_Configuration_Options_in_Viewer); 
        system.assertEquals(avc.show_Question_Name_on_Decision_Tree ,show_Question_Name_on_Decision_Tree);
     }
}