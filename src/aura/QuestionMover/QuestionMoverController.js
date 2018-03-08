({
    doInit : function(cmp, event, helper){
        var assessmentId = cmp.get("v.assessmentId");
        var question = cmp.get("v.QuestionTemplate");

        window.Exam.SectionServiceComponent.fetchSecTemplate(assessmentId, $A.getCallback(function(sectionTemplates){

            if(cmp.isValid()){
                var sectionId = question.ExAM__Section_Question__c;
                var sectionKeys = ["ExAM__Section_label__c", "Id"];
                cmp.set("v.sectionsName", helper.setDropDownValue(cmp, sectionTemplates, sectionKeys, "sections", sectionId));
                cmp.set("v.sectionId", sectionId);
            }

        }), null);

    },
    getAction : function(cmp, event, helper){
        var type = event.getParam("type");
        
        if(type === "QuestionMover"){
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
    changeSection : function(cmp, event, helper){
        var newSectionId = cmp.get("v.sectionId");
        cmp.set("v.nameOfSelectedQuestion", '--None--');
        helper.getQuestionTemplateBySectionId(cmp, helper, newSectionId);
    },
    selectQuestion : function(cmp, event, helper){
        var questionId = cmp.get("v.questionId");
        var questionTemplates = cmp.get("v.questionTemplateList");
        for(var i = 0; i < questionTemplates.length; i++){

            if(questionTemplates[i].Id === questionId){
                cmp.set("v.questionIndex", questionTemplates[i].ExAM__Question_Order_No__c - 1);
                 cmp.set("v.position", i);
            }

        }
    },
    saveRecord : function(cmp, event, helper){
        var currentSectionId = cmp.get("v.QuestionTemplate").ExAM__Section_Question__c;
        var newSectionId = cmp.get("v.sectionId");
        var questionIndex = cmp.get("v.questionIndex");
        var position = cmp.get("v.position");
        var sel_Direction = cmp.get("v.sel_Direction");
        var selectedQuestion = cmp.get("v.nameOfSelectedQuestion");
        var hasError = false;
        var status,message,time;

        if(selectedQuestion == '--None--' && cmp.get("v.questionsName").length == 1 || selectedQuestion != '--None--'){

            if(currentSectionId === newSectionId){
                
                if((position < 0 || position === cmp.get("v.index")) ||
                   (position === cmp.get("v.index")+1 && sel_Direction === 'Before') ||
                   (position === cmp.get("v.index")-1 && sel_Direction === 'After')){
                    status = 'error';
                    message = 'Please choose a valid question';
                    time = null;
                    helper.showNotificationEvt(cmp, status, message, time);
                    hasError = true;
                }

                newSectionId = null;
            }

            if(!hasError){
                if(selectedQuestion == '--None--' && sel_Direction == 'After'){
                    sel_Direction ="Before";
                }
                if(cmp.get("v.questionsName").length == 1){
                    questionIndex = 0;
                }

                var moveQuestionId = cmp.get("v.QuestionTemplate").Id;
                var param = {
                    'oldSectionId' : currentSectionId,
                    'newSectionId' : newSectionId,
                    'direction' : sel_Direction,
                    'index' : questionIndex,
                    'recordId' : moveQuestionId
                };
                
                window.Exam.QuestionServiceComponent.moveQuestion(param, $A.getCallback(function(){

                    if(cmp.isValid()){
                        helper.destoryCmp(cmp, event, helper);
                        status = "success";
                        message = "Question moved successfully";
                        time = null;
                        helper.showNotificationEvt(cmp, status, message, time);
                    }

                }), null);
            }
        }else{
            status = 'error';
            message = 'Please choose a valid section';
            time = null;
            helper.showNotificationEvt(cmp, status, message, time);
        }

    },
    cancelMove : function(cmp, event, helper){
        helper.destoryCmp(cmp, event, helper);
    }

})