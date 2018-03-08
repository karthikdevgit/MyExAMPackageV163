/**
    Code coverage for MultipleInspectionAssessmentViewCtrller class
**/
@isTest
private class TestLensViewerController {
    @testSetUp
    public static void testSetUp() {
       
        List<Account> aclist = new List<Account> {
                               new Account(Name = 'TestAcc1')};
        insert acList;
        
        List<Main_questionaire__c> asstempList = new List<Main_questionaire__c> {
            new Main_questionaire__c (Template_name__c = 'Template one', One_Time_Assessment__c = true),
            new Main_questionaire__c (Template_name__c = 'Site Template', One_Time_Assessment__c = true),
            new Main_questionaire__c (Template_name__c = 'Systems Template', One_Time_Assessment__c = true),
            new Main_questionaire__c (Template_name__c = 'Common Areas Template', One_Time_Assessment__c = true),
            new Main_questionaire__c (Template_name__c = 'Exterior  Template', One_Time_Assessment__c = true),
            new Main_questionaire__c (Template_name__c = 'Unit Template', One_Time_Assessment__c = true)};
        insert asstempList;
        
        List<Section_Template__c> secTempList = new List<Section_Template__c>{
                                                new Section_Template__c(Questionnaire_Section__c = asstempList[0].id)};
        insert secTempList;
        
        List<Question_Template__c> quesTempList1 = new List<Question_Template__c> {
            new Question_Template__c(Section_Question__c = secTempList[0].id, Question_Label__c = 'Test Question1')};
        insert quesTempList1;                                             
         
        List<IssueRequest_Life_Cycle__c> amList = new List<IssueRequest_Life_Cycle__c>{
            new IssueRequest_Life_Cycle__c(InvestigationType__c = assTempList[0].Id, Facility_Name__c = acList[0].Id, Status__c = 'Open' ),
            new IssueRequest_Life_Cycle__c(InvestigationType__c = assTempList[1].Id, Facility_Name__c = acList[0].Id, Status__c = 'Open' ),
            new IssueRequest_Life_Cycle__c(InvestigationType__c = assTempList[2].Id, Facility_Name__c = acList[0].Id, Status__c = 'Open' ),
            new IssueRequest_Life_Cycle__c(InvestigationType__c = assTempList[3].Id, Facility_Name__c = acList[0].Id, Status__c = 'Open' ),
            new IssueRequest_Life_Cycle__c(InvestigationType__c = assTempList[4].Id, Facility_Name__c = acList[0].Id, Status__c = 'Open' ),
            new IssueRequest_Life_Cycle__c(InvestigationType__c = assTempList[5].Id, Facility_Name__c = acList[0].Id, Status__c = 'Open' ),
            new IssueRequest_Life_Cycle__c(InvestigationType__c = assTempList[5].Id, Facility_Name__c = acList[0].Id, Status__c = 'Open' )};
        insert amList;
        
        List<Questionnaire_Response__c> dependAnsList = new  list<Questionnaire_Response__c>{
           new Questionnaire_Response__c(Question_Template__c=quesTempList1[0].Id,Response__c='optA',Issue_Request__c=amList[1].Id,
               Weight_Response__c = 50)};
        insert dependAnsList;       
        
        ExAM_Configuration__c ec = new ExAM_Configuration__c();
        ec.Name = 'Configuration';
        ec.Decision_Tree__c = 'Response__c~Priority__c~Comment__c~Pictures';
        ec.Hours__c = 50;
        ec.Primary_Assessment_Type_Template__c = assTempList[5].Id;
        
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
        ec.Related_Assessment_Type_1_Template__c = assTempList[1].Id;
        ec.Related_Assessment_Type_2_Template__c = assTempList[2].Id;
        ec.Related_Assessment_Type_3_Template__c = assTempList[3].Id;
        ec.Related_Assessment_Type_4_Template__c = assTempList[4].Id;
        insert ec; 
        
        System.assertEquals(7, amList.size());
    }
    public static testMethod void testMultiInspecAssessViewCtrller() {

       List<IssueRequest_Life_Cycle__c> amList = [SELECT Id,Name FROM IssueRequest_Life_Cycle__c];
       List<ExAM_Configuration__c> ec = [SELECT Id, Primary_Assessment_Type_Template__c, Hide_Related_Assignment_Manager1_Tab__c, Hide_Related_Assignment_Manager2_Tab__c, Hide_Related_Assignment_Manager3_Tab__c, Hide_Related_Assignment_Manager4_Tab__c,
           Hide_Data_Viewer_Tab__c, Hide_AM_List_Tab__c, Hide_Assessable_Record_Tab__c,Hide_Knowledge_Article_Tab__c, Hide_Save_Button__c  FROM ExAM_Configuration__c];
       List<Main_questionaire__c> asstempList = [SELECT Id,Name FROM Main_questionaire__c];
       List<Account> acList = [SELECT Id,Name FROM Account];

        ApexPages.currentPage().getParameters().put('amid', amList[0].Id);
        MultipleInspectionAssessmentViewCtrller  mulInsAss = new MultipleInspectionAssessmentViewCtrller();
       
        System.assertEquals(amList[0].Id, mulInsAss.currentASMId);
        System.assertEquals(amList[0].Name, mulInsAss.currentASMNameString);
        System.assertEquals(assTempList[0].Id, mulInsAss.currentASMAssessmentTemplateId);
        System.assertEquals(false, mulInsAss.hasAnswersAvailableForUnitTemplate);
        System.assertEquals(assTempList[0].Name, mulInsAss.currentASMAssessmentTemplateName);
        System.assertEquals('', mulInsAss.template_type);
        System.assertEquals(false, mulInsAss.isRelatedAM);
        System.assertEquals(false, mulInsAss.isLensViewerTemplate);
        System.assertEquals('', mulInsAss.primaryAMListStr);
        System.assertEquals('ExAM__Facility_Name__c', mulInsAss.assessableField_API);
        System.assertEquals(ec[0].Primary_Assessment_Type_Template__c, mulInsAss.primaryTemplateId);
        System.assertEquals(ec[0].Hide_Related_Assignment_Manager1_Tab__c, mulInsAss.hideRAMTab1);
        System.assertEquals(ec[0].Hide_Related_Assignment_Manager2_Tab__c, mulInsAss.hideRAMTab2);
        System.assertEquals(ec[0].Hide_Related_Assignment_Manager3_Tab__c, mulInsAss.hideRAMTab3);
        System.assertEquals(ec[0].Hide_Related_Assignment_Manager4_Tab__c, mulInsAss.hideRAMTab4);
        System.assertEquals(ec[0].Hide_Data_Viewer_Tab__c, mulInsAss.hideDataViewerTab);
        System.assertEquals(ec[0].Hide_AM_List_Tab__c, mulInsAss.hideAMListTab);
        System.assertEquals(ec[0].Hide_Assessable_Record_Tab__c, mulInsAss.hideAssessableRecordTab);
        System.assertEquals(ec[0].Hide_Knowledge_Article_Tab__c, mulInsAss.hideKnowledgeArticleTab);
        System.assertEquals(ec[0].Hide_Save_Button__c, mulInsAss.hideSaveBtn);
    }
       
    public Static testMethod void testFetchRelatedAssignmentManagers() {
       
       List<Main_questionaire__c> asstempList = [SELECT Id,Name FROM Main_questionaire__c];
        List<IssueRequest_Life_Cycle__c> amList = [SELECT Id,name FROM IssueRequest_Life_Cycle__c];
        List<Account> acList = [SELECT Id,Name FROM Account];  
        
        //Case 1 : Launching from Unit Template
        
        ApexPages.currentPage().getParameters().put('amid', amList[5].Id);
        MultipleInspectionAssessmentViewCtrller  mulInsAss5 = new MultipleInspectionAssessmentViewCtrller();
        
        System.assertEquals(amList[5].Id, mulInsAss5.currentASMId);
        System.assertEquals(amList[5].Name, mulInsAss5.currentASMNameString);
        System.assertEquals(assTempList[5].Name, mulInsAss5.currentASMAssessmentTemplateName);
        System.assertEquals('Primary_Assessment_Type', mulInsAss5.template_type);
        System.assertEquals('ExAM__Facility_Name__c', mulInsAss5.assessableField_API);
        System.assertEquals(acList[0].Id, mulInsAss5.assessableRecordId);
        System.assertEquals(acList[0].Name, mulInsAss5.assessableRecordName);
        System.assertEquals(false, mulInsAss5.isRelatedAM);
        List<IssueRequest_Life_Cycle__c> amList1 = [SELECT Id, Related_Assignment_Manager1__c, Related_Assignment_Manager2__c, Related_Assignment_Manager3__c, Related_Assignment_Manager4__c FROM IssueRequest_Life_Cycle__c WHERE Id = :amList[5].Id]; 
        System.assertEquals(null, amList1[0].Related_Assignment_Manager1__c);
        System.assertEquals(null, amList1[0].Related_Assignment_Manager2__c);
        System.assertEquals(null, amList1[0].Related_Assignment_Manager3__c);
        System.assertEquals(null, amList1[0].Related_Assignment_Manager4__c);
        
        
        List<ExAMUtilClass.AssessableRecordsClass> assClslist = new List<ExAMUtilClass.AssessableRecordsClass>(); 
        ExAMUtilClass.AssessableRecordsClass assCls = new ExAMUtilClass.AssessableRecordsClass();
        assCls.recordId = acList[0].Id;
        assCls.recordName = acList[0].Name;
        assCls.sObjectRecord = acList[0];
        assClslist.add(assCls);
        String str = JSON.serialize(assClslist);
        
        //System.assertEquals(str , mulInsAss5.assRecClsListJSON);
        
        MultipleInspectionAssessmentViewCtrller.MultipleInspectionViewerReqdInput mIView1 = MultipleInspectionAssessmentViewCtrller.fetchRelatedAssignmentManagers(mulInsAss5.currentASMId, mulInsAss5.assessableField_API, mulInsAss5.assRecClsListJSON);
        System.assert(mIView1.examConfigurationRecord != null);
        
        List<IssueRequest_Life_Cycle__c> currentAmList = [
                SELECT CreatedDate, Facility_Name__c, Facility_Name__r.Name, Id, InvestigationType__c,
                       InvestigationType__r.Name, Name, Assignment_Manager__c, Related_Assignment_Manager1__c,
                       Related_Assignment_Manager1__r.Name, Related_Assignment_Manager2__c,
                       Related_Assignment_Manager2__r.Name, Related_Assignment_Manager3__c,
                       Related_Assignment_Manager3__r.Name, Related_Assignment_Manager4__c,
                       Related_Assignment_Manager4__r.Name
                FROM   IssueRequest_Life_Cycle__c
                ];
            
        System.assertEquals(1, mIView1.ASMListForUnitAssessmentTemplate.size());
        List<IssueRequest_Life_Cycle__c> amListForUnit = mIView1.ASMListForUnitAssessmentTemplate;
        System.assertEquals(currentAmList[5], amListForUnit[0]); 
        
        System.assertEquals(1, mIView1.ASMListForSiteAssessmentTemplate.size());
        List<IssueRequest_Life_Cycle__c> amListForSite = mIView1.ASMListForSiteAssessmentTemplate;
        System.assertEquals(currentAmList[1], amListForSite[0]); 
       
        System.assertEquals(1, mIView1.ASMListForSystemsAssessmentTemplate.size());
        List<IssueRequest_Life_Cycle__c> amListForSystem = mIView1.ASMListForSystemsAssessmentTemplate;
        System.assertEquals(currentAmList[2], amListForSystem[0]); 
        
        System.assertEquals(1, mIView1.ASMListForCommonAreasAssessmentTemplate.size());
        List<IssueRequest_Life_Cycle__c> amListForcommonArea = mIView1.ASMListForCommonAreasAssessmentTemplate;
        System.assertEquals(currentAmList[3], amListForcommonArea[0]); 
        
        System.assertEquals(1, mIView1.ASMListForExteriorAssessmentTemplate.size());
        List<IssueRequest_Life_Cycle__c> amListForExterior = mIView1.ASMListForExteriorAssessmentTemplate;
        System.assertEquals(currentAmList[4], amListForExterior[0]);
        
        System.assertEquals('', mIView1.exceptionMsg); 
        System.assert(mIView1.examConfigurationRecord != null);
    }
    
    //Case 2: Create New AM
    public static testMethod void testCreateNewAMLaunchedFromPrimaryAM() {
        
        List<Main_questionaire__c> asstempList = [SELECT Id,Name FROM Main_questionaire__c];
        List<IssueRequest_Life_Cycle__c> amList = [SELECT Id, Name FROM IssueRequest_Life_Cycle__c];
        List<Account> acList = [SELECT Id,Name FROM Account]; 
        List<ExAM_Configuration__c> ec = [SELECT Id, Primary_Assessment_Type_Template__c, Hide_Related_Assignment_Manager1_Tab__c, Hide_Related_Assignment_Manager2_Tab__c, Hide_Related_Assignment_Manager3_Tab__c, Hide_Related_Assignment_Manager4_Tab__c,
           Hide_Data_Viewer_Tab__c, Hide_AM_List_Tab__c, Hide_Assessable_Record_Tab__c,Hide_Knowledge_Article_Tab__c, Hide_Save_Button__c  FROM ExAM_Configuration__c];   
    //Case 2(a) : Launch from Site
        
        ApexPages.currentPage().getParameters().put('amid', amList[1].Id);
        MultipleInspectionAssessmentViewCtrller  mulInsAss6 = new MultipleInspectionAssessmentViewCtrller();
        System.assertEquals(amList[1].Id, mulInsAss6.currentASMId);
        System.assertEquals(ec[0].Primary_Assessment_Type_Template__c, mulInsAss6.primaryTemplateId);
        System.assertEquals(assTempList[1].Id, mulInsAss6.currentASMAssessmentTemplateId);
        System.assertEquals(acList[0].Id, mulInsAss6.assessableRecordId);
        
        List<String> strList1 = new List<String> {amList[5].Id, mulInsAss6.assessableRecordId, mulInsAss6.currentASMAssessmentTemplateId, System.Label.Related_Assessment_Type_1,'Facility_Name__c' };
        String str4 = JSON.serialize(strList1);
        String str4a = MultipleInspectionAssessmentViewCtrller.createNewAssignmentManager(str4);
        MultipleInspectionAssessmentViewCtrller.SuccessClass retStr3 = (MultipleInspectionAssessmentViewCtrller.SuccessClass) JSON.deserialize(str4a, MultipleInspectionAssessmentViewCtrller.SuccessClass.class); 
        String rec3 = retstr3.msg;
        IssueRequest_Life_Cycle__c newManagerRecord3 =(IssueRequest_Life_Cycle__c) JSON.deserialize(rec3, IssueRequest_Life_Cycle__c.class);
        List<IssueRequest_Life_Cycle__c> amList2 = [SELECT Id, InvestigationType__c, Facility_Name__c, Related_Assignment_Manager1__c, Related_Assignment_Manager2__c, Related_Assignment_Manager3__c, Related_Assignment_Manager4__c FROM IssueRequest_Life_Cycle__c WHERE Id = :amList[5].Id];
        
        System.assertEquals(newManagerRecord3.Id, amList2[0].Related_Assignment_Manager1__c); 
        System.assertEquals(asstempList[1].Id,newManagerRecord3.InvestigationType__c); 
        System.assertEquals('success', retstr3.code); 
        
        //Case 2(b) : Launch from System
        
        ApexPages.currentPage().getParameters().put('amid', amList[2].Id);
        MultipleInspectionAssessmentViewCtrller  mulInsAss7 = new MultipleInspectionAssessmentViewCtrller();
        System.assertEquals(amList[2].Id, mulInsAss7.currentASMId);
        System.assertEquals(ec[0].Primary_Assessment_Type_Template__c, mulInsAss7.primaryTemplateId);
        System.assertEquals(assTempList[2].Id, mulInsAss7.currentASMAssessmentTemplateId);
        System.assertEquals(acList[0].Id, mulInsAss7.assessableRecordId);
        
        List<String> strList2 = new List<String> {amList[5].Id, mulInsAss7.assessableRecordId, mulInsAss7.currentASMAssessmentTemplateId, System.Label.Related_Assessment_Type_2,'Facility_Name__c' };
        String str3 = JSON.serialize(strList2);
        String str3a = MultipleInspectionAssessmentViewCtrller.createNewAssignmentManager(str3);
        MultipleInspectionAssessmentViewCtrller.SuccessClass retStr2 = (MultipleInspectionAssessmentViewCtrller.SuccessClass) JSON.deserialize(str3a, MultipleInspectionAssessmentViewCtrller.SuccessClass.class); 
        String rec2 = retstr2.msg;
        IssueRequest_Life_Cycle__c newManagerRecord2 =(IssueRequest_Life_Cycle__c) JSON.deserialize(rec2, IssueRequest_Life_Cycle__c.class);
        List<IssueRequest_Life_Cycle__c> amList3 = [SELECT Id, InvestigationType__c, Facility_Name__c, Related_Assignment_Manager1__c, Related_Assignment_Manager2__c, Related_Assignment_Manager3__c, Related_Assignment_Manager4__c FROM IssueRequest_Life_Cycle__c WHERE Id = :amList[5].Id];
        
        System.assertEquals(newManagerRecord2.Id, amList3[0].Related_Assignment_Manager2__c); 
        System.assertEquals(asstempList[2].Id,newManagerRecord2.InvestigationType__c); 
        System.assertEquals('success', retstr2.code); 

                
        //Case 2(c) : Launch from Common Area
        
        ApexPages.currentPage().getParameters().put('amid', amList[3].Id);
        MultipleInspectionAssessmentViewCtrller  mulInsAss8 = new MultipleInspectionAssessmentViewCtrller();
        System.assertEquals(amList[3].Id, mulInsAss8.currentASMId);
        System.assertEquals(ec[0].Primary_Assessment_Type_Template__c, mulInsAss8.primaryTemplateId);
        System.assertEquals(assTempList[3].Id, mulInsAss8.currentASMAssessmentTemplateId);
        System.assertEquals(acList[0].Id, mulInsAss8.assessableRecordId);
        
        List<String> strList3 = new List<String> {amList[5].Id, mulInsAss8.assessableRecordId, mulInsAss8.currentASMAssessmentTemplateId, System.Label.Related_Assessment_Type_3,'Facility_Name__c' };
        String str2 = JSON.serialize(strList3);
        String str2a = MultipleInspectionAssessmentViewCtrller.createNewAssignmentManager(str2);
        MultipleInspectionAssessmentViewCtrller.SuccessClass retStr1 = (MultipleInspectionAssessmentViewCtrller.SuccessClass) JSON.deserialize(str2a, MultipleInspectionAssessmentViewCtrller.SuccessClass.class); 
        String rec1 = retstr1.msg;
        IssueRequest_Life_Cycle__c newManagerRecord1 =(IssueRequest_Life_Cycle__c) JSON.deserialize(rec1, IssueRequest_Life_Cycle__c.class);
        List<IssueRequest_Life_Cycle__c> amList4 = [SELECT Id, InvestigationType__c, Facility_Name__c, Related_Assignment_Manager1__c, Related_Assignment_Manager2__c, Related_Assignment_Manager3__c, Related_Assignment_Manager4__c FROM IssueRequest_Life_Cycle__c WHERE Id = :amList[5].Id];
       
        System.assertEquals(newManagerRecord1.Id, amList4[0].Related_Assignment_Manager3__c); 
        System.assertEquals(asstempList[3].Id,newManagerRecord1.InvestigationType__c); 
        System.assertEquals('success', retstr1.code); 
       
        //Case 2(d) : Launch From Exterior
        
        ApexPages.currentPage().getParameters().put('amid', amList[4].Id);
        MultipleInspectionAssessmentViewCtrller  mulInsAss9 = new MultipleInspectionAssessmentViewCtrller();
        System.assertEquals(amList[4].Id, mulInsAss9.currentASMId);
        System.assertEquals(ec[0].Primary_Assessment_Type_Template__c, mulInsAss9.primaryTemplateId);
        System.assertEquals(assTempList[4].Id, mulInsAss9.currentASMAssessmentTemplateId);
        System.assertEquals(acList[0].Id, mulInsAss9.assessableRecordId);
        
        List<String> strList4 = new List<String> {amList[5].Id, mulInsAss9.assessableRecordId, mulInsAss9.currentASMAssessmentTemplateId, System.Label.Related_Assessment_Type_4,'Facility_Name__c' };
        String str1a = JSON.serialize(strList4);
        String str1 = MultipleInspectionAssessmentViewCtrller.createNewAssignmentManager(str1a);
        MultipleInspectionAssessmentViewCtrller.SuccessClass retStr = (MultipleInspectionAssessmentViewCtrller.SuccessClass) JSON.deserialize(str1, MultipleInspectionAssessmentViewCtrller.SuccessClass.class); 
        String rec = retstr.msg;
        IssueRequest_Life_Cycle__c newManagerRecord =(IssueRequest_Life_Cycle__c) JSON.deserialize(rec, IssueRequest_Life_Cycle__c.class);
        List<IssueRequest_Life_Cycle__c> amList5 = [SELECT Id, InvestigationType__c, Facility_Name__c, Related_Assignment_Manager1__c, Related_Assignment_Manager2__c, Related_Assignment_Manager3__c, Related_Assignment_Manager4__c FROM IssueRequest_Life_Cycle__c WHERE Id = :amList[5].Id];
        System.assertEquals(newManagerRecord.Id, amList5[0].Related_Assignment_Manager4__c); 
        System.assertEquals(asstempList[4].Id,newManagerRecord.InvestigationType__c); 
        System.assertEquals('success', retstr.code); 
    }
    
    //Case 3(a): Launched from related AM(Site,System,Common Area,Exterior) to link Primary AM - Proceed with existing record
    public static testMethod void testlinkCurrentAMwithPrimaryAM() { 
        
        List<Main_questionaire__c> asstempList = [SELECT Id, Name FROM Main_questionaire__c];
        List<IssueRequest_Life_Cycle__c> amList = [SELECT Id, Name FROM IssueRequest_Life_Cycle__c];
        List<Account> acList = [SELECT Id,Name FROM Account];    
        
        //case3a(i):launch from site
        
        List<IssueRequest_Life_Cycle__c> UnitTempList = [
                SELECT CreatedDate, Facility_Name__c, Facility_Name__r.Name, Id, InvestigationType__c,
                       InvestigationType__r.Name, Name, Assignment_Manager__c, Related_Assignment_Manager1__c,
                       Related_Assignment_Manager1__r.Name, Related_Assignment_Manager2__c,
                       Related_Assignment_Manager2__r.Name, Related_Assignment_Manager3__c,
                       Related_Assignment_Manager3__r.Name, Related_Assignment_Manager4__c,
                       Related_Assignment_Manager4__r.Name
                FROM   IssueRequest_Life_Cycle__c WHERE Id = : amList[5].Id];
                
        UnitTempList[0].Related_Assignment_Manager1__c = amList[1].Id;
        UnitTempList[0].Related_Assignment_Manager2__c = null;
        UnitTempList[0].Related_Assignment_Manager3__c = null;
        UnitTempList[0].Related_Assignment_Manager4__c = null;
        update UnitTempList;
        
        ApexPages.currentPage().getParameters().put('amid', amList[1].Id);
        MultipleInspectionAssessmentViewCtrller  mulInsAss6 = new MultipleInspectionAssessmentViewCtrller();
        System.assertEquals(amList[1].Id, mulInsAss6.currentASMId);
        List<IssueRequest_Life_Cycle__c> childAssignmentManagersList = (List<IssueRequest_Life_Cycle__c> )JSON.deserialize(mulInsAss6.primaryAMListStr, List<IssueRequest_Life_Cycle__c>.class);
        String Id = childAssignmentManagersList[0].Id;
        System.assertEquals(amList[5].Id, Id);
        
        List<String> strList = new list<String>();
            strList.add(Id);
            strList.add(mulInsAss6.currentASMId);
            strList.add('Site Demo');
            
            String stra = JSON.serialize(strList);
            String retStra =  MultipleInspectionAssessmentViewCtrller.linkSelectedASMWithCurrentAssignmentManager(stra);//It simply redirects the page.
        
            MultipleInspectionAssessmentViewCtrller.SuccessClass suc = (MultipleInspectionAssessmentViewCtrller.SuccessClass)JSON.deserialize(retStra, MultipleInspectionAssessmentViewCtrller.SuccessClass.class);
            List<IssueRequest_Life_Cycle__c> amList6 = [SELECT Id, Related_Assignment_Manager1__c, Related_Assignment_Manager2__c, Related_Assignment_Manager3__c, Related_Assignment_Manager4__c FROM IssueRequest_Life_Cycle__c WHERE Id = :amList[5].Id]; 
            System.assertEquals(amList[1].id,amList6[0].Related_Assignment_Manager1__c); 
            System.assertEquals('success', suc.code);
            System.assertEquals('Related Assignment of this assignment manager updated successfully', suc.msg);
            
    // case3a(ii) :launch from System
    
        UnitTempList[0].Related_Assignment_Manager1__c = null;
        UnitTempList[0].Related_Assignment_Manager2__c = amList[2].Id;
        UnitTempList[0].Related_Assignment_Manager3__c = null;
        UnitTempList[0].Related_Assignment_Manager4__c = null;
        update UnitTempList;
        
        ApexPages.currentPage().getParameters().put('amid', amList[2].Id);
        MultipleInspectionAssessmentViewCtrller  mulInsAss7 = new MultipleInspectionAssessmentViewCtrller();
        System.assertEquals(amList[2].Id, mulInsAss7.currentASMId);
        List<IssueRequest_Life_Cycle__c> childAssignmentManagersList1 = (List<IssueRequest_Life_Cycle__c> )JSON.deserialize(mulInsAss7.primaryAMListStr, List<IssueRequest_Life_Cycle__c>.class);
        String Id1 = childAssignmentManagersList1[0].Id;
        System.assertEquals(amList[5].Id, Id1);
        
        List<String> strList1a = new list<String> {Id1, mulInsAss7.currentASMId, 'Systems'};
        String str1b = JSON.serialize(strList1a);
        String retStr1a =  MultipleInspectionAssessmentViewCtrller.linkSelectedASMWithCurrentAssignmentManager(str1b);
        
        MultipleInspectionAssessmentViewCtrller.SuccessClass suc1 = (MultipleInspectionAssessmentViewCtrller.SuccessClass)JSON.deserialize(retStr1a, MultipleInspectionAssessmentViewCtrller.SuccessClass.class);
        List<IssueRequest_Life_Cycle__c> amList7 = [SELECT Id, Related_Assignment_Manager1__c, Related_Assignment_Manager2__c, Related_Assignment_Manager3__c, Related_Assignment_Manager4__c FROM IssueRequest_Life_Cycle__c WHERE Id = :amList[5].Id]; 
        System.assertEquals(amList[2].id,amList7[0].Related_Assignment_Manager2__c); 
        System.assertEquals('success', suc1.code);
        System.assertEquals( 'Related Assignment of this assignment manager updated successfully', suc1.msg);
        
        // case3a(iii) : Launch From Common Area
        
        UnitTempList[0].Related_Assignment_Manager1__c = null;
        UnitTempList[0].Related_Assignment_Manager2__c = null;
        UnitTempList[0].Related_Assignment_Manager3__c = amList[3].Id;
        UnitTempList[0].Related_Assignment_Manager4__c = null;
        update UnitTempList;
        
        ApexPages.currentPage().getParameters().put('amid', amList[3].Id);
        MultipleInspectionAssessmentViewCtrller  mulInsAss8 = new MultipleInspectionAssessmentViewCtrller();
        System.assertEquals(amList[3].Id, mulInsAss8.currentASMId);
        List<IssueRequest_Life_Cycle__c> childAssignmentManagersList2 = (List<IssueRequest_Life_Cycle__c> )JSON.deserialize(mulInsAss8.primaryAMListStr, List<IssueRequest_Life_Cycle__c>.class);
        String Id2 = childAssignmentManagersList2[0].Id;
        System.assertEquals(amList[5].Id, Id2);
        
        List<String> strList2a = new list<String> {Id2, mulInsAss8.currentASMId, 'Common Areas'};
        String str2b = JSON.serialize(strList2a);
        String retStr2a =  MultipleInspectionAssessmentViewCtrller.linkSelectedASMWithCurrentAssignmentManager(str2b);
        
        MultipleInspectionAssessmentViewCtrller.SuccessClass suc2 = (MultipleInspectionAssessmentViewCtrller.SuccessClass)JSON.deserialize(retStr2a, MultipleInspectionAssessmentViewCtrller.SuccessClass.class);
        List<IssueRequest_Life_Cycle__c> amList8 = [SELECT Id, Related_Assignment_Manager1__c, Related_Assignment_Manager2__c, Related_Assignment_Manager3__c, Related_Assignment_Manager4__c FROM IssueRequest_Life_Cycle__c WHERE Id = :amList[5].Id]; 
        System.assertEquals(amList[3].id,amList8[0].Related_Assignment_Manager3__c); 
        System.assertEquals('success', suc2.code);
        System.assertEquals( 'Related Assignment of this assignment manager updated successfully', suc2.msg);
        
        //case3a(iv) : Launch From Exterior
        
        UnitTempList[0].Related_Assignment_Manager1__c = null;
        UnitTempList[0].Related_Assignment_Manager2__c = null;
        UnitTempList[0].Related_Assignment_Manager3__c = null;
        UnitTempList[0].Related_Assignment_Manager4__c = amList[4].Id;
        update UnitTempList;
        
        ApexPages.currentPage().getParameters().put('amid', amList[4].Id);
        MultipleInspectionAssessmentViewCtrller  mulInsAss9 = new MultipleInspectionAssessmentViewCtrller();
        System.assertEquals(amList[4].Id, mulInsAss9.currentASMId);
        List<IssueRequest_Life_Cycle__c> childAssignmentManagersList3 = (List<IssueRequest_Life_Cycle__c> )JSON.deserialize(mulInsAss9.primaryAMListStr, List<IssueRequest_Life_Cycle__c>.class);
        String Id3 = childAssignmentManagersList3[0].Id;
        System.assertEquals(amList[5].Id, Id3);
        
        List<String> strList3a = new list<String> {Id3, mulInsAss9.currentASMId, 'Exterior'};
        String str3b = JSON.serialize(strList3a);
        String retStr3a =  MultipleInspectionAssessmentViewCtrller.linkSelectedASMWithCurrentAssignmentManager(str3b);
        
        MultipleInspectionAssessmentViewCtrller.SuccessClass suc3 = (MultipleInspectionAssessmentViewCtrller.SuccessClass)JSON.deserialize(retStr3a, MultipleInspectionAssessmentViewCtrller.SuccessClass.class);
        List<IssueRequest_Life_Cycle__c> amList9 = [SELECT Id, Related_Assignment_Manager1__c, Related_Assignment_Manager2__c, Related_Assignment_Manager3__c, Related_Assignment_Manager4__c FROM IssueRequest_Life_Cycle__c WHERE Id = :amList[5].Id]; 
        System.assertEquals(amList[4].id,amList9[0].Related_Assignment_Manager4__c); 
        System.assertEquals('success', suc3.code);
        System.assertEquals( 'Related Assignment of this assignment manager updated successfully', suc3.msg);
        
    }
    //case 3(b): Launched from related AM(Site,System,Common Area,Exterior) to link Primary AM - Create New Primary AM
    public static testMethod void testCreateNewPrimaryAM() { 
    
        List<Main_questionaire__c> asstempList = [SELECT Id, Name FROM Main_questionaire__c];
        List<IssueRequest_Life_Cycle__c> amList = [SELECT Id, Name FROM IssueRequest_Life_Cycle__c];
        List<Account> acList = [SELECT Id,Name FROM Account];    
        List<IssueRequest_Life_Cycle__c> UnitTempList = [
                SELECT CreatedDate, Facility_Name__c, Facility_Name__r.Name, Id, InvestigationType__c,
                       InvestigationType__r.Name, Name, Assignment_Manager__c, Related_Assignment_Manager1__c,
                       Related_Assignment_Manager1__r.Name, Related_Assignment_Manager2__c,
                       Related_Assignment_Manager2__r.Name, Related_Assignment_Manager3__c,
                       Related_Assignment_Manager3__r.Name, Related_Assignment_Manager4__c,
                       Related_Assignment_Manager4__r.Name
                FROM   IssueRequest_Life_Cycle__c WHERE Id = : amList[5].Id];
              
        UnitTempList[0].Related_Assignment_Manager1__c = null;
        UnitTempList[0].Related_Assignment_Manager2__c = null;
        UnitTempList[0].Related_Assignment_Manager3__c = null;
        UnitTempList[0].Related_Assignment_Manager4__c = null;
        update UnitTempList;
        
        // case 3b(i): Launch from unit
        ApexPages.currentPage().getParameters().put('amid', amList[1].Id);
        MultipleInspectionAssessmentViewCtrller  mulInsAss10 = new MultipleInspectionAssessmentViewCtrller();
        System.assertEquals(amList[1].Id, mulInsAss10.currentASMId);
        System.assertEquals('', mulInsAss10.primaryAMListStr);
        System.assertEquals(acList[0].Id, mulInsAss10.assessableRecordId);
        System.assertEquals(acList[0].Name, mulInsAss10.assessableRecordName);
        System.assertEquals('ExAM__Facility_Name__c', mulInsAss10.assessableField_API);
        
        String str5 = MultipleInspectionAssessmentViewCtrller.createNewPrimaryAM(asstempList[5].Id, 'Related_Assessment_Type_1',mulInsAss10.currentASMId, mulInsAss10.assessableField_API, mulInsAss10.assessableRecordId ); 
        MultipleInspectionAssessmentViewCtrller.SuccessClass retStr4 = (MultipleInspectionAssessmentViewCtrller.SuccessClass) JSON.deserialize(str5, MultipleInspectionAssessmentViewCtrller.SuccessClass.class); 
        String newAmId = retStr4.msg;
        List<IssueRequest_Life_Cycle__c> amList10 = [SELECT Id, InvestigationType__c, Facility_Name__c, Related_Assignment_Manager1__c, Related_Assignment_Manager2__c, Related_Assignment_Manager3__c, Related_Assignment_Manager4__c FROM IssueRequest_Life_Cycle__c WHERE Id = :newAmId];
        
        System.assertEquals(amList[1].Id, amList10[0].Related_Assignment_Manager1__c);
        System.assertEquals(asstempList[5].Id,amList10[0].InvestigationType__c); 
        System.assertEquals(mulInsAss10.assessableRecordId,amList10[0].Facility_Name__c); 
        
        //case 3b(ii): System
       
        UnitTempList[0].Related_Assignment_Manager1__c = null;
        UnitTempList[0].Related_Assignment_Manager2__c = null;
        UnitTempList[0].Related_Assignment_Manager3__c = null;
        UnitTempList[0].Related_Assignment_Manager4__c = null;
        update UnitTempList;
        
        ApexPages.currentPage().getParameters().put('amid', amList[2].Id);
        MultipleInspectionAssessmentViewCtrller  mulInsAss11 = new MultipleInspectionAssessmentViewCtrller();
        System.assertEquals(amList[2].Id, mulInsAss11.currentASMId);
        System.assertEquals('', mulInsAss11.primaryAMListStr);
        System.assertEquals(acList[0].Id, mulInsAss11.assessableRecordId);
        System.assertEquals(acList[0].Name, mulInsAss11.assessableRecordName);
        System.assertEquals('ExAM__Facility_Name__c', mulInsAss11.assessableField_API);
        
        String str6 = MultipleInspectionAssessmentViewCtrller.createNewPrimaryAM(asstempList[5].Id, 'Related_Assessment_Type_2',mulInsAss11.currentASMId, mulInsAss11.assessableField_API, mulInsAss11.assessableRecordId ); 
        MultipleInspectionAssessmentViewCtrller.SuccessClass retStr5 = (MultipleInspectionAssessmentViewCtrller.SuccessClass) JSON.deserialize(str6, MultipleInspectionAssessmentViewCtrller.SuccessClass.class); 
        String newAmId1 = retStr5.msg;
        List<IssueRequest_Life_Cycle__c> amList11 = [SELECT Id, InvestigationType__c,  Facility_Name__c, Related_Assignment_Manager1__c, Related_Assignment_Manager2__c, Related_Assignment_Manager3__c, Related_Assignment_Manager4__c FROM IssueRequest_Life_Cycle__c WHERE Id = :newAmId1];
        
        System.assertEquals(amList[2].Id, amList11[0].Related_Assignment_Manager2__c);
        System.assertEquals(asstempList[5].Id,amList11[0].InvestigationType__c); 
        System.assertEquals(mulInsAss11.assessableRecordId,amList11[0].Facility_Name__c); 
        
        //case 3b(iii) common Area
        
        ApexPages.currentPage().getParameters().put('amid', amList[3].Id);
        MultipleInspectionAssessmentViewCtrller  mulInsAss12 = new MultipleInspectionAssessmentViewCtrller();
        System.assertEquals(amList[3].Id, mulInsAss12.currentASMId);
        System.assertEquals('', mulInsAss12.primaryAMListStr);
        System.assertEquals(acList[0].Id, mulInsAss12.assessableRecordId);
        System.assertEquals(acList[0].Name, mulInsAss12.assessableRecordName);
        System.assertEquals('ExAM__Facility_Name__c', mulInsAss12.assessableField_API);
        
        String str7 = MultipleInspectionAssessmentViewCtrller.createNewPrimaryAM(asstempList[5].Id, 'Related_Assessment_Type_3',mulInsAss12.currentASMId, mulInsAss12.assessableField_API, mulInsAss12.assessableRecordId ); 
        MultipleInspectionAssessmentViewCtrller.SuccessClass retStr6 = (MultipleInspectionAssessmentViewCtrller.SuccessClass) JSON.deserialize(str7, MultipleInspectionAssessmentViewCtrller.SuccessClass.class); 
        String newAmId2 = retStr6.msg;
        List<IssueRequest_Life_Cycle__c> amList12 = [SELECT Id, InvestigationType__c, Facility_Name__c, Related_Assignment_Manager1__c, Related_Assignment_Manager2__c, Related_Assignment_Manager3__c, Related_Assignment_Manager4__c FROM IssueRequest_Life_Cycle__c WHERE Id = :newAmId2];
        
        System.assertEquals(amList[3].Id, amList12[0].Related_Assignment_Manager3__c);
        System.assertEquals(asstempList[5].Id,amList12[0].InvestigationType__c); 
        System.assertEquals(mulInsAss12.assessableRecordId,amList12[0].Facility_Name__c);  
        
        //case 3b(iv) Exterior
        ApexPages.currentPage().getParameters().put('amid', amList[4].Id);
        MultipleInspectionAssessmentViewCtrller  mulInsAss13 = new MultipleInspectionAssessmentViewCtrller();
        System.assertEquals(amList[4].Id, mulInsAss13.currentASMId);
        System.assertEquals('', mulInsAss13.primaryAMListStr);
        System.assertEquals(acList[0].Id, mulInsAss13.assessableRecordId);
        System.assertEquals(acList[0].Name, mulInsAss13.assessableRecordName);
        System.assertEquals('ExAM__Facility_Name__c', mulInsAss13.assessableField_API);
        
        String str8 = MultipleInspectionAssessmentViewCtrller.createNewPrimaryAM(asstempList[5].Id, 'Related_Assessment_Type_4',mulInsAss13.currentASMId, mulInsAss13.assessableField_API, mulInsAss13.assessableRecordId ); 
        MultipleInspectionAssessmentViewCtrller.SuccessClass retStr7 = (MultipleInspectionAssessmentViewCtrller.SuccessClass) JSON.deserialize(str8, MultipleInspectionAssessmentViewCtrller.SuccessClass.class); 
        String newAmId3 = retStr7.msg;
        List<IssueRequest_Life_Cycle__c> amList13 = [SELECT Id, InvestigationType__c, Facility_Name__c, Related_Assignment_Manager1__c, Related_Assignment_Manager2__c, Related_Assignment_Manager3__c, Related_Assignment_Manager4__c FROM IssueRequest_Life_Cycle__c WHERE Id = :newAmId3];
        
        System.assertEquals(amList[4].Id, amList13[0].Related_Assignment_Manager4__c);
        System.assertEquals(asstempList[5].Id,amList13[0].InvestigationType__c); 
        System.assertEquals(mulInsAss13.assessableRecordId,amList13[0].Facility_Name__c);  
    }
}