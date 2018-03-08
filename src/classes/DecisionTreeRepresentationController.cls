public with sharing class DecisionTreeRepresentationController {

    JSONGenerator gen;

    public string tempId { get; set; }
    public string jsonData { get; set; }
    public string nameMapJsonStr { get; set; }
    public string labelMapJsonStr { get; set; }
    public string sectionTemplateIdAndQuestionTemplatesMapStr { get; set; }
    public string sectionIdAndQTPaginationMapStr { get; set; }
    public string tempSTMap { get; set; }
    public string tempQTMap { get; set; }
    public String questionTypes { get; set; }

    public Boolean isFirstRun;

    public Integer totalCount;
    public Integer levelMaxLimit;

    public List<ExAM__Question_Template__c> decisionTreeQuestionsList;
    public List<ExAM__Question_Template__c> primaryQuestionsList;

    public Set<String> questionTypeNameSet;

    public Map<String, String> templateIdAndNameMap;
    public Map<String, String> templateIdAndLabelMap;
    public Map<Id, List<ExAM__Question_Template__c>> sectionTemplateIdAndQuestionTemplatesMap;
    public Map<String, Set<Id>> sTPaginationMap;
    public Map<String, Set<Id>> qTPaginationMap;
    public Map<Id, Map<String, Set<Id>>> sectionIdAndQTPaginationMap;
    public Map<Integer, Integer> paginationRangeAndTotalmap;

    public class ResponseClass {
        public string status { get; set; }
        public string response { get; set; }
        public ResponseClass(String statusStr, String responseStr) {
            this.status = statusStr;
            this.response = responseStr;
        }
    }

    public DecisionTreeRepresentationController() {

        jsonData = '';
        tempId = '';
        nameMapJsonStr = '';
        labelMapJsonStr = '';
        sectionTemplateIdAndQuestionTemplatesMapStr = '';
        sectionIdAndQTPaginationMapStr = '';
        tempSTMap = '';
        tempQTMap = '';

        isFirstRun = true;

        totalCount = 0;
        levelMaxLimit = 25;

        decisionTreeQuestionsList = new List<ExAM__Question_Template__c>();
        primaryQuestionsList = new List<ExAM__Question_Template__c>();

        questionTypeNameSet = new Set<String>();

        templateIdAndNameMap = new Map<String, String>();
        templateIdAndLabelMap = new Map<String, String>();
        sectionTemplateIdAndQuestionTemplatesMap = new Map<Id, List<ExAM__Question_Template__c>>();
        sTPaginationMap = new Map<String, Set<Id>>();
        qTPaginationMap = new Map<String, Set<Id>>();
        sectionIdAndQTPaginationMap = new Map<Id, Map<String, Set<Id>>>();
        paginationRangeAndTotalmap = new Map<Integer, Integer>();

        tempId = ApexPages.CurrentPage().getParameters().get('tempId');

        if (string.isNotBlank(tempId) && tempId != 'null') {
            gen = JSON.createGenerator(true);
            getDecisionTreeQuestions();
        }
        else {
            jsonData = JSON.serialize( new ResponseClass('ERROR', 'Assessment Template Id not defined') );
        }
        List<String> questionTypesList = new List<String>();
        
        Schema.DescribeFieldResult fieldResult = Question_Template__c.Question_Type__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            
        for( Schema.PicklistEntry f : ple) {
            if( f.getLabel() != 'Assessment Completed' && f.getLabel() != 'Likert' ){
                questionTypesList.add(f.getLabel());
            }
        }
        questionTypes = JSON.serialize(questionTypesList);
    }

    public string getDecisionTreeQuestions() {

        try {

            List<ExAM__Main_questionaire__c> assessmentTemplatesList = new List<ExAM__Main_questionaire__c>();
            SFDCAccessController accessForobj = ExAMUtilClass.AccessController;
            List<String> fieldsList = new List<String>{'ExAM__Template_Name__c'};
            accessForobj.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Main_questionaire__c'), fieldsList);
            assessmentTemplatesList = [SELECT Id, Name, ExAM__Template_Name__c FROM ExAM__Main_questionaire__c WHERE Id = :tempId LIMIT 1];

            if (assessmentTemplatesList != null && assessmentTemplatesList.size() > 0) {

                ExAM__Main_questionaire__c assessmentTemplate = assessmentTemplatesList[0];

                templateIdAndNameMap.put(assessmentTemplate.Id, assessmentTemplate.Name);
                templateIdAndLabelMap.put(assessmentTemplate.Id, assessmentTemplate.ExAM__Template_Name__c);

                string mainQuestionName = assessmentTemplatesList[0].Name;
                mainQuestionName += '@@'+assessmentTemplatesList[0].ExAM__Template_Name__c;
                mainQuestionName += '@@'+assessmentTemplatesList[0].Id;
                mainQuestionName += '@@false';

                //Iteration start for parent node
                gen.writeStartObject();
                gen.writeStringField('name', mainQuestionName);
                gen.writeStringField('modalWindowText', assessmentTemplatesList[0].ExAM__Template_Name__c);
                gen.writeNumberField('value', assessmentTemplatesList[0].ExAM__Template_Name__c.length());
                gen.writeStringField('color', 'black');
                gen.writeBooleanField('HasNextQuestion', false);
                gen.writeFieldName('children');

                List<ExAM__Section_Template__c> sectionTemplatesList = new List<ExAM__Section_Template__c>();
                Set<Id> sectionTemplateIdSet = new Set<Id>();
                
                List<String> fieldsList1 = new List<String>{'ExAM__Questionnaire_Section__c','ExAM__Section_label__c'};
                accessForobj.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Section_Template__c'), fieldsList1);

                for(ExAM__Section_Template__c st : [SELECT   Id, Name, ExAM__Questionnaire_Section__c, ExAM__Section_label__c
                                              FROM     ExAM__Section_Template__c
                                              WHERE    ExAM__Questionnaire_Section__c = :tempId
                                              ORDER BY Name ASC]) {

                    sectionTemplateIdSet.add( st.Id );
                    sectionTemplatesList.add( st );
                    templateIdAndNameMap.put(st.Id, st.Name);
                    templateIdAndLabelMap.put(st.Id, st.ExAM__Section_label__c);
                }

                if (sectionTemplatesList != null && sectionTemplatesList.size() > 0 && sectionTemplateIdSet != null && sectionTemplateIdSet.size() > 0) {

                    preparePaginationMap(sectionTemplatesList, 'Section Templates');
                    
                    List<String> fieldsList2 = new List<String>{'ExAM__Decision_Tree__c','ExAM__Next_Question__c', 'ExAM__Question_Label__c','ExAM__Question_Type__c','ExAM__Section_Question__c','ExAM__Subquestion_Label__c'};
                    accessForobj.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Question_Template__c'), fieldsList2);
                    
                    List<String> fieldsList3 = new List<String>{'ExAM__Help_Text__c','ExAM__Weight__c','ExAM__Dependent_Question__c','ExAM__Next_Question__c'};
                    accessForobj.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Answer_Option__c'), fieldsList3);
                    decisionTreeQuestionsList = [
                        SELECT CreatedDate, ExAM__Decision_Tree__c, Id, Name, ExAM__Next_Question__c, ExAM__Question_Label__c,
                               ExAM__Question_Type__c, ExAM__Section_Question__c, ExAM__Section_Question__r.Name, ExAM__Subquestion_Label__c,
                               ExAM__Single_Next_Question__c, ExAM__Single_Next_Question__r.Name,
                               (SELECT Id,Name,Help_Text__c,Weight__c,Dependent_Question__r.Name,Next_Question__r.Name FROM Answer_Options__r)
                        FROM   ExAM__Question_Template__c
                        WHERE  ExAM__Section_Question__c IN :sectionTemplateIdSet
                        ORDER BY CreatedDate ASC
                    ];
                    
                    Set<Id> quesTempIdSet = new Set<Id>();
                    if (decisionTreeQuestionsList != null && decisionTreeQuestionsList.size() > 0) {

                        for (ExAM__Question_Template__c qt : decisionTreeQuestionsList) {

                            List<String> nextQuestionsList = new List<String>();

                            //Prepare Next Questions List
                            if ( string.isNotBlank(qt.ExAM__Next_Question__c) ) {
                                nextQuestionsList = qt.ExAM__Next_Question__c.split('~');
                            }
                            if ( qt.Answer_Options__r.size() > 0 ){
                                for( Answer_Option__c ansOpt :qt.Answer_Options__r ){
                                    if( ansOpt.Next_Question__r.Name != null && ansOpt.Next_Question__r.Name != '' ){
                                        nextQuestionsList.add(ansOpt.Next_Question__r.Name);
                                        
                                    }
                                }
                            }
                            if ( qt.Single_Next_Question__c != null && qt.Single_Next_Question__r.Name != null ){
                                nextQuestionsList.add(qt.Single_Next_Question__r.Name);
                            }
                            questionTypeNameSet.addAll( nextQuestionsList );
                            quesTempIdSet.add(qt.Id);
                            templateIdAndNameMap.put(qt.Id, qt.Name);
                            templateIdAndLabelMap.put(qt.Id, qt.ExAM__Question_Label__c);
                        }

                        primaryQuestionsList = [
                            SELECT  CreatedDate, Id, Name, ExAM__Next_Question__c, ExAM__Section_Question__c,
                                    ExAM__Single_Next_Question__c, ExAM__Single_Next_Question__r.Name
                            FROM    ExAM__Question_Template__c
                            WHERE   ((ExAM__Section_Question__c IN :sectionTemplateIdSet)
                                     AND (Name NOT IN :questionTypeNameSet)
                            )
                            ORDER BY CreatedDate ASC
                        ];

                        for (ExAM__Question_Template__c qt : primaryQuestionsList) {

                            if (!sectionTemplateIdAndQuestionTemplatesMap.containsKey(qt.ExAM__Section_Question__c) ) {
                                sectionTemplateIdAndQuestionTemplatesMap.put(qt.ExAM__Section_Question__c, new List<ExAM__Question_Template__c>());
                            }
                            quesTempIdSet.add(qt.Id);
                            sectionTemplateIdAndQuestionTemplatesMap.get(qt.ExAM__Section_Question__c).add( qt );
                        }
                        for( Answer_Option__c ansOpt :[SELECT Id,Name,Help_Text__c,Weight__c,Dependent_Question__c,Next_Question__c FROM Answer_Option__c WHERE Question_Template__c IN :quesTempIdSet ] ){
                            templateIdAndNameMap.put(ansOpt.Id,ansOpt.Name);
                            
                        }
                        if (sectionTemplateIdAndQuestionTemplatesMap != null && sectionTemplateIdAndQuestionTemplatesMap.size() > 0) {
                            for (Id sectionId : sectionTemplateIdAndQuestionTemplatesMap.keySet()) {
                                qTPaginationMap = new Map<String, Set<Id>>();
                                List<ExAM__Question_Template__c> qtList = new List<ExAM__Question_Template__c>();
                                qtList = sectionTemplateIdAndQuestionTemplatesMap.get(sectionId);
                                if (qtList != null && qtList.size() > 0) {
                                    preparePaginationMap(qtList, 'Question Templates');
                                    sectionIdAndQTPaginationMap.put(sectionId, qTPaginationMap);
                                }
                            }
                        }
                    }

                    if (sectionTemplateIdSet.size() <= 25) {
                        prepareSectionTemplates(gen, sectionTemplateIdSet);
                    }
                    else {
                        gen.writeStartArray();
                        preparePaginationNodes(null, sectionTemplateIdSet.size(), 0, true, new Map<Integer, Integer>(), gen, 'Section Templates');
                        gen.writeEndArray();
                    }
                    if ( !stPaginationMap.isEmpty() ) {
                        tempSTMap = Json.serialize(stPaginationMap);
                    }
                    if ( !qtPaginationMap.isEmpty() ) {
                        tempQTMap = Json.serialize(qtPaginationMap);
                    }
                    if ( !sectionTemplateIdAndQuestionTemplatesMap.isEmpty() ) {
                        sectionTemplateIdAndQuestionTemplatesMapStr = Json.serialize(sectionTemplateIdAndQuestionTemplatesMap);
                    }
                    if ( !sectionIdAndQTPaginationMap.isEmpty() ) {
                        sectionIdAndQTPaginationMapStr = Json.serialize(sectionIdAndQTPaginationMap);
                    }

                }
                else {
                    gen.writeStartArray();
                    gen.writeEndArray();
                }
                if ( !templateIdAndNameMap.isEmpty() ) {        
                    nameMapJsonStr = Json.serialize( templateIdAndNameMap );        
                }       
                if ( !templateIdAndLabelMap.isEmpty() ) {       
                    labelMapJsonStr = Json.serialize( templateIdAndLabelMap );      
                }

                //Iteration end for parent node
                gen.writeEndObject();
                jsonData = gen.getAsString();
            }
            else {
                jsonData = JSON.serialize( new ResponseClass('ERROR', 'No Records Exists') );
            }
        }
        catch(Exception exp) {

            String errMsg = exp.getLineNumber() + ' - ' + exp.getMessage();
            errMsg += '\n';
            errMsg += exp.getStackTraceString();

            jsonData = JSON.serialize( new ResponseClass('ERROR', errMsg) );
        }
        return jsonData;
    }

    public static JSONGenerator prepareSectionTemplates(JSONGenerator gen, Set<Id> sectionIdSet) {

        gen.writeStartArray();
        
        if (sectionIdSet.size() > 0) {
            
            SFDCAccessController accessForobj = ExAMUtilClass.AccessController;
            List<String> fieldsList = new List<String>{'ExAM__Questionnaire_Section__c','ExAM__Section_label__c'};
            accessForobj.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Section_Template__c'), fieldsList);
            List<String> fieldsList1 = new List<String>{'ExAM__Template_name__c'};
            accessForobj.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Main_questionaire__c'), fieldsList1);
            for (ExAM__Section_Template__c st : [SELECT Id, Name, ExAM__Questionnaire_Section__c, ExAM__Questionnaire_Section__r.Name,
                                                        ExAM__Questionnaire_Section__r.Template_Name__c, ExAM__Section_label__c
                                                FROM    ExAM__Section_Template__c
                                                WHERE   Id IN :sectionIdSet ORDER BY Name ASC]) {

                string sectionName = st.Name;
                sectionName += '@@'+st.ExAM__Section_Label__c;
                sectionName += '@@'+st.Id;
                sectionName += '@@false';

                //Each Section Template Iteration start
                gen.writeStartObject();

                gen.writeStringField('name', sectionName);
                gen.writeStringField('modalWindowText', st.ExAM__Section_Label__c);
                gen.writeNumberField('value', st.ExAM__Section_Label__c.length());
                gen.writeStringField('color', 'black');
                gen.writeBooleanField('HasNextQuestion', false);
                gen.writeFieldName('children');

                //Array Iteration start for all primary questions against this section question
                gen.writeStartArray();

                gen.writeEndArray();
                //Array Iteration end for all primary questions against this section question
                gen.writeEndObject();
                //Each Section Template Iteration end
            } //end for loop iteration for Section Templates
        }
        gen.writeEndArray();
        
        return gen;
    }

    public static string prepareQuestionTemplates(Set<Id> qtnIdSet) {

        string nextQuestionsJson = '';
        JSONGenerator new_gen = JSON.createGenerator(true);
        
        
        if (qtnIdSet.size() > 0) {

            new_gen.writeStartArray();
            SFDCAccessController accessForobj = ExAMUtilClass.AccessController;
            List<String> fieldsList = new List<String>{'ExAM__Next_Question__c', 'ExAM__Question_Label__c','ExAM__Question_Type__c','ExAM__Section_Question__c','ExAM__Subquestion_Label__c'};
            accessForobj.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Question_Template__c'), fieldsList);

            for (ExAM__Question_Template__c qt : [SELECT   CreatedDate, Id, Name, ExAM__Next_Question__c, ExAM__Question_Label__c, ExAM__Question_Type__c, 
                                            ExAM__Section_Question__c, ExAM__Section_Question__r.Name, ExAM__Subquestion_Label__c, ExAM__Single_Next_Question__c, ExAM__Single_Next_Question__r.Name
                                            FROM     ExAM__Question_Template__c
                                            WHERE    Id IN :qtnIdSet
                                            ORDER BY CreatedDate ASC]) {
    
                string qtnName = qt.Name;
                qtnName += '@@'+qt.ExAM__Question_Label__c;
                qtnName += '@@'+qt.Id;
                qtnName += '@@false';
    
                //Each Primary Question Template Iteration start
                new_gen.writeStartObject();
    
                new_gen.writeStringField('name', qtnName);
                new_gen.writeStringField('modalWindowText', qt.ExAM__Question_Label__c);
                new_gen.writeNumberField('value', qt.ExAM__Question_Label__c.length());
                new_gen.writeStringField('color', 'black');
                if( qt.Single_Next_Question__c == null ){
                    new_gen.writeBooleanField('HasNextQuestion', false);
                } else {
                    new_gen.writeBooleanField('HasNextQuestion', true);
                }
                new_gen.writeStringField('calledFromQtnId', qt.Id);
                new_gen.writeStringField('sectionId', qt.ExAM__Section_Question__c);
                new_gen.writeStringField('sectionName', qt.ExAM__Section_Question__r.Name);
                new_gen.writeFieldName('children');
    
                //Array Iteration start for all answer below each primary questions
                new_gen.writeStartArray();
    
                new_gen.writeEndArray();
                //Array Iteration end for all answer below each primary questions
    
                new_gen.writeEndObject();
                //Each Primary Question Template Iteration end
            } //end for loop iteration for Question Templates

            new_gen.writeEndArray();

            nextQuestionsJson = new_gen.getAsString();
        }
        
        return nextQuestionsJson;
    }

    public static JSONGenerator prepareAnswerOption(Id qtnTemplateId, JSONGenerator new_gen) {

        List<String> ansOptionsList = new List<String>();
        List<String> nxtQtnsList = new List<String>();
        Map<String, ExAM__Question_Template__c> questionNameRecordMap = new Map<String, ExAM__Question_Template__c>();
        Id singleNextQuesId;
        if (qtnTemplateId != null) {
            
            SFDCAccessController accessForobj = ExAMUtilClass.AccessController;
            List<String> fieldsList = new List<String>{'ExAM__Next_Question__c', 'ExAM__Question_Label__c','ExAM__Question_Type__c','ExAM__Section_Question__c','ExAM__Subquestion_Label__c'};
            accessForobj.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Question_Template__c'), fieldsList);
            
            List<String> fieldsList3 = new List<String>{'ExAM__Help_Text__c','ExAM__Weight__c','ExAM__Dependent_Question__c','ExAM__Next_Question__c'};
            accessForobj.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Answer_Option__c'), fieldsList3);
            for(ExAM__Question_Template__c qt : [SELECT CreatedDate, ExAM__Decision_Tree__c, Id, Name, ExAM__Next_Question__c, ExAM__Question_Label__c, ExAM__Question_Type__c, ExAM__Section_Question__c,
                                                  ExAM__Section_Question__r.Name, ExAM__Subquestion_Label__c, ExAM__Single_Next_Question__c, ExAM__Single_Next_Question__r.Name,
                                                  (SELECT Id,Name,Help_Text__c,Weight__c,Dependent_Question__r.Name,Next_Question__r.Name FROM Answer_Options__r ORDER BY Order_No__c ASC)
                                           FROM   ExAM__Question_Template__c
                                           WHERE  Id = :qtnTemplateId LIMIT 1]) {

                //Prepare Available Answer Options List
                if (string.isNotBlank(qt.ExAM__Subquestion_Label__c) && qt.Answer_Options__r.size() == 0 ) {
                    ansOptionsList = qt.ExAM__Subquestion_Label__c.split('~');
                } else {
                    for( Answer_Option__c ansOpt :qt.Answer_Options__r ){
                        ansOptionsList.add(ansOpt.Name+'~'+ansOpt.Id);
                    } 
                }
                //Prepare Next Question List
                if( qt.Single_Next_Question__c == null ){
                    if (string.isNotBlank(qt.ExAM__Next_Question__c) && qt.Answer_Options__r.size() == 0 ) {
                        nxtQtnsList = qt.ExAM__Next_Question__c.split('~');
                    } else {
                        for( Answer_Option__c ansOpt :qt.Answer_Options__r ){
                            if( ansOpt.Next_Question__r.Name == null ){
                                nxtQtnsList.add(null);
                            } else {
                                nxtQtnsList.add(ansOpt.Next_Question__r.Name);
                            }
                        } 
                    }
                } else {
                    singleNextQuesId = qt.Single_Next_Question__c;
                    nxtQtnsList.add(qt.Single_Next_Question__r.Name);
                }
                questionNameRecordMap.put(qt.Id, qt);
            }
            if( ansOptionsList != null && ansOptionsList.size() > 0 && singleNextQuesId == null ){
                for (Integer thisPosition = 0; thisPosition < ansOptionsList.size(); thisPosition++) {
    
                    String ansOptn =  ansOptionsList[thisPosition];
                    String answerOption = ansOptn+'@@'+ansOptn+'@@'+ansOptn+'@@true';
                    List<String> ansOptWithIdList = new List<String>();
                    
                    //added om 04-05-2017,
                    if ( !ansOptn.contains('~') ){
                        answerOption = ansOptn+'@@'+ansOptn+'@@'+ansOptn+'@@true';
                    } else {
                        ansOptWithIdList = ansOptn.split('~');
                        answerOption = ansOptWithIdList[0]+'@@'+ansOptWithIdList[0]+'@@'+ansOptWithIdList[1]+'@@true';
                    }
                    
                    if ( String.isNotBlank(answerOption) ) {
                        //Iteration start for each answer option below primary question
                        new_gen.writeStartObject();
                        new_gen.writeStringField('name', answerOption);
                        //added om 04-05-2017, for update created question template as a next question for answer option record 
                        if ( ansOptn.contains('~') ){
                            new_gen.writeStringField('modalWindowText', ansOptWithIdList[0]);
                            new_gen.writeNumberField('value', ansOptWithIdList[0].length());
                        } else {
                            new_gen.writeStringField('modalWindowText', ansOptn);
                            new_gen.writeNumberField('value', ansOptn.length());
                        }
                        new_gen.writeStringField('color', 'black');
                        new_gen.writeBooleanField('HasNextQuestion', ((nxtQtnsList != null && nxtQtnsList.size() > 0) && (thisPosition < nxtQtnsList.size()) && (string.isNotBlank(nxtQtnsList[thisPosition]))) ? true : false);
                        if ( ansOptn.contains('~') ){
                            new_gen.writeStringField('calledFromQtnId', ansOptWithIdList[1]);
                        } else {
                            new_gen.writeStringField('calledFromQtnId', qtnTemplateId);
                        }
                        new_gen.writeStringField('sectionId', questionNameRecordMap.get(qtnTemplateId).ExAM__Section_Question__c);
                        new_gen.writeStringField('sectionName', questionNameRecordMap.get(qtnTemplateId).ExAM__Section_Question__r.Name);
                        new_gen.writeNumberField('answerPosition', thisPosition);
                        new_gen.writeFieldName('children');
                        new_gen.writeStartArray();
                        new_gen.writeEndArray();
                        new_gen.writeEndObject();
                    }
                }//end answer options iteration
            } else if( singleNextQuesId != null ) {
                //prepare question templates from single next question click.
                Set<Id> qtnIdSet = new Set<Id>();
                qtnIdSet.add(singleNextQuesId);
                String jsonStr = prepareQuestionTemplates(qtnIdSet);
                System.debug('JsonStr ::single next question ::'+jsonStr);
                List<JsonGeneratorClass> jsonStrMapList = (List<JsonGeneratorClass>)JSON.deserialize(jsonStr,List<JsonGeneratorClass>.class);
                new_gen.writeObject(jsonStrMapList[0]);
            }
        }
        
        return new_gen;
    }

    public static JSONGenerator prepareNextQtn(Id qtnTemplateId, Integer thisPosition, JSONGenerator new_gen) {
        Id ansOptId;
        List<String> nxtQtnsList = new List<String>();
        Set<String> dupSet = new Set<String>();
        Map<String, String> qtnIdDefaultValuesMap = new Map<String, String>();
        Map<String, ExAM__Question_Template__c> questionNameRecordMap = new Map<String, ExAM__Question_Template__c>();
        Map<String, String> fieldApiNameLabelMap = new Map<String, String>();
       
        if (qtnTemplateId != null) {
            
            String sObjName = qtnTemplateId.getSObjectType().getDescribe().getName();
            SFDCAccessController accessForobj = ExAMUtilClass.AccessController;
            List<String> fieldsList = new List<String>{'ExAM__Question_Template__c'};
            accessForobj.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Answer_Option__c'), fieldsList);
            if ( sObjName == 'ExAM__Answer_Option__c' ){
                ansOptId = qtnTemplateId;
                for( Answer_Option__c ansOpt :[SELECT Id,Question_Template__c FROM Answer_Option__c WHERE Id = :ansOptId] ){
                    qtnTemplateId = ansOpt.Question_Template__c;
                }
            }
            
            List<Schema.SObjectField> sObjFields = ExAM__Questionnaire_Response__c.sObjectType.getDescribe().fields.getMap().Values();
            for (Schema.SObjectField sObjField : sObjFields) {
                Schema.DescribeFieldResult dfr = sObjField.getDescribe();
                fieldApiNameLabelMap.put(dfr.getName().toUpperCase(), dfr.getLabel());
            }
            
            List<String> fieldsList1 = new List<String>{'ExAM__Decision_Tree__c','ExAM__Next_Question__c','ExAM__Question_Label__c','ExAM__Question_Type__c','ExAM__Section_Question__c','ExAM__Subquestion_Label__c'};
            accessForobj.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Question_Template__c'), fieldsList1);

            for(ExAM__Question_Template__c qt : [SELECT CreatedDate, ExAM__Decision_Tree__c, Id, Name, ExAM__Next_Question__c, ExAM__Question_Label__c,
                                                  ExAM__Question_Type__c, ExAM__Section_Question__c, ExAM__Section_Question__r.Name, ExAM__Subquestion_Label__c,
                                                  ExAM__Single_Next_Question__c, ExAM__Single_Next_Question__r.Name,
                                                  (SELECT Id,Name,Help_Text__c,Weight__c,Dependent_Question__r.Name,Next_Question__r.Name FROM Answer_Options__r)
                                           FROM   ExAM__Question_Template__c
                                           WHERE  Id = :qtnTemplateId LIMIT 1]) {

                //Prepare Next Questions List
                if( qt.Single_Next_Question__c == null ){
                    if (string.isNotBlank(qt.ExAM__Next_Question__c) && qt.Answer_Options__r.size() == 0 ) {
                        nxtQtnsList = qt.ExAM__Next_Question__c.split('~');
                    } else {
                        for( Answer_Option__c ansOpt :qt.Answer_Options__r ){
                            if( ansOpt.Next_Question__r.Name == null ){
                                nxtQtnsList.add(null);
                            } else {
                                nxtQtnsList.add(ansOpt.Next_Question__r.Name);
                            }
                        } 
                    }
                } else {
                    nxtQtnsList.add(qt.Single_Next_Question__r.Name);
                }
                questionNameRecordMap.put(qt.Id, qt);
            }
            //Permission for this checked above
            for(ExAM__Question_Template__c qt : [SELECT CreatedDate, ExAM__Decision_Tree__c, Id, Name, ExAM__Next_Question__c, ExAM__Question_Label__c,
                                                  ExAM__Question_Type__c, ExAM__Section_Question__c, ExAM__Section_Question__r.Name, ExAM__Subquestion_Label__c, 
                                                  ExAM__Single_Next_Question__c, ExAM__Single_Next_Question__r.Name
                                           FROM   ExAM__Question_Template__c
                                           WHERE  Name IN :nxtQtnsList]) {


                //Prepare configured Answer Field/Default Value List
                if ((qt.ExAM__Question_Type__c == 'Result') && string.isNotBlank(qt.ExAM__Decision_Tree__c) ) {

                    String qtnLabel = '';
                    List<String> defaultValuesList = new List<String>();
                    defaultValuesList = qt.ExAM__Decision_Tree__c.split('~');
                    qtnLabel = '<table>';
                    for (String eachKeyValue : defaultValuesList) {

                        string key = (eachKeyValue.split(':').size() > 0) ? eachKeyValue.split(':')[0] : '';
                        string value = (eachKeyValue.split(':').size() > 1) ? eachKeyValue.split(':')[1] : '';

                        if (string.isNotBlank(key) && string.isNotBlank(value) ) {

                            if (fieldApiNameLabelMap.containsKey( key.toUpperCase() ) ) {
                                qtnLabel += '<tr><td><b>' + fieldApiNameLabelMap.get( key.toUpperCase() ) + '</b>:</td><td>' + value + '</td></tr>';
                            }
                            else {
                                qtnLabel += '<tr><td><b>' + key + '</b>:</td><td>' + value + '</td></tr>';
                            }
                        }
                    }
                    qtnLabel += '</table>';
                    qtnIdDefaultValuesMap.put(qt.Id, qtnLabel);
                }
                questionNameRecordMap.put(qt.Name, qt);
            }

            if ((nxtQtnsList != null && nxtQtnsList.size() > 0) && (thisPosition < nxtQtnsList.size()) ) {

                String nxtQuestionName = nxtQtnsList[thisPosition];

                if (String.isNotBlank(nxtQuestionName) 
                    && (questionNameRecordMap.containsKey(nxtQuestionName) && questionNameRecordMap.get(nxtQuestionName) != null)
                ) {

                    ExAM__Question_Template__c nxtQuestion = new ExAM__Question_Template__c();
                    nxtQuestion = questionNameRecordMap.get(nxtQuestionName);

                    string qtnLabel = nxtQuestion.Name;
                    qtnLabel += '@@'+nxtQuestion.ExAM__Question_Label__c;
                    qtnLabel += '@@'+nxtQuestion.Id;
                    qtnLabel += '@@false';
                    string qtnLabel1 = nxtQuestion.ExAM__Question_Label__c;

                    if (!dupSet.contains(nxtQuestionName) || (nxtQuestion.ExAM__Question_Type__c == 'Result')) {

                        if (nxtQuestion.ExAM__Question_Type__c != 'Result') {
                            dupSet.add(nxtQuestionName);
                        }
                        else {
                            if (qtnIdDefaultValuesMap.containsKey(nxtQuestion.Id) ) {
                                qtnLabel += '@#@'+qtnIdDefaultValuesMap.get(nxtQuestion.Id);
                                qtnLabel1 += '@#@'+qtnIdDefaultValuesMap.get(nxtQuestion.Id);
                            }
                        }

                        new_gen.writeStartObject();
                        new_gen.writeStringField('name', qtnLabel);
                        new_gen.writeStringField('modalWindowText', qtnLabel1);
                        new_gen.writeNumberField('value', qtnLabel1.length());
                        new_gen.writeStringField('color', 'black');
                        new_gen.writeBooleanField('HasNextQuestion', false);
                        new_gen.writeStringField('calledFromQtnId', nxtQuestion.Id);
                        new_gen.writeStringField('sectionId', nxtQuestion.Section_Question__c);
                        new_gen.writeStringField('sectionName', nxtQuestion.Section_Question__r.Name);
                        new_gen.writeFieldName('children');
                        new_gen.writeStartArray();

                        new_gen.writeEndArray();
                        new_gen.writeEndObject();
                    }
                }
            }
            //end codn heck to ensure a question exists in thisPosition
        }
        
        return new_gen;
    }

    public void preparePaginationMap(List<SObject> sObjList, String forWhichEntity) {

        Integer listSize = sObjList.size();
        Integer strCount = 1;
        Integer endCount = (listSize <= 25) ? listSize : 25;
        Set<Id> sObjIdSet = new Set<Id>();

        for (Integer j=strCount; j<=endCount; j++) {
            if ((j-1) < listSize) {
                sObjIdSet.add( sObjList.get( (j-1) ).Id );
            }
            if ((j == endCount)) {
                String key = '['+strCount+'-'+endCount+']';
                if (forWhichEntity == 'Section Templates') {
                    sTPaginationMap.put(key, sObjIdSet);
                }
                else if (forWhichEntity == 'Question Templates') {
                    qTPaginationMap.put(key, sObjIdSet);
                }
                sObjIdSet = new Set<Id>();
                if (endCount < listSize) {
                    strCount = (endCount+1);
                    endCount = ((endCount+25) <= listSize) ? (endCount+25) : listSize;
                }
            }
        }
    }

    public static JSONGenerator preparePaginationNodes(Id templateId, Integer totalTemplates, Integer totalCount, Boolean isFirstRun, Map<Integer, Integer> paginationRangeAndTotalmap, JSONGenerator pagination_gen, String entity) {

        Integer counter, endPos, levelMaxLimit, maxValue, strPos;
        counter = 0;
        maxValue = 25;
        levelMaxLimit = 25;

        if (totalTemplates != null ) {
            if ((totalTemplates >= levelMaxLimit) && (totalTemplates <= (levelMaxLimit*10))) {
                maxValue = levelMaxLimit;
            }
            else if ((totalTemplates > (levelMaxLimit*10)) && (totalTemplates <= (levelMaxLimit*100))) {
                maxValue = levelMaxLimit*10;
            }
            else if ((totalTemplates > (levelMaxLimit*100)) && (totalTemplates <= (levelMaxLimit*1000))) {
                maxValue = levelMaxLimit*100;
            }
            else if ((totalTemplates > (levelMaxLimit*1000)) && (totalTemplates <= (levelMaxLimit*2000))) {
                maxValue = levelMaxLimit*1000;
            }
            if (totalTemplates > maxValue) {
                counter = totalTemplates/maxValue;
                if(Math.mod(totalTemplates, maxValue) > 0){
                    counter++;
                }
            }
            for(Integer i=1; i<=counter; i++) {

                if (isFirstRun) {
                    totalCount = totalTemplates;
                }
                if (paginationRangeAndTotalmap.containsKey(maxValue)) {
                    Integer previousValue = paginationRangeAndTotalmap.get(maxValue);
                    Integer newValue = (previousValue+maxValue);
                    Integer newValue_AfterCheck = (newValue < totalCount) ? newValue : totalCount;
                    paginationRangeAndTotalmap.put(maxValue, newValue_AfterCheck);
                }
                else {
                    paginationRangeAndTotalmap.put(maxValue, maxValue);
                }
                if (isFirstRun) {
                    isFirstRun = false;
                }
                String result = '';
                if (paginationRangeAndTotalmap.containsKey(maxValue)) {
                    if (paginationRangeAndTotalmap.get(maxValue) < totalCount) {
                        strPos = (paginationRangeAndTotalmap.get(maxValue)-maxValue)+1;
                    }
                    else {
                        Integer templatesRemaining = Math.mod(totalCount,maxValue);
                        strPos = (totalCount-templatesRemaining)+1;
                    }
                    endPos = paginationRangeAndTotalmap.get(maxValue);
                    result = '['+string.valueOf(strPos)+'-'+string.valueOf(endPos)+']';
                }

                pagination_gen.writeStartObject();
                pagination_gen.writeStringField('name', result+'@@'+result+'@@'+result+'@@true');
                pagination_gen.writeStringField('modalWindowText', result);
                pagination_gen.writeNumberField('value', result.length());
                pagination_gen.writeStringField('color', 'green');
                pagination_gen.writeStringField('entity', entity);
                /*
                    Setting HasNextQuestion flag to true here
                    in order to prevent displaying Add new Questions link
                */
                pagination_gen.writeBooleanField('HasNextQuestion', true);
                pagination_gen.writeFieldName('children');
                pagination_gen.writeStartArray();

                if (endPos == totalCount) {
                    maxValue = Math.mod(totalCount, maxValue);
                }
                preparePaginationNodes(templateId, maxValue, totalCount, false, paginationRangeAndTotalmap, pagination_gen, entity);

                pagination_gen.writeEndArray();
                pagination_gen.writeEndObject();
            }
        }
        return pagination_gen;
    }

    @RemoteAction
    public static string saveNextQuestion(Id calledFromQtnId, SObject newQtn) {

        String resp = '';
        String newlyCreatedQtnName = '';
        Set<Id> qtnIdSet = new Set<Id>();
        Map<Id, ExAM__Question_Template__c> qtnMap;
        Savepoint sp = Database.setSavepoint();
        try {
            SFDCAccessController accessForobj = ExAMUtilClass.AccessController;
            if (string.isNotBlank(calledFromQtnId) && newQtn != null) {
                String sObjName = calledFromQtnId.getSObjectType().getDescribe().getName();
                if ( sObjName == 'ExAM__Answer_Option__c' ){
                    Id ansOptId = calledFromQtnId;
                    
                    List<Answer_Option__c> ansOptList = new List<Answer_Option__c>();
                    
                    List<String> fieldsList = new List<String>{'ExAM__Help_Text__c','ExAM__Weight__c','ExAM__Next_Question__c','ExAM__Dependent_Question__c'};
                    accessForobj.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Answer_Option__c'), fieldsList);
                    List<Answer_Option__c> ansOpt = [SELECT Id,Name,Help_Text__c,Weight__c,Dependent_Question__c,Next_Question__c 
                                                    FROM Answer_Option__c 
                                                    WHERE Id = :ansOptId];
                    if ( ansOpt != null && ansOpt.size() > 0 ){
                        if ( ansOpt[0].Dependent_Question__c == null ){
                            List<String> fieldsListQT = new List<String>{'ExAM__Section_Question__c','ExAM__Question_Type__c','ExAM__Question_Label__c','ExAM__Subquestion_Label__c'};
                            accessForobj.assertAuthorizedToCreate(Schema.getGlobalDescribe().get('exam__Question_Template__c'), fieldsListQT);
                            insert newQtn;
                            if ( newQtn.Id != null ){
                                String optListString = String.valueOf(newQtn.get('ExAM__Subquestion_Label__c'));
                                List<String> optList = optListString.split('~');
                                //List<String> optList;
                                if ( optList != null && optList.size() > 0 ){
                                    List<Answer_Option__c> ansRecList = new List<Answer_Option__c>();
                                    Integer optLen = optList.size();
                                    for( Integer i = 0;i < optLen; i++ ){
                                        if ( optList[i] != null && optList[i] != '' ){
                                            Answer_Option__c ansObj = new Answer_Option__c();
                                            ansObj.Name = optList[i];
                                            ansObj.Question_Template__c = newQtn.Id;
                                            ansObj.Order_No__c = i+1;
                                            ansRecList.add(ansObj);
                                        }
                                    }
                                    if ( ansRecList.size() > 0 ){
                                        List<String> fieldsListAO = new List<String>{'ExAM__Order_No__c','ExAM__Question_Template__c'};
                                        accessForobj.assertAuthorizedTocreate(Schema.getGlobalDescribe().get('exam__Answer_Option__c'), fieldsListAO);
                                        insert ansRecList;
                                    }
                                }
                            }
                            ansOpt[0].Next_Question__c = newQtn.Id;
                            ansOptList.add(ansOpt[0]);
                        } else {
                            return 'Answer Option Record contains, Dependent Question also.';
                        }
                    }
                    if ( ansOptList.size() > 0 ){
                        
                        List<String> fieldsListAO = new List<String>{'ExAM__Next_Question__c'};
                        accessForobj.assertAuthorizedToUpdate(Schema.getGlobalDescribe().get('exam__Answer_Option__c'), fieldsListAO);
                        update ansOptList;
                        resp = 'Record Upserted Successfully';
                    }
                } else if ( sObjName == 'ExAM__Main_questionaire__c') {
                   // Savepoint sp = Database.setSavepoint();
                    List<String> fieldsListAO = new List<String>{'ExAM__Questionnaire_Section__c', 'ExAM__Section_label__c'};
                    accessForobj.assertAuthorizedToCreate(Schema.getGlobalDescribe().get('exam__Section_Template__c'), fieldsListAO);
                    insert newQtn;
                    resp = 'Record Upserted Successfully';
                } else if( sObjName == 'ExAM__Question_Template__c' ) {
                   // Savepoint sp = Database.setSavepoint();
                    List<String> fieldsListQT = new List<String>{'ExAM__Section_Question__c','ExAM__Question_Type__c','ExAM__Question_Label__c','ExAM__Subquestion_Label__c'};
                    accessForobj.assertAuthorizedToCreate(Schema.getGlobalDescribe().get('exam__Question_Template__c'), fieldsListQT);
                    insert newQtn;
                    resp = 'Record Inserted Successfully';
                    if ( newQtn.Id != null ){
                        String optListString = String.valueOf(newQtn.get('ExAM__Subquestion_Label__c'));
                        List<String> optList = optListString.split('~');
                        //List<String> optList;
                        if ( optList != null && optList.size() > 0 ){
                            List<Answer_Option__c> ansRecList = new List<Answer_Option__c>();
                            Integer optLen = optList.size();
                            for( Integer i = 0;i < optLen; i++ ){
                                if ( optList[i] != null && optList[i] != '' ){
                                    Answer_Option__c ansObj = new Answer_Option__c();
                                    ansObj.Name = optList[i];
                                    ansObj.Question_Template__c = newQtn.Id;
                                    ansObj.Order_No__c = i+1;
                                    ansRecList.add(ansObj);
                                }
                            }
                            if ( ansRecList.size() > 0 ){
                                
                                List<String> fieldsListAO = new List<String>{'ExAM__Order_No__c','ExAM__Question_Template__c'};
                                accessForobj.assertAuthorizedTocreate(Schema.getGlobalDescribe().get('exam__Answer_Option__c'), fieldsListAO);
                                insert ansRecList;
                                
                            }
                        }
                        qtnIdSet.add( newQtn.Id );
                    }
                     //add newly inserted question id
                    qtnIdSet.add( calledFromQtnId ); //add question id of record to which new question name to be linked
                    List<String> fieldsList1 = new List<String>{'ExAM__Help_Text__c','ExAM__Weight__c','ExAM__Next_Question__c','ExAM__Dependent_Question__c'};
                    accessForobj.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Answer_Option__c'), fieldsList1);
                    
                    List<String> fieldsList2 = new List<String>{'ExAM__Next_Question__c'};
                    accessForobj.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Question_Template__c'), fieldsList2);
                    qtnMap = new Map<Id, ExAM__Question_Template__c>([SELECT Id, Name, ExAM__Next_Question__c, ExAM__Single_Next_Question__c, ExAM__Single_Next_Question__r.Name,
                                                                      (SELECT Id,Name,Next_Question__c FROM Answer_Options__r)
                                                                      FROM ExAM__Question_Template__c 
                                                                      WHERE Id IN :qtnIdSet]);
    
                    if (qtnMap.containsKey(newQtn.Id) && qtnMap.get(newQtn.Id) != null) {
                        newlyCreatedQtnName = qtnMap.get(newQtn.Id).Name;
                    }
    
                    if (qtnMap.containsKey(calledFromQtnId) && qtnMap.get(calledFromQtnId) != null) {
                        if ( qtnMap.get(calledFromQtnId).Answer_Options__r.size() == 0 ){
                            //Update Next Question field in called from question
                            ExAM__Question_Template__c qtn = new ExAM__Question_Template__c();
                            qtn = qtnMap.get(calledFromQtnId);
                            if(newQtn.Id != null){
                                qtn.Single_Next_Question__c = newQtn.Id;
                            }
                            if (string.isNotBlank(qtn.ExAM__Next_Question__c) ) {
                                qtn.ExAM__Next_Question__c = qtn.ExAM__Next_Question__c+'~'+newlyCreatedQtnName;
                            }
                            else {
                                qtn.ExAM__Next_Question__c = newlyCreatedQtnName;
                            }
                            accessForobj.assertAuthorizedToUpdate(Schema.getGlobalDescribe().get('exam__Question_Template__c'), fieldsList2);
                            update qtn;
                            resp = 'Record Upserted Successfully';
                        } else {
                            resp = 'You cannot add single next question. because launched Question template has answer options';
                            Database.rollback(sp);   
                        }
                    }
                    resp = 'Record Upserted Successfully';
                } else { // question creating from section template
                    // Savepoint sp = Database.setSavepoint();
                    List<String> fieldsListQT = new List<String>{'ExAM__Section_Question__c','ExAM__Question_Type__c','ExAM__Question_Label__c','ExAM__Subquestion_Label__c'};
                    accessForobj.assertAuthorizedToCreate(Schema.getGlobalDescribe().get('ExAM__Question_Template__c'), fieldsListQT);
                    insert newQtn;
                    if ( newQtn.Id != null ){
                        String optListString = String.valueOf(newQtn.get('ExAM__Subquestion_Label__c'));
                        List<String> optList = optListString.split('~');
                        //List<String> optList;
                        if ( optList != null && optList.size() > 0 ){
                            List<Answer_Option__c> ansRecList = new List<Answer_Option__c>();
                            Integer optLen = optList.size();
                            for( Integer i = 0;i < optLen; i++ ){
                                if ( optList[i] != null && optList[i] != '' ){
                                    Answer_Option__c ansObj = new Answer_Option__c();
                                    ansObj.Name = optList[i];
                                    ansObj.Question_Template__c = newQtn.Id;
                                    ansObj.Order_No__c = i+1;
                                    ansRecList.add(ansObj);
                                }
                            }
                            if ( ansRecList.size() > 0 ){
                                
                                List<String> fieldsListAO = new List<String>{'ExAM__Order_No__c','ExAM__Question_Template__c'};
                                accessForobj.assertAuthorizedTocreate(Schema.getGlobalDescribe().get('ExAM__Answer_Option__c'), fieldsListAO);
                                insert ansRecList;
                                
                            }
                        }
                    }
                    resp = 'Record Inserted Successfully';
                }
            }
        }
        catch(Exception ex) {
           Database.rollback(sp);
            if (ex.getTypeName() == 'System.DMLException') {
                resp = ex.getDMLMessage(0);
            }
            else {
                resp = ex.getMessage();
            }
        }
        return resp;
    }

    @RemoteAction
    public static string constructNextQuestionsSet(string mainObj) {

        string jsonstr = '';

        try {

            Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(mainObj);

            if (m.containsKey('isAnswer') && m.get('isAnswer') != 'true') {

                if (m.containsKey('entity') && m.get('entity') == 'Section Templates') {
                    if (m.containsKey('sectionIdQTPaginationMap') ) {
                        Map<String, Object> sectionIdQTPaginationMap = (Map<String, Object>)m.get('sectionIdQTPaginationMap');
                        if (!sectionIdQTPaginationMap.isEmpty()) {
                            if (m.containsKey('recordId')) {
                                String sectionId = (String)m.get('recordId');
                                if (sectionIdQTPaginationMap.containsKey(sectionId) ) {
                                    Map<String, Object> qTPaginationMap = (Map<String, Object>)sectionIdQTPaginationMap.get( sectionId );
                                    if (qTPaginationMap.keySet().size() == 1) {

                                        List<Object> objList = (List<Object>)qTPaginationMap.values()[0];
                                        Set<Id> qtnIdSet = new Set<Id>();
                                        for(Object o : objList) {
                                            Id recId = (Id)o;
                                            qtnIdSet.add( recId );
                                        }
                                        jsonstr = prepareQuestionTemplates(qtnIdSet);
                                    }
                                    else {

                                        if (m.containsKey('sectionIdTemplatesMap') && m.get('sectionIdTemplatesMap') != null) {

                                            Map<String, Object> sectionIdQtnTemplatesMap = (Map<String, Object>)m.get('sectionIdTemplatesMap');
                                            List<Object> qtnsList = new List<Object>();
                                            qtnsList = (List<Object>)sectionIdQtnTemplatesMap.values()[0];

                                            JSONGenerator pagination_gen = JSON.createGenerator(true);
                                            pagination_gen.writeStartArray();
                                            JSONGenerator gen = preparePaginationNodes(sectionId, qtnsList.size(), 0, true, new Map<Integer, Integer>(), pagination_gen, 'Question Templates');
                                            gen.writeEndArray();
                                            jsonstr = gen.getAsString();
                                        }
                                    }
                                }
                            }
                        }
                        else {
                            throw new CustomException('Primary Questions not exists below this section template', null);
                        }
                    }
                }
                else if (m.containsKey('entity') && m.get('entity') == 'Question Templates') {

                    if (m.containsKey('recordId') && m.get('recordId') != null) {
                        Id qtnTemplateId = (Id)m.get('recordId');
                        JSONGenerator ansOptionGen = JSON.createGenerator(true);
                        ansOptionGen.writeStartArray();
                        JSONGenerator ansGen = prepareAnswerOption(qtnTemplateId, ansOptionGen);
                        ansGen.writeEndArray();
                        jsonstr = ansGen.getAsString();
                    }
                }
                else {
                     throw new CustomException('Section templates not exists below this assessment template', null);
                }
            }
            if (m.containsKey('isAnswer') && m.get('isAnswer') == 'true') {
                if (m.containsKey('entity') && m.get('entity') == 'Section Templates') {
                    if (m.containsKey('filteredSTMap')) {
                        Map<String, Object> sectionPaginationMap = (Map<String, Object>)m.get('filteredSTMap');

                        List<Object> objList = (List<Object>)sectionPaginationMap.values()[0];
                        Set<Id> qtnIdSet = new Set<Id>();
                        for(Object o : objList) {
                            Id recId = (Id)o;
                            qtnIdSet.add( recId );
                        }

                        JSONGenerator st_gen = JSON.createGenerator(true);
                        JSONGenerator stemplates_gen = prepareSectionTemplates(st_gen, qtnIdSet);
                        jsonstr = stemplates_gen.getAsString();
                    }
                }
                else if (m.containsKey('entity') && m.get('entity') == 'Question Templates') {

                    if (m.containsKey('filteredPTMap')) {
                        Map<String, Object> filteredPTMap = (Map<String, Object>)m.get('filteredPTMap');
                        List<Object> qtnsIdList = (List<Object>)filteredPTMap.values()[0];
                        Set<Id> qtnIdSet = new Set<Id>();
                        for(Object o : qtnsIdList) {
                            Id recId = (Id)o;
                            qtnIdSet.add( recId );
                        }
                        jsonstr = prepareQuestionTemplates(qtnIdSet);
                    }
                }
                else {

                    Boolean HasNextQuestion = false;
                    if (m.containsKey('HasNextQuestion') && m.get('HasNextQuestion') != null) {

                        HasNextQuestion = (Boolean)m.get('HasNextQuestion');
                        if (HasNextQuestion) {

                            if ((m.containsKey('ansposition') && m.get('ansposition') != null)
                                && (m.containsKey('calledFromQtnId') && m.get('calledFromQtnId') != null)
                            ) {

                                Id qtnTemplateId = (Id)m.get('calledFromQtnId');
                                Integer answerPosition = (Integer)m.get('ansposition');

                                JSONGenerator nextQtnGen = JSON.createGenerator(true);
                                nextQtnGen.writeStartArray();
                                JSONGenerator nextQtnGenResponse = prepareNextQtn(qtnTemplateId, answerPosition, nextQtnGen);
                                nextQtnGenResponse.writeEndArray();
                                jsonstr = nextQtnGenResponse.getAsString();
                            }
                        }
                    }
                }
            }
        }
        catch (Exception exp) {
            throw new CustomException(exp.getMessage(), exp);
        }
        return jsonstr;
    }
    public class JsonGeneratorClass {
        String name;
        String modalWindowText;
        String value;
        String color;
        Boolean HasNextQuestion;
        String calledFromQtnId;
        String sectionId;
        String sectionName;
        List<ChildClass> children;
    }
    public class ChildClass {
        Boolean HasNextQuestion;
        Integer answerPosition;
        String calledFromQtnId;
        String color;
        String modalWindowText;
        Integer depth;
        String name;
        String sectionId;
        String sectionName;
    }
}