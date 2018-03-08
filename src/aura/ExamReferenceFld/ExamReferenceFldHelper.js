({
    getSelectionQuestionLabel : function(cmp, event, helper, questionList, singleNextQuestionId) {
        var newValue = '';
        for(var i = 0; i < questionList.length; i++){
            if(singleNextQuestionId == questionList[i].Id){
                newValue = questionList[i].ExAM__Question_Label__c;
                break;
            }
        }
        return newValue;
    }
})