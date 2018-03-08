@isTest
public class TestMobileConfigController{
    
    static testMethod void test2(){
        
        Main_questionaire__c temp = new Main_questionaire__c();//Template creation
        temp.Template_name__c = 'Template1';
        insert temp;
        Main_questionaire__c temp1 = new Main_questionaire__c();//Template creation
        temp1.Template_name__c = 'Template11';
        insert temp1; 
        
        MobileConfigController mcc = new MobileConfigController();
        
        List<String> statusList = MobileConfigController.getOverallStatusList();
        System.assert(statusList.size()>0);
        
        String result = MobileConfigController.saveMobileConfig(new ExAM_Configuration__c(),String.valueOf(10),String.valueOf(10));
        //System.assertEquals('null', result);
    }
    static testMethod void test1(){
        
        Main_questionaire__c temp = new Main_questionaire__c();//Template creation
        temp.Template_name__c = 'Template1';
        insert temp;
        Main_questionaire__c temp1 = new Main_questionaire__c();//Template creation
        temp1.Template_name__c = 'Template11';
        insert temp1; 
        
        ExAM_Configuration__c e = new ExAM_Configuration__c();
        e.Name = 'Configuration';
        e.Mobile_Sync_Additional_Templates__c = temp.Id+'~'+temp1.Id;
        e.Mobile_Sync_Assignment_Manager_Statuses__c = 'safkjnsfdajsdas'; 
        e.Mobile_Sync_Last_X_Days__c = 23; 
        insert e;
        
        MobileConfigController mcc = new MobileConfigController();
        
        List<String> statusList = MobileConfigController.getOverallStatusList();
        System.assert(statusList.size()>0);
        
        String result = MobileConfigController.saveMobileConfig(new ExAM_Configuration__c(),string.valueOf(10),String.valueOf(10));
        System.assertEquals('success', result);
    }
}