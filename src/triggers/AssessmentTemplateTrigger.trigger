trigger AssessmentTemplateTrigger on Main_questionaire__c (before update) {

    if (Trigger.isBefore && Trigger.isUpdate) {
        AssessmentTemplateTriggerHandler.onBeforeUpdate(trigger.oldMap, trigger.newMap, trigger.new);
    }
}