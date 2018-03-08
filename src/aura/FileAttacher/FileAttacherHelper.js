({
    MAX_FILE_SIZE: 750000, 
    
    showNotificationEvt : function(cmp, event, helper, status, message){
        var showNotificationEvent = $A.get("e.c:notificationEvt");
        showNotificationEvent.setParams({
            "action" : status,
            "message" : message
        });
        showNotificationEvent.fire();
    },
    attachmentInfoToParent :  function(cmp, event, helper, attachment, params){
        var attachmentEvent = cmp.getEvent("fileAttachmentEvt");
        attachmentEvent.setParams({
            "attachment" : attachment
        });
        attachmentEvent.fire();
        
        
        if(params && params.onSuccess){
            var success = params.onSuccess;
            success(attachment);
        }
    }
})