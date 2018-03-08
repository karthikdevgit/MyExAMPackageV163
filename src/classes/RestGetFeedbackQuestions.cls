@RestResource(urlMapping='/FeedbackQuestions/*')
global with sharing class RestGetFeedbackQuestions {
    
  @HttpPost
  global static String getFeedbackQuestions(FeedbackQuestionsClass feedbackQuestion) {
      
      return MobileAppUtill.saveFeedbackAnswers(feedbackQuestion);
  }
  
  global class FeedbackQuestionTemplateClass{
      
      public String sectionName;
      public String questionName;
      public String questionType;
      public String helpText;
      public String questionId;
      public String answerOptions;
      public Boolean isMandatory;
  }
  
  
  global class FeedbackQuestionsClass {
  
  }

}