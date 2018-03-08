@isTest
public class TestAssessmentMapBuilderController {
    static testMethod void method(){
        Assessment_Event__c ae = new Assessment_Event__c();
        ae.Description__c = 'test ae';
        ae.Name = 'test ae';
        insert ae;
        Assessment_Group__c ag = new Assessment_Group__c();
        ag.Name = 'test assessment group';
        ag.Type__c = 'Account';
        insert ag;
        IssueRequest_Life_Cycle__c[] am = new IssueRequest_Life_Cycle__c[]{
            new IssueRequest_Life_Cycle__c(Assessment_Group__c = ag.Id,
                                          Assessment_Event__c = ae.Id
                                          )  
        }; 
        insert am;
        Map_Pin_Color_Configuration__c mpcc = new Map_Pin_Color_Configuration__c();
        mpcc.Assessible_Object__c = 'Account';
        insert mpcc;
        AssessmentMapBuilderController ambc = new AssessmentMapBuilderController();
        ambc.assessmentGroup = ag.Id;
        
        //ambc.assessmentGroup = ag.Id;
        ambc.assessableObjectChanged();
        //ambc.assessmentGroup = ag.Id;
        ambc.assessmentGroupChanged();
        ApexPages.currentPage().getHeaders().put('USER-AGENT','USER-AGENT iphone');
        ambc.getshowhead();
        ambc.submitmap();
        ambc.getAMPriority();
        ambc.getMappingGroup();
        ambc.getAMStatus();
        ambc.getAMAssessmentCompletion();
        ambc.getAMAssessmentType();
        
        AssessmentMapBuilderController ambc1 = new AssessmentMapBuilderController();
        ambc1.assessmentGroup = null;
        new AssessmentMapBuilderController();
        ambc.assessmentGroup = 'not none';
        ambc.submitmap();
        List<Map_Pin_Color_Configuration__c> mpcclist = [SELECT ID FROM Map_Pin_Color_Configuration__c];
        delete mpcclist;
        new AssessmentMapBuilderController();
        ambc1.ColorBy = 'test';

        AssessmentMapBuilderController ambc2 = new AssessmentMapBuilderController();
        ambc2.submitmap();
        List<ApexPages.Message> msgs = ApexPages.getMessages();
        system.assertEquals(msgs[0].getDetail(), 'Please select a Assessment Group');
    }
}