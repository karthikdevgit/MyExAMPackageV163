({
	scriptsLoaded : function(cmp, event, helper) {
        helper.getQuestionResponse(cmp, event, helper);
	},
    gotoPage : function(cmp, event, helper){
        var startPage = event.getParam("startPage");
        var recPerPage = 10;
        var startIndex = ((startPage-1)*recPerPage);
        var endIndex = ((startPage)*recPerPage)-1;
        helper.showRecords(cmp, event, helper, startIndex, endIndex);
    },
})