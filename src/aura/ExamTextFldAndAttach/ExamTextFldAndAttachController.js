({
    doInit : function(cmp, event, helper) {
        value = "No file";
        if(!cmp.get("v.newField")){
            if(cmp.get("v.attachment")){
                var value = cmp.get("v.attachment").Name;
                
                if(value){
                    var contentType = cmp.get("v.attachment").ContentType;
                    if(contentType){
                        contentType = contentType.split('/');
                        value = value+'.'+contentType[1];
                    }
                    
                }
            }
        }
        cmp.set("v.oldValue", value);
        cmp.set("v.value", value);
    },
    changevalue : function(cmp, event, helper){
        var defaultMode = cmp.get("v.defaultMode");
        if(defaultMode != "edit"){
            cmp.set("v.defaultMode", "edit");
            helper.disableView(cmp, event, helper);
        }
    },
    updateFieldValue : function(cmp, event, helper) {
        helper.updateFieldValue(cmp, event, helper);
    },
    cancelUpdateFieldVal : function(cmp, event, helper){
        cmp.set("v.value", cmp.get("v.oldValue"));
        cmp.set("v.defaultMode", "view");
        helper.enableView(cmp, event, helper);
    },
    saveImage : function(cmp, event, helper){
        var params = event.getParam('arguments');
        if(params && params.onSuccess){
            var onSuccess = params.onSuccess;
            var fileContent = cmp.find("fileAttachment").get("v.fileContent");
            if(fileContent && Object.keys(fileContent).length){
                helper.updateFieldValue(cmp, event, helper, onSuccess);
            }else{
                onSuccess();
            }
        }
    }
})