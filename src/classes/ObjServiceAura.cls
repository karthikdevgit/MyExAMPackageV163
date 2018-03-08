global with sharing class ObjServiceAura {

  @AuraEnabled
   global static IssueRequest_Life_Cycle__c createNewAObj(IssueRequest_Life_Cycle__c AMTemplate, String objApi, String objLabel) {
     system.debug('createNewAObj::::+++++====>' + AMTemplate); //api name

     IssueRequest_Life_Cycle__c obj = ObjService.createNewAObj(AMTemplate, objApi, objLabel);

     return obj;

    }

    @AuraEnabled
    global static List<sobject> getObjList(String objApi, String objFields, String objFilter, String objOrder) {

        List<sobject> obList = ObjService.getObjList(objApi, objFields, objFilter, objOrder);

        return obList;
    }
    
    @AuraEnabled
    global static List<sObject> fetchObjList(List<Id> ObjId, String fieldSet, String preDefinedFields) {

        List<sObject> objList = objService.fetchObjList(ObjId, fieldSet, preDefinedFields);

        return objList;
    }
    
    @AuraEnabled
    global static sObject updateRecord(String ObjectName, String id, String fieldName, String fieldVal){
          sObject obj = ObjService.updateRecord(ObjectName, id, fieldName, fieldVal);
          return obj;
    }

    @AuraEnabled
    global static List<sObject> fetchRelatedAnswers(String objId, String objFilter) {

        List<sObject> objList = ObjService.fetchRelatedAnswers(objId, objFilter);

        return objList;
    }

    /*
    * Generating Public Assessment Links
    *
    * @param ParamOfPALinks - wrapper class
    *   AMApi - Assessable Object Lookup in AM Oject (Eg:If assessable object is Account, 
        provide value as ExAM__Facility_Name__c
        or field api name in Assignment Manager object like AM_AssessableObjectName__c)(Required)
    *   assessmentGroupJunctionFieldApi - Assessable Object Lookup in AGJ Obj(Eg:If assessable object is Account, 
        provide value as ExAM__Facility_Name__c
        or field api name in Assessment Group Junction object like AGJ_AssessableObjectName__c)(Required)
    *   selectedGroupId - Selected Assessment Group Id
    *   selectedTemplateId - Selected Assessment Template (Required)
    *   noofrecords - No of records will be creating
    *   AssessableObjectApi - Assessable Object Api Name (Required)
    *   selectedobjectLabel - Assessable Object Label Name (Required)
    *   assessableRecId - Assessable Record Id
    *   expDate - Link Expiration Date (MM/DD/YYY)
    *   userId - Assigned user Id
    * @return ReturnPALinksClass - wrapper class
    */
    @AuraEnabled
    global static string generatePALink(String ParamOfPALinks){
          String sobjects = ObjService.generatePublicAssessmentLink(ParamOfPALinks);
          return sobjects;
    }
    // @AuraEnabled
    // public static Main_questionaire__c archiveAssessment(Main_questionaire__c selAssessment){
    //
    //     selAssessment = ObjService.archieveAssessment(selAssessment);
    //     return selAssessment;
    // }

   }