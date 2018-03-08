public with sharing class ScoreBasedPageForwardingController {

    public string templateId { get; set; }
    public String scoreUrls { get; set; }
    public string assCompletedURL { get;set; }
    
    public ScoreBasedPageForwardingController() {
    
        templateId = ApexPages.currentPage().getParameters().get('tempId');
        scoreUrls = '';
        assCompletedURL = '';
        
        if (templateId != null && templateId != '') {
        
            List<Main_questionaire__c> assTempList = new List<Main_questionaire__c>([
                SELECT Id,Assessment_Completed_URL__c FROM Main_questionaire__c WHERE Id = :templateId]);
            if(assTempList.size() > 0) {
                assCompletedURL = assTempList[0].Assessment_Completed_URL__c;
            }
            List<Fact_Score_Data__c> existScoreDataList = [ SELECT Id, Assessment_Template__c, Assessment_Completed_URL_JSON__c  
                                                                FROM Fact_Score_Data__c 
                                                                WHERE Assessment_Template__c =:templateId 
                                                                ORDER BY LastModifiedDate DESC];
            if (existScoreDataList != null && existScoreDataList.size() > 0) {
                scoreUrls = existScoreDataList[0].Assessment_Completed_URL_JSON__c ; 
            }
        }
    } 
    @RemoteAction
    public static string saveUrls(string saveAssTempUrl, string saveUrls, string tempId) {

        string message = '';
        if (tempId != null && tempId != '') {
            List<Main_questionaire__c> assTempList = new List<Main_questionaire__c>([
                SELECT Id,Assessment_Completed_URL__c FROM Main_questionaire__c WHERE Id = :tempId]);
            
            Main_questionaire__c assTemp = new Main_questionaire__c();
            if (assTempList != null && assTempList.size() > 0) {
                assTemp.Id = assTempList[0].Id; 
            }
            assTemp.Assessment_Completed_URL__c = saveAssTempUrl;
            
            List<Fact_Score_Data__c> existScoreDataList = [ SELECT Id, Assessment_Template__c 
                                                            FROM Fact_Score_Data__c 
                                                            WHERE Assessment_Template__c =:tempId
                                                            ORDER BY LastModifiedDate DESC];
            
            Fact_Score_Data__c scoreData = new Fact_Score_Data__c();
            
            if (existScoreDataList != null && existScoreDataList.size() > 0) {
                scoreData.Id = existScoreDataList[0].Id; 
            }
            scoreData.Assessment_Template__c = tempId;
            scoreData.Assessment_Completed_URL_JSON__c = saveUrls;
            try {
               
                SFDCAccessController accessForobj = ExAMUtilClass.AccessController;
                List<string> fieldsListAssTemp = new List<string>{'ExAM__Assessment_Completed_URL__c'};
                List<string> fieldsList = new List<string>{'ExAM__Assessment_Template__c','ExAM__Assessment_Completed_URL_JSON__c'};
                accessForobj.assertAuthorizedToCreate(Schema.getGlobalDescribe().get('exam__Main_questionaire__c'), fieldsListAssTemp);               
                accessForobj.assertAuthorizedToCreate(Schema.getGlobalDescribe().get('exam__Fact_Score_Data__c'), fieldsList);
                if(saveAssTempUrl != 'Not changed') {
                    upsert assTemp;
                }    
                upsert scoreData;
                message = 'success';
            } catch(Exception ex) {
                message = ex.getMessage();
            }
        }
        return message;
    }
}