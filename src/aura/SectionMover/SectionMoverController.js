({
    doInit : function(cmp, event, helper) {
        var currentAssessmentTemp = window.Exam.AssessmentServiceComponent.getCurrentAssessmentContext();
        var user = window.Exam.AssessmentServiceComponent.getSelectedView();
        var assessmentId = currentAssessmentTemp.Id;
        cmp.set("v.currentAssessmentId", assessmentId);
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
        
        if(type === "SectionMover"){
            event.stopPropagation();
            var label = event.getParam("name");
            var value = event.getParam("value");
            var text = event.getParam("label");
            
            if(label === "direction"){
                cmp.set("v.sel_Direction", value);
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
    saveRecord : function(cmp,event,helper){
        var newAssessmentId = cmp.get("v.assessmentId");
        var currentAssessmentId = cmp.get("v.currentAssessmentId");
        var sectionIndex = cmp.get("v.sectionIndex");
        var sel_Direction = cmp.get("v.sel_Direction");
        var hasError = false;
        var status,message,time;
        var selectedSection = cmp.get("v.nameOfSelectedSection");
        if(selectedSection == '--None--' && cmp.get("v.sectionsName").length == 1 || selectedSection != '--None--'){
            if(newAssessmentId === currentAssessmentId){
                
                if((sectionIndex < 0 || sectionIndex === cmp.get("v.indexPos")) ||
                   (sectionIndex === cmp.get("v.indexPos")+1 && sel_Direction === 'Before') ||
                   (sectionIndex === cmp.get("v.indexPos")-1 && sel_Direction === 'After')){
                    status = "error";
                    message = "please choose valid assessment or section";
                    time = null;
                    hasError = true;
                    helper.showNotificationEvt(cmp,status,message,time);
                }
                
                newAssessmentId = null;
            }
            
            
            
            if(!hasError){
                if(selectedSection == '--None--' && sel_Direction == "After"){
                    sel_Direction = "Before";
                }
                var index = cmp.get("v.sectionOrderNo");
                if(cmp.get("v.sectionsName").length == 1){
                    index = 0;
                }
                sectionIndex = cmp.get("v.sectionIndex");
                var sectionId = cmp.get("v.moveSectionId");
                
                var param = {
                    'oldAssessmentId' : currentAssessmentId,
                    'newAssessmentId' : newAssessmentId,
                    'direction' : sel_Direction,
                    'index' : index,
                    'recordId' : sectionId
                };
                
                window.Exam.SectionServiceComponent.moveSection(param, $A.getCallback(function(){
                    
                    if(cmp.isValid()){
                        helper.destoryCmp(cmp, event, helper);
                        status = "success";
                        message = "section Move successfully";
                        time = null;
                        helper.showNotificationEvt(cmp,status,message,time);
                    }
                    
                }), null);
            }
        }else{
            status = "error";
            message = "please choose valid assessment or section";
            time = null;
            helper.showNotificationEvt(cmp,status,message,time);
        }
        

    },
    cancelSectionMove : function(cmp,event,helper){
        helper.destoryCmp(cmp, event, helper);
    }
})