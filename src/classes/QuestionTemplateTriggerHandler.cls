public with sharing class QuestionTemplateTriggerHandler {

    public void beforeUpdate(Map<Id,Question_Template__c> quesTempOldMap, Map<Id,Question_Template__c> quesTempNewMap, List<Question_Template__c> newQuestTempList) {

        validateMultiSelectQuestionUpdate(quesTempOldMap, quesTempNewMap, newQuestTempList);
    }

    public void afterInsert(List<Question_Template__c> questions) {

        createAnswerOptionForLikertQtnType(new Map<Id, Question_Template__c>(), new Map<Id, Question_Template__c>(), questions, true, false);
    }

    public void afterUpdate(Map<Id, Question_Template__c> oldQuestionsMap, Map<Id, Question_Template__c> newQuestionsMap, List<Question_Template__c> questions) {

        createAnswerOptionForLikertQtnType(oldQuestionsMap, newQuestionsMap, questions, false, true);
    }

    public void validateMultiSelectQuestionUpdate(Map<Id,Question_Template__c> quesTempOldMap, Map<Id,Question_Template__c> quesTempNewMap, List<Question_Template__c> newQuestTempList) {
        
        Set<Id> multiselectQTSet = new Set<Id>();
        Map<Id,Set<String>> AnsOptquesIdWithNextQuesMap = new Map<Id,Set<String>>();
        Map<Id,List<String>> quesIdWithNextQuesMap = new Map<Id,List<String>>();
        
        if ( quesTempOldMap != null && quesTempOldMap.size() > 0 &&
             quesTempNewMap != null && quesTempNewMap.size() > 0 ) {
            
            for (Question_Template__c qtn : newQuestTempList) {
            
                if ( quesTempNewMap.get(qtn.Id).Question_Type__c == 'MultiselectPicklist' ) {
                    multiselectQTSet.add( qtn.Id );
                }
                if ((quesTempOldMap.get(qtn.Id).Question_Type__c != qtn.Question_Type__c)
                    && (quesTempOldMap.get(qtn.Id).Question_Type__c == 'Likert' &&  qtn.Question_Type__c != 'Likert')) {

                    qtn.Likert__c = '';
                }
            }

            if ( multiselectQTSet.size() > 0 ) {
                 
                 for( Answer_Option__c ansOption :[SELECT Id,Name,Help_Text__c,Weight__c,Dependent_Question__c,Next_Question__c,
                                            Question_Template__r.Question_Type__c,Question_Template__c
                                            FROM Answer_Option__c
                                            WHERE Question_Template__c IN :multiselectQTSet AND 
                                            Next_Question__c != null] ) {                   
                
                    if ( !AnsOptquesIdWithNextQuesMap.containsKey(ansOption.Question_Template__c ) ) {
                        AnsOptquesIdWithNextQuesMap.put(ansOption.Question_Template__c,new Set<string>());
                    }
                    AnsOptquesIdWithNextQuesMap.get(ansOption.Question_Template__c).add(ansOption.Next_Question__c);                        
                }
                
                // Question template not have a answer option records
                for(Id multiSelectQT : multiselectQTSet) {
                    if(!AnsOptquesIdWithNextQuesMap.containsKey(multiSelectQT) 
                        && quesTempNewMap.get(multiSelectQT).Next_Question__c != null && quesTempNewMap.get(multiSelectQT).Next_Question__c != '') {
                        
                        List<string> splitOfoptionList = new List<string>();
                        String nextQues = quesTempNewMap.get(multiSelectQT).Next_Question__c;
                        if( nextQues.indexOf('~') > 0 ) {
                            splitOfoptionList = nextQues.split('~');
                        } else {
                            splitOfoptionList.add(nextQues);
                        }
                        quesIdWithNextQuesMap.put(multiSelectQT,splitOfoptionList);
                    }
                }

                if ( AnsOptquesIdWithNextQuesMap.size() > 0 || quesIdWithNextQuesMap.size() > 0) {
                    for ( Id qid : multiselectQTSet) {
                        if (AnsOptquesIdWithNextQuesMap.containsKey(qid) && AnsOptquesIdWithNextQuesMap.get(qid).size() > 1 ) {
                            quesTempNewMap.get(qid).adderror('All Answer Options should point to the same Next Question for MultiselectPicklist question type');
                        } else if (quesIdWithNextQuesMap.containsKey(qid) && quesIdWithNextQuesMap.get(qid).size() > 1 ) {
                            quesTempNewMap.get(qid).adderror('Please set only one Next Question for MultiselectPicklist question type');
                        }
                    }
                }
            }
        }
    }

    public void createAnswerOptionForLikertQtnType(Map<Id, Question_Template__c> oldQuestionsMap, Map<Id, Question_Template__c> newQuestionsMap, List<Question_Template__c> questions, Boolean isAfterInsert, Boolean isAfterUpdate) {

        Integer counter = 1;

        List<Question_Template__c> likertQtns = new List<Question_Template__c>();
        List<Answer_Option__c> answerOptionsList = new List<Answer_Option__c>();

        Set<Id> qtnIdSet = new Set<Id>();

        Map<string, List<string>> likertKeyAndValuesMap = new Map<string, List<string>>{
            'agreement' => new List<string>{'Strongly Agree', 'Agree', 'Undecided', 'Disagree', 'Strongly Disagree'},
            'frequency' => new List<string>{'Very Frequently', 'Frequently', 'Occasionally', 'Rarely', 'Never'},
            'importance' => new List<string>{'Very Important', 'Important', 'Moderately Important', 'Of Little Importance', 'Unimportant'},
            'likelihood' => new List<string>{'Almost Always True', 'Usually True', 'Occasionally True', 'Usually Not True', 'Almost Never True'}
        };

        if (isAfterInsert) {

            for (Question_Template__c qtn : questions) {

                if (qtn.Question_Type__c == 'Likert' && string.isNotBlank(qtn.Likert__c)) {

                    likertQtns.add( qtn );
                }
            }
        }
        else if (isAfterUpdate) {

            for (Question_Template__c qtn : questions) {

                if (oldQuestionsMap.get(qtn.Id).Question_Type__c != qtn.Question_Type__c) {

                    if (qtn.Question_Type__c == 'Likert' && string.isNotBlank(qtn.Likert__c)) {

                        likertQtns.add( qtn );
                    }
                    else if ((oldQuestionsMap.get(qtn.Id).Question_Type__c == 'Likert') && (qtn.Question_Type__c != 'Likert')) {

                        qtnIdSet.add( qtn.Id );
                    }
                }
                else if ((qtn.Question_Type__c == 'Likert') && (oldQuestionsMap.get(qtn.Id).Likert__c != qtn.Likert__c)) {

                    qtnIdSet.add( qtn.Id );
                    likertQtns.add( qtn );
                }
            }
        }

        if (qtnIdSet.size() > 0) {
            delete [SELECT Id, Name, Question_Template__c FROM Answer_Option__c WHERE Question_Template__c IN :qtnIdSet];
        }
        if (likertQtns != null && likertQtns.size() > 0) {

            for (Question_Template__c qtn : likertQtns) {

                string likertKey = qtn.Likert__c.toLowerCase();

                if (likertKeyAndValuesMap.containsKey(likertKey) && likertKeyAndValuesMap.get(likertKey) != null && likertKeyAndValuesMap.get(likertKey).size() > 0) {

                    counter = 1;
                    for (string likertValue : likertKeyAndValuesMap.get(likertKey)) {

                        Answer_Option__c newAO = new Answer_Option__c();
                        newAO.Name = likertValue;
                        newAO.Order_No__c = counter;
                        newAO.Question_Template__c = qtn.Id;
                        answerOptionsList.add( newAO );
                        counter++;
                    }
                }
            }
            if (answerOptionsList != null && answerOptionsList.size() > 0) {
                insert answerOptionsList;
            }   
        }
    }
}