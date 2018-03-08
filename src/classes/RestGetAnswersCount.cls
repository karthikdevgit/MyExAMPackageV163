@RestResource(urlMapping='/AnswersCount/*')
global with sharing class RestGetAnswersCount {

  @HttpPost
  global static String getAnswersCount(AnswerWeightWrapper wrapperValues) {
  
        return MobileAppUtill.returnAnswersCount(wrapperValues);
  }
  
  global Class AnswerWeightWrapper{
      global List<Id> templateIdList;
  }
}