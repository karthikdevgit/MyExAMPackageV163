({
    doInit : function(cmp, event, helper){
        
        var assessmentId = cmp.get("v.assessmentId");
        var question = cmp.get("v.QuestionTemplate");
        window.Exam.SectionServiceComponent.fetchSecTemplate(assessmentId, $A.getCallback(function(sectionTemplates){

            if(cmp.isValid){
                var sectionId = question.ExAM__Section_Question__c;
                var sectionKeys = ["ExAM__Section_label__c", "Id"];
                cmp.set("v.sectionsName", helper.setDropDownValue(cmp, sectionTemplates, sectionKeys, "sections", sectionId));
                cmp.set("v.sectionId", sectionId);
            }

        }), null);

    },
    getAction : function(cmp, event, helper){
        var type = event.getParam("type");
        
        if(type === "QuestionCopier"){
            event.stopPropagation();
            var label = event.getParam("name");
            var value = event.getParam("value");
            var text = event.getParam("label");
            
            if(label === "direction"){
                cmp.set("v.sel_Direction", value);
            }else if(label === "sections"){
                cmp.set("v.sectionId", value);
                cmp.set("v.nameOfSelectedSection", text);
            }else if(label === "questions"){
                cmp.set("v.questionId", value);
                cmp.set("v.nameOfSelectedQuestion", text);
            }
            
        }
    },
    saveRecord : function(cmp, event, helper) {
        var questionIndex = cmp.get("v.questionIndex");
        var sectionId = cmp.get("v.sectionId");
        var status, message, time;
        var selectedQuestion = cmp.get("v.nameOfSelectedQuestion");
        
        if(selectedQuestion == '--None--' && cmp.get("v.questionsName").length == 1 || selectedQuestion != '--None--'){

            if(selectedQuestion != '--None--' && cmp.get("v.position") < 0){
                status = 'error';
                message = 'Please choose a valid question';
                time = null;
                helper.showNotificationEvt(status, message, time);

            }else{
                var sel_Direction = cmp.get("v.sel_Direction");
                if(selectedQuestion == '--None--' && sel_Direction == "After"){
                    sel_Direction = "Before";
                }
                if(cmp.get("v.questionsName").length == 1){
                    questionIndex = 0;
                }
                var question = cmp.get("v.QuestionTemplate");
                var questionId = question.Id
                
                var param = {
                    'questionId' : questionId,
                    'sectionId' : sectionId,
                    'direction' : sel_Direction,
                    'index' : questionIndex
                };
                

                if(question.ExAM__Question_Type__c === 'Image'){
                    window.Exam.QuestionServiceComponent.copyQuestionWithImage(param, cmp.get("v.position"), $A.getCallback(function(){
                        
                        if(cmp.isValid()){
                            helper.destoryCmp(cmp, event, helper);
                            status = "success";
                            message = "Question copied successfully";
                            time = null;
                            helper.showNotificationEvt(status, message, time);
                        }
                        
                    }), null);
                }else{
                    window.Exam.QuestionServiceComponent.copyQuestion(param, cmp.get("v.position"), $A.getCallback(function(){
                       
                        if(cmp.isValid()){
                            helper.destoryCmp(cmp, event, helper);
                            status = "success";
                            message = "Question copied successfully";
                            time = null;
                            helper.showNotificationEvt(status, message, time);
                        }
                        
                    }), null);
                }

            }

        }else{
            status = 'error';
            message = 'Please choose a valid question.';
            time = null;
            helper.showNotificationEvt(status, message, time);
        }

    },
    changeSection : function(cmp, event, helper){
        var sectionId = cmp.get("v.sectionId");
        cmp.set("v.nameOfSelectedQuestion", '--None--');
        helper.getQuestionsBySectionId(cmp, helper, sectionId);
    },
    selectQuestion : function(cmp, event, helper){
        var questionId = cmp.get("v.questionId");
        var questionTemplates = cmp.get("v.questionTemplateList");
        for(var i = 0; i < questionTemplates.length; i++){

            if(questionTemplates[i].Id === questionId){
                cmp.set("v.questionIndex",questionTemplates[i].ExAM__Question_Order_No__c - 1);
                cmp.set("v.position", i);
            }

        }
    },
    cancelCopy : function(cmp, event, helper){
        helper.destoryCmp(cmp, event, helper);
    }
})