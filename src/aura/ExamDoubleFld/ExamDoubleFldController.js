({
    doInit : function(cmp, event, helper) {
        var obj = cmp.get("v.record");
        var fieldApi = cmp.get("v.fieldName");
        var value = obj[fieldApi];
        value = value != null ? value : null; 
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
        var value = cmp.get("v.oldValue");
        value = value != null ? value : null;
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
})