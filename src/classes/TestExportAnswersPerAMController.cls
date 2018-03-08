@isTest
public class TestExportAnswersPerAMController {
    @testSetup
    public static void testSetUp() { 
        
        List<Account> acList = new List<Account>{
                               new Account(Name = 'testAcc')
        };
        insert acList;
        
        List<ExAM_Configuration__c> exConfigList = new List<ExAM_Configuration__c> {
                                                   new ExAM_Configuration__c(Add_Response_Score__c = true),
                                                   new ExAM_Configuration__c(Add_Response_Score__c = false)};
        insert exConfigList;                                           
        
        List<Main_questionaire__c> assTempList = new List<Main_questionaire__c>{
                                                 new Main_questionaire__c(),
                                                 new Main_questionaire__c()
        };
        insert assTempList;
        System.assert(assTempList [0].Id != null);
        
        List<Section_Template__c> secList = new List<Section_Template__c>{
                                            new Section_Template__c(Questionnaire_Section__c=assTempList[0].Id)
        };
        insert secList;
        
        List<Question_Template__c> quesList = new List<Question_Template__c>{
                                              new Question_Template__c(Subquestion_Label__c='test q1', Section_Question__c=secList[0].Id, Question_Label__c = 'test label'),
                                              new Question_Template__c(Subquestion_Label__c='test q1', Section_Question__c=secList[0].Id)                        
        };
        insert quesList;
        
        List<IssueRequest_Life_Cycle__c> amList = new List<IssueRequest_Life_Cycle__c>{
                                                  new IssueRequest_Life_Cycle__c(InvestigationType__c = assTempList[0].Id, Facility_Name__c = acList[0].Id)
        };
        insert amList;
    }
    public static testMethod void testExportAnswerrecords(){
    
        List<Main_questionaire__c> assTemplateList = [SELECT Id FROM Main_questionaire__c];
        List<Account> acList = [SELECT Id FROM Account];
        List<Question_Template__c> quesList = [SELECT Id FROM Question_Template__c];
        
        List<IssueRequest_Life_Cycle__c> amList = new List<IssueRequest_Life_Cycle__c>{
                                                  new IssueRequest_Life_Cycle__c(InvestigationType__c = assTemplateList[0].Id, Facility_Name__c = acList[0].Id)
        };
        insert amList;
        
        List<Questionnaire_Response__c> ansList = new List<Questionnaire_Response__c>{
                                                  new Questionnaire_Response__c(Issue_Request__c = amList[0].Id, Question_Template__c = quesList[0].Id, Response__c = 'Answer1'),
                                                  new Questionnaire_Response__c(Issue_Request__c = amList[0].Id, Question_Template__c = quesList[1].Id)
        };
        insert ansList;
        
        ExportAnswersPerAMController eCSVcntrlr = new ExportAnswersPerAMController();
        ExportAnswersPerAMController.WrapperClass wc = new ExportAnswersPerAMController.WrapperClass();
        ExportAnswersPerAMController.WrapperClass wc1 = new ExportAnswersPerAMController.WrapperClass();
        ExportAnswersPerAMController.WrapperClass wc2 = new ExportAnswersPerAMController.WrapperClass();
        ExportAnswersPerAMController.WrapperClass wc3 = new ExportAnswersPerAMController.WrapperClass();
        ExportAnswersPerAMController.WrapperClass wc4 = new ExportAnswersPerAMController.WrapperClass();
        ExportAnswersPerAMController.WrapperClass wc5 = new ExportAnswersPerAMController.WrapperClass();
        
        List<ExAM_Configuration__c> exConfigList1 = new List<ExAM_Configuration__c> {
                                                    new ExAM_Configuration__c(Add_Response_Score__c = true)};
        insert exConfigList1;                                           
        
        List<String> fieldList = new List<String>{
            'Facility_Name__c'
        };
        
        Datetime yourDate = Datetime.now();
        String startdate = yourDate.format('MM/dd/yyyy');
        Datetime yourDate1 = System.today()+3;
        String endDate = yourDate1.format('MM/dd/yyyy');
        
        wc = ExportAnswersPerAMController.exportAnswersRecords(startdate,endDate , null,fieldList, '','');
        System.assert(wc != null);
        
        wc2 = ExportAnswersPerAMController.exportAnswersRecords(startdate,null ,assTemplateList[0].Id,fieldList,'','');
        wc3 = ExportAnswersPerAMController.exportAnswersRecords('','' ,'',fieldList,'','');
        
        wc1 = ExportAnswersPerAMController.exportAnswersRecords('','' , assTemplateList[0].Id,fieldList,startdate,endDate );
        System.assertEquals('OK',wc1.status = 'OK');
        
        wc4 = ExportAnswersPerAMController.exportAnswersRecords('','' , assTemplateList[0].Id,fieldList,null,null);
        System.assertEquals(2,wc4.ansLength);
        
        wc5 = ExportAnswersPerAMController.exportAnswersRecords('','' , assTemplateList[1].Id,fieldList,startdate,endDate );
        System.assertEquals('OK',wc5.status = 'OK');
    } 
    
    public static testMethod void testExportAnswerrecordswithNullAnsList(){
    
        List<String> fieldList = new List<String>{
            'Facility_Name__c'
        };
        
        List<String> fieldList1 = new List<String>{
            'ExAM__Facility_Name__c'
        };
        
        List<Main_questionaire__c> assTemplateList = [SELECT Id FROM Main_questionaire__c];
        List<Question_Template__c> quesList = [SELECT Id FROM Question_Template__c];
        
        List<Questionnaire_Response__c> ansList = new List<Questionnaire_Response__c>{
                                                  new Questionnaire_Response__c( Question_Template__c = quesList[0].Id, Response__c = 'Answer1'),
                                                  new Questionnaire_Response__c( Question_Template__c = quesList[1].Id)
        };
        insert ansList;
        Datetime yourDate = Datetime.now();
        String startdate = yourDate.format('MM/dd/yyyy');
        Datetime yourDate1 = System.today()+3;
        String endDate = yourDate1.format('MM/dd/yyyy');
        
        ExportAnswersPerAMController.WrapperClass wc1 = new ExportAnswersPerAMController.WrapperClass();
        wc1 = ExportAnswersPerAMController.exportAnswersRecords('','' , assTemplateList[0].Id,fieldList,startdate,endDate);
        System.assertEquals(0, wc1.ansLength);
        System.assertEquals('FAIL',wc1.status = 'FAIL');
        
        ExportAnswersPerAMController.WrapperClass wc2 = new ExportAnswersPerAMController.WrapperClass();
        wc2 = ExportAnswersPerAMController.exportAnswersRecords('','' , assTemplateList[0].Id,fieldList1,startdate,endDate);
        System.assertEquals(0, wc2.ansLength);
        System.assertEquals('FAIL',wc2.status = 'FAIL');
        
        ExportAnswersPerAMController.WrapperClass wc3 = new ExportAnswersPerAMController.WrapperClass();
        wc3 = ExportAnswersPerAMController.exportAnswersRecords(null,null ,null,fieldList,'','');
        System.assertEquals(Null, wc3);
   }     
    
    public static testMethod void testsaveExAMConfiguration() {
    
        List<ExAM_Configuration__c> exConfigList = new List<ExAM_Configuration__c> {
                                                   new ExAM_Configuration__c(Add_Response_Score__c = false),
                                                   new ExAM_Configuration__c(Add_Response_Score__c = true)};
        insert exConfigList;
        
        string str1 = ExportAnswersPerAMController.saveExAMConfiguration(exConfigList[1].Id, 'true');
        string str = ExportAnswersPerAMController.saveExAMConfiguration(exConfigList[0].Id, 'true');
        System.assertEquals('Success', str);
    }     
}