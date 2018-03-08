({
    showTemplateOptions: function(cmp, event, helper) {
        helper.fireEventHelper(cmp, event, "ExamTemplateOptionsEdit");
        
    },
    showEditQuestions : function(cmp, event, helper){
        helper.fireEventHelper(cmp, event, "SectionContainer");
    }
})