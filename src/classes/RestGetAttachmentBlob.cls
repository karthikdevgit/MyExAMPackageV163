@RestResource(urlMapping='/getAttachmentBlob/*')
global with sharing class RestGetAttachmentBlob {

  @HttpPost
  global static String getAttachmentBlob1(String attachmentId) {
  
     LIST<Attachment> attachmentList;
     String returnString;
     try
     {
         attachmentList=[select Id,Body from Attachment WHERE Id=: attachmentId];
         if(attachmentList.size() > 0){
             returnString = 'data:image/png;base64,';
             returnString += EncodingUtil.base64Encode(attachmentList[0].body);
         }
     }
     catch(Exception ex)
     {
         returnString = ex.getMessage();
     }
      return returnString;
  }
}