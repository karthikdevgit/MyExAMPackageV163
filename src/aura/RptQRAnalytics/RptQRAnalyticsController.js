({
    showLegends : function(cmp, event, helper){
        $A.util.toggleClass(cmp.find("legend"), "slds-hide");
        cmp.set("v.showLegend", !cmp.get("v.showLegend"));
    }
})