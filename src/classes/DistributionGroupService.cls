public with sharing class DistributionGroupService {
    public static Map<String,String> operatorMap = new Map<String,String>{'equals'=>'=','not equals'=>'!=','less than'=>'<','less or equal'=>'<=','greater than'=>'>','greater or equal'=>'>=','contains'=>'Like'};
    
    public static TargetObjectsOperatorsClass fetchTargetObjectsWthOperators() {
        TargetObjectsOperatorsClass targetObjOperators = new TargetObjectsOperatorsClass();
        Map<String,List<String>> fieldTypeWithOperatorsMap = new Map<String,List<String>>();
        //Operaor map formation start
            fieldTypeWithOperatorsMap.put('ID',new List<String>{'equals','not equals'});//,'starts with'
            fieldTypeWithOperatorsMap.put('REFERENCE',new List<String>{'equals','not equals'});//,'starts with'
            fieldTypeWithOperatorsMap.put('BOOLEAN',new List<String>{'equals','not equals'});
            fieldTypeWithOperatorsMap.put('STRING',new List<String>{'equals','not equals','less than','less or equal','greater than','greater or equal','contains'});//all
            fieldTypeWithOperatorsMap.put('DATETIME',new List<String>{'equals','not equals','less than','less or equal','greater than','greater or equal'});
            fieldTypeWithOperatorsMap.put('DATE',new List<String>{'equals','not equals','less than','less or equal','greater than','greater or equal'});
            fieldTypeWithOperatorsMap.put('TEXTAREA',new List<String>{'equals','not equals','less than','less or equal','greater than','greater or equal','contains'});
            fieldTypeWithOperatorsMap.put('PHONE',new List<String>{'equals','not equals','less than','less or equal','greater than','greater or equal'});
            fieldTypeWithOperatorsMap.put('DOUBLE',new List<String>{'equals','not equals','less than','less or equal','greater than','greater or equal'});
            fieldTypeWithOperatorsMap.put('PICKLIST',new List<String>{'equals','not equals','less than','less or equal','greater than','greater or equal','contains'});
            fieldTypeWithOperatorsMap.put('PERCENT',new List<String>{'equals','not equals','less than','less or equal','greater than','greater or equal'});
            fieldTypeWithOperatorsMap.put('EMAIL',new List<String>{'equals','not equals','less than','less or equal','greater than','greater or equal','contains'});
            fieldTypeWithOperatorsMap.put('URL',new List<String>{'equals','not equals','less than','less or equal','greater than','greater or equal','contains'});
            fieldTypeWithOperatorsMap.put('MULTIPICKLIST',new List<String>{'equals','not equals'});
            fieldTypeWithOperatorsMap.put('CURRENCY',new List<String>{'equals','not equals','less than','less or equal','greater than','greater or equal'});
        //Operaor map formation end 
        targetObjOperators.fieldTypeWithOperatorsMap = fieldTypeWithOperatorsMap;
         List<Schema.PicklistEntry> pickListVal = Distribution_Group__c.Target_Object__c.getDescribe().getPicklistValues();
         List<TargetObjectClass> targetObjectList = new List<TargetObjectClass>();
         if(pickListVal != null && pickListVal.size() > 0) {
             for (Schema.PicklistEntry pickVal : pickListVal) {
                 if(pickVal.isActive()) {
                     SObjectType objTyp = Schema.getGlobalDescribe().get(pickVal.getLabel());
                     DescribeSObjectResult objDef = objTyp.getDescribe();
                     TargetObjectClass obj = new TargetObjectClass();     
                     obj.objAPI = objDef.getName();      
                     obj.objLabel = objDef.getLabel();    
                     targetObjectList.add(obj);                    
                 }
             }
             System.debug(':targetObjectList:'+targetObjectList);
             //targetObjectList.sort();
             System.debug(':targetObjectList after sorting:'+targetObjectList);
             targetObjOperators.targetObjectList = targetObjectList;
         }
         return targetObjOperators;
    }
    public static DistributionGroupClass fetchSelectedObjectGroup(String objectName) {
        DistributionGroupClass distGrp = new DistributionGroupClass();
        try {
            List<Distribution_Group__c> distGrpList = new List<Distribution_Group__c>();
            distGrp.distributionGroups = distGrpList;
            
            if(String.isNotBlank(objectName)) {
                List<DistObjectFieldClass> distObjFieldList = new List<DistObjectFieldClass>();
                 Map<String, Schema.SObjectField> fieldMap  = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();
                 for (Schema.SObjectField eachSObjField : fieldMap.Values()) {
                    Schema.DescribeFieldResult dfr = eachSObjField.getDescribe();
                    if( String.ValueOf(dfr.getType()).touppercase() != 'ADDRESS' ){
                        System.debug(':::'+dfr.getName()+':::');
                        DistObjectFieldClass fcls = new DistObjectFieldClass();     
                        fcls.fieldApi = dfr.getName();      
                        fcls.fieldLabel = dfr.getLabel();       
                        fcls.fieldType = string.valueOf(dfr.getType()); 
                        System.debug('fieldType ::'+string.valueOf(dfr.getType()));    
                        if( String.ValueOf(dfr.getType()).touppercase() == 'PICKLIST' ){
                            fcls.picklistValues = new List<String>();
                            List<Schema.PicklistEntry> pickListVal = eachSObjField.getDescribe().getPicklistValues();
                            if(pickListVal != null && pickListVal.size() > 0) {
                                List<String> picklistValues = new List<String>();
                                for (Schema.PicklistEntry pickVal : pickListVal) {
                                    if(pickVal.isActive()) {
                                        picklistValues.add(pickVal.getValue());
                                    }
                                }
                                fcls.picklistValues = picklistValues;
                            }
                        }
                        if( String.ValueOf(dfr.getType()).touppercase() == 'REFERENCE' ){
                            for(Schema.SObjectType reference : dfr.getReferenceTo()) {
                                fcls.refApi = reference.getDescribe().getName();
                                break;
                            }
                        }
                        distObjFieldList.add(fcls); 
                    }
                    
                }
                System.debug('distObjFieldList::'+distObjFieldList);
                if( distObjFieldList.size() > 0 ) {
                    //distObjFieldList.sort();
                    distGrp.fieldList = distObjFieldList;
                }
                String fields = 'ExAM__Target_Object__c';
                FieldLevelSecurity.checkFieldAccessByCriteria(fields, 'view', 'exam__Distribution_Group__c');
                distGrpList = [SELECT Id,Name FROM Distribution_Group__c WHERE Target_Object__c = :objectName];
                if(distGrpList.size() > 0) {
                    distGrpList.sort();
                    distGrp.distributionGroups = distGrpList;
                }
            }
        } catch (Exception e){
            throw new AuraHandledException(e.getMessage());
        }
        return distGrp;
    }
    public static DistributionCountClass queryDistRecord(String groupId) {
        DistributionCountClass distCountObj = new DistributionCountClass();
        try {
            List<Distribution_Group__c> distGrpList = new List<Distribution_Group__c>();
            distCountObj.targetRdIdFldLength = Distribution__c.Target_Object_Ids__c.getDescribe().getLength();
            String fields = 'ExAM__Target_Object__c, ExAM__Target_Object_Filter__c';
            FieldLevelSecurity.checkFieldAccessByCriteria(fields, 'view', 'exam__Distribution_Group__c');
            distGrpList = [SELECT Id, Name, Target_Object__c, Target_Object_Filter__c
                            FROM Distribution_Group__c 
                            WHERE Id = :groupId];
            if(distGrpList.size() > 0){
                List<DistributionFilterClass> distFilterList = new List<DistributionFilterClass>();
                distCountObj.distFilterList = distFilterList;
                distCountObj.count = 0;
                if( distGrpList[0].Target_Object_Filter__c != null && distGrpList[0].Target_Object_Filter__c != '' ){
                    distFilterList = (List<DistributionFilterClass>)JSON.deserialize( distGrpList[0].Target_Object_Filter__c, List<DistributionFilterClass>.class);
                    distCountObj.distFilterList = distFilterList;
                }
                fields = 'Email';
                FieldLevelSecurity.checkFieldAccessByCriteria(fields, 'view', distGrpList[0].Target_Object__c);
                String distGrpQueryStr = 'SELECT Id, Email FROM '+distGrpList[0].Target_Object__c;
                distGrpQueryStr += ' WHERE ';
                if( distFilterList.size() > 0 ){
                    List<DistributionFilterClass> updatedDistFilterList = removeInvalidFilters(distFilterList, distGrpList[0].Target_Object__c);
                    distCountObj.distFilterList = updatedDistFilterList;
                    if( updatedDistFilterList.size() > 0 ){
                        distGrpQueryStr += generateQueryStr(updatedDistFilterList);
                    }
                }
                distGrpQueryStr += 'Email != null';
                System.debug('distGrpQueryStr::'+distGrpQueryStr);
                List<SObject> targetObjectRecordsList = Database.query(distGrpQueryStr);
                distCountObj.count = targetObjectRecordsList.size();
                distCountObj.targetRecords = targetObjectRecordsList;
            }
            distCountObj.emailLimits = ExAMUtilClass.getDailyEmailLimit();
            System.debug('distCountObj with email:::'+distCountObj.emailLimits);
        } catch (Exception e){
            throw new AuraHandledException(e.getMessage());
        }
        return distCountObj;
    }
    public static AvailableDistribtionGroupClass checkFilterIsAvailable(String objectName, String filterJSON, String groupName, String selGrpId){
        AvailableDistribtionGroupClass distGroupStatus = new AvailableDistribtionGroupClass();
        try {
            List<Distribution_Group__c> distGrpList = new List<Distribution_Group__c>();
            Map<String,Set<String>> distGroupIdWthFilterListMap = new Map<String,Set<String>>();
            Map<Id,String> distGroupIdWthNameMap = new Map<Id,String>();
            distGroupStatus.isAvailable = false;
            distGroupStatus.distributionGroup = '';
            distGroupStatus.count = 0;
            distGroupStatus.isNameAvailable = false;
            distGroupStatus.targetRdIdFldLength = Distribution__c.Target_Object_Ids__c.getDescribe().getLength();
            Set<String> newFilterSet = new Set<String>();
            System.debug('filterJSON:::'+filterJSON);
            String fields = 'Email';
            FieldLevelSecurity.checkFieldAccessByCriteria(fields, 'view', objectName);
            String distGrpQueryStr = 'SELECT Id, Email FROM '+objectName;
            distGrpQueryStr += ' WHERE ';
            if( filterJSON != null && filterJSON != '' ){
                List<DistributionFilterClass> distFilterList = (List<DistributionFilterClass>)JSON.deserialize(filterJSON, List<DistributionFilterClass>.class);
                distGrpQueryStr += generateQueryStr(distFilterList);
                for( DistributionFilterClass filter :distFilterList ){
                    newFilterSet.add(JSON.serialize(filter));
                }
                System.debug('distGrpQueryStr:in check:'+distGrpQueryStr);
            }
            distGrpQueryStr += 'Email != null';
            List<SObject> targetObjectRecordsList = Database.query(distGrpQueryStr);
            distGroupStatus.count = targetObjectRecordsList.size();
            distGroupStatus.targetRecords = targetObjectRecordsList;
            fields = 'ExAM__Target_Object__c, ExAM__Target_Object_Filter__c';
            FieldLevelSecurity.checkFieldAccessByCriteria(fields, 'view', 'exam__Distribution_Group__c');
            for( Distribution_Group__c distGroup :[SELECT Id, Name, Target_Object__c, Target_Object_Filter__c FROM Distribution_Group__c WHERE Target_Object__c = :objectName]){
                if( groupName != null && groupName != '' && distGroup.Name == groupName ){
                    distGroupStatus.isNameAvailable = true;
                }
                Set<String> filterSet = new Set<String>();
                if( distGroup.Target_Object_Filter__c != null && distGroup.Target_Object_Filter__c != '' ){
                    for( DistributionFilterClass filter :(List<DistributionFilterClass>)JSON.deserialize(distGroup.Target_Object_Filter__c, List<DistributionFilterClass>.class) ){
                        filterSet.add(JSON.serialize(filter));
                    }
                }
                distGroupIdWthNameMap.put(distGroup.Id, distGroup.Name);
                distGroupIdWthFilterListMap.put(String.valueOf(distGroup.Id), filterSet);
            }
            if( distGroupIdWthFilterListMap.size() > 0 ){
                for( String groupId :distGroupIdWthFilterListMap.keySet() ){
                    Set<String> filterSet = distGroupIdWthFilterListMap.get(groupId);
                    if( newFilterSet.size() == filterSet.size() ) { 
                        Integer filterCount = 0;
                        for(String newFilter :newFilterSet){
                            if( filterSet.contains(newFilter) ){
                                filterCount++;
                            } 
                            System.debug(':::1:'+(filterCount == filterSet.size()));
                            System.debug('::1.1::'+groupId+'::'+selGrpId);
                            System.debug(':::CheckId:'+(string.isNotBlank(selGrpId)));
                            System.debug('::::compareIds:::'+ (groupId != selGrpId));
                            System.debug(':::23:'+(string.isNotBlank(selGrpId) && (groupId != selGrpId)));
                            System.debug(':::3:'+string.isBlank(selGrpId));
                            System.debug(':::4:'+((string.isNotBlank(selGrpId) && (groupId != selGrpId)) || string.isBlank(selGrpId) ));
                            if( (filterCount == filterSet.size() && ((string.isNotBlank(selGrpId) && (groupId != selGrpId)) || string.isBlank(selGrpId) ))) {
                                distGroupStatus.distributionGroup = distGroupIdWthNameMap.get(groupId);
                                distGroupStatus.isAvailable = true;
                                break;
                            }
                        }
                        if( distGroupStatus.isAvailable ){
                            break;
                        }
                    }
                }
            }
            distGroupStatus.emailLimits = ExAMUtilClass.getDailyEmailLimit();
        } catch (Exception e){
            throw new AuraHandledException(e.getMessage());
        }
        return distGroupStatus;
    }
    public static String generateQueryStr(List<DistributionFilterClass> distFilterList){
        String distGrpQueryStr = '';
        for( DistributionFilterClass filter :distFilterList ){
            String fieldAPI = filter.fieldApi;
            String fieldValue = filter.fieldValue;
            String fieldOperator = filter.operator;
            distGrpQueryStr += fieldAPI+' '+operatorMap.get(filter.operator)+' ';
            if( filter.fieldType == 'Double' ) {
                distGrpQueryStr += double.valueOf(fieldValue) +' AND ';
            } else if( filter.fieldType == 'Boolean' ){
                distGrpQueryStr += fieldValue +' AND ';
            } else if( filter.fieldType == 'Date' ){
                Date da = date.valueOf(fieldValue);
                String dStr = DateTime.newInstance(da.year(),da.month(),da.day()).format('yyyy-MM-dd');
                distGrpQueryStr +=  dStr+' AND ';
            } else if( filter.fieldType == 'DateTime' ){
                distGrpQueryStr +=  fieldValue+' AND ';
            }else {
                if( fieldOperator == 'contains' ){
                    distGrpQueryStr += '\'%'+fieldValue+'%\' AND ';
                } else {
                    distGrpQueryStr += '\''+fieldValue+'\' AND ';
                }
            }
            
        }
        System.debug('distGrpQueryStr:::'+distGrpQueryStr);
        return distGrpQueryStr;
    }
    public static List<DistributionFilterClass> removeInvalidFilters(List<DistributionFilterClass> distFilterList, String objectName){
        Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();
        Integer listLen = distFilterList.size();
        List<DistributionFilterClass> tempDistFilterList = new List<DistributionFilterClass>();
        for( Integer i = 0; i<listLen; i++ ){
            String fieldAPI = distFilterList[i].fieldApi.toLowerCase();
            if(fieldMap.containsKey(fieldAPI)){
                tempDistFilterList.add(distFilterList[i]);
            }
        }
        return tempDistFilterList;
    }
    public class DistributionGroupClass {
        @AuraEnabled
        public List<Distribution_Group__c> distributionGroups;
        @AuraEnabled
        public List<DistObjectFieldClass> fieldList;
    }
    public class DistributionCountClass {
        @AuraEnabled
        public Integer count;
        @AuraEnabled
        public List<DistributionFilterClass> distFilterList;
        @AuraEnabled
        public ExAMUtilClass.LimitClass emailLimits;
        @AuraEnabled
        public List<SObject> targetRecords;
        @AuraEnabled
        public Integer targetRdIdFldLength;
    }
    public class DistributionFilterClass{
        @AuraEnabled
        public String fieldApi;
        @AuraEnabled
        public String operator;
        @AuraEnabled
        public String fieldValue;
        @AuraEnabled
        public String fieldLabel;
        @AuraEnabled
        public String fieldType;
        @AuraEnabled
        public String refApi;
    }
    public class DistObjectFieldClass {
        @AuraEnabled
        public String fieldLabel;
        @AuraEnabled
        public String fieldApi;
        @AuraEnabled
        public String fieldType;
        @AuraEnabled
        public List<String> picklistValues;
        @AuraEnabled
        public String refApi;
    }
    public class TargetObjectsOperatorsClass {
        @AuraEnabled
        public List<TargetObjectClass> targetObjectList;
        @AuraEnabled
        public Map<String,List<String>> fieldTypeWithOperatorsMap;
    }
    public class TargetObjectClass {
        @AuraEnabled
        public String objLabel;
        @AuraEnabled
        public String objAPI;
    }
    public class AvailableDistribtionGroupClass {
        @AuraEnabled
        public String distributionGroup;
        @AuraEnabled
        public Boolean isAvailable;
        @AuraEnabled
        public Integer count;
        @AuraEnabled
        public ExAMUtilClass.LimitClass emailLimits;
        @AuraEnabled
        public Boolean isNameAvailable;
        @AuraEnabled
        public List<SObject> targetRecords;
        @AuraEnabled
        public Integer targetRdIdFldLength;
    }
}