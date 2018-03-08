global with sharing class SigntureAttachmentPageController{
   
    @RemoteAction
    global static String attachmentGetter(String amId){

        String attachmentJSON = '';
        OuterWrapper ow = new OuterWrapper();

        for(Attachment att :[SELECT Id,Name,ContentType,Body,ParentId FROM Attachment WHERE ParentId = :amId AND Name LIKE 'Signature%' ORDER BY CreatedDate ASC]){

            ow.addAttach(att);
        }
        attachmentJSON = JSON.serialize( ow );    
        return attachmentJSON;    
    }

    @RemoteAction
    global static String attachmentDeleter(List<Attachment> attList){

        String attDeleteResponseMsg = '';

        if (!attList.isEmpty()) {

            delete attList;
            attDeleteResponseMsg = 'Deleted';
        }
        return attDeleteResponseMsg;    
    }

    global class OuterWrapper{

        List<AttachmentClass> attachmentList;

        public OuterWrapper(){
            attachmentList = new List<AttachmentClass>();
        }

        public void addAttach(Attachment attach){
            
            AttachmentClass att= new AttachmentClass();
            att.Name = attach.Name;
            att.Id = attach.Id;
            att.ParentId = attach.ParentId;
            att.Body = attach.Body;
            att.ContentType = attach.ContentType;
            attachmentList.add(att);
        }
    }

    public class AttachmentClass{

        String Name;
        Id Id;
        Id ParentId;
        Blob Body;
        String ContentType;
    }
}