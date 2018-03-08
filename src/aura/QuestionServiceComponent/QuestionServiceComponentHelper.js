({
    moveQuestion : function(param, onSuccess, onError, questionBySection, cmp, helper){
        helper.toggleSpinner(cmp);
        var action = cmp.get("c.moveQuestionToSection");
        action.setParams(param);
        action.setCallback(this, function(response) {
            var state = response.getState();
            
            if (cmp.isValid() && state === "SUCCESS") {
                var oldWithNewQuestionTemplates = response.getReturnValue();
                var fromQuestionTemplate = oldWithNewQuestionTemplates.fromQuestionTemplate;
                var toQuestionTemplate = oldWithNewQuestionTemplates.toQuestionTemplate;
                questionBySection._NonDependentQuestions[param.oldSectionId] = fromQuestionTemplate;
                
                
                if(param.newSectionId){
                    var toQuestions = questionBySection._Questions[param.newSectionId] || [];
                    for(var i = 0; i < toQuestionTemplate.length; i++){
                        if(toQuestionTemplate[i].Id == param.recordId){
                            if(toQuestions.length){
                                toQuestions.push(toQuestionTemplate[i]);
                                questionBySection._Questions[param.newSectionId] = toQuestions;
                            }
                            var answerOption = toQuestionTemplate[i].ExAM__Answer_Options__r;
                            if(answerOption){
                                window.Exam.AnswerServiceComponent.storeAnswersByQuestion(param.recordId, answerOption);                                
                            }
                            break;
                        }
                    }
                    
                    questionBySection._NonDependentQuestions[param.newSectionId] = toQuestionTemplate;
                }
                onSuccess();
                helper.fireQuestionChangedEvt(param.oldSectionId);
            }else if(cmp.isValid() && state === "ERROR"){
                
                if(!onError){
                    helper.buildErrorMsg(cmp, helper, response.getError(), null);
                    
                }else{
                    onError(response.getError());
                }
                
            }else if(cmp.isValid() && state === "INCOMPLETE"){
                helper.buildOffLineMsg(cmp, helper, null);
            }
            
            helper.toggleSpinner(cmp);
            
        });
        $A.enqueueAction(action);
    },
    
    copyQuestion : function(param, position, onSuccess, onError, questionBySection, cmp, helper){
        helper.toggleSpinner(cmp);
        var direction = param.direction;
        var index = position;
        var action = cmp.get("c.copyQuestionTemplate");
        action.setParams(param);
        action.setCallback(this, function(response) {
            helper.toggleSpinner(cmp);
            var state = response.getState();
            
            if (cmp.isValid() && state === "SUCCESS") {
                var copyQuestionWthAnswers = response.getReturnValue();
                var questionTemplates = copyQuestionWthAnswers.copyQuestion;
                
                if(direction === 'After'){
                    index++;
                }
                
                if(copyQuestionWthAnswers.copyAnswerOptions){
                    window.Exam.AnswerServiceComponent.storeAnswersByQuestion(questionTemplates[index].Id, copyQuestionWthAnswers.copyAnswerOptions);
                }
                if(copyQuestionWthAnswers.questionImage){
                    window.Exam.AttachmentServiceComponent.storeQuestionImage(questionTemplates[index].Id, copyQuestionWthAnswers.questionImage);
                }
                
                //questionTemplates[index].ExAM__Answer_Options__r = copyQuestionWthAnswers.copyAnswerOptions;
                questionBySection._NonDependentQuestions[param.sectionId] = questionTemplates;
                
                helper.fireQuestionChangedEvt(param.sectionId);
                onSuccess();
            }else if(cmp.isValid() && state === "ERROR"){
                
                if(!onError){
                    helper.buildErrorMsg(cmp, helper, response.getError(), null);
                }else{
                    onError(response.getError());
                }
                
            }else if(cmp.isValid() && state === "INCOMPLETE"){
                helper.buildOffLineMsg(cmp, helper, null);
            }
            
                        
        });
        $A.enqueueAction(action);
    },
    updateQuestion : function(QuestionTemplate, questionBySection, cmp){
        
        var recordId = QuestionTemplate.Id;
        var sectionId = QuestionTemplate.ExAM__Section_Question__c;
        var questionTemplates = questionBySection._NonDependentQuestions[sectionId];
        
        for(var i = 0; i < questionTemplates.length; i++){
            
            if(questionTemplates[i].Id === recordId){
                questionTemplates[i] = QuestionTemplate;
            }
            
        }
        questionBySection._NonDependentQuestions[sectionId] = questionTemplates;
    },
    updateRecord : function(param, sectionId, onSuccess, onError, questionBySection, cmp, helper){
        helper.toggleSpinner(cmp);
        var action = cmp.get("c.updateRecord");
        action.setParams(param);
        action.setCallback(this, function(response) {
            var state = response.getState();
            
            if (cmp.isValid() && state === "SUCCESS") {
                var question = response.getReturnValue();
                
                if(param.fieldName == "ExAM__Question_Label__c"){
                    var questions = questionBySection._Questions[sectionId] || [];
                    
                    if(questions.length){
                        for(var i = 0; i < questions.length; i++){
                            if(question.Id == questions[i].Id){
                                questions[i].ExAM__Question_Label__c = question.ExAM__Question_Label__c;
                                questionBySection._Questions[sectionId] = questions;
                                break;
                            }
                        }
                    }
                    
                }
                
                onSuccess(question);
            }else if(cmp.isValid() && state === "ERROR"){
                
                if(!onError){
                    helper.buildErrorMsg(cmp, helper, response.getError(), null);
                }else{
                    onError(response.getError());
                }
                
            }else if(cmp.isValid() && state === "INCOMPLETE"){
                helper.buildOffLineMsg(cmp, helper, null);
            }
            helper.toggleSpinner(cmp);
        });
        $A.enqueueAction(action);
        
    },
    copyQuestionWithImage : function(param, position, onSuccess, onError, questionBySection, cmp, helper){
        helper.toggleSpinner(cmp);
        var sectionId = param.sectionId;
        var direction = param.direction;
        var index = position;
        var action = cmp.get("c.copyQuestionWithAttachment");
        action.setParams(param);
        action.setCallback(this, function(response) {
            var state = response.getState();
            
            
            if (cmp.isValid() && state === "SUCCESS") {                
                var copyQuestionWithAttachment = response.getReturnValue();
                var questionTemplates = copyQuestionWithAttachment.copyQuestion;
                
                if(direction === 'After'){
                    index++;
                }
                
                //questionTemplates[index].ExAM__Answer_Options__r = copyQuestionWithAttachment.copyAnswerOptions;
                questionBySection._NonDependentQuestions[param.sectionId] = questionTemplates;
                var Attachment = copyQuestionWithAttachment.copyAttachment;
                if(copyQuestionWithAttachment.copyAnswerOptions){
                    window.Exam.AnswerServiceComponent.storeAnswersByQuestion(questionTemplates[index].Id, copyQuestionWithAttachment.copyAnswerOptions);
                    for(var i = 0; i < Attachment.length; i++){
                        var parentId = Attachment.ParentId;
                        window.Exam.AttachmentServiceComponent.updateAttachment(parentId, Attachment[i]);
                    }
                }else{
                    
                    window.Exam.AttachmentServiceComponent.updateAttachment(parentId, Attachment);
                }
                if(copyQuestionWithAttachment.questionImage){
                    window.Exam.AttachmentServiceComponent.storeQuestionImage(questionTemplates[index].Id, copyQuestionWithAttachment.questionImage);
                }
                
                helper.fireQuestionChangedEvt(param.sectionId);
                onSuccess();
            }else if(cmp.isValid() && state === "ERROR"){
                
                if(!onError){
                    helper.buildErrorMsg(cmp, helper, response.getError(), null);
                }else{
                    onError(response.getError());
                }
                
            }else if(cmp.isValid() && state === "INCOMPLETE"){
                helper.buildOffLineMsg(cmp, helper, null);
            }
            helper.toggleSpinner(cmp);
        });
        $A.enqueueAction(action);
        
    },
    deleteQuestion : function(Question, onSuccess, onError, questionBySection, cmp, helper){
        helper.toggleSpinner(cmp);
        var sectionId = Question.ExAM__Section_Question__c;
        var action = cmp.get("c.deleteQuestionTemplate");
        action.setParams({
            "questionId" : Question.Id
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            
            
            if (cmp.isValid() && state === "SUCCESS") {
                questionBySection._NonDependentQuestions[sectionId] = response.getReturnValue();
                
                var changeQuestionsTemp = $A.get("e.c:fireSectionChangedEvt");
                changeQuestionsTemp.setParams({
                    "sectionId" : sectionId
                });
                changeQuestionsTemp.fire();
                
                onSuccess(response.getReturnValue());
            }else if(cmp.isValid() && state === "ERROR"){
                
                if(!onError){
                    helper.buildErrorMsg(cmp, helper, response.getError(), null);
                }else{
                    onError(response.getError());
                }
                
            }else if(cmp.isValid() && state === "INCOMPLETE"){
                helper.buildOffLineMsg(cmp, helper, null);
            }
            helper.toggleSpinner(cmp);
        });
        $A.enqueueAction(action);
        
    },
    createNewQuestion : function(param, position, hasDependent, onSuccess, onError, questionBySection, cmp, helper){
        
        helper.toggleSpinner(cmp);
        var sectionId = param.QuestionTemplate.ExAM__Section_Question__c;
        //var position = param.orderNo;
        var action = cmp.get("c.createQuestionWthAnswer");
        action.setParams(param);
        action.setCallback(this, function(response) {
            var state = response.getState();
            helper.toggleSpinner(cmp);
            if (cmp.isValid() && state === "SUCCESS") {
                var QuestionWthAnswer = response.getReturnValue();
                var questionTemplates = QuestionWthAnswer.questions;
                var questionOptions = QuestionWthAnswer.answers;
                var questionId = QuestionWthAnswer.newQuestionId[0];
                console.log("length:::", questionTemplates.length); 
                console.log("length:::", questionId); 
                for(var i = 0; i < questionTemplates.length; i++){
                    if(questionId == questionTemplates[i].Id){
                        position = i;
                        break;
                    }
                }
                console.log("position:::", position); 
                console.log("questionOptions:::",questionOptions.length);
                if(questionOptions.length){
                    
                    console.log("Id:::",questionTemplates, position,questionTemplates[position]);
                    window.Exam.AnswerServiceComponent.storeAnswersByQuestion(questionTemplates[position].Id, questionOptions);
                }
                
                questionBySection._NonDependentQuestions[sectionId] = questionTemplates;
                console.log("question:::", questionTemplates[position]); 
                onSuccess(questionTemplates[position]);
            }else if(cmp.isValid() && state === "ERROR"){
                
                if(!onError){
                    helper.buildErrorMsg(cmp, helper, response.getError(), null);
                }else{
                    onError(response.getError());
                }
                
            }else if(cmp.isValid() && state === "INCOMPLETE"){
                helper.buildOffLineMsg(cmp, helper, null);
            }
            
        });
        
        $A.enqueueAction(action);
        
    },
    showNotificationEvt : function(cmp, status, message, time){
        var showNotificationEvent = $A.get("e.c:notificationEvt");
        showNotificationEvent.setParams({
            "action" : status,
            "message" : message,
            "time" : time
        });
        showNotificationEvent.fire();
    },
    fireQuestionChangedEvt : function(sectionId, dependent){
        var changeSectionTemp = $A.get("e.c:fireSectionChangedEvt");
        changeSectionTemp.setParams({
            "sectionId" : sectionId,
            "dependent" : dependent
        });
        changeSectionTemp.fire();
    },
    getFieldSet : function(param, onSuccess, onError, cmp, helper){
        helper.toggleSpinner(cmp);
        var action = cmp.get("c.getFieldSet");
        action.setParams(param);
        action.setCallback(this, function(response) {
            var state = response.getState();
            
            if (cmp.isValid() && state === "SUCCESS") {
                onSuccess(JSON.parse(response.getReturnValue()));
            } else if(cmp.isValid() && state === "ERROR") {
                
                if(!onError){
                    helper.buildErrorMsg(cmp, helper, response.getError(), null);
                }else{
                    onError(response.getError());
                }
                
            }else if(cmp.isValid() && state === "INCOMPLETE"){
                helper.buildOffLineMsg(cmp, helper, null);
            }
            helper.toggleSpinner(cmp);
        });
        $A.enqueueAction(action);
        
    },
    upsertAnswerOption : function(sectionId, questionId, answerOptions, questionBySection, cmp, helper){
        
        var questionTemplates = questionBySection._NonDependentQuestions[sectionId];
        for(var i = 0; i < questionTemplates.length; i++){
            if(questionTemplates[i].Id === questionId){
                questionTemplates[i].ExAM__Answer_Options__r = answerOptions;
                break;
            }
        }
        
        questionBySection._NonDependentQuestions[sectionId] = questionTemplates;
        
    },
    fetchQuestionTemplates : function(param, onSuccess, onError, questionBySection, cmp, helper){
        
        helper.toggleSpinner(cmp);
        var action = cmp.get("c.fetchQuesTemplateWthQuestionFieldSetValue");
        action.setParams(param);
        //action.setStorable();
        action.setCallback(this, function(response) {
            var state = response.getState();
            
            if (cmp.isValid() && state === "SUCCESS") {
                var ObjContainFields = JSON.parse(response.getReturnValue());
                var questionTemplates = ObjContainFields.sobject;
                var attachments = ObjContainFields.attachment;
                
                var attachmentsLength = attachments.length;
                
                for(var i = 0; i < questionTemplates.length; i++){
                    var answerOptions = questionTemplates[i].ExAM__Answer_Options__r;
                    
                    if(answerOptions){
                        window.Exam.AnswerServiceComponent.storeAnswersByQuestion(questionTemplates[i].Id, answerOptions.records);
                    }
                    
                    for(var j = 0; j < attachmentsLength; j++){                        
                        if(attachments[j].ParentId == questionTemplates[i].Id){
                            window.Exam.AttachmentServiceComponent.storeQuestionImage(questionTemplates[i].Id, attachments[j]);
                            break;
                        }
                    }
                }
                
                questionBySection._NonDependentQuestions[param.sObjectId] = questionTemplates;
                
                if(ObjContainFields.fields){
                    questionBySection._Fields = ObjContainFields.fields;
                }
                
                onSuccess(questionTemplates);
                
            } else if(cmp.isValid() && state === "ERROR"){
                
                if(!onError){
                    helper.buildErrorMsg(cmp, helper, response.getError(), null);
                }else{
                    onError(response.getError());
                }
                
            }else if(cmp.isValid() && state === "INCOMPLETE"){
                helper.buildOffLineMsg(cmp, helper, null);
            }
            helper.toggleSpinner(cmp);
        });
        $A.enqueueAction(action);
    },
    buildErrorMsg : function(cmp, helper, errors, time){
        
        var errorMsg = "";
        
        if(errors[0] && errors[0].message){  // To show other type of exceptions
            errorMsg = errors[0].message;
        }else if(errors[0] && errors[0].pageErrors.length) {  // To show DML exceptions
            errorMsg = errors[0].pageErrors[0].message; 
        }else if(errors[0] && errors[0].fieldErrors){  // To show field exceptions
            var fields = Object.keys(errors[0].fieldErrors);
            var field = fields[0];
            errorMsg = errors[0].fieldErrors[field];
            errorMsg = errorMsg[0].message;
        }else if(errors[0] && errors[0].duplicateResults.length){ // To show duplicateResults exceptions
            errorMsg = errors[0].duplicateResults[0].message;
        }else{
            errorMsg = "Unknown errors";
        }
        
        helper.showNotificationEvt(cmp, 'error', errorMsg, time);
    },
    buildOffLineMsg : function(cmp, helper, time){
        var errorMsg = "No response from server or client is offline.";
        helper.showNotificationEvt(cmp, "error", errorMsg, time);
    },
    toggleSpinner : function(cmp){
        var spinner_container = cmp.find("spinner_container");
        $A.util.toggleClass(spinner_container, "slds-hide");
    },
    getQuestionsBySectionId : function(sectionId, questionId, onSuccess, questionBySection, cmp, helper){
        helper.toggleSpinner(cmp);
        var action = cmp.get("c.getQuestions");
        action.setParams({
            "sectionId" : sectionId
        });
        action.setCallback(this, function(response){
           var status = response.getState();
            helper.toggleSpinner(cmp);
            if(status === "SUCCESS"){
                var questions = response.getReturnValue();
                questionBySection._Questions[sectionId] = JSON.parse(JSON.stringify(questions));
                
                if(questionId){
                    helper.getQuestionsWthOutConetxtQuestion(questions, questionId);    
                }
                
                onSuccess(questions);
            }else if(status === "ERROR"){
                helper.buildErrorMsg(cmp, helper, response.getError(), null);
            }else if(status === "INCOMPLETE"){
                helper.buildOffLineMsg(cmp, helper, null);
            }
        });
        $A.enqueueAction(action);
        
    },
    getQuestionsWthOutConetxtQuestion : function(questions, questionId){
        for(var i = 0; i < questions.length; i++){
            if(questions[i].Id == questionId){
                questions.splice(i, 1);
                break;
            }
        }
    },
    getQuestionsByChangeQuestionsTemp : function(sectionId, onSuccess, onError, questionBySection, cmp, helper){
        helper.toggleSpinner(cmp);
        var action = cmp.get("c.getQuestions");
        action.setParams({
            "sectionId" : sectionId
        });
        action.setCallback(this, function(response){
            var status = response.getState();
            helper.toggleSpinner(cmp);
            if(status === "SUCCESS"){
                var questions = response.getReturnValue();
                questionBySection._Questions[sectionId] = JSON.parse(JSON.stringify(questions));
                onSuccess();
            }else if(status === "ERROR"){
                if(!onError){
                    helper.buildErrorMsg(cmp, helper, response.getError(), null);
                }else{
                    onError(response.getError());
                }
                
            }else if(status === "INCOMPLETE"){
                helper.buildOffLineMsg(cmp, helper, null);
            }
        });
        $A.enqueueAction(action);
    },
    getdependencyQuestionLabel : function(dependencyQuestionsName, onSuccess, onError, cmp, helper){
        helper.toggleSpinner(cmp);
        
        var action = cmp.get("c.getdependencyQuestionsLabel");
        action.setParams({
            "dependencyQuestions" : dependencyQuestionsName
        });
        action.setCallback(this, function(response){
            helper.toggleSpinner(cmp);
            var status = response.getState();
            if(status === "SUCCESS"){
                onSuccess(response.getReturnValue());
            }else if(status === "ERROR"){
                
                if(!onError){
                    helper.buildErrorMsg(cmp, helper, response.getError(), null);
                }else{
                    onError(response.getError());
                }
                
            }else if(status === "INCOMPLETE"){
                helper.buildOffLineMsg(cmp, helper, null);
            }
        });
        $A.enqueueAction(action);
    }
    
})