({
     fireEventHelper : function(cmp, event, componentLink){        
        var cmpEvent = cmp.getEvent("SettingSelectedTab");
        cmpEvent.setParams({
            "componentLink": componentLink,
            "changeTab" : true
        });
        cmpEvent.fire();
    }
})