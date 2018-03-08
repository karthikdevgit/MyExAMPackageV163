({
	fireToggleEditView : function(cmp, Id, eventName){
        var editViewToggle = cmp.getEvent(eventName);
        editViewToggle.setParams({
            "Id" : Id
        });
        editViewToggle.fire();
    }
})