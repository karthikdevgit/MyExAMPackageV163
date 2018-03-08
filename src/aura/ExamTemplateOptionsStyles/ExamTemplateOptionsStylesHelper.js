({
    buildErrorMsg : function(cmp, event, helper, errors, time){
        var errorMsg = "";
        if(errors[0] && errors[0].message)// To show other type of exceptions
            errorMsg = errors[0].message;
        if(errors[0] && errors[0].pageErrors) // To show DML exceptions
            errorMsg = errors[0].pageErrors[0].message;
        helper.showNotificationEvt("error", errorMsg, time); 
    },
    buildOffLineMsg : function(cmp, event, helper, time){
        var errorMsg = "No response from server or client is offline.";
        helper.showNotificationEvt("error", errorMsg, time);
    },
    showNotificationEvt : function(status, message, time){
        var showNotificationEvent = $A.get("e.c:notificationEvt");
        showNotificationEvent.setParams({
            "action" : status,
            "message" : message,
            "time" : time
        });
        showNotificationEvent.fire();
    }
})