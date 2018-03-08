({
	cancel : function(cmp, event, helper) {
        var enableView = cmp.getEvent("doneEditingView");
        enableView.setParams({
            "Id" : cmp.get("v.sectionTemplate").Id
        });
        enableView.fire();
        cmp.destroy();
	},
    toggleInLineViewOfSectionOption : function(cmp, event, helper){
        var sectionId = event.getParam("Id");
        if(sectionId === cmp.get("v.sectionTemplate").Id){
            event.stopPropagation();
            var state = event.getParam("state");
            var editCount = cmp.get("v.editCount") || 0;
            if(state === "disableView"){
                editCount++;
            }else if(state === "enableView"){
                editCount--;
            }
            cmp.set("v.editCount", editCount);
        }
    },
    showSectionOptions : function(cmp, event, helper){
        var sectionLinkPreface = cmp.get("v.sectionOptionsLinkType");
        if(sectionLinkPreface === "Advanced"){
            sectionLinkPreface = "Basic";
        }else{
            sectionLinkPreface = "Advanced";
        }
        cmp.set("v.sectionOptionsLinkType", sectionLinkPreface);
        $A.util.toggleClass(cmp.find("AdvancedOption"), "slds-hide");
        $A.util.toggleClass(cmp.find("BasicOption"), "slds-hide");
    }
})