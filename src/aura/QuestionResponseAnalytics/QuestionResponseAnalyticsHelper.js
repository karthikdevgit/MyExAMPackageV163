({
	showRecords : function(cmp, event, helper, startIndex, endIndex){
        var noOfRecordPerPage = 10;
        var noOfQuestions = cmp.get("v.lengthOfQuestionsResponse");
        var max = Math.ceil(noOfQuestions / noOfRecordPerPage);
        cmp.set("v.max", max);
        
        var questionTemp = [];
        var lastIndex = noOfQuestions-1;
        
        if(lastIndex<endIndex){
            endIndex = lastIndex;
        }
        var totalQuestionsViewer = cmp.get("v.totalQuestionsResponse") || [];
        
        if(endIndex > totalQuestionsViewer.length -1){
            helper.getQuestionResponse(cmp, event, helper);
        }else{
            
            for(var i = startIndex; i <= endIndex; i++){
                
                if(totalQuestionsViewer[i]){
                    questionTemp.push(totalQuestionsViewer[i]);
                }
                
            }
            cmp.set("v.currentQuestionsResponse", JSON.parse(JSON.stringify(questionTemp)));
        }
        
        
    },
    getQuestionResponse : function(cmp, event, helper){
        var spinner_container = cmp.find("spinner_container");
        $A.util.toggleClass(spinner_container, "slds-hide");
        var startPage = cmp.get("v.currentPage");
        var action = cmp.get("c.getAnswerResponseWithCount");
        action.setParams({
            "assessmentId" : cmp.get("v.assessmentId"),
            "offset" : ((startPage-1)*10)
        });
        action.setCallback(this, function(response){
            $A.util.toggleClass(spinner_container, "slds-hide");
            var state = response.getState();
            
            if(state === "SUCCESS"){
                var lengthAndViewerQuestionResponse = response.getReturnValue();
                var currentQuestionsResponse = lengthAndViewerQuestionResponse.questions;
                var lengthOfQuestionsResponse = lengthAndViewerQuestionResponse.noOfQuestions;
                cmp.set("v.lengthOfQuestionsResponse", lengthOfQuestionsResponse);
                
                var totalQuestionsResponse = cmp.get("v.totalQuestionsResponse") || [];
                
                var max = Math.ceil(lengthOfQuestionsResponse / 10);
                cmp.set("v.max", max);
                
                totalQuestionsResponse = totalQuestionsResponse.concat(currentQuestionsResponse);
                cmp.set("v.totalQuestionsResponse", totalQuestionsResponse);
                cmp.set("v.currentQuestionsResponse", currentQuestionsResponse);
            }else if(state === "ERROR"){
                helper.buildErrorMsg(cmp, response.getError(), null, helper);
                
            }else if(state === "INCOMPLETE"){
                helper.buildOffLineMsg(cmp, helper, null);
            }
            
        });
        $A.enqueueAction(action);
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
    showNotificationEvt : function(cmp, status, message, time){
        var showNotificationEvent = $A.get("e.c:notificationEvt");
        showNotificationEvent.setParams({
            "action" : status,
            "message" : message,
            "time" : time
        });
        showNotificationEvent.fire();
    }
})