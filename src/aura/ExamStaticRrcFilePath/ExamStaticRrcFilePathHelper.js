({
    saveFilePath : function(cmp, event, helper, filepath){
        var newValue = '';
        for(var i = 0 ; i < filepath.length; i++){
            
            if(!newValue){
                newValue = filepath[i];
            }else{
                newValue = newValue+'~'+filepath[i];
            }
            
        }
        helper.saveField(cmp, event, helper, newValue);
    },
    
    toggleAction : function(cmp, event, helper) {
        if(cmp.get("v.newFilePath")){
            cmp.set("v.newFilePath", false);
        }
        if(cmp.get("v.hideButton")){
            cmp.set("v.hideButton", false);
        }
    }
})