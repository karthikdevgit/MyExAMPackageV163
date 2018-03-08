@isTest
public class TestPublicAssessmentsCreationCtrller {

    static testmethod void method1() {

        Viewer_Custom_Configuration__c vc = new Viewer_Custom_Configuration__c();
        vc.Name ='Viewer 1';
        insert vc;

        Main_questionaire__c[] templateList = new Main_questionaire__c[] {
            new Main_questionaire__c(Template_name__c = 'General Safety', Viewer_Configuration__c = vc.Id),
            new Main_questionaire__c(Template_name__c = 'Fire Safety', Viewer_Configuration__c = vc.Id),
            new Main_questionaire__c(Template_name__c = 'Accident Safety', Viewer_Configuration__c = vc.Id),
            new Main_questionaire__c(Template_name__c = 'General Instructions', Viewer_Configuration__c = vc.Id)
        };
        insert templateList;

        Account[] acctList = new Account[] {
            new Account(Name = 'Test Account 1'),
            new Account(Name = 'Test Account 2'),
            new Account(Name = 'Test Account 3'),
            new Account(Name = 'Test Account 4')
        };
        insert acctList;

        Account[] acctList1 = new Account[] {
            new Account(Name = 'Test Account 5')
        };
        insert acctList1;

        Assessment_Group__c ag = new Assessment_Group__c(Type__c = 'Account');
        insert ag;

        Assessment_Group_Junction__c[] agjList = new Assessment_Group_Junction__c[] {
            new Assessment_Group_Junction__c(Assessment_Group__c = ag.Id, Facility_Name__c = acctList[0].Id),
            new Assessment_Group_Junction__c(Assessment_Group__c = ag.Id, Facility_Name__c = acctList[1].Id),
            new Assessment_Group_Junction__c(Assessment_Group__c = ag.Id, Facility_Name__c = acctList[2].Id),
            new Assessment_Group_Junction__c(Assessment_Group__c = ag.Id, Facility_Name__c = acctList[3].Id)
        };
        insert agjList;

        PublicAssessmentCreationController.SuccessClass sClass = new PublicAssessmentCreationController.SuccessClass('success', 'Public Assessment records created successfully');
        string sClassStr = Json.serialize( sClass );

        PublicAssessmentCreationController pac = new PublicAssessmentCreationController();
        PublicAssessmentCreationController.getAssessibleObjectAndTemplates();

        PublicAssessmentCreationController.onAssessibleObjectChange('Account');

        string createPAForWhichEntity = 'AssessmentGroup'+'@@'+ag.Id;
        Date expDate = Date.today().addMonths(6);
        Map<String, String> agjAssessibleObjectApiNameMap = new Map<String, String>{'Account' => 'ExAM__Facility_Name__c'};
        Map<String, String> paAssessibleObjectApiNameMap = new Map<String, String>{'Account' => 'ExAM__Facility_Name__c'};
        String responseMsg = PublicAssessmentCreationController.createPublicAssessments('Account', createPAForWhichEntity, templateList[0].Id, string.valueOf(expDate), agjAssessibleObjectApiNameMap, paAssessibleObjectApiNameMap);
        system.assertEquals(responseMsg, sClassStr, 'Public Assessments creation not successful');

        PublicAssessmentCreationController.SuccessClass sClass1 = new PublicAssessmentCreationController.SuccessClass('success', 'Public Assessment record created successfully');
        string sClassStr1 = Json.serialize( sClass1 );

        PublicAssessmentCreationController.ErrorClass eClass1 = new PublicAssessmentCreationController.ErrorClass('RecordAlreadyExists', 'Public Assessments already created for this combination of Assessable object and Assessment template');
        string eClasstr1 = Json.serialize( eClass1 );

        PublicAssessmentCreationController.ErrorClass eClass2 = new PublicAssessmentCreationController.ErrorClass('System.DmlException', 'Assessment Template: id value of incorrect type: '+acctList1[0].Id);
        string eClasstr2 = Json.serialize( eClass2 );

        PublicAssessmentCreationController.ErrorClass eClass3 = new PublicAssessmentCreationController.ErrorClass('RecordAlreadyExists', 'Public Assessments already created for this combination of Assessable record and Assessment template');
        string eClasstr3 = Json.serialize( eClass3 );

        Public_Assessment__c[] paList = new Public_Assessment__c[] {
            new Public_Assessment__c(Assessment_Template__c = templateList[0].Id, Facility_Name__c = acctList[0].Id, Assessible_Object_ID__c = acctList[0].Id),
            new Public_Assessment__c(Assessment_Template__c = templateList[0].Id, Facility_Name__c = acctList[1].Id, Assessible_Object_ID__c = acctList[1].Id),
            new Public_Assessment__c(Assessment_Template__c = templateList[0].Id, Facility_Name__c = acctList[2].Id, Assessible_Object_ID__c = acctList[2].Id),
            new Public_Assessment__c(Assessment_Template__c = templateList[0].Id, Facility_Name__c = acctList[3].Id, Assessible_Object_ID__c = acctList[3].Id)
        };
        insert paList;

        PublicAssessmentCreationController.getAssessibleObjectAndTemplates();

        PublicAssessmentCreationController.onAssessibleObjectChange('Account');

        string createPAForWhichEntity1 = 'AssessableRecord'+'@@'+acctList1[0].Id;
        Map<String, String> agjAssessibleObjectApiNameMap1 = new Map<String, String>{'Account' => 'ExAM__Facility_Name__c'};
        Map<String, String> paAssessibleObjectApiNameMap1 = new Map<String, String>{'Account' => 'ExAM__Facility_Name__c'};
        String responseMsg1 = PublicAssessmentCreationController.createPublicAssessments('Account', createPAForWhichEntity1, templateList[0].Id, '12/27/2099', agjAssessibleObjectApiNameMap1, paAssessibleObjectApiNameMap1);
        system.assertEquals(responseMsg1, sClassStr1, 'Public Assessments created successfully');

        string createPAForWhichEntity2 = 'AssessableRecord'+'@@'+acctList1[0].Id;
        String responseMsg2 = PublicAssessmentCreationController.createPublicAssessments('Account', createPAForWhichEntity2, acctList1[0].Id, '12/27/2099', agjAssessibleObjectApiNameMap1, paAssessibleObjectApiNameMap1);
        system.assertEquals(responseMsg2, eClasstr2, 'Public Assessments created successfully');

        Map<String, String> agjAssessibleObjectApiNameMap2 = new Map<String, String>{'Account' => 'ExAM__Facility_Name__c'};
        Map<String, String> paAssessibleObjectApiNameMap2 = new Map<String, String>{'Account' => 'ExAM__Facility_Name__c'};
        String responseMsg3 = PublicAssessmentCreationController.createPublicAssessments('Account', createPAForWhichEntity2, templateList[0].Id, '12/27/2099', agjAssessibleObjectApiNameMap2, paAssessibleObjectApiNameMap2);
        system.assertEquals(responseMsg3, eClasstr3, 'Public Assessments created successfully');

        string createPAForWhichEntity3 = 'AssessmentGroup'+'@@'+ag.Id;
        Map<String, String> agjAssessibleObjectApiNameMap3 = new Map<String, String>{'Account' => 'ExAM__Facility_Name__c'};
        Map<String, String> paAssessibleObjectApiNameMap3 = new Map<String, String>{'Account' => 'ExAM__Facility_Name__c'};
        String responseMsg4 = PublicAssessmentCreationController.createPublicAssessments('Account', createPAForWhichEntity3, templateList[0].Id, '12/27/2099', agjAssessibleObjectApiNameMap3, paAssessibleObjectApiNameMap3);
        system.assertEquals(responseMsg4, eClasstr1, 'Public Assessments created successfully');
        
        Assessable_Fields_Mapping__c[] afmList = new Assessable_Fields_Mapping__c[]{
            new Assessable_Fields_Mapping__c(Assessment_Template__c = templateList[0].Id,Assessable_Object_API__c = 'Account'),
                new Assessable_Fields_Mapping__c(Assessment_Template__c = templateList[0].Id,Assessable_Object_API__c = 'Account',Mapped_From__c = 'Assignment Manager')
        };
        insert afmList;
        
        PublicAssessmentCreationController.AFMWrapper afmObj = new PublicAssessmentCreationController.AFMWrapper();
        afmObj.selectedObj = 'Account';
        afmObj.templateId = templateList[0].Id;
        String responseMsg5 = PublicAssessmentCreationController.getAssessableFieldMapping(afmObj);
        PublicAssessmentCreationController.FieldMappingWrapper deserializedAFM = new PublicAssessmentCreationController.FieldMappingWrapper();
        deserializedAFM = (PublicAssessmentCreationController.FieldMappingWrapper)JSON.deserialize(responseMsg5, PublicAssessmentCreationController.FieldMappingWrapper.class);
        System.assertEquals(deserializedAFM.afmList.size(), 2);
    }
}