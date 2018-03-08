@isTest 
private class TestPublicAssessmentComponentCtrller {

    @testSetup static void setup() {
        Main_questionaire__c assTemp = new Main_questionaire__c();
         
        assTemp.Public_Assessment_Page_Footer__c = '<p><strong>Custom Footer</strong></p>';
        assTemp.Modal_Window_Text__c = 'test modal';
        assTemp.Public_Assessment_Page_Header__c = '<p><strong>Custom header</strong></p>';
        assTemp.Show_Image_Upload_Icon__c = true;
        assTemp.Show_Modal_Window__c = true;
        assTemp.Show_Notes_Icon__c = true;
        assTemp.Show_Refresh_Icon__c = true;
        assTemp.Static_Resource_Name__c = 'DynamicStyle';
        assTemp.SRFile_Path__c = '/styles_vavoice/styles_vavoice_css.min.css';
        assTemp.Hide_Section_Titles__c = true;
        assTemp.Public_Assessment_Single_Question_Mode__c = true;
        assTemp.Enable_Survey_Overlay__c = true;
        assTemp.Survey_Overlay_Text__c ='Test Ovelay Text';
        assTemp.Survey_Overlay_button_Text__c = 'Test Overlay Button';
        insert assTemp;
    
        Attachment attachment = new Attachment();
        attachment.ParentId = assTemp.Id;
        attachment.Name = 'userLogo';
        attachment.Body = Blob.valueOf('Test Data');
        insert attachment;      
    }
    static testMethod void method1() {
        List<Main_questionaire__c> assTempList = new List<Main_questionaire__c>(
                                                    [SELECT 
                                                        Id,Public_Assessment_Page_Footer__c,Modal_Window_Text__c,
                                                        Public_Assessment_Page_Header__c,Show_Image_Upload_Icon__c,
                                                        Show_Modal_Window__c,Show_Notes_Icon__c,Show_Refresh_Icon__c,
                                                        Static_Resource_Name__c,SRFile_Path__c,Hide_Section_Titles__c,
                                                        Public_Assessment_Single_Question_Mode__c,Enable_Survey_Overlay__c,
                                                        Survey_Overlay_Text__c,Survey_Overlay_button_Text__c
                                                     FROM Main_questionaire__c]);
       
        String assTempStr = JSON.serialize(assTempList[0]);
        
        Test.startTest();
            String tempId = ApexPages.currentPage().getParameters().put('templateId',assTempList[0].Id);
            PublicAssessmentComponentCtrller paCtrlr = new PublicAssessmentComponentCtrller();
        Test.stopTest();
        
        Blob b = Blob.valueOf('test image');
        Map<string, string> headerLogo = new Map<string, string>();
        headerLogo.put('contentType', 'image/jpg');
        headerLogo.put('name', 'userLogo');
        headerLogo.put('resultbody', b.toString());

        string saveMsg = PublicAssessmentComponentCtrller.savePAConfig(assTempStr, headerLogo);
        system.debug(':::saveMsg::::'+saveMsg);
    }
    static testMethod void method2() {
        List<Main_questionaire__c> assTempList = new List<Main_questionaire__c>(
                                                    [SELECT 
                                                        Id,Public_Assessment_Page_Footer__c,Modal_Window_Text__c,
                                                        Public_Assessment_Page_Header__c,Show_Image_Upload_Icon__c,
                                                        Show_Modal_Window__c,Show_Notes_Icon__c,Show_Refresh_Icon__c,
                                                        Static_Resource_Name__c,SRFile_Path__c,Hide_Section_Titles__c,
                                                        Public_Assessment_Single_Question_Mode__c,Enable_Survey_Overlay__c,
                                                        Survey_Overlay_Text__c,Survey_Overlay_button_Text__c
                                                     FROM Main_questionaire__c]);
        List<Attachment> attachments = new List<Attachment>([SELECT id, name FROM Attachment WHERE ParentId = :assTempList[0].Id]);
        System.assertEquals(1, attachments.size());
        
        String deleteMsg = PublicAssessmentComponentCtrller.deleteLogo(attachments[0].Id);
        System.assertEquals(deleteMsg, 'success');
        system.debug(':::deleteMsg::::'+deleteMsg);
    }
}