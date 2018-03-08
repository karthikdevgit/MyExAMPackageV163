({
    MAX_FILE_SIZE: 750000,
    
    showNotificationEvt : function(cmp, event, helper, status, message){
        var showNotificationEvent = $A.get("e.c:notificationEvt");
        showNotificationEvent.setParams({
            "action" : status,
            "message" : message
        });
        showNotificationEvent.fire();
    },
})