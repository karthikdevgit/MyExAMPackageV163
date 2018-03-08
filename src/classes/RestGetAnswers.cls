@RestResource(urlMapping='/DataViewer/*')
global with sharing class RestGetAnswers {

  @HttpPost
  global static String getAnswers(String assignmentManagerId) {
      
      
    return MobileAppUtill.queryAllAnswerRecords(assignmentManagerId,true);
  }
}