@isTest 
private class TestCaseHandler {
    static testMethod void method1() {
        
        Contact[] conList = new Contact[]{
            new Contact(LastName = 'test contact',Email = 'test@test.com') 
        };
        insert conList;
        
        case caseObj = new case();
        caseObj.ContactId = conList[0].Id;
        caseObj.Origin = 'Email';
        insert caseObj;
        
        Main_questionaire__c assTemp = new Main_questionaire__c();
        assTemp.Template_Name__c = 'Test Template';
        insert assTemp;
        
        String json = '[{"configTempName":"'+assTemp.Id+'","configFieldValue":"Email","configFieldName":"Origin"}]';
        
        
        
        Map<Id,case> oldCaseMap = new Map<Id,case>();
        oldCaseMap.put(caseObj.Id,caseObj);
        
        
        
        //String json = '[{"configTempName":"'+assTemp.Id+'","configFieldValue":"Email","configFieldName":"Origin"}]';
        ExAM_Configuration__c exmConfig = new ExAM_Configuration__c();
        exmConfig.Name='Configuration';
        exmConfig.Enable_Case_Survey__c = true;
        exmConfig.Case_Configuration__c = json;
        insert exmConfig;
        
        case updateCaseObj = new case();
        updateCaseObj.Id = caseObj.Id;
        updateCaseObj.status = 'Closed';
        try{
            update updateCaseObj;
        }catch(Exception e){
            System.debug('**e'+e);    
        }
        
        List<case> newCaseList = new List<case>();
        newCaseList.add(updateCaseObj);

        Test.startTest();
            CaseHandler ch = new CaseHandler();
            CaseHandler.createPublicAssessmentRecords(oldCaseMap,newCaseList);
        Test.stopTest();
        
        List<ExAM__Public_Assessment__c> paObj = new List<ExAM__Public_Assessment__c>();
        paObj = [SELECT Id,Assessment_Template__c FROM ExAM__Public_Assessment__c WHERE Assessment_Template__c = :assTemp.Id];
        system.assertNotEquals(1, paObj.size());
    }
}