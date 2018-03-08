({
    doInit : function(cmp, event, helper) {
        
        window.Exam.EmailTemplateServiceComponent.getDailyEmailLimit($A.getCallback(function(response){
            if(response.remaining >= -5 && response.remaining < 0){
                response.remaining = 0;
            }
            cmp.set("v.emailDailyLtd", response);
            var cmpName = cmp.get("v.wizardName");
            // passing attributes as params to their cmps
            if(cmpName){
                if(cmpName == "DistributionOptionsViewer"){
                    var params = {
                        "distributionRd" : cmp.get("v.distributionRd"),
                        "mode" : "edit",
                        "defaultMode" : "view",
                        "newField" : false,
                        "wizardName" : cmp.getReference("v.wizardName")
                    };
                }else{
                    var params = {
                        "wizardName" : cmp.getReference("v.wizardName"),
                        "assessmentId" : cmp.get("v.assessmentId"),
                        "emailDailyLtd" : cmp.get("v.emailDailyLtd")
                    };
                }
                
                helper.generateCmp(cmp, event, helper, cmpName, params);
                
            }
        }), null);
    },
    generateOptionsViewer : function(cmp, event, helper){
        cmp.set("v.distributionRd", event.getParam("distributionRd")); // set as context record, when navigate to optionsViewer via listView.
        //console.log("distri::::",event.getParam("distribution"));
        cmp.set("v.wizardName", "DistributionOptionsViewer");
    }
})