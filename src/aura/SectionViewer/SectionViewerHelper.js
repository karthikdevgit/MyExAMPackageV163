({
    moveSection : function(cmp, event, helper, direction){
        var lengthOfSecTemp = cmp.get("v.lengthOfSecTemp");
        var assessmentId = cmp.get("v.SectionTemplate").ExAM__Questionnaire_Section__c;
        var index = cmp.get("v.index");
        var status,message,time;

        if((index === 0 && direction === 'up') || (index === lengthOfSecTemp - 1 && direction === 'down')){
            status = "error";
            message = "Sorry this action cannot be completed";
            time = null;
            helper.showNotificationEvt(cmp, event, status, message, time);
        }else{
            var param = {
                "assessmentId" : assessmentId,
                "index" : index,
                "direction" : direction
            }
            window.Exam.SectionServiceComponent.moveSectionUpOrDwn(param, $A.getCallback(function(){

                if(cmp.isValid()){
                    status = "success";
                    message = "Section Successfully move "+direction;
                    time = null;
                    helper.showNotificationEvt(cmp, event, status, message, time);
                }

            }), null);
        }
    },
    handleSectionChange: function(cmp, event, helper) {
        var sectionId = cmp.get("v.SectionTemplate.Id");
        
        var fieldSets = [];

        fieldSets.push("ExAM__lightningComp_QuestionOptions_FieldSet");

        var param = {
            "sObjectName": "ExAM__Question_Template__c",
            "fieldSets": fieldSets,
            "sObjectId": sectionId
        };

        window.Exam.QuestionServiceComponent.getQuestionBySectionId(param, false, $A.getCallback(function(questionTemplates) {

            if(cmp.isValid()){
                helper.findOrderNoOfLastQuestion(cmp, event, helper, questionTemplates);
                cmp.set("v.QuestionsTemplate", questionTemplates);
                if(cmp.get("v.showQuestion")){
                    //first time section creation time,default position is 0
                    var orderNo = '0';//cmp.find("dataIndex").getElement().getAttribute("data-index");
                    var position = orderNo;
                    var div1 = helper.rearrangeElement(cmp, event, position);
                    helper.builtNewQuestion(cmp, event, helper, orderNo, position, div1);
                    cmp.set("v.showQuestion", false);
                }
            }

        }), null);

    },
    toggleClassExpand : function(cmp){
        var examSec = cmp.find("examSec");
        $A.util.toggleClass(examSec, 'slds-is-collapsed');
        $A.util.toggleClass(examSec, 'slds-is-expanded');
    },
    showNotificationEvt : function(cmp, event, status, message, time){
        var showNotificationEvent = $A.get("e.c:notificationEvt");
        showNotificationEvent.setParams({
            "action" : status,
            "message" : message
            //"time" : time
        });
        showNotificationEvent.fire();
    },
    builtNewQuestion : function(cmp, event, helper, orderNo, position, div1){
        //var position = orderNo;
        var question = {
            'sobjectType': 'ExAM__Question_Template__c',
            'ExAM__Section_Question__c': cmp.get("v.SectionTemplate.Id"),
            'ExAM__Question_Type__c': '',
            'ExAM__Subquestion_Label__c': '',
            'ExAM__Question_Label__c': ''
        }
        window.Exam.QuestionServiceComponent.fetchFieldSet($A.getCallback(function(fields){
            if(cmp.isValid()){
               fields = fields.ExAM__lightningComp_QuestionOptions_FieldSet;
                for(var i = 0 ; i < fields.length; i++){
                    var fieldApi = fields[i].fieldApi;
                    question[fieldApi] = '';
                }
                helper.toggleSpinner(cmp);
                
                $A.createComponent(
                    "c:QuestionViewer", {
                        "QuestionTemplate": question,
                        "orderNo" : orderNo,
                        "position" : position,
                        "builtNewQuestion" : true,
                        "assessmentId" : cmp.get("v.SectionTemplate").ExAM__Questionnaire_Section__c
                    },
                    function(myCmp, status, errorMessage) {
                        helper.toggleSpinner(cmp);
                        if(cmp.isValid() && status === "SUCCESS"){
                            
                            if(Array.isArray(div1)){
                                var body = div1[position].get("v.body");
                                body.push(myCmp);
                                div1[position].set("v.body", body);
                                cmp.set("v.orderNo", position);
                            }
                            cmp.set("v.isSectionEdited", true); // newly added
                            
                        }else if(cmp.isValid() && status === "ERROR"){
                            errorMessage = errorMessage.split('at org')[0];
                            helper.showNotificationEvt(cmp, event, "error", errorMessage, null);
                        }else if(cmp.isValid() && status === "INCOMPLETE"){
                            errorMessage = "No response from server or client is offline";
                            helper.showNotificationEvt(cmp, event, "error", errorMessage, null);
                        }
                        
                    });
                
            }
        }), null);

        
    },
    rearrangeElement : function(cmp, event, position){

        var hideBtn = cmp.find("addBtn");
        var div1 = cmp.find("questionEditView");
        if(!Array.isArray(hideBtn)){
            hideBtn = [hideBtn];
            div1 = [div1];
        }else{
            var last = hideBtn.splice(0,1);
            hideBtn.push(last[0]);
            last = div1.splice(0,1);
            div1.push(last[0]);
        }

        $A.util.toggleClass(hideBtn[position], "slds-hide");
        return div1;
    },
    createCmp : function(cmp, event, helper, cmpName, attribute, parentDiv){
        helper.toggleSpinner(cmp);
        $A.createComponent(
            "ExAM:"+cmpName,
            attribute,
            function(myComponent, status, errorMessage){
               helper.toggleSpinner(cmp);
                if(cmp.isValid() && status === "SUCCESS"){
                    cmp.set("v.isSectionEdited", true);		// newly added
                    parentDiv.set("v.body", []);
                    var body = parentDiv.get("v.body");
                    body.push(myComponent);
                    parentDiv.set("v.body", body);
                }else if(cmp.isValid() && status === "ERROR"){
                    errorMessage = errorMessage.split('at org')[0];
                    helper.showNotificationEvt(cmp, event, "error", errorMessage, null);
                }else if(cmp.isValid() && status === "INCOMPLETE"){
                    errorMessage = "No response from server or client is offline";
                    helper.showNotificationEvt(cmp, event, "error", message, null);
                }
                
            }
        );
    },
    toggleSpinner : function(cmp){
        var spinner_container = cmp.find("spinner_container");
        $A.util.toggleClass(spinner_container, "slds-hide");
    },
    fireToggleEditView : function(cmp, Id, eventName){
        var editViewToggle = cmp.getEvent(eventName);
        editViewToggle.setParams({
            "Id" : Id,
            "type" : "sectionContainer"
        });
        editViewToggle.fire();
    },
    constructArrayElements : function(arrayElements){
        if(!Array.isArray(arrayElements)){
            arrayElements = [arrayElements];
        }
        return arrayElements;
    },
    findOrderNoOfLastQuestion : function(cmp, event, helper, questionTemplates){
        
        if(questionTemplates && questionTemplates.length){
            cmp.set("v.lastQues_OrderNo", questionTemplates[questionTemplates.length -1].ExAM__Question_Order_No__c);
        }else{
            cmp.set("v.lastQues_OrderNo", questionTemplates.length);
        }
        
    }
})