({
    doInit : function(cmp, event, helper) {
        
        window.Exam.AssessmentServiceComponent = (function() {
            // Maintain Assessment Data by assessmentId 
            var data = {
                "currentView" : '',
                //"AssessmentsList" : [],
                "_Assessments" : {},
                "_currentAssessment" : {},
                "AssessmentListOnView" : {
                    "Current_User" : [],
                    "All" : []
                }
            }
            // Callback Function via related Service Component
            return {
                /*getAssessmentsByCurrentUser : function(onSuccess, onError){
                    if(data.AssessmentsList.length){
                        onSuccess(data.AssessmentsList);
                    }else{
                        helper.getAssessmentsByCurrentUser(onSuccess, onError, data, cmp, helper);
                    }
                },*/
                cloneAssessmentWithRelatedSections : function(param, onSuccess, onError){
                    helper.cloneAssessmentWithRelatedSections(param, onSuccess, onError, data, cmp, helper);
                },
                archieveAssessment : function(selectedAssessment, onSuccess, onError){
                    helper.archieveAssessment(selectedAssessment, onSuccess, onError, data, cmp, helper);
                },
                getRecordById : function(params, onSuccess, onError){
                    
                    if(data._Assessments[params.sObjectId]){
                        onSuccess(data._Assessments[params.sObjectId]);
                    }else{
                        helper.getRecordById(params, onSuccess, onError, data, cmp, helper);
                    }
                    
                },
                getRecord : function(params, onSuccess, onError){
                    
                    if(data._Assessments[params.sObjectId]){
                        onSuccess(data._Assessments[params.sObjectId]);
                    }else{
                        helper.getRecord(params, onSuccess, onError, data, cmp, helper);
                    }
                    
                },
                updateRecord : function(param, onSuccess, onError){
                    helper.updateRecord(param, onSuccess, onError, data, cmp, helper);
                },
                updateAssessmentList : function(sobject){
                    helper.updateAssessmentList(sobject, data, cmp);
                },
                uploadFileToSerever : function(param, onSuccess, onError){
                    window.Exam.AttachmentServiceComponent.uploadFileToSerever(param, onSuccess, onError, data);
                },
                createNewAssessment : function(param, onSuccess, onError){
                    helper.createNewAssessment(param, onSuccess, onError, data, cmp, helper);
                },
                getCurrentAssessmentContext : function(){
                    return data._currentAssessment;
                },
                setCurrentAssessmentContext : function(assessmentId){
                    helper.setCurrentAssessmentContext(assessmentId, data);
                },
                clearCurrentAssessmentContext : function(){
                    helper.clearCurrentAssessmentContext(data);
                },
                clearAssessmentContextData : function(){
                    data._Assessments = {};
                    //data._currentAssessment = {};
                    window.Exam.SectionServiceComponent.clearSectionsContextData();
                },
                getAssessmentsBasedOnView : function(user, onSuccess, onError){
                    if(data.AssessmentListOnView[user].length){
                        onSuccess(data.AssessmentListOnView[user]);
                    }else{
                        helper.getAssessmentsBasedOnView(user, onSuccess, onError, data, cmp, helper);
                    }
                }, 
                getSelectedView : function(){
                    return data.currentView; 
                },
                getLastModifiedOfCurrentContextAssessment : function(onSuccess, onError){
                   helper.getLastModifiedOfCurrentAssessment(onSuccess, onError, data, cmp, helper);
                }
            };
        }());
    }
})