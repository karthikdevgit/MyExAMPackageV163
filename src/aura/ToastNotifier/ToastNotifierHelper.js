({
    closeAlertNotified : function(cmp, event) {
        $A.enqueueAction(cmp.get("v.method"));
        cmp.destroy();
    }
})