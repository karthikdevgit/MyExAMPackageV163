({
    //Function used on onClick of tab links.
    fireEvent: function(cmp, event, helper) {
        if(!cmp.get("v.canSwitchTab")){
                var showNotificationEvent = $A.get("e.c:notificationEvt");
                showNotificationEvent.setParams({
                    "action": "error",
                    "message": "Please save your changes before continuing.",
                    "time": null
                });
                showNotificationEvent.fire();
            return;
        }
        
        if(cmp.get("v.currentComponent") !== cmp.get("v.componentLink")){
            cmp.set("v.currentComponent", cmp.get("v.componentLink"));
            helper.fireEventHelper(cmp, event, cmp.get("v.componentLink"));
        }
        
    },
    
    //Function used for updating the style of selected tab as ACTIVE.
    changeTempalteTab: function(cmp, event, helper) {
        
        if(cmp.get("v.currentComponent") === cmp.get("v.componentLink")){
            cmp.set("v.active", true);
        }else{
            cmp.set("v.active", false);
        }
        
    }
})