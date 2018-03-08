public with sharing class Exam {
    //AssessmentWrapper class
    public class AssessmentWrapper{
        public Main_questionaire__c assessmentRecord;
        public List<SectionWrapper> sections;
        
        //clone Assessment
        public  Main_questionaire__c cloneAssessment(){
            assessmentRecord = assessmentRecord.clone(false,true,false,false);
            return assessmentRecord;
        }
        
        // constructor  for AssessmentWrapper class
        public AssessmentWrapper(Main_questionaire__c assessment, Map<Id,List<Section_Template__c>> assessmentIdWthSections, Map<Id,List<Question_Template__c>> sectionIdWthQuestions, Map<Id,List<Answer_Option__c>> questionIdWthAnswers){
            this.assessmentRecord = assessment;            
            List<SectionWrapper> sectionWrapperList = new List<SectionWrapper>();
            
            if(assessmentIdWthSections.containsKey(assessment.Id)){
                for(Section_Template__c section : assessmentIdWthSections.get(assessment.Id)){
                    sectionWrapperList.add(new Exam.SectionWrapper(section,sectionIdWthQuestions,questionIdWthAnswers));
                }
                this.sections = sectionWrapperList;
            }
            
        }
    }
    
    //SectionWrapper class
    public class SectionWrapper{
        public Section_Template__c sectionRecord;
        public List<QuestionWrapper> questions;
        
        // cloneSection
        public Section_Template__c cloneSection(Exam.AssessmentWrapper assessment){
            sectionRecord = sectionRecord.clone(false,true,false,false);
            sectionRecord.Questionnaire_Section__c = assessment.assessmentRecord.Id;
            return sectionRecord;
        }
        
        // constructor for SectionWrapper class
        public SectionWrapper(Section_Template__c section, Map<Id,List<Question_Template__c>> sectionIdWthQuestions, Map<Id,List<Answer_Option__c>> questionIdWthAnswers){
            this.sectionRecord = section;
            List<QuestionWrapper> questionWrapperList = new List<QuestionWrapper>();
            
            if(sectionIdWthQuestions.containsKey(section.Id)){
                for(Question_Template__c question : sectionIdWthQuestions.get(section.Id)){
                    questionWrapperList.add(new Exam.QuestionWrapper(question,questionIdWthAnswers));
                }
                this.questions = questionWrapperList;
            }
            
        }
    }
    
    // QuestionWrapper class
    public class QuestionWrapper{
        public Question_Template__c questionRecord;
        public List<AnswerOptionsWrapper> answerOptions;
        
        // CloneQuestion
        public Question_Template__c cloneQuestion(Exam.SectionWrapper section){
            questionRecord = questionRecord.clone(false,true,false,false);
            questionRecord.Section_Question__c = section.sectionRecord.Id;
            return questionRecord;
        }
        
        // constructor for QuestionWrapper class
        public QuestionWrapper(Question_Template__c question, Map<Id,List<Answer_Option__c>> questionIdWthAnswers){
            this.questionRecord = question;
            List<AnswerOptionsWrapper> answerOptionsWrapperList = new List<AnswerOptionsWrapper>();
            
            if(questionIdWthAnswers.containsKey(question.Id)){
                for(Answer_Option__c answer : questionIdWthAnswers.get(question.Id)){
                    answerOptionsWrapperList.add(new Exam.AnswerOptionsWrapper(answer));
                }
                this.answerOptions = answerOptionsWrapperList;
            }  
            
        }
    }
    
    // AnswerOptionsWrapper class
    public class AnswerOptionsWrapper{
        public Answer_Option__c answerOptionRecord;
        
        // clone AnswerOption
        public Answer_Option__c cloneAnswerOption(Exam.QuestionWrapper question,Id nextQuestion, Id dependentQuestion){
            answerOptionRecord = answerOptionRecord.clone(false,true,false,false);
            answerOptionRecord.Question_Template__c = question.questionRecord.Id;
            if(nextQuestion != null){
                answerOptionRecord.Next_Question__c = nextQuestion;
            }else if(dependentQuestion != null){
                answerOptionRecord.Dependent_Question__c = dependentQuestion;
            }
            return answerOptionRecord;
        }
        
        //Constructor for AnswerOptionsWrapper class
        public AnswerOptionsWrapper(Answer_Option__c answerOption){
            this.answerOptionRecord = answerOption;
            
        }
    }
}