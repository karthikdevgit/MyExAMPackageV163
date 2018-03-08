({
    // perform Action Based on menu Action
    getAction : function(cmp, event, helper){
        var type = event.getParam("type");
        
        if(type === "SectionViewer"){
            event.stopPropagation();
            var action = event.getParam("action");
            var index = event.getParam("itemIndex");
            var sectionTemplate = cmp.get("v.SectionTemplate");
            
            if(action === "copySection"){
                var sectionEditorCopy = cmp.find("sectionMoveOrCpy");
                var cmpName = "SectionCopier";
                var attribute = {
                    "copySectionId": sectionTemplate.Id
                };
                helper.createCmp(cmp, event, helper, cmpName, attribute, sectionEditorCopy);
                
            }else if(action === "moveSection"){
                var sectionEditorMove = cmp.find("sectionMoveOrCpy");
                cmpName = "SectionMover";
                attribute = {
                    "moveSectionId": sectionTemplate.Id,
                    "indexPos": cmp.get("v.index")
                };
                helper.createCmp(cmp, event, helper, cmpName, attribute, sectionEditorMove);
                
            }else if(action === "sectionOption"){
                
                window.Exam.SectionServiceComponent.fetchFieldSet($A.getCallback(function(fields){
                    if(cmp.isValid()){
                        var sectionEditorMove = cmp.find("sectionMoveOrCpy");
                        cmpName = "SectionOptionsViewer";
                        attribute = {
                            "sectionTemplate" : sectionTemplate,
                            "fields" : fields,
                            "defaultMode" : "view",
                            "mode" : 'edit'
                        };
                        helper.createCmp(cmp, event, helper, cmpName, attribute, sectionEditorMove);
                    }                    
                }), null);
                
            }else if(action === "moveSectionUp"){
                helper.moveSection(cmp, event, helper, "up");
            }else if(action === "moveSectionDown"){
                helper.moveSection(cmp, event, helper, "down");
            }else if(action === "changeArchive"){
                //sectionTemplate["sobjectType"] = "ExAM__Section_Template__c";
                //sectionTemplate.ExAM__isArchive__c = true;
                var param = {
                    "sectionId" : sectionTemplate.Id,
                    "assessmentId" : sectionTemplate.ExAM__Questionnaire_Section__c
                };
                var status, message;
                
                window.Exam.SectionServiceComponent.archiveSection(param, $A.getCallback(function() {
                    
                    if(cmp.isValid()){
                        status = "success";
                        message = "Record archived";
                        helper.showNotificationEvt(cmp, event, status, message);
                    }
                    
                }), null);
                
            }
            
        } 
    },
  doInit: function(cmp, event, helper) {
      console.log("DoInit of SectionViewer:::");
    var index = cmp.get("v.index");
    var check = cmp.get("v.check");
   
    if (index === cmp.get("v.position") && !check) {
      cmp.set("v.check", true);
      helper.handleSectionChange(cmp, event, helper);
      helper.toggleClassExpand(cmp);
    }

  },
  // fetch QuestionTemplates specified SectionTemplate
  handleSectionChange: function(cmp, event, helper) {
    var isExpanded = !cmp.get("v.check");
    cmp.set("v.check", isExpanded);
    if (isExpanded) {
      var toggleExpand = cmp.getEvent("toggleExpandEvent");
      toggleExpand.setParams({
        "index": cmp.get("v.index")
      })
      toggleExpand.fire();
      helper.handleSectionChange(cmp, event, helper);
    }
    helper.toggleClassExpand(cmp);
  },
  toggleExpandSection: function(cmp, event, helper) {
    var isExpanded = cmp.get("v.check");
    
    if (isExpanded) {
      cmp.set("v.check", false);
      helper.toggleClassExpand(cmp);
    }
  },
  toggleQuestionSelected: function(cmp, event, helper) {
    var questionDiv = cmp.find("editQuest");
    var evtIndex = event.getParam("index");
      
      if(!Array.isArray(questionDiv)){
          questionDiv = [questionDiv];
      }
      if (questionDiv.length) {
          for (var index = 0; index < questionDiv.length; index++) {
              if(index != evtIndex){
                  if($A.util.hasClass(questionDiv[index], "edit-mode")){
                      if(questionDiv[index].get("v.editAnswers")){
                          questionDiv[index].set("v.editAnswers", false);
                      }
                      $A.util.removeClass(questionDiv[index], "edit-mode");
                  }
              }else{
                  if(!$A.util.hasClass(questionDiv[index], "edit-mode")){
                      $A.util.addClass(questionDiv[evtIndex], "edit-mode");
                  }
              }
              
          }
      }else{
          if(!$A.util.hasClass(questionDiv, "edit-mode")){
              $A.util.addClass(questionDiv, "edit-mode");
          }
      }

  },
  //update View when new Question created
  /*AddNewQuestion: function(cmp, event, helper) {
    var sectionId = event.getParam("questionTemplate").ExAM__Section_Question__c;
    window.Exam.QuestionServiceComponent.getQuestionBySectionId(sectionId,
      $A.getCallback(
        function(questionTemplates) {
            if(cmp.isValid()){
                cmp.set("v.QuestionsTemplate", questionTemplates);
            }
          
        }), null);

  },*/
  addQuestion: function(cmp, event, helper) {
      var orderNo = event.currentTarget.getAttribute("data-item");
      var position = event.currentTarget.getAttribute("data-index");
      if(event.currentTarget.getAttribute("data-btn")){
          cmp.set("v.lastBtn", true);
      }else{
          cmp.set("v.lastBtn", false);
      }
      var div1 = helper.rearrangeElement(cmp, event, position);
      helper.builtNewQuestion(cmp, event, helper, orderNo, position, div1);
      
  },
  changeQuestionTemplates: function(cmp, event, helper) {
    
    var sectionId = event.getParam("sectionId");
    
    if (sectionId === cmp.get("v.SectionTemplate").Id) {
        window.Exam.QuestionServiceComponent.getQuestionsByChangeQuestionsTemp(sectionId, $A.getCallback(function(){
            var dependent = event.getParam("dependent");
            var fieldSets = [];
            
            fieldSets.push("ExAM__lightningComp_QuestionOptions_FieldSet");
            
            var param = {
                "sObjectName": "ExAM__Question_Template__c",
                "fieldSets": fieldSets,
                "sObjectId": sectionId
            };
            window.Exam.QuestionServiceComponent.getQuestionBySectionId(param, dependent, 
            $A.getCallback(function(questionTemplates) {
                                                                                
                if (cmp.isValid()) {
                    helper.findOrderNoOfLastQuestion(cmp, event, helper, questionTemplates);
                    var addBtns = cmp.find("addBtn");
                    if(!Array.isArray(addBtns)){
                        addBtns = [addBtns];
                    }
                    for(var index = 0; index < addBtns.length; index++){
                        if($A.util.hasClass(addBtns[index], "slds-hide")){
                            $A.util.removeClass(addBtns[index], "slds-hide");
                            break;
                        }
                    }
                    cmp.set("v.QuestionsTemplate", questionTemplates);
                }
                
            }), null);
        }), null);
        
    }
  },
  cancelCreateQuestion: function(cmp, event, helper) {
      cmp.set("v.orderNo", null);
      if(cmp.get("v.lastBtn")){
          cmp.set("v.lastBtn", false);
      }
    var position = event.getParam("position");
    var hideBtn = cmp.find("addBtn");

    if (!Array.isArray(hideBtn)) {
      hideBtn = [hideBtn];
    } else {
      var last = hideBtn.splice(0, 1);
      hideBtn.push(last[0]);
    }

    $A.util.toggleClass(hideBtn[position], "slds-hide");
  },
  
  reloadContent: function(cmp, event, helper) {
    var sobject = event.getParam("sObject");
    var section = cmp.get("v.SectionTemplate");
    
    if (sobject.Id === section.Id) {
      event.stopPropagation();
      var assessmentId = section.ExAM__Questionnaire_Section__c;
      var objectKeys = Object.keys(sobject);
      var fieldApi = objectKeys[1];
      section[fieldApi] = sobject[fieldApi];
      cmp.set("v.SectionTemplate", JSON.parse(JSON.stringify(section)));
    }
  },
    // find Which Section's Inline editViewOn
    toggleInLineViewOfSection : function(cmp, event, helper){
        var state = event.getParam("state");
        var Id = event.getParam("Id");
        
        if(Id === cmp.get("v.SectionTemplate").Id){
            event.stopPropagation();            
            if(state === "enableView"){
                cmp.set("v.isInLineEdit", false);	//Inline EditView comes View state
                cmp.set("v.isSectionEdited", false); // section comes view state
                
            }else{
                cmp.set("v.isInLineEdit", true);	//Inline EditViewOn
                cmp.set("v.isSectionEdited", true);	// section comes edit state
            }
        }
        
    },
    // view state comes to edit state
    sectionEditStateOn : function(cmp, event, helper){
        var Id = event.getParam("Id");
        var type = event.getParam("type");
        if(type != "sectionContainer" && Id === cmp.get("v.SectionTemplate").Id){
            event.stopPropagation();
            cmp.set("v.isSectionEdited", true);		// section comes edit state 
        }
    },
    // edit state comes to view state
    sectionViewStateOn : function(cmp, event, helper){
        if(cmp.get("v.SectionTemplate")){ // have section template have in sectionViewer? for move section into external assessment
            var Id = event.getParam("Id");
            var type = event.getParam("type"); 
            
            if(type != "sectionContainer" && Id === cmp.get("v.SectionTemplate").Id){
                event.stopPropagation();
                cmp.set("v.isSectionEdited", false);	// section comes view state
            }else if(cmp.get("v.isSectionEdited")){
                event.stopPropagation();
                cmp.set("v.isSectionEdited", false);	// section comes view state
            }
        }
    },
    // inform child state to parent 
    changesInformToParent : function(cmp, event, helper){        
        var isSectionEdited =  cmp.get("v.isSectionEdited");
        var Id = cmp.get("v.SectionTemplate").Id;
        if(isSectionEdited){
            helper.fireToggleEditView(cmp, Id, "editViewOn");
        }else{
            helper.fireToggleEditView(cmp, Id, "doneEditingView");
        }
    },
    questionEditStateOn : function(cmp, event, helper){
        cmp.set("v.showBtns", false);
        var questionEditors = cmp.find("editQuest");
        if(questionEditors){
            questionEditors = helper.constructArrayElements(questionEditors);
            for(var index = 0; index < questionEditors.length; index++){
                var toggleViewContent = questionEditors[index].get("v.toggleViewContent");
                
                if(toggleViewContent["isQuestionEdited"]){	// is Question editState On
                    if(questionEditors[index].get("v.hasSwitchTab")){	// tab Switched (copy, Move)
                        $A.util.addClass(questionEditors[index].find("questionEditor"), "disable");		// QuestionTemplate left side is diable Of userView
                        var editAnswers = questionEditors[index].get("v.editAnswers");
                        if(editAnswers){	
                            $A.util.addClass(questionEditors[index].find("answerViewer"), "disable");		// AnswerViewer Disable
                        }
                    }else if(toggleViewContent["questionTypeEnabled"]){
                        $A.util.addClass(questionEditors[index].find("toggleAnswers"), "disable");		// AnswerViewer Disable
                        var editAnswers = questionEditors[index].get("v.editAnswers");                            
                        if(editAnswers){
                            $A.util.addClass(questionEditors[index].find("answerViewer"), "disable");		// AnswerViewer Disable
                        }
                    }else if(toggleViewContent["answerOptionsViewerEdited"]){
                        $A.util.addClass(questionEditors[index].find("questionType"), "disable");		// AnswerViewer Disable
                    } 
                }else{
                    $A.util.addClass(questionEditors[index], "disable");	// Disable Question
                }
            }
        }
    },
    questionViewStateOn : function(cmp, event, helper){
        cmp.set("v.showBtns", true);
        var questionEditors = cmp.find("editQuest");
        if(questionEditors){
            questionEditors = helper.constructArrayElements(questionEditors);
            for(var index = 0; index < questionEditors.length; index++){
                if($A.util.hasClass(questionEditors[index], "disable")){		// Question has Disable?
                    $A.util.removeClass(questionEditors[index], "disable");		// enable View
                }else{
                    if($A.util.hasClass(questionEditors[index].find("toggleAnswers"), "disable")){
                        $A.util.removeClass(questionEditors[index].find("toggleAnswers"), "disable");		
                    }
                    if($A.util.hasClass(questionEditors[index].find("questionType"), "disable")){
                        $A.util.removeClass(questionEditors[index].find("questionType"), "disable");		
                    }
                    $A.util.removeClass(questionEditors[index].find("questionEditor"), "disable");	// enable view in left side of Question
                    var editAnswers = questionEditors[index].get("v.editAnswers");
                    if(editAnswers){
                        $A.util.removeClass(questionEditors[index].find("answerViewer"), "disable");	// AnswerViewer enable
                    }
                }
            }
        }
    }
})