({
    doInit : function(cmp, event, helper) {
        
        // get fieldset information
        var distributionRd = cmp.get("v.distributionRd");
        var publicAssessment = distributionRd.ExAM__Public_Assessments__r ? distributionRd.ExAM__Public_Assessments__r[0] : "";
        cmp.set("v.publicAssessment", publicAssessment);
        
        
        window.Exam.DistributionServiceComponent.getFieldSet($A.getCallback(function(fields){
            
            
            cmp.set("v.validator", function(selectionDate, fieldApi){
                
                var examFld = cmp.find("examFld");
                var isValid = {
                    hasError : false,
                    errorMsg : ""
                };
                var errorMsg= '';
                if(!Array.isArray(examFld)){
                    examFld = [examFld];
                }
                for(var i = 0; i < examFld.length; i++){
                    var record = examFld[i].get("v.record");
                    if(fieldApi == "ExAM__Start_Date__c"){
                        
                        var endDate = record.ExAM__Expiration_Date__c;
                        var todayDate = getTodayDate();
                        if(endDate){
                            if(selectionDate != '' && selectionDate > endDate || selectionDate < todayDate){ // Expiration Date
                                isValid.hasError = true;
                                isValid.errorMsg = selectionDate > endDate ? 'Start Date should be less than Expiration Date' : "Please give Current or Future Date";
                            }
                        }else if(!endDate){
                            if(selectionDate != '' && selectionDate < todayDate){ // today Date
                                isValid.hasError = true;
                                isValid.errorMsg = "Please give Current or Future Date";
                            }
                        }
                    }else if(fieldApi == "ExAM__Expiration_Date__c"){
                        var startDate = record.ExAM__Start_Date__c;
                        if(!startDate){
                            startDate = getTodayDate();                            
                        }
                        if(selectionDate != '' && selectionDate < startDate) { // today Date / start Date
                            isValid.hasError = true;
                            isValid.errorMsg =  record.ExAM__Start_Date__c ? "Expiration Date should be greater than Start Date" : "Please give Current or Future Date";
                        }
                    }
                    
                    if(!isValid.hasError && fieldApi == "ExAM__Expiration_Date__c" && cmp.get("v.sendMode") != "Email with Salesforce"){
                        if(helper.validateDependencyFldValue(cmp, event, helper, fieldApi, examFld[i])){
                            return isValid;
                        }
                    }else{
                        return isValid;
                    }
                    
                    //break;
                    
                }
                
                function getTodayDate(){
                    var today = new Date();        
                    var dd = today.getDate();
                    var mm = today.getMonth() + 1; //January is 0!
                    var yyyy = today.getFullYear();
                    // if date is less then 10, then append 0 before date   
                    if(dd < 10){
                        dd = '0' + dd;
                    } 
                    // if month is less then 10, then append 0 before date    
                    if(mm < 10){
                        mm = '0' + mm;
                    }
                    return yyyy+'-'+mm+'-'+dd;
              
                }
               
                
            });
            
            cmp.set("v.fields", fields);
        }));
    },
    clearPanel : function(cmp, event, helper){
        cmp.set("v.wizardName", 'DistributionListView');
    },
    doValidate : function(cmp, event, helper){
        
        var fields =   cmp.get("v.fields");
        for(var i = 0; i < fields.length; i++){
            if(fields[i].fieldApi == "ExAM__Expiration_Date__c"){
                if(cmp.get("v.sendMode") == "Email with Salesforce"){
                    i--;
                }
                var examFld = cmp.find("examFld");
                if(!Array.isArray(examFld)){
                    examFld = [examFld];
                }
                var isValid = examFld[i].get("v.isValid");
                break;
            }
        }
        return isValid;
    },
    handleDestroy : function(cmp, event, helper){
        var distributionRd = cmp.get("v.distributionRd");
        if(distributionRd){
            distributionRd.ExAM__Start_Date__c = null;
            distributionRd.ExAM__Expiration_Date__c = null;
            cmp.set("v.distributionRd", distributionRd);
        }
    }
})