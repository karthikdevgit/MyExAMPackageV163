({
    showToast : function(cmp, event, helper) {
        var toast = $A.get("e.force:showToast");
        if (toast){
            toast.setParams({
                "type": event.getParam("action"),
                "message":  event.getParam("message")
            });
            toast.fire();
        }else{
            var toastContainer = cmp.find("toastContainer");
            var body = toastContainer.get("v.body");
            
            if(body.length > 1){
                return;
            }
            
            var action = event.getParam("action");
            var message = event.getParam("message");
            var time = event.getParam("time");
            
            var attribute = {
                "action": action,
                "message": message,
                "time" : time,
                "method" : cmp.getReference("c.destoryToast")
            };
            $A.createComponent(
                "c:ToastNotifier",
                attribute
                ,
                function(notification, status, errorMessage){
                    
                    if (cmp.isValid() && status === "SUCCESS") {
                        
                        body.push(notification);
                        toastContainer.set("v.body", body);
                    }
                    else if (cmp.isValid() && status === "INCOMPLETE") {
                        errorMessage = "No response from server or client is offline.";
                        helper.showNotificationEvt("error", errorMessage, null);
                    }
                        else if (cmp.isValid() && status === "ERROR") {
                            errorMessage = errorMessage.split('at org')[0];
                            helper.showNotificationEvt("error", errorMessage, null);
                        }
                }
            );
            
        }
    },
    destoryToast : function(cmp){
        var toastContainer = cmp.find("toastContainer");
        var body = toastContainer.get("v.body");
        body.splice(body.length-1, 1);
        toastContainer.set("v.body", body);
    }
})