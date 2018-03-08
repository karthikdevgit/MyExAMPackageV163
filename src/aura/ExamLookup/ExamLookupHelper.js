({
    windowClick : null,
    
    showLookupfield : function(cmp){
        var forclose = cmp.find("lookup-pill");
        $A.util.addClass(forclose, 'slds-show');
        $A.util.removeClass(forclose, 'slds-hide');
        
        
        var forclose = cmp.find("searchRes");
        $A.util.addClass(forclose, 'slds-is-close');
        $A.util.removeClass(forclose, 'slds-is-open');
        
        var lookUpTarget = cmp.find("lookupField");
        $A.util.addClass(lookUpTarget, 'slds-hide');
        $A.util.removeClass(lookUpTarget, 'slds-show');
    },
    toggleSpinner : function(cmp, event, helper){
        var loading_spinner = cmp.find("loading_spinner");
        $A.util.toggleClass(loading_spinner, "slds-hide");
    },
    filterSearch : function(cmp, event, helper, searchString){
        helper.toggleSpinner(cmp, event, helper);
        var sObjectAPIName = cmp.get('v.objRefName');
        var action = cmp.get('c.lookup');
        
        action.setParams({ 
            "searchString" : searchString,
            "sObjectAPIName" : sObjectAPIName
        });
        action.setCallback(this, function(response) {
            helper.toggleSpinner(cmp, event, helper);
            var state = response.getState();
            
            if (cmp.isValid() && state === "SUCCESS"){
                var matches = response.getReturnValue();
                
                if (matches.length == 0){
                    matches = [];
                    //cmp.set('v.matches', null);
                    //return;
                }
                var forOpen = cmp.find("searchRes");
                $A.util.addClass(forOpen, 'slds-is-open');
                $A.util.removeClass(forOpen, 'slds-is-close');
                cmp.set('v.matches', matches);
                
            }
            else if (cmp.isValid() && state === "ERROR"){
                helper.buildErrorMsg(cmp, helper, response.getError(), null);
            }else if(cmp.isValid() && state === "INCOMPLETE"){
                helper.buildOffLineMsg(cmp, helper, null);
            }
            
        });      
        $A.enqueueAction(action);
    },
    resolveId : function(elmId){
        var i = elmId.lastIndexOf('_');
        return elmId.substr(i+1);
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
        
        helper.showNotificationEvt(cmp, "error", errorMsg, time);
    },
    buildOffLineMsg : function(cmp, helper, time){
        var errorMsg = "No response from server or client is offline.";
        helper.showNotificationEvt(cmp, "error", errorMsg, time);
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
})