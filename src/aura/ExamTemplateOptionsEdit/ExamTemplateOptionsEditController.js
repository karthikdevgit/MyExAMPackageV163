({
	toggleInLineViewOfAssessment : function(cmp, event, helper) {
        var type = event.getParam("sourceDrivenCmp");
        var editCountIn = cmp.get("v.editCountIn");
        
        Object.keys(editCountIn).forEach(function(element){
            if(element === type){
                event.stopPropagation();   
                var state = event.getParam("state");
                if(state === "enableView"){
                    editCountIn[type]--;
                    if(editCountIn[type] === 0){
                        helper.fireToggleEditView(cmp, event.getParam("Id"), "doneEditingView");
                    }
                }else if(state === "disableView"){
                    editCountIn[type]++;
                    if(editCountIn[type] === 1){
                        helper.fireToggleEditView(cmp, event.getParam("Id"), "editViewOn");
                    }
                }
                cmp.set("v.editCountIn", editCountIn);
            }
        });
	}
})