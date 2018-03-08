({
    doInit : function(cmp, event, helper) {
        var currentAssessmentTemp = window.Exam.AssessmentServiceComponent.getCurrentAssessmentContext();
        var user = window.Exam.AssessmentServiceComponent.getSelectedView();
        var assessmentId = currentAssessmentTemp.Id;

        window.Exam.AssessmentServiceComponent.getAssessmentsBasedOnView(user, $A.getCallback(function(assessmentTemplates){

            if(cmp.isValid()){
                var assessmentKeys = ["ExAM__Template_name__c", "Id"];
                cmp.set("v.assessmentsName", helper.setDropDownValue(cmp, assessmentTemplates, assessmentKeys, "assessments", assessmentId));
                cmp.set("v.assessmentId", assessmentId);
            }

        }), null);
    },
    getAction : function(cmp, event, helper){
        var type = event.getParam("type");
        
        if(type === "SectionCopier"){
            event.stopPropagation();
            var label = event.getParam("name");
            var value = event.getParam("value");
            var text = event.getParam("label");
            
            if(label === "direction"){
                cmp.set("v.sel_Direction", value);
                cmp.set("v.nameOfSelectedDirection", text);
            }else if(label === "assessments"){
                cmp.set("v.assessmentId", value);
                cmp.set("v.nameOfSelectedAssessment", text);
            }else if(label === "sections"){
                cmp.set("v.sectionId", value);
                cmp.set("v.nameOfSelectedSection", text);
            }
            
        }
    },
    changeAssessmentTemp : function(cmp, event, helper){
        var assessmentId = cmp.get("v.assessmentId");
        cmp.set("v.nameOfSelectedSection", '--None--');
        helper.fetchSectionByAssessmentId(cmp, event, helper, assessmentId);
    },
    selectedSection : function(cmp, event, helper){
        var sectionTemplates = cmp.get("v.sectionTemplates");
        var sectionId = cmp.get("v.sectionId");
        
        for(var i = 0; i < sectionTemplates.length; i++){

            if(sectionTemplates[i].Id === sectionId){
                cmp.set("v.sectionIndex", i);
                cmp.set("v.sectionOrderNo", sectionTemplates[i].ExAM__Order_No__c - 1);
            }

        }

    },
    saveRecord : function(cmp, event, helper){

        var sectionIndex = cmp.get("v.sectionIndex");
        var assessmentId = cmp.get("v.assessmentId");
        var status, message, time;
        var selectedSection = cmp.get("v.nameOfSelectedSection");
        if(selectedSection == '--None--' && cmp.get("v.sectionsName").length == 1 || selectedSection != '--None--'){

            if(selectedSection != '--None--' && sectionIndex < 0){
                status = "error";
                message = "Please choose a valid assessment";
                time = null;
                helper.showNotificationEvt(cmp, status, message, time);
            }else{
                var sel_Direction = cmp.get("v.sel_Direction");
                var index = cmp.get("v.sectionOrderNo");
                if(selectedSection == '--None--' && sel_Direction == "After"){
                    sel_Direction = "Before";
                    
                }
                if(cmp.get("v.sectionsName").length == 1){
                    index = 0;
                }
                var sectionId = cmp.get("v.copySectionId");
                var param = {
                    'toassessmentId' : assessmentId,
                    'direction' : sel_Direction,
                    'index' : index,
                    'recordId' : sectionId
                };
                

               window.Exam.SectionServiceComponent.copySection(param, sectionIndex, $A.getCallback(function(){
                   
                   if(cmp.isValid()){
                       helper.destoryCmp(cmp, event, helper);
                       status = "success";
                       message = "Section copied successfully";
                       time = null;
                       helper.showNotificationEvt(cmp,status,message,time);
                   }
                   

                }), null);
            }

        }else{
            status = "error";
            message = "Please choose a valid assessment";
            time = null;
            helper.showNotificationEvt(cmp, status, message, time);
        }

    },
    cancelSectionCopy : function(cmp, event, helper){
        helper.destoryCmp(cmp, event, helper);
    }
})