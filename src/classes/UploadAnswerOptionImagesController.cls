public with sharing class UploadAnswerOptionImagesController {

    public Integer noOfOptions { get; set; }
    public string baseUrl { get; set; }
    public string options { get; set; }
    
    public UploadAnswerOptionImagesController() {
    
        baseUrl = Url.getSalesforceBaseUrl().toExternalForm();
        options = '';
        String queTempId = ApexPages.currentPage().getParameters().get('quesTempId');

        List<Question_Template__c> quesTempList = new List<Question_Template__c>();
        
        if(queTempId != null && queTempId != '' ) {
        
            noOfOptions = 1;
            quesTempList = [SELECT Id, Name, Subquestion_Label__c FROM Question_Template__c WHERE Id = :queTempId LIMIT 1];
            
            if(quesTempList != null && quesTempList.size() > 0) {

                if (string.isNotBlank(quesTempList[0].Subquestion_Label__c)) {
                    options = quesTempList[0].Subquestion_Label__c;
                    if (quesTempList[0].Subquestion_Label__c.contains('~') ) {
                        noOfOptions = noOfOptions + quesTempList[0].Subquestion_Label__c.countMatches('~');
                    }
                }
            }
        }
    }
}