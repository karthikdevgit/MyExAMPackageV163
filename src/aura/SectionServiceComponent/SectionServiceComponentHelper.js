({
    fetchSecTemplateWthFldSet : function(param, onSuccess, onError, sectionByAssessment, cmp, helper){
        
        helper.toggleSpinner(cmp);
        var action = cmp.get("c.fetchSecTemplateWthSectionFieldSetValue");
        action.setParams(param);
        action.setStorable();
        action.setCallback(this, function(response) {
            var state = response.getState();
            helper.toggleSpinner(cmp);
            
            if (cmp.isValid() && state === "SUCCESS") {
                var ObjContainFields = JSON.parse(response.getReturnValue());                
                var sectionTemplates = ObjContainFields.sobject;
                sectionByAssessment._Sections[param.sObjectId] = sectionTemplates;
                
                if(ObjContainFields.fields){
                    sectionByAssessment._Fields = ObjContainFields.fields;
                }
                
                onSuccess(sectionTemplates);
                
            } else if(cmp.isValid() && state === "ERROR"){
                
                if(!onError){
                    helper.buildErrorMsg(cmp, response.getError(), null, helper);
                }else{
                    onError(response.getError());
                }
                
            }else if(cmp.isValid() && state === "INCOMPLETE"){
                helper.buildOffLineMsg(cmp, helper, null);
            }
            
        });
        $A.enqueueAction(action);
    },
    fetchSecTemplate : function(assessmentId, onSuccess, onError, sectionByAssessment, cmp, helper) {
        helper.toggleSpinner(cmp);
        var action = cmp.get("c.fetchSecTemplate");
        action.setParams({
            "assessementId": assessmentId
        });
        //action.setStorable();
        action.setCallback(this, function(response) {
            var state = response.getState();
            
            if (cmp.isValid() && state === "SUCCESS") {
                sectionByAssessment._Sections[assessmentId] = response.getReturnValue();
                onSuccess(response.getReturnValue());
            }else if(cmp.isValid() && state === "ERROR"){
                
                if(!onError){
                    helper.buildErrorMsg(cmp, response.getError(), null, helper);
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
    moveSectionUpOrDwn : function(param, onSuccess, onError, sectionByAssessment, cmp, helper){
        helper.toggleSpinner(cmp);
        var assessmentId = param.assessmentId;
        var action = cmp.get("c.moveSectionUpOrDwn");
        var direction = param.direction;
        var index = param.index;
        action.setParams(param);
        action.setCallback(this, function(response) {
            var state = response.getState();
            
            if (cmp.isValid() && state === "SUCCESS") {
                var sectionTemplates = response.getReturnValue();
                var changeElement = sectionTemplates[index];
                
                if(direction === 'up'){
                    sectionTemplates.splice(index, 1);
                    sectionTemplates.splice(index-1, 0, changeElement);
                }
                if(direction === 'down'){
                    sectionTemplates.splice(index, 1);
                    sectionTemplates.splice(index+1, 0, changeElement);
                }
                sectionByAssessment._Sections[assessmentId] = sectionTemplates;
                helper.fireSectionChangedEvt(assessmentId, true);
                onSuccess();
            }else if(cmp.isValid() && state === "ERROR"){
                
                if(!onError){
                    helper.buildErrorMsg(cmp, response.getError(), null, helper);
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
    createSection : function(param, onSuccess, onError, sectionByAssessment, cmp, helper){
        helper.toggleSpinner(cmp);
        var section = param.SectionTemplate;
        var assessmentId = section.ExAM__Questionnaire_Section__c;
        var sectionId = section.Id;
        var action = cmp.get("c.createSection");
        action.setParams(param);
        action.setCallback(this, function(response) {
            var state = response.getState();
            
            if (cmp.isValid() && state === "SUCCESS") {
                sectionByAssessment._Sections[assessmentId] = response.getReturnValue();
                helper.fireSectionChangedEvt(assessmentId, true);
                onSuccess();
            }else if(cmp.isValid() && state === "ERROR"){
                
                if(!onError){
                    helper.buildErrorMsg(cmp, response.getError(), null, helper);
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
    archiveSection : function(param, onSuccess, onError, sectionByAssessment, cmp, helper){
        helper.toggleSpinner(cmp);
        var assessmentId = param.assessmentId;
        var sectionTemplates = sectionByAssessment._Sections[assessmentId];
        var index;//= sectionTemplates.indexOf(sectionTemplate);
        var action = cmp.get("c.archiveSection");
        
        action.setParams(param);
        action.setCallback(this, function(response) {
            var state = response.getState();
            helper.toggleSpinner(cmp);
            
            if (cmp.isValid() && state === "SUCCESS") {  
                for(var i = 0; i < sectionTemplates.length; i++){
                    if(param.sectionId === sectionTemplates[i].Id){
                        index = i;
                        break;
                    }
                }
                sectionTemplates.splice(index,1);   
                sectionByAssessment._Sections[assessmentId] = sectionTemplates;
                helper.fireSectionChangedEvt(assessmentId, true);
                onSuccess();
            }else if(cmp.isValid() && state === "ERROR"){
                
                if(!onError){
                    helper.buildErrorMsg(cmp, response.getError(), null, helper);
                }else{
                    onError(response.getError());
                }
                
            }else if(cmp.isValid() && state === "INCOMPLETE"){
                helper.buildOffLineMsg(cmp, helper, null);
            }
            
        });
        $A.enqueueAction(action);
    },
    
    moveSection : function(param, onSuccess, onError, sectionByAssessment, cmp, helper){
        helper.toggleSpinner(cmp);
        var newAssessmentId = param.newAssessmentId;
        var oldAssessmentId = param.oldAssessmentId;
        var action = cmp.get("c.moveSection");
        action.setParams(param);
        action.setCallback(this, function(response){
            var state = response.getState();
            
            if(cmp.isValid() && state==="SUCCESS"){
                var oldtoNewSectionTemplates = response.getReturnValue();
                sectionByAssessment._Sections[oldAssessmentId] = oldtoNewSectionTemplates.formSectionTemplate;
                
                if(newAssessmentId){
                    sectionByAssessment._Sections[newAssessmentId] = oldtoNewSectionTemplates.toSectionTemplate;
                }
                
                helper.fireSectionChangedEvt(oldAssessmentId, false);
                onSuccess();
                
            }else if(cmp.isValid() && state === "ERROR"){
                
                if(!onError){
                    helper.buildErrorMsg(cmp, response.getError(), null, helper);
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
    copySection : function(param, sectionIndex, onSuccess, onError, sectionByAssessment, cmp, helper){
        helper.toggleSpinner(cmp);
        var assessmentId = param.toassessmentId;
        var index = sectionIndex;
        var direction = param.direction;
        var action = cmp.get("c.copySection");
        action.setParams(param);
        action.setCallback(this, function(response){
            var state = response.getState();
            
            if(cmp.isValid() && state === "SUCCESS"){
                var responseMap = response.getReturnValue();
                var newSectionTemplates =  responseMap.copySection;
                var newQuestionTemplates = responseMap.copyQuestion;
                var newAnswerOptions = responseMap.answerOptions;
                var newAttachmentTemplates = responseMap.copyAttachment;
                var newAttachmentTemplatesByQues = responseMap.cloneAttachmentsByQuestion;
                var newAttachmentOfImageQuestion = responseMap.cloneImageQuestion;
                
                for(var i = 0; i < newQuestionTemplates.length; i++){
                    var answerOptions = [];
                    for(var j = 0; j < newAnswerOptions.length; j++){
                        if(newQuestionTemplates[i].Id === newAnswerOptions[j].ExAM__Question_Template__c){
                            answerOptions.push(newAnswerOptions[j]);
                        }
                    }
                    if(answerOptions.length){
                        window.Exam.AnswerServiceComponent.storeAnswersByQuestion(newQuestionTemplates[i].Id, answerOptions);
                    }
                }
                
                
                
                for(var i = 0; i < newQuestionTemplates.length; i++){
                    for(var j = 0; j < newAttachmentOfImageQuestion.length; j++){
                        if(newQuestionTemplates[i].Id === newAttachmentOfImageQuestion[j].ParentId){
                            window.Exam.AttachmentServiceComponent.storeQuestionImage(newQuestionTemplates[i].Id, newAttachmentOfImageQuestion[j]);
                            break;
                        }
                    }
                }
                
                
                if(newSectionTemplates.length === 1){
                    index = 0;
                }else{
                    if(direction === 'After'){
                        index++;
                    }else{
                        index;
                    }
                    
                }
                
                sectionByAssessment._Sections[assessmentId] = newSectionTemplates;
                var newCopySectionId = newSectionTemplates[index].Id;
                
                window.Exam.QuestionServiceComponent.updateQuestionTemplate(newCopySectionId, newQuestionTemplates);
                
                for(i = 0; i < newAttachmentTemplates.length; i++){
                    var parentId = newAttachmentTemplates[i].parentId;
                    window.Exam.AttachmentServiceComponent.updateAttachment(parentId, newAttachmentTemplates[i]);
                }
                
                for(i = 0; i < newQuestionTemplates.length; i++){
                    var attachments = [];
                    for(j = 0; j < newAttachmentTemplatesByQues.length; j++){
                        
                        if(newQuestionTemplates[i].Id === newAttachmentTemplatesByQues[j].parentId){
                            attachments.push(newAttachmentTemplatesByQues[j]);
                        }
                        
                    }
                    
                    if(attachments.length){
                        
                        window.Exam.AttachmentServiceComponent.updateAttachment(newQuestionTemplates[i].Id, attachments);
                    }
                }
                helper.fireSectionChangedEvt(assessmentId, false);
                onSuccess();
            }else if(cmp.isValid() && state === "ERROR"){
                
                if(!onError){
                    helper.buildErrorMsg(cmp, response.getError(), null, helper);
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
    updateRecord : function(param, onSuccess, onError, questionBySection, cmp, helper){  
        helper.toggleSpinner(cmp);
        var action = cmp.get("c.updateRecord");
        action.setParams(param);
        action.setCallback(this, function(response) {
            var state = response.getState();
            
            if (cmp.isValid() && state === "SUCCESS") {
                onSuccess(response.getReturnValue());
            }else if(cmp.isValid() && state === "ERROR"){
                if(!onError){
                    helper.buildErrorMsg(cmp, response.getError(), null, helper);
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
    fireSectionChangedEvt : function(assessmentId, isExpand){
        var changeAssessmentTemp = $A.get("e.c:fireAssessmentChanged");
        changeAssessmentTemp.setParams({
            "assessmentId" : assessmentId,
            "isExpand" : isExpand
        });
        changeAssessmentTemp.fire();
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
    buildErrorMsg : function(cmp, errors, time, helper){
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
    }
})