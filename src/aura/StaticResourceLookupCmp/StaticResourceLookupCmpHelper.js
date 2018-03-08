({
	showNotificationEvt : function(status, message){
        var showNotificationEvent = $A.get("e.c:notificationEvt");
        showNotificationEvent.setParams({
            "action" : status,
            "message" : message
        });
        showNotificationEvent.fire();
    }
})