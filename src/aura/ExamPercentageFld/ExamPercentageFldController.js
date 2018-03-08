({
    doInit : function(cmp, event, helper) {
        var obj = cmp.get("v.record");
        var fieldApi = cmp.get("v.fieldName");
        var value = obj[fieldApi] || null; 
        cmp.set("v.newValue", value);
    },
    changevalue : function(cmp, event, helper){
        var defaultMode = cmp.get("v.defaultMode");
        if(defaultMode != "edit"){
            helper.disableView(cmp, event, helper);
            var showValue = cmp.get("v.showValue");
            if(showValue){
                showValue *= 100; 
            }
            cmp.set("v.oldValue", showValue);
            cmp.set("v.defaultMode", "edit");
        }
    },
    updateFieldValue : function(cmp, event, helper) {
        var value = cmp.get("v.oldValue") || null;
        helper.saveField(cmp, event, helper, value);
    },
    cancelUpdateFieldVal : function(cmp, event, helper){
        helper.enableView(cmp, event, helper);
        cmp.set("v.defaultMode", "view");
    },
    setPercentageValue : function(cmp, event, helper){
        var value = cmp.get("v.newValue");
        if(value){
            value /= 100;
        }
        cmp.set("v.showValue", value);
        if(cmp.get("v.newField")){
            var obj = cmp.get("v.record");
            var fieldApi = cmp.get("v.fieldName");
            obj[fieldApi] = cmp.get("v.showValue"); 
            cmp.set("v.record", obj);
        }
    }
})