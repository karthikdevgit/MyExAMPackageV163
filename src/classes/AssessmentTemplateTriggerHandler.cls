public class AssessmentTemplateTriggerHandler {

    public static void onBeforeUpdate(Map<Id, Main_questionaire__c> oldTemplateMap, Map<Id, Main_questionaire__c> newTemplateMap, List<Main_questionaire__c> templatesList) {
        setOneTimeAssessmentOnlyWhenTemplateHasNoPublicAssessments(oldTemplateMap, templatesList);
    }

    public static void setOneTimeAssessmentOnlyWhenTemplateHasNoPublicAssessments(Map<Id, Main_questionaire__c> oldTemplateMap, List<Main_questionaire__c> templatesList) {

        List<Main_questionaire__c> templates = new List<Main_questionaire__c>();
        Map<Id, List<Public_Assessment__c>> templateIdPublicAssessmentsMap = new Map<Id, List<Public_Assessment__c>>();

        if (templatesList != null && templatesList.size() > 0) {

            for (Main_questionaire__c template : templatesList) {

                if (template.One_Time_Assessment__c
                    && (oldTemplateMap.get(template.Id).One_Time_Assessment__c != template.One_Time_Assessment__c)
                ) {
                    templates.add( template );
                }
            }
            if (templates != null && templates.size() > 0) {
                for (Public_Assessment__c pa : [SELECT Assessment_Template__c , Id, Name FROM Public_Assessment__c WHERE Assessment_Template__c IN :templates]) {
                    if (!templateIdPublicAssessmentsMap.containsKey(pa.Assessment_Template__c)) {
                        templateIdPublicAssessmentsMap.put(pa.Assessment_Template__c, new List<Public_Assessment__c>());
                    }
                    templateIdPublicAssessmentsMap.get(pa.Assessment_Template__c).add( pa );
                }
                for (Main_questionaire__c template : templates) {
                    if (templateIdPublicAssessmentsMap.containsKey(template.Id)
                        && templateIdPublicAssessmentsMap.get(template.Id) != null
                        && templateIdPublicAssessmentsMap.get(template.Id).size() > 0
                    ) {
                        template.addError( 'One Time Assessment cannot be set as true since this template has existing public assessments below it' );
                    }
                }
            }
        }
    }
}