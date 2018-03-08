({
    uploadImg : function(component, event, helper){

        var index = event.currentTarget.getAttribute("data-index");
        
        var filename = parseInt(index, 10) + 1;
        filename = filename.toString();
        var fileInput = component.find("file").getElement();
        var file = fileInput.files[0];

        if (file && file.size > helper.MAX_FILE_SIZE) {
            component.find("file").getElement().value='';
            var status = "error";
            var message = 'File size cannot exceed ' + (helper.MAX_FILE_SIZE/(1024*1024)).toFixed(2) + ' Mb.\n' +
                'Selected file size: ' + (file.size/(1024*1024)).toFixed(2);
            helper.showNotificationEvt(component, event, helper, status, message);
            return;
        }

        var fr = new FileReader();
        
        if(file){
            var fileType = file.type;
            fileType = fileType.split('/');
            fileType = fileType[1];
        }
        
        
        if(fileType === 'png' || fileType === 'jpeg' || fileType === 'jpg' || fileType === 'gif' || fileType === 'tif'){


            fr.onload = $A.getCallback(function() {
                var fileContents = fr.result;
                var base64Mark = 'base64,';
                var dataStart = fileContents.indexOf(base64Mark) + base64Mark.length;

                fileContents = fileContents.substring(dataStart);
                var fileContent = {
                    "fileContents" : fileContents,
                    "fileName"  : filename,
                    "contentType" : file.type
                }
                
                var contentType = fileContent.contentType;
                contentType = contentType.split('/');
                var fileName = fileContent.fileName;
                fileName = fileName +'.'+contentType[1];
                
                var indexWthImageMap = {};
                indexWthImageMap["attachmentId"] = '';
                indexWthImageMap["fileName"] = fileName;
                indexWthImageMap["fileContent"] = fileContent;
                
                component.set("v.indexWthImageMap", indexWthImageMap);

                
                var fileUpload = component.getEvent("fileUpload");
                fileUpload.setParams({
                    "fileContent" : fileContent,
                    "index" : index,
                    "fileName" : fileName
                });
                fileUpload.fire();

            });

            fr.readAsDataURL(file);
        }else{
            status = "error";
            message = "Please use png, jpg, gif, or tif file format";
            component.find("file").getElement().value='';
            helper.showNotificationEvt(component, event, helper, status, message);
            return;
        }
    },
    uploadfile : function(cmp, event){
        cmp.find("file").getElement().click();
    },

})