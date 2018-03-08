({
    showStyleAdvancedOptions : function(cmp, event, helper) {
        var styleLinkPreface = cmp.get("v.styleOptionsLinkType");
        if (styleLinkPreface === "Advanced")
        {
            cmp.set("v.styleOptionsLinkType", "Basic");
        }
        else {
            {
                cmp.set("v.styleOptionsLinkType", "Advanced");
            }
        }
        var styleAdvancedOptions = cmp.find("styleAdvancedOptions");
        $A.util.toggleClass(styleAdvancedOptions, "slds-hide");
        var styleBasicOptions = cmp.find("styleBasicOptions");
        $A.util.toggleClass(styleBasicOptions, "slds-hide");
        
    },
    downloadTemplateCss : function(cmp, event, helper){
        if(!cmp.get("v.publicAssessmentCSS")){
            var action = cmp.get("c.getStaticFileUrl");
            action.setParams({
                "resourceName" : "PublicAssessmentCSS"
            });
            action.setCallback(this, function(response){
                var status = response.getState();
                
                if(cmp.isValid() && status === "SUCCESS"){
                    var publicAssessmentCSS = response.getReturnValue();
                    cmp.set("v.publicAssessmentCSS", publicAssessmentCSS);
                }else if(cmp.isValid() && status === "INCOMPLETE"){
                    helper.buildOffLineMsg(cmp, event, helper, null);
                }else if(cmp.isValid() && status === "ERROR"){
                    helper.buildErrorMsg(cmp, event, helper, response.getError(), null);
                }
                
            });
            $A.enqueueAction(action);
        }
    },
    
})