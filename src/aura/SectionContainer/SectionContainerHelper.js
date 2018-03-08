({
    builtNewSection : function(cmp, event, helper, hideBtn, div, whichBtn, position, orderNo) {
        helper.toggleSpinner(cmp);
        
        if(!Array.isArray(hideBtn)){
            hideBtn = [hideBtn];
            div = [div];
        }
        $A.util.toggleClass(hideBtn[position], "slds-hide");
        
        var section = {
            'sobjectType': 'ExAM__Section_Template__c',
            'ExAM__Questionnaire_Section__c': cmp.get("v.assessmentId"),
            'ExAM__Section_label__c': '',
            'ExAM__Section_Description__c': ''
        }
        
        $A.createComponent(
            "c:CreateSectionViewer", {
                "sectionTemplate": section,
                "orderNo" : orderNo,
                "position" : position,
                "whichBtn" : whichBtn
            },
            function(myCmp, status, errorMessage) {
                helper.toggleSpinner(cmp);
                if(cmp.isValid() && status === "SUCCESS"){
                    helper.editViewOnRelatedToChild(cmp, helper);	// newly added
                    var body = div[position].get("v.body");
                    body.push(myCmp);
                    div[position].set("v.body", body);
                    
                    cmp.set("v.whichBtn", whichBtn);
                    cmp.set("v.orderNo", position);
                }else if(cmp.isValid() && status === "ERROR"){
                    helper.showNotificationEvt("error", errorMessage);
                }else if(cmp.isValid() && status === "INCOMPLETE"){
                    errorMessage = "No response from server or client is offline";
                    helper.showNotificationEvt("error", errorMessage);
                }
            });
    },
    toggleExpanded : function(cmp, index){
        
        var sectionEditor = cmp.find("sectionEditor");
        
        for(var i = 0; i < cmp.get("v.SectionTemplates").length; i++){
            if(index !== i){
                sectionEditor[i].toggleExpand();
            }
        }
    },
    findOrderNoOfLastSection : function(cmp, event, helper, SectionTemplates){
        var lastSec_OrderNo = SectionTemplates[SectionTemplates.length-1].ExAM__Order_No__c;
        cmp.set("v.lastSec_OrderNo", lastSec_OrderNo);
    },
    toggleSpinner : function(cmp){
        var spinner_container = cmp.find("spinner_container");
        $A.util.toggleClass(spinner_container,"slds-hide");
    },
    showNotificationEvt : function(status, message){
        var showNotificationEvent = $A.get("e.c:notificationEvt");
        showNotificationEvent.setParams({
            "action" : status,
            "message" : message
        });
        showNotificationEvent.fire();
    },
    constructArrayElements : function(arrayElements){
        if(!Array.isArray(arrayElements)){
            arrayElements = [arrayElements];
        }
        return arrayElements;
    },
    fireToggleEditView : function(cmp, Id, eventName){ // child Changes inform to its Parent cmp 
        var editViewToggle = cmp.getEvent(eventName);
        editViewToggle.setParams({
            "Id" : Id
        });
        editViewToggle.fire();
    },
    editViewOnRelatedToChild : function(cmp, helper){
        helper.fireToggleEditView(cmp, cmp.get("v.assessmentId"), "editViewOn");
        cmp.set("v.showBtns", false);
        var sectionEditors = cmp.find("sectionEditor");
        
        if(sectionEditors){
            sectionEditors = helper.constructArrayElements(sectionEditors);
            for(var index = 0; index < sectionEditors.length; index++){
                if(sectionEditors[index].get("v.isSectionEdited")){
                    
                    if(sectionEditors[index].get("v.isInLineEdit")){
                        $A.util.addClass(sectionEditors[index].find("ctrlLink"), "disable");
                        $A.util.addClass(sectionEditors[index].find("expand"), "disable");
                    }else{
                        $A.util.addClass(sectionEditors[index].find("sectionView"), "disable");
                    }
                    sectionEditors[index].disableQuestionView();
                }else{
                    $A.util.addClass(sectionEditors[index], "disable");
                }
            }
        }
    }
})