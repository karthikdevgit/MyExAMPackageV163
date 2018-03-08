@RestResource(urlMapping='/AssesableRecord/*')
global with sharing class RestGetAssesableRecords {

  @HttpPost
  global static String getAssesableRecord(String assignmentManagerId) {
      
    return MobileAppUtill.returnAssessableRecord(assignmentManagerId);
  }
  
  global List<Schema.FieldSetMember> readFieldSet(String fieldSetName, String ObjectName) {
        Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe(); 
        Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get(ObjectName);
        system.debug(':::::::::::::SObjectTypeObj:'+SObjectTypeObj);
        Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();
        List<Schema.FieldSetMember> fields = new List<Schema.FieldSetMember> ();
        
        //system.debug('====>' + DescribeSObjectResultObj.FieldSets.getMap().get(fieldSetName));
    
        Schema.FieldSet fieldSetObj = DescribeSObjectResultObj.FieldSets.getMap().get(fieldSetName);
    
        //List<Schema.FieldSetMember> fieldSetMemberList =  fieldSetObj.getFields();
        //system.debug('fieldSetMemberList ====>' + fieldSetMemberList);  
        if (fieldSetObj != null && fieldSetObj.getFields() != null && fieldSetObj.getFields().size() > 0) {
            fields = fieldSetObj.getFields();
        }
        return fields; 
    }   
}