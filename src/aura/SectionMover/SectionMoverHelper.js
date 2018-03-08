({
    fetchSectionByAssessmentId : function(cmp, event, helper, assessmentId) {
        window.Exam.SectionServiceComponent.fetchSecTemplate(assessmentId, $A.getCallback(function(sectionTemplates){
            if(cmp.isValid()){
                var sectionKeys = ["ExAM__Section_label__c", "Id"];
                cmp.set("v.sectionsName", helper.setDropDownValue(cmp, sectionTemplates, sectionKeys, "sections"));
                cmp.set("v.sectionTemplates",sectionTemplates);
            }
        }), null);
    },
    showNotificationEvt : function(cmp,status,message,time){
        var showNotificationEvent = $A.get("e.c:notificationEvt");
        showNotificationEvent.setParams({
            "action" : status,
            "message" : message,
            "time" : time
        });
        showNotificationEvent.fire();
    },
    destoryCmp : function(cmp, event, helper){
        var enableView = cmp.getEvent("doneEditingView");
        enableView.setParams({
            "Id" : cmp.get("v.moveSectionId"),
            "type" : "sectionContainer" 	// this param for move sec into external assessment.becz sectiontemplate is undefined in sectionviewer
        });
        enableView.fire();
        cmp.destroy();
    },
    setDropDownValue : function(cmp, templateRecords, keys, label, Id){
        var attributes = [];
        if(templateRecords){
            if(label === "sections"){
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
                    cmp.set("v.nameOfSelectedAssessment", attribute["optionText"]);
                }
                attribute["optionValue"] = templateRecord[key];
                attributes.push(attribute);
            }
        }else{
            attribute = {};
            attribute["optionText"] = "--None--";
            attribute["optionValue"] = "SectionMover";
            attributes.push(attribute);
        }
        return attributes;
    }
})