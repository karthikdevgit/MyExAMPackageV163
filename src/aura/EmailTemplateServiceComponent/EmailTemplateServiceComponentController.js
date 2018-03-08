({
	doInit : function(cmp, event, helper) {
        
        window.Exam.EmailTemplateServiceComponent = (function() {
            
            return{
                fetchEmailTemplates: function(onSuccess, onError){
                    helper.fetchEmailTemplates(onSuccess, onError, cmp, event, helper);
                },
                getDailyEmailLimit : function(onSuccess, onError){
                    helper.getDailyEmailLimit(onSuccess, onError, cmp, event, helper);
                }
            };
        
        }());			
	}
})