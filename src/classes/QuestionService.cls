public with sharing class QuestionService {
    public static String sObjectName = 'Question_Template__c';
    
    public static String fieldsToQuery = 'Id, Name, Single_Next_Question__c, Video_URL__c, Question_Order_No__c, Question_Label__c, Subquestion_Label__c,'+
        ' Next_Question__c, Weight_of_Answer__c, Question_Type__c, Section_Question__c, Dependent_Question__c';
    
    public static List<String> fieldSets = new List<String>{('ExAM__lightningComp_QuestionOptions_FieldSet')};
    
    //copy Question 
    public static Map<String,object> copyQuestion(String questionId, String sectionId, String direction, Decimal indexPos){
        String fields = 'Question_Order_No__c';
        
        Integer index = (Integer) indexPos;
        Integer orderno;
        Integer position;
        Map<String,object> responseMap = new Map<String,Object>();
        List<Question_Template__c> questionTemplates = getNonDependentQuestionsBySectionId(sectionId); // get QuestionTemplates(Questions by SectionId)
        
        Question_Template__c copyQuestionTemplate = getQuestion(questionId); // get Copy Question 
        copyQuestionTemplate.Id = null;  // set Copy Question Id null
         responseMap.put('withInSec', true);
        if(copyQuestionTemplate.Section_Question__c != sectionId){ // if copy Question's SectionId Not Equal destination SectionId 
            responseMap.put('withInSec', false);
            copyQuestionTemplate.Section_Question__c = sectionId; // set copy Question's SectionId destination Section ID
            if(copyQuestionTemplate.Next_Question__c != null){
                copyQuestionTemplate.Next_Question__c = null;
                fields += ', Next_Question__c';
            }else if(copyQuestionTemplate.Dependent_Question__c != null){
                copyQuestionTemplate.Dependent_Question__c = null;
                fields += ', Dependent_Question__c';
            }
             if(copyQuestionTemplate.Single_Next_Question__c != null){
                copyQuestionTemplate.Single_Next_Question__c = null;
                fields += ', Single_Next_Question__c';
            }
            fields += ', Section_Question__c';            
        }
        
        if(questionTemplates.isEmpty()){      // destination QuestionTemplates Empty
            index = 0;
            orderno = index+1;
            copyQuestionTemplate.Question_Order_No__c = orderno;
            questionTemplates.add(copyQuestionTemplate);
        }else{  // check Direction
            
            if(direction == 'After'){
                orderno = index+2;
                copyQuestionTemplate.Question_Order_No__c = orderno;
                index = index+1;
                
                if(questionTemplates.size() == index){
                    questionTemplates.add(copyQuestionTemplate); // Add copy Question in destination questionTemplates last if index and Size is Equal
                }else{
                    questionTemplates.add(index, copyQuestionTemplate);   // Add Copy Question to QuestionTemplates Position
                }
                
            }
            
            if(direction == 'Before'){
                orderno = index+1;
                copyQuestionTemplate.Question_Order_No__c = orderno;
                questionTemplates.add(index, copyQuestionTemplate); 
            }
            
        }
        
        position = orderno;
        // change orderNo From which index add Question 
        for(Integer i = position; i < questionTemplates.size(); i++){
            questionTemplates[position].Question_Order_No__c =  questionTemplates[position].Question_Order_No__c + 1;
            position++;
            orderno++;
        }
        try{
            FieldLevelSecurity.checkFieldAccessByCriteria(fields, 'create', sObjectName);
            fields = 'Question_Order_No__c';
            FieldLevelSecurity.checkFieldAccessByCriteria(fields, 'update', sObjectName);
            upsert questionTemplates;
            
        }
        catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
        
        responseMap.put('newQuestionId', questionTemplates[index].Id);
        // filter non dependent
        questionTemplates = filterGetNonDependentQuestions(questionTemplates);
        responseMap.put('updateRecords', questionTemplates);
        
        return responseMap;  
    }
    
    public static Map<String, List<Question_Template__c>> moveQuestion(String oldSectionId, String newSectionId, String direction, Decimal index, String recordId){
        String fields = 'Question_Order_No__c';
        
        Integer indexpos = (Integer)index;
        Integer removePosition;
        Integer orderno;
        List<Question_Template__c> fromQuestionTemp;
        List<Question_Template__c> toQuestionsTemp;
        Map<String, List<Question_Template__c>> oldToNewQuestion = new Map<String, List<Question_Template__c>>();
        
        Question_Template__c questionTemplate = getQuestionWthAnswerOption(recordId);
        fromQuestionTemp = getNonDependentQuestionsBySectionId(oldSectionId);
        
        
        for(Integer i = 0; i < fromQuestionTemp.size(); i++){
            
            if(fromQuestionTemp[i].Id == recordId){
                removePosition = i;
                break;
            }
            
        }
        
        
        if(newSectionId != null ){
            toQuestionsTemp = getNonDependentQuestionsBySectionId(newSectionId);
            questionTemplate.Section_Question__c = newSectionId;    
            fields += ', Section_Question__c';
            set<String> questionIds = new set<String>{questionTemplate.Id};
            List<Answer_Option__c> answerOptions = questionTemplate.Answer_Options__r;
            
            for(Answer_Option__c answerOption : answerOptions){
                if(answerOption.Dependent_Question__c != null){
                    answerOption.Dependent_Question__c = null;
                }else if(answerOption.Next_Question__c != null){
                    answerOption.Next_Question__c = null;
                }
            }
            update answerOptions;
            if(questionTemplate.Next_Question__c != null){
                questionTemplate.Next_Question__c = '';
                fields += ', Next_Question__c';
            }else if(questionTemplate.Dependent_Question__c != null){
                questionTemplate.Dependent_Question__c = '';
                fields += ', Dependent_Question__c';
            }
            if(questionTemplate.Single_Next_Question__c != null){
                questionTemplate.Single_Next_Question__c = null;
                fields += ', Single_Next_Question__c';
            }
        }else {
            toQuestionsTemp = fromQuestionTemp;
            
            if(removePosition > indexpos){
                removePosition++;
            }
            
        }
        
        
        
        if(toQuestionsTemp.isEmpty()){
            indexpos = 0;
            orderNo = indexpos+1;
            questionTemplate.Question_Order_No__c = orderno;
            toQuestionsTemp.add(questionTemplate);
        }else{
            
            if(direction == 'After'){
                orderno = indexpos+2;
                questionTemplate.Question_Order_No__c = orderno;
                
                if(toQuestionsTemp.size() == indexpos+1){
                    toQuestionsTemp.add(questionTemplate); 
                }else{
                    toQuestionsTemp.add(indexpos+1, questionTemplate); 
                }
                
            }else if(direction == 'Before'){
                orderno = indexpos+1;
                questionTemplate.Question_Order_No__c = orderno;
                toQuestionsTemp.add(indexpos, questionTemplate); 
            }
            
        }
        
        
        Integer position = orderno;
        
        for(Integer i = position; i < toQuestionsTemp.size(); i++){
            toQuestionsTemp[position].Question_Order_No__c = toQuestionsTemp[position].Question_Order_No__c + 1;
            position++;
            orderno++;
        }
        
        if(newSectionId != null){
            try{
                FieldLevelSecurity.checkFieldAccessByCriteria(fields, 'update', sObjectName);
                update toQuestionsTemp;
                // update Assessment
                String assessmentId = toQuestionsTemp[0].Section_Question__r.Questionnaire_Section__c;
                AssessmentService.updateAssessmentDueToChildUpdates(assessmentId);
            }
            catch(Exception e){
                throw new AuraHandledException(e.getMessage());
            }
            
            // filter non dependent
            toQuestionsTemp = filterGetNonDependentQuestions(toQuestionsTemp);
            oldToNewQuestion.put('toQuestionTemplate', toQuestionsTemp);
        }else {
            fromQuestionTemp = toQuestionsTemp;
            
        }
        
        
        if(!fromQuestionTemp.isEmpty()){
            String assessmentId = fromQuestionTemp[0].Section_Question__r.Questionnaire_Section__c;
            if(fromQuestionTemp.size() == 1){
                List<Question_Template__c> emptyList = new List<Question_Template__c>();
                fromQuestionTemp = emptyList;
            }else{
                fromQuestionTemp.remove(removePosition);
                orderno = removePosition; 
                
                for(Integer i = removePosition; i < fromQuestionTemp.size(); i++){
                    fromQuestionTemp[removePosition].Question_Order_No__c = fromQuestionTemp[removePosition].Question_Order_No__c != null ? fromQuestionTemp[removePosition].Question_Order_No__c - 1 : orderno;
                    removePosition++;
                    orderno++;
                }
                try{
                    FieldLevelSecurity.checkFieldAccessByCriteria(fields, 'update', sObjectName);
                    update fromQuestionTemp;
                }
                catch(Exception e){
                    throw new AuraHandledException(e.getMessage());
                }
                
                
                // filter non dependent
                fromQuestionTemp = filterGetNonDependentQuestions(fromQuestionTemp);
            }
            
            AssessmentService.updateAssessmentDueToChildUpdates(assessmentId); // update Assessment
            oldToNewQuestion.put('fromQuestionTemplate', fromQuestionTemp);
        }
        
        
        return oldToNewQuestion;
    }
    
    public static List<Question_Template__c> getQuestionsBySectionId(String sectionId, String fieldToQuery){
        try{
            String fields = ' Name, Order_No__c, Dependent_Question__c, Help_Text__c, Next_Question__c, Weight__c, Question_Template__c';
            sObjectName = 'Answer_Option__c';
            FieldLevelSecurity.checkFieldAccessByCriteria(fields, 'view', sObjectName);
            
            
            if(fieldToQuery == 'undefined'){
                fieldToQuery = 'Id, Name' ;
            }
            
            sObjectName = 'Question_Template__c';
            fieldToQuery = ExamDescribeHelper.getFieldsFromFieldSet(fieldSets, fieldToQuery, 'ExAM__Question_Template__c'); // call method for field set
            FieldLevelSecurity.checkFieldAccessByCriteria(fieldToQuery, 'view', sObjectName);
            
            // add reference in fieldToQuery
            fieldToQuery += ', Section_Question__r.Questionnaire_Section__c';
            FieldLevelSecurity.checkFieldAccessByCriteria('Questionnaire_Section__c', 'view', 'Section_Template__c');
            
            String questionQuery = 'SELECT '+fieldToQuery+',(SELECT Id,'+ fields +' FROM Answer_Options__r)' 
                +' FROM Question_Template__c WHERE Section_Question__c =\''+ sectionId+'\''
                +' ORDER BY Question_Order_No__c';
            
            System.debug('questionQuery:::'+questionQuery);
            
            List<Question_Template__c> QuestionTemplates = Database.query(questionQuery);
            return QuestionTemplates;
        }
        catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
        
        
    }
    public static List<Question_Template__c> filterGetNonDependentQuestions(List<Question_Template__c> Questions){
        Map<Id,Question_Template__c> questionIdWthRecord = new Map<Id,Question_Template__c>(Questions);
        Set<Id> questionIds = questionIdWthRecord.keySet();
        Set<String> questionSet = new Set<String>();
        List<Answer_Option__c> answerOptions;
        try{
            String fields = 'Dependent_Question__c, Question_Template__c, Next_Question__c';
            sObjectName = 'Answer_Option__c';
            FieldLevelSecurity.checkFieldAccessByCriteria(fields, 'view', sObjectName);
            fields = 'Name';
            sObjectName = 'Question_Template__c';
            FieldLevelSecurity.checkFieldAccessByCriteria(fields, 'view', sObjectName);
            answerOptions = [SELECT Dependent_Question__c, Dependent_Question__r.Name, Question_Template__c, Next_Question__c, Next_Question__r.Name  FROM Answer_Option__c WHERE Question_Template__c IN :questionIds];
        }
        catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
        
        Set<Id> QuestionHasAnswers = new Set<Id>();
        
        for(Answer_Option__c answer : answerOptions){
            QuestionHasAnswers.add(answer.Question_Template__c);
            if(answer.Next_Question__c != NULL){
                questionSet.add(answer.Next_Question__r.Name);
            }else if(answer.Dependent_Question__c != NULL){
                questionSet.add(answer.Dependent_Question__r.Name);
            }
            
        }
        List<Question_Template__c> questionTemplatesWthoutAnswerOptions = new List<Question_Template__c>();
        
        for(Question_Template__c question : questionIdWthRecord.values()){
            if(!QuestionHasAnswers.contains(question.Id)){
                questionTemplatesWthoutAnswerOptions.add(question);
            }
        }
        
        List<Question_Template__c> questionTemplates = new List<Question_Template__c>();
        Set<Id> singleNextQuestionIds = new Set<Id>(); // collect Id of single Next Question Ids
        for(Question_Template__c question : questionTemplatesWthoutAnswerOptions){
            
            if(question.Next_Question__c != NULL){
                
                List<String> nextQuestions = question.Next_Question__c.split('~');
                questionSet.addAll(nextQuestions);
                
            }else if(question.Dependent_Question__c != NULL){
                
                List<String> dependentQuestions = question.Dependent_Question__c.split('~');
                questionSet.addAll(dependentQuestions);
            }else if(question.Single_Next_Question__c != null){
                singleNextQuestionIds.add(question.Single_Next_Question__c);
            }
            
        }
        
        for(Question_Template__c question : Questions){
            
            if(!questionSet.contains(question.Name) && !singleNextQuestionIds.contains(question.Id)){
                
                questionTemplates.add(question);  
            }
            
        }
        
        
        return questionTemplates;
        
        
    }
    
    public static List<Question_Template__c> getNonDependentQuestionsBySectionId(String sectionId){
        List<Question_Template__c> Questions = getQuestionsBySectionId(sectionId, fieldsToQuery);
        
        return Questions;
    } 
    
    
    public static Question_Template__c getQuestion(String questionId){
        try{
            String fields = 'Name, Question_Order_No__c, Video_URL__c, Question_Label__c, Subquestion_Label__c,'+
                'Next_Question__c, Dependent_Question__c, Question_Type__c, Section_Question__c, Weight_of_Answer__c';
            
            fields = ExamDescribeHelper.getFieldsFromFieldSet(fieldSets, fields, 'ExAM__Question_Template__c'); // call method for field set
            FieldLevelSecurity.checkFieldAccessByCriteria(fields, 'view', sObjectName);
            // add reference in fieldToQuery
            fields += ', Section_Question__r.Questionnaire_Section__c';
            FieldLevelSecurity.checkFieldAccessByCriteria('Questionnaire_Section__c', 'view', 'Section_Template__c');
            
            String questionQuery = 'SELECT '+fields+ 
                +' FROM Question_Template__c WHERE Id =\''+ questionId+'\'';
            
            List<Question_Template__c> questionTemplates = Database.query(questionQuery);
            
            return questionTemplates[0];
        }
        catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
        
    }
    
    public static Question_Template__c getQuestionWthAnswerOption(String questionId){
        try{
            String fields = 'Name, Question_Order_No__c, Video_URL__c, Hotspot_Image_Properties__c, Question_Label__c, Subquestion_Label__c,'+
                'Next_Question__c, Dependent_Question__c, Question_Type__c, Section_Question__c, Weight_of_Answer__c';
            
            fields = ExamDescribeHelper.getFieldsFromFieldSet(fieldSets, fields, 'ExAM__Question_Template__c'); // call method for field set 
            FieldLevelSecurity.checkFieldAccessByCriteria(fields, 'view', sObjectName);
            
            String innerQuery = 'SELECT Id,';
            String answerOptionsFields = ' Name, Dependent_Question__c, Order_No__c, Weight__c, Question_Template__c, Next_Question__c, Help_Text__c';
            innerQuery += answerOptionsFields + ' FROM Answer_Options__r';
             // add reference in fieldToQuery
            fields += ', Section_Question__r.Questionnaire_Section__c';
            FieldLevelSecurity.checkFieldAccessByCriteria('Questionnaire_Section__c', 'view', 'Section_Template__c');
            
            String questionQuery = 'SELECT '+ fields + ', (' + innerQuery + ')'
                +' FROM Question_Template__c WHERE Id =\''+ questionId+'\'';
            
            //List<Question_Template__c> QuestionTemplates = Database.query(questionQuery);
            
            List<Question_Template__c> questionTemplates = Database.query(questionQuery);
            
            return questionTemplates[0];
        }
        catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
        
    }
    
    public static List<Question_Template__c> deleteQuestion(String questionId){
        String assessmentId = '';
        Question_Template__c question = getQuestion(questionId);
        List<Question_Template__c> questionTemplates = getNonDependentQuestionsBySectionId(question.Section_Question__c);
        
        Integer order = (Integer)question.Question_Order_No__c;
        Integer position = order-1;
        Integer sizeOfQuestionTemp = questionTemplates.size();
        for(Integer i = position; i < sizeOfQuestionTemp; i++){
            
            if(questionTemplates[position].Id == questionId){
                
                questionTemplates.remove(position);
            }else{
                
                questionTemplates[position].Question_Order_No__c = order;
                order++;
                position++;
            }
            
        }
        try{
            FieldLevelSecurity.checkObjectAccessByDelete(sObjectName);
            assessmentId = question.Section_Question__r.Questionnaire_Section__c; // get assessment Id
            delete question; 
        }
        catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
        
        if(!questionTemplates.isEmpty()){
            
            try{
                String fields = 'Question_Order_No__c';
                FieldLevelSecurity.checkFieldAccessByCriteria(fields, 'update', sObjectName);
                update questionTemplates;
            }
            catch(Exception e){
                throw new AuraHandledException(e.getMessage());
            }
            
            // filter non dependent
            questionTemplates = filterGetNonDependentQuestions(questionTemplates);
        }
        AssessmentService.updateAssessmentDueToChildUpdates(assessmentId); // update Assessment
        return questionTemplates;
    }
    
    public static List<Question_Template__c> createQuestion(Question_Template__c questionTemplate, Integer orderNo){ // has to check FLS
        Integer position = orderNo;
        orderNo++;
        String sectionId = questionTemplate.Section_Question__c;
        List<Question_Template__c> questionTemplates = getNonDependentQuestionsBySectionId(sectionId);
        
        if(questionTemplates.size() == position){
            questionTemplates.add(questionTemplate);
        }else{
            questionTemplates.add(position,questionTemplate);
        }
        
        
        for(Integer i = position; i < questionTemplates.size(); i++){
            questionTemplates[position].Question_Order_No__c = orderNo;
            position++;
            orderNo++;
        }
        
        upsert questionTemplates;
        
        // filter non dependent
        //questionTemplates = filterGetNonDependentQuestions(questionTemplates);
        return questionTemplates;
    }
    
    
    
    public static Map<String, object> cloneQuestionsBySectionId(String newSectionId, String sectionId){
        
        Map<String,Question_Template__c> questionOldNameToNewQuestion = new Map<String,Question_Template__c>();
        Map<String,String> questionOldIdWthNewId = new Map<String,String>();
        Map<Id, Question_Template__c> updatableCloneQuestion;
        Map<String, object> infoQuesIdWithQues = new Map<String, object>();
        Set<String> questionOldIds = new Set<String>();
        String fields = ExamDescribeHelper.getFieldsOfSobject('Question_Template__c'); 
        Map<String,Question_Template__c> IdWthOldQuestion = new Map<String,Question_Template__c>(getQuestionsBySectionId(sectionId,fields));
        List<Question_Template__c> oldQuestions = IdWthOldQuestion.values();
        
        questionOldIds.addAll(IdWthOldQuestion.keySet());
        Set<Id> questionHasAnswer = new Set<Id>();
        List<Answer_Option__c> answerOptions = AnswerOptionService.getAnswerOptionsByQuesIds(questionOldIds); 
        
        Set<String> questionIdByAnswerOptions = new Set<String>();
        List<Question_Template__c> oldQuestionsByAnswer;
        List<Question_Template__c> Questions;
        
        for(Answer_Option__c answerOption : answerOptions){
            questionHasAnswer.add(answerOption.Question_Template__c);
            if(answerOption.Dependent_Question__c != null && !questionOldIds.contains(answerOption.Dependent_Question__c)){
                questionIdByAnswerOptions.add(answerOption.Dependent_Question__c);
            }else if(answerOption.Next_Question__c != null && !questionOldIds.contains(answerOption.Next_Question__c)){
                questionIdByAnswerOptions.add(answerOption.Next_Question__c); 
            }
            
        }
        if(!questionIdByAnswerOptions.isEmpty()){
            try{
                sObjectName = 'Question_Template__c';
                FieldLevelSecurity.checkObjectAccessByView(sObjectName);
                //FieldLevelSecurity.checkFieldAccessByCriteria(fields, 'view', sObjectName);
                String questionQuery = 'SELECT '+fields+' FROM Question_Template__c WHERE Id IN :questionIdByAnswerOptions'
                    +' ORDER BY Question_Order_No__c';
                
                Questions = Database.query(questionQuery);
            }
            catch(Exception e){
                throw new AuraHandledException(e.getMessage());
            }
            
            
            questionOldIds.addAll(questionIdByAnswerOptions);
            oldQuestions.addAll(Questions);
        }
        
        
        Set<Id> questionWthOutAnswers = new Set<Id>();
        for(Integer i = 0; i < oldQuestions.size(); i++){
            if(!questionHasAnswer.contains(oldQuestions[i].Id)){
                questionWthOutAnswers.add(oldQuestions[i].Id);
            }
            
            oldQuestions[i].Section_Question__c = newSectionId;
            
            oldQuestions[i].Id = null;
            questionOldNameToNewQuestion.put(oldQuestions[i].Name,oldQuestions[i]);
        }
        
        if(!questionOldNameToNewQuestion.isEmpty()){
            try{
                FieldLevelSecurity.checkObjectAccessByCreate('Question_Template__c');
                insert questionOldNameToNewQuestion.values(); 
            }
            catch(Exception e){
                throw new AuraHandledException(e.getMessage());
            }
            
        }        
        List<Question_Template__c> newQuestions = questionOldNameToNewQuestion.values();
        
        List<String> questionOldIdsList = new List<String>(questionOldIds);
        Map<String,String> questionOldIdWthNewIdWthOutAnswer = new Map<String,String>();
        for(Integer i = 0; i < questionOldIdsList.size(); i++){
            
            if(questionWthOutAnswers.contains(questionOldIdsList[i])){
                questionOldIdWthNewIdWthOutAnswer.put(questionOldIdsList[i], newQuestions[i].Id);
            }
            
            questionOldIdWthNewId.put(questionOldIdsList[i], newQuestions[i].Id);
        }
        
        List<Question_Template__c> QuestionTemplates = getQuestionsBySectionId(newSectionId,fields);
        updatableCloneQuestion = new Map<Id, Question_Template__c>(QuestionTemplates);
        
        updatableCloneQuestion = updateDecisionTreeQuestion(questionOldNameToNewQuestion,updatableCloneQuestion,questionOldIdWthNewId); 
        List<Question_Template__c> cloneQuestionTemplates = updatableCloneQuestion.values();
        infoQuesIdWithQues.put('questionId', questionOldIdWthNewId);
        infoQuesIdWithQues.put('questionTemp',cloneQuestionTemplates);
        infoQuesIdWithQues.put('AttachmentCopyByQuestionId',questionOldIdWthNewIdWthOutAnswer);
        
        
        return infoQuesIdWithQues;
    }
    
    public static Map<Id, Question_Template__c> updateDecisionTreeQuestion(Map<String,Question_Template__c> questionOldNameToNewQuestion, Map<Id, Question_Template__c> updatableCloneQuestion, Map<String, String> questionOldIdWthNewId){
        
        for(String questionId : updatableCloneQuestion.keySet()){
            
            Question_Template__c question = updatableCloneQuestion.get(questionId);
            
            if(question.Next_Question__c != null && question.Next_Question__c != '' ) {
                string newNextQuestion = '';
                for (string oldQName : question.Next_Question__c.split('~')) {
                    if (questionOldNameToNewQuestion.containsKey(oldQName)) {
                        if (newNextQuestion != '') {
                            newNextQuestion += '~'+updatableCloneQuestion.get(questionOldNameToNewQuestion.get(oldQName).Id).Name;
                        } else {
                            newNextQuestion += updatableCloneQuestion.get(questionOldNameToNewQuestion.get(oldQName).Id).Name;
                        } 
                    }
                }
                updatableCloneQuestion.get(questionId).Next_Question__c = newNextQuestion;
                
            }else if(question.Dependent_Question__c != null && question.Dependent_Question__c != '' ) {
                string newDependentQuestion = '';
                for (string oldQName : question.Dependent_Question__c.split('~')) {
                    if (questionOldNameToNewQuestion.containsKey(oldQName)) {
                        if (newDependentQuestion != '') {
                            newDependentQuestion += '~'+updatableCloneQuestion.get(questionOldNameToNewQuestion.get(oldQName).Id).Name;
                        } else {
                            newDependentQuestion += updatableCloneQuestion.get(questionOldNameToNewQuestion.get(oldQName).Id).Name;
                        } 
                    }
                }
                updatableCloneQuestion.get(questionId).Dependent_Question__c = newDependentQuestion;
                
            }
            if(question.Single_Next_Question__c != null){
                updatableCloneQuestion.get(questionId).Single_Next_Question__c = questionOldIdWthNewId.get(question.Single_Next_Question__c);
            }
            
        }
        try{
            String fields = 'Next_Question__c, Dependent_Question__c';
            FieldLevelSecurity.checkFieldAccessByCriteria(fields, 'update', sObjectName);
            update updatableCloneQuestion.values();
        }
        catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
        
        return updatableCloneQuestion;
    }
    
    public static List<Question_Template__c> getQuestionsWthOutAnswers(String sectionId){
        try{
            String fields = 'Name, Question_Label__c, Question_Order_No__c';
            FieldLevelSecurity.checkFieldAccessByCriteria(fields, 'view', 'Question_Template__c');
            List<Question_Template__c> questions = [SELECT Id, Name, Question_Label__c, Question_Order_No__c FROM Question_Template__c 
                                                    WHERE Section_Question__c = :sectionId ORDER BY Question_Order_No__c];
            
            return questions;	
        }
        catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
}