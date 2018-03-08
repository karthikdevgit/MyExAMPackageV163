trigger AssignmentManagerTrigger on IssueRequest_Life_Cycle__c (before insert, before update, after insert, after update) {
    
    AssignmentManagerTriggerHandler amHandler = new AssignmentManagerTriggerHandler(Trigger.isExecuting, Trigger.size);
    
    if(Trigger.isBefore && Trigger.isInsert) {
        amHandler.onBeforeInsert(Trigger.new);
    } else if (Trigger.isBefore && Trigger.isUpdate) {
        amHandler.onBeforeUpdate(Trigger.old, Trigger.new, Trigger.newMap);
    } else if (Trigger.isAfter && Trigger.isInsert) {
        amHandler.onAfterInsert(Trigger.new);
    } else if (Trigger.isAfter && Trigger.isUpdate) {
        amHandler.onAfterUpdate(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap);
    }
}