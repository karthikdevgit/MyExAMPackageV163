({
	toggleQuestionOptions: function(cmp, event, helper) {
        var toggleVal = cmp.get("v.hideQuestionOptions");
        cmp.set("v.hideQuestionOptions", !toggleVal);
        $A.util.toggleClass(toggleVal, 'slds-hide');
        $A.util.toggleClass(toggleVal, 'slds-show');
    }
})