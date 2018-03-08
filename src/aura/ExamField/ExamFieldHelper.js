({
    createExamField : function(cmp, event, helper, attrs, cmpName) {
        var uiCmps = [];

        var uiCmp = [
            cmpName,
            attrs
        ];

        uiCmps.push(uiCmp);
        this.createUiCmps(cmp, helper, uiCmps);

    },
    createUiCmps : function(cmp, helper, uiCmps) {
        var spinner_container = cmp.find("spinner_container");
        $A.util.removeClass(spinner_container, "slds-hide");
        var div = cmp.find("createCmp");        
        div.set("v.body", []);
        $A.createComponents(uiCmps,
            function(components, status, errorMessage){
                $A.util.addClass(spinner_container, "slds-hide");
                if (cmp.isValid() && status === "SUCCESS") {
                    div.set("v.body", components);
                }
                else if (cmp.isValid() && status === "INCOMPLETE") {
                    errorMessage = "No response from server or client is offline.";
					helper.showNotificationEvt("error", errorMessage, null);
                }
                else if (cmp.isValid() && status === "ERROR") {
                    if(errorMessage){
                        errorMessage = errorMessage.split('at org')[0];
                        helper.showNotificationEvt("error", errorMessage, null);
                    }

               }
            }
        );
    },
    showNotificationEvt : function(status, message, time){
        var showNotificationEvent = $A.get("e.c:notificationEvt");
        showNotificationEvent.setParams({
            "action" : status,
            "message" : message,
            "time" : time
        });
        showNotificationEvent.fire();
    },
})