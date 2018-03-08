({  
    firePaginatorEvt : function(cmp, event, startPage){        
        var fireIndex = cmp.getEvent("fireIndex");
        fireIndex.setParams({
            "startPage" : startPage            
        });
        fireIndex.fire();
    }
})