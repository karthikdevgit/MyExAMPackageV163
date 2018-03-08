({
    doInit : function(cmp, event, helper) {
        window.Exam.AssessableObjects = function() {
            var assessableObjects = [];
            var self = this;
            return {
                fetchAssessableObjects: function(callback) {
                    var action = cmp.get("c.getAssessableObjectDetails");
                    action.setParams({
                        "sObjectApiName" : "IssueRequest_Life_Cycle__c" 
                    });
                    action.setCallback(this, function(response) {
                        var state = response.getState();
                        if (cmp.isValid() && state === "SUCCESS") {
                            console.log(":::",response.getReturnValue());
                            self.assessableObjects = response.getReturnValue();
                        }else if(cmp.isValid() && state === "ERROR"){
                            //helper.buildErrorMsg(cmp, helper, response.getError(), null);
                        }else if(cmp.isValid() && state === "INCOMPLETE"){
                            //helper.buildOffLineMsg(cmp, helper, null);
                        }
                    });
                    
                    $A.enqueueAction(action);
                },
                getAssessableObjects: function() {
                    return self.assessableObjects;
                }
            };
        }
        window.Exam.AssessableObjects().fetchAssessableObjects();
        
        window.Exam.DistributionServiceComponent  = (function() {
            var data = {
                "fieldset" : []
            };
            
            return{
                fetchDistributions : function(param, onSuccess, onError){
                    if(data.fieldset.length){
                        helper.fetchDistribution(param.assessmentId, onSuccess, onError, cmp, event, helper);
                    }else{
                        helper.getDistributionsWthFieldSet(param, onSuccess, onError, cmp, event, helper, data);
                    }
                    
                },
                getFieldSet : function(onSuccess){
                    onSuccess(data.fieldset);
                },
                cloneDistribution : function(distributionId,onSuccess, onError){
                    helper.cloneDistribution(distributionId, onSuccess, onError, cmp, event, helper);
                },
                archiveDistribution : function(distributionId,onSuccess, onError){
                	helper.archiveDistribution(distributionId, onSuccess, onError, cmp, event, helper);    
                },
                deleteDistribution : function(distributionId,onSuccess, onError){                	
                    helper.deleteDistribution(distributionId, onSuccess, onError, cmp, event, helper);    
                },
                createDistributionWthPALink : function(param, onSuccess, onError){
                    helper.createDistributionWthPALink(param, onSuccess, onError, cmp, event, helper);
                },
                updateRecord : function(param, onSuccess, onError){
                    helper.updateRecord(param, onSuccess, onError, cmp, event, helper);
                }
            };   
        }());        
    }
})