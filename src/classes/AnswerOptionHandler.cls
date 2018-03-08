public with sharing class AnswerOptionHandler {
    
    Set<Id> questionIdSet = new Set<Id>();
    Set<Id> quesIdWithDependentQuesSet = new Set<Id>();
    Set<Id> quesIdWithNextQuesSet = new Set<Id>();
    Set<Id> multiselectQTSet = new Set<Id>();
    Map<Id,Set<String>> AnsOptquesIdWithNextQuesMap = new Map<Id,Set<String>>();
    Map<Id,List<Answer_Option__c>> quesIdWithAnsOptListMap = new Map<Id,List<Answer_Option__c>>();
    Map<Id,Id> quesIdWithAssTempIdMap = new Map<Id,Id>();
    
    public void insertValidation(List<Answer_Option__c> ansOptNewList){
        
        Map<Id,List<Answer_Option__c>> quesIdWithAnswerOptListMap = new Map<Id,List<Answer_Option__c>>();
        Set<Id> depenQuesIdSet = new Set<Id>();
        Set<Id> nextQuesIdSet = new Set<Id>();
        for( Answer_Option__c ansOpt :ansOptNewList ){
            if ( ansOpt.Question_Template__c != null ){
                questionIdSet.add(ansOpt.Question_Template__c);
            }
            if ( ansOpt.Next_Question__c != null ){
                questionIdSet.add(ansOpt.Next_Question__c);
                
                if ( !AnsOptquesIdWithNextQuesMap.containsKey(ansOpt.Question_Template__c ) ) {
                    AnsOptquesIdWithNextQuesMap.put(ansOpt.Question_Template__c,new Set<string>());
                }
                AnsOptquesIdWithNextQuesMap.get(ansOpt.Question_Template__c).add(ansOpt.Next_Question__c);
            }
            if ( ansOpt.Dependent_Question__c != null ){
                questionIdSet.add(ansOpt.Dependent_Question__c);
            }
            if ( ansOpt.Dependent_Question__c != null && !depenQuesIdSet.contains(ansOpt.Question_Template__c) ){
                depenQuesIdSet.add(ansOpt.Question_Template__c);
            }
            if ( ansOpt.Next_Question__c != null && !nextQuesIdSet.contains(ansOpt.Question_Template__c) ){
                nextQuesIdSet.add(ansOpt.Question_Template__c);
            }
            if ( ansOpt.Question_Template__c != null && 
                ( ansOpt.Next_Question__c != null || ansOpt.Dependent_Question__c != null )){
                if ( ansOpt.Next_Question__c != null && ansOpt.Dependent_Question__c != null ){
                    ansOpt.adderror('Please provide either dependent question or Next Question for answer Option Record: '+ansOpt.Name);
                } else if ( ((ansOpt.Next_Question__c != null && depenQuesIdSet.contains(ansOpt.Question_Template__c)) || 
                     (ansOpt.Dependent_Question__c != null && nextQuesIdSet.contains(ansOpt.Question_Template__c))) ){
                    ansOpt.adderror('Please provide next question or dependent question for this question Template '+ansOpt.Question_Template__c);
                } else {
                    if ( !quesIdWithAnsOptListMap.containsKey(ansOpt.Question_Template__c) ){
                        quesIdWithAnsOptListMap.put(ansOpt.Question_Template__c,new List<Answer_Option__c>());
                        quesIdWithAnsOptListMap.get(ansOpt.Question_Template__c).add(ansOpt);
                    } else {
                        quesIdWithAnsOptListMap.get(ansOpt.Question_Template__c).add(ansOpt);
                    }
                }
            }
        }
        if ( questionIdSet != null && questionIdSet.size() > 0 ){
            for( Question_Template__c ques :[SELECT Id,Name,Question_Type__c,Section_Question__r.Questionnaire_Section__c
                                            FROM Question_Template__c WHERE Id IN :questionIdSet] ){
                if ( !quesIdWithAssTempIdMap.containsKey(ques.Id) ){
                    quesIdWithAssTempIdMap.put(ques.Id,ques.Section_Question__r.Questionnaire_Section__c);
                }
                if ( ques.Question_Type__c == 'MultiselectPicklist' ) {
                    multiselectQTSet.add(ques.Id);
                }
            }
        }
        // pre validated (both != null) and question modal change(one opt has nextQues and another ques has depenQues under same quesTemp).
        if ( quesIdWithAnsOptListMap != null && quesIdWithAnsOptListMap.size() > 0 ){
            for( List<Answer_Option__c> answerOptList :quesIdWithAnsOptListMap.values() ){
                for( Answer_Option__c ansOption :answerOptList ){
                    if ( multiselectQTSet.contains(ansOption.Question_Template__c) && AnsOptquesIdWithNextQuesMap.containsKey(ansOption.Question_Template__c) &&
                         AnsOptquesIdWithNextQuesMap.get(ansOption.Question_Template__c).size() > 1 ) {
                        ansOption.adderror('Please select same question for Next Question field when question template’s question type is "MultiselectPicklist"');  
                    } else if ( ansOption.Next_Question__c != null && 
                        quesIdWithAssTempIdMap.get(ansOption.Question_Template__c) != quesIdWithAssTempIdMap.get(ansOption.Next_Question__c) ){
                        ansOption.adderror('Please provide same template\'s next question for Answer Option Record: '+ansOption.Name);
                    } else if ( ansOption.Dependent_Question__c != null && 
                        quesIdWithAssTempIdMap.get(ansOption.Question_Template__c) != quesIdWithAssTempIdMap.get(ansOption.Dependent_Question__c) ){
                        ansOption.adderror('Please provide same template\'s dependent question for Answer Option Record: '+ansOption.Name);
                    } else { 
                        if ( !quesIdWithAnswerOptListMap.containsKey(ansOption.Question_Template__c) ){
                            quesIdWithAnswerOptListMap.put(ansOption.Question_Template__c,new List<Answer_Option__c>());
                            quesIdWithAnswerOptListMap.get(ansOption.Question_Template__c).add(ansOption);
                        } else {
                            quesIdWithAnswerOptListMap.get(ansOption.Question_Template__c).add(ansOption);
                        }
                    }
                }
            }
        }
        //here records reached, when that records(trigger.New) meets is true on pre validation(within trigger.New records).
        //here this map contains pre validated records for post validation with existing records.
        if ( quesIdWithAnswerOptListMap != null && quesIdWithAnswerOptListMap.size() > 0 ){
        
            for( Answer_Option__c ansOption :[SELECT Id,Name,Help_Text__c,Weight__c,Dependent_Question__c,Next_Question__c,
                                            Question_Template__r.Question_Type__c,Question_Template__c
                                            FROM Answer_Option__c
                                            WHERE Question_Template__c IN :quesIdWithAnswerOptListMap.keySet() AND 
                                            (Dependent_Question__c != null OR Next_Question__c != null)] ){
                if ( ansOption.Dependent_Question__c != null && !quesIdWithDependentQuesSet.contains(ansOption.Question_Template__c)){
                    quesIdWithDependentQuesSet.add(ansOption.Question_Template__c);
                } else if ( ansOption.Next_Question__c != null && !quesIdWithNextQuesSet.contains(ansOption.Question_Template__c)){
                    quesIdWithNextQuesSet.add(ansOption.Question_Template__c);
                } 
                if ( ansOption.Question_Template__r.Question_Type__c == 'MultiselectPicklist' ) {
                    if ( !AnsOptquesIdWithNextQuesMap.containsKey(ansOption.Question_Template__c ) ) {
                        AnsOptquesIdWithNextQuesMap.put(ansOption.Question_Template__c,new Set<string>());
                    }
                    AnsOptquesIdWithNextQuesMap.get(ansOption.Question_Template__c).add(ansOption.Next_Question__c);
                }
                
            }
            for( List<Answer_Option__c> ansOptRecList :quesIdWithAnswerOptListMap.values() ){
                for( Answer_Option__c ansOptRec :ansOptRecList ){
                    if ( ((ansOptRec.Next_Question__c != null && quesIdWithDependentQuesSet.contains(ansOptRec.Question_Template__c)) || 
                         (ansOptRec.Dependent_Question__c != null && quesIdWithNextQuesSet.contains(ansOptRec.Question_Template__c))) ){
                        ansOptRec.adderror('Please provide next question or dependent question for this Question Template '+ansOptRec.Question_Template__c);
                    } else if ( multiselectQTSet.contains(ansOptRec.Question_Template__c) && AnsOptquesIdWithNextQuesMap.containsKey(ansOptRec.Question_Template__c) && 
                                AnsOptquesIdWithNextQuesMap.get(ansOptRec.Question_Template__c).size() > 1 ) {
                        ansOptRec.adderror('All Answer Options should point to the same Next Question for MultiselectPicklist question type');  
                    } 
                }
            }
        }
    }
    
    public void updateValidation(List<Answer_Option__c> ansOptNewList, Map<Id,Answer_Option__c> ansOptOldMap){
        for( Answer_Option__c ansOpt :ansOptNewList ){
            if ( ansOpt.Next_Question__c != null && ansOpt.Dependent_Question__c != null ){
                ansOpt.adderror('Please provide either dependent question or Next Question for Answer Option Record: '+ansOpt.Name);
            } else {
                if ( ansOpt.Question_Template__c != null ){
                    questionIdSet.add(ansOpt.Question_Template__c);
                }
                if ( ansOpt.Next_Question__c != null ){
                    questionIdSet.add(ansOpt.Next_Question__c);
                    
                    if ( !AnsOptquesIdWithNextQuesMap.containsKey(ansOpt.Question_Template__c ) ) {
                        AnsOptquesIdWithNextQuesMap.put(ansOpt.Question_Template__c,new Set<string>());
                    }
                    AnsOptquesIdWithNextQuesMap.get(ansOpt.Question_Template__c).add(ansOpt.Next_Question__c);
                }
                if ( ansOpt.Dependent_Question__c != null ){
                    questionIdSet.add(ansOpt.Dependent_Question__c);
                }
                if ( ansOpt.Dependent_Question__c != ansOptOldMap.get(ansOpt.Id).Dependent_Question__c || 
                     ansOpt.Next_Question__c != ansOptOldMap.get(ansOpt.Id).Next_Question__c ){
                     if ( ansOpt.Question_Template__c != null && 
                        ( ansOpt.Next_Question__c != null || ansOpt.Dependent_Question__c != null )){
                        if ( !quesIdWithAnsOptListMap.containsKey(ansOpt.Question_Template__c) ){
                            quesIdWithAnsOptListMap.put(ansOpt.Question_Template__c,new List<Answer_Option__c>());
                            quesIdWithAnsOptListMap.get(ansOpt.Question_Template__c).add(ansOpt);
                        } else {
                            quesIdWithAnsOptListMap.get(ansOpt.Question_Template__c).add(ansOpt);
                        }
                    }
                     
                }
            }
        }
        if ( questionIdSet != null && questionIdSet.size() > 0 ){
            for( Question_Template__c ques :[SELECT Id,Name,Question_Type__c,Section_Question__r.Questionnaire_Section__c
                                            FROM Question_Template__c WHERE Id IN :questionIdSet] ){
                if ( !quesIdWithAssTempIdMap.containsKey(ques.Id) ){
                    quesIdWithAssTempIdMap.put(ques.Id,ques.Section_Question__r.Questionnaire_Section__c);
                }
                if ( ques.Question_Type__c == 'MultiselectPicklist' ) {
                    multiselectQTSet.add(ques.Id);
                }
            }
        }
        
        if ( quesIdWithAnsOptListMap != null && quesIdWithAnsOptListMap.size() > 0 ){
        
            for( Answer_Option__c ansOption :[SELECT Id,Name,Help_Text__c,Weight__c,Dependent_Question__c,Next_Question__c,
                                            Question_Template__r.Question_Type__c,Question_Template__c
                                            FROM Answer_Option__c
                                            WHERE Question_Template__c IN :quesIdWithAnsOptListMap.keySet() AND 
                                            (Dependent_Question__c != null OR Next_Question__c != null) AND Id NOT IN :ansOptNewList ] ){
                
                if ( ansOption.Dependent_Question__c != null && !quesIdWithDependentQuesSet.contains(ansOption.Question_Template__c)){
                    quesIdWithDependentQuesSet.add(ansOption.Question_Template__c);
                } else if ( ansOption.Next_Question__c != null && !quesIdWithNextQuesSet.contains(ansOption.Question_Template__c)){
                    quesIdWithNextQuesSet.add(ansOption.Question_Template__c);
                }
                if ( ansOption.Question_Template__r.Question_Type__c == 'MultiselectPicklist' ) {
                    if ( !AnsOptquesIdWithNextQuesMap.containsKey(ansOption.Question_Template__c ) ) {
                        AnsOptquesIdWithNextQuesMap.put(ansOption.Question_Template__c,new Set<string>());
                    }
                    AnsOptquesIdWithNextQuesMap.get(ansOption.Question_Template__c).add(ansOption.Next_Question__c);
                }
            }
            for( List<Answer_Option__c> ansOptRecList :quesIdWithAnsOptListMap.values() ){
                for( Answer_Option__c ansOptRec :ansOptRecList ){
                    if ( ansOptRec.Next_Question__c != null && 
                        quesIdWithAssTempIdMap.get(ansOptRec.Question_Template__c) != quesIdWithAssTempIdMap.get(ansOptRec.Next_Question__c) ){
                        ansOptRec.adderror('Please provide same template\'s next question for Answer Option Record: '+ansOptRec.Name);
                    } else if ( ansOptRec.Dependent_Question__c != null && 
                        quesIdWithAssTempIdMap.get(ansOptRec.Question_Template__c) != quesIdWithAssTempIdMap.get(ansOptRec.Dependent_Question__c) ){
                        ansOptRec.adderror('Please provide same template\'s dependent question for Answer Option Record: '+ansOptRec.Name);
                    } else if ( (ansOptRec.Next_Question__c != null && quesIdWithDependentQuesSet.contains(ansOptRec.Question_Template__c)) || 
                         (ansOptRec.Dependent_Question__c != null && quesIdWithNextQuesSet.contains(ansOptRec.Question_Template__c)) ){
                        ansOptRec.adderror('Please provide next question or dependent question for this Question Template '+ansOptRec.Question_Template__c);
                    } else if ( multiselectQTSet.contains(ansOptRec.Question_Template__c) && AnsOptquesIdWithNextQuesMap.containsKey(ansOptRec.Question_Template__c) && 
                                AnsOptquesIdWithNextQuesMap.get(ansOptRec.Question_Template__c).size() > 1 ) {
                        ansOptRec.adderror('All Answer Options should point to the same Next Question for MultiselectPicklist question type');  
                    } 
                }
            }
        }
    }
}