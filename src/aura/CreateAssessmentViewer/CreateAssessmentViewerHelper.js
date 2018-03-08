({
    // component destoried
    destroyCmp : function(cmp) {
        
        window.setTimeout($A.getCallback(function(){
            if(cmp.isValid()){
                cmp.destroy();
            }
        }),0);
        
    },
    // show Notification based On Action'Result
    showNotificationEvt : function(status, message, time){
        var showNotificationEvent = $A.get("e.c:notificationEvt");
        showNotificationEvent.setParams({
            "action": status,
            "message": message,
            "time": time
        });
        showNotificationEvent.fire();
    },
})