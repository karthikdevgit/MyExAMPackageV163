({
    // Show Records
    showRecords : function(cmp, startIndex, endIndex, assessments){
        var min = 1;
        var noOfRecordPerPage = cmp.get("v.recordPerPage");
        var noOfAssessments = assessments.length;
        var max = Math.ceil(noOfAssessments / noOfRecordPerPage);
        cmp.set("v.max", max);
        
        var assessment_Temp = [];
        var lastIndex = assessments.length-1;
        
        if(lastIndex<endIndex){
            endIndex = lastIndex;
        }
        
        for(var i = startIndex; i <= endIndex; i++){
            
            if(assessments[i]){
                assessment_Temp.push(assessments[i]);
            }
            
        }
        cmp.set("v.AssessmentTemplates", JSON.parse(JSON.stringify(assessment_Temp)));
    },
    
    
    // clone Record
    cloneAssessmentRecord : function(cmp, event, helper, recordId, recordName){
        var template_Name = cmp.get("v.template_Name");
        
        var param = {
            "recordId" : recordId,
            "temp_name" : template_Name
        };
        var status,message;
        window.Exam.AssessmentServiceComponent.cloneAssessmentWithRelatedSections(param, $A.getCallback(function(assessmentTemplates){
            
            if(cmp.isValid()){
                cmp.set('v.template_Name', '');
                helper.modalAction(cmp, event);
                cmp.set("v.totalAssessmentTemplates", assessmentTemplates);
                status = "success";
                message = recordName +" Object cloned Success ! Here is the message to be displayed: 'Attachments are getting cloned in the background. You will be notified via email once it is done'";
                helper.showNotificationEvt(status, message);
                helper.refreshAssessmentTable(cmp, event, helper);
            }
            
            
        }), null);
    },
    // Refresh table 
    refreshAssessmentTable : function(cmp, event, helper){
        
        var assessments = cmp.get("v.totalAssessmentTemplates");
        var perPage = cmp.get("v.recordPerPage");
        var currentPage = cmp.get("v.currentPage");
        
        var startIndex = (currentPage-1)*perPage;
        var endIndex = (currentPage*perPage)-1;
        
        helper.showRecords(cmp, startIndex, endIndex, assessments);
        
    },
    // Archive Assessment
    archiveAssessment : function(cmp, event, helper, selectedAssessment){
        var status,message;
        window.Exam.AssessmentServiceComponent.archieveAssessment(selectedAssessment, $A.getCallback(function(assessmentTemplates){
            
            if(cmp.isValid()){
                cmp.set("v.totalAssessmentTemplates", JSON.parse(JSON.stringify(assessmentTemplates)));
                status = "success";
                message = "Record archived";
                helper.showNotificationEvt(status, message);
                helper.refreshAssessmentTable(cmp, event, helper);
            }
            
        }), null);
    },
    modalAction : function(cmp, event){
        var modal = cmp.find("modal");
        var backdrop = cmp.find("backdrop");
        $A.util.toggleClass(modal, "slds-fade-in-open");
        $A.util.toggleClass(backdrop, "slds-backdrop--open");
    },
    
    // show Notification based On Action
    showNotificationEvt : function(status, message){
        var showNotificationEvent = $A.get("e.c:notificationEvt");
        showNotificationEvent.setParams({
            "action" : status,
            "message" : message
        });
        showNotificationEvent.fire();
    },
    // toggle Button
    toggleBtn : function(cmp, event){
        var hideBtn = cmp.find("addBtn");
        $A.util.toggleClass(hideBtn, 'slds-hide');
    },
    // sorting
    sort : function(cmp, sorting, column){
        var assessmentTemplates = cmp.get("v.totalAssessmentTemplates");
        assessmentTemplates.sort(function (a, b) {
            
            if(sorting.order === "asc"){
                
                if (a[column] > b[column]) {
                    return 1;
                }
                else if (a[column] < b[column]) {
                    return -1;
                }
                
                return 0;
            }
            else{
                
                if (a[column] < b[column]) {
                    return 1;
                }
                else if (a[column] > b[column]) {
                    return -1;
                }
                
                return 0;
            }
            
        });
        return assessmentTemplates;
    },
    unSaveChangeMsg : function(cmp, event, helper){
        if(cmp.get("v.editViewOnNewAssessment")){
            var errorMessage = "Please save your changes before continuing.";
            helper.showNotificationEvt("error", errorMessage);
            return false;
        }
        return true;
    },
    toggleSpinner : function(cmp){
        var spinner_container = cmp.find("spinner_container");
        $A.util.toggleClass(spinner_container, "slds-hide");
    }
})