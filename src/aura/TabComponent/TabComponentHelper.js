({
    //Fires the Component level event to set the Tab as Active.
    fireEventHelper: function(cmp, event, componentLink) {
        var cmpEvent = cmp.getEvent("SettingSelectedTab");
        cmpEvent.setParams({
            "componentLink": componentLink
        });
        cmpEvent.fire();
    }
})