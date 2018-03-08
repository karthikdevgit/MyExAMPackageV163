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
            cmp.set("v.oldValue", cmp.get("v.newValue"));
            cmp.set("v.defaultMode", "edit");
            helper.disableView(cmp, event, helper);
        }
    },
    updateFieldValue : function(cmp, event, helper) {
        var staticResourceCmp = cmp.find("staticResource");
        var value = staticResourceCmp.get("v.searchString");
        helper.saveField(cmp, event, helper, value);
    },
    cancelUpdateFieldVal : function(cmp, event, helper){
        cmp.set("v.defaultMode", "view");
        helper.enableView(cmp, event, helper);
    },
})