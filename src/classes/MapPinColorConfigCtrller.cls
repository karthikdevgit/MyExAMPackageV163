public with sharing class MapPinColorConfigCtrller {

    public class AssessibleEntityDetails {
        public List<Map_Pin_Color_Configuration__c> mapPinColorConfigRecords;
        public List<AssessibleObjectDetails> assessibleObjDtls;
        public Map<string, List<AssessibleFieldDetails>> assessibleObjApiRelatedFieldsMap;
        public Map<string, string> assessibleObjApiNameLabelMap;
        public Map<string, string> assessibleObjFieldApiNameLabelMap;
        public Map<string, List<string>> fieldApiAndPklstOptionsMap;
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

        public AssessibleFieldDetails(string fieldApi, string fieldLabel) {
            this.assessibleFieldApiName = fieldApi;
            this.assessibleFieldLabel = fieldLabel;
        }
    }

    public MapPinColorConfigCtrller() {
    }

    @RemoteAction
    public static AssessibleEntityDetails queryAllAccessibleObjsFromASM() {
        
        try{
            string fieldPrefix = 'AM_';
            AssessibleEntityDetails assessibleEntityDtls = new AssessibleEntityDetails();
            List<AssessibleObjectDetails> objDtlsList = new List<AssessibleObjectDetails>();
            List<AssessibleFieldDetails> fieldsDtlsList = new List<AssessibleFieldDetails>();
            List<Map_Pin_Color_Configuration__c> mapPinColorConfigRecordsList = new List<Map_Pin_Color_Configuration__c>();
            Map<string, List<AssessibleFieldDetails>> tempMap = new Map<string, List<AssessibleFieldDetails>>();
            Map<string, string> objMap = new Map<string, string>();
            Map<string, string> fieldMap = new Map<string, string>();
            Map<string, List<string>> pklsttempMap = new Map<string, List<string>>();
    
            SFDCAccessController accessForobj = ExAMUtilClass.AccessController;
            List<string> fieldsList = new List<string>{'ExAM__Assessible_Object__c', 'ExAM__Assessible_Object_Field__c', 'ExAM__Color_Mapping__c'};
            accessForobj.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Map_Pin_Color_Configuration__c'), fieldsList);
    
    
            for(Map_Pin_Color_Configuration__c mapConfig : [SELECT Assessible_Object__c, Assessible_Object_Field__c, Color_Mapping__c, Id, LastModifiedDate, Name FROM Map_Pin_Color_Configuration__c ORDER BY LastModifiedDate DESC]) {
                
                mapPinColorConfigRecordsList.add( mapConfig );
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

                            if (fieldType == Schema.DisplayType.Picklist ) {

                                for (Schema.PicklistEntry pklstEntry : dfr.getPicklistValues()) {

                                    if(!pklsttempMap.containsKey( dfr.getName() )) {
                                        pklsttempMap.put(dfr.getName(), new List<string>{'--None--'});
                                    }
                                    pklsttempMap.get(dfr.getName()).add( pklstEntry.getValue() );
                                }

                                string fieldTypeStr = string.valueOf(dfr.getType());
                                AssessibleFieldDetails fieldDtl = new AssessibleFieldDetails(dfr.getName(), dfr.getLabel());

                                if(!tempMap.containsKey(eachSObj.assessibleObjApiName)) {

                                    AssessibleFieldDetails defaultFieldDtl = new AssessibleFieldDetails('--None--', '--None--');
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
    
                    if ( tempMap.containsKey(eachSObj.assessibleObjApiName) && tempMap.get(eachSObj.assessibleObjApiName).size() > 0 ) {
    
                        objDtlsList1.add( eachSObj );
                    }
                }
    
                assessibleEntityDtls.mapPinColorConfigRecords = mapPinColorConfigRecordsList;
                assessibleEntityDtls.assessibleObjDtls = objDtlsList1;
                assessibleEntityDtls.assessibleObjApiRelatedFieldsMap = tempMap;
                assessibleEntityDtls.assessibleObjApiNameLabelMap = objMap;
                assessibleEntityDtls.assessibleObjFieldApiNameLabelMap = fieldMap;
                assessibleEntityDtls.fieldApiAndPklstOptionsMap = pklsttempMap;
            }
            return assessibleEntityDtls;
        }catch(Exception e){
            AssessibleEntityDetails assessibleEntityDtls = new AssessibleEntityDetails();
           // ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
            assessibleEntityDtls.errormsg = e.getmessage();
            return assessibleEntityDtls;
        }
    }

    @RemoteAction
    public static string saveMapPinColorConfiguration(Map_Pin_Color_Configuration__c mapConfigRecord) {

        string recordCreationResponse;

        try {

            SFDCAccessController accessForSSupsert = ExAMUtilClass.AccessController;
            List<string> fieldsListSSInsert = new List<string>{'ExAM__Assessible_Object__c', 'ExAM__Assessible_Object_Field__c', 'ExAM__Assessible_Object_Field__c'};
            accessForSSupsert.assertAuthorizedToCreate(Schema.getGlobalDescribe().get('exam__Map_Pin_Color_Configuration__c'), fieldsListSSInsert);
            accessForSSupsert.assertAuthorizedToUpdate(Schema.getGlobalDescribe().get('exam__Map_Pin_Color_Configuration__c'), fieldsListSSInsert);

            upsert mapConfigRecord;
            recordCreationResponse = mapConfigRecord.Id+'@@'+'Pin Color Configuration record saved successfully';
            
        }
        catch(DMLException dmlExp) {

            recordCreationResponse = 'Exception-'+dmlExp.getDMLMessage(0);
        }
        catch(Exception exp) {

            recordCreationResponse = 'Exception-'+exp.getMessage();
        }
        return recordCreationResponse;
    }

    @RemoteAction
    public static string deleteMapPinColorConfiguration(Map_Pin_Color_Configuration__c mapConfigRecord) {

        string recordCreationResponse;

        try {
           
           SFDCAccessController accessForSSdelete = ExAMUtilClass.AccessController;
           if(accessForSSdelete.isAuthorizedToDelete(Schema.getGlobalDescribe().get('exam__Map_Pin_Color_Configuration__c'))){
                delete mapConfigRecord;
                recordCreationResponse = 'Pin Color Configuration record deleted successfully';
            }
            else {

                recordCreationResponse = 'Exception-You do not have access to delete Map Pin Color Configuration';
            }
        }
        catch(DMLException dmlExp) {

            recordCreationResponse = 'Exception-'+dmlExp.getDMLMessage(0);
        }
        catch(Exception exp) {

            recordCreationResponse = 'Exception-'+exp.getMessage();
        }
        
        return recordCreationResponse;
    }
}