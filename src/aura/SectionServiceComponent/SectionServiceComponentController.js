({
    doInit : function(cmp, event, helper) {
		
        window.Exam.SectionServiceComponent = (function() {
            var sectionByAssessment = {
                "_Sections" : {},
                "_Fields" : {}
            }

            return {
                fetchFieldSet : function(onSuccess, onError){
                    if(sectionByAssessment._Fields){
                        onSuccess(sectionByAssessment._Fields);
                    }
                },
                fetchSecTemplateWthFldSet : function(params, onSuccess, onError){
                    helper.fetchSecTemplateWthFldSet(params, onSuccess, onError, sectionByAssessment, cmp, helper);
                },
                fetchSecTemplate : function(assessmentId, onSuccess, onError){                    
                    if(sectionByAssessment._Sections[assessmentId]){
                        onSuccess(sectionByAssessment._Sections[assessmentId]);
                    }else{
                        helper.fetchSecTemplate(assessmentId, onSuccess, onError, sectionByAssessment, cmp, helper);
                    }
                },
                moveSectionUpOrDwn : function(param, onSuccess, onError){
                    helper.moveSectionUpOrDwn(param, onSuccess, onError, sectionByAssessment, cmp, helper);
                },
                createSection : function(param, onSuccess, onError){
                    helper.createSection(param, onSuccess, onError, sectionByAssessment, cmp, helper);
                },
                updateRecord : function(param, onSuccess, onError){
                    helper.updateRecord(param, onSuccess, onError, sectionByAssessment, cmp, helper);
                },
                archiveSection : function(param, onSuccess, onError){
                    helper.archiveSection(param, onSuccess, onError, sectionByAssessment, cmp, helper);
                },
                moveSection : function(param, onSuccess, onError){
                 helper.moveSection(param, onSuccess, onError, sectionByAssessment, cmp, helper);
                },
                copySection : function(param, sectionIndex, onSuccess, onError){
                 helper.copySection(param, sectionIndex, onSuccess, onError, sectionByAssessment, cmp, helper);
                },
                fetchSecTemplateByCount : function(assessmentId, onSuccess, onError){
                    helper.fetchSecTemplate(assessmentId, onSuccess, onError, sectionByAssessment, cmp, helper);
                },
                clearSectionsContextData : function(){
                    sectionByAssessment["_Sections"] = {};
                    window.Exam.QuestionServiceComponent.clearQuestionsContextData();
                }

            };
        }());

    }
})