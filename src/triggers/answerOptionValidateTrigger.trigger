trigger answerOptionValidateTrigger on Answer_Option__c (before insert,before update) {
    
    AnswerOptionHandler ansOptObj = new AnswerOptionHandler();
    if ( Trigger.isInsert ) {
         ansOptObj.insertValidation(Trigger.New);
    }
    if ( Trigger.isUpdate ){
        ansOptObj.updateValidation(Trigger.New,Trigger.oldMap);
    }
}