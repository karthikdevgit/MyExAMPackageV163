({
    getDistributionsWthFieldSet : function(param, onSuccess, onError, cmp, event, helper, data){
        helper.toggleSpinner(cmp);
        var action = cmp.get("c.getDistributionsWthFieldSet");
        action.setParams(param);
        action.setCallback(this, function(response){
            helper.toggleSpinner(cmp);
            var status = response.getState();
            
            if(status === "SUCCESS"){
                var distributionsObjDetails = response.getReturnValue();
                data["fieldset"] = distributionsObjDetails.fieldSet;
                onSuccess(distributionsObjDetails.distributions);
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
    createDistributionWthPALink : function(param, onSuccess, onError, cmp, event, helper){
        helper.toggleSpinner(cmp);
        
        var action = cmp.get("c.createDistributionWthPALink");
        action.setParams(param);
        action.setCallback(this, function(response){
            helper.toggleSpinner(cmp);
            var status = response.getState();
            if(status === "SUCCESS"){
                helper.showNotificationEvt(cmp, "success", "Distribution Created Successfully!");
                onSuccess();
            }else if(status === "INCOMPLETE"){
                helper.buildOffLineMsg(cmp, helper);
            }else if(status === "ERROR"){
                
                if(!onError){
                    helper.buildErrorMsg(cmp, helper, response.getError());
                }else{
                    onError(response.getReturnValue());
                }
                
            }
        });
        $A.enqueueAction(action);
    },
	fetchDistribution : function(assessmentId, onSuccess, onError, cmp, event, helper) {

        helper.toggleSpinner(cmp);
		var action = cmp.get("c.fetchDistribution");
        action.setParams({
            "assessmentId" : assessmentId
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
                    onError(response.getReturnValue());
                }
                
            }
            
        });
        $A.enqueueAction(action);	
	},
    updateRecord : function(param, onSuccess, onError, cmp, event, helper){
        helper.toggleSpinner(cmp);
        var action = cmp.get("c.updateRecord");
        action.setParams(param);
        action.setCallback(this, function(response) {
            var state = response.getState();
            
            if (cmp.isValid() && state === "SUCCESS") {
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
    cloneDistribution : function(distributionId, onSuccess, onError, cmp, event, helper){
        
    },
    archiveDistribution : function(distributionId, onSuccess, onError, cmp, event, helper){
        
        helper.toggleSpinner(cmp);
    	var action = cmp.get("c.archiveDistribution");
        action.setParams({
            "distributionId" : distributionId
        });
        action.setCallback(this, function(response){
            helper.toggleSpinner(cmp);
            var status = response.getState();
            
            if(status === "SUCCESS"){
                onSuccess();
            }else if(status === "INCOMPLETE"){
                helper.buildOffLineMsg(cmp, helper);
            }if(status === "ERROR"){
               
                if(!onError){
                    helper.buildErrorMsg(cmp, helper, response.getError());
                }else {
                    onError(response.getReturnValue());
                }
               
            }
            
        });
        $A.enqueueAction(action);	   
    },
    deleteDistribution : function(distributionId, onSuccess, onError, cmp, event, helper){
        
    	helper.toggleSpinner(cmp);
        var action = cmp.get("c.deleteDistribution");
        action.setParams({
            "distributionId" : distributionId
        });
        action.setCallback(this, function(response){   
            helper.toggleSpinner(cmp);
            var status = response.getState();
            if(status === "SUCCESS"){
                onSuccess();
            }else if(status === "INCOMPLETE"){
                helper.buildOffLineMsg(cmp, helper);
            }if(status === "ERROR"){
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