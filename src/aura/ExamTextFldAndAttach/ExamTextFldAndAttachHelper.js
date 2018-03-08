({
    fileNameConstruct : function(cmp, event){
        var value = cmp.get("v.attachment").Name;
        if(value){
            var contentType = cmp.get("v.attachment").ContentType;
            if(contentType){
                contentType = contentType.split('/');
                value = value+'.'+contentType[1];
            }
            
        }else{
            value = "No file";
        }
        return value;
    },
})