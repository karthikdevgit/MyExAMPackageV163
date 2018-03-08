({
  createComponents : function(cmp, event, helper, uiCmps) {
      helper.toggleSpinner(cmp);
      $A.createComponents(
          uiCmps,
          function(retCmp, status, message) {
              helper.toggleSpinner(cmp);
              if(cmp.isValid() && status === "SUCCESS"){
                  var nextCmp = uiCmps[0];
                  
                  if(nextCmp[0] === 'c:QuestionCopier' || nextCmp[0] === 'c:QuestionMover'){
                      var toggleViewContent = cmp.get("v.toggleViewContent");
                      toggleViewContent["isQuestionEdited"] = true;
                      cmp.set("v.toggleViewContent", toggleViewContent);
                      cmp.set("v.canSwitchTab", false);
                      cmp.set("v.hasSwitchTab", true);
                      helper.fireToggleEditView(cmp, cmp.get("v.QuestionTemplate").ExAM__Section_Question__c, "editViewOn");
                  }
                  var questionOptionCmp = retCmp[0];
                  var templateActions = cmp.find("templateActions");
                  templateActions.set("v.body", []);
                  var body = templateActions.get("v.body");
                  body.push(questionOptionCmp);
                  templateActions.set("v.body", body);
                  
                  var addittionalOptionCmp = retCmp[1];
                  
                  if(addittionalOptionCmp){
                      var additionalActions = cmp.find("additionalActions");
                      additionalActions.set("v.body", []);
                      body = additionalActions.get("v.body");
                      body.push(addittionalOptionCmp);
                      additionalActions.set("v.body", body);
                  }
                  
              }else if(cmp.isValid() && status === 'ERROR'){
                  message = message.split('at org')[0];
                  helper.showNotificationEvt(cmp, event, "error", message, null);
              }else if(cmp.isValid() && status === "INCOMPLETE"){
                  message = "No response from server or client is offline";
                  helper.showNotificationEvt(cmp, event, "error", message, null);
              }

          });
  },
  createOptionsCmp : function(cmp, event, helper, showQuestionOption){
        var QuestionTemplate = cmp.get("v.QuestionTemplate");
        var answerOptions = QuestionTemplate.ExAM__Answer_Options__r;
        var answerTemp = cmp.find("answerTemp");
        var fields = cmp.get("v.fields");
      
        var type = QuestionTemplate.ExAM__Question_Type__c;
        var uiCmps = [];

        if(answerOptions){
            cmp.set("v.answerOptions", answerOptions);
        }

        if(answerTemp){
            answerTemp.doInitMethod();
        }

      if(showQuestionOption){
          var nextCmp = "c:QuestionOptionsViewer";
            var attributes = {
                "QuestionTemplate" : QuestionTemplate,
                "fields" : fields,
                "defaultMode" : "view",
                "mode" : "edit"
            };
            var uiCmp = [
                nextCmp,
                attributes
            ];
            uiCmps.push(uiCmp);
        
        helper.createComponents(cmp, event, helper, uiCmps);
      }
            
    },
    uploadImage : function(cmp, event, fileContent, index, answerOptions, helper){
        var imageSrc = cmp.get("v.imageSrc"); 
        var attachmentId = imageSrc[index];
        var recordId = answerOptions.Id;

        if(Object.keys(fileContent).length > 1){
            var param = {
                "attachmentId" : attachmentId,
                "parentId" : recordId,
                "fileName" : fileContent.fileName,
                "base64Data" : encodeURIComponent(fileContent.fileContents),
                "contentType" : fileContent.contentType
            };
            window.Exam.AttachmentServiceComponent.saveFile(param, $A.getCallback(function(attachment){
                if (cmp.isValid()) {
                    
                    var attachId = attachment.Id;
                    var count = cmp.get("v.count");
                    imageSrc = cmp.get("v.imageSrc");// review line
                    
                    var fileContentMap = cmp.find("additionOpt").get("v.answerDetailsMap").fileContentMap || {}; 
                    
                    var indexWthImageMap = {};
                    indexWthImageMap["attachmentId"] = attachId;
                    
                    var contentType = attachment.ContentType;
                    var value = attachment.Name
                    if(contentType){
                        contentType = contentType.split('/');
                        value = value+'.'+contentType[1];
                    }  
                    
                    indexWthImageMap["fileName"] = value;
                    indexWthImageMap["fileContent"] = {'fileContents' : ''};
                    fileContentMap[index] = indexWthImageMap;
                    
                    if(attachmentId){
                        imageSrc[index] = attachId;
                        count++;
                    }else{
                        imageSrc.push(attachId);
                        count++;
                    }
                    
                    cmp.set("v.imageSrc", imageSrc);
                    cmp.set("v.count", count);
                    

                    if(cmp.get("v.count") ===  cmp.get("v.fileContentList").length){
                        var answerDetailsMap = cmp.find("additionOpt").get("v.answerDetailsMap");
                        answerDetailsMap['fileContentMap'] = JSON.parse(JSON.stringify(fileContentMap));
                        cmp.find("additionOpt").set("v.answerDetailsMap", answerDetailsMap);
                        cmp.find("additionOpt").set("v.fileContentMap", JSON.parse(JSON.stringify(fileContentMap)));
                        cmp.set("v.fileContentMap", {});
                        cmp.set("v.fileContentList", []);
                        cmp.set("v.count", 0);
                        cmp.set("v.isFileUpload", false);
                        var sectionId = cmp.get("v.QuestionTemplate").ExAM__Section_Question__c;

                       if (cmp.get("v.QuestionTemplate").ExAM__Question_Type__c === "Image") {
                            imageSrc = cmp.get("v.imageSrc");
                            var answerTemp = cmp.find("answerTemp");

                            if(answerTemp){
                                answerTemp.doInitMethod();
                            }

                        }
                        cmp.find("additionOpt").enableView();
                        helper.closeCaptureWindow(cmp, event, helper, sectionId);
                    }
                }
            }), null);

        }

    },
    updateImage : function(cmp, event, answerOptions, helper){
        var fileContentMap = cmp.get("v.fileContentMap");
        
        Object.keys(fileContentMap).forEach(function(index){
            var fileContent = fileContentMap[index].fileContent;
            if(fileContent.fileContents && answerOptions[index]){
                helper.uploadImage(cmp, event, fileContent, index, answerOptions[index], helper); 
            }
        });
    },
    showNotificationEvt : function(cmp, event, status, message, time){
        var showNotificationEvent = $A.get("e.c:notificationEvt");
        showNotificationEvent.setParams({
            "action" : status,
            "message" : message
        });
        showNotificationEvent.fire();
    },

    saveQuestion : function(cmp, event, helper, questionTemplate, answerOptions, questionOptions, hasDependent){

        for(var i = 0; i < answerOptions.length; i++){
            if(answerOptions[i].ExAM__Next_Question__r){
                delete answerOptions[i].ExAM__Next_Question__r;
            }
            if(answerOptions[i].ExAM__Dependent_Question__r){
                delete answerOptions[i].ExAM__Dependent_Question__r;
            }
        }

        var orderNo = cmp.get("v.orderNo");
        var position = cmp.get("v.position");
        
        var param = {
            "QuestionTemplate" : questionTemplate,
            "orderNo" : orderNo,
            "answerOptions" : answerOptions
        };
        questionTemplate.sobjectType = 'ExAM__Question_Template__c';
        
        window.Exam.QuestionServiceComponent.createNewQuestion(param, position, hasDependent, $A.getCallback(function(question){
            
            if(cmp.isValid()){
                var imageQuestionUploadCmp = cmp.find("imageQuestion");
                if(imageQuestionUploadCmp){
                    
                    imageQuestionUploadCmp.set("v.Id", question.Id);
                    //imageQuestionUploadCmp.set("v.sObjectName", "Question_Template__c");
                    
                    imageQuestionUploadCmp.uploadImage(function(){
                        console.log("hai2:::");
                        window.Exam.AnswerServiceComponent.getAnswerOptions(question.Id, $A.getCallback(function(answerOptions){
                            if(cmp.isValid()){                        
                                console.log("hai2:::",question.ExAM__Question_Type__c);
                                if(question.ExAM__Question_Type__c === "Image"){
                                    var additionOpt = cmp.find("additionOpt");
                                    var isFileUpload = additionOpt.get("v.isFileUpload");
                                    //if(isFileUpload){
                                    var fileContentMap = additionOpt.get("v.fileContentMap");
                                    helper.getFileContentList(cmp, fileContentMap);
                                    cmp.set("v.isFileUpload", isFileUpload);
                                    cmp.set("v.fileContentMap", fileContentMap);
                                    helper.updateImage(cmp, event, answerOptions, helper);
                                    /* }else{
                                helper.updateQuestionEvent(cmp, event, helper);   
                            }*/
                                }else{
                                    console.log("hai:::");
                                    helper.updateQuestionEvent(cmp, event, helper);
                                }
                                
                                cmp.set("v.QuestionTemplate", question);
                            }
                            
                        }), null);
                    });
                }
            }
            
        }), null);
    },
    closeModal : function(cmp, event, helper, position, splice){
		var self = this;
        var cancelCreateQuestion = cmp.getEvent("cancelCreateAction");
        cancelCreateQuestion.setParams({
            "position" : position
        });
        cancelCreateQuestion.fire();
        self.destoryCmp(cmp, event, helper);
    },

    updateQuestionEvent : function(cmp, event, helper){
        var question = cmp.get("v.QuestionTemplate");
        var sectionId = question.ExAM__Section_Question__c;
        
        helper.closeCaptureWindow(cmp, event, helper, sectionId);
    },
    navigateOption : function(cmp, event, helper){
        
        cmp.find("tabContainer").set("v.currentComponent", 'QuestionOptionsViewer');
        var uiCmps = [];
        var fields = cmp.get("v.fields");
        var QuestionTemplate = cmp.get("v.QuestionTemplate");
        var nextCmp = "c:QuestionOptionsViewer";
        var attributes = {
            "QuestionTemplate" : QuestionTemplate,
            "fields" : fields,
            "defaultMode" : "view",
            "mode" : "edit"
        };
        var uiCmp = [
            nextCmp,
            attributes
        ];
        uiCmps.push(uiCmp);
        helper.createComponents(cmp, event, helper, uiCmps);
    },
    closeCaptureWindow : function(cmp, event, helper, sectionId){
        
        if(cmp.get("v.builtNewQuestion")){
            var status = "success";
            var message = "Question created";
            var time = null;
            helper.showNotificationEvt(cmp, event, status, message, time);
            var position = parseInt(cmp.get("v.position"), 10) + 1;
            helper.closeModal(cmp, event, helper, position);
        }else{
            status = "success";
            message = "Answers Changes with Attachment Saved";
            time = null;
            helper.showNotificationEvt(cmp, event, status, message, time);
        }
        var dependent = event.getParam("dependent") || false;
        window.Exam.QuestionServiceComponent.fireQuestionEvt(sectionId, dependent);
    },
    validateQuestionWthAnswer : function(cmp, event, helper, answerOptions, type, serverAction){

            if(answerOptions.length){
                if(type === "Image"){
                    
                    var additionOpt = cmp.find("additionOpt");
                    var isFileUpload = additionOpt.get("v.isFileUpload");
                    if(!isFileUpload){
                        serverAction.allow = false;
                        serverAction.msg = "Each answer must have an attachment";
                        return serverAction;
                    }else{
                        var fileContentMap = cmp.find("additionOpt").get("v.fileContentMap");
                        var indexWthImageMapList = Object.keys(fileContentMap);
                        if(indexWthImageMapList.length !== answerOptions.length){
                            serverAction.allow = false;
                            serverAction.msg = "Each answer must have an attachment";
                            return serverAction;
                        }
                    }
                    
                    /*var fileNames = helper.getFileNameList(cmp);//cmp.find("additionOpt").get("v.fileNames");
                    
                    if(fileNames.includes('No file')){
                        serverAction.allow = false;
                        serverAction.msg = "Each answer must have an attachment";
                        return serverAction;
                    }*/
                }
                serverAction.allow = true;
                return serverAction;
            }else{
                serverAction.allow = false;
                serverAction.msg = "At least one answer is required";
                return serverAction;
            }
        },
    toggleSpinner : function(cmp){
        var spinner_container = cmp.find("spinner_container");
        $A.util.toggleClass(spinner_container,"slds-hide");
    },
    getFileContentList : function(cmp, fileContentMap){
        var fileContentList = cmp.get("v.fileContentList") || [];
        Object.keys(fileContentMap).forEach(function(index){
            if(fileContentMap[index].fileContent.fileContents){
                fileContentList.push(index);
            }
        });
        cmp.set("v.fileContentList", fileContentList);
    },
    getFileNameList : function(cmp){
        var fileNames = [];
        var fileContentMap = cmp.find("additionOpt").get("v.fileContentMap");
        
        Object.keys(fileContentMap).forEach(function(index){
            if(fileContentMap[index].fileContent && fileContentMap[index].fileContent.fileName){
                fileNames.push(fileContentMap[index].fileContent.fileName);
            }else{
                fileNames.push('No file');
            }
        });
        return fileNames;
    },
    destoryCmp : function(cmp, event, helper){
        var sectionId = cmp.get("v.QuestionTemplate").ExAM__Section_Question__c;
        helper.fireToggleEditView(cmp, sectionId, "doneEditingView");
        cmp.destroy();
    },
    fireToggleEditView : function(cmp, Id, eventName){
        var editViewToggle = cmp.getEvent(eventName);
        editViewToggle.setParams({
            "Id" : Id
        });
        editViewToggle.fire();
    },
})