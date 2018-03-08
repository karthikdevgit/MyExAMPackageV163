({
    validateDependencyFldValue : function(cmp, event, helper, fieldApi, examFld) {
        var hasValid = false;
        var dateFld = examFld.find("dateFld");
        if(fieldApi == "ExAM__Start_Date__c" && examFld.get("v.fieldName") == "ExAM__Expiration_Date__c"){
            if(dateFld){
                dateFld.validateValues();
            }
            hasValid = true;
            
        }else if(fieldApi == "ExAM__Expiration_Date__c"  && examFld.get("v.fieldName") == "ExAM__Start_Date__c"){
            if(dateFld){
                dateFld.validateValues();
            }
            hasValid = true;
        }
        return hasValid;
    }
})