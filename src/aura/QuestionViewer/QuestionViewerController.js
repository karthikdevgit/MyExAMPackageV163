({
    doInit : function(cmp, event, helper) {
        console.log("DoInit of Questions");
        var question = cmp.get("v.QuestionTemplate");
        var questionId = question.Id;
		
        window.Exam.QuestionServiceComponent.fetchFieldSet($A.getCallback(function(fields){
            if(cmp.isValid()){
                cmp.set("v.fields", fields);

                if(questionId){
                    
                    window.Exam.AttachmentServiceComponent.getQuestionImage(questionId, $A.getCallback(function(attachment){    
                        if(cmp.isValid()){
                            if(Array.isArray(attachment)){
                                attachment = attachment[0];
                            }
                            cmp.set("v.questionImageAttachment", attachment);
                            cmp.set("v.showAttachment", true);
                            
                            window.Exam.AnswerServiceComponent.getAnswerOptions(questionId, $A.getCallback(function(answerOptions){
                                if(cmp.isValid()){
                                    question.ExAM__Answer_Options__r =  answerOptions;
                                    cmp.set("v.QuestionTemplate", question);
                                }                        
                            }), null);
                            helper.createOptionsCmp(cmp, event, helper, true);
                        }
                        
                    }), null);
                }

                var QuestionTypes = window.Exam.QuestionTypeServices(cmp).getQuestionTypes();
                cmp.set("v.questionTypes", QuestionTypes);
                cmp.set("v.showPick", true);
                

            }
        }), null);

    },
    toggleAnswerDetails : function(cmp, event, helper) {
        if(cmp.get("v.editAnswers")){
            var additionOpt = cmp.find("additionOpt");
            if(additionOpt){
                var captureWindow = additionOpt.get("v.captureWindow");
                var showBtn = additionOpt.get("v.showBtn");
                if(captureWindow){
                    helper.showNotificationEvt(cmp, event, "error", "cancel Capture window", null);
                    return;
                }else if(showBtn){
                    helper.showNotificationEvt(cmp, event, "error", "Please save your changes before continuing.", null);
                    return;
                }
            }
        }
      cmp.set("v.editAnswers", !cmp.get("v.editAnswers"));
    },
    changeTemplateAction : function(cmp, event, helper) {
        var nextCmp = event.getParam("componentLink");
        event.stopPropagation();
        var questionTemplates =  cmp.get("v.QuestionTemplate");
        var fields = cmp.get("v.fields");
        var templateActions = cmp.find("templateActions");
        var additionalActions = cmp.find("additionalActions");
        templateActions.set("v.body", []);
        additionalActions.set("v.body", []);
        
        var attributes = {
            "fields": fields,
            "QuestionTemplate": questionTemplates,
            "questionTypes": window.Exam.QuestionTypeServices(cmp).getQuestionTypes(),
            "assessmentId": cmp.get("v.assessmentId"),
            "index": cmp.get("v.index"),
            "defaultMode" : "view",
            "mode" : 'edit'
        };
        
            var uiCmps = [];

            nextCmp = "ExAM:" + nextCmp;

            var uiCmp = [
                nextCmp,
                attributes
            ];
            uiCmps.push(uiCmp);
            helper.createComponents(cmp, event, helper, uiCmps);
       

    },
    reloadContent : function(cmp, event, helper) {
        var sobject = event.getParam("sObject");
        var question = cmp.get("v.QuestionTemplate");
        
        if (sobject.Id === question.Id) {
            event.stopPropagation();
            var sectionId = question.ExAM__Section_Question__c;
            var objectKeys = Object.keys(sobject);
            var fieldApi = objectKeys[1];
            question[fieldApi] = sobject[fieldApi];
            if(fieldApi === "ExAM__Question_Type__c"){
                var answerTemp = cmp.find("answerTemp");
                
                if(sobject[fieldApi] !== 'Dropdown Picklist' ||
                   sobject[fieldApi] !== 'RadioPicklist' || 
                   sobject[fieldApi] !== 'Button' ||
                   sobject[fieldApi] !== 'MultiselectPicklist' || 
                   sobject[fieldApi] !== 'List' ||
                   sobject[fieldApi] !== 'Image' ||
                   sobject[fieldApi] !== 'Horizontal Radiopicklist'){
                    
                    if(cmp.get("v.editAnswers")){
                        cmp.set("v.editAnswers", false);
                    }
                    
                }  
                
                if(answerTemp){
                    answerTemp.doInitMethod();
                }
            }
            cmp.set("v.QuestionTemplate", JSON.parse(JSON.stringify(question)));
        }
    },
    updateAnswer : function(cmp, event, helper) {
        var answerOptions = event.getParam("answerOptions");
        
        var questionId = answerOptions.AnswerOptions[0].ExAM__Question_Template__c;
        var questionTemplate = cmp.get("v.QuestionTemplate");
        
        if (questionId === questionTemplate.Id) {
            event.stopPropagation();
            

            if (questionTemplate.ExAM__Question_Type__c === 'Image') {
                var isFileUpload = event.getParam("isFileUpload");
                var fileContentMap = event.getParam("fileContentMap");
                cmp.set("v.isFileUpload", isFileUpload);
                cmp.set("v.fileContentMap",fileContentMap);
                helper.getFileContentList(cmp, fileContentMap);
                
                var imageSrc = cmp.find("answerTemp").get("v.imageSrc");
                var removedIndices = event.getParam("removedIndices");
                
                if(removedIndices){
                    for(var i = 0; i < removedIndices.length; i++){
                        imageSrc.splice(removedIndices[i], 1);
                    }
                }
                
                cmp.set("v.imageSrc", imageSrc);
            }

            if (isFileUpload) {
                helper.updateImage(cmp, event, answerOptions.AnswerOptions, helper);
            }

        }
    },
    deleteQuestion : function(cmp, event, helper) {
        event.stopPropagation();
        var hasConfirm = event.getParam("hasConfirm");
        
        var templateActions = cmp.find("templateActions");
        templateActions.set("v.body", []);
        if (hasConfirm) {
            var Question = cmp.get("v.QuestionTemplate");
            var status, message, time;
            window.Exam.QuestionServiceComponent.deleteQuestion(Question, $A.getCallback(function() {
                
                if(cmp.isValid()){
                    status = "success";
                    time = 5000;
                    message = Question.ExAM__Question_Label__c + " has been deleted";
                    helper.showNotificationEvt(cmp, event, status, message, time);
                }
                
            }), null);

        }else{
            helper.navigateOption(cmp, event, helper);
        }
    },
    saveQuestion : function(cmp, event, helper) {
        var additionOpt = cmp.find("additionOpt");
        var hasDependent = false;
        if(additionOpt){
            var captureWindow = additionOpt.get("v.captureWindow");
            if(!additionOpt.get("v.hasDependentQuestion") && additionOpt.get("v.hasNextQuestion") ||
              additionOpt.get("v.hasDependentQuestion") && !additionOpt.get("v.hasNextQuestion")){
                hasDependent = true;
            }
            if(captureWindow){
                helper.showNotificationEvt(cmp, event, "error", "cancel Capture window", null);
                return;
            }
        }
        
        var questionTemplate = cmp.get("v.QuestionTemplate");
        var questionName = questionTemplate.ExAM__Question_Label__c;
        var type = questionTemplate.ExAM__Question_Type__c;
        if(!type || type == "--None--"){
            var status = "warning";
            var message = "Please select a Question type";
            var time = 5000;
            helper.showNotificationEvt(cmp, event, status, message, time);
            return;
        }
        if(!questionName.trim()){
            var status = "warning";
            var message = "Please enter a Question name";
            var time = 5000;
            helper.showNotificationEvt(cmp, event, status, message, time);
            return;
        }
        
        var answerOptions = [];
        var serverAction = {};
        serverAction.allow = true;
        if (type === 'Dropdown Picklist' ||
            type === 'RadioPicklist' ||
            type === 'Button' ||
            type === 'MultiselectPicklist' ||
            type === 'List' ||
            type === 'Image' ||
            type === 'Horizontal Radiopicklist') {
              var additionOpt = cmp.find("additionOpt");
              answerOptions = additionOpt.get("v.answerOptions");            
              var questionOptions = cmp.find("questionOptions");
              additionOpt = cmp.find("additionOpt");

            questionOptions = questionOptions.get("v.fields");
           
            serverAction = helper.validateQuestionWthAnswer(cmp, event, helper, answerOptions, type, serverAction);
            
        }
        if(serverAction.allow){
            helper.saveQuestion(cmp, event, helper, questionTemplate, answerOptions, questionOptions, hasDependent);
        }else{
            helper.showNotificationEvt(cmp, event,'error', serverAction.msg, null);
        }
        
    },
    closeModal: function(cmp, event, helper) {
        var position = cmp.get("v.position");
        helper.closeModal(cmp, event, helper, position);

    },
    editQuestionTemplate: function(cmp, event, helper) {
        var index = cmp.get("v.index");
        var QuestionSelected = cmp.getEvent("QuestionSelected");
        QuestionSelected.setParams({
            "index": index
        })
        QuestionSelected.fire();

    },
    changeAnswerTemplates : function(cmp, event, helper){
        var questionId = event.getParam("questionId");
        var question = cmp.get("v.QuestionTemplate");
       
        if(questionId === question.Id){
            
            window.Exam.AnswerServiceComponent.getAnswerOptions(questionId, $A.getCallback(function(answerOptions){
                if(cmp.isValid()){
                    question.ExAM__Answer_Options__r =  answerOptions;
                    cmp.set("v.QuestionTemplate",question);
                    helper.createOptionsCmp(cmp, event, helper, false);
                }
            }));
        }
    },
    navigateOption : function(cmp, event, helper){
        helper.navigateOption(cmp, event, helper);
    },
    
    // find which Question comes to edit state  
    toggleQuestionInLineEditView : function(cmp, event, helper){
        var state = event.getParam("state");
        var Id = event.getParam("Id");
        var question = cmp.get("v.QuestionTemplate");
        
        if(Id === question.Id){
            var toggleViewContent = cmp.get("v.toggleViewContent");
            var sectionId = question.ExAM__Section_Question__c;
            event.stopPropagation();
            var editCount = cmp.get("v.editCount") || 0;
            var fieldName = event.getParam("fieldName");
            if(state === "enableView"){			
                editCount--;			// whenever state is enableview decrement editCount
                if(editCount === 0 && !cmp.get("v.canSwitchTab")){	 
                    cmp.set("v.canSwitchTab", true);		// able to switch other tab
                    toggleViewContent["isQuestionEdited"] = false; // the question template come view State
                    var sourceDrivenCmp = event.getParam("sourceDrivenCmp");
                    
                    if(fieldName == "ExAM__Question_Type__c"){
                        toggleViewContent["questionTypeEnabled"] = false;
                    }else if(sourceDrivenCmp == "answerOptionsViewer"){
                        toggleViewContent["answerOptionsViewerEdited"] = false;
                    }
                    cmp.set("v.toggleViewContent", toggleViewContent);
                    helper.fireToggleEditView(cmp, sectionId, "doneEditingView"); // inform to its parent whether i change view state
                }
            }else{
                editCount++;	// whenever state is disable increment editCount
                if(editCount === 1 && cmp.get("v.canSwitchTab")){
                    cmp.set("v.canSwitchTab", false);	// unable to switch other tab
                    toggleViewContent["isQuestionEdited"] = true;	//the question template come edit State
                    var sourceDrivenCmp = event.getParam("sourceDrivenCmp");
                    
                    if(fieldName == "ExAM__Question_Type__c"){
                        toggleViewContent["questionTypeEnabled"] = true;
                    }else if(sourceDrivenCmp == "answerOptionsViewer"){
                        toggleViewContent["answerOptionsViewerEdited"] = true;
                    }
                    
                    cmp.set("v.toggleViewContent", toggleViewContent);
                    helper.fireToggleEditView(cmp, sectionId, "editViewOn");	// inform to its parent whether i change edit state
                }
            }
            cmp.set("v.editCount", editCount);
        }
    },
    //  Copy / Move Question Editing Done
    questionEditingDone : function(cmp, event, helper){
        var Id = event.getParam("Id");
        var question = cmp.get("v.QuestionTemplate");
        if(Id === question.Id){
            event.stopPropagation();
            var toggleViewContent = cmp.get("v.toggleViewContent");
            toggleViewContent["isQuestionEdited"] = false
            cmp.set("v.toggleViewContent", toggleViewContent);
            cmp.set("v.canSwitchTab", true);
            cmp.set("v.hasSwitchTab", false);
            helper.fireToggleEditView(cmp, question.ExAM__Section_Question__c, "doneEditingView");
        }
    }
})