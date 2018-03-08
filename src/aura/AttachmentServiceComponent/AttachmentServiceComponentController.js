({
    doInit : function(cmp, event, helper) {
        var attachmentByParentId = {
            "_Attachment" : {},
            "_QuestionImage" : {}
        };
        
        window.Exam.AttachmentServiceComponent = (function() {
            
            return {
                saveFile : function(param, onSuccess, onError){
                    helper.saveFile(param, onSuccess, onError, attachmentByParentId, cmp, helper);
                },
                uploadFileToSerever : function(param, onSuccess, onError, data){
                    helper.uploadFileToSerever(param, onSuccess, onError, data, cmp, helper);
                },
                uploadQuestionImage : function(param, onSuccess, onError){
                    helper.uploadQuestionImage(param, onSuccess, onError, attachmentByParentId, cmp, helper);
                },
                fetchAttachment : function(param, onSuccess, onError){
                    
                    var parentIds = param.answerOptionsId;
                    
                    if(parentIds && parentIds.length){
                        var attachments = [];                        
                        
                        for(var i = 0; i < parentIds.length; i++){
                            
                            if(attachmentByParentId._Attachment[parentIds[i]]){
                                attachments.push(attachmentByParentId._Attachment[parentIds[i]]);
                            }
                            
                        }
                        
                        if(attachments.length){
                            onSuccess(attachments);
                        }else{
                            helper.fetchAttachment(param, onSuccess, onError, attachmentByParentId, cmp, helper);
                        }
                        
                    }else{
                        var parentId = param.QuesId;
                        
                        if(attachmentByParentId._Attachment[parentId]){
                            
                            onSuccess(attachmentByParentId._Attachment[parentId]);
                        }else{
                            helper.fetchAttachment(param, onSuccess, onError, attachmentByParentId, cmp, helper);
                        }
                    }
                    
                },
                cloneAttachment : function(parentId, onSuccess, onError){
                    helper.cloneAttachment(parentId, onSuccess, onError, attachmentByParentId, cmp, helper);
                },
                updateAttachment : function(parentId, Attachment){
                    attachmentByParentId._Attachment[parentId] = Attachment;
                },
                storeQuestionImage :  function(parentId, Attachment){
                    attachmentByParentId._QuestionImage[parentId] = Attachment;
                },
                getQuestionImage : function(parentId, onSuccess){
                    
                    if(attachmentByParentId._QuestionImage[parentId]){
                        onSuccess(attachmentByParentId._QuestionImage[parentId]);
                    }else{
                        onSuccess({});
                    }
                },
                clearAttachmentsContextData : function(){
                    attachmentByParentId = {
                        "_Attachment" : {},
                        "_QuestionImage" : {}
                    };
                }
            };
        }());
    }
})