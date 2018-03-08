({
    closeSectionCapture : function(cmp, event, helper) {
        
        var cancelCreateNewSec = cmp.getEvent("cancelCreateSectionEvt");
        cancelCreateNewSec.setParams({
            "position" : cmp.get("v.position"),
            "whichBtn" : cmp.get("v.whichBtn")
        });        
        cancelCreateNewSec.fire();
        
        //window.setTimeout($A.getCallback(function(){
            
          //  if(cmp.isValid()){
                helper.destoryCmp(cmp, event, helper);
            //}
            
        //}),0);
        
    },
    showNotificationEvt : function(cmp, event, status, message, time){
        var showNotificationEvent = $A.get("e.c:notificationEvt");
        showNotificationEvent.setParams({
            "action" : status,
            "message" : message,
            "time" : time
        });
        showNotificationEvent.fire();
    },
    destoryCmp : function(cmp, event, helper){
        var enabelView = cmp.getEvent("doneEditingView");
        enabelView.setParams({
            "Id" : "",
            "type" : "sectionContainer"
        });
        enabelView.fire();
        cmp.destroy();
    }
})