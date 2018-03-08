@isTest 

private class TestScoreBasedPageForwardingController {
    
    static testMethod void testSaveUrls() {
        
        Main_questionaire__c assTemp = new Main_questionaire__c();
        assTemp.Template_name__c= 'testTemplate1';
        insert assTemp;
        
        Fact_Score_Data__c factScore = new Fact_Score_Data__c();
        factScore.Assessment_Template__c = assTemp.Id;
        factScore.Assessment_Completed_URL_JSON__c = '[{"fromScore":"1","toScore":"12","urlStr":"www.google.com"},{"fromScore":"13","toScore":"23","urlStr":"www.salesforce.com"}]';
        insert factScore;
        
        ApexPages.currentPage().getParameters().put('tempId',assTemp.Id);
        Test.startTest();
            ScoreBasedPageForwardingController score = new ScoreBasedPageForwardingController();
            ScoreBasedPageForwardingController.saveUrls('www.google.com','[{"fromScore":"1","toScore":"12","urlStr":"www.google.com"},{"fromScore":"13","toScore":"23","urlStr":"www.salesforce.com"}]',assTemp.Id);
        Test.stopTest();
        List<Main_questionaire__c> assTempList = [SELECT Id, Assessment_Completed_URL__c FROM Main_questionaire__c];
        List<Fact_Score_Data__c> factScoreList =[SELECT Id,Assessment_Template__c,Assessment_Completed_URL_JSON__c
                                                FROM Fact_Score_Data__c 
                                                WHERE Assessment_Template__c = :assTemp.Id];
        System.assert(factScoreList.size()==1);
        System.assertEquals('www.google.com', assTempList[0].Assessment_Completed_URL__c);
    }
}