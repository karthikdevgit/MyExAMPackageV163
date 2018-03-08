({
    // generate Component based on navigation Tab
    changeTemplateAction: function(cmp, event, helper) {
        
        var nextCmp = event.getParam("componentLink");
        var changeTab = event.getParam("changeTab");
        
        if(changeTab){
            cmp.find("tabContainer").set("v.currentComponent", nextCmp);
        }
        if(nextCmp === "ExamTemplateSummary"){
            window.Exam.SectionServiceComponent.fetchSecTemplateByCount(cmp.get("v.assessementId"), $A.getCallback(function(sectionTemplates){
                
                if(cmp.isValid()){
                    helper.calculateNoOfQuestionsByAssessments(cmp, sectionTemplates);
                    helper.navigateSectionTab(cmp, nextCmp, helper);
                }
                
            }), null);
        }else{
            helper.navigateSectionTab(cmp, nextCmp, helper);
        }
        
    },
    // Navigate to Assessment Table 
    navigateToAssessmentTable: function(cmp, event, helper) {
        if(cmp.get("v.hasName") && helper.unSaveChangeMsg(cmp, event, helper)){
            cmp.set("v.hasName", false);
            cmp.set("v.showNavTab", false);
            /*var assessmentTable = cmp.find("assessment");
            assessmentTable.contextAssessment();*/
            window.Exam.AssessmentServiceComponent.clearCurrentAssessmentContext();
            window.Exam.AssessmentServiceComponent.clearAssessmentContextData();
        }        
    },
    // Navigate To TabContainer component 
    navigateToExamMngTemplate: function(cmp, event, helper) {
        
        var assessmentId = event.getParam("assessmentId");
        var showSection = event.getParam("showSection");
        
        if(showSection){
            cmp.set("v.showSection", showSection);
        }
        
        cmp.set("v.assessementId", assessmentId);
        cmp.set("v.hasName", true);
        cmp.set("v.showNavTab", true);
        helper.doInit(cmp, event, helper);
        window.Exam.AssessmentServiceComponent.setCurrentAssessmentContext(assessmentId);
        
    },
    
    refreshData: function(cmp, event, helper) {
        var sobject = event.getParam("sObject");
        
        if (sobject.Id === cmp.get("v.assessementId")) {
            event.stopPropagation();
            var objectKeys = Object.keys(sobject);
            var fieldApi = objectKeys[1];
            if(fieldApi === 'ExAM__Template_name__c'){
                window.Exam.AssessmentServiceComponent.updateAssessmentList(sobject);
            }
            
            var assessmentTemp = cmp.get("v.assessmentTemplate");
            assessmentTemp[fieldApi] = sobject[fieldApi];
            cmp.set("v.assessmentTemplate", assessmentTemp);            
        }
        
    },
    reloadFileContent : function(cmp, event, helper){
        var attachment = event.getParam("attachment");
        if(cmp.get("v.assessementId") == attachment.ParentId){
           cmp.set("v.attachment", attachment);            
        }
        
    },
    // clear All service Component's context data when assessment Changed
    /*clearAssessmentContextDataWthRelatedRecord : function(cmp, event, helper){
        window.Exam.AssessmentServiceComponent.clearAssessmentContextData();
    },*/
    viewChange : function(cmp, event, helper){
        var selectedLabel = event.getParam("label");
        
        if(selectedLabel === 'My ExAMs' || selectedLabel === 'All ExAMs'){
            event.stopPropagation();
            if(cmp.get("v.selectedLabel") !== selectedLabel){
                var selectedValue = event.getParam("value");
                cmp.set("v.selectedView", selectedValue);
                cmp.set("v.selectedLabel", selectedLabel);
            }
        }
    },
    editStateOn : function(cmp, event, helper){
        var editCount = cmp.get("v.editCount") || 0;
        editCount++;
        if(editCount === 1){
            cmp.set("v.canSwitchTab", false);		// Unable to switch other tab
        }
        
        cmp.set("v.editCount", editCount);
    },
    viewStateOn : function(cmp, event, helper){
        var editCount = cmp.get("v.editCount");
        editCount--;
        if(editCount === 0){
            cmp.set("v.canSwitchTab", true); // able to switch other tab
        }        		
        cmp.set("v.editCount", editCount);
    },
})