public with sharing class MapAnythingAddressConfigCtrller {

    public class AssessibleEntityDetails {
        public List<Map_Anything_Address_Configuration__c> mapConfigRecords;
        public List<AssessibleObjectDetails> assessibleObjDtls;
        public Map<string, List<AssessibleFieldDetails>> assessibleObjApiRelatedFieldsMap;
        public Map<string, string> assessibleObjApiNameLabelMap;
        public Map<string, string> assessibleObjFieldApiNameLabelMap;
        public string errormsg;
    }

    public class AssessibleObjectDetails {
        public string assessibleObjApiName;
        public string assessibleObjLabel;

        public AssessibleObjectDetails(string objApi, string objLabel) {
            this.assessibleObjApiName = objApi;
            this.assessibleObjLabel = objLabel;
        }
    }

    public class AssessibleFieldDetails {
        public string assessibleFieldApiName;
        public string assessibleFieldLabel;
        public string assessibleFieldDataType;

        public AssessibleFieldDetails(string fieldApi, string fieldLabel, string fieldDataType) {
            this.assessibleFieldApiName = fieldApi;
            this.assessibleFieldLabel = fieldLabel;
            this.assessibleFieldDataType = fieldDataType;
        }
    }

    public MapAnythingAddressConfigCtrller() {
    }

    @RemoteAction
    public static AssessibleEntityDetails queryAllAccessibleObjsFromASM() {
        
        try{
            string fieldPrefix = 'AM_';
            AssessibleEntityDetails assessibleEntityDtls = new AssessibleEntityDetails();
            List<AssessibleObjectDetails> objDtlsList = new List<AssessibleObjectDetails>();
            List<AssessibleFieldDetails> fieldsDtlsList = new List<AssessibleFieldDetails>();
            List<Map_Anything_Address_Configuration__c> mapConfigRecordsList = new List<Map_Anything_Address_Configuration__c>();
            Set<string> existingObjNameSet = new Set<string>();
            Map<string, List<AssessibleFieldDetails>> tempMap = new Map<string, List<AssessibleFieldDetails>>();
            Map<string, string> objMap = new Map<string, string>();
            Map<string, string> fieldMap = new Map<string, string>();
    
            SFDCAccessController accessForobj = ExAMUtilClass.AccessController;
            List<string> fieldsList = new List<string>{'ExAM__Address__c','ExAM__City_Field_Name__c','ExAM__Country_Field_Name__c','ExAM__Postal_Code_Field_Name__c','ExAM__Street_Field_Name__c'};
            accessForobj.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Map_Anything_Address_Configuration__c'), fieldsList);
    
            for(Map_Anything_Address_Configuration__c mapConfig : [SELECT Address__c, City_Field_Name__c, Country_Field_Name__c, CreatedDate,
                                                                          Id, LastModifiedDate, Name, Postal_Code_Field_Name__c, Street_Field_Name__c
                                                                   FROM Map_Anything_Address_Configuration__c ORDER BY LastModifiedDate DESC]) {
                
                mapConfigRecordsList.add( mapConfig );
                existingObjNameSet.add( mapConfig.Name );
            }

            ExAMUtilClass.AssessableObjectDetails objectDetails = ExAMUtilClass.getAssessableObjectDetails('ExAM__IssueRequest_Life_Cycle__c');
            if (objectDetails != null && objectDetails.objectAPIAndLabelMap != null && objectDetails.objectAPIAndLabelMap.size() > 0) {
                for(string objectApiName : objectDetails.objectAPIAndLabelMap.keySet()) {

                    string objectLabel = objectDetails.objectAPIAndLabelMap.get(objectApiName);

                    objDtlsList.add( new AssessibleObjectDetails(objectApiName, objectLabel) );
                    objMap.put(objectApiName, objectLabel);
                }
            }
            if(objDtlsList != null && objDtlsList.size() > 0) {

                for(AssessibleObjectDetails eachSObj : objDtlsList) {
    
                    if (eachSObj.assessibleObjApiName != '--None--' && eachSObj.assessibleObjLabel != '--None--') {

                        for(Schema.SObjectField sObjField : ExAMUtilClass.getSObjectFieldsMap( eachSObj.assessibleObjApiName ).values()) {
    
                            Schema.DescribeFieldResult dfr = sObjField.getDescribe();
                            Schema.DisplayType fieldType = dfr.getType();
    
                            if (fieldType == Schema.DisplayType.String ||
                                fieldType == Schema.DisplayType.TextArea || 
                                fieldType == Schema.DisplayType.Picklist
                            ) {
    
                                string fieldTypeStr = string.valueOf(dfr.getType());
                                AssessibleFieldDetails fieldDtl = new AssessibleFieldDetails(dfr.getName(), dfr.getLabel(), fieldTypeStr);
    
                                if(!tempMap.containsKey(eachSObj.assessibleObjApiName)) {
    
                                    AssessibleFieldDetails defaultFieldDtl = new AssessibleFieldDetails('--None--', '--None--', '');
                                    tempMap.put(eachSObj.assessibleObjApiName, new List<AssessibleFieldDetails>{defaultFieldDtl});
                                }
                                tempMap.get(eachSObj.assessibleObjApiName).add( fieldDtl );
                                fieldMap.put(dfr.getName(), dfr.getLabel());
                            } // end if fieldType check
                        } // end Assessible Object fields loop iteration
                    } // end if s not equal to --None--
    
                } // end AssessibleObjectDetails loop iteration
    
                List<AssessibleObjectDetails> objDtlsList1 = new List<AssessibleObjectDetails>();
                for(AssessibleObjectDetails eachSObj : objDtlsList) {
    
                    if ( !existingObjNameSet.contains(eachSObj.assessibleObjApiName) ) {
    
                        objDtlsList1.add( eachSObj );
                    }
                }
    
                assessibleEntityDtls.mapConfigRecords = mapConfigRecordsList;
                assessibleEntityDtls.assessibleObjDtls = objDtlsList1;
                assessibleEntityDtls.assessibleObjApiRelatedFieldsMap = tempMap;
                assessibleEntityDtls.assessibleObjApiNameLabelMap = objMap;
                assessibleEntityDtls.assessibleObjFieldApiNameLabelMap = fieldMap;
            }
            return assessibleEntityDtls;
        }
        catch(Exception e){
            AssessibleEntityDetails assessibleEntityDtls = new AssessibleEntityDetails();
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
            assessibleEntityDtls.errormsg = e.getmessage();
            return assessibleEntityDtls;
        }
        
    }

    @RemoteAction
    public static string saveMapAddressConfiguration(Map_Anything_Address_Configuration__c mapConfigRecord) {

        string recordCreationResponse;

        try {
           
            SFDCAccessController accessForSSupsert = ExAMUtilClass.AccessController;
            List<string> fieldsListSSInsert = new List<string>{'ExAM__Address__c', 'ExAM__City_Field_Name__c', 'ExAM__Country_Field_Name__c', 'ExAM__Postal_Code_Field_Name__c','ExAM__Street_Field_Name__c'};
            accessForSSupsert.assertAuthorizedToCreate(Schema.getGlobalDescribe().get('exam__Map_Anything_Address_Configuration__c'), fieldsListSSInsert);
            accessForSSupsert.assertAuthorizedToUpdate(Schema.getGlobalDescribe().get('exam__Map_Anything_Address_Configuration__c'), fieldsListSSInsert);
            upsert mapConfigRecord;
            recordCreationResponse = mapConfigRecord.Id+'@@'+'Address Configuration record saved successfully';
        }
        catch(DMLException dmlExp) {
            recordCreationResponse = 'Exception-'+dmlExp.getDMLMessage(0);
            
        }
        catch(Exception exp) {

            recordCreationResponse = 'Exception-'+exp.getMessage();
            //recordCreationResponse = 'Exception-You don\'t have access to save Map Anything Address Configuration';
        }
        return recordCreationResponse;
    }

    @RemoteAction
    public static string deleteMapAddressConfiguration(Map_Anything_Address_Configuration__c mapConfigRecord) {

        string recordCreationResponse;

        try {
           
            SFDCAccessController accessForSSdelete = ExAMUtilClass.AccessController;
            if(accessForSSdelete.isAuthorizedToDelete(Schema.getGlobalDescribe().get('exam__Map_Anything_Address_Configuration__c'))){
                delete mapConfigRecord;
                recordCreationResponse = 'Address Configuration record deleted successfully';
            }else{
                recordCreationResponse = 'Exception-You don\'t have access to delete Map Anything Address Configuration';
            }
            
        }
        catch(DMLException dmlExp) {

            recordCreationResponse = 'Exception-'+dmlExp.getDMLMessage(0);
            
        }
        return recordCreationResponse;
    }
}