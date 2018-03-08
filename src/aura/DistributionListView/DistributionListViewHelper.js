({
	distributionSplice : function(cmp, event, helper, distributionIndex) {
        var distributions = cmp.get("v.distributions");
        distributions.splice(distributionIndex,1);
        cmp.set('v.distributions' , distributions);	
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