@isTest

public class TestRestGetDecisionTree {
    
    static testmethod void method1(){
        List<String> templateIdList = new List<String>();
        
        Main_questionaire__c temp = new Main_questionaire__c();//Template creation
        temp.Template_name__c = 'Template1';
        insert temp;
        Main_questionaire__c temp1 = new Main_questionaire__c();//Template creation
        temp1.Template_name__c = 'Template2';
        insert temp1;
        
        templateIdList.add(temp.Id);
        templateIdList.add(temp1.Id);
        String ret = RestGetDecisionTree.getDecisionTree(templateIdList);
    
    System.assert( ret != Null );        
    }
}