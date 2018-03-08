({
    doInit : function(cmp, event, helper) {
        var questionTemplate = cmp.get("v.record");
        var disabled = false;
        var type = questionTemplate.ExAM__Question_Type__c;
        if(type == 'Dropdown Picklist' || type  == 'RadioPicklist' || 
           type == "Button" || type == "MultiselectPicklist" || 
           type == "List" || type == "Image" || type == "Horizontal Radiopicklist"){
            disabled = true;
        }
        if(!disabled){
            var sectionId = questionTemplate.ExAM__Section_Question__c;
            // get all Questions except current Question Of Section template
            window.Exam.QuestionServiceComponent.getQuestionsBySectionId(sectionId, questionTemplate.Id, $A.getCallback(function(questionList){
                var newValue = "";
                if(questionTemplate.ExAM__Single_Next_Question__c){
                    newValue = helper.getSelectionQuestionLabel(cmp, event, helper, questionList, questionTemplate.ExAM__Single_Next_Question__c);
                }
                cmp.set("v.newValue", newValue);
                cmp.set("v.questionList", questionList);
            }), null);
        }
        cmp.set("v.disabled", disabled);
        
    },
    singleNextQuestionSelect : function(cmp, event, helper){
        var selectedQuestion = event.getParam("value");
        var questionTemplate = cmp.get("v.record");
        questionTemplate["ExAM__Single_Next_Question__c"] = selectedQuestion;
        var newValue = "";
        if(selectedQuestion){
            newValue = helper.getSelectionQuestionLabel(cmp, event, helper, cmp.get("v.questionList"), selectedQuestion);
        } 
        cmp.set("v.record", questionTemplate);
        cmp.set("v.newValue", newValue);
    },
    changevalue : function(cmp, event, helper){
        var defaultMode = cmp.get("v.defaultMode");
        if(defaultMode != "edit"){
            helper.disableView(cmp, event, helper);
            var questionTemplate = cmp.get("v.record");
            cmp.set("v.oldValue", questionTemplate.ExAM__Single_Next_Question__c || '');
            cmp.set("v.defaultMode", "edit");
        }
    },
    cancelUpdateFieldVal : function(cmp, event, helper){
        var oldValue = cmp.get("v.oldValue");
        var questionTemplate = cmp.get("v.record");
        questionTemplate["ExAM__Single_Next_Question__c"] = oldValue;
        var newValue = "";
        if(questionTemplate["ExAM__Single_Next_Question__c"]){
            newValue = helper.getSelectionQuestionLabel(cmp, event, helper, cmp.get("v.questionList"), questionTemplate["ExAM__Single_Next_Question__c"]);
        } 
        cmp.set("v.record", questionTemplate);
        cmp.set("v.newValue", newValue);
        
        helper.enableView(cmp, event, helper);
        cmp.set("v.defaultMode", "view");
    },
    updateFieldValue : function(cmp, event, helper){
        helper.saveField(cmp, event, helper, cmp.get("v.record").ExAM__Single_Next_Question__c || '');
    }
})