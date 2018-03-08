({
	confirmActionPerform : function(cmp, event, helper) {
        var hasConfirm = event.target.getAttribute("data-index");
        if(hasConfirm === "true"){
            hasConfirm = true;
        }else{
            hasConfirm = false;
        }
		helper.togglePrompt(cmp, event, hasConfirm);
	},
    
})