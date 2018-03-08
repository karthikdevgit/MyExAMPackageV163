({
    removeError : function(cmp, event, helper, uiDate) {
        if($A.util.hasClass(uiDate,'slds-has-error')){
            $A.util.removeClass(uiDate,'slds-has-error');
            uiDate.set("v.errors", []);
            cmp.set("v.isValid", true);
        }
    }
})