({
    doInit : function(cmp,event,helper){
        var status = cmp.get("v.action");
         if(status !== 'error'){
            window.setTimeout(
            $A.getCallback(function() {
                if (cmp.isValid()) {
                    helper.closeAlertNotified(cmp, event);
                }
            }), cmp.get("v.time") || 5000
        );
         }

    },
    closeNotification : function(cmp, event, helper) {
        helper.closeAlertNotified(cmp, event);
    }
})