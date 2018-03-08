({
	closeModal : function(cmp, event, helper) {
		helper.closeSectionCapture(cmp, event, helper);
	},
    addSection : function(cmp, event, helper){
        var section = cmp.get("v.sectionTemplate");
        section.ExAM__Section_label__c = section.ExAM__Section_label__c.trim();
        if(!section.ExAM__Section_label__c){
            status = "warning";
            message = "Please enter a Section name";
            time = 5000;
            helper.showNotificationEvt(cmp, event, status, message, time);
            return;
        }
        section.sobjectType = "ExAM__Section_Template__c";
        var param = {
            "SectionTemplate" : section,
            "orderNo" : cmp.get("v.orderNo")
        };
        var status, message, time;
				
        window.Exam.SectionServiceComponent.createSection(param, $A.getCallback(function(){
            
            if(cmp.isValid()){
                status = "success";
                message = "Section created";
                time = null;
                helper.showNotificationEvt(cmp, event, status, message, time);
                helper.closeSectionCapture(cmp, event, helper);
            }
            

        }), null);
    }
})