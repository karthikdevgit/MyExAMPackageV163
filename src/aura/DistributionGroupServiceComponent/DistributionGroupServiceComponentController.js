({
	doInit : function(cmp, event, helper) {
        
        window.Exam.DistributionGroupServiceComponent = (function(){
            return {
                fetchTargetObjectsWthOperators : function(onSuccess, onError){
                    helper.fetchTargetObjectsWthOperators(onSuccess, onError, cmp, event, helper);
                },
                fetchSelectedObjectGroup : function(sObjectName, onSuccess, onError){
                    helper.fetchSelectedObjectGroup(sObjectName, onSuccess, onError, cmp, event, helper);
                },
                checkCriteriaMet : function(params, onSuccess, onError){
                    helper.checkCriteriaMet(params, onSuccess, onError, cmp, event, helper);
                },
                fetchCriteriaWthCountOfRd : function(groupId, onSuccess, onError){
                    helper.fetchCriteriaWthCountOfRd(groupId, onSuccess, onError, cmp, event, helper);
                }
            }
        }());
	}
})