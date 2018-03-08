@RestResource(urlMapping='/DecisionTreeTemplate/*')
global with sharing class RestGetDecisionTreeTemplate {
  @HttpPost
  global static String getDecisionTreeTemplate(DecisionTreeTemplateClass decisionTreeTemplateClassInput) {
      
      DecisionTreeTemplateResponseClass DecisionTreeTemplateResponse = new DecisionTreeTemplateResponseClass();
      DecisionTreeTemplateResponse.questionNamewithQuestionTemplate = new Map<String, ExAM__Question_Template__c>();
      
      if(decisionTreeTemplateClassInput.templateId != null){
          for(ExAM__Question_Template__c qt: [select Id, ExAM__Question_Type__c, ExAM__Question_Label__c, ExAM__HelpText__c
                                    ,Name, ExAM__Subquestion_Label__c, ExAM__Next_Question__c, ExAM__Decision_Tree__c
                                    ,ExAM__Section_Question__r.ExAM__Questionnaire_Section__c
                                    ,ExAM__Section_Question__r.ExAM__Section_label__c, 
                                    (SELECT Id,Name, ExAM__Help_Text__c, ExAM__Weight__c, ExAM__Dependent_Question__r.Name, ExAM__Next_Question__r.Name FROM ExAM__Answer_Options__r ORDER BY ExAM__Order_No__c ASC)
                                    from ExAM__Question_Template__c
                                    Where ExAM__Section_Question__r.ExAM__Questionnaire_Section__c =: decisionTreeTemplateClassInput.templateId]){
          
              if(qt.ExAM__Answer_Options__r.size() > 0){
                  qt.ExAM__Next_Question__c = '';
                  qt.ExAM__Subquestion_Label__c = '';
                  for( ExAM__Answer_Option__c ansOpt :qt.ExAM__Answer_Options__r ){
                  
                      if(qt.ExAM__Subquestion_Label__c == ''){
                          qt.ExAM__Subquestion_Label__c = ansOpt.Name;
                      }else{
                          qt.ExAM__Subquestion_Label__c += '~'+ansOpt.Name;
                      }
                      if(qt.ExAM__Next_Question__c == ''){
                          qt.ExAM__Next_Question__c = ansOpt.ExAM__Next_Question__r.Name;
                      }else{
                          qt.ExAM__Next_Question__c += '~'+ansOpt.ExAM__Next_Question__r.Name;
                      }
                      
                  }
              }
              DecisionTreeTemplateResponse.questionNamewithQuestionTemplate.put(qt.Name, qt);
          }
      }
      
      return JSON.serialize(DecisionTreeTemplateResponse);
  }
  
  global class DecisionTreeTemplateResponseClass {
      global Map<String, ExAM__Question_Template__c> questionNamewithQuestionTemplate;
      global Map<Id, Map<String, String>> resultQuestionIdDefaultVal;
  }
  global class DecisionTreeTemplateClass {
      global Id templateId;
  }
  
}