@RestResource(urlMapping='/SaveDecisionTree/*')
global with sharing class RestSaveDecisionTreeAnswerRecords {

  @HttpPost
  global static String saveDecisionTreeAnswerRecords(List<Questionnaire_Response__c> decisionTreeAnsList) {
      
    system.debug('decisionTreeAnsList::::::::'+decisionTreeAnsList); 
    return MobileAppUtill.saveDecisionTreeAnswerRecords(decisionTreeAnsList);
  }
}