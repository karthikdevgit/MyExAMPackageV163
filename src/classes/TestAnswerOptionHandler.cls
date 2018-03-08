@isTest
public class TestAnswerOptionHandler {
    @testSetup static void methodName() {
        List<Main_questionaire__c> assTempList = new List<Main_questionaire__c>{
            new Main_questionaire__c(Template_name__c = 'testTemp1'),
                new Main_questionaire__c(Template_name__c = 'testTemp2')
                };
                    insert assTempList;
        List<Section_Template__c> secList = new List<Section_Template__c>{
            new Section_Template__c(Section_label__c = 'test sec1',Questionnaire_Section__c = assTempList[0].Id ),
                new Section_Template__c(Section_label__c = 'test sec2',Questionnaire_Section__c = assTempList[1].Id)
                };
                    insert secList;
        List<Question_Template__c> quesList = new List<Question_Template__c>{
            new Question_Template__c(Question_Label__c = 'test ques1',Section_Question__c = secList[0].Id),
                new Question_Template__c(Question_Label__c = 'test ques2',Section_Question__c = secList[0].Id),
                new Question_Template__c(Question_Label__c = 'test ques3',Section_Question__c = secList[0].Id),
                new Question_Template__c(Question_Label__c = 'test ques4',Section_Question__c = secList[1].Id),
                new Question_Template__c(Question_Label__c = 'test ques5',Section_Question__c = secList[1].Id),
                new Question_Template__c(Question_Label__c = 'test ques6',Section_Question__c = secList[1].Id)
                };
                    insert quesList;
        List<Answer_Option__c> ansOptList1= new List<Answer_Option__c>{
            new Answer_Option__c(Question_Template__c =quesList[0].Id,Order_No__c=1,
                                 Name = 'test1'),
                new Answer_Option__c(Question_Template__c =quesList[0].Id,Order_No__c=1,
                                     Name ='test2',Dependent_Question__c = quesList[1].Id),
                new Answer_Option__c(Question_Template__c =quesList[1].Id,Order_No__c=1,
                                     Name = 'test3',Next_Question__c = quesList[2].Id),
                new Answer_Option__c(Question_Template__c =quesList[1].Id,Order_No__c=1,
                                     Name = 'test1',Next_Question__c = quesList[1].Id)
                };
                    Test.startTest();
                    insert ansOptList1;
              Test.stopTest();
        List<Answer_Option__c> ansOptList2= new List<Answer_Option__c>{
            new Answer_Option__c(Question_Template__c =quesList[0].Id,Order_No__c=1,
                                 Name = 'test1'),
                new Answer_Option__c(Question_Template__c =quesList[0].Id,Order_No__c=1,
                                     Name ='test2',Dependent_Question__c = quesList[1].Id),
                new Answer_Option__c(Question_Template__c =quesList[1].Id,Order_No__c=1,
                                     Name = 'test3',Next_Question__c = quesList[2].Id)
                
                };
                    
                    insert ansOptList2;
        List<Answer_Option__c> ansOptList= new List<Answer_Option__c>{
            new Answer_Option__c(Question_Template__c =quesList[0].Id,Order_No__c=1,
                                 Name = 'test1',Dependent_Question__c = quesList[1].Id,Next_Question__c = quesList[1].Id)
                };
                    try{
                        insert ansOptList;
                    } catch (Exception e){
                        String ex= e.getMessage();
                        System.debug('mess1'+ex);
                        System.assert(ex.contains('Please provide either dependent question or Next Question for answer Option Record'));
                    }    
    }
    static testmethod void method1(){
        List<Question_Template__c> quesList = [SELECT Id FROM Question_Template__c LIMIT 20];
        List<Answer_Option__c> ansOptionlist =[SELECT Id, Name, Order_No__c, Dependent_Question__c, 
                                               Next_Question__c, Weight__c, Question_Template__c, Help_Text__c 
                                               FROM Answer_Option__c
                                               WHERE Question_Template__c =:quesList[0].Id];
        ansOptionlist[0].Dependent_Question__c = null;
        ansOptionlist[0].Next_Question__c = quesList[3].Id;
        try{
            update ansOptionlist;
        } catch (Exception e){
            String ex= e.getMessage();
            System.debug('mess2'+ex);    
            System.assert(ex.contains('Please provide same template\'s next question for Answer Option Record:'));
        }   
        List<Answer_Option__c> ansOptionlist1=[SELECT Id, Name, Order_No__c, Dependent_Question__c, 
                                               Next_Question__c, Weight__c, Question_Template__c, Help_Text__c 
                                               FROM Answer_Option__c
                                               WHERE Question_Template__c =:quesList[0].Id];
        ansOptionlist1[0].Dependent_Question__c = quesList[3].Id;
        try{
            update ansOptionlist1;
        } catch (Exception e){
            String ex= e.getMessage();
            System.debug('mess3'+ex);    
            System.assert(ex.contains('Please provide same template\'s dependent question for Answer Option Record:'));
        }   
        List<Answer_Option__c> ansOptionlist2=[SELECT Id, Name, Order_No__c, Dependent_Question__c, 
                                               Next_Question__c, Weight__c, Question_Template__c, Help_Text__c 
                                               FROM Answer_Option__c
                                               WHERE Question_Template__c =:quesList[0].Id];
        ansOptionlist2[0].Dependent_Question__c = quesList[3].Id;
        ansOptionlist2[0].Next_Question__c = quesList[3].Id;
        try{
            update ansOptionlist2;
        } catch (Exception e){
            String ex= e.getMessage();
            System.debug('mess4'+ex);    
            System.assert(ex.contains('Please provide either dependent question or Next Question for Answer Option Record:'));
        } 
    }
}