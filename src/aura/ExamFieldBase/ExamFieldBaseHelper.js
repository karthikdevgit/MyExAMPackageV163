({
    saveField : function(cmp, event, helper, value) {
        var JsonStru = {};
        JsonStru["id"] = cmp.get("v.Id");
        JsonStru[cmp.get("v.fieldName")] = value;
        
        var param = {
            "ObjectName" : cmp.get("v.sObjectName"),
            "JSONStr" : JSON.stringify(JsonStru),
            "fieldName" : cmp.get("v.fieldName"),
            //"fieldVal" : value
        };

        var status, message;
        var fieldLabel = cmp.get("v.fieldLabel");
        if(param.ObjectName === 'ExAM__Main_questionaire__c'){
            
            window.Exam.AssessmentServiceComponent.updateRecord(param, $A.getCallback(function(record){
                if(cmp.isValid()){
                    helper.enableView(cmp, event, helper);
                    status = "success";
                    message = fieldLabel+" has been updated";
                    helper.showNotificationEvt(cmp, event, helper, status, message);
                    helper.updateFieldsEvt(cmp, event, helper, record);
                    helper.setNewValue(cmp, value);
                }
                
            }), null);
        }

        if(param.ObjectName === 'ExAM__IssueRequest_Life_Cycle__c'){
            window.AMServiceComponent.updateRecord(param, $A.getCallback(function(record){
                if(cmp.isValid()){
                    status = "success";
                    message = fieldLabel+" has been updated";
                    helper.showNotificationEvt(cmp, event, helper, status, message);
                    helper.updateFieldsEvt(cmp, event, helper, record);
                    helper.setNewValue(cmp, value);
                }
                
            }), null);
        }

        if(param.ObjectName === 'ExAM__Section_Template__c'){
            
            window.Exam.SectionServiceComponent.updateRecord(param, $A.getCallback(function(record){
                if(cmp.isValid()){
                    helper.enableView(cmp, event, helper);
                    status = "success";
                    message = fieldLabel+" has been updated";
                    helper.showNotificationEvt(cmp, event, helper, status, message);
                    helper.updateFieldsEvt(cmp, event, helper, record);
                    helper.setNewValue(cmp, value);
                }
                
            }), null);

        }
        
        
        if(param.ObjectName === "ExAM__Distribution__c"){
            
            window.Exam.DistributionServiceComponent.updateRecord(param, $A.getCallback(function(record){
                if(cmp.isValid()){
                    helper.enableView(cmp, event, helper);
                    status = "success";
                    message = fieldLabel+" has been updated";
                    helper.showNotificationEvt(cmp, event, helper, status, message);
                    helper.updateFieldsEvt(cmp, event, helper, record);
                    helper.setNewValue(cmp, value);
                }
                
            }), null);
            
        }

        if(param.ObjectName === 'ExAM__Question_Template__c'){
			if(cmp.get("v.fieldName") === "ExAM__Question_Type__c"){
                if(!value){
                    var status = "warning";
                    var message = "Please select valid Question type";
                    var time = 5000;
                    helper.showNotificationEvt(cmp, event, helper, status, message);
                    return;
                }
            }
            var sectionId = cmp.get("v.record").ExAM__Section_Question__c;
            window.Exam.QuestionServiceComponent.updateRecord(param, sectionId, $A.getCallback(function(record){

                if(cmp.isValid()){
                    helper.enableView(cmp, event, helper);
                    status = "success";
                    message = fieldLabel+" has been updated";
                    helper.showNotificationEvt(cmp, event, helper, status, message);
                    helper.updateFieldsEvt(cmp, event, helper, record);
                    helper.setNewValue(cmp, value, helper);
                }

            }), null);
        }

        
    },
    updateFieldsEvt : function(cmp, event, helper, record){
        var updateFields = cmp.getEvent("updateFields");
        updateFields.setParams({
            "sObject" : record
        });
        updateFields.fire();
    },

    showNotificationEvt : function(cmp, event, helper, status, message){
        var showNotificationEvent = $A.get("e.c:notificationEvt");
        showNotificationEvent.setParams({
            "action" : status,
            "message" : message
        });
        showNotificationEvent.fire();
    },
    updateFieldValue : function(cmp, event, helper, onSuccess ){

        var fieldLabel = cmp.get("v.fieldLabel");
        var status, message;
        var fileAttachment = cmp.find("fileAttachment");
        var fileContent = fileAttachment.get("v.fileContent");
        if(fileContent && Object.keys(fileContent).length){
            fileAttachment.uploadToServer($A.getCallback(function(attachment){
                
                if(cmp.isValid()){
                    
                    cmp.set("v.attachment", attachment);
                    cmp.set("v.defaultMode", "view");
                    
                    var value = cmp.get("v.attachment").Name;
                    
                    if(value){
                        var contentType = cmp.get("v.attachment").ContentType;
                        contentType = contentType.split('/');
                        value = value+'.'+contentType[1];
                    }else{
                        value = "No file";
                    }
                    
                    cmp.set("v.value",value);
                    
                    if(cmp.get("v.newField")){
                        onSuccess();
                    }else{
                        helper.enableView(cmp, event, helper);
                        status = "success";
                        message = fieldLabel+" has been updated";
                        helper.showNotificationEvt(cmp, event, helper, status, message);
                    }
                }
                
            }));
        }else{
            status = "warning";
            message = "choose image or cancel";
            helper.showNotificationEvt(cmp, event, helper, status, message);
        }
    },
    disableView : function(cmp, event, helper){
        
        var sObjectName = cmp.get("v.sObjectName");
        var obj = cmp.get("v.record");
        var fieldName = cmp.get("v.fieldName");
        if(sObjectName === "ExAM__Main_questionaire__c"){
            var type = cmp.get("v.sourceDerivenCmp").type;
            helper.toggleEditView(cmp, "disableView", obj.Id, 'disableViewToggle', fieldName, type);
        }else{
            helper.toggleEditView(cmp, "disableView", obj.Id, 'disableViewToggle', fieldName);
        }
        
    },
    enableView : function(cmp, event, helper){
        
        var sObjectName = cmp.get("v.sObjectName");
        var obj = cmp.get("v.record");
        var fieldName = cmp.get("v.fieldName");
        if(sObjectName === "ExAM__Main_questionaire__c"){
            var type = cmp.get("v.sourceDerivenCmp").type;
            helper.toggleEditView(cmp, "enableView", obj.Id, 'disableViewToggle', fieldName, type);
        }else{
            helper.toggleEditView(cmp, "enableView", obj.Id, 'disableViewToggle', fieldName);
        }
        
    },
    setNewValue : function(cmp, value, helper){
        if(cmp.get("v.sObjectName") == "ExAM__Question_Template__c" && cmp.get("v.fieldName") == "ExAM__Single_Next_Question__c"){
            value = helper.getSelectionQuestionLabel(cmp, event, helper, cmp.get("v.questionList"), value);
            var changeSectionTemp = $A.get("e.c:fireSectionChangedEvt");
            changeSectionTemp.setParams({
                "sectionId" : cmp.get("v.record").ExAM__Section_Question__c,
                "dependent" : true
            });
            changeSectionTemp.fire();
        }
        cmp.set("v.newValue", value);
        cmp.set("v.defaultMode", 'view');
    },
    toggleEditView : function(cmp, state, Id, eventName, fieldName, type){
        
        var editViewToggle = cmp.getEvent(eventName);
        editViewToggle.setParams({
            "state" : state,
            "Id" : Id,
            "fieldName" : fieldName,
            "sourceDrivenCmp" : type
            //"CurrentTab" : currentTab
        });
        editViewToggle.fire();
        
        
    }
})