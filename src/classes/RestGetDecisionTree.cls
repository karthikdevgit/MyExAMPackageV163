@RestResource(urlMapping='/GetDecisionTree/*')
global with sharing class RestGetDecisionTree {
    
  
  @HttpPost
  global static String getDecisionTree(List<String> templateIdList) {
      
      return MobileAppUtill.getDecisionTree(templateIdList);
  }
}