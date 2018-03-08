({
    showNotificationEvt : function(cmp, status, message, time){
        var showNotificationEvent = $A.get("e.c:notificationEvt");
        showNotificationEvent.setParams({
            "action" : status,
            "message" : message,
            "time" : time
        });
        showNotificationEvent.fire();
    },
    toggleSpinner : function(cmp){
        var spinner_container = cmp.find("spinner_container");
        $A.util.toggleClass(spinner_container, "slds-hide");
    },
    generateCmp : function(cmp, event, helper, cmpName, params){
        console.log('genearte')
        helper.toggleSpinner(cmp);
        var createCmp = cmp.find("createCmp");
        createCmp.set("v.body", []);
        $A.createComponent(
            "ExAM:"+cmpName,
            params,
            function(generateCmp, status, errorMessage){
                helper.toggleSpinner(cmp);
                if(status === "SUCCESS"){
                    var body = createCmp.get("v.body");
                    body.push(generateCmp);
                    createCmp.set("v.body", body);
                }else if(status === "INCOMPLETE"){
                    errorMessage = "No response from server or client is offline";
                    helper.showNotificationEvt(cmp, event, "error", errorMessage, null);
                }else if(status === "Error"){
                    errorMessage = errorMessage.split('at org')[0];
                    helper.showNotificationEvt(cmp, event, "error", errorMessage, null);
                }
            }
        );
    }
})