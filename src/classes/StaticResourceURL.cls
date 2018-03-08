public with sharing class StaticResourceURL {
    public static String NameSpacePrefix = ExAMUtilClass.getNameSpacePrefix();
    @AuraEnabled 
    public static String getStaticFileUrl(String resourceName){
        String publicAssessmentCSSURL;
        
        if(resourceName != null) {
            List<StaticResource> resourceList = [SELECT Name, SystemModStamp FROM StaticResource WHERE Name = :resourceName LIMIT 1];
                        
            if(!resourceList.isEmpty()){
                publicAssessmentCSSURL =  '/resource/' + resourceList[0].SystemModStamp.getTime() + '/' + NameSpacePrefix + resourceName; 
            }
            
        }
        
        return publicAssessmentCSSURL;
    }
}