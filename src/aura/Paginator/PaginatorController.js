({  
    // show previous Assessment page 
    
    previous : function(cmp, event, helper){
        var currentPage = cmp.get("v.currentPage");
        
        if(currentPage-1 >= 1){
            var previousPage = currentPage - 1;
            cmp.set("v.currentPage", previousPage);
            helper.firePaginatorEvt(cmp, event, previousPage);
        }
    },
    
    // show next Assessment page 
    
    next : function(cmp, event, helper){
        var currentPage = cmp.get("v.currentPage");
        var LastPage = cmp.get("v.max");
        
        if(currentPage + 1 <= LastPage){
            var nextPage = currentPage + 1;
            cmp.set("v.currentPage", nextPage);
            helper.firePaginatorEvt(cmp, event, nextPage);
        }
    },
    //Show First Assessment page
    
    firstPage : function(cmp, event, helper){
        var min = cmp.get("v.min");
        var currentPage = min;
        
        if(currentPage){
            cmp.set("v.currentPage", Number(currentPage));
            helper.firePaginatorEvt(cmp, event, currentPage);            
        }
    },
    //Show Last Assessment page
    
    lastPage : function(cmp, event, helper){
        var max = cmp.get("v.max");
        var currentPage = max;
        
        if(currentPage){
            cmp.set("v.currentPage", Number(currentPage));
            helper.firePaginatorEvt(cmp, event, currentPage);            
        }
    },
})