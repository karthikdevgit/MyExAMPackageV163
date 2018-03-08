({
    doInit : function(cmp, event, helper) {
        var obj = cmp.get("v.record");
        var fieldApi = cmp.get("v.fieldName");
        var value = obj[fieldApi] || ''; 
        var filepaths = [];
        if(value){
            filepaths = value.split('~');
        }
        cmp.set("v.staticResourceFilePaths", filepaths);
    },
    changevalue : function(cmp, event, helper){
        if(!cmp.get("v.newFilePath")){
            helper.disableView(cmp, event, helper);
            var filepath = cmp.get("v.staticResourceFilePaths");
            var index = event.currentTarget.getAttribute("data-index");
            cmp.set("v.currentValue", filepath[index]);
            cmp.set("v.index", parseInt(index, 10));
            cmp.set("v.hideButton", true);
        }
    },
    updateFieldValue : function(cmp, event, helper) {
        var index = event.currentTarget.getAttribute("data-index");
        var filePath = cmp.get("v.staticResourceFilePaths");
        
        if(filePath.length === parseInt(index, 10)){
            filePath.push(cmp.get("v.currentValue"));
        }else{
            filePath[index] = cmp.get("v.currentValue");
        }
        
        cmp.set("v.staticResourceFilePaths", filePath);
        cmp.set("v.currentValue", '');
        cmp.set("v.index", null);
        helper.toggleAction(cmp, event, helper);
        helper.saveFilePath(cmp, event, helper, filePath);
    },
    cancelUpdateFieldVal : function(cmp, event, helper){
        helper.enableView(cmp, event, helper);
        cmp.set("v.index", null);
        helper.toggleAction(cmp, event, helper);
    },
    CreateNewFilePath : function(cmp, event, helper){
        helper.disableView(cmp, event, helper);
        cmp.set("v.newFilePath", true);
        cmp.set("v.currentValue", '');
        cmp.set("v.hideButton", true);
    },
    removeFieldValue : function(cmp, event, helper){
        var index = event.currentTarget.getAttribute("data-index");
        var filePath = cmp.get("v.staticResourceFilePaths");
        filePath.splice(index,1);
        cmp.set("v.staticResourceFilePaths", filePath);
        cmp.set("v.index", null);
        
        if(cmp.get("v.hideButton")){
            cmp.set("v.hideButton", false);
        }
        helper.saveFilePath(cmp, event, helper, filePath);
    }
})