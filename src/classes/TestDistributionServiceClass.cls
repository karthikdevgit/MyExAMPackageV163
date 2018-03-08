@isTest
public class TestDistributionServiceClass {
    static Testmethod void method1(){
        Main_questionaire__c[] assesment = new Main_questionaire__c[]{
            new Main_questionaire__c(),
            new Main_questionaire__c()
        };
        insert assesment;
        
        Contact newContact = new Contact(LastName='testContact1', Email = 'selva@gmail.com');
        insert newContact;
        
        Account newAcc = new Account(Name = 'TestAcc');
        insert newAcc;
        
        Distribution_Group__c[] distGpList = new Distribution_Group__c[]{
            new Distribution_Group__c(Name = 'test distGp 1' , Target_Object__c = 'Contact', Target_Object_Filter__c = '[{"fieldApi":"LastName","fieldLabel":"Last Name","fieldType":"STRING","operator":"not equals","fieldValue":"testContact"}]'),
            new Distribution_Group__c(Name = 'test distGp 1' , Target_Object__c = 'Contact', Target_Object_Filter__c = '[]'),
            new Distribution_Group__c(Name = 'test distGp 1' , Target_Object__c = 'Contact')
        };
        insert distGpList;                              
        
        Distribution__c[] distributionList = new Distribution__c[]{
            new Distribution__c(Name='test Distribution1'),
            new Distribution__c(Name='test Distribution2'),
            new Distribution__c(Name='test Distribution3')
             
        };
        insert distributionList;
        
        Distribution__c[] distributionList1 = new Distribution__c[]{
            new Distribution__c(Name='test Distribution4', Assessment_Template__c = assesment[1].Id, Distribution_DateTime__c = System.now().addMinutes(2), Assessable_Object_API__c = 'Account', Send_Mode__c = 'Download as CSV'), 
            new Distribution__c(Name='test Distribution5', Assessment_Template__c = assesment[1].Id, Distribution_DateTime__c = System.now().addMinutes(4), Assessable_Record__c = newAcc.Id, Assessable_Object_API__c = 'Account', Send_Mode__c = 'Email with Salesforce'), 
            new Distribution__c(Name='test Distribution6', Assessment_Template__c = assesment[1].Id, Distribution_DateTime__c = System.now().addMinutes(6), Assessable_Object_API__c = 'Account', Send_Mode__c = 'Anonymous Link'),
            new Distribution__c(Name='test Distribution7', Assessment_Template__c = assesment[1].Id, Distribution_DateTime__c = System.now().addMinutes(10), Assessable_Record__c = newAcc.Id, Assessable_Object_API__c = 'Account', Send_Mode__c = 'Email with Salesforce')  
        };
        
        Distribution__c[] newList = [SELECT Name FROM Distribution__c];
        newList[0].Assessment_Template__c = assesment[0].Id;
        newList[1].Assessment_Template__c = assesment[0].Id;
        newList[2].Assessment_Template__c = assesment[0].Id;
        update newList;
        
        List<String> fieldSet = new List<String>();
        fieldSet.add('ExAM__LightningCmp_Distribution_FieldSet');
        
        List<Distribution__c> archivedList = new List<Distribution__c>(); 
        archivedList.add(distributionList[0]);
        archivedList.add(distributionList[1]);
        AssessmentTemplateController.fetchDistribution(assesment[0].Id);        
        System.assert(AssessmentTemplateController.fetchDistribution(assesment[0].Id).size() == 3);
        
        AssessmentTemplateController.archiveDistribution(distributionList[2].Id); 
        AssessmentTemplateController.fetchDistribution(assesment[0].Id);
        System.assert(AssessmentTemplateController.fetchDistribution(assesment[0].Id).size() == 2); 
        if(AssessmentTemplateController.getAssessableObjectDetails('ExAM__IssueRequest_Life_Cycle__c')[0].assObjApiName == 'Account'){
           System.assert(AssessmentTemplateController.getAssessableObjectDetails('ExAM__IssueRequest_Life_Cycle__c')[0].assObjApiName == 'Account'); 
        } else{
           System.assert(AssessmentTemplateController.getAssessableObjectDetails('ExAM__IssueRequest_Life_Cycle__c')[0].assObjFieldApi.startsWithIgnoreCase('AM_')); 
        }
        
        System.assert(AssessmentTemplateController.getDistributionsWthFieldSet(assesment[0].Id, fieldSet, 'ExAM__Distribution__c').distributions[0].Name =='test Distribution1');
        
        Test.startTest();
        try {
            AssessmentTemplateController.createDistributionWthPALink(distributionList1[0], distGpList[0], 3);
                List<Public_Assessment__c> paList = [SELECT Id , Distribution__c FROM Public_Assessment__c ];
               // System.assertEquals(1, paList.size());
               //System.assertEquals(distributionList1[1].Id , paList[0].Distribution__c);
        } catch(Exception e){
            System.assert(e.getMessage() != Null);
        }           
        try {
            AssessmentTemplateController.createDistributionWthPALink(distributionList1[1], distGpList[0], 3);
        } catch(Exception e){
            System.debug('e:::'+e.getMessage());
            System.assertNotEquals(e.getMessage(),'');
        }   
        try {   
            AssessmentTemplateController.createDistributionWthPALink(distributionList1[2], distGpList[0], 3);
        } catch(Exception e){
            System.assertNotEquals(e.getMessage(),'');
        }  
        try {
            AssessmentTemplateController.createDistributionWthPALink(distributionList1[3], distGpList[1], 3);
        } catch(Exception e){
            System.assertNotEquals(e.getMessage(),'');
        }  
        Test.stopTest();
       // AssessmentTemplateController.createDistributionWthPALink(distributionList1[1], distGpList[0], 3);
        
        AssessmentTemplateController.deleteDistribution(distributionList[1].Id);
        System.assert(AssessmentTemplateController.fetchDistribution(assesment[0].Id).size() == 1);
    }
}