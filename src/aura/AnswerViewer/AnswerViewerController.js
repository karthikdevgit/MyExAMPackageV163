({
    //dynamically created Component based on QuestionType 
    doInit : function(cmp, event, helper) {
        
        var answer =  cmp.get("v.answerOptions") || [];
        var type = cmp.get("v.QuestionTemplate.ExAM__Question_Type__c");
        cmp.set("v.type", type);
        
        if(answer.length){
            // Fetch Attachment when QuestionType is Image specified QuestionTemplate
            
            if(type === "Image"){
                
                var answerOptions = answer; //question.Answer_Options__r;
                var answerOptionsId = [];
                
                if(answerOptions){
                    for(var i = 0; i < answerOptions.length; i++){
                        answerOptionsId.push(answerOptions[i].Id);
                    }  
                }
                
                var param ={
                    "QuesId" : '',
                    "answerOptionsId" : answerOptionsId 
                };
                
                window.Exam.AttachmentServiceComponent.fetchAttachment(param, $A.getCallback(function(attachment){
                    
                    if(cmp.isValid()){
                        helper.setImageSrc(cmp, helper, answerOptionsId, attachment, answer);                      
                    }
                    
                }), null);  
            }      
            
        }else if(!answer.length){
            
            var answers = [];
            var ans = cmp.get("v.QuestionTemplate.ExAM__Subquestion_Label__c");
            
            if(ans){
                answer = ans.split("~");
                for(i = 0; i < answer.length; i++){
                    answers.push(answer[i]);
                }
                answer = answers;
                
                
                if(type === "Image"){
                    var question = cmp.get("v.QuestionTemplate");
                    var questionId = question.Id;
                    
                    param ={
                        "QuesId" : questionId,
                        "answerOptionsId" : [] 
                    };
                    
                    window.Exam.AttachmentServiceComponent.fetchAttachment(param, $A.getCallback(function(attachment){
                        
                        if(cmp.isValid()){                            
                            helper.setImageSrcByQuestion(cmp, helper, answer, attachment);
                        }
                        
                    }), null);  
                }      
                
            }
        }
        
        
        var uiCmps = [];
        
        if(type === "RadioPicklist"){
            
            helper.createRadioPicklist(cmp, answer, uiCmps);
            
        }else if(type === "Text"){
            
            helper.createText(cmp, uiCmps);            
            
        }else if(type === "Textarea"){
            
            helper.createTextarea(cmp, uiCmps);
            
        }else if(type === "Date"){
            
            helper.createDate(cmp, uiCmps); 
            
        }  else if(type === "Email"){
            
            helper.createEmail(cmp, uiCmps);
            
        }else if(type === "Phone Number"){
            
            helper.createPhoneNumber(cmp, uiCmps);
            
        }else if(type === "Dropdown Picklist"){
            
            helper.createDropdownPicklist(cmp, answer, uiCmps);
            
        }else if(type === "Button"){
            
            helper.createButton(cmp, answer, uiCmps);
            
        }else if(type === "MultiselectPicklist"){
            
            helper.createMultiselectPicklist(cmp, answer, uiCmps);
            
        }else if(type === "List"){
            
            helper.createList(cmp, answer, uiCmps);
            
        }else if(type === "Case"){
            
            helper.createCase(cmp, uiCmps);
            
        }else if(type === "Signature") {
            
            helper.createSignature(cmp, uiCmps);
            
        }else if(type === "File Question - Answer" || type === "File Question - AM"){
            
            helper.createFileQuestion(cmp, uiCmps);
            
        }else if(type === "Horizontal Radiopicklist"){
            
            helper.createHorizontalRadioPicklist(cmp, answer, uiCmps);
            
        }else if(type === "Number"){
            
            helper.createNumber(cmp, uiCmps);
        }else if(type === "Checkbox"){
            
            helper.createCheckbox(cmp, uiCmps);
        }else if(type === "File Question - Answer" || 
                type === "File Question - AM" || 
                 type === "File Question - Assessable Object"){
            helper.createFileUpload(cmp, uiCmps);
            
        }else{
            var div1 = cmp.find("createUiCmp");
            div1.set("v.body", []);
        }
    },
    hasCheck : function(cmp, event, helper){
        cmp.set("v.hasCheck", !cmp.get("v.hasCheck"));
    },
    getAction : function(cmp, event, helper){
        var type = event.getParam("type");
        if(type === "AnswerViewer"){
            event.stopPropagation();
        }
    }
})