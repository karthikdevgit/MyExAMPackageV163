({
    doInit : function(cmp, event, helper){
        
        if(!cmp.get("v.menuLinkText")){
            cmp.set("v.menuLinkText", cmp.get("v.attributes[0].optionText"));
        }
    },
    // toggle Action Menu
  showAction: function(cmp, event, helper) {
    helper.toggleDropdown(cmp, event);
  },
    // select Option
  selectItem: function(cmp, event, helper) {
    helper.fireEventHelper(cmp, event);
	
    if (cmp.get("v.linkChange")) {
      cmp.set("v.menuLinkText", event.currentTarget.getAttribute(
        "data-optionText"));
    }

  },
    // closeDropdown if already other dropDown is open
    closeDropDown : function(cmp,event,helper){
        var type = event.getParam("sourceDerivenCmp");
        var index = event.getParam("index");
        var dropdown = cmp.find('dropdown');
        
        if(type === cmp.get("v.sourceDerivenCmp").type){
            if(index !== cmp.get("v.itemIndex") && $A.util.hasClass(dropdown, 'slds-is-open')){
                helper.closeDropdown(cmp,event);
            }  
        }else if($A.util.hasClass(dropdown, 'slds-is-open')){
            event.stopPropagation();
            helper.closeDropdown(cmp,event);
        }
        
        event.stopPropagation();
    }
})