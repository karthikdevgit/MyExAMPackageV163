({
    doInit : function(cmp, event, helper) {
        var obj = cmp.get("v.record");
        var fieldApi = cmp.get("v.fieldName");
        var value = obj[fieldApi] || ''; 
        cmp.set("v.newValue", value);
        
    },
    changevalue : function(cmp, event, helper){
        var defaultMode = cmp.get("v.defaultMode");
        if(defaultMode != "edit"){
            helper.disableView(cmp, event, helper);
            cmp.set("v.oldValue", cmp.get("v.newValue"));
            cmp.set("v.defaultMode", "edit");
        }
    },
    updateFieldValue : function(cmp, event, helper) {
        var value = cmp.get("v.oldValue") || '';
        helper.saveField(cmp, event, helper, value);
        
    },
    cancelUpdateFieldVal : function(cmp, event, helper){
        helper.enableView(cmp, event, helper);
        cmp.set("v.defaultMode", "view");
        
    },
    changeObjValue : function(cmp, event, helper){
        
        if(cmp.get("v.newField")){
            var obj = cmp.get("v.record");
            var fieldApi = cmp.get("v.fieldName");
            obj[fieldApi] = cmp.get("v.newValue"); 
            cmp.set("v.record", obj);
        }
    },
    dateValidate : function(cmp, event, helper){
        
        var fun = cmp.get("v.validator");
        var fieldName = cmp.get("v.fieldName");
       
        var isValid = fun(cmp.get("v.newValue"), fieldName);
        
        var uiDate = cmp.find('uiDate');
        if(isValid.hasError == true){
            
            if(!$A.util.hasClass(uiDate,'slds-has-error')){
                $A.util.addClass(uiDate,'slds-has-error');
                uiDate.set("v.errors", [{message:isValid.errorMsg}]);
                cmp.set("v.isValid", false);
            }else{
                uiDate.set("v.errors", [{message:isValid.errorMsg}]);
            }
        }else{            
            helper.removeError(cmp, event, helper, uiDate);
        }
        
        
    },
    removeDependencyCmpErrors : function(cmp, event, helper){
        
        var uiDate = cmp.find('uiDate');
        helper.removeError(cmp, event, helper, uiDate);
    }
})