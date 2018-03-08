({
    doInit : function(cmp, event, helper) {
        
        window.Exam.AnswerServiceComponent = (function() {
            // Maintain AnswerOptions Data by QuestionId
            var AnswerByQuestion = {
                "_Answer" : {}
            };
            // Callback Function via related Service Component
            return {
                upsertAnswerOption : function(param, sectionId, onSuccess, onError){
                    helper.upsertAnswerOption(param, sectionId, onSuccess, onError, cmp, helper, AnswerByQuestion);
                },
                getAnswerOptions : function(questionId, onSuccess, onError){
                    
                    if(AnswerByQuestion._Answer[questionId]){
                        onSuccess(AnswerByQuestion._Answer[questionId]);
                    }else{
                        onSuccess();
                    }
                    
                },
                storeAnswersByQuestion : function(questionId, AnswerOptions){
                    AnswerByQuestion._Answer[questionId] = AnswerOptions;
                },
                clearAnswersContextData : function(){
                    AnswerByQuestion = {
                        "_Answer" : {}
                    };
                    window.Exam.AttachmentServiceComponent.clearAttachmentsContextData();
                }
            };
        }());
        
    }
})