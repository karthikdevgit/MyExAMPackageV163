({
	fetchEmailTemplates : function(onSuccess, onError, cmp, event, helper) {
        helper.toggleSpinner(cmp);
        var action = cmp.get("c.fetchEmailTemplates");
        action.setCallback(this, function(response){
            var status = response.getState();
            helper.toggleSpinner(cmp);
            if(status === "SUCCESS"){
                onSuccess(response.getReturnValue());
            } else if(status === "ERROR"){ 
            	if(!onError){
                    helper.buildErrorMsg(cmp, helper, response.getError(), null);
                }else{
                    onError(response.getError());
                }
            }
        });
        $A.enqueueAction(action);
		
	},
    getDailyEmailLimit : function(onSuccess, onError, cmp, event, helper){
        
        helper.toggleSpinner(cmp);
        var action = cmp.get("c.getDailyEmailLimit");
        action.setCallback(this, function(response){
            
            var status = response.getState();
            helper.toggleSpinner(cmp);
            if(status === "SUCCESS"){
                onSuccess(response.getReturnValue());
            } else if(status === "ERROR"){ 
            	if(!onError){
                    helper.buildErrorMsg(cmp, helper, response.getError(), null);
                }else{
                    onError(response.getError());
                }
            }
        });
        $A.enqueueAction(action);
        
    },
    toggleSpinner : function(cmp){
        var spinner_container = cmp.find("spinner_container");
        $A.util.toggleClass(spinner_container, "slds-hide");
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
        }
        
        helper.showNotificationEvt(cmp, 'error', errorMsg, time);
    },
    showNotificationEvt : function(cmp, status, message){
        
        var showNotificationEvent = $A.get("e.c:notificationEvt");
        showNotificationEvent.setParams({
            "action" : status,
            "message" : message
        });
        showNotificationEvent.fire();
    }
})