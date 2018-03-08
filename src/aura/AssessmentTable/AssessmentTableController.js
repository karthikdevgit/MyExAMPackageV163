({
    // perform Action based on menu action 
    getAction : function(cmp, event, helper){
        var type = event.getParam("type");
        if(type === "assessmentTable"){
            event.stopPropagation();
            var action = event.getParam("action");
            if(helper.unSaveChangeMsg(cmp, event, helper)){
                var index = event.getParam("itemIndex");
                
                if(action === "cloneSobjectRecord"){
                    cmp.set("v.position", index);
                    helper.modalAction(cmp, event);
                }else if(action === "changeArchive"){
                    var AssessmentTemplates = cmp.get("v.AssessmentTemplates");
                    var selectedAssessment = AssessmentTemplates[index];
                    selectedAssessment.ExAM__isArchive__c = true;
                    helper.archiveAssessment(cmp, event, helper, selectedAssessment);
                }else{
                    cmp.set("v.recordPerPage", action);
                }
                
            }
        }
    },
    
    // fetch Assessment
    doInit: function(cmp, event, helper) {
        var user = cmp.get("v.selectView");
        
        window.Exam.AssessmentServiceComponent.getAssessmentsBasedOnView(user, $A.getCallback(function(assessments){  
            
            if(cmp.isValid()){
                cmp.set("v.totalAssessmentTemplates", assessments);
                helper.showRecords(cmp, 0, 9, assessments);
            }
            
        }),null);
    },
	// select Assessment and navigate to ExamManage 
    showAssessment : function(cmp, event, helper){
        if(helper.unSaveChangeMsg(cmp, event, helper)){
            var assessmentId = event.getSource().get("v.class");
            var navigateToExamManageEvt = cmp.getEvent("navigateToExamManage");
            navigateToExamManageEvt.setParams({
                "assessmentId" : assessmentId
            });
            navigateToExamManageEvt.fire();
        }
    },

    // show Record Based on ItemPerPage

    showRecord : function(cmp, event, helper){
        var assessments = cmp.get("v.totalAssessmentTemplates");
        var perPage = cmp.get("v.recordPerPage");        
        cmp.set("v.currentPage", 1);
        var startIndex = 0;
        var endIndex = perPage-1;
        helper.showRecords(cmp, startIndex, endIndex, assessments);
    },
	// display the Record based on page_index
    gotoPage : function(cmp, event, helper){
        var startPage = event.getParam("startPage");
        var recPerPage = cmp.get("v.recordPerPage");
        var startIndex = ((startPage-1)*recPerPage);
        var endIndex = ((startPage)*recPerPage)-1;
        var assessments = cmp.get("v.totalAssessmentTemplates");
        helper.showRecords(cmp, startIndex, endIndex, assessments);
    },

    closeModal : function(cmp, event, helper){
        cmp.set('v.template_Name', '');
        helper.modalAction(cmp, event);
    },

    saveCloneObject : function(cmp, event, helper){
        if(!cmp.get("v.template_Name") || !cmp.get("v.template_Name").trim()){
            helper.showNotificationEvt("error", "Enter New Template Name Before procceding.");
            return;
        }
        var index = cmp.get("v.position");
        var AssessmentTemplates = cmp.get("v.AssessmentTemplates");
        var recordId = AssessmentTemplates[index].Id;
        var recordName = AssessmentTemplates[index].ExAM__Template_name__c;
        helper.cloneAssessmentRecord(cmp, event, helper, recordId, recordName);
    },

    //create New Assessment 
    createNewAssessment : function(cmp, event, helper){
        helper.toggleSpinner(cmp);
        helper.toggleBtn(cmp, event);
        var newAssessment = cmp.find("addNewAssessment");
        $A.createComponent(
            "c:CreateAssessmentViewer",
            {},
            function(assessmentCapture, status, errorMessage){
				helper.toggleSpinner(cmp);
                
                if(cmp.isValid() && status === "SUCCESS") {
                    cmp.set("v.editViewOnNewAssessment", true);
                    var body = newAssessment.get("v.body");
                    body.push(assessmentCapture);
                    newAssessment.set("v.body",body);
                }else if(cmp.isValid() && status === "ERROR"){
                    errorMessage = errorMessage.split('at org')[0];
                    helper.showNotificationEvt("error", errorMessage);
                }else if(cmp.isValid() && status === "INCOMPLETE"){
                    errorMessage = "No response from server or client is offline";
                    helper.showNotificationEvt("error", errorMessage);
                }

            });
    },
   //cancel Create New Assessment if Assessment Id has not
    cancelAction : function(cmp, event, helper){
        var assessmentId = event.getParam("assessmentId");        
        cmp.set("v.editViewOnNewAssessment", false);
        // After create new Assessment, Navigate to ExamManage template for create New Section
        if(assessmentId){
            event.stopPropagation();
            var navigateToExamManageEvt = cmp.getEvent("navigateToExamManage");

            navigateToExamManageEvt.setParams({
                "assessmentId" : assessmentId,
                "showSection" : true
            });
            navigateToExamManageEvt.fire();
        }
        helper.toggleBtn(cmp, event);
    },
    //reload Assessment Table when create New Assessment 
    reloadAssesment : function(cmp, event, helper){
        var user = cmp.get("v.selectView");
        window.Exam.AssessmentServiceComponent.getAssessmentsBasedOnView(user, $A.getCallback(function(assessmentTemplate){
            if(cmp.isValid()){
                helper.toggleBtn(cmp, event);
                cmp.set("v.totalAssessmentTemplates", assessmentTemplate);
                helper.refreshAssessmentTable(cmp, event, helper);
            }
        }), null);
    },
    // sorting based on Column 
    sortByColumn : function(cmp, event, helper){
        var column =  event.currentTarget.getAttribute("data-name");
        var sorting = cmp.get("v.sorting");

        if(sorting.column !== column) {
            sorting.column = column;
            sorting.order = 'desc';
        }

        if(!sorting.order || sorting.order === 'desc'){
            sorting.order = 'asc';
        }
        else{
            sorting.order = 'desc';
        }

        var assessmentTemplates = helper.sort(cmp, sorting, column);

        if(assessmentTemplates){
            var currentPage = cmp.get("v.currentPage");
            cmp.set("v.totalAssessmentTemplates", assessmentTemplates);
            cmp.set("v.sorting", sorting);

            if(currentPage !== 1){
                currentPage = 1;
                cmp.set("v.currentPage", currentPage);
            }

            var perPage = cmp.get("v.recordPerPage");
            var startIndex = (currentPage-1)*perPage;
            var endIndex = (currentPage*perPage)-1;
            helper.showRecords(cmp, startIndex, endIndex, assessmentTemplates);
        }

    },
    /*updateLastModifiedOfContextAssessment : function(cmp, event, helper){
        window.Exam.AssessmentServiceComponent.getLastModifiedOfCurrentContextAssessment($A.getCallback(function(assessments){
            if(cmp.isValid()){
                cmp.set("v.totalAssessmentTemplates", assessments);
                var sorting = cmp.get("v.sorting");
                var assessmentTemplates = helper.sort(cmp, sorting, sorting.column);
                helper.refreshAssessmentTable(cmp, event, helper);
            }
        }), null);
    }*/

})