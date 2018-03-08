({
    hasErrorEnabled : function(cmp, event, helper, cmpName, msg){
        if(!$A.util.hasClass(cmpName, "slds-has-error")){
            $A.util.addClass(cmpName, "slds-has-error");
            msg = msg || "complete this fields";
            cmpName.set("v.errors", [{message : msg}]);
        }
    },
    hasErrorDisabled : function(cmp, event, helper, cmpName){
        if($A.util.hasClass(cmpName, 'slds-has-error')){
            $A.util.removeClass(cmpName, 'slds-has-error');
            cmpName.set("v.errors", []);
        } 
    },
    validateDate : function(cmp, event, helper, selectionDate){
        
        var todayFormattedDate = helper.getTodayDate();
        
        if(selectionDate != '' && selectionDate < todayFormattedDate){
            return true;
        }else{
            return false;
        }
    },
    getTodayDate : function(cmp, event, helper){
        var today = new Date();        
        var dd = today.getDate();
        var mm = today.getMonth() + 1; //January is 0!
        var yyyy = today.getFullYear();
        // if date is less then 10, then append 0 before date   
        if(dd < 10){
            dd = '0' + dd;
        } 
        // if month is less then 10, then append 0 before date    
        if(mm < 10){
            mm = '0' + mm;
        }
        
        return yyyy+'-'+mm+'-'+dd;
    },
    toggleBtnActive : function(cmp, event, helper, activeDom, inActiveDom, className){
        if(!$A.util.hasClass(activeDom, className)){
            $A.util.addClass(activeDom, className);
        }
        
        if($A.util.hasClass(inActiveDom, className)){
            $A.util.removeClass(inActiveDom, className);
        }
        
    },
    enableReviewViewer : function(cmp, event, helper){
        var enabledViewers = cmp.get("v.enabledViewers")
        if(!enabledViewers.review){
            enabledViewers.review = true;
            cmp.set("v.enabledViewers", enabledViewers);
        }
    },
    reset : function(cmp, event, helper){
        var actionSelections = cmp.get("v.actionSelections");
        if(actionSelections){
            actionSelections.email = false;
            cmp.set("v.actionSelections", actionSelections);
        }
        var selectedObjInfo = cmp.get("v.selectedObjInfo");
        if(selectedObjInfo){
            selectedObjInfo.emailTemplate = {};
            selectedObjInfo.distributiongroup = {};
            cmp.set("v.selectedObjInfo", selectedObjInfo);
        }
        cmp.set("v.emailTemplates", []);
        var distributionRd = cmp.get("v.distributionRd");
        if(distributionRd){
            distributionRd.ExAM__Start_Date__c = '';
            distributionRd.ExAM__Distribution_DateTime__c = "";
            cmp.set("v.distributionRd", distributionRd);
        }
    },
    addHasError : function(cmp, event, helper, scheduledCmp, msg){
        if(!$A.util.hasClass(scheduledCmp, "slds-has-error")){
            $A.util.addClass(scheduledCmp, "slds-has-error");
            scheduledCmp.set("v.errors", [{message : msg}]);
        }
    },
    removeHasError : function(cmp, event, helper, scheduledCmp){
        if($A.util.hasClass(scheduledCmp, "slds-has-error")){
            $A.util.removeClass(scheduledCmp, "slds-has-error");
            scheduledCmp.set("v.errors", []);
        }
    }
})