({
    showAnswerDetails: function(cmp, event, helper) {
    },
    // perform Function based on Action
    getAction: function(cmp, event, helper) {
        var action = event.getParam("action");
        if(action === "showAnswerForEdit" || action === "removeOption"){
            event.stopPropagation();
            var itemIndex = event.getParam("itemIndex");
            cmp.set("v.itemIndex",itemIndex);    
            
            if (action === "showAnswerForEdit") {
                helper.showAnswerForEdit(cmp, event, helper);
            } else if (action === "removeOption") {
                helper.showActionBtn(cmp, event, helper);
                helper.removeOption(cmp, event, helper);
            }
        }
    },
    // build new Answer Option 
    newAnswer: function(cmp, event, helper) {
        if (cmp.get("v.captureWindow")) {
            helper.showNotificationEvt("warning", "Save Answer Before Proceeding", 5000);
            return;
        }
        helper.resetAnswerOption(cmp);
        
        var addNewLink = cmp.find("addNewLink");
        if(!$A.util.hasClass(addNewLink, 'slds-hide')){
            $A.util.addClass(addNewLink, 'slds-hide');
        }
        var selectedQuestion = {
            'labelOfNextQues' : '--None--',
            'labelOfDependentQues' : '--None--'
        };
        cmp.set("v.selectedQuestion", selectedQuestion);
        cmp.set("v.captureWindow", true);
        helper.toggleEditView(cmp, "disableView", cmp.get("v.QuestionTemplate").Id);
        cmp.set("v.itemIndex", cmp.get("v.answerOptions").length);
        
        var updateOptionBtn = cmp.find("updateOption");
        var newOptionBtn = cmp.find("newOption");
        
        if (!$A.util.hasClass(updateOptionBtn, "slds-hide")) {
            $A.util.addClass(updateOptionBtn, "slds-hide");
        }
        
        if ($A.util.hasClass(newOptionBtn, "slds-hide")) {
            $A.util.removeClass(newOptionBtn, "slds-hide");
        }
      
        
        if(cmp.get("v.QuestionTemplate").ExAM__Question_Type__c === "Image"){
            var indexWthImageMap = {};
            indexWthImageMap["attachmentId"] = '';
            indexWthImageMap["fileName"] = 'No file';
            indexWthImageMap["fileContent"] = {'fileContents' : ''};
            cmp.set("v.indexWthImageMap", indexWthImageMap);
        }
        
    },
    
    addAnswer: function(cmp, event, helper) {
        
        var answerOption = cmp.get("v.answerOption");  
        var answerOptionName = answerOption.Name;
        if (!answerOptionName.trim()) {
            helper.showNotificationEvt("warning", "Enter Answer Text Before Saving", 5000);
        } else {
            var type = cmp.get("v.QuestionTemplate").ExAM__Question_Type__c;
            if(type === 'Image'){
                var fileName = cmp.find("fileUploaded").get("v.indexWthImageMap").fileName;;
                if(fileName === 'No file'){
                    helper.showNotificationEvt("warning", "Answer must have an attachment", 5000);
                    return;
                }
                
            }
            helper.showActionBtn(cmp, event, helper);
            
            var answerOptions = cmp.get("v.answerOptions");
            answerOption.ExAM__Question_Template__c = cmp.get("v.QuestionTemplate").Id || 
                null;
            answerOption.ExAM__Order_No__c = answerOptions.length + 1;
            
            if (answerOption.ExAM__Next_Question__r.Id) {
                answerOption.ExAM__Next_Question__c = answerOption.ExAM__Next_Question__r.Id;
                cmp.set("v.hasNextQuestion", true);
            }
            if (answerOption.ExAM__Dependent_Question__r.Id) {
                answerOption.ExAM__Dependent_Question__c = answerOption.ExAM__Dependent_Question__r
                .Id;
                cmp.set("v.hasDependentQuestion", true);
            }
            
            answerOptions.push(answerOption);
            cmp.set("v.answerOptions", answerOptions);
            helper.closeOption(cmp, event, helper);
            
        }
    },
    doInit: function(cmp, event, helper) {
        
        var questionTemplate = cmp.get("v.QuestionTemplate");
        var sectionId = questionTemplate.ExAM__Section_Question__c;
        var questionId = questionTemplate.Id;
        
        window.Exam.QuestionServiceComponent.getQuestionsBySectionId(sectionId, questionId, $A.getCallback(function(questions){
            
            cmp.set("v.menuItems", questions);
            var type = questionTemplate.ExAM__Question_Type__c;
            var answerOptions = JSON.parse(JSON.stringify(cmp.get("v.answerOptionsFrmQuestion"))) || []; // avoid Data binding of original list of parent
            var hasDependentQuestion = false
            var hasNextQuestion = false
            var answerOptionsIds = [];
            var nextQuestions = [],
                dependentQuestions = [],
                weightofAnswerOptions = [],
                attachmentNames = [];
            
            if (answerOptions.length) {
                helper.setReference(answerOptions, nextQuestions, dependentQuestions, answerOptionsIds);
                
                cmp.set("v.answerOptions", answerOptions);
                
                helper.showDependentAndNextQuestionView(cmp, nextQuestions,
                                                        dependentQuestions);
                
                if(type === "Image"){
                    var param = {
                        "answerOptionsId" : answerOptionsIds
                    };
                    helper.generateFileContentMap(cmp, event, helper, param);
                }else{
                    helper.defineOriginalInstance(cmp, event, helper);
                }       
                
                
            } else if (!answerOptions.length) {
                var answer = questionTemplate.ExAM__Subquestion_Label__c;
                
                if (answer) {
                    cmp.set("v.derivedFromQuestion", true);
                    
                    var nextQuestion = questionTemplate.ExAM__Next_Question__c;
                    var dependentQuestion = questionTemplate.ExAM__Dependent_Question__c;
                    var weight = questionTemplate.ExAM__Weight_of_Answer__c;
                    var dependencyQuestionsName = [];
                    
                    if (nextQuestion) {
                        nextQuestions = nextQuestion.split('~');
                        dependencyQuestionsName = nextQuestions;
                        cmp.set("v.hasDependentQuestion", false);
                        
                    } else if (dependentQuestion) {
                        dependentQuestions = dependentQuestion.split('~');
                        dependencyQuestionsName = dependentQuestions;
                        cmp.set("v.hasNextQuestion", false);
                    }
                    
                    if (weight) {
                        weightofAnswerOptions = weight.split('~');
                    }
                    
                    if(dependencyQuestionsName.length){
                        window.Exam.QuestionServiceComponent.getdependencyQuestionLabel(dependencyQuestionsName, $A.getCallback(function(dependencyQuestions){
                            helper.convertLegacyToNewInternally(cmp, event, helper, answer, questionTemplate.Id, type, 
                                                                dependentQuestions, nextQuestions, weightofAnswerOptions, 
                                                                answerOptions, dependencyQuestions);
                        }), null);
                    }else{         
                        helper.convertLegacyToNewInternally(cmp, event, helper, answer, questionTemplate.Id, type, 
                                                            dependentQuestions, nextQuestions, weightofAnswerOptions, 
                                                            answerOptions, []);
                    }
                    
                } else {
                    cmp.set("v.answerOptions", []);
                    helper.defineOriginalInstance(cmp, event, helper);
                }
                
            }
        }));
    },
    
    updateOption: function(cmp, event, helper) {
        var answerOption = cmp.get("v.answerOption");
        
        var answerOptionName = answerOption.Name;
        if(!answerOptionName.trim()){
            helper.showNotificationEvt("warning", "Enter Answer Text Before updating", 5000);
            return;
        }
        cmp.set("v.hasUpdate", true);
        helper.showActionBtn(cmp, event, helper);
        var answerOptions = cmp.get("v.answerOptions");
        
        
        var index = cmp.get("v.indexPos");
        
        if(answerOption.ExAM__Next_Question__r){
            answerOption.ExAM__Next_Question__c = answerOption.ExAM__Next_Question__r.Id;
            answerOption.ExAM__Dependent_Question__c = answerOption.ExAM__Dependent_Question__r.Id;  
        }
        
        
        answerOptions[index] = JSON.parse(JSON.stringify(answerOption));
        
        
        
        for (var i = 0; i < answerOptions.length; i++) {
            
            if (answerOptions[i].ExAM__Next_Question__r && answerOptions[i].ExAM__Next_Question__r.Id) {
                cmp.set("v.hasNextQuestion", true);
                break;
            } else if (answerOptions[i].ExAM__Dependent_Question__r && answerOptions[i].ExAM__Dependent_Question__r.Id) {
                cmp.set("v.hasDependentQuestion", true);
                break;
            }
            
        }
        
        cmp.set("v.answerOptions", JSON.parse(JSON.stringify(answerOptions)));
        helper.closeOption(cmp, event, helper);
    },
    
    upsertAnswers: function(cmp, event, helper) {
        if (cmp.get("v.captureWindow")) {
            helper.showNotificationEvt("error", "cancel Capture window", null);
            return;
        }
        var answerOptions = JSON.parse(JSON.stringify(cmp.get("v.answerOptions")));
        var serverAction = helper.validateQuestionWthAnswer(cmp, event, helper, answerOptions);   
        
        if(serverAction.allow){
            
            var questionTemplate = cmp.get("v.QuestionTemplate");
            if(questionTemplate.ExAM__Question_Type__c === "Image"){
                var fileContentMap =  cmp.get("v.fileContentMap");
                var indexWthImageMapList = Object.keys(fileContentMap);//cmp.get("v.fileNames");
                var attachmnentIdCount = 0;
                for(var i = 0; i < indexWthImageMapList.length; i++){
                    if(fileContentMap[i].attachmentId) {
                        attachmnentIdCount++;
                    } 
                }
                if(attachmnentIdCount === indexWthImageMapList.length){
                    cmp.set("v.isFileUpload", false);
                }
            }
            var sectionId = questionTemplate.ExAM__Section_Question__c;
            
            var removedAnswerIds = cmp.get("v.removedAnswerIds");
            
            for (var i = 0; i < answerOptions.length; i++) {
                if (answerOptions[i].ExAM__Next_Question__r) {
                    delete answerOptions[i].ExAM__Next_Question__r;
                }
                if (answerOptions[i].ExAM__Dependent_Question__r) {
                    delete answerOptions[i].ExAM__Dependent_Question__r;
                }
            }
            var param = {
                "answerOptions": JSON.stringify(answerOptions),
                "removeOptionIds": removedAnswerIds,
                "removedOptionIndices": cmp.get("v.removedOptionIndices"),
                "derivedFromQuestion": cmp.get("v.derivedFromQuestion")
            };
            
            window.Exam.AnswerServiceComponent.upsertAnswerOption(param, sectionId, $A.getCallback(
                function(answers) {
                    
                    if (cmp.isValid()) {
                        
                        var nextQuestions = [],
                            dependentQuestions = [],
                            answerOptionsIds = [];
                        answerOptions = answers.AnswerOptions;
                        helper.setReference(answerOptions, nextQuestions, dependentQuestions, answerOptionsIds);
                        helper.showDependentAndNextQuestionView(cmp, nextQuestions,
                                                                dependentQuestions);
                        cmp.set("v.answerOptions", answerOptions);
                        cmp.set("v.hasUpdate", false);
                        if(cmp.get("v.derivedFromQuestion")){
                            cmp.set("v.derivedFromQuestion", false);
                        }
                        
                        helper.defineOriginalInstance(cmp, event, helper);
                        cmp.set("v.removedAnswerIds", []);
                        cmp.set("v.removedOptionIndices", []);
                        var dependent = false;
                        if(!cmp.get("v.hasDependentQuestion") && cmp.get("v.hasNextQuestion") ||
                           cmp.get("v.hasDependentQuestion") && !cmp.get("v.hasNextQuestion")||
                           cmp.get("v.hasDependentQuestion") && cmp.get("v.hasNextQuestion")){
                            dependent = true;
                            
                        }
                        
                        if (cmp.get("v.isFileUpload")) {
                            var additionalInfo = $A.get("e.c:additionalOptionBasedEvt");
                            additionalInfo.setParams({
                                "answerOptions": answers,
                                "isFileUpload": cmp.get("v.isFileUpload"),
                                "fileContentMap" : JSON.parse(JSON.stringify(cmp.get("v.fileContentMap"))),
                                "removedIndices" : cmp.get("v.removedIndices"),
                                "dependent" : true//dependent
                            });
                            additionalInfo.fire();
                            cmp.set("v.removedIndices", []);
                            cmp.set("v.isFileUpload", false);
                            
                        } else {
                            helper.hideActionBtn(cmp, event, helper);
                             helper.showNotificationEvt("success",
                                                       "Answers Changes Saved", null);
                             //if(dependent){
                                 
                                window.Exam.QuestionServiceComponent.fireQuestionEvt(sectionId, true);
                            //}
                        }
                    }
                    
                }));
        }else{
            helper.showNotificationEvt("error", serverAction.msg, null);
        }
    },
    cancel: function(cmp, event, helper) {
        
        var answerDetailsMap = cmp.get("v.answerDetailsMap");
        if(!cmp.get("v.answerOptions").length){
            var addNewLink = cmp.find("addNewLink");
            $A.util.removeClass(addNewLink, 'slds-hide');
        }
        if(cmp.get("v.answerOptions").length === answerDetailsMap["answerOptions"].length){
            helper.hideActionBtn(cmp, event, helper);
        }
        
        helper.closeOption(cmp, event, helper);
        var newOptionBtn = cmp.find("newOption");
        if(cmp.get("v.QuestionTemplate").ExAM__Question_Type__c === "Image"){
            helper.cancelIndiviualChange(cmp);
        }
        
    },
    fileUpload: function(cmp, event, helper) {
        cmp.set("v.isFileUpload", true);
        var fileContent = event.getParam("fileContent");
        var index = event.getParam("index");
        var fileName = event.getParam("fileName");
        
        var fileContentMap = cmp.get("v.fileContentMap") || {};
        var indexWthImageMap = {};
        
        indexWthImageMap["attachmentId"] = '';
        indexWthImageMap["fileName"] = fileName;
        indexWthImageMap["fileContent"] = fileContent;
        
        fileContentMap[index] = indexWthImageMap;
        cmp.set("v.fileContentIndex", index);
        cmp.set("v.fileContentMap", fileContentMap);
    },
    resetLookupInfo: function(cmp, event, helper) {
        helper.resetLookupInfo(cmp, event, helper);
        
    },
    // over All cancel 
    revertChanges : function(cmp, event, helper){
        if(cmp.get("v.hasUpdate")){
            cmp.set("v.hasUpdate", false); 
        }
        if (cmp.get("v.captureWindow")) {
            helper.showNotificationEvt("warning", "Cancel Answer Before Proceeding", 5000);
            return;
        }
        
        var answerDetailsMap = cmp.get("v.answerDetailsMap");
        
        cmp.set("v.answerOptions",answerDetailsMap["answerOptions"]);
        
        cmp.set("v.hasDependentQuestion", answerDetailsMap["hasDependentQuestion"]);
        cmp.set("v.hasNextQuestion", answerDetailsMap["hasNextQuestion"]);  
        helper.hideActionBtn(cmp, event, helper);
        cmp.set("v.removedAnswerIds", []);
        cmp.set("v.removedOptionIndices", []);
        var type = cmp.get("v.QuestionTemplate").ExAM__Question_Type__c;
        if(type === "Image"){
            cmp.set("v.removedIndices", []);
            cmp.set("v.isFileUpload", false);
            cmp.set("v.fileContentMap", JSON.parse(JSON.stringify(answerDetailsMap["fileContentMap"]))); // avoid 2nd time edit reflect instance using Json
        }
    },
    doneEditingView : function(cmp, event, helper){
        helper.hideActionBtn(cmp, event, helper);
    },
    dependentQuestionSelect : function(cmp, event, helper){
        var selectedMenuItemValue = event.getParam("value"); 
        var selectedQuestionInfo = helper.handleSelect(cmp, event, helper, selectedMenuItemValue);
        helper.setSelection(cmp, event, selectedQuestionInfo, "ExAM__Dependent_Question__r", helper);
    },
    nextQuestionSelect : function(cmp, event, helper){
        var selectedMenuItemValue = event.getParam("value");
        var selectedQuestionInfo = helper.handleSelect(cmp, event, helper, selectedMenuItemValue);
        helper.setSelection(cmp, event, selectedQuestionInfo, "ExAM__Next_Question__r", helper);
    }
    
})