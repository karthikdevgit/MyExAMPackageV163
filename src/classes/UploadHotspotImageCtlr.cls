public class UploadHotspotImageCtlr {

    public String hotspotPropertyStr {get;set;}
    public String attStr {get;set;}
    
    public UploadHotspotImageCtlr() {
        hotspotPropertyStr = '';
        attStr = '';
        AttachmentClass attachCls = new AttachmentClass();
        String qId =  ApexPages.currentPage().getParameters().get('quesTempId');
        
        if(qId != null && qId != '') {
        
            SFDCAccessController accessQT = ExAMUtilClass.AccessController;
            List<string> fieldsListQT = new List<string>{'ExAM__Hotspot_Image_Properties__c'};
            accessQT.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Question_Template__c'), fieldsListQT);
            
            List<Question_Template__c> quesTempList = [SELECT Id,Name,Hotspot_Image_Properties__c FROM Question_Template__c WHERE Id =:qId];
            
            List<Attachment> attachList = [SELECT Id,Name,ParentId,ContentType,Body FROM Attachment WHERE ParentId =:qId AND Name = 'Hotspot-Image' ORDER BY LastModifiedDate DESC LIMIT 1];
            if(attachList != null && attachList.size() > 0) {
                attachCls.attId = attachList[0].Id;
                attachCls.parentId = attachList[0].ParentId;
                attachCls.name = attachList[0].Name;
                attachCls.contenttype = attachList[0].ContentType;
                attachCls.resultbody = attachList[0].Body;
                
            } else {
                attachCls.name = 'No file chosen';
            }
            attStr = JSON.serialize(attachCls);
            
            if( attachList != null && attachList.size() > 0 && quesTempList != null && quesTempList.size() > 0 && 
                quesTempList[0].Hotspot_Image_Properties__c != null && quesTempList[0].Hotspot_Image_Properties__c != '') {
                hotspotPropertyStr =  quesTempList[0].Hotspot_Image_Properties__c;
            } else {
                List<AreaClass> areaList = new List<AreaClass>();
                AreaClass areaCls = new AreaClass();
                areaCls.shape = '';
                areaCls.coords = '';
                areaCls.areaValue = '';
                areaList.add(areaCls);
                
                HotspotImagePropertyClass hsImagePrpty = new HotspotImagePropertyClass();
                hsImagePrpty.area = areaList;
                hsImagePrpty.imageWidth = 240;
                hsImagePrpty.imageHeight = 320;
                hsImagePrpty.questionId = quesTempList[0].Id;
                hsImagePrpty.questionImageId = '';
                hotspotPropertyStr = JSON.serialize(hsImagePrpty);
            }
        }
    }
    @RemoteAction 
    public static String deleteImage(AttachmentClass attach) {
    
        ReturnResponses responseCls = new ReturnResponses();
        String hotspotPropertyStr;
        String attStr;
        try {
            SFDCAccessController accessQT = ExAMUtilClass.AccessController;
            List<string> fieldsListQT = new List<string>{'ExAM__Hotspot_Image_Properties__c'};
            accessQT.assertAuthorizedToUpdate(Schema.getGlobalDescribe().get('exam__Question_Template__c'), fieldsListQT);
            
            if(attach.attId != null && attach.attId != '') {
                Attachment att = new Attachment();
                att.Id = attach.attId;
                Delete att;
                Question_Template__c ques = new Question_Template__c(Id = attach.parentId,Hotspot_Image_Properties__c='');
                update ques;
                List<AreaClass> areaList = new List<AreaClass>();
                AreaClass areaCls = new AreaClass();
                areaCls.shape = '';
                areaCls.coords = '';
                areaCls.areaValue = '';
                areaList.add(areaCls);
                
                HotspotImagePropertyClass hsImagePrpty = new HotspotImagePropertyClass();
                hsImagePrpty.area = areaList;
                hsImagePrpty.imageWidth = 240;
                hsImagePrpty.imageHeight = 320;
                hsImagePrpty.questionId = attach.parentId;
                hsImagePrpty.questionImageId = '';
                hotspotPropertyStr = JSON.serialize(hsImagePrpty);
                AttachmentClass attachCls = new AttachmentClass();
                attachCls.name = 'No file chosen';
                attStr = JSON.serialize(attachCls);
            }
            responseCls.message = 'success';
            responseCls.hotspotPropertyStr = hotspotPropertyStr;
            responseCls.attStr = attStr;
        } catch(Exception exp) {
            responseCls.message = 'failure';
            responseCls.messageText = exp.getMessage();
        }
        return JSON.serialize(responseCls);
    }
    
    @RemoteAction 
    public static String saveHotspotImage(AttachmentClass att,HotspotImagePropertyClass imagePrpty) {
        ReturnResponses responseCls = new ReturnResponses();
        try {
            SFDCAccessController accessQT = ExAMUtilClass.AccessController;
            List<string> fieldsListQT = new List<string>{'ExAM__Hotspot_Image_Properties__c'};
            accessQT.assertAuthorizedToUpdate(Schema.getGlobalDescribe().get('exam__Question_Template__c'), fieldsListQT);
            System.debug('::::imagePrpty::::'+imagePrpty);
            if( att != null && imagePrpty != null ) {
                Attachment attIns = new Attachment();
                if(att.attId != null && att.attId != '') {
                    attIns.Id = att.attId;
                } else {
                    attIns.ParentId = imagePrpty.questionId;
                }
                attIns.Name = 'Hotspot-Image';
                attIns.ContentType = att.contenttype;
                attIns.Body = att.resultbody;
                upsert attIns;
                imagePrpty.questionImageId = attIns.Id;
                Question_Template__c ques = new Question_Template__c(Id = imagePrpty.questionId,Hotspot_Image_Properties__c = JSON.serialize(imagePrpty));
                update ques;
            }
            responseCls.message = 'success';
        } catch(Exception exp) {
            responseCls.message = 'failure';
            responseCls.messageText = exp.getMessage();
        }
        return JSON.serialize(responseCls);
    }
    public class HotspotImagePropertyClass {
        public List<AreaClass> area;
        public String questionId;
        public Integer imageWidth;
        public Integer imageHeight;
        public String questionImageId;
    }
    public class AreaClass {
        public String shape;
        public String coords;
        public String areaValue;
    }
    public class AttachmentClass {
        public String attId;
        public String parentId;
        public String name;
        public String contenttype;
        public Blob resultbody;
    } 
    public class ReturnResponses {
        public String message;
        public String messageText;
        public String hotspotPropertyStr;
        public String attStr;
    }
}