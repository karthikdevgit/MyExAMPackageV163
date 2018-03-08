({
    // Your renderer method overrides go here
    
    afterRender: function(cmp, helper) {
        this.superAfterRender();
        
        if (!cmp.get("v.menuLinkText")) {
            cmp.set("v.menuLinkText", cmp.get("v.attributes[0].optionText"))
        }
        
        
        helper.windowClick = $A.getCallback(function(event) {
            if (cmp.isValid()) {
                helper.closeDropdown(cmp, event);
            }
        });
        document.addEventListener('click', helper.windowClick);
        
    },
    unrender: function(cmp, helper) {
        this.superUnrender();
        document.removeEventListener('click', helper.windowClick);
    }
})