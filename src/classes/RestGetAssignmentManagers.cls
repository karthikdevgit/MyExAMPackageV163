@RestResource(urlMapping='/IssueRequest/*')
global with sharing class RestGetAssignmentManagers {

  @HttpPost
  global static String getAssignmentManagers(List<Id> templateIdList) {
      
      
    return MobileAppUtill.getAssignmentManagers(templateIdList,'Rest');
  }
}