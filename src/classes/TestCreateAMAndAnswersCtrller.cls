@isTest
public class TestCreateAMAndAnswersCtrller {
    
    @testsetup static void setup(){
    
        List<Account> aclist = new List<Account> {
            new Account(Name = 'TestAcc1')};
        insert acList;
        
        List<Main_questionaire__c> asstempList = new List<Main_questionaire__c> {
            new Main_questionaire__c (Template_name__c = 'Public viewer with normal question', Public_Assessment_Viewer_Title__c = 'Test viewer Title',Public_Assessment_Viewer_Tab_Icon__c = 'Sanitize',
                One_Time_Assessment__c = false, Google_Analytics_Script__c = 'test URL<script></script>', Survey_Overlay_Text__c = 'Test survey', Survey_Overlay_Header_Text__c = 'test header', Survey_Overlay_button_Text__c = 'Test button',
                Enable_Survey_Overlay__c = true,Show_Modal_Window__c = true,Modal_Window_Text__c = 'Test Modal window text',Hide_Section_Titles__c = true, Enable_Survey_Intro_Text__c = true,Enable_Section_Description__c = true,
                Public_Assessment_Page_Header__c = '<b>Test Intro Text<b>',Public_Assessment_Page_Footer__c = '<b>Test footer Text<b>',PA_Template_Heading_Text__c = 'Test Heading text - {Name}', PA_Header_and_Button_Background_Color__c = '#A6B9CC', 
                PA_Header_and_Button_Text_Color__c='#fff', Static_Resource_Name__c='sanitize', SRFile_Path__c = '/header.html~/footer.html~/srStyle.css',
                Web_Intercept_PA_Static_Resource_Name__c = 'sanitize', Web_Intercept_PA_Resource_File_Path__c = '/header.html~/footer.html~/style.css',Auto_Submit__c = false)
        };
        insert asstempList;
        
        List<Attachment> attachList =  new List<Attachment>{
            new Attachment(ParentId = assTempList[0].Id, ContentType = 'Image', Name = String.valueof('userLogo'), Body = Blob.valueof('attached'))
        };    
        insert attachList;                           
        
        List<IssueRequest_Life_Cycle__c> amList = new List<IssueRequest_Life_Cycle__c>{
            new IssueRequest_Life_Cycle__c(InvestigationType__c = assTempList[0].Id, Facility_Name__c = acList[0].Id, Status__c = 'Open', Field_Start_Time__c = null, Total_Score__c = 70 )};
        insert amList;
        
        List<Distribution__c> distributionList = new List<Distribution__c>{
            new Distribution__c(Name='test Distribution1', Landing_Page__c = 'www.google.com' ),
            new Distribution__c(Name='test Distribution1', Landing_Page__c = 'https://www.google.com', Pre_Assessment_Message__c = 'Welcome', Post_Assessment_Message__c = 'Thank You'),
            new Distribution__c(Name='test Distribution1', Landing_Page__c = 'www.google.com', Pre_Assessment_Message__c = 'Welcome', Post_Assessment_Message__c = 'Thank You', Start_Date__c = System.today().adddays(2),Expiration_Date__c = System.today().adddays(4)),
            new Distribution__c(Name='test Distribution1', Landing_Page__c = 'https://www.google.com', Pre_Assessment_Message__c = 'Welcome', Post_Assessment_Message__c = 'Thank You', Start_Date__c = System.today().adddays(-4),Expiration_Date__c = System.today().adddays(-2))
        }; 
        insert distributionList;   
                               
        List<Public_Assessment__c> paList = new List<Public_Assessment__c> {
            new Public_Assessment__c(Facility_Name__c = acList[0].Id, Assignment_Manager__c = amList[0].Id, Expiration_Date__c = System.today()+2 ),
            new Public_Assessment__c(Facility_Name__c = acList[0].Id, Expiration_Date__c = System.today()+2, Assessible_Object_ID__c = acList[0].Id, Assessment_Template__c = assTempList[0].Id),
            new Public_Assessment__c(Facility_Name__c = acList[0].Id, Expiration_Date__c = System.today()+2, Assessable_Object_API__c = 'Account', Assessment_Template__c = assTempList[0].Id),
            new Public_Assessment__c(Facility_Name__c = acList[0].Id, Expiration_Date__c = System.today()-2, Assessable_Object_API__c = 'Account', Assessment_Template__c = assTempList[0].Id)
        };
        insert paList;
        System.assert(paList.size() != 0);        
        
    } 
    public static testMethod void testCreateAMAndAnswersController() {    
        
        Public_Assessment_Configuration__c config = new Public_Assessment_Configuration__c ();
        config.Site_URL__c = 'www.google.com';
        insert config;
        
        List<Public_Assessment__c> paList = [ SELECT Id,Assignment_Manager__c, Assessible_Object_ID__c, 
                    Assessable_Object_API__c, Assessment_Template__c  
                    FROM Public_Assessment__c]; //WHERE Id = :paList[0].Id];
        System.assertEquals(paList.size(),4);
        
        Public_Assessment__c pa = new Public_Assessment__c();
        Public_Assessment__c paForAssObjIdandAssTemp = new Public_Assessment__c();
        List<Public_Assessment__c> paForAssObjApiandAssTempList = new List<Public_Assessment__c>();
        
        for(Public_Assessment__c p : paList) {
            if(p.Assignment_Manager__c != null) {
                pa = p;
            } 
            if(p.Assessible_Object_ID__c <> Null && p.Assessment_Template__c <> Null){
                paForAssObjIdandAssTemp = p;
            }
            if(p.Assessable_Object_API__c <> Null && p.Assessment_Template__c <> Null){
                paForAssObjApiandAssTempList.add(p);
            }
        }
        
        System.assertNotEquals(pa.Id,null);
        
        List<IssueRequest_Life_Cycle__c> queryAMList = [ SELECT Id, InvestigationType__c,Facility_Name__c 
                                FROM IssueRequest_Life_Cycle__c 
                                WHERE Id = :pa.Assignment_Manager__c];
        System.assertEquals(queryAMList.size(),1);
        System.assertEquals(pa.Assignment_Manager__c,queryAMList[0].Id);
        
        List<Main_questionaire__c> asstempList = [SELECT Id, Google_Analytics_Script__c, Modal_Window_Text__c,
           Name, Public_Assessment_Page_Footer__c, Public_Assessment_Page_Header__c,
           Static_Resource_Name__c, SRFile_Path__c, Template_name__c, Hide_Section_titles__c,
           Public_Assessment_Single_Question_Mode__c,Auto_Submit__c,Web_Intercept_PA_Resource_File_Path__c,
           Web_Intercept_PA_Static_Resource_Name__c, Public_Assessment_Viewer_Tab_Icon__c,
           Public_Assessment_Viewer_Title__c,PA_Header_and_Button_Background_Color__c,PA_Header_and_Button_Text_Color__c,
           PA_Template_Heading_Text__c,Enable_Section_Description__c,Enable_Survey_Intro_Text__c,
           Enable_Survey_Overlay__c, Survey_Overlay_Header_Text__c, Survey_Overlay_Text__c,
           Survey_Overlay_button_Text__c  
           FROM Main_questionaire__c WHERE Id = :queryAMList[0].InvestigationType__c];
        
        System.assertEquals(asstempList.size(),1);
        List<Account> acList = [SELECT Id,Name FROM Account];
        System.assertEquals(acList.size(),1);
        System.assertEquals(queryAMList[0].InvestigationType__c,asstempList[0].Id);
        System.assertEquals(queryAMList[0].Facility_Name__c,acList[0].Id);
        
        List<Attachment> attachList = [SELECT Id,Name FROM Attachment WHERE ParentId = :asstempList[0].Id];
        System.assertEquals(attachList.size(),1);        
      
        //Case 1 : Null paList
        
        ApexPages.currentPage().getParameters().put('paId',asstempList[0].Id);        
        CreateAMAndAnswersController cAmandAnsCtrller5 = new CreateAMAndAnswersController();
        
        System.assertEquals(cAmandAnsCtrller5.tempId,'');
        System.assertEquals(cAmandAnsCtrller5.objId,'');
        System.assertEquals(cAmandAnsCtrller5.amId,'');
        System.assertEquals(cAmandAnsCtrller5.PARecordId,asstempList[0].Id);
        System.assertEquals(cAmandAnsCtrller5.assessbleObjAPI,'');
        System.assertEquals(cAmandAnsCtrller5.headerStr,null);
        System.assertEquals(cAmandAnsCtrller5.footerStr,null);
        System.assertEquals(cAmandAnsCtrller5.customScriptConfigured,null);        
        System.assertEquals(cAmandAnsCtrller5.tabTitle,null);
        System.assertEquals(cAmandAnsCtrller5.errHandler,'');
        System.assertEquals(cAmandAnsCtrller5.imgURl,'');      
        System.assertEquals(cAmandAnsCtrller5.headerText,'');
        System.assertEquals(cAmandAnsCtrller5.basicStyle,'');    
        System.assertEquals(cAmandAnsCtrller5.overlayDetailStr,'');        
        System.assertEquals(cAmandAnsCtrller5.hideSectionTitles,false);
        System.assertEquals(cAmandAnsCtrller5.moveforward,false);
        System.assertEquals(cAmandAnsCtrller5.singleQuestionMode,false);        
        System.assertEquals(cAmandAnsCtrller5.showIntroText,null);
        System.assertEquals(cAmandAnsCtrller5.showSecDesc,null);
        System.assertEquals(cAmandAnsCtrller5.hasLinkExpired ,false);
        System.assertEquals(cAmandAnsCtrller5.hasAssessableObj,false);
        System.assertEquals(cAmandAnsCtrller5.autoSubmit,null);
        System.assertEquals(cAmandAnsCtrller5.pathList,null );
        System.assertEquals(cAmandAnsCtrller5.webIntercept,false);
        
        //Case 2: pa.Expiration_Date__c < Date.today()        
        
        ApexPages.currentPage().getParameters().put('paId',paForAssObjApiandAssTempList[1].Id);        
        CreateAMAndAnswersController cAmandAnsCtrller3 = new CreateAMAndAnswersController();
        
        System.assertEquals(cAmandAnsCtrller3.tempId,'');
        System.assertEquals(cAmandAnsCtrller3.objId,'');
        System.assertEquals(cAmandAnsCtrller3.amId,'');
        System.assertEquals(cAmandAnsCtrller3.PARecordId,paForAssObjApiandAssTempList[1].Id);
        System.assertEquals(cAmandAnsCtrller3.assessbleObjAPI,'');
        System.assertEquals(cAmandAnsCtrller3.headerStr,null);
        System.assertEquals(cAmandAnsCtrller3.footerStr,null);
        System.assertEquals(cAmandAnsCtrller3.customScriptConfigured,null);        
        System.assertEquals(cAmandAnsCtrller3.tabTitle,null);
        System.assertEquals(cAmandAnsCtrller3.errHandler,'');
        System.assertEquals(cAmandAnsCtrller3.imgURl,'');      
        System.assertEquals(cAmandAnsCtrller3.headerText,'');
        System.assertEquals(cAmandAnsCtrller3.basicStyle,'');        
        System.assertEquals(cAmandAnsCtrller3.overlayDetailStr,'');        
        System.assertEquals(cAmandAnsCtrller3.hideSectionTitles,false);
        System.assertEquals(cAmandAnsCtrller3.moveforward,false);
        System.assertEquals(cAmandAnsCtrller3.singleQuestionMode,false);
        System.assertEquals(cAmandAnsCtrller3.webIntercept,false);
        System.assertEquals(cAmandAnsCtrller3.showIntroText,null);
        System.assertEquals(cAmandAnsCtrller3.showSecDesc,null);
        System.assertEquals(cAmandAnsCtrller3.hasLinkExpired ,true);
        System.assertEquals(cAmandAnsCtrller3.hasAssessableObj,false);
        System.assertEquals(cAmandAnsCtrller3.autoSubmit,null);
        System.assertEquals(cAmandAnsCtrller3.pathList,null );

        
        //case 3 : Assessment Template Id and Assessable Object Id in PA 
        
        ApexPages.currentPage().getParameters().put('paId',paForAssObjIdandAssTemp .Id);        
        CreateAMAndAnswersController cAmandAnsCtrller1 = new CreateAMAndAnswersController();
        
        System.assertEquals(cAmandAnsCtrller1.tempId,paForAssObjIdandAssTemp.Assessment_Template__c);
        System.assertEquals(cAmandAnsCtrller1.objId,paForAssObjIdandAssTemp.Assessible_Object_ID__c);
        System.assertEquals(cAmandAnsCtrller1.amId,'');
        System.assertEquals(cAmandAnsCtrller1.PARecordId,paForAssObjIdandAssTemp.Id);
        System.assertEquals(cAmandAnsCtrller1.assessbleObjAPI,'Account');
        System.assertEquals(cAmandAnsCtrller1.headerStr,asstempList[0].Public_Assessment_Page_Header__c);
        System.assertEquals(cAmandAnsCtrller1.footerStr,null);
        System.assertEquals(cAmandAnsCtrller1.customScriptConfigured,'test URL');        
        System.assertEquals(cAmandAnsCtrller1.tabTitle,asstempList[0].Public_Assessment_Viewer_Title__c);
        System.assertEquals(cAmandAnsCtrller1.errHandler,'');
        System.assertEquals(cAmandAnsCtrller1.imgURl,'www.google.com/servlet/servlet.FileDownload?file='+attachList[0].Id);        
        System.assertEquals(cAmandAnsCtrller1.headerText,'Test Heading text - TestAcc1');
        System.assertEquals(cAmandAnsCtrller1.basicStyle,'');
      
        Map<string,string> overlayDetailMap1  = new Map<string,string>();
        overlayDetailMap1.put('isEnable',string.valueOf(asstempList[0].Enable_Survey_Overlay__c));
        overlayDetailMap1.put('Header',asstempList[0].Survey_Overlay_Header_Text__c);
        overlayDetailMap1.put('Body',asstempList[0].Survey_Overlay_Text__c);
        overlayDetailMap1.put('ButtonText',asstempList[0].Survey_Overlay_button_Text__c);
        String overlayDetailStr1 = JSON.serialize(overlayDetailMap1);
        System.assertEquals(cAmandAnsCtrller1.overlayDetailStr,overlayDetailStr1);
        
        System.assertEquals(cAmandAnsCtrller1.hideSectionTitles,asstempList[0].Hide_Section_titles__c);
        System.assertEquals(cAmandAnsCtrller1.moveforward,true);
        System.assertEquals(cAmandAnsCtrller1.singleQuestionMode,false);        
        System.assertEquals(cAmandAnsCtrller1.showIntroText,asstempList[0].Enable_Survey_Intro_Text__c);
        System.assertEquals(cAmandAnsCtrller1.showSecDesc,asstempList[0].Enable_Section_Description__c);
        System.assertEquals(cAmandAnsCtrller1.hasLinkExpired ,false);
        System.assertEquals(cAmandAnsCtrller1.hasAssessableObj,true);
        System.assertEquals(cAmandAnsCtrller1.autoSubmit,false);
        System.assertEquals(cAmandAnsCtrller1.pathList,new List<String>{'/srStyle.css'});
        System.assertEquals(cAmandAnsCtrller1.webIntercept,false);
        
        //case 4 :Assessment Template Id and Assessable Object API in PA 
        
        ApexPages.currentPage().getParameters().put('paId',paForAssObjIdandAssTemp.Id);        
        ApexPages.currentPage().getParameters().put('amId', asstempList[0].Id);
        CreateAMAndAnswersController cAmandAnsCtrller10 = new CreateAMAndAnswersController();
        System.assertEquals(cAmandAnsCtrller10.tempId,paForAssObjIdandAssTemp.Assessment_Template__c  );
        System.assertEquals(cAmandAnsCtrller10.objId,paForAssObjIdandAssTemp.Assessible_Object_ID__c);
        System.assertEquals(cAmandAnsCtrller10.amId,'');
        System.assertEquals(cAmandAnsCtrller10.PARecordId,paForAssObjIdandAssTemp.Id);
        System.assertEquals(cAmandAnsCtrller10.assessbleObjAPI,'Account');
        System.assertEquals(cAmandAnsCtrller10.headerStr,asstempList[0].Public_Assessment_Page_Header__c);
        System.assertEquals(cAmandAnsCtrller10.footerStr,null);
        System.assertEquals(cAmandAnsCtrller10.customScriptConfigured,'test URL');        
        System.assertEquals(cAmandAnsCtrller10.tabTitle,asstempList[0].Public_Assessment_Viewer_Title__c);
        System.assertEquals(cAmandAnsCtrller10.errHandler,'');
        System.assertEquals(cAmandAnsCtrller10.imgURl,'www.google.com/servlet/servlet.FileDownload?file='+attachList[0].Id);        
        System.assertEquals(cAmandAnsCtrller10.headerText,'Test Heading text - TestAcc1');
        System.assertEquals(cAmandAnsCtrller10.basicStyle,'');
      
        Map<string,string> overlayDetailMap10  = new Map<string,string>();
        overlayDetailMap10.put('isEnable',string.valueOf(asstempList[0].Enable_Survey_Overlay__c));
        overlayDetailMap10.put('Header',asstempList[0].Survey_Overlay_Header_Text__c);
        overlayDetailMap10.put('Body',asstempList[0].Survey_Overlay_Text__c);
        overlayDetailMap10.put('ButtonText',asstempList[0].Survey_Overlay_button_Text__c);
        String overlayDetailStr10 = JSON.serialize(overlayDetailMap10);
        System.assertEquals(cAmandAnsCtrller10.overlayDetailStr,overlayDetailStr10);
        
        System.assertEquals(cAmandAnsCtrller10.hideSectionTitles,asstempList[0].Hide_Section_titles__c);
        System.assertEquals(cAmandAnsCtrller10.moveforward,true);
        System.assertEquals(cAmandAnsCtrller10.singleQuestionMode,false);        
        System.assertEquals(cAmandAnsCtrller10.showIntroText,asstempList[0].Enable_Survey_Intro_Text__c);
        System.assertEquals(cAmandAnsCtrller10.showSecDesc,asstempList[0].Enable_Section_Description__c);
        System.assertEquals(cAmandAnsCtrller10.hasLinkExpired ,false);
        System.assertEquals(cAmandAnsCtrller10.hasAssessableObj,true);
        System.assertEquals(cAmandAnsCtrller10.autoSubmit,false);
        System.assertEquals(cAmandAnsCtrller10.pathList,new List<String>{'/srStyle.css'} ); 
        System.assertEquals(cAmandAnsCtrller10.webIntercept,false);
       
        ApexPages.currentPage().getParameters().put('paId',paForAssObjApiandAssTempList[0].Id);        
        CreateAMAndAnswersController cAmandAnsCtrller2 = new CreateAMAndAnswersController();
        System.assertEquals(cAmandAnsCtrller2.tempId,paForAssObjApiandAssTempList[0].Assessment_Template__c);
        System.assertEquals(cAmandAnsCtrller2.objId,'');
        System.assertEquals(cAmandAnsCtrller2.amId,'');
        System.assertEquals(cAmandAnsCtrller2.PARecordId,paForAssObjApiandAssTempList[0].Id);
        System.assertEquals(cAmandAnsCtrller2.assessbleObjAPI,'Account');
        System.assertEquals(cAmandAnsCtrller2.headerStr,asstempList[0].Public_Assessment_Page_Header__c);
        System.assertEquals(cAmandAnsCtrller2.footerStr,null);
        System.assertEquals(cAmandAnsCtrller2.customScriptConfigured,'test URL');        
        System.assertEquals(cAmandAnsCtrller2.tabTitle,asstempList[0].Public_Assessment_Viewer_Title__c);
        System.assertEquals(cAmandAnsCtrller2.errHandler,'');
        System.assertEquals(cAmandAnsCtrller2.imgURl,'www.google.com/servlet/servlet.FileDownload?file='+attachList[0].Id);        
        System.assertEquals(cAmandAnsCtrller2.headerText,'');
        System.assertEquals(cAmandAnsCtrller2.basicStyle,'');
       
        Map<string,string> overlayDetailMap2  = new Map<string,string>();
        overlayDetailMap2.put('isEnable',string.valueOf(asstempList[0].Enable_Survey_Overlay__c));
        overlayDetailMap2.put('Header',asstempList[0].Survey_Overlay_Header_Text__c);
        overlayDetailMap2.put('Body',asstempList[0].Survey_Overlay_Text__c);
        overlayDetailMap2.put('ButtonText',asstempList[0].Survey_Overlay_button_Text__c);
        String overlayDetailStr2 = JSON.serialize(overlayDetailMap2);
        System.assertEquals(cAmandAnsCtrller2.overlayDetailStr,overlayDetailStr2);
        
        System.assertEquals(cAmandAnsCtrller2.hideSectionTitles,asstempList[0].Hide_Section_titles__c);
        System.assertEquals(cAmandAnsCtrller2.moveforward,true);
        System.assertEquals(cAmandAnsCtrller2.singleQuestionMode,false);        
        System.assertEquals(cAmandAnsCtrller2.showIntroText,asstempList[0].Enable_Survey_Intro_Text__c);
        System.assertEquals(cAmandAnsCtrller2.showSecDesc,asstempList[0].Enable_Section_Description__c);
        System.assertEquals(cAmandAnsCtrller2.hasLinkExpired ,false);
        System.assertEquals(cAmandAnsCtrller2.hasAssessableObj,true);
        System.assertEquals(cAmandAnsCtrller2.autoSubmit,false);
        System.assertEquals(cAmandAnsCtrller2.pathList,new List<String>{'/srStyle.css'} );
        System.assert(cAmandAnsCtrller2.srName.contains(asstempList[0].Static_Resource_Name__c));
        System.assert(cAmandAnsCtrller2.tabIconSRName.contains('base64'));
        System.assert(cAmandAnsCtrller2.headerFilePath.contains(asstempList[0].Static_Resource_Name__c+'/header.html'));
        System.assert(cAmandAnsCtrller2.footerFilePath.contains(asstempList[0].Static_Resource_Name__c+'/footer.html'));
        System.assertEquals(cAmandAnsCtrller2.webIntercept,false); 
                
        //case 5 : with WebIntercept = true & with amId in PA Link
        
        ApexPages.currentPage().getParameters().put('WebIntercept', 'true');
        ApexPages.currentPage().getParameters().put('paId',pa.Id);
        CreateAMAndAnswersController cAmandAnsCtrller = new CreateAMAndAnswersController();
        System.assertEquals(cAmandAnsCtrller.tempId,queryAMList[0].InvestigationType__c);
        System.assertEquals(cAmandAnsCtrller.objId,queryAMList[0].Facility_Name__c,acList[0].Id);
        System.assertEquals(cAmandAnsCtrller.amId,pa.Assignment_Manager__c);
        System.assertEquals(cAmandAnsCtrller.PARecordId,pa.Id);
        System.assertEquals(cAmandAnsCtrller.assessbleObjAPI,'Account');
        System.assertEquals(cAmandAnsCtrller.headerStr,asstempList[0].Public_Assessment_Page_Header__c);
        System.assertEquals(cAmandAnsCtrller.footerStr,null);
        System.assertEquals(cAmandAnsCtrller.customScriptConfigured,'test URL');
        System.assert(cAmandAnsCtrller.srName.contains(asstempList[0].Web_Intercept_PA_Static_Resource_Name__c));
        System.assert(cAmandAnsCtrller.tabIconSRName.contains('base64'));
        //System.assertEquals(cAmandAnsCtrller.srName,asstempList[0].Web_Intercept_PA_Static_Resource_Name__c);
        //System.assertEquals(cAmandAnsCtrller.tabIconSRName,'');
        System.assertEquals(cAmandAnsCtrller.tabTitle,asstempList[0].Public_Assessment_Viewer_Title__c);
        System.assertEquals(cAmandAnsCtrller.errHandler,'');
        System.assertEquals(cAmandAnsCtrller.imgURl,'www.google.com/servlet/servlet.FileDownload?file='+attachList[0].Id);        
        System.assertEquals(cAmandAnsCtrller.headerText,'Test Heading text - TestAcc1');
        System.assertEquals(cAmandAnsCtrller.basicStyle,'');
        System.assert(cAmandAnsCtrller.headerFilePath.contains(asstempList[0].Web_Intercept_PA_Static_Resource_Name__c+'/header.html'));
        System.assert(cAmandAnsCtrller.footerFilePath.contains(asstempList[0].Web_Intercept_PA_Static_Resource_Name__c+'/footer.html'));
        //System.assertEquals(cAmandAnsCtrller.headerFilePath,asstempList[0].Web_Intercept_PA_Static_Resource_Name__c+'/header.html');
        //System.assertEquals(cAmandAnsCtrller.footerFilePath,asstempList[0].Web_Intercept_PA_Static_Resource_Name__c+'/footer.html');
        
        Map<string,string> overlayDetailMap  = new Map<string,string>();
        overlayDetailMap.put('isEnable',string.valueOf(asstempList[0].Enable_Survey_Overlay__c));
        overlayDetailMap.put('Header',asstempList[0].Survey_Overlay_Header_Text__c);
        overlayDetailMap.put('Body',asstempList[0].Survey_Overlay_Text__c);
        overlayDetailMap.put('ButtonText',asstempList[0].Survey_Overlay_button_Text__c);
        String overlayDetailStr = JSON.serialize(overlayDetailMap);
        System.assertEquals(cAmandAnsCtrller.overlayDetailStr,overlayDetailStr);
        
        System.assertEquals(cAmandAnsCtrller.hideSectionTitles,asstempList[0].Hide_Section_titles__c);
        System.assertEquals(cAmandAnsCtrller.moveforward,true);
        System.assertEquals(cAmandAnsCtrller.singleQuestionMode,asstempList[0].Public_Assessment_Single_Question_Mode__c);
        System.assertEquals(cAmandAnsCtrller.webIntercept,true);
        System.assertEquals(cAmandAnsCtrller.showIntroText,asstempList[0].Enable_Survey_Intro_Text__c);
        System.assertEquals(cAmandAnsCtrller.showSecDesc,asstempList[0].Enable_Section_Description__c);
        System.assertEquals(cAmandAnsCtrller.hasLinkExpired ,false);
        System.assertEquals(cAmandAnsCtrller.hasAssessableObj,true);
        System.assertEquals(cAmandAnsCtrller.autoSubmit,false);
        System.assertEquals(cAmandAnsCtrller.pathList,new List<String>{'/style.css'} );
        
    }
    
    public static testMethod void testWithNoBackgroundColour() {
        List<Public_Assessment__c> paList = [SELECT Id, Assignment_Manager__c  FROM Public_Assessment__c];        
        Public_Assessment__c pa = new Public_Assessment__c();
        
        for(Public_Assessment__c p : paList) {
            if(p.Assignment_Manager__c != null) {
                pa = p;
            }
        }
        
        List<IssueRequest_Life_Cycle__c> queryAMList = [ SELECT Id, InvestigationType__c,Facility_Name__c 
                        FROM IssueRequest_Life_Cycle__c 
                        WHERE Id = :pa.Assignment_Manager__c];
        
        List<Main_questionaire__c> asstempList = [SELECT Id, Google_Analytics_Script__c, Modal_Window_Text__c,
           Name, Public_Assessment_Page_Footer__c, Public_Assessment_Page_Header__c,
           Static_Resource_Name__c, SRFile_Path__c, Template_name__c, Hide_Section_titles__c,
           Public_Assessment_Single_Question_Mode__c,Auto_Submit__c,Web_Intercept_PA_Resource_File_Path__c,
           Web_Intercept_PA_Static_Resource_Name__c, Public_Assessment_Viewer_Tab_Icon__c,
           Public_Assessment_Viewer_Title__c,PA_Header_and_Button_Background_Color__c,PA_Header_and_Button_Text_Color__c,
           PA_Template_Heading_Text__c,Enable_Section_Description__c,Enable_Survey_Intro_Text__c,
           Enable_Survey_Overlay__c, Survey_Overlay_Header_Text__c, Survey_Overlay_Text__c,
           Survey_Overlay_button_Text__c  
           FROM Main_questionaire__c WHERE Id = :queryAMList[0].InvestigationType__c];
           
        assTempList[0].PA_Header_and_Button_Background_Color__c = null;
        update assTempList;
        List<Attachment> attachList = [SELECT Id,Name FROM Attachment WHERE ParentId = :asstempList[0].Id];
        
        // AT with Text Color alone        
        
        ApexPages.currentPage().getParameters().put('paId',pa.Id);        
        CreateAMAndAnswersController cAmandAnsCtrller7 = new CreateAMAndAnswersController();
        
        System.assertEquals(cAmandAnsCtrller7.tempId,queryAMList[0].InvestigationType__c);
        System.assertEquals(cAmandAnsCtrller7.objId,queryAMList[0].Facility_Name__c);
        System.assertEquals(cAmandAnsCtrller7.amId,pa.Assignment_Manager__c);
        System.assertEquals(cAmandAnsCtrller7.PARecordId,pa.Id);
        System.assertEquals(cAmandAnsCtrller7.assessbleObjAPI,'Account');
        System.assertEquals(cAmandAnsCtrller7.headerStr,asstempList[0].Public_Assessment_Page_Header__c);
        System.assertEquals(cAmandAnsCtrller7.footerStr,null);
        System.assertEquals(cAmandAnsCtrller7.customScriptConfigured,'test URL');        
        System.assertEquals(cAmandAnsCtrller7.tabTitle,asstempList[0].Public_Assessment_Viewer_Title__c);
        System.assertEquals(cAmandAnsCtrller7.errHandler,'');
        System.assertEquals(cAmandAnsCtrller7.imgURl,'null/servlet/servlet.FileDownload?file='+attachList[0].Id);        
        System.assertEquals(cAmandAnsCtrller7.headerText,'Test Heading text - TestAcc1');
        System.assertEquals(cAmandAnsCtrller7.basicStyle,'');
   
        Map<string,string> overlayDetailMap7  = new Map<string,string>();
        overlayDetailMap7.put('isEnable',string.valueOf(asstempList[0].Enable_Survey_Overlay__c));
        overlayDetailMap7.put('Header',asstempList[0].Survey_Overlay_Header_Text__c);
        overlayDetailMap7.put('Body',asstempList[0].Survey_Overlay_Text__c);
        overlayDetailMap7.put('ButtonText',asstempList[0].Survey_Overlay_button_Text__c);
        String overlayDetailStr7 = JSON.serialize(overlayDetailMap7);
        System.assertEquals(cAmandAnsCtrller7.overlayDetailStr,overlayDetailStr7);
        
        System.assertEquals(cAmandAnsCtrller7.hideSectionTitles,asstempList[0].Hide_Section_titles__c);
        System.assertEquals(cAmandAnsCtrller7.moveforward,true);
        System.assertEquals(cAmandAnsCtrller7.singleQuestionMode,asstempList[0].Public_Assessment_Single_Question_Mode__c);
        System.assertEquals(cAmandAnsCtrller7.webIntercept,false);
        System.assertEquals(cAmandAnsCtrller7.showIntroText,asstempList[0].Enable_Survey_Intro_Text__c);
        System.assertEquals(cAmandAnsCtrller7.showSecDesc,asstempList[0].Enable_Section_Description__c);
        System.assertEquals(cAmandAnsCtrller7.hasLinkExpired ,false);
        System.assertEquals(cAmandAnsCtrller7.hasAssessableObj,true);
        System.assertEquals(cAmandAnsCtrller7.autoSubmit,false);
        System.assertEquals(cAmandAnsCtrller7.pathList,new List<String>{'/srStyle.css'} ); 
        
        // assTemplate having PA_Template_Heading_Text__c  without{}
        
        assTempList[0].PA_Header_and_Button_Background_Color__c = '#A6B9CC';
        assTempList[0].PA_Template_Heading_Text__c = 'Test Heading text -';
        update assTempList;
        
        ApexPages.currentPage().getParameters().put('paId',pa.Id);        
        CreateAMAndAnswersController cAmandAnsCtrller8 = new CreateAMAndAnswersController();
        
        System.assertEquals(cAmandAnsCtrller8.tempId,queryAMList[0].InvestigationType__c);
        System.assertEquals(cAmandAnsCtrller8.objId,queryAMList[0].Facility_Name__c);
        System.assertEquals(cAmandAnsCtrller8.amId,pa.Assignment_Manager__c);
        System.assertEquals(cAmandAnsCtrller8.PARecordId,pa.Id);
        System.assertEquals(cAmandAnsCtrller8.assessbleObjAPI,'Account');
        System.assertEquals(cAmandAnsCtrller8.headerStr,asstempList[0].Public_Assessment_Page_Header__c);
        System.assertEquals(cAmandAnsCtrller8.footerStr,null);
        System.assertEquals(cAmandAnsCtrller8.customScriptConfigured,'test URL');        
        System.assertEquals(cAmandAnsCtrller8.tabTitle,asstempList[0].Public_Assessment_Viewer_Title__c);
        System.assertEquals(cAmandAnsCtrller8.errHandler,'');
        System.assertEquals(cAmandAnsCtrller8.imgURl,'null/servlet/servlet.FileDownload?file='+attachList[0].Id);        
        System.assertEquals(cAmandAnsCtrller8.headerText,'Test Heading text -');
        System.assertEquals(cAmandAnsCtrller8.basicStyle,'');
   
        Map<string,string> overlayDetailMap8  = new Map<string,string>();
        overlayDetailMap8.put('isEnable',string.valueOf(asstempList[0].Enable_Survey_Overlay__c));
        overlayDetailMap8.put('Header',asstempList[0].Survey_Overlay_Header_Text__c);
        overlayDetailMap8.put('Body',asstempList[0].Survey_Overlay_Text__c);
        overlayDetailMap8.put('ButtonText',asstempList[0].Survey_Overlay_button_Text__c);
        String overlayDetailStr8 = JSON.serialize(overlayDetailMap8);
        System.assertEquals(cAmandAnsCtrller8.overlayDetailStr,overlayDetailStr8);
        
        System.assertEquals(cAmandAnsCtrller8.hideSectionTitles,asstempList[0].Hide_Section_titles__c);
        System.assertEquals(cAmandAnsCtrller8.moveforward,true);
        System.assertEquals(cAmandAnsCtrller8.singleQuestionMode,asstempList[0].Public_Assessment_Single_Question_Mode__c);
        System.assertEquals(cAmandAnsCtrller8.webIntercept,false);
        System.assertEquals(cAmandAnsCtrller8.showIntroText,asstempList[0].Enable_Survey_Intro_Text__c);
        System.assertEquals(cAmandAnsCtrller8.showSecDesc,asstempList[0].Enable_Section_Description__c);
        System.assertEquals(cAmandAnsCtrller8.hasLinkExpired ,false);
        System.assertEquals(cAmandAnsCtrller8.hasAssessableObj,true);
        System.assertEquals(cAmandAnsCtrller8.autoSubmit,false);
        System.assertEquals(cAmandAnsCtrller8.pathList,new List<String>{'/srStyle.css'} ); 
    }
    
    public static testMethod void testwithNoHeaderButtonColour() {
        List<Public_Assessment__c> paList = [SELECT Id, Assignment_Manager__c  FROM Public_Assessment__c];
        Public_Assessment__c pa = new Public_Assessment__c();
        
        for(Public_Assessment__c p : paList) {
            if(p.Assignment_Manager__c != null) {
                pa = p;
            }
        }
        
        List<IssueRequest_Life_Cycle__c> queryAMList = [ SELECT Id, InvestigationType__c,Facility_Name__c 
                        FROM IssueRequest_Life_Cycle__c 
                        WHERE Id = :pa.Assignment_Manager__c];
        
        List<Main_questionaire__c> asstempList = [SELECT Id, Google_Analytics_Script__c, Modal_Window_Text__c,
           Name, Public_Assessment_Page_Footer__c, Public_Assessment_Page_Header__c,
           Static_Resource_Name__c, SRFile_Path__c, Template_name__c, Hide_Section_titles__c,
           Public_Assessment_Single_Question_Mode__c,Auto_Submit__c,Web_Intercept_PA_Resource_File_Path__c,
           Web_Intercept_PA_Static_Resource_Name__c, Public_Assessment_Viewer_Tab_Icon__c,
           Public_Assessment_Viewer_Title__c,PA_Header_and_Button_Background_Color__c,PA_Header_and_Button_Text_Color__c,
           PA_Template_Heading_Text__c,Enable_Section_Description__c,Enable_Survey_Intro_Text__c,
           Enable_Survey_Overlay__c, Survey_Overlay_Header_Text__c, Survey_Overlay_Text__c,
           Survey_Overlay_button_Text__c  
           FROM Main_questionaire__c WHERE Id = :queryAMList[0].InvestigationType__c];
        
        assTempList[0].PA_Header_and_Button_Text_Color__c = null;        
        assTempList[0].PA_Template_Heading_Text__c = 'Test Heading text - {test}'; 
        update assTempList;
        List<Attachment> attachList = [SELECT Id,Name FROM Attachment WHERE ParentId = :asstempList[0].Id];
        
        // AT with bg-color alone         
        
        ApexPages.currentPage().getParameters().put('paId',pa.Id);        
        CreateAMAndAnswersController cAmandAnsCtrller8 = new CreateAMAndAnswersController();
        
        System.assertEquals(cAmandAnsCtrller8.tempId,queryAMList[0].InvestigationType__c);
        System.assertEquals(cAmandAnsCtrller8.objId,queryAMList[0].Facility_Name__c);
        System.assertEquals(cAmandAnsCtrller8.amId,pa.Assignment_Manager__c);
        System.assertEquals(cAmandAnsCtrller8.PARecordId,pa.Id);
        System.assertEquals(cAmandAnsCtrller8.assessbleObjAPI,'Account');
        System.assertEquals(cAmandAnsCtrller8.headerStr,asstempList[0].Public_Assessment_Page_Header__c);
        System.assertEquals(cAmandAnsCtrller8.footerStr,null);
        System.assertEquals(cAmandAnsCtrller8.customScriptConfigured,'test URL');        
        System.assertEquals(cAmandAnsCtrller8.tabTitle,asstempList[0].Public_Assessment_Viewer_Title__c);
        System.assertEquals(cAmandAnsCtrller8.errHandler,'');
        System.assertEquals(cAmandAnsCtrller8.imgURl,'null/servlet/servlet.FileDownload?file='+attachList[0].Id);        
        System.assertEquals(cAmandAnsCtrller8.headerText,'Test Heading text - {test}');
        System.assertEquals(cAmandAnsCtrller8.basicStyle,'');
   
        Map<string,string> overlayDetailMap8  = new Map<string,string>();
        overlayDetailMap8.put('isEnable',string.valueOf(asstempList[0].Enable_Survey_Overlay__c));
        overlayDetailMap8.put('Header',asstempList[0].Survey_Overlay_Header_Text__c);
        overlayDetailMap8.put('Body',asstempList[0].Survey_Overlay_Text__c);
        overlayDetailMap8.put('ButtonText',asstempList[0].Survey_Overlay_button_Text__c);
        String overlayDetailStr8 = JSON.serialize(overlayDetailMap8);
        System.assertEquals(cAmandAnsCtrller8.overlayDetailStr,overlayDetailStr8);
        
        System.assertEquals(cAmandAnsCtrller8.hideSectionTitles,asstempList[0].Hide_Section_titles__c);
        System.assertEquals(cAmandAnsCtrller8.moveforward,true);
        System.assertEquals(cAmandAnsCtrller8.singleQuestionMode,asstempList[0].Public_Assessment_Single_Question_Mode__c);
        System.assertEquals(cAmandAnsCtrller8.webIntercept,false);
        System.assertEquals(cAmandAnsCtrller8.showIntroText,asstempList[0].Enable_Survey_Intro_Text__c);
        System.assertEquals(cAmandAnsCtrller8.showSecDesc,asstempList[0].Enable_Section_Description__c);
        System.assertEquals(cAmandAnsCtrller8.hasLinkExpired ,false);
        System.assertEquals(cAmandAnsCtrller8.hasAssessableObj,true);
        System.assertEquals(cAmandAnsCtrller8.autoSubmit,false);
        System.assertEquals(cAmandAnsCtrller8.pathList,new List<String>{'/srStyle.css'} );
        
        //To cover unused methods and classes.
        
        String rsqt = CreateAMAndAnswersController.returnSectionAndQuestionTemplate(null,false);
        String sars = CreateAMAndAnswersController.saveAnswerRecords(null,null,null,null,null,null,null,null,null,null,null,null,null,null);
        String sar = CreateAMAndAnswersController.saveAnswerRecord(null,null,null,null,null,null,null,null,null,null,null,null,null,null,null);
        String star = CreateAMAndAnswersController.saveDecisionTreeAnswerRecords(null,null,null,null,null,null,null);
        String sas = CreateAMAndAnswersController.saveAttachments(null);
        String sa = CreateAMAndAnswersController.saveAttachment(null,null);
        String qury = CreateAMAndAnswersController.query(null);
        List<IssueRequest_Life_Cycle__c> mpr = CreateAMAndAnswersController.modalPopupRec(null);
        Map<String, String> mpr1 = CreateAMAndAnswersController.modalPopupRec1(null, null);
        String mkerr = CreateAMAndAnswersController.makeError(null, null);
        CreateAMAndAnswersController.attachmentClass ac = new CreateAMAndAnswersController.attachmentClass();
        CreateAMAndAnswersController.AnswerRecordClass arc = new CreateAMAndAnswersController.AnswerRecordClass();
        CreateAMAndAnswersController.AttachmentDetails ad =new CreateAMAndAnswersController.AttachmentDetails();
        CreateAMAndAnswersController.CaseRecordClass crc = new CreateAMAndAnswersController.CaseRecordClass();
        CreateAMAndAnswersController.ErrorClass ec = new CreateAMAndAnswersController.ErrorClass();
        
        //for distribution
        List<Account> acList = [SELECT Id FROM Account];
        List<Main_questionaire__c> assTempList1 = [SELECT Id FROM Main_questionaire__c];
        List<Distribution__c> distributionList = [SELECT Id, Pre_Assessment_Message__c FROM Distribution__c];
        List<Public_Assessment__c> pa1 = new List<Public_Assessment__c> {
            new Public_Assessment__c(Facility_Name__c = acList[0].Id, Expiration_Date__c = System.today()+2, Assessible_Object_ID__c = acList[0].Id, Assessment_Template__c = assTempList1[0].Id, distribution__c = distributionList[1].Id),
            new Public_Assessment__c(Facility_Name__c = acList[0].Id, Expiration_Date__c = System.today()+2, Assessible_Object_ID__c = acList[0].Id, Assessment_Template__c = assTempList1[0].Id, distribution__c = distributionList[2].Id),
            new Public_Assessment__c(Facility_Name__c = acList[0].Id, Expiration_Date__c = System.today()+2, Assessible_Object_ID__c = acList[0].Id, Assessment_Template__c = assTempList1[0].Id, distribution__c = distributionList[3].Id)
        };
        insert pa1;
        
        ApexPages.currentPage().getParameters().put('paId',pa1[1].Id);        
        CreateAMAndAnswersController cAmandAnsCtrller9 = new CreateAMAndAnswersController();
        
        ApexPages.currentPage().getParameters().put('paId',pa1[2].Id);        
        CreateAMAndAnswersController cAmandAnsCtrller10 = new CreateAMAndAnswersController();
        
        ApexPages.currentPage().getParameters().put('paId',pa1[0].Id);        
        CreateAMAndAnswersController cAmandAnsCtrller11 = new CreateAMAndAnswersController();
        Map<string,string> overlayDetailMap1  = new Map<string,string>();
        overlayDetailMap1.put('Body',distributionList[2].Pre_Assessment_Message__c);
        overlayDetailMap1.put('isEnable',string.valueOf(asstempList[0].Enable_Survey_Overlay__c));
        overlayDetailMap1.put('Header',asstempList[0].Survey_Overlay_Header_Text__c);
        overlayDetailMap1.put('ButtonText',asstempList[0].Survey_Overlay_button_Text__c);
        String overlayDetailStr1 = JSON.serialize(overlayDetailMap1);
        System.assertEquals(cAmandAnsCtrller11.overlayDetailStr,overlayDetailStr1);
    }
    
}