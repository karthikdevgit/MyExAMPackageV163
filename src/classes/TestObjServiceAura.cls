@isTest
private class TestObjServiceAura {
    
    @testSetup static void dataforTest() {
        
        ExAM__Public_Assessment_Configuration__c pac = ExAM__Public_Assessment_Configuration__c.getOrgDefaults();
        if (pac.Id == null) {
            pac = new ExAM__Public_Assessment_Configuration__c();
            pac.SetUpOwnerId = UserInfo.getOrganizationId();
            pac.ExAM__Site_URL__c = 'https://www.google.com';
            insert pac;
        }
        
        List<Main_questionaire__c> assessment = new List<Main_questionaire__c>{
                new Main_questionaire__c(Template_name__c = 'testAssessment'),
                new Main_questionaire__c(Template_name__c = 'testAssess')};
        insert assessment;
        
        List<Account> acc = new List<Account>{new Account(Name='kk'),new Account(Name='kk2')};
        insert acc;
        
        Assessment_Group__c assgrp = new Assessment_Group__c();
        assgrp.Name = 'testgroup';
        assgrp.Type__c = 'Account';
        insert assgrp;
        
        List<Assessment_Group_Junction__c> agjList = new List<Assessment_Group_Junction__c>{
                                         new Assessment_Group_Junction__c(Assessment_Group__c = assgrp.Id, Facility_Name__c = acc[0].Id),
                                         new Assessment_Group_Junction__c(Assessment_Group__c = assgrp.Id, Facility_Name__c = acc[1].Id)};
        insert agjList;
        
    }

    static testMethod void validateObjService(){
        
        List<Main_questionaire__c> assessment = [SELECT Id, Template_name__c FROM Main_questionaire__c];                
        
        IssueRequest_Life_Cycle__c AMTemplate = new IssueRequest_Life_Cycle__c(Issue_request__c = 'testIssue', InvestigationType__c=assessment[0].Id);
        AMTemplate = ObjServiceAura.createNewAObj(AMTemplate, 'account', 'Accounts');        
        
        List<ObjService.fieldWrapper> fieldWrapperList = new List<ObjService.fieldWrapper>();
        ObjService.fieldWrapper  fieldWrapper = new ObjService.fieldWrapper();
        
        fieldWrapper.fieldApi = 'Name';
        fieldWrapper.fieldDisplay = true;
        fieldWrapper.fieldLabel = 'Account Name';
        fieldWrapper.fieldValue = 'testing';
        fieldWrapperList.add(fieldWrapper);
        
        String objFields  = JSON.serialize(fieldWrapperList);
        List<sobject> objList = ObjServiceAura.getObjList('Account', objFields, '', '');        
        Account acc = (Account)objList[0];
        
        //System.assertEquals(acc.id, AMTemplate.Facility_Name__c);
        
        sObject obj = ObjServiceAura.updateRecord('Account', objList[0].id, 'Name', 'testing');
        acc = (Account)obj;
        System.assertEquals('testing', acc.Name);
        
        IssueRequest_Life_Cycle__c assignmentManager = [SELECT Id, Assessment_Template_Type__c FROM IssueRequest_Life_Cycle__c WHERE Id = :AMTemplate.Id];
        System.assertEquals('testAssessment', assignmentManager.Assessment_Template_Type__c);
    }

    static testMethod void testgeneratePublicAssessmentLink(){

        List<Main_questionaire__c> assessment = [SELECT Id, Template_name__c FROM Main_questionaire__c];     
        
        //CASE:1                        
        String Params = '{"AMApi":"Facility_Name__c","assessmentGroupJunctionFieldApi":"Facility_Name__c","selectedTemplateId":"';
        Params+= assessment[0].Id+'","noofrecords":"2","AssessableObjectApi":"Account","selectedobjectLabel":"Account"}';
        System.debug(':::::Params::::'+Params);
        String response = ObjService.generatePublicAssessmentLink(Params);
        
        ObjService.ReturnPALinksClass param = new ObjService.ReturnPALinksClass();
        param = (ObjService.ReturnPALinksClass)JSON.deserialize(response, ObjService.ReturnPALinksClass.class);
        
        system.assertEquals(2,param.objectList.size());
        system.assertEquals(2,param.amList.size());
        system.assertEquals(2,param.paList.size());

        ExAM__Public_Assessment_Configuration__c pac = ExAM__Public_Assessment_Configuration__c.getOrgDefaults();
        if (pac.Id != null) {
            for (IssueRequest_Life_Cycle__c am : param.amList) {
                for (Public_Assessment__c pm : param.paList) {
                    if (am.Id == pm.ExAM__Assignment_Manager__c) {
                        string paurl = pac.ExAM__Site_URL__c+'/ExAM__AMAndAnswerCreationPage?paId='+ string.valueOf(pm.Id).substring(0, 15);
                        system.assertEquals(paurl, am.ExAM__Public_Assessment_URL__c);
                        break;
                    }
                }
            }
        }
        
        //CASE:2                
        List<Account> accList = [SELECT Id, Name FROM Account];
        
        Assessment_Group__c assgrp = [SELECT Id, Name, Type__c FROM Assessment_Group__c];        
        
        List<Assessment_Group_Junction__c> agjList = [SELECT Id, Assessment_Group__c FROM Assessment_Group_Junction__c];
        
        String testparams = '{"AMApi":"Facility_Name__c","assessmentGroupJunctionFieldApi":"Facility_Name__c","selectedGroupId":"';
        testparams+=assgrp.Id+'","selectedTemplateId":"'+assessment[0].Id+'","AssessableObjectApi":"Account","selectedobjectLabel":"Account"}';
        String res = ObjService.generatePublicAssessmentLink(testparams); 
        
        ObjService.ReturnPALinksClass returnParam = new ObjService.ReturnPALinksClass();
        returnParam = (ObjService.ReturnPALinksClass)JSON.deserialize(res, ObjService.ReturnPALinksClass.class);
        
        List<Public_Assessment__c> paList = [SELECT Id FROM Public_Assessment__c];
        
        system.assertEquals(2,returnParam.amList.size());
        system.assertEquals(4,paList.size());
        system.assertEquals(accList[0].Id, returnParam.amList[0].Facility_Name__c);
        system.assertEquals(accList[1].Id, returnParam.amList[1].Facility_Name__c);
        
        String Params2 = '{"AMApi":"Facility_Name__c","assessmentGroupJunctionFieldApi":"Facility_Name__c","selectedTemplateId":"';
        Params2+= assessment[0].Id+'","noofrecords":"2","AssessableObjectApi":"Account","selectedobjectLabel":"Account","expDate":"12/15/2017"}';
        System.debug(':::::Params::::'+Params2);
        String response2 = ObjService.generatePublicAssessmentLink(Params2);
             
        //CASE:3
        String Params1 = '{"AMApi":"Facility_Name__c","assessmentGroupJunctionFieldApi":"Facility_Name__c","selectedTemplateId":"';
        Params1+= assessment[0].Id+'","noofrecords":"2","AssessableObjectApi":"Account","selectedobjectLabel":"Account","expDate":"15/12/2017"}';
        System.debug(':::::Params::::'+Params1);
        try {
            String response1 = ObjService.generatePublicAssessmentLink(Params1);
        }catch(Exception e) {
            System.assertEquals('Invalid date: 15/12/2017', e.getMessage());
        }       
    }

    static testMethod void testgeneratePublicAssessmentLink1(){
        
        //CASE:3
        List<Main_questionaire__c> assessment = [SELECT Id, Template_name__c FROM Main_questionaire__c];
        List<Account> accList = [SELECT Id, Name FROM Account];
        Assessment_Group__c assgrp = [SELECT Id, Name, Type__c FROM Assessment_Group__c];
        List<Assessment_Group_Junction__c> agjList = [SELECT Id, Assessment_Group__c FROM Assessment_Group_Junction__c]; 
        
        String testparam = '{"AMApi":"Facility_Name__c","assessmentGroupJunctionFieldApi":"Facility_Name__c","selectedTemplateId":"';
        testparam+=assessment[0].Id+'","AssessableObjectApi":"Account","noofrecords":"2","selectedobjectLabel":"Account","assessableRecId":"'+accList[0].Id+'"}';
        String resp = ObjService.generatePublicAssessmentLink(testparam);
        
        ObjService.ReturnPALinksClass returnParams = new ObjService.ReturnPALinksClass();
        returnParams = (ObjService.ReturnPALinksClass)JSON.deserialize(resp, ObjService.ReturnPALinksClass.class);
        
        List<Public_Assessment__c> pubassList = [SELECT Id FROM Public_Assessment__c];
        
        system.assertEquals(2,returnParams.amList.size());
        system.assertEquals(2,pubassList.size());
    }

    static testMethod void validateObjServiceOfFetchObjList(){ 
        Main_questionaire__c newAssessment = new Main_questionaire__c();
        newAssessment.Template_name__c = 'test';
        insert newAssessment;
        
        // CASE 1 : passing recordId only
        List<Id> sobjectIdList = new List<Id>{newAssessment.Id};
        List<sobject> objectList = ObjServiceAura.fetchObjList(sobjectIdList, null, null); 
        System.assertEquals(newAssessment.Id, objectList[0].Id);
        
        // CASE 2 : passing recordId, preDefinedFields
        objectList = ObjServiceAura.fetchObjList(sobjectIdList, null, 'ExAM__Template_name__c, ExAM__isArchive__c'); 
        List<Main_questionaire__c> assessmentList = (List<Main_questionaire__c>)objectList;
        System.assertEquals(false, assessmentList[0].isArchive__c);
        
        // CASE 3 : passing recordId, fieldSetName, and preDefinedFields
        objectList = ObjServiceAura.fetchObjList(sobjectIdList, 'ExAM__lightningComp_BasicOptions_FieldSet', 'ExAM__Template_name__c'); 
        assessmentList = (List<Main_questionaire__c>)objectList;
        System.assertEquals('test', assessmentList[0].Template_name__c);                        
        
        List<Main_questionaire__c> assessments = [SELECT Id, Template_name__c FROM Main_questionaire__c];
        List<Account> acc = [SELECT Id, Name FROM Account];
        
        sobjectIdList.add(acc[0].Id);
        sobjectIdList.add(acc[1].Id);
        sobjectIdList.add(assessments[0].Id);
        sobjectIdList.add(assessments[1].Id);
        
        // CASE 4 : passing recordId Of Assessment and account, fieldSetName, and preDefinedFields
        objectList = ObjServiceAura.fetchObjList(sobjectIdList, 'ExAM__lightningComp_BasicOptions_FieldSet', 'ExAM__Template_name__c'); 
        System.assertEquals(3, objectList.size());
        
    }
}