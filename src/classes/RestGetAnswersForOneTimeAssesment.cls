@RestResource(urlMapping='/OTAAnswers/*')
global with sharing class RestGetAnswersForOneTimeAssesment {

  @HttpPost
  global static String getAnswersForOneTimeAssesment(String assessmentTemplateId, String ASMId, String AdditionalParam) {
      
    return MobileAppUtill.getAnswersForOneTimeAssesment(assessmentTemplateId, ASMId);
  }
}