@RestResource(urlMapping='/SaveFeedbackAnswers/*')
global with sharing class RestSaveFeedbackAnswers {
  
  @HttpPost
  global static String saveFeedbackAnswers(FeedbackAnswersClass feedbackAnswers) {
      
      return MobileAppUtill.saveFeedbackAnswers(feedbackAnswers);
  }
  
  global class FeedbackAnswersClass {
      
      public List<Questionnaire_Response__c> answerList;
      public Id userId;
      public string screenName;
      public Id decisionTreeQuestionId;
  }

}