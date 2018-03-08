({
    doInit : function(cmp, event, helper) {
        var distribution = {
            "Name" : "",
            "ExAM__Assessment_Template__c" : cmp.get("v.assessmentId"),
            "ExAM__Start_Date__c" : "",
            "ExAM__Expiration_Date__c" : "",
            "ExAM__Landing_Page__c" : "",
            "ExAM__Post_Assessment_Message__c" : "",
            "ExAM__Type__c" : "Anonymous Link",
            "ExAM__Send_Mode__c" : "",
            "ExAM__Assessable_Record__c" : "",
            "ExAM__Assessable_Object_API__c" : "",
            "ExAM__Email_Template__c" : "",
            "ExAM__Distribution_DateTime__c" : "",
            "ExAM__Pre_Assessment_Message__c" : "",
            "ExAM__Target_Object_Ids__c" : "",
            "ExAM__Distribution_DateTime__c" : ""
        };
        
        cmp.set("v.distributionRd", distribution); // set distribution obj instance
        cmp.set("v.nameOfObjs.assessableObjs", window.Exam.AssessableObjects().getAssessableObjects());
    },
    createObjSelected : function(cmp, event, helper){
        var hasEnabled = cmp.get("v.hasEnabled");
        var action = event.getSource().get("v.label");
         var buttonId = event.getSource().getLocalId();
        if(!($A.util.hasClass(cmp.find(buttonId),'activeBtn'))){
            if(cmp.get("v.enabledViewers").audience && !hasEnabled.prompt){
                hasEnabled.prompt = true;
                hasEnabled.label = action;
                cmp.set("v.hasEnabled", hasEnabled);
                return true;
            }
            helper.selectAssessableObjMode(cmp, event, helper, action);
        }
    },
    assessableObjSelection : function(cmp, event, helper){
        
        var selectedAssessableObjApiWthIndex = event.getParam("value");
        if(selectedAssessableObjApiWthIndex){
            var selectedAssessableObjApi = selectedAssessableObjApiWthIndex.split('~')[0];
            var index = selectedAssessableObjApiWthIndex.split('~')[1];
            var assessableObjList = cmp.get("v.nameOfObjs").assessableObjs;
            
            if(assessableObjList[index].assObjApiName == selectedAssessableObjApi){
                helper.clearSelc_AssRd(cmp, event, helper);
                var selectedAssessableObject = cmp.get("v.selectedObjInfo").assessableObj;
                selectedAssessableObject["assObjApiName"] = assessableObjList[index].assObjApiName;
                selectedAssessableObject["assObjLabel"] = assessableObjList[index].assObjLabel;
                selectedAssessableObject["assObjFieldApi"] = assessableObjList[index].assObjFieldApi;
                cmp.set("v.selectedObjInfo.assessableObj", selectedAssessableObject);
                cmp.set("v.distributionRd.ExAM__Assessable_Object_API__c", selectedAssessableObject.assObjApiName);
            }
            
        }
    },
    enableSendersInfo : function(cmp, event, helper){
        var enabledViewers = cmp.get("v.enabledViewers");
        if(!enabledViewers.audience){
            enabledViewers.audience = true;
            cmp.set("v.enabledViewers", enabledViewers); 
        }
        
    },
    cancel : function(cmp, event, helper){
        cmp.set("v.wizardName", "DistributionListView");
    },
    saveDistr : function(cmp, event, helper){
        var distributionRd = cmp.get("v.distributionRd");
        var distroName = distributionRd.Name;
        var distroNameCmp = cmp.find("distroName");
        
        if(!distroName.trim()){
            if(!$A.util.hasClass(distroNameCmp, "slds-has-error")){
                $A.util.addClass(distroNameCmp, "slds-has-error");
                distroNameCmp.set("v.errors", [{"message" : "Please complete this field"}]);
            }
        }else if($A.util.hasClass(distroNameCmp, "slds-has-error")){
            $A.util.removeClass(distroNameCmp, "slds-has-error");
            distroNameCmp.set("v.errors", []);
        }
        
        
        var assessbleRdSelc = cmp.get("v.actionSelections").assessableRcd;
        
        if(assessbleRdSelc){
            var lookupHasError = cmp.find("lookupCmp").validate();
        }
        var audienceHasError = cmp.find("audience").validate();
        var distr_typeHasError = cmp.find("distr_type").validate();
        var isValid = cmp.find("dist_OptsViewer").validate();
        
        
        if(lookupHasError || audienceHasError || distr_typeHasError || !distroName || !isValid){
            helper.showNotificationEvt(cmp, "error", "Review errors on this page", null);
        }else{
            
            var selectedObjInfo = cmp.get("v.selectedObjInfo");
            if(assessbleRdSelc){
                distributionRd.ExAM__Assessable_Record__c = selectedObjInfo.assessableRcd.Id;
            }
            
            
            if(selectedObjInfo.emailTemplate.Id){
                distributionRd.ExAM__Email_Template__c = selectedObjInfo.emailTemplate.Id;
            }
            
            cmp.find("audience").setGroupInstance();
            var params = {
                "distributionObj" : distributionRd,
                "distributionGroupObj" : cmp.find("audience").get("v.distributionGroupRd")
            }
            
            window.Exam.DistributionServiceComponent.createDistributionWthPALink(params, $A.getCallback(function(){
                cmp.set("v.wizardName", "DistributionListView");
            }), null);
        }
        
    },
    destroyChilds : function(cmp, event, helper){
        var hasEnabled = cmp.get("v.hasEnabled");
        if(hasEnabled.prompt){
            event.stopPropagation();
            var hasConfirm = event.getParam("hasConfirm");
            if(hasConfirm){
                cmp.set("v.enabledViewers.audience", false);
                helper.selectAssessableObjMode(cmp, event, helper, hasEnabled.label);
            }
            hasEnabled.prompt = !hasEnabled.prompt;
            hasEnabled.label = '';
            cmp.set("v.hasEnabled", hasEnabled);
        }
    },
    changeName : function(cmp, event, helper){
        cmp.set("v.distributionRd.Name", event.getSource().get("v.value"));
    }
    
})