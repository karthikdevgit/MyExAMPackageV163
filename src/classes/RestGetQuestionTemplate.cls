@RestResource(urlMapping='/QuestionTemplate/*')
global with sharing class RestGetQuestionTemplate {
    
  @HttpPost
  global static String getQuestionTemplate(QuestionTemplateClass questionTemplateClassInput) {
      
      QuestionTemplateResponseClass questionTemplateResponse = new QuestionTemplateResponseClass();
      questionTemplateResponse.questionTemplateRecords = new Map<Id, List<ExAM__Question_Template__c>>();
      questionTemplateResponse.sectionTemplateRecord = new List<ExAM__Section_Template__c >();
      List<ExAM__Section_Template__c > sectionTemplateList = new List<ExAM__Section_Template__c >();
      List<ExAM__Question_Template__c> questionTemplateList = new List<ExAM__Question_Template__c>();
      Map<Id,List<ExAM__Question_Template__c>> questionTemplateMap = new Map<Id,List<ExAM__Question_Template__c>>();
          
      if(questionTemplateClassInput.templateId != null){
          
          Set<String> questionTypeSet = new Set<String>{'Button','Dropdown Picklist','RadioPicklist','Result'};
          Set<String> questionTemplateNameSet = new Set<String>();
          Set<String> mobileSupportedQuestionType = new Set<String>{'Text','Email','Phone Number','Textarea','Date','Dropdown Picklist','RadioPicklist','MultiselectPicklist','Button','File Question - AM','File Question - Answer','Signature'};
          
          
          sectionTemplateList = [Select Id, ExAM__Section_label__c, ExAM__Order_No__c from ExAM__Section_Template__c where ExAM__Questionnaire_Section__c =: questionTemplateClassInput.templateId ORDER BY ExAM__Order_No__c ASC NULLS LAST];
          
          if(sectionTemplateList.size() > 0){
          
             for (ExAM__Question_Template__c qt : [select Id, ExAM__Next_Question__c, ExAM__Question_Type__c, 
                                              ExAM__Section_Question__c, Name,
                                              (SELECT Id,Name,ExAM__Next_Question__r.Name FROM ExAM__Answer_Options__r ORDER BY ExAM__Order_No__c ASC)
                                               from ExAM__Question_Template__c 
                                              Where ExAM__Section_Question__c IN: sectionTemplateList AND ExAM__Question_Type__c IN: questionTypeSet]) {
                 if(qt.ExAM__Answer_Options__r.size() > 0){
                     for( ExAM__Answer_Option__c ansOpt :qt.ExAM__Answer_Options__r ){
                         if(ansOpt.ExAM__Next_Question__r != null){
                         questionTemplateNameSet.add(ansOpt.ExAM__Next_Question__r.Name);
                         }
                     }
                 }else if(qt.ExAM__Next_Question__c != null){
                     if(qt.ExAM__Next_Question__c.contains('~')) {
                        List<string> tempList = new List<string>();
                        tempList = qt.ExAM__Next_Question__c.split('~');
                        for(string quesName : tempList) {
                            questionTemplateNameSet.add(quesName);
                        }
                     } else {
                        questionTemplateNameSet.add(qt.ExAM__Next_Question__c);
                     }
                 }
             
             }
             
             for(ExAM__Question_Template__c qt: [select Id, ExAM__Section_Question__c, ExAM__Is_Dependent__c, ExAM__HelpText__c, ExAM__Is_Mandatory__c, 
                                            ExAM__Knowledge_Article_Link__c, Name, ExAM__Next_Question__c, ExAM__Question_Label__c, ExAM__Question_Type__c,
                                            ExAM__Do_Not_Create_Answer__c, ExAM__Question_Order_No__c,
                                            ExAM__Subquestion_Label__c, ExAM__SubSection_label__c,
                                            (SELECT Id,Name, ExAM__Help_Text__c, ExAM__Weight__c, ExAM__Dependent_Question__r.Name, ExAM__Next_Question__r.Name FROM ExAM__Answer_Options__r ORDER BY ExAM__Order_No__c ASC)
                                            from ExAM__Question_Template__c 
                                            Where ExAM__Section_Question__c IN: sectionTemplateList AND Name NOT IN: questionTemplateNameSet 
                                            AND ExAM__Question_Type__c IN: mobileSupportedQuestionType AND ExAM__Is_Dependent__c = false
                                            ORDER BY ExAM__Question_Order_No__c ASC NULLS LAST]){
                  if(qt.ExAM__Answer_Options__r.size() > 0){
                      qt.ExAM__Next_Question__c = '';
                      qt.ExAM__Subquestion_Label__c = '';
                      for( ExAM__Answer_Option__c ansOpt :qt.ExAM__Answer_Options__r ){
                          /*if( ansOpt.Next_Question__r.Name != null && ansOpt.Next_Question__r.Name != '' ){
                          
                          } */
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
                  if (!questionTemplateMap.containskey(qt.ExAM__Section_Question__c)) {
                    questionTemplateMap.put(qt.ExAM__Section_Question__c, new List<ExAM__Question_Template__c>());
                  }
                  questionTemplateMap.get(qt.ExAM__Section_Question__c).add(qt);
             } 
             questionTemplateResponse.questionTemplateRecords = questionTemplateMap;
             questionTemplateResponse.sectionTemplateRecord = sectionTemplateList;
          } else {
              questionTemplateResponse.sectionTemplateRecord = sectionTemplateList;
              questionTemplateResponse.questionTemplateRecords = questionTemplateMap;
          } 
      } else {
           questionTemplateResponse.sectionTemplateRecord = sectionTemplateList;
           questionTemplateResponse.questionTemplateRecords = questionTemplateMap;
      }
      
      return JSON.serialize(questionTemplateResponse);
  }
  
  global class QuestionTemplateResponseClass {
      global List<ExAM__Section_Template__c > sectionTemplateRecord;
      global Map<Id, List<ExAM__Question_Template__c>> questionTemplateRecords;
  }
  
  global class QuestionTemplateClass {
      global Id templateId;
  }
  
}