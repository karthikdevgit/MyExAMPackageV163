trigger CaseTrigger on Case (after update) {

    if(Trigger.New.Size() > 0 ) {
        CaseHandler.createPublicAssessmentRecords(Trigger.oldMap,Trigger.New);    
    }
}