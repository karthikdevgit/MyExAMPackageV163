({ 
    doUpdate : function(cmp, event, helper) {
        if(!cmp.get("v.canSwitchTab")){
            return;
        }
        var tabs = cmp.find("tabCmp");
        
        /*for(var index in tabs){
            tabs[index].changeTab();
        }*/
        
        for(var i = 0; i <  tabs.length; i++){
            tabs[i].changeTab();
        }
        
    }
})