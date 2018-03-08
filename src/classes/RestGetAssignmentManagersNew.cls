@RestResource(urlMapping='/IssueRequestNew/*')
global with sharing class RestGetAssignmentManagersNew {

  @HttpPost
  global static String getAssignmentManagersNew(List<Id> templateIdList) {
      
      
    return MobileAppUtill.getAssignmentManagersNew(templateIdList,'Rest');
  }
}