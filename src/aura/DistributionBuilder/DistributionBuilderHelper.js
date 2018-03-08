({
    toggleBtnActive : function(cmp, event, helper, activeDom, inActiveDom, className){
        
        if(activeDom && !$A.util.hasClass(activeDom, className)){
            $A.util.addClass(activeDom, className);
        }
        
        if(inActiveDom && $A.util.hasClass(inActiveDom, className)){           
            $A.util.removeClass(inActiveDom, className);
        }
        
    },
    clearSelc_AssRd : function(cmp, event, helper){
        var selectedObjInfo = cmp.get("v.selectedObjInfo");
        
        if(selectedObjInfo.assessableRcd && selectedObjInfo.assessableRcd.Id){
            selectedObjInfo.assessableRcd = {};
            cmp.set("v.selectedObjInfo", selectedObjInfo);
            cmp.find("lookupCmp").clearSelection();
        }
    },
    toggleSpinner : function(cmp){
        var spinner_container = cmp.find("spinner_container");
        $A.util.toggleClass(spinner_container, "slds-hide");
    },
    showNotificationEvt : function(cmp, status, message, time){
        var showNotificationEvent = $A.get("e.c:notificationEvt");
        showNotificationEvent.setParams({
            "action" : status,
            "message" : message,
            "time" : time
        });
        showNotificationEvent.fire();
    },
    selectAssessableObjMode : function(cmp, event, helper, action){
        
        var actionSelections = cmp.get("v.actionSelections");
        
        var chooseObject = cmp.find("chooseObject");
        if($A.util.hasClass(chooseObject, 'slds-hide')){
            $A.util.removeClass(chooseObject, 'slds-hide');
        }
        
        if(action == "Existing"){
            
            var activeDom = cmp.find("assObj_Yes");
            var inActiveDom = cmp.find("assObj_No");
            
            if(!actionSelections.assessableRcd){
                actionSelections.assessableRcd = true;
            }
            
        }else if(action == "New"){
            
            activeDom = cmp.find("assObj_No");
            inActiveDom = cmp.find("assObj_Yes");
            
            if(actionSelections.assessableRcd){
                actionSelections.assessableRcd = false;
            }
            
        }
        
        helper.toggleBtnActive(cmp, event, helper, activeDom, inActiveDom, "activeBtn");
        helper.reset(cmp, event, helper);
        cmp.set("v.actionSelections", actionSelections);
    },
    reset : function(cmp, event, helper){
        var selectedObjInfo = cmp.get("v.selectedObjInfo");
        helper.clearSelc_AssRd(cmp, event, helper);
        selectedObjInfo.assessableObj = {};
        selectedObjInfo.assessableRcd = {};
        cmp.set("v.selectedObjInfo", selectedObjInfo);
    }
    
})