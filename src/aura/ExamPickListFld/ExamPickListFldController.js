({
    doInit : function(cmp, event, helper) {
        
        
        var options = cmp.get("v.options");
        if(!options){
            var action = cmp.get("c.getPicklistValues");
            action.setParams({
                "ObjectApi_name" : cmp.get("v.sObjectName"),
                "Field_name" : cmp.get("v.fieldName")
            });
            action.setCallback(this, function(response){
                var status = response.getStatus();
                if(cmp.isValid() && status === "SUCCESS"){
                    var options = response.getReturnValue();
                    cmp.set("v.options",options);
                }else if(cmp.isValid() && status === "ERROR"){
                    var errors = response.getError();
                    if(errors[0] && errors[0].message)// To show other type of exceptions
                    var errorMsg = errors[0].message;
                    if(errors[0] && errors[0].pageErrors) // To show DML exceptions
                        errorMsg = errors[0].pageErrors[0].message;
                    helper.showNotificationEvt(cmp, event, helper, 'error', errorMsg);
                }else if(cmp.isValid() && status === "INCOMPLETE"){
                    errorMsg = "No response from server or client is offline.";
                    helper.showNotificationEvt(cmp, event, helper, "error", errorMsg);
                }
            });
            $A.enqueueAction(action);
        }else{
            var attributes = [];
            var attribute = {};
            var fieldName = cmp.get("v.fieldName");
            attribute["optionText"] = "--None--";
            attribute["optionValue"] = "";
            attribute["uniqueName"] = fieldName;
            attributes.push(attribute);
            for(var index = 0; index < options.length; index++){
                attribute = {};
                attribute["optionText"] = options[index];
                attribute["optionValue"] = options[index];
                attribute["uniqueName"] = fieldName;
                attributes.push(attribute);
            }
            cmp.set("v.optionsAttribute", attributes);
        }
        var obj = cmp.get("v.record");
        var fieldApi = cmp.get("v.fieldName");
        var value = obj[fieldApi] || ''; 
        cmp.set("v.newValue", value);
        
    },
    getAction : function(cmp, event, helper){
        var type = event.getParam("type");
        
        if(type === "Advanced Options" ||
          type === "Basic Options" ||
          type === "QuestionViewer" || 
          type === "SectionOptions"){
            var fieldName = event.getParam("uniqueName");
            
            if(fieldName === cmp.get("v.fieldName")){
                event.stopPropagation();
                var value = event.getParam("value");
                var text = event.getParam("label");
                if(cmp.get("v.newField")){
                    cmp.set("v.newValue", value);
                }else{
                    cmp.set("v.oldValue", value);
                }
                
            }
        }
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
        if(value == "--None--"){
            value = '';
        }
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
    }
})