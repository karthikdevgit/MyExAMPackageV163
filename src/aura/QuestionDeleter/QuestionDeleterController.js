({
    doInit : function(cmp, event, helper) {
       
        $A.createComponent(
            "c:PromptNotifier",
            {}
            ,
            function(prompt, status, errorMessage){
                
                if (cmp.isValid() && status === "SUCCESS") {
                    var body = cmp.get("v.body");
                    body.push(prompt);
                    cmp.set("v.body", body);
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
})