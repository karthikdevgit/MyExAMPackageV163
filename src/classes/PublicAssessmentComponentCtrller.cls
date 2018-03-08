public with sharing class PublicAssessmentComponentCtrller {

    public string templateId { get; set; }
    public string templateRecord {get;set;}
    public string exceptMsg { get; set; }
    public string logoId {get;set;}
    
    public PublicAssessmentComponentCtrller() {
        
        try{
            exceptMsg = '';
            logoId = '';
            templateId = ApexPages.currentPage().getParameters().get('templateId');
            
            SFDCAccessController accessForAT = ExAMUtilClass.AccessController;
            List<string> fieldsListAT = new List<string>{'ExAM__Public_Assessment_Page_Footer__c','ExAM__Modal_Window_Text__c','ExAM__Public_Assessment_Page_Header__c',
                           'ExAM__Public_Assessment_Viewer_Tab_Icon__c','ExAM__Public_Assessment_Viewer_Title__c','ExAM__Show_Image_Upload_Icon__c',
                           'ExAM__Show_Modal_Window__c','ExAM__Show_Notes_Icon__c','ExAM__Show_Refresh_Icon__c','ExAM__Static_Resource_Name__c','ExAM__SRFile_Path__c',
                           'ExAM__Hide_Section_Titles__c','ExAM__Public_Assessment_Single_Question_Mode__c','ExAM__Enable_Survey_Overlay__c',
                           'ExAM__Survey_Overlay_Header_Text__c','ExAM__Survey_Overlay_Text__c','ExAM__Survey_Overlay_button_Text__c',
                           'ExAM__PA_Header_and_Button_Background_Color__c','ExAM__PA_Header_and_Button_Text_Color__c','ExAM__Auto_Submit__c',
                           'ExAM__PA_Template_Heading_Text__c','ExAM__Enable_Section_Description__c','ExAM__Enable_Survey_Intro_Text__c'};
            accessForAT.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Main_questionaire__c'), fieldsListAT);
            
            if (string.isNotBlank(templateId) && templateId != 'null' ) {
                
                List<Attachment> attachList = new List<Attachment>([SELECT Id FROM Attachment WHERE ParentId = :templateId AND Name = 'userLogo' ORDER BY LastModifiedDate DESC LIMIT 1]);
               
                if(attachList != null && attachList.size() > 0 ) {
                    logoId = attachList[0].Id;
                }
                
                List<Main_questionaire__c> templateRecordsList = new List<Main_questionaire__c>();
                templateRecordsList = [
                    SELECT Id, Name, Public_Assessment_Page_Footer__c, Modal_Window_Text__c, Public_Assessment_Page_Header__c,
                           Public_Assessment_Viewer_Tab_Icon__c, Public_Assessment_Viewer_Title__c, Show_Image_Upload_Icon__c,
                           Show_Modal_Window__c, Show_Notes_Icon__c, Show_Refresh_Icon__c, Static_Resource_Name__c, SRFile_Path__c,
                           Hide_Section_Titles__c, Public_Assessment_Single_Question_Mode__c, Enable_Survey_Overlay__c,
                           Survey_Overlay_Header_Text__c, Survey_Overlay_Text__c, Survey_Overlay_button_Text__c,
                           PA_Header_and_Button_Background_Color__c,PA_Header_and_Button_Text_Color__c, Auto_Submit__c,
                           PA_Template_Heading_Text__c,Enable_Section_Description__c,Enable_Survey_Intro_Text__c
                    FROM   Main_questionaire__c
                    WHERE  Id = :templateId
                ];
    
                if (templateRecordsList != null && templateRecordsList.size() > 0) {
                    templateRecord = JSON.serializePretty(templateRecordsList[0]);
                }
            }//end templateId string not blank codn check
        } catch (Exception e){
            exceptMsg = e.getMessage();
        }
    }//end constructor

    
    @RemoteAction
    public static string savePAConfig(string templateRec,Map<string,string> headerLogo) {
        
        string responseMsg;
        Main_questionaire__c assTemp = new Main_questionaire__c();
        try {
            
            assTemp = (Main_questionaire__c)JSON.deserialize(templateRec,Main_questionaire__c.Class);
            if(headerLogo != null && headerLogo.size() > 0) {
                List<Attachment> attachList = new List<Attachment>([SELECT Id FROM Attachment WHERE ParentId = :assTemp.Id AND Name = 'userLogo']);
                Attachment att = new Attachment();
                att.Body = EncodingUtil.Base64Decode(headerLogo.get('resultbody'));
                att.Name = 'userLogo';
                att.ContentType =headerLogo.get('contentType');
                att.ParentId = assTemp.Id;
                att.IsPrivate = false;
                if(attachList.size() > 0) {
                    Delete attachList;
                }
                insert att;
            }
            update assTemp;
            responseMsg = 'success';
           
        } catch(Exception exp) {
            System.debug(':::exp:::::'+exp.getMessage());
            responseMsg = exp.getMessage();
        }
        return responseMsg;
    }
    
    @RemoteAction 
    public static string deleteLogo(String attId) {
        string responseMsg;
        try {
            if(attId != null && attId != '') {
                Attachment att = new Attachment();
                att.Id = attId;
                Delete att;
            }
            responseMsg = 'success';
        }  catch(Exception exp) {
            responseMsg = exp.getMessage();
        }
        return responseMsg;
    }
}