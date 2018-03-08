({
    // Get Assessments By Login user
    /*getAssessmentsByCurrentUser : function(onSuccess, onError, data, cmp, helper){
        helper.toggleSpinner(cmp);
        var action = cmp.get("c.fetchAssessment");
        //action.setStorable();
        action.setCallback(this, function(response) {
            var state = response.getState();
            
            if (cmp.isValid() && state === "SUCCESS") {
                data.AssessmentsList = response.getReturnValue();
                onSuccess(response.getReturnValue());
            }else if(cmp.isValid() && state === "ERROR"){
                
                if(!onError){
                    helper.buildErrorMsg(cmp, helper, response.getError(), null);
                }else{
                    onError(response.getError());
                }
                
            }else if(cmp.isValid() && state === "INCOMPLETE"){
                helper.buildOffLineMsg(cmp, helper, null);
            }
            
            helper.toggleSpinner(cmp);
            
        });
        
        $A.enqueueAction(action);
        
    },*/
    // clone Assessment With Related childs
    cloneAssessmentWithRelatedSections : function(param, onSuccess, onError, data, cmp, helper){
        helper.toggleSpinner(cmp);
        var action = cmp.get("c.cloneAssessmentTemp");
        action.setParams(param);
        action.setCallback(this, function(response) {
            var state = response.getState();
            
            if (cmp.isValid() && state === "SUCCESS") {
                var user = data.currentView;
                var assessmentTemplates = data.AssessmentListOnView[user];
                // cloned Assessment push In Assessment List 0th position
                assessmentTemplates.splice(0,0,response.getReturnValue());
                data.AssessmentListOnView[user] = assessmentTemplates;
                onSuccess(data.AssessmentListOnView[user]);
            }else if(cmp.isValid() && state === "ERROR"){
                
                if(!onError){
                    helper.buildErrorMsg(cmp, helper, response.getError(), null);
                }else{
                    onError(response.getError());
                }
                
            }else if(cmp.isValid() && state === "INCOMPLETE"){
                helper.buildOffLineMsg(cmp, helper, null);
            }
            
            helper.toggleSpinner(cmp);
            
        });
        
        $A.enqueueAction(action);
        
    },
    // Archive Assessment 
    archieveAssessment : function(selectedAssessment, onSuccess, onError, data, cmp, helper){
        helper.toggleSpinner(cmp);
        var action = cmp.get("c.archiveAssessment");
        action.setParams({
            "selAssessment" : selectedAssessment
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
                        
            if (cmp.isValid() && state === "SUCCESS") {
                var user = data.currentView;
                var assessmentTemplates = data.AssessmentListOnView[user];
                var index;
                for(var i = 0; i < assessmentTemplates.length; i++){
                    if(selectedAssessment.Id === assessmentTemplates[i].Id){
                        index = i; // find Index Position of Archive Assessment In Assessment List 
                        break;
                    }
                }
                assessmentTemplates.splice(index,1); // Splice Archive Assessmnet From Assessment List
                onSuccess(assessmentTemplates);
            }else if(cmp.isValid() && state === 'ERROR'){
                
                if(!onError){
                    helper.buildErrorMsg(cmp, helper, response.getError(), null);
                }else{
                    onError(response.getError());
                }
                
            }else if(cmp.isValid() && state === "INCOMPLETE"){
                helper.buildOffLineMsg(cmp, helper, null);
            }
            
            helper.toggleSpinner(cmp);
            
        });
        
        $A.enqueueAction(action);
    },
    
    getRecordById : function(param, onSuccess, onError, data, cmp, helper){
        helper.toggleSpinner(cmp);
        var action = cmp.get("c.getRecordById");
        action.setParams(param);
        action.setCallback(this, function(response) {
            var state = response.getState();
            
            if (cmp.isValid() && state === "SUCCESS") {
                data._Assessments[param.sObjectId] = JSON.parse(response.getReturnValue());
                onSuccess(JSON.parse(response.getReturnValue()));
            } else if(cmp.isValid() && state === "ERROR"){
                
                if(!onError){
                    helper.buildErrorMsg(cmp, helper, response.getError(), null);
                    
                }else{
                    onError(response.getError());
                }
                
            } else if(cmp.isValid() && state ==='INCOMPLETE'){
                helper.buildOffLineMsg(cmp, helper, null);
            }
            
            helper.toggleSpinner(cmp);
            
        });
        $A.enqueueAction(action);
        
    },
    getRecord : function(param, onSuccess, onError, data, cmp, helper){
        helper.toggleSpinner(cmp);
        var action = cmp.get("c.getRecord");
        action.setParams(param);
        action.setCallback(this, function(response) {
            var state = response.getState();
            
            if (cmp.isValid() && state === "SUCCESS") {
                data._Assessments[param.sObjectId] = JSON.parse(response.getReturnValue());
                onSuccess(JSON.parse(response.getReturnValue()));
            } else if(cmp.isValid() && state === "ERROR"){
                
                if(!onError){
                    helper.buildErrorMsg(cmp, helper, response.getError(), null);                    
                }else{
                    onError(response.getError());
                }
                
            }else if(cmp.isValid() && state === "INCOMPLETE"){
                helper.buildOffLineMsg(cmp, helper, null);
            }
            
            helper.toggleSpinner(cmp);
        });
        $A.enqueueAction(action);
        
    },
    updateRecord : function(param, onSuccess, onError, data, cmp, helper){
        helper.toggleSpinner(cmp);
        var action = cmp.get("c.updateRecord");
        action.setParams(param);
        action.setCallback(this, function(response) {
            var state = response.getState();
            
            if (cmp.isValid() && state === "SUCCESS") {
                var record = response.getReturnValue();
                var objWithFieldsAndAttachment = data._Assessments[record.Id];
                
                if(objWithFieldsAndAttachment){
                    
                    //if (record.Id === assessmentId) {
                        var objectKeys = Object.keys(record);
                        var fieldApi = objectKeys[1];
                        var assessmentTemp = objWithFieldsAndAttachment.sobject[0];
                        assessmentTemp[fieldApi] = record[fieldApi];
                        objWithFieldsAndAttachment.sobject[0] = assessmentTemp;
                        data._Assessments[record.Id] = objWithFieldsAndAttachment;
                        onSuccess(response.getReturnValue());
                    //}
                    
                }
                
            }else if(cmp.isValid() && state === "ERROR"){
                if(!onError){
                    helper.buildErrorMsg(cmp, helper, response.getError(), null);
                }else{
                    onError(response.getError());
                }
                
            }else if(cmp.isValid() && state === "INCOMPLETE"){
                helper.buildOffLineMsg(cmp, helper, null);
            }
            
            helper.toggleSpinner(cmp);
            
        });
        $A.enqueueAction(action);
        
    },
    updateAssessmentList : function(sobject, data, cmp){
        var assessmentId = sobject.Id;
        var user = data.currentView;
        var assessmentTempList = data.AssessmentListOnView[user];
        for(var i = 0; i < assessmentTempList.length; i++){
            
            if(assessmentTempList[i].Id === assessmentId){
                var objectKeys = Object.keys(sobject);
                var fieldApi = objectKeys[1];
                var assessmentRecord = assessmentTempList[i];
                assessmentRecord[fieldApi] = sobject[fieldApi];
                assessmentTempList[i] = assessmentRecord;
                data.AssessmentListOnView[user] = assessmentTempList;
                break;
            }
            
        }
    },
    createNewAssessment : function(param, onSuccess, onError, data, cmp, helper){
        helper.toggleSpinner(cmp);
        var user = data.currentView;
        param.selectView = user;
        var action = cmp.get("c.createAssessment");
        action.setParams(param);
        action.setCallback(this, function(response) {
            var state = response.getState();
            
            
            if (cmp.isValid() && state === "SUCCESS") {
                var assessment = response.getReturnValue();
                var assessemntTemplates = data.AssessmentListOnView[user];
                // New Assessment push In Assessment List 0th position
                assessemntTemplates.splice(0,0,assessment);
                helper.fireAssessmentEvent(cmp);
                onSuccess(assessment.Id);
            }else if(cmp.isValid() && state === "ERROR"){
                
                if(!onError){
                    helper.buildErrorMsg(cmp, helper, response.getError(), null); 
                }else{
                    
                    onError(response.getError());
                }
                
            }else if(cmp.isValid() && state === "INCOMPLETE"){
                helper.buildOffLineMsg(cmp, helper, null);
            }
            
            helper.toggleSpinner(cmp);
        });
        $A.enqueueAction(action);
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
    fireAssessmentEvent : function(cmp){
        var assessmentEvent = $A.get("e.c:fireAssessmentChangedEvt");
        assessmentEvent.fire();
    },
    setCurrentAssessmentContext : function(assessmentId, data){
        var user = data.currentView;
        var assessmentList = data.AssessmentListOnView[user];
        var currentAssessment;
        for(var i = 0; i < assessmentList.length; i++){
            if(assessmentList[i].Id === assessmentId){
                
                currentAssessment = assessmentList[i];
                break;
            }
        }
        data._currentAssessment = currentAssessment;
    },
    clearCurrentAssessmentContext : function(data){
        data._currentAssessment = {};
    },
    buildErrorMsg : function(cmp, helper, errors, time){
        var errorMsg = "";
        
        if(errors[0] && errors[0].message){  // To show other type of exceptions
            errorMsg = errors[0].message;
        }else if(errors[0] && errors[0].pageErrors.length) {  // To show DML exceptions
            errorMsg = errors[0].pageErrors[0].message; 
        }else if(errors[0] && errors[0].fieldErrors){  // To show field exceptions
            var fields = Object.keys(errors[0].fieldErrors);
            var field = fields[0];
            errorMsg = errors[0].fieldErrors[field];
            errorMsg = errorMsg[0].message;
        }else if(errors[0] && errors[0].duplicateResults.length){ // To show duplicateResults exceptions
            errorMsg = errors[0].duplicateResults[0].message;
        }else{
            errorMsg = "Unknown errors";
        }
            
        helper.showNotificationEvt(cmp, "error", errorMsg, time);
    },
    buildOffLineMsg : function(cmp, helper, time){
        var errorMsg = "No response from server or client is offline.";
        helper.showNotificationEvt(cmp, "error", errorMsg, time);
    },
    toggleSpinner : function(cmp){
        var spinner_container = cmp.find("spinner_container");
        $A.util.toggleClass(spinner_container, "slds-hide");
    },
    getAssessmentsBasedOnView : function(user, onSuccess, onError, data, cmp, helper){
        helper.toggleSpinner(cmp);
        var action = cmp.get("c.fetchAssessment");
        action.setParams({
            "selectView" : user
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            
            if (cmp.isValid() && state === "SUCCESS") {
                data.AssessmentListOnView[user] = response.getReturnValue();
                data.currentView = user;
                onSuccess(response.getReturnValue());
            }else if(cmp.isValid() && state === "ERROR"){
                
                if(!onError){
                    helper.buildErrorMsg(cmp, helper, response.getError(), null);
                }else{
                    onError(response.getError());
                }
                
            }else if(cmp.isValid() && state === "INCOMPLETE"){
                helper.buildOffLineMsg(cmp, helper, null);
            }
            
            helper.toggleSpinner(cmp);
            
        });
        
        $A.enqueueAction(action);
        
    },
    getLastModifiedOfCurrentAssessment : function(onSuccess, onError, data, cmp, helper){
        helper.toggleSpinner(cmp);
        var action = cmp.get("c.getLastModifiedOfCurrentAssessment");
        var currentAssessment = data._currentAssessment;
        action.setParams({
            "assessmentId" : currentAssessment.Id
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(cmp.isValid() && state === "SUCCESS"){
                var assessment = response.getReturnValue();
                var user = data.currentView;
                var assessmentTemplates = data.AssessmentListOnView[user];
                for(var index = 0; index < assessmentTemplates.length; index++){
                    if(assessmentTemplates[index].Id === assessment.Id){
                        assessmentTemplates[index] = assessment;
                        break;
                    }
                }
                data.AssessmentListOnView[user] = assessmentTemplates;
                onSuccess(assessmentTemplates);
            }else if(cmp.isValid() && state === "ERROR"){
                if(!onError){
                    helper.buildErrorMsg(cmp, helper, response.getError(), null);
                }else{
                    onError(response.getError());
                }
            }else if(cmp.isValid() && state === "INCOMPLETE"){
                helper.buildOffLineMsg(cmp, helper, null);
            }
            helper.toggleSpinner(cmp);
        });
        $A.enqueueAction(action);
        
    }
})