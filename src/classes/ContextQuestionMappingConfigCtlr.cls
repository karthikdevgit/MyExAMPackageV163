public with sharing class ContextQuestionMappingConfigCtlr {
    
    public string answerFieldsStr {get;set;}
    public string questionListStr {get;set;}
    public string quesAndAnsFieldStr {get;set;}
    
    public ContextQuestionMappingConfigCtlr() {
       
        SFDCAccessController accessObj = ExAMUtilClass.AccessController;
        String assTempId = '';
        assTempId = ApexPages.currentPage().getParameters().get('assTempId');
        List<FieldClass> fieldClassList = new List<FieldClass>();
        
        Map <String, Schema.SObjectField> fieldMap = ExAMUtilClass.getSObjectFieldsMap('ExAM__Questionnaire_Response__c');
        List<String> Fieldlist = new List<String>();
        for (Schema.SObjectField ansField : fieldMap.Values()) {
            Schema.DescribeFieldResult fieldDesc = ansField.getDescribe();
            if ( !fieldDesc.isCalculated() && String.ValueOf(fieldDesc.getType()).touppercase() != 'REFERENCE' && fieldDesc.isCreateable() && fieldDesc.isUpdateable() ) {
                if(fieldDesc.isCustom()){
                    Fieldlist.add(fieldDesc.getName());
                }
                FieldClass fcls = new FieldClass();
                fcls.fieldApi = fieldDesc.getName();
                fcls.fieldLabel = fieldDesc.getLabel();
                fcls.fieldType = String.valueOf(fieldDesc.getType()).touppercase();
                fieldClassList.add(fcls);
            }        
        }
        system.debug('****Fieldlist'+Fieldlist);
        System.debug('***fieldClassList'+fieldClassList);
        try{
            accessObj.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Questionnaire_Response__c'), Fieldlist);
            accessObj.assertAuthorizedToCreate(Schema.getGlobalDescribe().get('exam__Questionnaire_Response__c'), Fieldlist);
            accessObj.assertAuthorizedToUpdate(Schema.getGlobalDescribe().get('exam__Questionnaire_Response__c'), Fieldlist);
            answerFieldsStr = JSON.serialize(fieldClassList);
            System.debug('***answerFieldsStr'+answerFieldsStr);
            if(assTempId !='') {
            
                List<Main_questionaire__c> assTempList =  new List<Main_questionaire__c>();
                List<Question_Template__c> quesTempList = new List<Question_Template__c>();
                List<QuestionAndAnswerFieldClass> quesAndAnsFieldList = new List<QuestionAndAnswerFieldClass>();
                Map<String,String> quesIdAndAnsFieldMap = new Map<String,String>();
                
                
                List<String> fieldsListAT = new List<String>{'ExAM__Context_Questions_Mapping__c'};
                accessObj.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Main_questionaire__c'), fieldsListAT);
                assTempList = [SELECT Id,Context_Questions_Mapping__c 
                                FROM Main_questionaire__c 
                                WHERE Id = :assTempId];
                system.debug(':::assTempList:::'+assTempList);
                if(assTempList != null && assTempList.size() > 0 ) {
                    if(assTempList[0].Context_Questions_Mapping__c != null && assTempList[0].Context_Questions_Mapping__c != '' ) {
                        List<String> mappedValues = new List<String>();
                        if(assTempList[0].Context_Questions_Mapping__c.contains(':')) {
                            mappedValues = assTempList[0].Context_Questions_Mapping__c.split(':');
                        } else {
                            mappedValues.add(assTempList[0].Context_Questions_Mapping__c);
                        }
                        if(mappedValues.size()> 0) {
                            for(String mv : mappedValues) {
                                List<String> splitVal = new List<String>();
                                splitVal = mv.split('~');
                                quesIdAndAnsFieldMap.put(splitVal[0],splitVal[1]);
                            }
                        }
                    }
                }
                List<String> fieldsList = new List<String>{'ExAM__Question_Label__c','ExAM__Next_Question__c','ExAM__Dependent_Question__c','ExAM__Question_Type__c'};
                accessObj.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Question_Template__c'), fieldsList);
                
                List<String> fieldsList1 = new List<String>{'ExAM__Help_Text__c','ExAM__Weight__c','ExAM__Dependent_Question__c','ExAM__Next_Question__c'};
                accessObj.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Answer_Option__c'), fieldsList1);
                       
                Set<String> qNameSet = new Set<String>();
                
                quesTempList = [SELECT Id,Name,Question_Label__c,Next_Question__c,Dependent_Question__c,Question_Type__c,
                                (SELECT Id,Name,Help_Text__c,Weight__c,Dependent_Question__r.Name,Next_Question__r.Name FROM Answer_Options__r)
                                FROM Question_Template__c 
                                WHERE Section_Question__r.Questionnaire_Section__c = :assTempId AND Question_Type__c != 'Hidden'
                                ];
                if(quesTempList.size() > 0) {  
                    for(Question_Template__c ques : quesTempList) {
                        List<string> tempList = new List<string>();
                        if(((ques.Next_Question__c != null && ques.Next_Question__c != '') || (ques.Dependent_Question__c != null && ques.Dependent_Question__c != '') ) && ques.Answer_Options__r.size() == 0 ) {
                            if(ques.Next_Question__c != null && ques.Next_Question__c != '') {
                                if(ques.Next_Question__c.contains('~')) {
                                    tempList = ques.Next_Question__c.split('~');
                                    for(string quesName : tempList) {
                                        qNameSet.add(quesName);
                                    }
                                } else {
                                    qNameSet.add(ques.Next_Question__c);
                                }
                            }
                            if (ques.Dependent_Question__c != null && ques.Dependent_Question__c != '') {
                                if(ques.Dependent_Question__c.contains('~')) {
                                    tempList = ques.Dependent_Question__c.split('~');
                                    for(string quesName : tempList) {
                                        qNameSet.add(quesName);
                                    }
                                } else {
                                    qNameSet.add(ques.Dependent_Question__c);
                                }
                            }
                        } else {
                        
                            for( Answer_Option__c ansOpt :ques.Answer_Options__r ){
                                if ( ansOpt != null && ansOpt.Next_Question__r.Name != null && ansOpt.Next_Question__r.Name != '' ){
                                    tempList.add(ansOpt.Next_Question__r.Name);
                                } 
                                if (ansOpt != null && ansOpt.Dependent_Question__r.Name != null && ansOpt.Dependent_Question__r.Name != '' ) {
                                    tempList.add(ansOpt.Dependent_Question__r.Name);
                                }
                            }
                            if ( tempList.size() > 0 ){
                                for(string quesName : tempList) {
                                    qNameSet.add(quesName);
                                }
                            }
                        }
                    }
                    if(qNameSet.size() > 0) {
                        Integer i = 0;
                        while(i < quesTempList.size()) {
                            for(String dtques : qNameSet) {
                                if(dtques == quesTempList[i].Name) {
                                    quesTempList.remove(i);
                                    qNameSet.remove(dtques);
                                    i--;
                                    break;
                                } 
                            }
                            i++;
                        }
                    }
                    questionListStr = JSON.serialize(quesTempList);
                    
                    for(Question_Template__c ques : quesTempList) {
                        if(quesIdAndAnsFieldMap.containsKey(ques.Id)) {
                            for(FieldClass fields : fieldClassList) {
                                if(fields.fieldApi == quesIdAndAnsFieldMap.get(ques.Id)) {
                                    QuestionAndAnswerFieldClass qa = new QuestionAndAnswerFieldClass();
                                    qa.questionId = ques.Id;
                                    qa.answerFieldApi = fields.fieldApi;
                                    quesAndAnsFieldList.add(qa);
                                    break;
                                }
                            }
                        }
                    }
                }
                if(quesAndAnsFieldList.size() > 0) {
                    quesAndAnsFieldStr = JSON.serialize(quesAndAnsFieldList);
                } else {
                    QuestionAndAnswerFieldClass qa = new QuestionAndAnswerFieldClass();
                    qa.questionId = '';
                    qa.answerFieldApi = '';
                    quesAndAnsFieldList.add(qa);
                    quesAndAnsFieldStr = JSON.serialize(quesAndAnsFieldList);
                }
                
            }
        }catch(Exception ex){
             ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
        }
               
    }
    
    @RemoteAction
    public static string saveMappingFieldsFunc(List<QuestionAndAnswerFieldClass> quesAndAnsFieldsList,String assTempId,Boolean isReqForUpdation) {
        system.debug('::::quesAndAnsFieldsList::::'+quesAndAnsFieldsList);
        
        String contextQuestionsStr = '';
        String resultMsg = '';
        SFDCAccessController accessObj = ExAMUtilClass.AccessController;
        
        try {    
        
            List<String> fieldsListAT = new List<String>{'ExAM__Context_Questions_Mapping__c'};
            accessObj.assertAuthorizedToUpdate(Schema.getGlobalDescribe().get('exam__Main_questionaire__c'), fieldsListAT);
            if(quesAndAnsFieldsList != null && quesAndAnsFieldsList.size()> 0) {
                for(QuestionAndAnswerFieldClass quesAndAns : quesAndAnsFieldsList) {
                    contextQuestionsStr += quesAndAns.questionId+'~'+quesAndAns.answerFieldApi+':';
                }
                if(contextQuestionsStr.endsWith(':')) {
                    contextQuestionsStr = contextQuestionsStr.removeEnd(':');
                }
                
                Main_questionaire__c assTemplate = new Main_questionaire__c();
                assTemplate.Id = assTempId;
                assTemplate.Context_Questions_Mapping__c = contextQuestionsStr;
                update assTemplate;
                resultMsg = 'success';
                
            } else if(quesAndAnsFieldsList.size()== 0 && isReqForUpdation) {
            
                Main_questionaire__c assTemplate = new Main_questionaire__c();
                assTemplate.Id = assTempId;
                assTemplate.Context_Questions_Mapping__c = '';
                update assTemplate;
                resultMsg = 'success';
            }
            return resultMsg;
        } catch(exception e) {
            resultMsg = e.getMessage();
            return resultMsg;
        }
    }
    
    public class FieldClass {
        public String fieldApi;
        public String fieldLabel;
        public String fieldType;
    }
    
    public class QuestionAndAnswerFieldClass {
        public string questionId;
        public String answerFieldApi;
    }
}