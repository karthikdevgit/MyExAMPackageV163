@RestResource(urlMapping='/SaveDecisionTreeNew/*')
global with sharing class RestSaveDecisionTreeAnswerRecordsNew {

  @HttpPost
  global static String saveDecisionTreeAnswerRecords(DecisionTreeResponseClass decisionTreeAnsListObj) {
      
    //system.debug('decisionTreeAnsList::::::::'+decisionTreeAnsList); 
    return MobileAppUtill.saveDecisionTreeAnswerRecordsNew(decisionTreeAnsListObj);
  }
  
  //Added on 20-07-2017 for delete decision tree old path by one time assessment
    global class DecisionTreeResponseClass {
        global List<Questionnaire_Response__c> dtResponseList;
        global Boolean oneTimeAss;
        global String startQuestion;
        global String templateId;
    }
}