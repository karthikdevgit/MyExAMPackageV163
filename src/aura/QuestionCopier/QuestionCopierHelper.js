({
    showNotificationEvt : function(status, message, time){
        var showNotificationEvent = $A.get("e.c:notificationEvt");
        showNotificationEvent.setParams({
            "action" : status,
            "message" : message
        });
        showNotificationEvent.fire();
    },
    getQuestionsBySectionId : function(cmp, helper, sectionId){
        var param = {
            "sObjectName" : 'ExAM__Question_Template__c',
            "fieldSets" : [],
            "sObjectId" : sectionId
        };
        window.Exam.QuestionServiceComponent.getQuestionBySectionId(param, false, $A.getCallback(function(questionTemplates){
            
            if(cmp.isValid()){
                
                if(questionTemplates.length === 0){
                    cmp.set("v.questionIndex",0);
                    cmp.set("v.position", 0);
                }
                
            }
             var questionKeys = ["ExAM__Question_Label__c", "Id"];
            cmp.set("v.questionsName", helper.setDropDownValue(cmp, questionTemplates, questionKeys, "questions"));
            cmp.set("v.questionTemplateList",questionTemplates);
        }), null);
    },
    destoryCmp : function(cmp, event, helper){
        var enableView = cmp.getEvent("doneEditingView");
        enableView.setParams({
            "Id" : cmp.get("v.QuestionTemplate").Id
        });
        enableView.fire();
        var navigation =  cmp.getEvent("navigateToOptionTab");
        navigation.fire();
        cmp.destroy();
    },
    setDropDownValue : function(cmp, templateRecords, keys, label, Id){
        var attributes = [];
        if(templateRecords){
            if(label === "questions"){
                var attribute = {};
                attribute["optionText"] = "--None--";
                attribute["optionValue"] = "";
                attributes.push(attribute);
            }
            for(var index = 0; index < templateRecords.length; index++){
                
                var templateRecord = templateRecords[index];
                attribute = {};
                var key = keys[0];
                attribute["optionText"] = templateRecord[key];
                key = keys[1];
                if(templateRecord[key] === Id){
                    cmp.set("v.nameOfSelectedSection", attribute["optionText"]);
                }
                attribute["optionValue"] = templateRecord[key];
                attributes.push(attribute);
            }
        }else{
            attribute = {};
            attribute["optionText"] = "--None--";
            attribute["optionValue"] = "";
            attributes.push(attribute);
        }
        return attributes;
    }
})