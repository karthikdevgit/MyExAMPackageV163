({
    // arrange value from Object to specific attribute 
    arrangeValue : function(cmp, event, helper, ObjContainFields){  
        cmp.set("v.assessmentTemplate", ObjContainFields.sobject[0]);
        var attachment = ObjContainFields.attachment;
        
        if(attachment.length){
            cmp.set("v.attachment",attachment[0]);
        }else{
            var defaultVal = {Name : '', Id : '', ContentType : ''};
            cmp.set("v.attachment", defaultVal);
        }
        
        // Fetch sectionTemplate By AssessmentId
        if(!cmp.get("v.hasQuriedFieldSetOfSec")){
            
            var fieldSets = [];
            fieldSets.push("ExAM__lightningComp_SectionOptions_FieldSet");
            fieldSets.push("ExAM__lightningCmp_AdvanceSecOptions_FieldSet");
            var params = {
                "sObjectName": "ExAM__Section_Template__c",
                "fieldSets": fieldSets,
                "sObjectId": cmp.get("v.assessementId")
            };
            window.Exam.SectionServiceComponent.fetchSecTemplateWthFldSet(params, $A.getCallback(function(sectionTemplates){
                if(cmp.isValid()){
                    cmp.set("v.hasQuriedFieldSetOfSec", true);
                    cmp.set("v.SectionTemplates", sectionTemplates);
                    var nextCmp = "SectionContainer";
                    helper.navigateSectionTab(cmp, nextCmp, helper);
                }
            }), null);
            
        }else{
            // Fetch sectionTemplate By AssessmentId
            window.Exam.SectionServiceComponent.fetchSecTemplate(cmp.get("v.assessementId"), $A.getCallback(function(sectionTemplates){
                if(cmp.isValid()){
                    cmp.set("v.SectionTemplates", sectionTemplates);
                    var nextCmp = "SectionContainer";
                    helper.navigateSectionTab(cmp, nextCmp, helper);
                }
            }), null);
        }
        
        
    },
    // Show Notification 
    showNotificationEvt : function(status, message){
        var showNotificationEvent = $A.get("e.c:notificationEvt");
        showNotificationEvent.setParams({
            "action" : status,
            "message" : message
        });
        showNotificationEvent.fire();
    },
    // fetch Assessment Record With related fieldSet value and Attachment 
    doInit : function(cmp, event, helper){
        var fieldSets = [];
        
        fieldSets.push("ExAM__lightningComp_TemplateOverview_FieldSet");
        fieldSets.push("ExAM__lightningComp_BasicOptions_FieldSet");
        fieldSets.push("ExAM__lightningComp_AdvancedOptions_FieldSet");
        
        cmp.set("v.showNavTab", true);
        
        var params = {
            "sObjectName": "ExAM__Main_questionaire__c",
            "fieldSets": fieldSets,
            "sObjectId": cmp.get("v.assessementId")
        };
        
        if (!cmp.get("v.fields")) {
            // if Fieldset is Not contain 
            window.Exam.AssessmentServiceComponent.getRecordById(params, $A.getCallback(function(ObjContainFields){
                
                if(cmp.isValid()){
                    cmp.set("v.fields", ObjContainFields.fields);
                    helper.arrangeValue(cmp, event, helper, ObjContainFields);
                }
                
            }), null);
            
        }else {
            // if FieldSet Contain
            window.Exam.AssessmentServiceComponent.getRecord(params, $A.getCallback(function(ObjContainFields){
                
                if(cmp.isValid()){
                    helper.arrangeValue(cmp,event,helper,ObjContainFields);
                }
                
            }), null);
        }
    },
    // find total No of Questions in Assessment
    calculateNoOfQuestionsByAssessments : function(cmp, sectionTemplates){
        var sectionTempLength = sectionTemplates.length;
        var countQuestion = 0;
        
        for(var i = 0 ; i < sectionTempLength; i++){
            if(sectionTemplates[i].ExAM__No_of_Questions_Section__c){
                countQuestion += sectionTemplates[i].ExAM__No_of_Questions_Section__c;
            }
        }
        
        cmp.set("v.countQuestion", countQuestion);
    },
    // create component 
    navigateSectionTab : function(cmp, nextCmp, helper){
        window.Exam.AssessmentServiceComponent.clearAssessmentContextData();
        helper.toggleSpinner(cmp);
        var templateActions = cmp.find("templateActions");
        templateActions.set("v.body", []);
        
        var attributes = {
            sectionTempLength: cmp.get("v.SectionTemplates").length,
            noOfQuestion: cmp.get("v.countQuestion"),
            SectionTemplates: cmp.getReference("v.SectionTemplates"),
            assessmentTemplate: cmp.get("v.assessmentTemplate"),
            fields: cmp.get("v.fields"),
            attachment : cmp.get("v.attachment"),
            assessmentId : cmp.get("v.assessmentTemplate").Id,
            showSection : cmp.get("v.showSection")
        };
        
        if(cmp.get("v.showSection")){
            cmp.set("v.showSection", false);
        }
        
        $A.createComponent(
            "ExAM:" + nextCmp, 
            attributes,
            function(retCmp, status, message) {
                helper.toggleSpinner(cmp);
                if(cmp.isValid() && status === "SUCCESS"){
                    var body = templateActions.get("v.body");
                    body.push(retCmp);
                    templateActions.set("v.body", body);
                }else if(cmp.isValid() && status === "ERROR"){
                    message = message.split('at org')[0];
                    helper.showNotificationEvt('error', message);
                }else if(cmp.isValid() && status === "INCOMPLETE"){
                    var errorMsg = 'No response from server or client is offline';
                    helper.showNotificationEvt('error', errorMsg);
                }
                
            });
    }, 
    toggleSpinner : function(cmp){
        var spinner_container = cmp.find("spinner_container");
        $A.util.toggleClass(spinner_container,"slds-hide");
    },
    unSaveChangeMsg : function(cmp, event, helper){
        if(!cmp.get("v.canSwitchTab")){
            var focusToEditView = $A.get("e.c:focusToEditViewEvt");
            focusToEditView.fire();
            var errorMessage = "Please save your changes before continuing.";
            helper.showNotificationEvt("error", errorMessage);
            return false;
        }
        return true;
    }
})