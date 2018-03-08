({
	togglePrompt : function(cmp, event, hasConfirm) {
		var promptEvent = cmp.getEvent("promptEvent");
        promptEvent.setParams({
            "hasConfirm" : hasConfirm
        });
        promptEvent.fire();
	}
})