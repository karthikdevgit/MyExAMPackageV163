({
    doInit : function(cmp, event, helper){
        /*console.log("hai:::");
        var wizardNames = [{cmpLink :"AnonymousLink",  cmpName : "Anonymous Link"},
                           {cmpLink :"PersonalLink",  cmpName : "Personal Link"},
                           {cmpLink :"DistributionListView",  cmpName : "Distribution ListView"}];
        cmp.set("v.wizardNames", wizardNames);
        console.log("wizardNames:::",wizardNames);*/
        var fieldSets = [];
        fieldSets.push('ExAM__LightningCmp_Distribution_FieldSet');
        var param = {
            "assessmentId" : cmp.get("v.assessmentId"),
            "fieldSets" : fieldSets,
            "sObjectName" : "ExAM__Distribution__c"
        }
        window.Exam.DistributionServiceComponent.fetchDistributions(param, $A.getCallback(function(distributions){            
            cmp.set("v.distributions", distributions);
        }), null);
    },
	handleSelect : function(cmp, event, helper) {
        
        var distributions = cmp.get('v.distributions');
		var actionIndex = event.getParam('value');
        var splitValuesOfActionIndex = actionIndex.split('~');
        var distributionIndex = parseInt(splitValuesOfActionIndex[0]);
        var distributionId = cmp.get('v.distributions')[distributionIndex].Id;
        var action = splitValuesOfActionIndex[1];
        if(action == 'Clone'){
            
            window.Exam.DistributionServiceComponent.cloneDistribution(distributionId, $A.getCallback(function(returnDistribution){
                
            }),null);
            
        } else if(action =='Archive'){
            
            window.Exam.DistributionServiceComponent.archiveDistribution(distributionId, $A.getCallback(function(){
                helper.distributionSplice(cmp, event, helper, distributionIndex);
                helper.showNotificationEvt(cmp, "success", "Record archived", null);
            }),null);
            
        } else{
            
            window.Exam.DistributionServiceComponent.deleteDistribution(distributionId, $A.getCallback(function(){
                helper.distributionSplice(cmp, event, helper, distributionIndex);
                helper.showNotificationEvt(cmp, "success", "Record deleted", null);
            }),null);
            
        }       
	},
    getContextDist_Record : function(cmp, event, helper){
        var index = event.currentTarget.getAttribute('data-index');
        var distributions = cmp.get('v.distributions');
		var selectedRecord = cmp.getEvent("selectedRecord");
        selectedRecord.setParams({
            "distributionRd" : distributions[index]
        });
        selectedRecord.fire();
    },
    createNewDistribution : function(cmp, event, helper){
        cmp.set("v.wizardName", "DistributionBuilder");
    }
    /*wizardNameSelection : function(cmp, event, helper){
        var wizard = event.getParam("value");
        var wizardNames = cmp.get("v.wizardNames");
        wizardNames.forEach(function(wizardName){
            if(wizard == wizardName.cmpLink){
                var NameOfwizard = cmp.get("v.wizardName");
                NameOfwizard["cmpLink"] = wizardName.cmpLink;
                NameOfwizard["cmpName"] = wizardName.cmpName;
                console.log("NameOfwizard::",NameOfwizard);
                cmp.set("v.wizardName", NameOfwizard);
            }
        });
    }*/
})