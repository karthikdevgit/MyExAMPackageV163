({
    fetchCriteriaWthCountOfRd : function(groupId, onSuccess, onError, cmp, event, helper){
        
        var action = cmp.get("c.fetchCriteriaWthCountOfRd");
        
        action.setParams({
            "groupId" : groupId
        });
        action.setCallback(this, function(response){
            var status = response.getState();
           	
            if(status === "SUCCESS"){
                onSuccess(response.getReturnValue());
            }else if(status === "INCOMPLETE"){
                helper.buildOffLineMsg(cmp, helper);
            }else if(status === "ERROR"){
                
                if(!onError){
                    helper.buildErrorMsg(cmp, helper, response.getError());
                }else{
                    onError(response.getError());
                }
                
            }
            
            
        });
        $A.enqueueAction(action);
        
    },
    fetchTargetObjectsWthOperators : function(onSuccess, onError, cmp, event, helper) {
        helper.toggleSpinner(cmp);
        var action = cmp.get("c.fetchTargetObjectsWthOperators ");
        action.setCallback(this, function(response){
            helper.toggleSpinner(cmp);
            var status = response.getState();
            if(status === "SUCCESS"){
                onSuccess(response.getReturnValue());
            }else if(status === "INCOMPLETE"){
                helper.buildOffLineMsg(cmp, helper);
            }else if(status === "ERROR"){
                
                if(!onError){
                    helper.buildErrorMsg(cmp, helper, response.getError());
                }else{
                    onError(response.getError());
                }
                
            }
            
        });
        $A.enqueueAction(action);
    },
    fetchSelectedObjectGroup : function(sObjectName, onSuccess, onError, cmp, event, helper){
        helper.toggleSpinner(cmp);
        var action = cmp.get("c.fetchSelectedObjectGroup");
        action.setParams({
            "objectName" : sObjectName
        });
        action.setCallback(this, function(response){
            helper.toggleSpinner(cmp);
            var status = response.getState();
            if(status === "SUCCESS"){
                onSuccess(response.getReturnValue());
            }else if(status === "INCOMPLETE"){
                helper.buildOffLineMsg(cmp, helper);
            }else if(status === "ERROR"){
                
                if(!onError){
                    helper.buildErrorMsg(cmp, helper, response.getError());
                }else{
                    onError(response.getError());
                }
                
            }
            
        });
        $A.enqueueAction(action);
    },
    checkCriteriaMet : function(params, onSuccess, onError, cmp, event, helper){
        helper.toggleSpinner(cmp);
        
        var action = cmp.get("c.checkCriteriaMet");
        action.setParams(params);
        action.setCallback(this, function(response){
            helper.toggleSpinner(cmp);
            var status = response.getState();
            if(status === "SUCCESS"){
                onSuccess(response.getReturnValue());
            }else if(status === "INCOMPLETE"){
                helper.buildOffLineMsg(cmp, helper);
            }else if(status === "ERROR"){
                
                if(!onError){
                    helper.buildErrorMsg(cmp, helper, response.getError());
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
    showNotificationEvt : function(cmp, status, message){
        
        var showNotificationEvent = $A.get("e.c:notificationEvt");
        showNotificationEvent.setParams({
            "action" : status,
            "message" : message
        });
        showNotificationEvent.fire();
    },
    
    buildErrorMsg : function(cmp, helper, errors){
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
        
        helper.showNotificationEvt(cmp, "error", errorMsg);
        
    },
    buildOffLineMsg : function(cmp, helper){
        var errorMsg = "No response from server or client is offline.";
        helper.showNotificationEvt(cmp, "error", errorMsg);
    },
})