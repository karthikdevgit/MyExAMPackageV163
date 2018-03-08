({
    editModeSelc : function(cmp, event, helper){
        var mode = cmp.get("v.mode");
        if(!mode.edit){
            mode.edit = true;
        }
        if(mode.view){
            mode.view = false;
        }
        
        cmp.set("v.mode", JSON.parse(JSON.stringify(mode)));
        
    }, 
    viewModeSelc : function(cmp, event, helper){
        var mode = cmp.get("v.mode");
        if(!mode.view){
            mode.view = true;
        }
        if(mode.edit){
            mode.edit = false;
        }  
        cmp.set("v.mode", mode);
    },
    clearSelectionBySwitch : function(cmp, event, helper, selectedObjInfo){
        
        if(selectedObjInfo.distributiongroup.Id){
            selectedObjInfo.distributiongroup = {};
        }
        
        var selectionFilterCriteria = cmp.get("v.selectionFilterCriteria") || [];
        if(selectionFilterCriteria.length){
            cmp.set("v.selectionFilterCriteria", []);
        }
        
        var distributionGroupRd = cmp.get("v.distributionGroupRd") || {};
        
        if(Object.keys(distributionGroupRd).length){
            distributionGroupRd["Name"] = '';
            distributionGroupRd["ExAM__Target_Object__c"] = '';
            distributionGroupRd["ExAM__Target_Object_Filter__c"] = '';
            cmp.set("v.distributionGroupRd", distributionGroupRd);
            var distributionRd = cmp.get("v.distributionRd");
            if(distributionRd.ExAM__Start_Date__c){
                distributionRd.ExAM__Start_Date__c = null;
                cmp.set("v.distributionRd", distributionRd);
            }
        }
    },
    revertActionSelectionBySwitch : function(cmp, event, helper, actionSelections){
        
        if(actionSelections.criteria){
            actionSelections.criteria = false;
        }
        if(actionSelections.showCount){
            actionSelections.showCount = false;
        }
        
        helper.resetMode(cmp, event, helper);
        
    },
    validateCriteria : function(cmp, event, helper, selectionFilterCriteria){
        var missingArguments = {};
        var count = 0;
        var errorMsg = '' ;
        for(var i = 0; i < selectionFilterCriteria.length; i++){
            selectionFilterCriteria[i].fieldApi
            if(!selectionFilterCriteria[i].fieldApi){
                
                if(!missingArguments["fields"]){
                    errorMsg += errorMsg ? ", fields" : "fields";
                    missingArguments["fields"] = true; 
                    count++;
                } 
            } 
            if(!selectionFilterCriteria[i].operator){
                if(!missingArguments["operator"]){
                    
                    errorMsg += errorMsg ? ", operator" : "operator";
                    missingArguments["operator"] = true; 
                    count++;
                } 
                
            }
            if(selectionFilterCriteria[i].fieldType != "BOOLEAN" && !selectionFilterCriteria[i].fieldValue){
                if(!missingArguments["value"]){
                    errorMsg += errorMsg ? ", value" : "value";
                    missingArguments["value"] = true; 
                    count++;
                } 
            }
            if(count == 3){                
                break;
            }
        }
        return errorMsg;
    },
    setContextTargetObj : function(cmp, event, helper, fieldInfo, distrGroupInfo){
        var contextTargetObj = cmp.get("v.contextTargetObj");
        contextTargetObj.fieldInfo = fieldInfo;
        contextTargetObj.distrGroupInfo = distrGroupInfo;
        cmp.set("v.contextTargetObj", contextTargetObj);
    },
    showCount : function(cmp, event, helper){
        var actionSelections = cmp.get("v.actionSelections");
        if(!actionSelections.showCount){
            actionSelections.showCount = true;
            cmp.set("v.actionSelections", actionSelections);
        }
    },
    clearSelectionInfoByWho : function(cmp, event, helper){
        var selectedObjInfo = cmp.get("v.selectedObjInfo");
        if(selectedObjInfo.targetObj.objAPI){
            selectedObjInfo.targetObj = {
                'objAPI' : '',
                'objLabel' : ''
            };
        }
        
        helper.clearSelectionBySwitch(cmp, event, helper, selectedObjInfo);
        if(selectedObjInfo.emailTemplate.Id){
            selectedObjInfo.emailTemplate = {};
        }
        cmp.set("v.selectedObjInfo", selectedObjInfo);
    },
    revertActionSelection : function(cmp, event, helper){
        
        var actionSelections = cmp.get("v.actionSelections");
        
        if(actionSelections.newGroup){
            actionSelections.newGroup = false;
        }else if(actionSelections.existingGroup){
            actionSelections.existingGroup = false;
        }
        
        helper.revertActionSelectionBySwitch(cmp, event, helper, actionSelections);
        
        if(actionSelections.email){
            actionSelections.email = false;
        }        
        cmp.set("v.actionSelections", actionSelections);
    },
    addCriteria : function(cmp, event, helper, selectionFilterCriteria){
        var filterCriteria = {
            'fieldApi' : '',
            'fieldLabel' : '',
            'fieldType' : 'STRING',
            'operator' : '',
            'fieldValue' : ''
        };
        selectionFilterCriteria.push(filterCriteria);
        cmp.set("v.selectionFilterCriteria", selectionFilterCriteria);
    },
    toggleBtnActive : function(cmp, event, helper, activeDom, inActiveDom, className){
        if(activeDom && !$A.util.hasClass(activeDom, className)){
            $A.util.addClass(activeDom, className);
        }
        
        if(inActiveDom && $A.util.hasClass(inActiveDom, className)){
            $A.util.removeClass(inActiveDom, className);
        }
        
    },
    
    showNotificationEvt : function(cmp, status, message, time){
        var showNotificationEvent = $A.get("e.c:notificationEvt");
        showNotificationEvent.setParams({
            "action" : status,
            "message" : message,
            "time" : time
        });
        showNotificationEvent.fire();
    },
    targetSelection : function(cmp, event, helper, action){
        
        var actionSelections = cmp.get("v.actionSelections");
        if(action == "Yes" && !actionSelections.distr_TargetObj){
            var activeDom = cmp.find("objSelcYes");
            var inActiveDom = cmp.find("objSelcNo");
            
            var distributionGroupRd = cmp.get("v.distributionGroupRd") || {};
            if(!Object.keys(distributionGroupRd).length){
                distributionGroupRd["Name"] = '';
                distributionGroupRd["ExAM__Target_Object__c"] = '';
                distributionGroupRd["ExAM__Target_Object_Filter__c"] = '';
                cmp.set("v.distributionGroupRd", distributionGroupRd);
            }
            
            actionSelections.distr_TargetObj = true; 
            
            if(cmp.get("v.targetObjs").length == 0){
                window.Exam.DistributionGroupServiceComponent.fetchTargetObjectsWthOperators($A.getCallback(function(response){
                    cmp.set("v.criteriaMetsByFldTyp", response.fieldTypeWithOperatorsMap );
                    cmp.set("v.targetObjs", response.targetObjectList);
                }), null);
            }
            
            
        }else if(action == "No" && !actionSelections.distr_Link){
            var activeDom = cmp.find("objSelcNo");
            var inActiveDom = cmp.find("objSelcYes");
            actionSelections.distr_Link = true;
            
        }
        
        helper.toggleBtnActive(cmp, event, helper, activeDom, inActiveDom, "activeBtn");
        cmp.set("v.actionSelections", actionSelections);
    },
    
    resetAudience : function(cmp, event, helper){
        var actionSelections = cmp.get("v.actionSelections");
        if(actionSelections){
            if(actionSelections.distr_Link){
                actionSelections.distr_Link = false;
            }
            if(actionSelections.distr_TargetObj){
                actionSelections.distr_TargetObj = false;
            }
            helper.resetTargetSelection(cmp, event, helper, actionSelections);
        }
        
        var targetObjs = cmp.get("v.targetObjs");
        if(targetObjs && targetObjs.length){
            cmp.set("v.targetObjs", []);
        }
        
    },
    resetTargetSelection : function(cmp, event, helper, actionSelections){
        if(actionSelections.criteria){
            actionSelections.criteria = false;
        }
        if(actionSelections.newGroup){
            actionSelections.newGroup = false;
        }
        if(actionSelections.existingGroup){
            actionSelections.existingGroup = false;
        }
        if(actionSelections.showCount){
            actionSelections.showCount = false;
        }
        cmp.set("v.actionSelections", actionSelections);
        
        var distributionRd = cmp.get("v.distributionRd");
        if(distributionRd){
            distributionRd.ExAM__Target_Object_Ids__c = '';
            cmp.set("v.distributionRd", distributionRd);
        }
        
        
        var selectedObjInfo = cmp.get("v.selectedObjInfo");
        if(selectedObjInfo){
            selectedObjInfo.targetObj = {
                'objAPI' : '',
                'objLabel' : ''
            }
            selectedObjInfo.distributiongroup = {};
            cmp.set("v.selectedObjInfo", selectedObjInfo);
        }
        var distributionGroupRd = cmp.get("v.distributionGroupRd");
        if(distributionGroupRd && distributionGroupRd.Name){
            distributionGroupRd["Name"] = '';
            cmp.set("v.distributionGroupRd", distributionGroupRd);
        }
    },
    resetMode : function(cmp, event, helper){
        var mode = cmp.get("v.mode");
        if(mode.edit){
            mode.edit = false;
        }
        if(mode.view){
            mode.view = false;
        }
        cmp.set("v.mode", mode);
    },
    destoryRelatedChildCard : function(cmp, event, helper){
        var enabledViewers = cmp.get("v.enabledViewers");
        if(enabledViewers.manner){
            enabledViewers.manner = false;
        }
        if(enabledViewers.review){
            enabledViewers.review = false;
        }
        cmp.set("v.enabledViewers", enabledViewers);
    },
    resetLocalContext : function(cmp, event, helper){
        var selectionFilterCriteria = cmp.get("v.selectionFilterCriteria");
        if(selectionFilterCriteria && selectionFilterCriteria.length){
            cmp.set("v.selectionFilterCriteria", []);
        }       
        cmp.set("v.contextTargetObj", {
            'fieldInfo' : [],
            'distrGroupInfo' : []
        });
    },
    resetErrors : function(cmp, event, helper){
        var errors = cmp.get("v.errors");
        var criteriaMet = errors.criteriaMet;
        if(criteriaMet.hasError){
            criteriaMet.hasError = false;
            criteriaMet.errorMsg = "";
        }
        var groupSelc = errors.groupSelc;
        if(groupSelc.hasError){
            groupSelc.hasError = false;
        }
        var applyCriteria = errors.applyCriteria;
        if(applyCriteria.hasError){
            applyCriteria.hasError = false;
        }
        
        cmp.set("v.errors", errors);
    },
    setDistrGroupInstance : function(cmp, event, helper){
        var distributionGroupRd = cmp.get("v.distributionGroupRd");
        
        if(distributionGroupRd){
            var selectedObjInfo = cmp.get("v.selectedObjInfo").targetObj;
            var JSONStr = JSON.stringify(cmp.get("v.selectionFilterCriteria") || '');
            
            if(!cmp.get("v.actionSelections").newGroup){
                var distributiongroup = cmp.get("v.selectedObjInfo").distributiongroup;
                distributionGroupRd["Id"] = distributiongroup.Id;
                distributionGroupRd["Name"] = distributiongroup.Name;
            }
            
            distributionGroupRd.ExAM__Target_Object__c = selectedObjInfo.objAPI;
            distributionGroupRd.ExAM__Target_Object_Filter__c = JSONStr;
            cmp.set("v.distributionGroupRd", distributionGroupRd);
        }
        
    },
    setTargetIds : function(cmp, event, helper, response){
        var targetRecords = response.targetRecords;
        var targetRdIdFldLength = response.targetRdIdFldLength;
        
        if(targetRecords.length){
            var distributionRd = cmp.get("v.distributionRd");
            if(distributionRd.ExAM__Target_Object_Ids__c){
                distributionRd.ExAM__Target_Object_Ids__c = "";
            }
            var lengthOfIds = 0;
            
            for(var i = 0; i < targetRecords.length; i++){
                lengthOfIds += targetRecords[i].Id.length;
                if(distributionRd.ExAM__Target_Object_Ids__c){
                    
                    if(lengthOfIds ==  Math.floor(targetRdIdFldLength)){
                        break;
                    }
                    
                    distributionRd.ExAM__Target_Object_Ids__c += ','+targetRecords[i].Id;
                    
                }else{
                    distributionRd.ExAM__Target_Object_Ids__c = targetRecords[i].Id;
                }
                
                
            }
            cmp.set("v.distributionRd", distributionRd);
        }
    },
    resetDisabled : function(cmp, event, helper){
        var createFliter = cmp.find("createFliter");
        if($A.util.hasClass(createFliter, "disabled")){
            $A.util.removeClass(createFliter, "disabled")
        }
    },
    
    criteriaInEditMode : function(cmp, event, helper){
        
    },
    wthOutCriteriaUseNewGrp : function(cmp, event, helper, objName){
        var hasEnabled = cmp.get("v.hasEnabled");
        hasEnabled.wthOutCriteriaUseNewGrp.prompt = true;
        var promptMsg = cmp.get("v.promptMsg");
        promptMsg.headerMsg = "Continue";
        promptMsg.msgDescription = "Do you want to send public assessment link to all the "+objName;
        cmp.set("v.promptMsg", promptMsg);
        cmp.set("v.hasEnabled", hasEnabled);
    },
    getTargetAudienceRecord : function(cmp, event, helper, selectionFilterCriteria){
        var selectedObjInfo = cmp.get("v.selectedObjInfo");
        var targetObjName = selectedObjInfo.targetObj.objAPI;
        
        var params = {
            "selGrpId" : selectedObjInfo.distributiongroup.Id || '',
            "sObjectName" : targetObjName,
            "JSONStr" : JSON.stringify(selectionFilterCriteria),
            "groupName" : cmp.get("v.distributionGroupRd").Name
        };
        window.Exam.DistributionGroupServiceComponent.checkCriteriaMet(params, $A.getCallback(function(response){
            helper.setTargetIds(cmp, event, helper, response);
            var isAvailable = response.isAvailable;
            
            if(isAvailable){
                helper.showNotificationEvt(cmp, "error", "A group already exists with same criteria", null);
                return;
            }
            
            cmp.set("v.noOfRecords", response.count);
            helper.viewModeSelc(cmp, event, helper);
            helper.showCount(cmp, event, helper);
            
            if(!selectionFilterCriteria.length){
                cmp.set("v.selc_TargetObjName", targetObjName);
                helper.enableSendTypeViewer(cmp, event, helper, cmp.get("v.actionSelections"));
            }
            
        }), null);
    },
    enableSendTypeViewer : function(cmp, event, helper, actionSelections){
        if(actionSelections.distr_TargetObj){
            helper.setDistrGroupInstance(cmp, event, helper);
        }
        var enabledDistr_type = cmp.get("v.enabledViewers");
        if(!enabledDistr_type.manner){
            enabledDistr_type.manner = true;
            cmp.set("v.enabledViewers", JSON.parse(JSON.stringify(enabledDistr_type)));
        }
        helper.toggleBtnActive(cmp, event, helper, cmp.find('proceedBtn'), '', "activeBtn");
    }
    
})