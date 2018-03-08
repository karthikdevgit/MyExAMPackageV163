@isTest
private class TestAuraAMAnalyticsController {
    
    public static List<AuraAMAnalyticsController.AMAnalytic> responseOfAM_Analytic;
    
    @testSetup static void generateInputToChart(){
        Main_questionaire__c assessment = new Main_questionaire__c(Template_name__c = 'testing');
        insert assessment;
        DateTime completedDate = (DateTime) Date.today();
        List<IssueRequest_Life_Cycle__c> AssignmentManagers = new List<IssueRequest_Life_Cycle__c>{
            new IssueRequest_Life_Cycle__c(Status__c = 'Completed', InvestigationType__c = assessment.Id),
            new IssueRequest_Life_Cycle__c(Status__c = 'Open', InvestigationType__c = assessment.Id, Date_Completed__c=completedDate)
        };
        insert AssignmentManagers;
        
    }
    
    static testMethod void validateAuraAMByStatus() {
        List<Main_questionaire__c> assessments = [SELECT Id FROM Main_questionaire__c];
        
        responseOfAM_Analytic = AuraAMAnalyticsController.getAmByOverallStatus(assessments[0].Id, '');
        /**
        System.assertEquals('Open', responseOfAM_Analytic[0].Xaxis);
        System.assertEquals(1, responseOfAM_Analytic[0].Yaxis);
        System.assertEquals('Completed', responseOfAM_Analytic[1].Xaxis);
        System.assertEquals(1, responseOfAM_Analytic[1].Yaxis);
        **/
    }
    static testMethod void validateAuraAMByCreatedDate() {
        List<Main_questionaire__c> assessments = [SELECT Id FROM Main_questionaire__c];
        responseOfAM_Analytic = AuraAMAnalyticsController.getAmByCreatedDate(assessments[0].Id, 'THIS_WEEK');
        Date todayDate = Date.today();
        String recordCreatedDate = todayDate.format();
        Integer getDay = AuraAMAnalyticsController.getDay(todayDate);
        //System.assertEquals(2, responseOfAM_Analytic[getDay].Yaxis);
        
        
        responseOfAM_Analytic = AuraAMAnalyticsController.getAmByCreatedDate(assessments[0].Id, 'LAST_WEEK');
        responseOfAM_Analytic = AuraAMAnalyticsController.getAmByCreatedDate(assessments[0].Id, 'THIS_MONTH');
        Integer day = todayDate.day();
        Integer getWeek = Math.round(day/ 7); 
        //System.assertEquals(2, responseOfAM_Analytic[getWeek].Yaxis);
        
        responseOfAM_Analytic = AuraAMAnalyticsController.getAmByCreatedDate(assessments[0].Id, 'LAST_MONTH');
        
        responseOfAM_Analytic = AuraAMAnalyticsController.getAmByCreatedDate(assessments[0].Id, 'THIS_YEAR');
        Integer getMonth = todayDate.month();
        //System.assertEquals(2, responseOfAM_Analytic[getMonth-1].Yaxis);
        
        responseOfAM_Analytic = AuraAMAnalyticsController.getAmByCreatedDate(assessments[0].Id, 'LAST_YEAR');
        
        responseOfAM_Analytic = AuraAMAnalyticsController.getAmByCreatedDate(assessments[0].Id, 'LAST_N_YEARS:2');
        List<Integer> getYears = AuraAMAnalyticsController.getYears(todayDate.year(), 2);
        //System.assertEquals(getYears[0], Integer.valueOf(responseOfAM_Analytic[0].Xaxis));
        //System.assertEquals(getYears[1], Integer.valueOf(responseOfAM_Analytic[1].Xaxis));
        
    }
    static testMethod void validateAuraAMByCompletedDate() {
        List<Main_questionaire__c> assessments = [SELECT Id FROM Main_questionaire__c];
        responseOfAM_Analytic = AuraAMAnalyticsController.getAmByCompletedDate(assessments[0].Id, 'THIS_WEEK');
        Date todayDate = Date.today();
        String recordCreatedDate = todayDate.format();
        Integer getDay = AuraAMAnalyticsController.getDay(todayDate);
        //System.assertEquals(1, responseOfAM_Analytic[getDay].Yaxis);
        
        
        responseOfAM_Analytic = AuraAMAnalyticsController.getAmByCompletedDate(assessments[0].Id, 'LAST_WEEK');
        responseOfAM_Analytic = AuraAMAnalyticsController.getAmByCompletedDate(assessments[0].Id, 'THIS_MONTH');
        Integer day = todayDate.day();
        Integer getWeek = Math.round(day/ 7); 
        //System.assertEquals(1, responseOfAM_Analytic[getWeek].Yaxis);
        
        responseOfAM_Analytic = AuraAMAnalyticsController.getAmByCompletedDate(assessments[0].Id, 'LAST_MONTH');
        
        responseOfAM_Analytic = AuraAMAnalyticsController.getAmByCompletedDate(assessments[0].Id, 'THIS_YEAR');
        Integer getMonth = todayDate.month();
        //System.assertEquals(1, responseOfAM_Analytic[getMonth-1].Yaxis);
        
        responseOfAM_Analytic = AuraAMAnalyticsController.getAmByCompletedDate(assessments[0].Id, 'LAST_YEAR');
        
        responseOfAM_Analytic = AuraAMAnalyticsController.getAmByCompletedDate(assessments[0].Id, 'LAST_N_YEARS:2');
        List<Integer> getYears = AuraAMAnalyticsController.getYears(todayDate.year(), 2);
        //System.assertEquals(getYears[0], Integer.valueOf(responseOfAM_Analytic[0].Xaxis));
        //System.assertEquals(getYears[1], Integer.valueOf(responseOfAM_Analytic[1].Xaxis));
    }
    
}