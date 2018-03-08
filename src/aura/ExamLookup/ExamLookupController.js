({
    keyPressController : function(cmp, event, helper) {
        // get the search Input keyword   
        var getInputkeyWord = cmp.get("v.SearchKeyWord");
        // check if getInputKeyWord size id more then 0 then open the lookup result List and 
        // call the helper 
        // else close the lookup result List part.   
        if( getInputkeyWord.length > 2 ){
            
            helper.filterSearch(cmp, event, helper, getInputkeyWord);
        }
        else{  
            cmp.set("v.matches",null); 
            var forclose = cmp.find("searchRes");
            $A.util.addClass(forclose, 'slds-is-close');
            $A.util.removeClass(forclose, 'slds-is-open');
        }
        
    },
    
    // function for clear the Record Selaction 
    clear :function(cmp, event, heplper){
        
        var pillTarget = cmp.find("lookup-pill");
        var lookUpTarget = cmp.find("lookupField"); 
        
        $A.util.addClass(pillTarget, 'slds-hide');
        $A.util.removeClass(pillTarget, 'slds-show');
        
        $A.util.addClass(lookUpTarget, 'slds-show');
        $A.util.removeClass(lookUpTarget, 'slds-hide');
        
        cmp.set("v.SearchKeyWord",null);
        
        cmp.set("v.selectedRecord", null );
        
    },
    selectedRecord : function(cmp, event, helper){
        var selectedRecord = cmp.get("v.selectedRecord") || {};
        if(selectedRecord.Id){
            helper.showLookupfield(cmp, event);   
        }
    },
    select : function(cmp, event, helper){
        var objectId = helper.resolveId(event.currentTarget.id);
        var objectLabel = event.currentTarget.innerText ;
        var selectedRecord = cmp.get("v.selectedRecord") || {};
        selectedRecord["Id"] = objectId;
        selectedRecord["Name"] = objectLabel;
        cmp.set("v.selectedRecord", selectedRecord);
        cmp.set("v.SearchKeyWord", objectLabel);
        helper.showLookupfield(cmp);
    },
    validate : function(cmp, event, helper){
        var selectedRecord = cmp.get("v.selectedRecord") || {};
        var lookupCmp = cmp.find("lookupinput");
        if(!selectedRecord.Id){
            if(!$A.util.hasClass(lookupCmp, 'hasError')){
                $A.util.addClass(lookupCmp, 'hasError');
                lookupCmp.set("v.errors", [{"message" : 'Please complete this field'}]);
            }   
            return true;
        }else{
            if($A.util.hasClass(lookupCmp, 'hasError')){
                $A.util.removeClass(lookupCmp, 'hasError');
                lookupCmp.set("v.errors", []);
            } 
            return false;
        }
    }
    
})