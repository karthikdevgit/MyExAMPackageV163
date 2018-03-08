({
    saveFile : function(param, onSuccess, onError, attachmentByParentId, cmp, helper) {
        var parentId = param.parentId;
        var action = cmp.get("c.saveFile");
        action.setParams(param);
        helper.toggleSpinner(cmp);
        action.setCallback(this, function(response) {
            var state = response.getState();
            
            if (cmp.isValid() && state === "SUCCESS") {
                var attachments = attachmentByParentId._Attachment[parentId];
                attachmentByParentId._Attachment[parentId] = response.getReturnValue();
                onSuccess(response.getReturnValue());
            }
            else if(cmp.isValid() && state === "ERROR"){
                
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
    
    uploadFileToSerever : function(param, onSuccess, onError, data, cmp, helper){
        helper.toggleSpinner(cmp);
        var assessmentId = param.parentId;
        var action = cmp.get("c.updateAttachFile");
        action.setParams(param);
        action.setCallback(this, function(response) {
            var state = response.getState();
            
            if (cmp.isValid() && state === "SUCCESS") {
                var attachmentObject = JSON.parse(response.getReturnValue());
                var attachment = attachmentObject.attachment[0];
                var objWithFieldsAndAttachment = data[assessmentId];
                
                if(objWithFieldsAndAttachment){
                    
                    if (attachment.ParentId === assessmentId) {
                        objWithFieldsAndAttachment.attachment[0] = attachment;
                        data[assessmentId] = objWithFieldsAndAttachment;
                    }
                    
                }
                onSuccess(attachment);
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
    uploadQuestionImage : function(param, onSuccess, onError, attachmentByParentId, cmp, helper){
        helper.toggleSpinner(cmp);
        var questionId = param.parentId;
        var action = cmp.get("c.upsertQuestionImage");
        action.setParams(param);
        action.setCallback(this, function(response) {
            
            var state = response.getState();
            if(state === "SUCCESS"){
                var attachment = response.getReturnValue();
                attachmentByParentId._QuestionImage[questionId] = attachment;
                onSuccess(attachment);
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
    fetchAttachment : function(param, onSuccess, onError, attachmentByParentId, cmp, helper){
        helper.toggleSpinner(cmp);
        var action = cmp.get("c.fetchAttachment");
        action.setParams(param);
        //action.setStorable();
        action.setCallback(this, function(response) {
            var state = response.getState();
            
            if (cmp.isValid() && state === "SUCCESS") {
                var attachment = response.getReturnValue();
                var parentIds = param.answerOptionsId;
                
                if(parentIds.length){
                    var k = 0;
                    for(var i = 0; i < parentIds.length; i++){
                        if(attachment[k] && attachment[k].ParentId === parentIds[i]){
                            attachmentByParentId._Attachment[parentIds[i]] = attachment[k];
                            k++;
                        }
                    }
                }else{
                    var parentId = param.QuesId;
                    attachmentByParentId._Attachment[parentId] = attachment;
                }
                
                onSuccess(attachment);
            }
            else if(cmp.isValid() && state === "ERROR"){
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
    cloneAttachment : function(parentId, onSuccess, onError, attachmentByParentId, cmp, helper){
        helper.toggleSpinner(cmp);        
        var action = cmp.get("c.fetchAttachment");
        action.setParams({
            "QuesId" : parentId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            
            if (cmp.isValid() && state === "SUCCESS") {
                var attachment = response.getReturnValue();
                attachmentByParentId._Attachment[parentId] = attachment;
                onSuccess(attachment);
            }
            else if(cmp.isValid() && state === "ERROR"){
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
        
        helper.showNotificationEvt('error', errorMsg, time);
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
    buildOffLineMsg : function(cmp, helper, time){
        var errorMsg = "No response from server or client is offline.";
        helper.showNotificationEvt("error", errorMsg, time);
    },
    toggleSpinner : function(cmp){
        var spinner_container = cmp.find("spinner_container");
        $A.util.toggleClass(spinner_container,"slds-hide");
    }
})