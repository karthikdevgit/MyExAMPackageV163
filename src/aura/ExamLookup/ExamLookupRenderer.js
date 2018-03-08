({
    // Your renderer method overrides go here
    afterRender: function (cmp, helper) {
        this.superAfterRender();
        var forOpen = cmp.find("searchRes");
        
        helper.windowClick = $A.getCallback(function(event){
            if(cmp.isValid() &&  $A.util.hasClass(forOpen, 'slds-is-open')){
                $A.util.addClass(forOpen, 'slds-is-close');
                $A.util.removeClass(forOpen, 'slds-is-open');
                //cmp.set("v.listOfSearchRecords",null);
            }
        });
        
        document.addEventListener('click',helper.windowClick);
    },
    unrender: function (cmp, helper) {
        this.superUnrender();
        document.removeEventListener('click', helper.windowClick);
    }
})