({
    toggleSpinner : function(cmp, event, helper) {
        var loading = cmp.find("loading");
        $A.util.toggleClass(loading, "slds-hide");
    },
    // Show Notification 
    showNotificationEvt : function(status, message){
        var showNotificationEvent = $A.get("e.c:notificationEvt");
        showNotificationEvent.setParams({
            "action" : status,
            "message" : message
        });
        showNotificationEvent.fire();
    }
})