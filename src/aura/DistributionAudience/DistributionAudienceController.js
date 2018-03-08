({
    targetSelection : function(cmp, event, helper){
        var hasEnabled = cmp.get("v.hasEnabled");
        var action = event.getSource().get("v.label");
        var buttonId = event.getSource().getLocalId();
        if(!($A.util.hasClass(cmp.find(buttonId),'activeBtn'))){
            if(cmp.get("v.enabledViewers").manner && !hasEnabled.targetSelectionChanged.prompt){
                hasEnabled.targetSelectionChanged.prompt = true;
                hasEnabled.targetSelectionChanged.label = action;
                var promptMsg = cmp.get("v.promptMsg");
                promptMsg.headerMsg = "Change";
                promptMsg.msgDescription = "Do you want to Change this view.";
                cmp.set("v.promptMsg", promptMsg);
                cmp.set("v.hasEnabled", hasEnabled);
                return true;
            }
        }
        helper.resetAudience(cmp, event, helper);
        helper.resetMode(cmp, event, helper);
        helper.resetDisabled(cmp, event, helper);
        helper.resetErrors(cmp, event, helper);
        helper.resetLocalContext(cmp, event, helper);
        helper.targetSelection(cmp, event, helper, action);
    },
    targetObjSelection : function(cmp, event, helper){
        helper.resetTargetSelection(cmp, event, helper, cmp.get("v.actionSelections"));
        var selectedTargetObjWthIndex = event.getParam("value");
        
        if(selectedTargetObjWthIndex){
            var selectedTargetObj = selectedTargetObjWthIndex.split('~')[0];
            var index = selectedTargetObjWthIndex.split('~')[1];
            
            var targetObjs = cmp.get("v.targetObjs");
            var targetObj = cmp.get("v.targetObj");
            var distrGroupsInfo = targetObj.distrGroupsInfo;
            var fieldsInfo = targetObj.fieldsInfo;
            
            if(targetObjs[index].objAPI == selectedTargetObj){
                var selectedTargetObjInfo = cmp.get("v.selectedObjInfo").targetObj;
                selectedTargetObjInfo.objAPI = targetObjs[index].objAPI;
                selectedTargetObjInfo.objLabel = targetObjs[index].objLabel;
                cmp.set("v.selectedObjInfo.targetObj", selectedTargetObjInfo);
            }
            if(!distrGroupsInfo[selectedTargetObj]){
                window.Exam.DistributionGroupServiceComponent.fetchSelectedObjectGroup(selectedTargetObj, $A.getCallback(function(response){
                    distrGroupsInfo[selectedTargetObj] = response.distributionGroups;
                    fieldsInfo[selectedTargetObj] = response.fieldList;
                    helper.setContextTargetObj(cmp, event, helper, fieldsInfo[selectedTargetObj], distrGroupsInfo[selectedTargetObj]);
                    cmp.set("v.targetObj", targetObj);
                }), null);
            }else{
                helper.setContextTargetObj(cmp, event, helper, fieldsInfo[selectedTargetObj], distrGroupsInfo[selectedTargetObj]);
            }
        }
    },
    groupNameSelection : function(cmp, event, helper){
        var selectedGroupIdWthIndex = event.getParam("value");
        
        
        if(selectedGroupIdWthIndex){
            var selectedGroupId = selectedGroupIdWthIndex.split('~')[0];
            var index = selectedGroupIdWthIndex.split('~')[1];
            var selectedObjInfo = cmp.get("v.selectedObjInfo");
            var distributiongroup = selectedObjInfo.distributiongroup || {};
            
            if(distributiongroup.Id != selectedGroupId){
                window.Exam.DistributionGroupServiceComponent.fetchCriteriaWthCountOfRd(selectedGroupId, $A.getCallback(function(response){
                    helper.setTargetIds(cmp, event, helper, response);
                    var actionSelections = cmp.get("v.actionSelections");
                    
                    if(!actionSelections.existingGroup){
                        var newGroupCmp = cmp.find("newGroup");
                        $A.util.addClass(newGroupCmp, "disabled");
                        actionSelections.existingGroup = true;
                    }
                    
                    cmp.set("v.noOfRecords", response.count);
                    if(!actionSelections.showCount){
                        actionSelections.showCount = true;
                    }
                    
                    var filtercriteriaList = response.distFilterList;
                    
                    
                    if(filtercriteriaList.length){
                        if(actionSelections.criteria == false){
                            actionSelections.criteria = !actionSelections.criteria;
                        }
                        var mode = cmp.get("v.mode");
                        if(mode.edit){
                            mode.edit = false;
                        }
                        if(!mode.view){
                            mode.view = true;
                            
                        }
                        cmp.set("v.mode", mode);
                    }
                    
                    
                    
                    cmp.set("v.selectionFilterCriteria", filtercriteriaList);
                    
                    var currentDistrGroups = cmp.get("v.contextTargetObj").distrGroupInfo;
                    if(currentDistrGroups[index].Id == selectedGroupId){
                        distributiongroup["Id"] = currentDistrGroups[index].Id;
                        distributiongroup["Name"] = currentDistrGroups[index].Name;
                        selectedObjInfo.distributiongroup = distributiongroup;
                        cmp.set("v.selectedObjInfo", selectedObjInfo);
                    }
                    
                    cmp.set("v.actionSelections", actionSelections);
                }), null);
            }
        }
        
    }, 
    createGroup : function(cmp, event, helper){


        var actionSelections = cmp.get("v.actionSelections");
        if(!actionSelections.newGroup){
            actionSelections.newGroup = true;
        }
        if(actionSelections.criteria){
            actionSelections.criteria = false;
        }
        if(actionSelections.showCount){
            actionSelections.showCount = false;
        }
        var mode = cmp.get("v.mode");
        if(mode.edit){
            mode.edit = false;
        }
        if(!mode.view){
            mode.view = true;
        }
        cmp.set("v.mode", mode);
        //helper.editModeSelc(cmp, event, helper);
        var selectionFilterCriteria = cmp.get("v.selectionFilterCriteria") || [];
        if(selectionFilterCriteria.length){
            cmp.set("v.selectionFilterCriteria", []);
        }
        cmp.set("v.actionSelections", actionSelections);
    },
    addCriteria : function(cmp, event, helper){
        var selectionFilterCriteria = cmp.get("v.selectionFilterCriteria") || [];
        var errors = cmp.get("v.errors");
        var criteriaMetError = errors.criteriaMet;
        var errorMsg = helper.validateCriteria(cmp, event, helper, selectionFilterCriteria);
        
        if(!errorMsg){
            criteriaMetError.hasError = false;
            helper.addCriteria(cmp, event, helper, selectionFilterCriteria);
        }else{
            criteriaMetError.hasError = true;
        }
        criteriaMetError.errorMsg = errorMsg;
        
        cmp.set("v.errors", errors);
    },
    cancelCriteria : function(cmp, event, helper){
        var selectionFilterCriteria = cmp.get("v.selectionFilterCriteria");
        var index = event.currentTarget.getAttribute("data-index");
        
        if(selectionFilterCriteria[index]){
            selectionFilterCriteria.splice(index, 1);
        }
        
        cmp.set("v.selectionFilterCriteria", selectionFilterCriteria);
    },
    createFilter : function(cmp, event, helper){
        var createFliter = cmp.find("createFliter");
        if(!$A.util.hasClass(createFliter, "disabled")){
            $A.util.addClass(createFliter, "disabled");
            helper.editModeSelc(cmp, event, helper);
            
            var actionSelections = cmp.get("v.actionSelections");
            if(!actionSelections.criteria){
                actionSelections.criteria = true;
                if(actionSelections.showCount){
                    actionSelections.showCount = false;                
                }
                cmp.set("v.actionSelections", actionSelections);
            }
            
            var selectionFilterCriteria = cmp.get("v.selectionFilterCriteria") || [];
            helper.addCriteria(cmp, event, helper, selectionFilterCriteria);
        }
    },
    changevalue : function(cmp, event, helper){
        helper.editModeSelc(cmp, event, helper);
        var actionSelections = cmp.get("v.actionSelections");
        if(actionSelections.showCount){
            actionSelections.showCount = false;
            cmp.set("v.actionSelections", actionSelections);
        }
        
    },
    getRdCountOfCriteriaMet : function(cmp, event, helper){
        var selectionFilterCriteria = cmp.get("v.selectionFilterCriteria");
        var errorMsg = helper.validateCriteria(cmp, event, helper, selectionFilterCriteria);
        var errors = cmp.get("v.errors");
        var criteriaMetError = errors.criteriaMet;
        
        if(errorMsg){
            criteriaMetError.hasError = true;
        }else{
            criteriaMetError.hasError = false;
        }
        criteriaMetError.errorMsg = errorMsg;
        cmp.set("v.errors", errors);
        
        if(!errorMsg){
            helper.getTargetAudienceRecord(cmp, event, helper, selectionFilterCriteria);
        }
        
        
    },
    enableSendTypeViewer : function(cmp, event, helper){
        var actionSelections = cmp.get("v.actionSelections");
        
        if(actionSelections.newGroup){
            var selectionFilterCriteria = cmp.get("v.selectionFilterCriteria") || [];
            
            if(selectionFilterCriteria.length  < 1){
                var targetObj = cmp.get("v.selectedObjInfo").targetObj;
                helper.wthOutCriteriaUseNewGrp(cmp, event, helper, targetObj.objLabel); 
                return;
            }
        }
        
        if(cmp.get("v.mode").edit){
            helper.showNotificationEvt(cmp, "error", "Please click Apply Filter to save the changes", null);
            return;
        }
        
        helper.enableSendTypeViewer(cmp, event, helper, actionSelections);
    },
    switchGroup : function(cmp, event, helper){
        var actionSelections = cmp.get("v.actionSelections");
        var existingGroup = actionSelections.existingGroup;
        
        if(existingGroup){
            var inActiveDom = cmp.find("newGroup");            
        }else{
            var activeDom = cmp.find("newGroup");
            helper.resetDisabled(cmp, event, helper);
        }
        actionSelections.newGroup = existingGroup;
        actionSelections.existingGroup = !existingGroup;
        
        var selectedObjInfo = cmp.get("v.selectedObjInfo");
        helper.clearSelectionBySwitch(cmp, event, helper, selectedObjInfo);
        cmp.set("v.selectedObjInfo", selectedObjInfo);
        
        helper.revertActionSelectionBySwitch(cmp, event, helper, actionSelections);
        cmp.set("v.actionSelections", actionSelections);
        helper.resetErrors(cmp, event, helper);
        helper.toggleBtnActive(cmp, event, helper, activeDom, inActiveDom, "disabled");
    },
    validateInputs: function(cmp,event,helper){
        var actionSelections = cmp.get('v.actionSelections');
        var errors = cmp.get("v.errors");
        var hasError = false;
        if(actionSelections.distr_TargetObj){
            if(actionSelections.newGroup){
                var groupNameCmp = cmp.find("groupNameCmp");
                var distr_Name = cmp.get('v.distributionGroupRd').Name;
                if(!distr_Name && !$A.util.hasClass(groupNameCmp, "slds-has-error")){
                    $A.util.addClass(groupNameCmp, "slds-has-error");
                    groupNameCmp.set('v.errors',[{message:"Please Complete this Field"}]);
                    hasError = true;
                    
                }else if(distr_Name && $A.util.hasClass(groupNameCmp, "slds-has-error")){
                    $A.util.removeClass(groupNameCmp, "slds-has-error");
                    groupNameCmp.set('v.errors',[{message:null}]);
                }
            }else if(actionSelections.existingGroup){
                var groupId = cmp.get("v.selectedObjInfo").distributiongroup.Id;
                if(!groupId){
                    errors.groupSelc.hasError = true;
                    
                }else if(groupId){
                    errors.groupSelc.hasError = false;
                }
                
            }
            if(actionSelections.criteria){
                var selectionFilterCriteria = cmp.get("v.selectionFilterCriteria");
                var errorMsg = helper.validateCriteria(cmp, event, helper, selectionFilterCriteria);
                if(errorMsg){
                    errors.criteriaMet.hasError = true;
                }else{
                    errors.criteriaMet.hasError = false;
                }
                errors.criteriaMet.errorMsg = errorMsg;
            }
            
            if(errors.criteriaMet.hasError || errors.groupSelc.hasError){
                hasError = true;
            }
            cmp.set("v.errors", errors);
            return hasError;
        }
    },
    handleDestroy : function(cmp, event, helper){
        helper.resetAudience(cmp, event, helper);
        var enabledViewers = cmp.get("v.enabledViewers");
        if(enabledViewers && enabledViewers.manner){
            enabledViewers.manner = false;
            cmp.set("v.enabledViewers", enabledViewers);
        }
    },
    destroyChilds : function(cmp, event, helper){
        var hasEnabled = cmp.get("v.hasEnabled");
        if(hasEnabled.targetSelectionChanged.prompt){
            event.stopPropagation();
            var hasConfirm = event.getParam("hasConfirm");
            if(hasConfirm){
                var enabledViewers = cmp.get("v.enabledViewers");
                enabledViewers.manner = false;
                cmp.set("v.enabledViewers", enabledViewers);
                helper.resetAudience(cmp, event, helper);
                helper.resetMode(cmp, event, helper); 
                helper.resetLocalContext(cmp, event, helper);
                helper.targetSelection(cmp, event, helper, hasEnabled.targetSelectionChanged.label);
            }
            hasEnabled.targetSelectionChanged.prompt = false;
            hasEnabled.label = '';
            cmp.set("v.hasEnabled", hasEnabled);
        }else if(hasEnabled.wthOutCriteriaUseNewGrp.prompt){
            event.stopPropagation();
            var hasConfirm = event.getParam("hasConfirm");
            if(hasConfirm){
                var targetObj = cmp.get("v.selectedObjInfo").targetObj;
                var selc_TargetObjName = cmp.get("v.selc_TargetObjName");
                if(targetObj.objAPI != selc_TargetObjName){
                    helper.getTargetAudienceRecord(cmp, event, helper, cmp.get("v.selectionFilterCriteria"));
                }else{
                    helper.enableSendTypeViewer(cmp, event, helper, cmp.get("v.actionSelections"));
                }
                
            }
            hasEnabled.wthOutCriteriaUseNewGrp.prompt = false;
            cmp.set("v.hasEnabled", hasEnabled);
        }
        
    },
    setDistributionGrpInstance : function(cmp, event, helper){
        if(cmp.get("v.actionSelections").distr_TargetObj){
            helper.setDistrGroupInstance(cmp, event, helper);
        }
    },
    groupNameSelc : function(cmp, event, helper){
        var selectedObjInfo = cmp.get("v.selectedObjInfo");
        selectedObjInfo.distributiongroup.Name = cmp.get("v.distributionGroupRd").Name;
        cmp.set("v.selectedObjInfo", selectedObjInfo);
    }
    
})