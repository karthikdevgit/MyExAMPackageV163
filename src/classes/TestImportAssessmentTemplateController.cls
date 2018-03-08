@isTest 
public class TestImportAssessmentTemplateController {

    static testMethod void method1() {
       
        Test.startTest();
        Main_questionaire__c[] templateList = new Main_questionaire__c[] {
            new Main_questionaire__c(Template_name__c = 'General Safety',Context_Questions_Mapping__c='Q-4~ExAM__Answer_Text__c:Q-0~ExAM__Comment__c'),
            new Main_questionaire__c(Template_name__c = 'Fire Safety'),
            new Main_questionaire__c(Template_name__c = 'Accident Safety'),
            new Main_questionaire__c(Template_name__c = 'General Instructions')
        };
        List<String> oldTempIdList = new List<String> {'id1','id2','id3','id4'};
        List<String> oldSecIdList = new List<String> {'id1','id2','id3','id4'};
        List<String> oldQusIdList = new List<String> {'Q-1','Q-2','Q-3','Q-4','Q-5','Q-6','Q-7'};
        List<String>oldAnsOptIdList = new List<String> {'Ans- opt1','Ans- opt2','Ans- opt3' };
        Map<String, String> responseTemplateInsert = ImportAssessmentTemplateController.saveAssessmentTemplate(templateList, oldTempIdList);
        //insert templateList;
        if (responseTemplateInsert != null && responseTemplateInsert.size() > 0) {
            List<Section_Template__c> secTemp = new List<Section_Template__c> {
                    new Section_Template__c(Section_label__c = 'Section1',Questionnaire_Section__c = responseTemplateInsert.get('id1')),
                    new Section_Template__c(Section_label__c = 'Section2',Questionnaire_Section__c = responseTemplateInsert.get('id1')),
                    new Section_Template__c(Section_label__c = 'Section3',Questionnaire_Section__c = responseTemplateInsert.get('id1')),
                    new Section_Template__c(Section_label__c = 'Section4',Questionnaire_Section__c = responseTemplateInsert.get('id1'))
            };
            Map<String, String> responseSec = ImportAssessmentTemplateController.saveSectionTemplate(secTemp,oldSecIdList);
            
            if (responseSec != null && responseSec.size() > 0) {

                List<Question_Template__c> quesTemp = new List<Question_Template__c> {
                    new Question_Template__c(Question_Label__c = 'question1', Next_Question__c = 'Q-1', Section_Question__c = responseSec.get('id1'), Question_Type__c = 'RadioPicklist'),
                    new Question_Template__c(Question_Label__c = 'question2', Next_Question__c = 'Q-2~Q-3', Section_Question__c = responseSec.get('id1')),
                    new Question_Template__c(Question_Label__c = 'question3', Section_Question__c = responseSec.get('id1')),
                    new Question_Template__c(Question_Label__c = 'question4', Section_Question__c = responseSec.get('id1')),
                    new Question_Template__c(Question_Label__c = 'question5', Dependent_Question__c = 'Q-5~Q-6', Section_Question__c = responseSec.get('id1')),
                    new Question_Template__c(Question_Label__c = 'question6', Section_Question__c = responseSec.get('id1')),
                    new Question_Template__c(Question_Label__c = 'question7', Section_Question__c = responseSec.get('id1'))
                };
                Map<String, Map<String, String>> responseQuestion = ImportAssessmentTemplateController.saveQuestionTemplate(quesTemp,oldQusIdList);
                System.assertEquals(null,responseQuestion.get('error'));
                if (responseQuestion != null && responseQuestion.size() > 0) {
                    if (!responseQuestion.containsKey('error')) {

                        String responseDecisionTreepopulate = ImportAssessmentTemplateController.decisionTreeQuestionUpdate(responseTemplateInsert.values(), responseQuestion.get('newQuesNameMap'), responseQuestion.get('newQuesIdMap'));
                        system.assertEquals('success',responseDecisionTreepopulate);

                        List<String> oldTempValue = new List<String>();
                        oldTempValue.addAll(responseTemplateInsert.keySet());
                        String responseDependentQues = ImportAssessmentTemplateController.contextQuestionMapFieldsUpdate(oldTempValue, responseQuestion.get('newQuesNameMap'), responseTemplateInsert);
                        system.assertEquals('success',responseDependentQues);
                        
                        List<Answer_Option__c> ansoptions1 = new List<Answer_Option__c> {
                            new Answer_Option__c(Question_Template__c = quesTemp[0].Id, Order_No__c = 1, Name = 'optA', Weight__c = 50), 
                            new Answer_Option__c(Question_Template__c = quesTemp[0].Id, Order_No__c = 2, Name = 'optB', Weight__c = 50), 
                            new Answer_Option__c(Question_Template__c = quesTemp[0].Id, Order_No__c = 3, Name = 'optC', Weight__c = 50)
                        };    
                        Map<string, string> ansOptMap = ImportAssessmentTemplateController.saveAnswerOptions(ansoptions1 ,oldAnsOptIdList);
                        System.assert(ansOptMap != Null);
                    }
                }
            }
            ImportAssessmentTemplateController.deleteTemplate(responseTemplateInsert);
        }
           
        Test.stopTest();
        
    }
}