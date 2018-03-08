({
    upsertAnswerOption : function(param, sectionId, onSuccess, onError, cmp, helper, AnswerByQuestion){
        helper.toggleSpinner(cmp);
        
        var action = cmp.get("c.upsertAnswer");
        action.setParams(param);
        action.setCallback(this, function(response){
            var state = response.getState();
            
            if(cmp.isValid() && state === 'SUCCESS'){
                var answerOptionsWthAttachment = response.getReturnValue(); 
                var answerOptions = answerOptionsWthAttachment.AnswerOptions;
                var attachment = answerOptionsWthAttachment.AnswerOptionsWthAttachments;
                var questionId = answerOptions[0].ExAM__Question_Template__c;
                
                window.Exam.QuestionServiceComponent.upsertAnswerOption(sectionId, questionId, answerOptions); 
                window.Exam.AttachmentServiceComponent.updateAttachment(questionId, null); 
                
                if(attachment){
                    var k = 0;
                    for(var i = 0; i < answerOptions.length; i++){
                        if(attachment[k] && answerOptions[i].Id === attachment[k].ParentId){
                            window.Exam.AttachmentServiceComponent.updateAttachment(answerOptions[i].Id, attachment[k]);
                            k++;
                        }
                    }
                }
                
                AnswerByQuestion._Answer[questionId] = answerOptions;
                onSuccess(response.getReturnValue());
                helper.fireAnswerChangedEvt(questionId);
            }else if(cmp.isValid() && state === "ERROR"){
                
                if(!onError){
                    helper.buildErrorMsg(cmp, helper, response.getError(), null);
                }else{
                    onError(response.getError());
                }
                
            }else if(cmp.isValid() && state === 'INCOMPLETE'){
                helper.buildOffLineMsg(cmp, helper, null);
            }
            
            helper.toggleSpinner(cmp);
            
        });
        $A.enqueueAction(action);
    },
    
    fireAnswerChangedEvt : function(questionId){
        var changeQuestionTemp = $A.get("e.c:fireAnswerChangedEvt");
        changeQuestionTemp.setParams({
            "questionId" : questionId
        });
        changeQuestionTemp.fire();
    },
    showNotificationEvt : function(status, message, time){
        var showNotificationEvent = $A.get("e.c:notificationEvt");
        showNotificationEvent.setParams({
            "action" : status,
            "message" : message,
            "time" : time
        });
        showNotificationEvent.fire();
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
        
        helper.showNotificationEvt("error", errorMsg, time); 
    },
    buildOffLineMsg : function(cmp, helper, time){
        var errorMsg = "No response from server or client is offline.";
        helper.showNotificationEvt("error", errorMsg, time);
    },
    toggleSpinner : function(cmp){
        var spinner_container = cmp.find("spinner_container");
        $A.util.toggleClass(spinner_container, "slds-hide");
    }
})