({
    emailTemplateSelection : function(cmp, event, helper){
        var emailTemplateIdWthIndex = event.getParam("value");
        if(emailTemplateIdWthIndex){
            var index = emailTemplateIdWthIndex.split('~')[1];
            var emailTemplateId = emailTemplateIdWthIndex.split('~')[0];
            var emailTemplates = cmp.get('v.emailTemplates');
            var selectedEmail = cmp.get("v.selectedObjInfo").emailTemplate;
            
            if(emailTemplates[index].Id == emailTemplateId){
                var distributionRd = cmp.get("v.distributionRd");
                selectedEmail["Id"] = emailTemplates[index].Id;
                selectedEmail["Name"] = emailTemplates[index].Name;
                cmp.set("v.selectedObjInfo.emailTemplate", selectedEmail);
            }
            
            var scheduleDateCmp = cmp.find("scheduleDate");
            if($A.util.hasClass(scheduleDateCmp, 'slds-hide')){
                $A.util.removeClass(scheduleDateCmp, 'slds-hide');
            }
        }
        
        
    },
    emailWithSalesforce : function(cmp, event, helper){
        window.Exam.EmailTemplateServiceComponent.fetchEmailTemplates($A.getCallback(function(emailTemplates){
            
            cmp.set('v.emailTemplates', emailTemplates);
            var distributionRd = cmp.get("v.distributionRd");
            //distributionRd.ExAM__Type__c = "Unique Link";
            distributionRd.ExAM__Send_Mode__c = 'Email with Salesforce';
            cmp.set("v.distributionRd", distributionRd);
            helper.toggleBtnActive(cmp, event, helper, cmp.find("emailSales"), '', "activeBtn");
            var actionSelections = cmp.get("v.actionSelections");
            if(!actionSelections.email){
                actionSelections.email = true;
            }
            cmp.set("v.actionSelections", actionSelections);
        }), null);
    },
    enableReviewViewer : function(cmp, event, helper){
        helper.enableReviewViewer(cmp, event, helper);
    },
    downloadCSV : function(cmp, event, helper){
        var distributionRd = cmp.get("v.distributionRd");
         if(distributionRd.ExAM__Send_Mode__c){
            distributionRd.ExAM__Send_Mode__c = '';
            cmp.set("v.distributionRd", distributionRd);
        }
        helper.toggleBtnActive(cmp, event, helper, cmp.find("csvDown"), '', "activeBtn");
        helper.enableReviewViewer(cmp, event, helper);
    },
    createLink : function(cmp, event, helper){
        var distributionRd = cmp.get("v.distributionRd");
        if(distributionRd.ExAM__Send_Mode__c){
            distributionRd.ExAM__Send_Mode__c = '';
            cmp.set("v.distributionRd", distributionRd);
        }
        
        helper.toggleBtnActive(cmp, event, helper, cmp.find("anon_link"), '', "activeBtn");
        helper.enableReviewViewer(cmp, event, helper);
    },
    dateTimeUpdate : function(cmp, event, helper){
        var scheduledCmp = cmp.find("scheduledCmp");
        var distributionRd = cmp.get("v.distributionRd");
        distributionRd.ExAM__Start_Date__c = distributionRd.ExAM__Distribution_DateTime__c;
        var date = new Date(distributionRd.ExAM__Distribution_DateTime__c);
        
        var year = date.getFullYear();
        var month = date.getMonth()+1;
        var dt = date.getDate();
        
        if (dt < 10) {
            dt = '0' + dt;
        }
        if (month < 10) {
            month = '0' + month;
        }
        var selectionDate = year+'-' + month + '-'+dt;
        var hasError = helper.validateDate(cmp, event, helper, selectionDate);
        if(hasError){
            helper.hasErrorEnabled(cmp, event, helper, scheduledCmp, "Give Current or Future Date time");
        }else{
            helper.hasErrorDisabled(cmp, event, helper, scheduledCmp);
        }
        cmp.set("v.distributionRd", distributionRd);
    },
    validateInputs : function(cmp, event, helper){
        var distributionRd = cmp.get("v.distributionRd");
        var sendMode = distributionRd.ExAM__Send_Mode__c;
        if(sendMode == "Email with Salesforce"){
            var scheduledCmp = cmp.find("scheduledCmp");
            if(!distributionRd.ExAM__Distribution_DateTime__c){
                helper.addHasError(cmp, event, helper, scheduledCmp, 'Please complete this field');
                return true;
            }else if(distributionRd.ExAM__Distribution_DateTime__c){
                if(distributionRd.ExAM__Expiration_Date__c != '' && distributionRd.ExAM__Distribution_DateTime__c > distributionRd.ExAM__Expiration_Date__c){
                    helper.addHasError(cmp, event, helper, scheduledCmp, 'Distribution DateTime should be less than Expiration Date');
                    return true;
                }else{
                    helper.removeHasError(cmp, event, helper, scheduledCmp);
                    return false;
                }
            }else{
                helper.removeHasError(cmp, event, helper, scheduledCmp);
                return false;
            }
        }
    },
    destoryChild : function(cmp, event, helper){
        helper.reset(cmp, event, helper);
        var enabledViewers = cmp.get("v.enabledViewers");
        if(enabledViewers && enabledViewers.review){
            enabledViewers.review = false;
            cmp.set("v.enabledViewers", enabledViewers);
        }
    }
})