public with sharing class ExamDescribeHelper {
    public static String NameSpacePrefix = ExAMUtilClass.getNameSpacePrefix();
    
    public static String getFieldsOfSobject(String objectName){
        
        if(!objectName.contains(NameSpacePrefix)){
            objectName = NameSpacePrefix + objectName;
        }
        
        String selectField = '';
        
        SObjectType sobjectType = Schema.getGlobalDescribe().get(objectName);
        Map<String,Schema.SObjectField> sobjectfields = sobjectType.getDescribe().fields.getMap();
        
        for (Schema.SObjectField fieldName : sobjectfields.values()){
            selectField = selectField + fieldName + ',';
        }
        
        selectField = selectField.substring(0,selectField.length()-1);
        
        return selectField;
    }
    
    public static List<AssessmentTemplateController.WrapperFieldSet> getFieldSetByRecord(String fieldSet, String sObjectName)
    {
        
        String fieldApi;
        String fieldLabel;
        String fieldDataType;
        String helpText;
		String caseOfFieldApi; // used for lowerCase
        
        List<String> options = new List<String>();
        List<AssessmentTemplateController.WrapperFieldSet> fieldSetList = new List<AssessmentTemplateController.WrapperFieldSet>();
        
        Schema.DescribeSObjectResult DescribeSObjectResultObj = Schema.getGlobalDescribe().get(sObjectName).getDescribe();
        Map<String, Schema.SObjectField> field_map = DescribeSObjectResultObj.fields.getMap();
        Schema.FieldSet fieldSetObj = DescribeSObjectResultObj.FieldSets.getMap().get(fieldSet);
        
        if(fieldSetObj != null){
            for(Schema.FieldSetMember fieldSetMemberObj : fieldSetObj.getFields())
            {
                
                fieldApi = fieldSetMemberObj.getFieldPath();
                caseOfFieldApi = fieldApi.toLowerCase();
                fieldLabel = fieldSetMemberObj.getLabel();
                helpText = field_map.get(caseOfFieldApi).getDescribe().getInlineHelpText();
                Schema.DisplayType fieldDataTypeSchema = fieldSetMemberObj.getType();
                fieldDataType = String.valueOf(fieldDataTypeSchema);
                
                
                if ( fieldDataTypeSchema == Schema.DisplayType.Picklist ) {
                    
                    for ( Schema.Picklistentry fld : field_map.get(fieldApi).getDescribe().getpicklistValues() ) {
                        options.add(fld.getLabel());
                    }
                }
                fieldSetList.add(new AssessmentTemplateController.WrapperFieldSet(fieldApi,fieldDataType,options,fieldLabel,sObjectName, helpText));
            }
        }else{
            throw new CustomOwnException('Invalid fieldSet');
        }
        
        
        
        return fieldSetList;
    }
    
    
    public static List<sObject> getRecordByFieldSet(String sObjectName, List<String> fieldSets, String sObjectId){
        
        String query = 'SELECT ';
        String fields = '';
        String InnerQuery;
        String answerOptionsFields;
        
        if(sObjectName == NameSpacePrefix+'Main_questionaire__c'){
            fields = 'Id, Web_Intercept_Header__c, Web_Intercept_PA_Static_Resource_Name__c, Web_Intercept_PA_Resource_File_Path__c, SRFile_Path__c,'+
                'Web_Intercept_Static_Resource_Name__c, Web_Intercept_Header_color__c,'+
                'PA_Template_Heading_Text__c, PA_Header_and_Button_Background_Color__c, PA_Header_and_Button_Text_Color__c, Static_Resource_Name__c';
        } else if(sObjectName == NameSpacePrefix+'Question_Template__c'){
            fields = 'Id, Video_URL__c, Question_Label__c, Question_Order_No__c,'+
                'Name, Subquestion_Label__c, Next_Question__c, Weight_of_Answer__c, Question_Type__c, Section_Question__c, Dependent_Question__c';
            answerOptionsFields = 'Id, Name, Order_No__c, Dependent_Question__c, Dependent_Question__r.Name, Dependent_Question__r.Question_Label__c, Help_Text__c, Next_Question__c, Next_Question__r.Name, Next_Question__r.Question_Label__c, Weight__c, Question_Template__c';
            InnerQuery = ',(SELECT '+answerOptionsFields+' FROM Answer_Options__r ORDER BY Order_No__c)';
        } else if(sObjectName == NameSpacePrefix+'IssueRequest_Life_Cycle__c'){
            fields = 'Id';
        }else if(sObjectName == NameSpacePrefix+'Section_Template__c'){
            fields = 'Name, Section_label__c, isArchive__c, Questionnaire_Section__c, No_of_Questions_Section__c, Order_No__c';
        }
        
        fields = getFieldsFromFieldSet(fieldSets, fields, sObjectName);
        
        
        
        if(sObjectName == NameSpacePrefix+'Main_questionaire__c'){
            query += fields +' FROM '+ sObjectName + ' WHERE Id = \''+sObjectId+'\'';
        }else if(sObjectName == NameSpacePrefix+'Question_Template__c'){
            query += fields +InnerQuery+' FROM '+ sObjectName + ' WHERE Section_Question__c = \''+sObjectId+'\''+' ORDER BY Question_Order_No__c';
        }else if(sObjectName == NameSpacePrefix+'IssueRequest_Life_Cycle__c'){
            query += fields +' FROM '+ sObjectName + ' WHERE Id = \''+sObjectId+'\'';
        }else if(sObjectName == NameSpacePrefix+'Section_Template__c'){
            query += fields +' FROM '+ sObjectName + ' WHERE Questionnaire_Section__c = \''+sObjectId+'\'' +' and isArchive__c = false ORDER BY Order_No__c ASC';
        }
        
        try{
            if(sObjectName == NameSpacePrefix+'Question_Template__c'){
                answerOptionsFields = 'Id, Name, Order_No__c, Dependent_Question__c, Help_Text__c, Next_Question__c, Weight__c, Question_Template__c';
                FieldLevelSecurity.checkFieldAccessByCriteria(answerOptionsFields, 'view', 'Answer_Option__c');
                FieldLevelSecurity.checkFieldAccessByCriteria(fields, 'view', 'Question_Template__c');
            }else{
                FieldLevelSecurity.checkFieldAccessByCriteria(fields, 'view', sObjectName);
            }
            
            List<sObject> objList = Database.query(query);
            return objList;
        }
        catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
        
    }
    
    public static List<Schema.FieldSetMember> getFields(String sObjectName, String fieldSet) {
        Schema.DescribeSObjectResult DescribeSObjectResultObj = Schema.getGlobalDescribe().get(sObjectName).getDescribe();
        Schema.FieldSet fieldSetObj = DescribeSObjectResultObj.FieldSets.getMap().get(fieldSet);
        
        if(fieldSetObj == null){
            throw new CustomOwnException('Invalid fieldSet');
        }
        return fieldSetObj.getFields();
    }
    
    @AuraEnabled
    public static List<String> getPicklistValues(String ObjectApi_name,String Field_name){
        
        List<String> lstPickvals=new List<String>();
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(ObjectApi_name);//From the Object Api name retrieving the SObject
        Sobject Object_name = targetType.newSObject();
        Schema.sObjectType sobject_type = Object_name.getSObjectType(); //grab the sobject that was passed
        Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe(); //describe the sobject
        Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap(); //get a map of fields for the passed sobject
        List<Schema.PicklistEntry> pick_list_values = field_map.get(Field_name).getDescribe().getPickListValues(); //grab the list of picklist values for the passed field on the sobject
        for (Schema.PicklistEntry a : pick_list_values) { //for all values in the picklist list
            lstPickvals.add(a.getValue());//add the value  to our final list
        }
        
        return lstPickvals;
    }
    
    public static String getFieldsFromFieldSet(List<String> fieldSets, String fields, String sObjectName){
        
        String NameSpacePrefix = ExAMUtilClass.getNameSpacePrefix();
        for(String fieldSet : fieldSets){
            for(Schema.FieldSetMember f : getFields(sObjectName,fieldSet)) {
                if(!fields.contains(f.getFieldPath().substringAfter(NameSpacePrefix))){
                    if(fields != ''){
                        fields += ', ' + f.getFieldPath();
                    }else{
                        fields = f.getFieldPath();
                    }
                }
            }
        }
        
        return fields;
    }
    public class CustomOwnException extends Exception {
        
    }
}