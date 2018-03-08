({
    uploadImg : function(cmp, event, helper){
        var fileInput = cmp.find("fileUpload").getElement();
        var file = fileInput.files[0];
		var status,message;
        if (file.size > helper.MAX_FILE_SIZE) {
            cmp.find("fileUpload").getElement().value='';
            status = "error";
            message = 'File size cannot exceed ' + helper.MAX_FILE_SIZE + ' bytes.\n' +
                'Selected file size: ' + file.size;
            helper.showNotificationEvt(cmp, event, helper, status, message);
            return;
        }

        var fr = new FileReader();
        var fileType = file.type;
        fileType = fileType.split('/');
        fileType = fileType[1];
        

        if(fileType === 'png' || fileType === 'jpeg' || fileType === 'jpg' || fileType === 'gif' || fileType === 'tif'){

            fr.onload = $A.getCallback(function() {
                var fileContents = fr.result;
                var base64Mark = 'base64,';
                var dataStart = fileContents.indexOf(base64Mark) + base64Mark.length;

                fileContents = fileContents.substring(dataStart);
                var fileContent = {
                    "fileContents" : fileContents,
                    "fileName"  : "userLogo",
                    "contentType" : file.type
                }
                
                var contentType = fileContent.contentType;
                contentType = contentType.split('/');
                var fileName = fileContent.fileName;
                fileName = fileName +'.'+contentType[1];
                
                cmp.set("v.fileContent", fileContent);
                cmp.set("v.fileName", fileName);
            });

            fr.readAsDataURL(file);

        }else{
            cmp.find("fileUpload").getElement().value='';
            status = "error";
            message = "Please use png, jpg, gif, or tif file format";
            helper.showNotificationEvt(cmp, event, helper, status, message);
            return;
        }


    },
    uploadfile : function(cmp, event){
        cmp.find("fileUpload").getElement().click();

    },
    uploadFileToSerever : function(cmp, event, helper){
        var params = event.getParam('arguments');
        var fileContent = cmp.get("v.fileContent");
        var status, message;

        if(fileContent && Object.keys(fileContent).length){
            var parentId = cmp.get("v.parentId");
            var param = {
                "parentId" : parentId,
                "fileName" : fileContent.fileName,
                "base64Data" : encodeURIComponent(fileContent.fileContents),
                "contentType" : fileContent.contentType
            };
            
            var sObjectName = cmp.get("v.sObjectName");
            
            if(sObjectName == "ExAM__Main_questionaire__c"){
                window.Exam.AssessmentServiceComponent.uploadFileToSerever(param, $A.getCallback(function(attachment){
                    helper.attachmentInfoToParent(cmp, event, helper, attachment, params);                
                }), null);
                
            }else if(sObjectName == "ExAM__Question_Template__c"){
                param["attachmentId"] = cmp.get("v.attachmentId");
                param["fileName"] = "Question-Image";
                window.Exam.QuestionServiceComponent.uploadFileToSerever(param, $A.getCallback(function(attachment){
                    helper.attachmentInfoToParent(cmp, event, helper, attachment, params);
                }), null);
            }

            
        }else{
            status = "error";
            message = "Please use png, jpg, gif, or tif file format";
            helper.showNotificationEvt(cmp, event, helper, status, message);
        }
    }
})