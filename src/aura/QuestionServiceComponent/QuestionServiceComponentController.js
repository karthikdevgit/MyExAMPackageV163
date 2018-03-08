({
    doInit: function(cmp, event, helper) {
        
        window.Exam.QuestionTypeServices = function() {
            var questionTypes = [];
            var self = this;
            return {
                fetchQuestionTypes: function(callback) {
                    var action = cmp.get("c.getQuestionType");
                    
                    action.setCallback(this, function(response) {
                        var state = response.getState();
                        if (cmp.isValid() && state === "SUCCESS") {
                            self.questionTypes = response.getReturnValue();
                        }else if(cmp.isValid() && state === "ERROR"){
                            helper.buildErrorMsg(cmp, helper, response.getError(), null);
                        }else if(cmp.isValid() && state === "INCOMPLETE"){
                            helper.buildOffLineMsg(cmp, helper, null);
                        }
                    });
                    
                    $A.enqueueAction(action);
                },
                getQuestionTypes: function() {
                    return self.questionTypes;
                }
            };
        }
        window.Exam.QuestionTypeServices().fetchQuestionTypes();
        
        
        
        window.Exam.QuestionServiceComponent = (function() {
            var questionBySection = {
                "_NonDependentQuestions": {},
                "_Fields" : {},
                "_Questions" : {}
            };
            
            return {
                fetchFieldSet : function(onSuccess, onError){
                    if(questionBySection._Fields){
                        onSuccess(questionBySection._Fields);
                    }
                },
                getQuestionBySectionId : function(param, dependent,  onSuccess, onError){
                    
                    if(!dependent && questionBySection._NonDependentQuestions[param.sObjectId]){
                        onSuccess(questionBySection._NonDependentQuestions[param.sObjectId]);
                    }else{
                        helper.fetchQuestionTemplates(param, onSuccess, onError, questionBySection, cmp, helper);
                    }
                    
                },
                moveQuestion: function(param, onSuccess, onError) {
                    helper.moveQuestion(param, onSuccess, onError, questionBySection, cmp, helper);
                },
                copyQuestion: function(param, position, onSuccess, onError) {
                    helper.copyQuestion(param, position, onSuccess, onError, questionBySection, cmp, helper);
                },
                updateQuestion: function(QuestionTemplate) {
                    helper.updateQuestion(QuestionTemplate, questionBySection, cmp);
                },
                createNewQuestion: function(param, position, hasDependent, onSuccess, onError) {
                    helper.createNewQuestion(param, position, hasDependent, onSuccess, onError, questionBySection, cmp, helper);
                },
                updateRecord: function(param, sectionId, onSuccess, onError) {
                    helper.updateRecord(param, sectionId, onSuccess, onError, questionBySection, cmp, helper);
                },
                copyQuestionWithImage: function(param, position, onSuccess, onError) {
                    helper.copyQuestionWithImage(param, position, onSuccess, onError, questionBySection, cmp, helper);
                },
                deleteQuestion: function(Question, onSuccess, onError) {
                    helper.deleteQuestion(Question, onSuccess, onError, questionBySection, cmp, helper);
                },
                updateQuestionTemplate: function(sectionId, QuestionTemplates) {
                    questionBySection._NonDependentQuestions[sectionId] = QuestionTemplates;
                },
                upsertAnswerOption: function(sectionId, questionId, answerOptions) {
                    helper.upsertAnswerOption(sectionId, questionId, answerOptions, questionBySection, cmp, helper);
                },
                fireQuestionEvt: function(sectionId, dependent) {
                    helper.fireQuestionChangedEvt(sectionId, dependent);
                },
                getFieldSet: function(params, onSuccess, onError) {
                    helper.getFieldSet(params, onSuccess, onError, cmp, helper);
                },
                clearQuestionsContextData : function(){
                    questionBySection = {
                        "_NonDependentQuestions": {},
                        "_Fields" : {},
                        "_Questions" : {}
                    };
                    window.Exam.AnswerServiceComponent.clearAnswersContextData();
                },
                getQuestionsBySectionId : function(sectionId, questionId, onSuccess){
                    
                    if(questionBySection._Questions[sectionId]){
                        var questions = JSON.parse(JSON.stringify(questionBySection._Questions[sectionId]));
                        if(questionId){
                            helper.getQuestionsWthOutConetxtQuestion(questions, questionId);  
                        }
                        onSuccess(questions);
                    }else{
                        helper.getQuestionsBySectionId(sectionId, questionId, onSuccess, questionBySection, cmp, helper);
                    }
                },
                getQuestionsByChangeQuestionsTemp : function(sectionId, onSuccess, onError){
                    if(questionBySection._Questions[sectionId]){
                        helper.getQuestionsByChangeQuestionsTemp(sectionId, onSuccess, onError, questionBySection, cmp, helper);
                    }else{
                        onSuccess();
                    }
                },
                getdependencyQuestionLabel : function(dependencyQuestionsName, onSuccess, onError){
                    helper.getdependencyQuestionLabel(dependencyQuestionsName, onSuccess, onError, cmp, helper);
                },
                uploadFileToSerever : function(param, onSuccess, onError){
                    window.Exam.AttachmentServiceComponent.uploadQuestionImage(param, onSuccess, onError);
                },
            };
        }());
        
    }
})