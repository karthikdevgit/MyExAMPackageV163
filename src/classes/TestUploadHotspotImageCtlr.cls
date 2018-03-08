@isTest
private class TestUploadHotspotImageCtlr {
    
    @testSetUp
    public static void testSetUp() {
       
        List<Main_questionaire__c> asstempList = new List<Main_questionaire__c> {
            new Main_questionaire__c (Template_name__c = 'Test HotspotImage Template')
        };
        insert asstempList;
        
        List<Section_Template__c> secTempList = new List<Section_Template__c>{
            new Section_Template__c(Questionnaire_Section__c = asstempList[0].id, Section_label__c = 'HotSpot Section')
        };
        insert secTempList;
        
        List<Question_Template__c> quesTempList = new List<Question_Template__c> {
            new Question_Template__c(Section_Question__c = secTempList[0].id, Question_Label__c = 'Ur Hotspot Image Question is Shown below', 
                Question_Order_No__c = 1, Question_Type__c = 'Hotspot Image', Weight_of_Answer__c  = '10'),
            new Question_Template__c(Section_Question__c = secTempList[0].id, Question_Label__c = 'Ur Hotspot Image1 Question is Shown below', 
                Question_Order_No__c = 1, Question_Type__c = 'Hotspot Image', Weight_of_Answer__c  = '10')
        };
        insert quesTempList;
    }
    
    public static testMethod Void testUploadHotspotImageCtlrCons() {
        
        List<Question_Template__c> quesTempList = [SELECT Id, Name, Hotspot_Image_Properties__c FROM Question_Template__c];
        List<Attachment> attachList = new List<Attachment> {
            new Attachment(ParentId = quesTempList[0].Id, ContentType = 'Image', Name = String.valueof('Hotspot-Image'), Body = Blob.valueof('attached'))
        };
        
        List<UploadHotspotImageCtlr.AreaClass> areaList2 = new List<UploadHotspotImageCtlr.AreaClass>();
        UploadHotspotImageCtlr.AreaClass areaCls2 = new UploadHotspotImageCtlr.AreaClass();
        areaCls2.shape = '';
        areaCls2.coords = '';
        areaCls2.areaValue = '';
        areaList2.add(areaCls2);
                
        UploadHotspotImageCtlr.HotspotImagePropertyClass hsImagePrpty1 = new UploadHotspotImageCtlr.HotspotImagePropertyClass();
        hsImagePrpty1.area = areaList2;
        hsImagePrpty1.imageWidth = 240;
        hsImagePrpty1.imageHeight = 320;
        hsImagePrpty1.questionId = quesTempList[0].Id;
        hsImagePrpty1.questionImageId = '';
        String hotspotStr1 = JSON.serialize(hsImagePrpty1);
        
        UploadHotspotImageCtlr.AttachmentClass attachCls1 = new UploadHotspotImageCtlr.AttachmentClass();
        attachCls1.name = 'No file chosen';
        String attachStr1 = Json.serialize(attachCls1);
        
        //Case 1 (a): No Attachments are found under Ques @ initial condition
        
        ApexPages.currentPage().getParameters().put('quesTempId', quesTempList[0].Id);
        UploadHotspotImageCtlr uploadImg = new UploadHotspotImageCtlr();
        System.assertEquals(attachStr1, uploadImg.attStr);
        System.assertEquals(hotspotStr1, uploadImg.hotspotPropertyStr);
        
        // Case 2 (a): Save Attachment
        
        UploadHotspotImageCtlr.AttachmentClass attachCls = new UploadHotspotImageCtlr.AttachmentClass();
        attachCls.parentId = attachList[0].ParentId;
        attachCls.name = attachList[0].Name;
        attachCls.contenttype = attachList[0].ContentType;
        attachCls.resultbody = attachList[0].Body;
        String attachStr = Json.serialize(attachCls);
        
        List<UploadHotspotImageCtlr.AreaClass> areaList = new List<UploadHotspotImageCtlr.AreaClass>();
        UploadHotspotImageCtlr.AreaClass areaCls = new UploadHotspotImageCtlr.AreaClass();
        areaCls.shape = 'Square';
        areaCls.coords = '123';
        areaCls.areaValue = 'Rose';
        areaList.add(areaCls);
        
        UploadHotspotImageCtlr.HotspotImagePropertyClass hsImagePrpty = new UploadHotspotImageCtlr.HotspotImagePropertyClass();
        hsImagePrpty.area = areaList;
        hsImagePrpty.imageWidth = 240;
        hsImagePrpty.imageHeight = 320;
        hsImagePrpty.questionId = quesTempList[0].Id;
        hsImagePrpty.questionImageId = '';
        String hotspotStr = JSON.serialize(hsImagePrpty);
        
        String retSaveStr = UploadHotspotImageCtlr.saveHotspotImage(attachCls, hsImagePrpty);
        UploadHotspotImageCtlr.ReturnResponses retCls1 = (UploadHotspotImageCtlr.ReturnResponses)JSON.deserialize(retSaveStr, UploadHotspotImageCtlr.ReturnResponses.class);
        
        //Attachment saved under This Ques 
        List<Attachment> attachList1 = [SELECT Id, Name, ParentId, ContentType, Body FROM Attachment WHERE ParentId = :quesTempList[0].Id ];
        System.assertEquals('success', retCls1.message );
        System.assertEquals('Hotspot-Image', attachList1[0].Name);
        
        ApexPages.currentPage().getParameters().put('quesTempId', quesTempList[0].Id);
        UploadHotspotImageCtlr uploadImg2 = new UploadHotspotImageCtlr();
        
        UploadHotspotImageCtlr.AttachmentClass attachCls2 = new UploadHotspotImageCtlr.AttachmentClass();
        attachCls2.attId = attachList1[0].Id;
        attachCls2.parentId = attachList1[0].ParentId;
        attachCls2.name = attachList1[0].Name;
        attachCls2.contenttype = attachList1[0].ContentType;
        attachCls2.resultbody = attachList1[0].Body;
        String attachStr2 = Json.serialize(attachCls2);
        
        List<Question_Template__c> quesTempList1 = [SELECT Id, Name, Hotspot_Image_Properties__c FROM Question_Template__c];
        System.assertEquals(quesTempList1[0].Hotspot_Image_Properties__c , uploadImg2.hotspotPropertyStr);
        System.assertEquals(attachStr2, uploadImg2.attStr);
        
       //case 3 : Delete Existing attachment
        
        String retDelStr = UploadHotspotImageCtlr.deleteImage(attachCls2);
        UploadHotspotImageCtlr.ReturnResponses retCls = (UploadHotspotImageCtlr.ReturnResponses)JSON.deserialize(retDelStr, UploadHotspotImageCtlr.ReturnResponses.class);
        System.assertEquals('success', retCls.message);
        System.assertEquals(hotspotStr1, retCls.hotspotPropertyStr);
        System.assertEquals(attachStr1, retCls.attStr);
        
        //Case 2 (b): Save Exception block
        
        String retSaveStr2 = UploadHotspotImageCtlr.saveHotspotImage(attachCls2, hsImagePrpty);
        UploadHotspotImageCtlr.ReturnResponses retCls3 = (UploadHotspotImageCtlr.ReturnResponses)JSON.deserialize(retSaveStr2, UploadHotspotImageCtlr.ReturnResponses.class);
        System.assertEquals('failure', retCls3.message );
    }
}