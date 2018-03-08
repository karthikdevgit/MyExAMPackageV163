({
    closeOption: function(cmp, event, helper) {
        cmp.set("v.captureWindow", false);
        helper.toggleEditView(cmp, "enableView", cmp.get("v.QuestionTemplate").Id);
        
        helper.resetAnswerOption(cmp);
        
        var answerOptions = cmp.get("v.answerOptions");
        
        var nextQuestions = [],
            dependentQuestions = [];
        for (var i = 0; i < answerOptions.length; i++) {
            
            if (answerOptions[i].ExAM__Next_Question__r && answerOptions[i].ExAM__Next_Question__r.Id) {
                nextQuestions.push(answerOptions[i].ExAM__Next_Question__r.Id);
            } else if (answerOptions[i].ExAM__Dependent_Question__r && answerOptions[i].ExAM__Dependent_Question__r.Id) {
                dependentQuestions.push(answerOptions[i].ExAM__Dependent_Question__r.Id);
            }
            
        }
        helper.showDependentAndNextQuestionView(cmp, nextQuestions,
                                                dependentQuestions);
    },
    
    showNotificationEvt: function(status, message, time) {
        var showNotificationEvent = $A.get("e.c:notificationEvt");
        showNotificationEvent.setParams({
            "action": status,
            "message": message,
            "time": time
        });
        showNotificationEvent.fire();
    },
    resetAnswerOption: function(cmp) {
        var answerOption = {
            'Name': '',
            'ExAM__Help_Text__c': '',
            'ExAM__Weight__c': null,
            'ExAM__Next_Question__r': {
                'Name': '',
                'Id': '',
                'ExAM__Question_Label__c' : ''
            },
            'ExAM__Dependent_Question__r': {
                'Name': '',
                'Id': '',
                'ExAM__Question_Label__c' : ''
            },
            'sobjectType': 'ExAM__Answer_Option__c'
        };
        cmp.set("v.answerOption", {});
        cmp.set("v.answerOption", JSON.parse(JSON.stringify(answerOption)));
        
    },
    showDependentAndNextQuestionView: function(cmp, nextQuestions, dependentQuestions) {
        
        if (!nextQuestions.length && !dependentQuestions.length) {
            cmp.set("v.hasDependentQuestion", true);
            cmp.set("v.hasNextQuestion", true);
        } else {
            cmp.set("v.hasDependentQuestion", dependentQuestions.length > 0);
            cmp.set("v.hasNextQuestion", nextQuestions.length > 0);
        }
        
    },
    showAnswerForEdit: function(cmp, event, helper) {
        
        if (cmp.get("v.captureWindow")) {
            helper.showNotificationEvt("error", "Sorry, there was a problem editing this answer.", null);
            return;
        }
        var action = event.getParam("action");
        var index = event.getParam("itemIndex");
        cmp.set("v.indexPos", parseInt(index, 10));
        
        var answerOptions = cmp.get("v.answerOptions");
        var answerOption = cmp.get("v.answerOption");
        answerOption = JSON.parse(JSON.stringify(answerOptions[index]));
        cmp.set("v.answerOption", answerOption);
        
        var hasDependentQuestion = cmp.get("v.hasDependentQuestion");
        var hasNextQuestion = cmp.get("v.hasNextQuestion");
        
        if(!hasDependentQuestion && hasNextQuestion || hasDependentQuestion && !hasNextQuestion){
            
            var selectedQuestion = cmp.get("v.selectedQuestion");
            if(hasDependentQuestion){
                var selectedMenuItemValue = answerOption.ExAM__Dependent_Question__r.Id;
                var label = "labelOfDependentQues"; 
            }else if(hasNextQuestion){                
                var selectedMenuItemValue = answerOption.ExAM__Next_Question__r.Id;
                var label = "labelOfNextQues";
            }
            
            var selectedQuestionInfo = helper.handleSelect(cmp, event, helper, selectedMenuItemValue);
            selectedQuestion[label] = selectedQuestionInfo["Label"];
            cmp.set("v.selectedQuestion", selectedQuestion);
        }
        
        cmp.set("v.captureWindow", true);
        
        helper.toggleEditView(cmp, "disableView", cmp.get("v.QuestionTemplate").Id);
        
        
        var type = cmp.get("v.QuestionTemplate").ExAM__Question_Type__c;
        
        if(type === "Image"){
            var fileContentMap = cmp.get("v.fileContentMap");
            var indexWthImageMap = {};
            if(fileContentMap[index]){
                indexWthImageMap = fileContentMap[index];
            }
            cmp.set("v.indexWthImageMap", JSON.parse(JSON.stringify(indexWthImageMap)));
        }
        
        var newOption = cmp.find("newOption");
        var updateOption = cmp.find("updateOption");
        
        if (!$A.util.hasClass(newOption, "slds-hide")) {
            $A.util.addClass(newOption, "slds-hide");
        }
        
        if ($A.util.hasClass(updateOption, "slds-hide")) {
            $A.util.removeClass(updateOption, "slds-hide");
        }
    },
    removeOption: function(cmp, event, helper) {
        if (cmp.get("v.captureWindow")) {
            helper.showNotificationEvt("error", "cancel Capture window", null);
            return;
        }
        
        var index = event.getParam("itemIndex");
        var answerOptions = cmp.get("v.answerOptions");
        var type = cmp.get("v.QuestionTemplate").ExAM__Question_Type__c;
        var removeOption = answerOptions.splice(index, 1);
        
        
        if (removeOption[0].Id) {
            var removedAnswerIds = cmp.get("v.removedAnswerIds");
            removedAnswerIds.push(removeOption[0].Id);
            
            if(type === "Image"){
                var removedIndices = cmp.get("v.removedIndices") || [];
                removedIndices.push(index);
                helper.reOrderFileContent(cmp, event, helper, index);
                cmp.set("v.removedIndices", removedIndices);
            }
            cmp.set("v.removedAnswerIds", removedAnswerIds);
        }else {
            var removedOptionIndices = cmp.get("v.removedOptionIndices");
            removedOptionIndices.push(index);
            
            if(type === "Image"){        
                helper.reOrderFileContent(cmp, event, helper, index);
            }
            cmp.set("v.removedOptionIndices", removedOptionIndices);
        }
        
        for (var i = 1; i <= answerOptions.length; i++) {
            answerOptions[i - 1].ExAM__Order_No__c = i;
        }
        
        
        if (!answerOptions.length) {
            cmp.set("v.hasNextQuestion", true);
            cmp.set("v.hasDependentQuestion", true);
        }
        
        cmp.set("v.answerOptions", answerOptions);
    },
    generateFileContentMap : function(cmp, event, helper, param){
        window.Exam.AttachmentServiceComponent.fetchAttachment(param,$A.getCallback(function(attachments){
            if(cmp.isValid()){
                
                var answerOptionsIds,answer,answerOpt;
                var value;
                var fileContentMap = cmp.get("v.fileContentMap") || {};
                var indexWthImageMap = {};
                
                if(!cmp.get("v.derivedFromQuestion")){
                    answerOptionsIds = param.answerOptionsId;
                }else{
                    answer = cmp.get("v.QuestionTemplate").ExAM__Subquestion_Label__c;
                    answerOpt = answer.split('~');
                }
                
                if(attachments.length){
                    var k = 0;
                    
                    if(!cmp.get("v.derivedFromQuestion")){
                        for(var i = 0; i < answerOptionsIds.length; i++){
                            
                            if(attachments[k] && answerOptionsIds[i] === attachments[k].ParentId){
                                
                                value = attachments[k].Name;
                                
                                var contentType = attachments[k].ContentType;
                                
                                if(contentType){
                                    contentType = contentType.split('/');
                                    value = value+'.'+contentType[1];
                                }              
                                
                                indexWthImageMap["attachmentId"] = attachments[k].Id;
                                indexWthImageMap["fileName"] = value;
                                indexWthImageMap["fileContent"] = {'fileContents' : ''};
                                fileContentMap[i] = JSON.parse(JSON.stringify(indexWthImageMap));
                                k++;
                            }else{
                                indexWthImageMap["attachmentId"] = '';
                                indexWthImageMap["fileName"] = 'No file';
                                indexWthImageMap["fileContent"] = {'fileContents' : ''};
                                fileContentMap[i] = JSON.parse(JSON.stringify(indexWthImageMap));
                            }
                            
                        }
                    }else{
                        
                        for (i = 1; i <= answerOpt.length; i++) {
                            var j = i-1;
                            
                            if(parseInt(attachments[k].Name, 10) === i){
                                value = attachments[k].Name;
                                contentType = attachments[k].ContentType;
                                
                                contentType = contentType.split('/');
                                value = value+'.'+contentType[1];
                                
                                indexWthImageMap["attachmentId"] = attachments[k].Id;
                                indexWthImageMap["fileName"] = value;
                                indexWthImageMap["fileContent"] = {'fileContents' : ''};
                                fileContentMap[j] = JSON.parse(JSON.stringify(indexWthImageMap));
                                k++;
                            }else{
                                
                                indexWthImageMap["attachmentId"] = '';
                                indexWthImageMap["fileName"] = 'No file';
                                indexWthImageMap["fileContent"] = {'fileContents' : ''};
                                fileContentMap[j] = JSON.parse(JSON.stringify(indexWthImageMap));
                            }
                            
                        }
                        
                    }
                }else{
                    
                    if(cmp.get("v.derivedFromQuestion")){
                        for (i = 0; i < answerOpt.length; i++) {
                            indexWthImageMap["attachmentId"] = '';
                            indexWthImageMap["fileName"] = 'No file';
                            indexWthImageMap["fileContent"] = {'fileContents' : ''};
                            fileContentMap[i] = JSON.parse(JSON.stringify(indexWthImageMap));
                        }
                    }else{
                        for(var j = 0; j < answerOptionsIds.length; j++){
                            indexWthImageMap["attachmentId"] = '';
                            indexWthImageMap["fileName"] = 'No file';
                            indexWthImageMap["fileContent"] = {'fileContents' : ''};
                            fileContentMap[j] = JSON.parse(JSON.stringify(indexWthImageMap));
                        }
                    }
                    
                }
                
                cmp.set("v.fileContentMap", fileContentMap);
                helper.defineOriginalInstance(cmp, event, helper);
            }
            
        }), null);
    },
    validateQuestionWthAnswer : function(cmp,event,helper,answerOptions){
        var serverAction = {};
        var question = cmp.get("v.QuestionTemplate");
        var type = question.ExAM__Question_Type__c;
        if(type === "Dropdown Picklist"
           || type === "RadioPicklist"
           || type === "Button"
           || type === "MultiselectPicklist"
           || type === "List"
           || type === "Image"
           || type === "Dropdown Picklist"){
            
            if(answerOptions.length){
                if(type === "Image"){
                    var fileContentMap = cmp.get("v.fileContentMap");
                    
                    var indexWthImageMapList = Object.keys(fileContentMap);//cmp.get("v.fileNames");
                    
                    for(var i = 0; i < indexWthImageMapList.length; i++){
                        if(!fileContentMap[i].fileName || fileContentMap[i].fileName === 'No file'){
                            serverAction.allow = false;
                            serverAction.msg = "Each answer must have an attachment";
                            return serverAction;
                        }
                    }
                }
                serverAction.allow = true;
                return serverAction;
            }else{
                serverAction.allow = false;
                serverAction.msg = "At least one answer is required";
                return serverAction;
            }
        }else{
            serverAction.allow = true;
            return serverAction;
        }
    },
    setReference : function(answerOptions,nextQuestions,dependentQuestions,answerOptionsIds){
        for (var i = 0; i < answerOptions.length; i++) {
            answerOptionsIds.push(answerOptions[i].Id);		// collect AnswerOptionsId
            // define AnswerOption Structure 
            var answerOption = {
                'Name': '',
                'ExAM__Help_Text__c': '',
                'ExAM__Weight__c': null,
                'ExAM__Next_Question__r': {
                    'Name': '',
                    'Id': '',
                    'ExAM__Question_Label__c' : ''
                },
                'ExAM__Dependent_Question__r': {
                    'Name': '',
                    'Id': '',
                    'ExAM__Question_Label__c' : ''
                },
                'sobjectType': 'ExAM__Answer_Option__c'
            };
            // check AnswerOption record have reference value 
            if (answerOptions[i].ExAM__Next_Question__r) {
                nextQuestions.push(answerOptions[i].ExAM__Next_Question__r.Id);
            } else if (answerOptions[i].ExAM__Dependent_Question__r) {
                dependentQuestions.push(answerOptions[i].ExAM__Dependent_Question__r.Id);
            }
            //  set reference to AnswerOption record 
            answerOptions[i].ExAM__Next_Question__r = answerOptions[i].ExAM__Next_Question__r ||
                answerOption.ExAM__Next_Question__r;
            answerOptions[i].ExAM__Dependent_Question__r = answerOptions[i].ExAM__Dependent_Question__r ||
                answerOption.ExAM__Dependent_Question__r;
            answerOptions[i].ExAM__Weight__c = answerOptions[i].ExAM__Weight__c != null ? answerOptions[i].ExAM__Weight__c : answerOption.ExAM__Weight__c;
            answerOptions[i].ExAM__Help_Text__c = answerOptions[i].ExAM__Help_Text__c ||
                answerOption.ExAM__Help_Text__c;
            answerOptions[i].sobjectType = answerOption.sobjectType;
        }
    },
    reOrderFileContent : function(cmp, event, helper, index){
        var fileContentMap = cmp.get("v.fileContentMap");
        
        if(fileContentMap){
            Object.keys(fileContentMap).forEach(function(key) {
                
                if(key > index){
                    Object.defineProperty(fileContentMap, parseInt(key, 10)- 1,
                                          Object.getOwnPropertyDescriptor(fileContentMap, key));
                    delete fileContentMap[key];
                }else if(parseInt(key, 10) === index){
                    delete fileContentMap[key];
                }
                
            });
        }
        if(fileContentMap && !Object.keys(fileContentMap).length){
            cmp.set("v.isFileUpload", false);
        }
        cmp.set("v.fileContentMap", fileContentMap);
    },
    showActionBtn : function(cmp, event, helper){
        if(!cmp.get("v.disable") && !cmp.get("v.showBtn")){
            helper.toggleEditView(cmp, "disableView", cmp.get("v.QuestionTemplate").Id);
            cmp.set("v.showBtn", true); 
        }
    },
    hideActionBtn : function(cmp, event, helper){
        if(!cmp.get("v.disable") && !cmp.get("v.hasUpdate") && cmp.get("v.showBtn")){
            helper.toggleEditView(cmp, "enableView", cmp.get("v.QuestionTemplate").Id);
            cmp.set("v.showBtn", false);
        }
    },
    defineOriginalInstance : function(cmp, event, helper){
        
        var answerDetailsMap  = cmp.get("v.answerDetailsMap") || {};
        
        answerDetailsMap["answerOptions"] = cmp.get("v.answerOptions");
        var type = cmp.get("v.QuestionTemplate").ExAM__Question_Type__c;
        if(type === "Image"){
            answerDetailsMap["fileContentMap"] = cmp.get("v.fileContentMap");
        }
        answerDetailsMap["hasDependentQuestion"] = cmp.get("v.hasDependentQuestion");
        answerDetailsMap["hasNextQuestion"] = cmp.get("v.hasNextQuestion");
        
        cmp.set("v.answerDetailsMap", JSON.parse(JSON.stringify(answerDetailsMap)));
        
    },
    cancelIndiviualChange : function(cmp){
        var fileContentMap = cmp.get("v.fileContentMap");
        var index = cmp.get("v.indexPos");
        if(!index){
            index = cmp.get("v.fileContentIndex");
            if(fileContentMap[index]){
                delete fileContentMap[index];
                cmp.set("v.fileContentMap", fileContentMap);
            }
        }else if(fileContentMap[index]){
            var originalInstance = cmp.get("v.answerDetailsMap").fileContentMap;
            fileContentMap[index] = JSON.parse(JSON.stringify(originalInstance[index] || {}));
            cmp.set("v.fileContentMap", fileContentMap);
            cmp.set("v.indexWthImageMap", JSON.parse(JSON.stringify(originalInstance[index] || {})));
        }
    },
    toggleEditView : function(cmp, state, Id){
        if(Id){
            var editViewToggle = cmp.getEvent("disableViewToggle");
            editViewToggle.setParams({
                "state" : state,
                "Id" : Id,
                "sourceDrivenCmp" : "answerOptionsViewer"
            });
            editViewToggle.fire();
        }
    },
    handleSelect : function(cmp, event, helper, selectedMenuItemValue){
        var selectedQuestionInfo = {
            "Name" : '',
            "Label" : '--None--'
        };
        
        
        if(selectedMenuItemValue){
            var menuItems = cmp.get("v.menuItems");
            
            for(var i = 0; i < menuItems.length; i++){
                if(menuItems[i].Id == selectedMenuItemValue){
                    selectedQuestionInfo["Name"] = menuItems[i].Name;
                    selectedQuestionInfo["Label"] = menuItems[i].ExAM__Question_Label__c;
                    break;
                }
            }
        }
        
        selectedQuestionInfo["Id"] = selectedMenuItemValue;
        return selectedQuestionInfo;
    },
    setSelection : function(cmp, event, selectedQuestionInfo, reference, helper){
        var answerOption = cmp.get("v.answerOption");
        var selectedQuestion = cmp.get("v.selectedQuestion");
        var referenceOfQues = answerOption[reference];
        referenceOfQues["Id"] = selectedQuestionInfo["Id"];
        referenceOfQues["Name"] = selectedQuestionInfo["Name"];
        referenceOfQues["ExAM__Question_Label__c"] = selectedQuestionInfo["Label"] == '--None--'? '' : selectedQuestionInfo["Label"];
        
        if(reference == "ExAM__Dependent_Question__r"){
            selectedQuestion["labelOfDependentQues"] = selectedQuestionInfo["Label"];
        }else{
            selectedQuestion["labelOfNextQues"] = selectedQuestionInfo["Label"];
        }
        
        cmp.set("v.selectedQuestion", selectedQuestion);
        cmp.set("v.answerOption", answerOption);
        if(!selectedQuestionInfo["Id"] || (cmp.get("v.hasNextQuestion") && cmp.get("v.hasDependentQuestion"))){
            helper.resetLookupInfo(cmp, event, helper)
        }
    },
    resetLookupInfo: function(cmp, event, helper) {
        
        var answerOptions = cmp.get("v.answerOptions");
        var answerOption = cmp.get("v.answerOption");
        var index = cmp.get("v.indexPos");
        var nextQuestions = [],
            dependentQuestions = [];
        
        if(answerOptions.length){
            for (var i = 0; i < answerOptions.length; i++) {
                var obj;
                
                if (index === i) {
                    obj = answerOption;
                } else {
                    obj = answerOptions[i];
                }
                
                
                if (obj.ExAM__Next_Question__r.Id) {                    
                    nextQuestions.push(obj.ExAM__Next_Question__r.Id);
                    break;
                } else if (obj.ExAM__Dependent_Question__r.Id) {
                    dependentQuestions.push(obj.ExAM__Dependent_Question__r.Id);
                    break;
                }
                
            }
        }else{
            obj = answerOption;
            if (obj.ExAM__Next_Question__r.Id) {
                nextQuestions.push(obj.ExAM__Next_Question__r.Id);
            } else if (obj.ExAM__Dependent_Question__r.Id) {
                dependentQuestions.push(obj.ExAM__Dependent_Question__r.Id);
            }
        }
        
        helper.showDependentAndNextQuestionView(cmp, nextQuestions,
                                                dependentQuestions);
        
    },
    convertLegacyToNewInternally : function(cmp, event, helper, answer, questionId, type, 
                                            dependentQuestions, nextQuestions, weightofAnswerOptions, 
                                            answerOptions, dependencyQuestions){ 
        var answerOpt = answer.split('~');
        var orderNo = 1;
        for (var i = 0; i < answerOpt.length; i++) {
            var answerOption = {
                'Name': '',
                'ExAM__Help_Text__c': '',
                'ExAM__Weight__c': null,
                'ExAM__Next_Question__r': {
                    'Name': '',
                    'Id': '',
                    'ExAM__Question_Label__c' : ''
                },
                'ExAM__Dependent_Question__r': {
                    'Name': '',
                    'Id': '',
                    'ExAM__Question_Label__c' : ''
                },
                'sobjectType': 'ExAM__Answer_Option__c'
            };
            answerOption.Name = answerOpt[i];
            answerOption.ExAM__Question_Template__c = questionId || '';
            answerOption.ExAM__Order_No__c = orderNo++;
            answerOption.sobjectType = 'ExAM__Answer_Option__c';
            
            
            if (dependentQuestions.length > i) {
                answerOption.ExAM__Dependent_Question__r.Name = dependentQuestions[i];
                answerOption.ExAM__Dependent_Question__r.ExAM__Question_Label__c = dependencyQuestions[i] ? dependencyQuestions[i].ExAM__Question_Label__c : '';
                answerOption.ExAM__Dependent_Question__r.Id = dependencyQuestions[i] ? dependencyQuestions[i].Id : '';
            } else if (nextQuestions.length > i) {
                answerOption.ExAM__Next_Question__r.Name = nextQuestions[i];
                answerOption.ExAM__Next_Question__r.ExAM__Question_Label__c = dependencyQuestions[i] ? dependencyQuestions[i].ExAM__Question_Label__c : '';
                answerOption.ExAM__Next_Question__r.Id = dependencyQuestions[i] ? dependencyQuestions[i].Id : '';
            }
            
            if (weightofAnswerOptions.length > i) {
                answerOption.ExAM__Weight__c = parseInt(weightofAnswerOptions[i], 10);
            }
            
            answerOptions.push(answerOption);
        }
        
        cmp.set("v.answerOptions", answerOptions);
        
        if(type === 'Image'){
            param = {
                "QuesId" : questionId
            };
            helper.generateFileContentMap(cmp, event, helper, param);
        }else{
            helper.defineOriginalInstance(cmp, event, helper);
        }
        
    }
})