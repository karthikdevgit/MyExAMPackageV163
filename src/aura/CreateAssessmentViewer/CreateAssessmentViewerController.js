({
    
    // cancel create New Assessment 
    cancel: function(cmp, event, helper) {
        var cancelCreateNewAss = cmp.getEvent("cancelCreateAssessmentEvt");
        cancelCreateNewAss.fire();
        helper.destroyCmp(cmp);
    },
    // Save create New Assessment 
    saveAssessmentTemplate: function(cmp, event, helper) {
        
        var assessmentTemplate = cmp.get("v.AssessmentTemplate");
        assessmentTemplate.ExAM__Template_name__c = assessmentTemplate.ExAM__Template_name__c.trim();
        //Assessment Template Name Is Required  
        if (assessmentTemplate.ExAM__Template_name__c) {
            assessmentTemplate.sobjectType = "ExAM__Main_questionaire__c";
            
            var param = {
                "AssessmentTemplate": assessmentTemplate
            };
            
            window.Exam.AssessmentServiceComponent.createNewAssessment(param, $A.getCallback(
                function(assessmentId) {
                    
                    if(cmp.isValid()){
                        var status = "success";
                        var message = "ExAM created successfully";
                        var time = 5000;
                        helper.showNotificationEvt(status, message, time);
                        
                        var cancelCreateNewAss = cmp.getEvent("cancelCreateAssessmentEvt");
                        cancelCreateNewAss.setParams({
                            "assessmentId": assessmentId
                        });
                        cancelCreateNewAss.fire();
                        helper.destroyCmp(cmp);
                    }
                    
                }), null);
        } else {
            var status = "warning";
            var message = "Please enter a name to continue";
            var time = 5000;
            helper.showNotificationEvt(status, message, time);
        }
    }
})