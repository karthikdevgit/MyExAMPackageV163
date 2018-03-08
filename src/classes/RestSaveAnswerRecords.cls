@RestResource(urlMapping='/SaveAnswerRecords/*')
global with sharing class RestSaveAnswerRecords {

  @HttpPost
  global static String saveAnswerRecords(List<AnswerRecordClass> answerList,String tempId,String assignmentId,Boolean isSubmit) {
        String totalAssesmentTime;
        List<String> multipleValuesList = new List<String>();
        Map<Id,Id> quesIdANDAnsIdMap = new Map<Id,Id>();
        
        if (tempId != null && tempId.contains('~')) {
            
            multipleValuesList = tempId.split('~');
            if(multipleValuesList.size() == 3){
                tempId = multipleValuesList[0];
                totalAssesmentTime = multipleValuesList[1];
                quesIdANDAnsIdMap = (Map<Id,Id>)System.JSON.deserialize(multipleValuesList[2], Map<Id,Id>.class);
            }else if(multipleValuesList.size() == 2){
                tempId = multipleValuesList[0];
                totalAssesmentTime = multipleValuesList[1];
            }else{
                totalAssesmentTime = '0';
            }
        } else {
            totalAssesmentTime = '0';
        }          
    return MobileAppUtill.saveAnswerRecords(answerList, tempId, assignmentId, isSubmit, totalAssesmentTime, quesIdANDAnsIdMap);
  }
  
  global class AnswerRecordClass {
    public String questiontemplateId;
    public String assignmentManagerId;
    public String response;
    public String comment;
 }
  
}