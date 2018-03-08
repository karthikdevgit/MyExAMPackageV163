@isTest
public class TestViewerConfigurationController {
    static testMethod void method1() {
    
        Viewer_Custom_Configuration__c vc =new Viewer_Custom_Configuration__c();
        vc.Name = 'TestName';
        vc.Hierarchical_Object__c =true;
        vc.Answer_Options__c =true;
        vc.Data_Management__c = true;
        vc.Single_Question_Mode__c=true;
        vc.Assignment_Manager__c=true;
        vc.Assignment_Manager_List__c=true;
        insert vc;
        List<Viewer_Custom_Configuration__c> configList = [Select Id from Viewer_Custom_Configuration__c Where Name = 'TestName']; 
        System.assert(configList.size() == 1);
        
        ViewerConfigurationController vcInst = new ViewerConfigurationController();
        Viewer_Custom_Configuration__c vc1 =new Viewer_Custom_Configuration__c();
        vc1.Name = 'TestName';
        vc1.Hierarchical_Object__c =true;
        vc1.Answer_Options__c =true;
        vc1.Data_Management__c = true;
        vc1.Single_Question_Mode__c=true;
        vc1.Assignment_Manager__c=true;
        vc1.Assignment_Manager_List__c=true;
        ViewerConfigurationController.saveCustomConfigurationViewer1(vc1);
       
    }
    
    static testMethod void method2() {
    
        Viewer_Custom_Configuration__c vc =new Viewer_Custom_Configuration__c();
        vc.Name = 'TestName';
        vc.Hierarchical_Object__c =true;
        vc.Answer_Options__c =true;
        vc.Data_Management__c = true;
        vc.Single_Question_Mode__c=true;
        vc.Assignment_Manager__c=true;
        vc.Assignment_Manager_List__c=true;
        insert vc;
        List<Viewer_Custom_Configuration__c> configList = [Select Id from Viewer_Custom_Configuration__c Where Name = 'TestName']; 
        System.assert(configList.size() == 1);
        
        ViewerConfigurationController vcInst = new ViewerConfigurationController();
        Viewer_Custom_Configuration__c vc1 =new Viewer_Custom_Configuration__c();
        ViewerConfigurationController.saveCustomConfigurationViewer1(vc1);
       
    }
}