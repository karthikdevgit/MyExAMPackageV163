trigger questionTemplateTrigger on Question_Template__c (before update, after insert, after update) {
    
    QuestionTemplateTriggerHandler quesTempHandler = new QuestionTemplateTriggerHandler();

    if (Trigger.isBefore && Trigger.isUpdate) {
        quesTempHandler.beforeUpdate(Trigger.OldMap, Trigger.NewMap, Trigger.New);
    }
    else if (Trigger.isAfter && Trigger.isInsert) {
        quesTempHandler.afterInsert(Trigger.New);
    }
    else if (Trigger.isAfter && Trigger.isUpdate) {
        quesTempHandler.afterUpdate(Trigger.OldMap, Trigger.NewMap, Trigger.New);
    }
}