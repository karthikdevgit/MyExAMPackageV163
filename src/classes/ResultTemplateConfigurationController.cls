public with sharing class ResultTemplateConfigurationController {

    public string questionTemplateId { get; set; }
    public Boolean isResultQuestion { get; set; }

    public String fieldVisibility { get; set; }
    public String templateString { get; set; }
    public String resultQuesButtonText { get; set; }
    public List<FieldDefaultValueClass> fieldDefaultValueList { get; set; }
    
    public class TemplateClass {
        public String id;
        public String resultQuesButtonText;
        public List<FieldVisibilityClass> fieldVisibilityList;
    }
    
    public class FieldVisibilityClass {
        public Boolean hasSelected { get; set; }
        public Boolean isHidden { get; set; }
        public String fieldPosition { get; set; }
        public string fieldAPIName { get; set; }
        public string fieldLabelName { get; set; }
    }

    public class FieldDefaultValueClass {
        public string defaultValue { get; set; }
        public string fieldAPIName { get; set; }
        public string fieldLabelName { get; set; }
        public Boolean isPickList { get; set; }
        public Boolean isEnabled { get; set; }
        public List<SelectOption> fieldPklstOptions { get; set; }
    }
    
    public string assessmentTemplateId;
    public List<FieldVisibilityClass> fieldVisibilityList;
    public List<FieldVisibilityClass> fieldVisibleList ;
    
    public ResultTemplateConfigurationController() {
        try{
            assessmentTemplateId = ApexPages.currentPage().getParameters().get('assessmentTemplateId');
            questionTemplateId = ApexPages.currentPage().getParameters().get('questionTemplateId');
            SFDCAccessController accessForAT = ExAMUtilClass.AccessController;
                
            isResultQuestion = true;
            fieldVisibilityList = new List<FieldVisibilityClass>();
            fieldDefaultValueList = new List<FieldDefaultValueClass>();
            fieldVisibleList = new List<FieldVisibilityClass>();
            
            //Adding Pictures Option in to fieldVisibilityList
            FieldVisibilityClass fieldVisible1 = new FieldVisibilityClass();
            fieldVisible1.hasSelected = false;
            fieldVisible1.isHidden = false;
            fieldVisible1.fieldPosition = '';
            fieldVisible1.fieldAPIName = 'Pictures';
            fieldVisible1.fieldLabelName = 'Pictures';
            fieldVisibilityList.add( fieldVisible1 );
    
            Map<String, List<String>> pklsttempMap = new Map<String, List<String>>();
    
            Map <string, Schema.SObjectField> answerFieldNameAPIMap = Schema.SObjectType.Questionnaire_Response__c.fields.getMap();
            for (Schema.SObjectField ansfield : answerFieldNameAPIMap.values()) {
    
                Schema.DescribeFieldResult res = ansfield.getdescribe();
    
                if (res.isCustom() && res.getCalculatedFormula() == null &&
                    ((String.valueOf(res.getType()).toUpperCase() == 'STRING' ) ||
                     (String.valueOf(res.getType()).toUpperCase() == 'TEXTAREA' ) ||
                     (String.valueOf(res.getType()).toUpperCase() == 'PICKLIST' )
                    )
                ) {
    
                    FieldVisibilityClass fieldVisible2 = new FieldVisibilityClass();
                    fieldVisible2.hasSelected = false;
                    fieldVisible2.isHidden = false;
                    fieldVisible2.fieldPosition = '';
                    fieldVisible2.fieldAPIName = res.getName();
                    fieldVisible2.fieldLabelName = res.getLabel();
                    fieldVisibilityList.add( fieldVisible2 );
    
                    if (String.valueOf(res.getType()).toUpperCase() == 'PICKLIST' ) {
    
                        List<SelectOption> options = new List<SelectOption>();
                        Boolean enteredOnce = false;
                        for (Schema.PicklistEntry pklstEntry : res.getPicklistValues()) {
    
                            if (!enteredOnce) {
                                enteredOnce = true;
                                options.add( new SelectOption('', '--None--') );
                            }
                            options.add( new SelectOption(pklstEntry.getValue(), pklstEntry.getLabel()) );
                        }
                        FieldDefaultValueClass fieldDefaultVal1 = new FieldDefaultValueClass();
                        fieldDefaultVal1.defaultValue = '';
                        fieldDefaultVal1.fieldAPIName = res.getName();
                        fieldDefaultVal1.fieldLabelName = res.getLabel();
                        fieldDefaultVal1.isPickList = true;
                        fieldDefaultVal1.isEnabled = false;
                        fieldDefaultVal1.fieldPklstOptions = options;
                        fieldDefaultValueList.add( fieldDefaultVal1 );
                    }
                    else {
                        FieldDefaultValueClass fieldDefaultVal2 = new FieldDefaultValueClass();
                        fieldDefaultVal2.defaultValue = '';
                        fieldDefaultVal2.fieldAPIName = res.getName();
                        fieldDefaultVal2.fieldLabelName = res.getLabel();
                        fieldDefaultVal2.isPickList = false;
                        fieldDefaultVal2.isEnabled = false;
                        fieldDefaultVal2.fieldPklstOptions = new List<SelectOption>();
                        fieldDefaultValueList.add( fieldDefaultVal2 );
                    }
                }
            }
    
            if (String.isNotBlank(assessmentTemplateId) && assessmentTemplateId != 'null') {
    
                List<String> fieldsListAT = new List<String>{'ExAM__Decision_Tree__c'};
                accessForAT.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Main_questionaire__c'), fieldsListAT);
                
                List<Main_questionaire__c> templateList = new List<Main_questionaire__c>();
                templateList = [SELECT Id, Name, Decision_Tree__c, Result_Question_Button_Text__c FROM Main_questionaire__c WHERE Id = :assessmentTemplateId LIMIT 1];
    
                if (templateList != null && templateList.size() > 0) {
                    if ( templateList[0].Result_Question_Button_Text__c != null && templateList[0].Result_Question_Button_Text__c != '' ){
                        resultQuesButtonText = templateList[0].Result_Question_Button_Text__c;
                    }
                    if (templateList[0].Decision_Tree__c != null && templateList[0].Decision_Tree__c != '') {
    
                        List<String> strList1 = new List<String>();
    
                        if ( templateList[0].Decision_Tree__c.contains('~') ) {
                            strList1 = templateList[0].Decision_Tree__c.split('~');
                        }
                        else {
                            strList1.add( templateList[0].Decision_Tree__c );
                        }
                        if(strList1 != null && strList1.size() > 0) {
                            for(Integer i1=0;i1<strList1.size();i1++) {
                            
                                for(Integer f=0;f<fieldVisibilityList.size();f++) {
                                
                                    if (strList1[i1].split(':')[0] == fieldVisibilityList[f].fieldAPIName) {
                                        FieldVisibilityClass f1 = new FieldVisibilityClass();
                                        f1.fieldAPIName = fieldVisibilityList[f].fieldAPIName;
                                        f1.fieldLabelName = fieldVisibilityList[f].fieldLabelName;
                                        if (strList1[i1].split(':').size() > 1) {
                                            f1.hasSelected = Boolean.valueOf( strList1[i1].split(':')[1] );
                                        }
                                        if (strList1[i1].split(':').size() > 2) {
                                            f1.isHidden = Boolean.valueOf( strList1[i1].split(':')[2] );
                                        }
                                        if (strList1[i1].split(':').size() > 3) {
                                            f1.fieldPosition = strList1[i1].split(':')[3];
                                        }
                                        fieldVisibleList.add(f1);
                                        fieldVisibilityList.remove(f);
                                        break;
                                    }
                                    
                                }
                            }
                        }
                        //Unavailable fields are also show
                        if(fieldVisibilityList != null && fieldVisibilityList.size() >0) { 
                            for(FieldVisibilityClass f: fieldVisibilityList) {
                                fieldVisibleList.add(f);
                            }
                        }
                    } else {
                        fieldVisibleList = fieldVisibilityList.clone();
                    } //end Decision_Tree__c in templateList not null check
                    system.debug('::::fieldVisibleList::::'+fieldVisibleList);
                } //end templateList size check
            }//end Assessment Template CRUD check
    
            if (String.isNotBlank(questionTemplateId) && questionTemplateId != 'null') {
                
                List<String> fieldsListAT = new List<String>{'ExAM__Decision_Tree__c'};
                accessForAT.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Main_questionaire__c'), fieldsListAT);
                
                List<String> fieldsListST = new List<String>{'ExAM__Questionnaire_Section__c'};
                accessForAT.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Section_Template__c'), fieldsListST);
                
                List<String> fieldsListQT = new List<String>{'ExAM__Question_Type__c','ExAM__Section_Question__c'};
                accessForAT.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Question_Template__c'), fieldsListQT);
                
                List<Question_Template__c> questionTemplateList = new List<Question_Template__c>();
                questionTemplateList = [
                    SELECT Decision_Tree__c, Id, Name, Question_Type__c, Section_Question__c, Section_Question__r.Questionnaire_Section__c,
                           Section_Question__r.Questionnaire_Section__r.Decision_Tree__c,Section_Question__r.Questionnaire_Section__r.Result_Question_Button_Text__c
                    FROM   Question_Template__c
                    WHERE  Id = :questionTemplateId AND Question_Type__c = 'Result' LIMIT 1
                ];
    
                if (questionTemplateList == null || questionTemplateList.size() == 0) {
                    isResultQuestion = false;
                }
    
                if (questionTemplateList != null && questionTemplateList.size() > 0) {
    
                    if (questionTemplateList[0].Section_Question__r.Questionnaire_Section__r.Decision_Tree__c != null &&
                        questionTemplateList[0].Section_Question__r.Questionnaire_Section__r.Decision_Tree__c != ''
                    ) {
    
                        List<String> strList2 = new List<String>();
                        if ( questionTemplateList[0].Section_Question__r.Questionnaire_Section__r.Decision_Tree__c.contains('~') ) {
                            strList2 = questionTemplateList[0].Section_Question__r.Questionnaire_Section__r.Decision_Tree__c.split('~');
                        }
                        else {
                            strList2.add( questionTemplateList[0].Section_Question__r.Questionnaire_Section__r.Decision_Tree__c );
                        }
    
                        for(Integer i2=0;i2<strList2.size();i2++) {
    
                            for(FieldDefaultValueClass f : fieldDefaultValueList) {
                                if (strList2[i2].split(':')[0] == f.fieldAPIName) {
    
                                    Boolean isVisible = Boolean.valueOf( strList2[i2].split(':')[1] );
                                    Boolean isHidden = Boolean.valueOf( strList2[i2].split(':')[2] );
    
                                    if (isVisible || isHidden ) {
                                        f.isEnabled = true;
                                        break;
                                    }
                                }
                            }
                        }
                    }
    
                    if (questionTemplateList[0].Decision_Tree__c != null && questionTemplateList[0].Decision_Tree__c != '') {
    
                        List<String> strList3 = new List<String>();
                        if ( questionTemplateList[0].Decision_Tree__c.contains('~') ) {
                            strList3 = questionTemplateList[0].Decision_Tree__c.split('~');
                        }
                        else {
                            strList3.add( questionTemplateList[0].Decision_Tree__c );
                        }
    
                        for(Integer i3=0;i3<strList3.size();i3++) {
    
                            for(FieldDefaultValueClass f : fieldDefaultValueList) {
                                if (strList3[i3].split(':')[0] == f.fieldAPIName) {
                                    f.defaultValue = strList3[i3].split(':')[1];
                                    break;
                                }
                            }
                        }
    
                    }//end Decision_Tree__c in questionTemplateList not null check
                }//end questionTemplateList size check
            }//end Question Template CRUD check
            TemplateClass tC = new TemplateClass();
            tC.id = '';
            tC.fieldVisibilityList = fieldVisibleList;
            tC.resultQuesButtonText = resultQuesButtonText;
            templateString = JSON.serializePretty(tC);
            //fieldVisibility = JSON.serializePretty(fieldVisibleList);
        } catch(Exception e){
            ApexPages.addMessage( new Apexpages.Message(ApexPages.Severity.ERROR, e.getMessage()) );
        }
    }//end constructor
    
    public PageReference saveFieldDefaultValues() {

        if (String.isNotBlank(questionTemplateId) && questionTemplateId != 'null' &&
            (fieldDefaultValueList != null && fieldDefaultValueList.size() > 0)
        ) {

            ApexPages.Message msg;
            String resultStr = '';
            try {
                SFDCAccessController accessQT = ExAMUtilClass.AccessController;
                
                for(FieldDefaultValueClass f : fieldDefaultValueList) {

                    if (String.isNotBlank(f.defaultValue) ) {

                        if (String.isBlank(resultStr) ) {
                            resultStr = f.fieldApiName + ':' + f.defaultValue + '~';
                        }
                        else {
                            resultStr += f.fieldApiName + ':' + f.defaultValue + '~';
                        }
                    }
                }

                if (String.isNotBlank(resultStr) && resultStr.endsWith('~') ) {
                    resultStr = resultStr.substring(0, resultStr.length()-1);
                }

                Question_Template__c qt = new Question_Template__c();
                qt.Id = questionTemplateId;
                qt.Decision_Tree__c = resultStr;
                
                List<String> fieldsListQT = new List<String>{'ExAM__Decision_Tree__c'};
                accessQT.assertAuthorizedToUpdate(Schema.getGlobalDescribe().get('exam__Question_Template__c'), fieldsListQT);
                update qt;

                msg = new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Result Template field default values configuration saved successfully');
                ApexPages.addMessage(msg);

                PageReference pg = new PageReference('/'+questionTemplateId);
                return pg;
                
            } catch (Exception e) {

                String errMsg = '';

                if (e.getTypeName() == 'System.DMLExpception') {
                    errMsg = e.getDMLMessage(0);
                }
                else {
                    errMsg = e.getMessage();
                }
                msg = new ApexPages.Message(ApexPages.Severity.ERROR, errMsg);
                ApexPages.addMessage(msg);
                return null;
            }
        }        
        return null;
    }
    
    @RemoteAction
    public static string saveFieldVisibility(String templateObj) {
    
        List<FieldVisibilityClass> fieldsList = new List<FieldVisibilityClass>();
        TemplateClass template = new TemplateClass();
        String msg;
        String resultStr = '';
        template = (TemplateClass)JSON.deserialize(templateObj,TemplateClass.Class);
        fieldsList = template.fieldVisibilityList;
        String tempId = template.id;
        String resultQuesButtonText = template.resultQuesButtonText;
        
        if (String.isNotBlank(tempId) && tempId != 'null' &&
            (fieldsList != null && fieldsList.size() > 0)
        ) {
            try {
                SFDCAccessController accessAT = ExAMUtilClass.AccessController;
                Integer i=1;
                for(FieldVisibilityClass f : fieldsList) {
                    if (String.isBlank(resultStr) ) {
                        resultStr = f.fieldApiName + ':' + f.hasSelected + ':' + f.isHidden + ':' +i+ '~';
                    }
                    else {
                        resultStr += f.fieldApiName + ':' + f.hasSelected + ':' + f.isHidden + ':' +i+ '~';
                    }
                    i++;
                }

                if (String.isNotBlank(resultStr) && resultStr.endsWith('~') ) {
                    resultStr = resultStr.substring(0, resultStr.length()-1);
                }

                Main_questionaire__c mq = new Main_questionaire__c();
                mq.Id = tempId;
                mq.Decision_Tree__c = resultStr;
                if( resultQuesButtonText != null && resultQuesButtonText != '' ){
                    mq.Result_Question_Button_Text__c = resultQuesButtonText;
                }
                
                List<String> fieldsListAT = new List<String>{'ExAM__Decision_Tree__c'};
                accessAT.assertAuthorizedToUpdate(Schema.getGlobalDescribe().get('exam__Main_questionaire__c'), fieldsListAT);
                update mq;
                msg ='Success';
                
            } catch (Exception e) {
                System.debug('::::Error::::'+e.getMessage());
                msg = e.getMessage();
                return msg;
            }
        }        
        return msg;
    }
}