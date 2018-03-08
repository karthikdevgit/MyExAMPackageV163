public with sharing class DistributionService {
    public static String fields = 'Name, ExAM__Expiration_Date__c, ExAM__Landing_Page__c, ExAM__Start_Date__c,'+
        'ExAM__Status__c,  ExAM__Type__c, ExAM__Post_Assessment_Message__c, ExAM__Pre_Assessment_Message__c, ExAM__Assessment_Template__c, ExAM__Assessable_Object_API__c'; 
    
    public static List<Distribution__c> fetchDistribution(String assessmentId){
        return getDistribution(assessmentId, fields);
    }
    public static List<Distribution__c> getDistribution(String assessmentId, String fields){
        String distQuery = 'SELECT Id,'+fields+', (SELECT Id, Public_Assessment_URL__c FROM Public_Assessments__r ) FROM Distribution__c WHERE Is_Archive__c = false AND Assessment_Template__c = \''+assessmentId+'\' ORDER BY CreatedDate DESC'; 
        List<Distribution__c> distributions = Database.query(distQuery);
        return distributions;
    }
    
    public static void archiveDistribution(String distributionId){        
        Distribution__c archivedDistribution = [SELECT Id,Is_Archive__c FROM Distribution__c WHERE Id = :distributionId];
        archivedDistribution.Is_Archive__c = true;
        String fields = 'ExAM__Is_Archive__c';
        FieldLevelSecurity.checkFieldAccessByCriteria(fields, 'update', 'exam__Distribution__c');
        update archivedDistribution;
    }
    
    public static void deleteDistribution(String distributionId){
        Database.Delete(distributionId);
    }
    
    public static DistributionsDetails getDistributionsWthFieldSet(String assessmentId, List<String> fieldSets, String sObjectName){
        List<WrapperFieldSet> listOfWrapperFieldSet = new List<WrapperFieldSet>();
        if(!fieldSets.isEmpty()){
            
            for(String fieldSet : fieldSets){
                Schema.DescribeSObjectResult DescribeSObjectResultObj = Schema.getGlobalDescribe().get(sObjectName).getDescribe();
                Map<String, Schema.SObjectField> field_map = DescribeSObjectResultObj.fields.getMap();
                Schema.FieldSet fieldSetObj = DescribeSObjectResultObj.FieldSets.getMap().get(fieldSet);
                System.debug('fieldSet::::'+fieldSet);
                System.debug('fieldSet::::'+DescribeSObjectResultObj.FieldSets.getMap());
                System.debug('DescribeSObjectResultObj:::'+DescribeSObjectResultObj);
                System.debug('fieldSetObj:::'+fieldSetObj);
                if(fieldSetObj != null){
                    for(Schema.FieldSetMember fieldSetMemberObj : fieldSetObj.getFields()){
                        WrapperFieldSet wrapperInstance = new WrapperFieldSet();
                        
                        wrapperInstance.fieldApi = fieldSetMemberObj.getFieldPath();
                        String caseOfFieldApi = wrapperInstance.fieldApi.toLowerCase();
                        wrapperInstance.fieldLabel = fieldSetMemberObj.getLabel();
                        wrapperInstance.sObjectApi = sObjectName;
                        wrapperInstance.inLineHelpText = field_map.get(caseOfFieldApi).getDescribe().getInlineHelpText();
                        Schema.DisplayType fieldDataTypeSchema = fieldSetMemberObj.getType();
                        wrapperInstance.fieldDataType = String.valueOf(fieldDataTypeSchema);
                        
                        if ( fieldDataTypeSchema == Schema.DisplayType.Picklist ) {
                            for ( Schema.Picklistentry fld : field_map.get(wrapperInstance.fieldApi).getDescribe().getpicklistValues() ) {
                                wrapperInstance.options.add(fld.getLabel());
                            }
                        }
                        listOfWrapperFieldSet.add(wrapperInstance);
                    }
                }
            }
            
        }
        DistributionsDetails distributionsInstance = new DistributionsDetails();
        distributionsInstance.fieldSet = listOfWrapperFieldSet;
        fields = ExamDescribeHelper.getFieldsFromFieldSet(fieldSets, fields, sObjectName);
        
        /*String innerQuery = 'SELECT Id, Public_Assessment_URL__c FROM Public_Assessments__r';
        String query = 'SELECT '+ fields +',('+ innerQuery +') FROM '+ sObjectName + ' WHERE ExAM__Assessment_Template__c = \''+assessmentId+'\'';
        */        
        distributionsInstance.distributions = getDistribution(assessmentId, fields); // Database.query(query);
        return distributionsInstance;
    }
    
    public static void createDistributionWthPALink(Distribution__c distributionObj, Distribution_Group__c distributionGroupObj, Integer countOfPALinks){

        Savepoint sp;

        try{

            //Setting savepoint here to roll back to this state if any error occurs
            sp = Database.setSavepoint();

           /**
                Below code checks whether Field Mapping Configuration is done correctly
                before creating Distribution and Public Assessment record.
            **/
            if( distributionObj.Assessable_Record__c == null || distributionObj.Assessable_Record__c == '' ){
                PublicAssessmentCreationController.AFMWrapper afm = new PublicAssessmentCreationController.AFMWrapper();
                afm.selectedObj = distributionObj.Assessable_Object_API__c;
                afm.templateId = distributionObj.Assessment_Template__c;
                String returnMsg = PublicAssessmentCreationController.getAssessableFieldMapping(afm);
                String errorMsg = '';
                try {
                    PublicAssessmentCreationController.FieldMappingWrapper fmw = (PublicAssessmentCreationController.FieldMappingWrapper)JSON.deserialize(returnMsg, PublicAssessmentCreationController.FieldMappingWrapper.class);
                        if(!fmw.isEnableFMConfig || fmw.afmList.size() == 0) {
                            errorMsg = 'You must enable field mapping and configure field mapping records to create public assessments using selected template and assessable object';
                        } else if(fmw.requiredFieldsSet.size() > 0){
                            string fieldsReqd = '';
                            for( string s : fmw.requiredFieldsSet ) {
                                fieldsReqd += (string.isBlank(fieldsReqd)) ? s : ','+s;
                            }
                            errorMsg = 'Please ensure the following required fields are covered via Field Mapping '+fieldsReqd;
                        } else {
                            Integer fmLen = fmw.afmList.size();
                                for(Integer i=0; i<fmLen; i++){
                                    if(fmw.afmList[i].Mapped_From__c == 'Assignment Manager' ){
                                        errorMsg = 'Assessment Templates with field mapping based on Assignment Manager cannot be used for this feature';
                                        break;
                                    }
                                }
                        }
                } catch ( Exception e ){
                    PublicAssessmentCreationController.ErrorClass ec = (PublicAssessmentCreationController.ErrorClass)JSON.deserialize(returnMsg, PublicAssessmentCreationController.ErrorClass.class);
                    errorMsg = ec.errMsg;
                }
                if( errorMsg != '' ){
                    throw new CustomOwnException(errorMsg);
                }
            }

            /**
                Below code finds any existing Distribution Group with selected criteria.
                If matching group exists set that group as parent of Distribution record.
            **/
            if( distributionGroupObj != null && distributionObj.Send_Mode__c == 'Email with Salesforce' ) { 
                if(distributionGroupObj.Target_Object_Filter__c == '[]'){
                    distributionGroupObj.Target_Object_Filter__c = null;
                    String objName = distributionGroupObj.Target_Object__c;
                    String fields = 'ExAM__Target_Object__c, ExAM__Target_Object_Filter__c';
                    FieldLevelSecurity.checkFieldAccessByCriteria(fields, 'view', 'exam__Distribution_Group__c');
                    List<Distribution_Group__c> dstGrpList = new List<Distribution_Group__c>([SELECT Id, Name, Target_Object_Filter__c FROM Distribution_Group__c WHERE Target_Object__c = :objName]);
                    if( dstGrpList != null && dstGrpList.size() > 0 ) {
                        for( Distribution_Group__c distGrp :dstGrpList ){
                            if(distGrp.Target_Object_Filter__c == null){
                                distributionGroupObj.Id = distGrp.Id;
                                break;
                            }
                        }
                    }
                }
                if( distributionObj != null ){
                    distributionObj.Distribution_Group__c = distributionGroupObj.Id;
                }
            }

            //Upsert Distribution Group record
            if( distributionGroupObj != null && distributionGroupObj.Name != null && distributionGroupObj.Name != '' ) {
                String fields = 'ExAM__Target_Object__c, ExAM__Target_Object_Filter__c';
                FieldLevelSecurity.checkFieldAccessByCriteria(fields, 'create', 'exam__Distribution_Group__c');
                FieldLevelSecurity.checkFieldAccessByCriteria(fields, 'update', 'exam__Distribution_Group__c');
                upsert distributionGroupObj;    
            }  
            System.debug('inserted Distribution Group record::::'+distributionGroupObj);

            //Insert Distribution record
            if( distributionObj != null && distributionObj.Name != null && distributionObj.Name != '' ) {
                String fields = 'Name, ExAM__Expiration_Date__c, ExAM__Landing_Page__c, ExAM__Start_Date__c,'+
        'ExAM__Type__c, ExAM__Post_Assessment_Message__c, ExAM__Pre_Assessment_Message__c, ExAM__Assessment_Template__c, ExAM__Assessable_Object_API__c'; 
                FieldLevelSecurity.checkFieldAccessByCriteria(fields, 'create', 'exam__Distribution__c');
                insert distributionObj;    
            }  
            System.debug('inserted Distribution record::::'+distributionObj);

            //Insert Public Assessment record
            String assessableObjectAPIInPA = '';
            Public_Assessment__c paRec = new Public_Assessment__c();
            paRec.Assessment_Template__c = distributionObj.Assessment_Template__c;
            paRec.Distribution__c = distributionObj.Id;
            if( String.isNotBlank(distributionObj.Assessable_Object_API__c) ) {
                Schema.DescribeSObjectResult objectResult = Schema.getGlobalDescribe().get(distributionObj.Assessable_Object_API__c).getDescribe();
                string objectLocalName = (objectResult.isCustom()) ? objectResult.getLocalName() : objectResult.getLocalName()+'__c';
                assessableObjectAPIInPA = (objectLocalName == 'Account__c') ? 'ExAM__Facility_Name__c' :'PA_'+objectLocalName;
            }
            if( String.isNotBlank(distributionObj.Assessable_Record__c) ) {
                paRec.Assessible_Object_ID__c = distributionObj.Assessable_Record__c;
                if(String.isNotBlank(assessableObjectAPIInPA)) {
                    paRec.put(assessableObjectAPIInPA, distributionObj.Assessable_Record__c);
                }
            } else if( String.isBlank(distributionObj.Assessable_Record__c) && String.isNotBlank(distributionObj.Assessable_Object_API__c) ) {
                paRec.Assessable_Object_API__c = distributionObj.Assessable_Object_API__c;
            }
            String fields = 'ExAM__Assessment_Template__c, ExAM__Distribution__c, ExAM__Assessible_Object_ID__c, ExAM__Assessable_Object_API__c';
            FieldLevelSecurity.checkFieldAccessByCriteria(fields, 'create', 'exam__Public_Assessment__c');
            insert paRec;
            System.debug('inserted PA record::::'+paRec);

            /**
                Below code triggers SendDistributionScheduler to run at the prescribed date and time
                in distribution record only when Send Mode is Email with Salesforce
            **/
            if( distributionObj != null && distributionObj.Distribution_DateTime__c != null && distributionObj.Send_Mode__c == 'Email with Salesforce' ) {
                system.debug('::distributionObj.Distribution_DateTime__c::'+distributionObj.Distribution_DateTime__c);
                SendDistributionScheduler sds = new SendDistributionScheduler(distributionObj.Id);
                String jobName = distributionObj.Name + ' ' + String.valueOf(System.now());
                Integer min = distributionObj.Distribution_DateTime__c.minute();
                Integer hr = distributionObj.Distribution_DateTime__c.hour();
                Integer day = distributionObj.Distribution_DateTime__c.day();
                Integer mon = distributionObj.Distribution_DateTime__c.month();
                Integer year = distributionObj.Distribution_DateTime__c.year();
                String cron = 0+' '+string.valueOf(min)+' '+string.valueOf(hr)+' '+string.valueOf(day)+' '+string.valueOf(mon)+' '+'?'+' '+string.valueOf(year);
                String jobID = system.schedule(jobName, cron, sds);
            }

        }
        catch(Exception e){
            Database.rollback( sp );
            throw new AuraHandledException(e.getMessage());
        }
    }

    public static List<AssessableObjectWrapper> getAssessableObjectDetails(String sObjectApiName) {
        
        List<AssessableObjectWrapper> AssessableObjectWrapperList = new List<AssessableObjectWrapper>();
        System.debug('obj api name:::'+sObjectApiName);
        if (String.isNotBlank(sObjectApiName)) {
            sObjectApiName = (sObjectApiName.startsWithIgnoreCase('exam') == false) ? 'ExAM__'+sObjectApiName : sObjectApiName;
            String fieldPrefix = 'AM_';
            Map<string, Schema.SObjectField> sObjFieldsMap = ExAMUtilClass.getSObjectFieldsMap( sObjectApiName );
            AssessableObjectWrapper assessableObjWrapper = new AssessableObjectWrapper();
            assessableObjWrapper.assObjFieldApi = (sObjectApiName != 'ExAM__Questionnaire_Response__c') ? 'ExAM__Facility_Name__c' : 'ExAM__Account_to_Response__c';
            assessableObjWrapper.assObjApiName = 'Account';
            assessableObjWrapper.assObjLabel = 'Account';
            AssessableObjectWrapperList.add(assessableObjWrapper);
            if (sObjFieldsMap != null && sObjFieldsMap.size() > 0) {
                for (Schema.SObjectField eachfield : sObjFieldsMap.Values()) {
                    Schema.DescribeFieldResult dfr = eachfield.getDescribe();
                    if ((dfr.isCustom() && (dfr.getType() == Schema.DisplayType.REFERENCE) && dfr.getLocalName().startsWithIgnoreCase(fieldPrefix))) {
                        Schema.DescribeSObjectResult dsor = dfr.getReferenceTo().get(0).getDescribe();
                        AssessableObjectWrapper assessableObjWrap = new AssessableObjectWrapper();
                        assessableObjWrap.assObjFieldApi = dfr.getName();           
                        assessableObjWrap.assObjApiName = dsor.getName();
                        assessableObjWrap.assObjLabel = dsor.getLabel();
                        AssessableObjectWrapperList.add(assessableObjWrap);
                        System.debug('ass obj::'+assessableObjWrap);
                    }
                }
            }
        }
        system.debug('::::AssessableObjectWrapperList:::::'+AssessableObjectWrapperList);
        return AssessableObjectWrapperList;  
    }
    
    public class AssessableObjectWrapper {
        @AuraEnabled
        Public String assObjFieldApi;
        @AuraEnabled
        public String assObjApiName;
        @AuraEnabled
        public String assObjLabel;
    }
    
    public class DistributionsDetails{
        @AuraEnabled
        public List<WrapperFieldSet> fieldSet;
        @AuraEnabled
        public List<Distribution__c> distributions;
    }
    public class WrapperFieldSet{
        @AuraEnabled
        public string fieldApi;
        @AuraEnabled
        public string fieldDataType;
        @AuraEnabled
        public string fieldLabel;
        @AuraEnabled
        public string sObjectApi;
        @AuraEnabled
        public List<String> options = new List<String>();
        @AuraEnabled
        public string inLineHelpText;
    }
    public class CustomOwnException extends Exception {}
}