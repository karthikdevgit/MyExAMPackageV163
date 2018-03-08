({
    search : function(cmp, event, helper) {
        
        var searchString = cmp.get('v.searchString');        
        var lookupList = cmp.find('lookuplist');
        
        $A.util.removeClass(lookupList, 'slds-hide');
        $A.util.addClass(lookupList, 'slds-show');
        
        var action = cmp.get("c.fetchSRC");
        action.setParams({
            "searchString": searchString
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (cmp.isValid() && state === "SUCCESS") {
                var matches = response.getReturnValue();
                cmp.set("v.matches", matches);
            }else if(cmp.isValid() && state === "ERROR"){
                var errors = response.getError();
                if(errors[0] && errors[0].message)// To show other type of exceptions
                    var errorMsg = errors[0].message;
                if(errors[0] && errors[0].pageErrors) // To show DML exceptions
                    errorMsg = errors[0].pageErrors[0].message;
                helper.showNotificationEvt('error', errorMsg);
            }else if(cmp.isValid() && state === "INCOMPLETE"){
                errorMsg = "No response from server or client is offline.";
                helper.showNotificationEvt(status, errorMsg);
            }
        });
        $A.enqueueAction(action);
    },
    select : function(cmp, event){
        var objectLabel = event.currentTarget.innerText ;
        cmp.set("v.searchString", objectLabel);
        var lookupList = cmp.find("lookuplist");
        $A.util.removeClass(lookupList, 'slds-show');
        $A.util.addClass(lookupList, 'slds-hide');
    }
})