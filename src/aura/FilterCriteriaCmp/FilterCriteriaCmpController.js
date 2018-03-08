({
    doInit : function(cmp, event, helper) {
        var filterCriteria = cmp.get("v.filterCriteria");
        var fieldType = filterCriteria.fieldType;
        var criteriaMetsByFldTyp = cmp.get("v.criteriaMetsByFldTyp");
        
        
        cmp.set("v.criteriaMets", criteriaMetsByFldTyp[fieldType]);
        
        if(fieldType === "REFERENCE"){
            var fieldValue = filterCriteria.fieldValue;
            
            if(fieldValue){
                var action = cmp.get('c.fetchSpecifyRecord');
                action.setParams({ 
                    "recordId" : filterCriteria.fieldValue,
                    "sObjectAPIName" : filterCriteria.refApi
                });
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    
                    if (cmp.isValid() && state === "SUCCESS"){
                        var refIdWthNameByFld = cmp.get("v.refIdWthNameByFld") || {};
                        refIdWthNameByFld.Id = filterCriteria.fieldValue;
                        refIdWthNameByFld.Name = response.getReturnValue();
                        cmp.set("v.refIdWthNameByFld", refIdWthNameByFld);
                    }
                    else if (cmp.isValid() && state === "ERROR"){
                        helper.buildErrorMsg(cmp, helper, response.getError(), null);
                    }else if(cmp.isValid() && state === "INCOMPLETE"){
                        helper.buildOffLineMsg(cmp, helper, null);
                    }
                    
                });
                $A.enqueueAction(action); 
            }
        }
        
    },
    fieldSelection : function(cmp, event, helper){
        
        var fieldApiName = event.getParam("value");
        
        var currentObjFields = cmp.get("v.contextObjFieldInfo");
        currentObjFields.forEach(function(objFld){
            
            if(objFld.fieldApi === fieldApiName){
                var filterCriteria = cmp.get("v.filterCriteria");
                filterCriteria.operator = '';
                filterCriteria.fieldValue = '';
                
                var fieldType = objFld.fieldType;
                
                if(fieldType === "PICKLIST"){
                    cmp.set("v.pickValuesByFld", objFld.picklistValues);
                }else if(fieldType === "REFERENCE"){
                    filterCriteria.refApi = objFld.refApi;
                }else if(fieldType === "BOOLEAN"){
                    filterCriteria.fieldValue = false;
                }
                
                filterCriteria.fieldApi = objFld.fieldApi;
                filterCriteria.fieldLabel = objFld.fieldLabel;
                filterCriteria.fieldType = fieldType;   
                
                cmp.set("v.criteriaMets", cmp.get("v.criteriaMetsByFldTyp")[fieldType]);
                cmp.set("v.filterCriteria", filterCriteria);
                
            }
            
        });
    },
    criteriaSelection : function(cmp, event, helper){
        var operator = event.getParam("value");     
        cmp.set("v.filterCriteria.operator", operator);
    },
    pickValSelc : function(cmp, event, helper){
        var value = event.getParam("value");
        cmp.set("v.filterCriteria.fieldValue", value);
    },
    changePercentVal : function(cmp, event, helper){
        var value = event.getSource.get("v.value");
        if(value){
            value *= 100; 
            cmp.set("v.filterCriteria.fieldValue", value);
        }
    },
})