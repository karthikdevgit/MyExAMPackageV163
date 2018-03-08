global with sharing class ObjService {
    
    global static SObject updateRecord(string ObjectName, string id, string fieldName, string fieldVal){
        
        Map<string, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        Set<string> objectKeys = gd.keySet();
        SObject sObj;
        if(objectKeys.contains(Objectname.toLowerCase()))
        {
            //Creating a new SObject
            sObj = Schema.getGlobalDescribe().get(ObjectName).newSObject();
            sObj.put('id',id);
            sObj.put(fieldName,fieldVal);
            
            try{
                FieldLevelSecurity.checkFieldAccessByCriteria(fieldName, 'update', ObjectName, true); //Do Not add namespace before check
                update sObj;
            }
            catch(Exception e){
                throw new AuraHandledException(e.getMessage());
            }
            
        }
        return sObj;
    }
    
    global static IssueRequest_Life_Cycle__c createNewAObj(IssueRequest_Life_Cycle__c AMTemplate, string objApi, string objLabel) {
        
        string amDesc = AMTemplate.ExAM__Issue_request__c;
        string amFields = 'ExAM__Issue_request__c, ExAM__Support_Status__c';
        string paFields = 'ExAM__Assignment_Manager__c';
        Boolean isAutonumber = true;
        string fieldApiName = '';
        string nameSpace = '';
        try {
            if(Schema.getGlobalDescribe().containsKey(objApi)){
                if(objApi != 'Account'){
                    nameSpace = [SELECT NamespacePrefix FROM Organization].NamespacePrefix;
                    nameSpace = nameSpace != '' && nameSpace != null ? nameSpace+'__' : '';
                }
                FieldLevelSecurity.checkFieldAccessByCriteria(amFields, 'create', 'ExAM__IssueRequest_Life_Cycle__c', true); //Do Not add namespace before check
                FieldLevelSecurity.checkFieldAccessByCriteria(paFields, 'create', 'ExAM__Public_Assessment__c', true); //Do Not add namespace before check
                
                if (!objApi.equalsIgnoreCase('Contact') && !objApi.equalsIgnoreCase('Lead') && !objApi.equalsIgnoreCase('Case')) {
                    Map<string, Schema.SObjectField> fldMap = Schema.getGlobalDescribe().get(objApi).getDescribe().fields.getMap();
                    Schema.DescribeFieldResult desribeResult = fldMap.get('Name').getDescribe();
                    if ( !desribeResult.isNillable() && !desribeResult.isDefaultedOnCreate()) {
                        isAutonumber = false;
                    }
                }
                
                SObject sob = Schema.getGlobalDescribe().get(objApi).newSObject();
                
                if (objApi.equalsIgnoreCase('Contact')) {
                    sob.put('lastname', 'Contact '+System.now());
                } else if (objApi.equalsIgnoreCase('Lead')) {
                    sob.put('lastname', 'Lead '+System.now());
                    sob.put('Company', 'Company '+System.now());
                } else {
                    if(!isAutonumber) {
                        sob.put('Name', objLabel+System.now());
                    }
                }
                insert sob;
                
                if(objApi == 'Account') {
                    FieldLevelSecurity.checkFieldAccessByCriteria('ExAM__Facility_Name__c', 'create', 'ExAM__IssueRequest_Life_Cycle__c', true); //Do Not add namespace before check
                    AMTemplate.put('Facility_Name__c',  sob.Id);
                } else {
                    if(objApi.endsWith('__c')){    // check whether Custom Object
                        if(objApi.startsWith('ExAM__')){  // Object from ExAM package
                            string wthOutNobjectListApi = objApi.removeStart('ExAM__');
                            fieldApiName = 'AM_' + wthOutNobjectListApi;
                            FieldLevelSecurity.checkFieldAccessByCriteria(nameSpace+fieldApiName, 'create', 'ExAM__IssueRequest_Life_Cycle__c', true); //Do Not add namespace before check
                            AMTemplate.put(fieldApiName, sob.Id);
                        }else if(nameSpace != '' && objApi.startsWith(nameSpace)){      // Object from Local Org. check local Org have NameSpace 
                            string wthOutNobjectListApi = objApi.removeStart(nameSpace);
                            fieldApiName = 'AM_' + wthOutNobjectListApi;
                            FieldLevelSecurity.checkFieldAccessByCriteria(nameSpace+fieldApiName, 'create', 'ExAM__IssueRequest_Life_Cycle__c', true); //Do Not add namespace before check
                            AMTemplate.put(fieldApiName, sob.Id);
                        }else{      // Object from Local Org without NameSpace
                            fieldApiName = 'AM_' + objApi;
                            FieldLevelSecurity.checkFieldAccessByCriteria(nameSpace+fieldApiName, 'create', 'ExAM__IssueRequest_Life_Cycle__c', true); //Do Not add namespace before check
                            AMTemplate.put(fieldApiName,  sob.Id);
                        }
                    }else{      // whether Standard Object
                        fieldApiName = 'AM_' + objApi + '__c';
                        FieldLevelSecurity.checkFieldAccessByCriteria(nameSpace+fieldApiName, 'create', 'ExAM__IssueRequest_Life_Cycle__c', true); //Do Not add namespace before check
                        AMTemplate.put(fieldApiName,  sob.Id);
                    }
                }
                
                insert AMTemplate;
                
                Public_Assessment__c pa = new Public_Assessment__c();
                pa.Assignment_Manager__c = AMTemplate.Id;
                
                if(objApi == 'Account') {
                    FieldLevelSecurity.checkFieldAccessByCriteria('ExAM__Facility_Name__c', 'create', 'ExAM__Public_Assessment__c', true); //Do Not add namespace before check
                    pa.put('Facility_Name__c', sob.Id);
                } else {
                    if(objApi.endsWith('__c')){  // check whether Custom Object
                        if(objApi.startsWith('ExAM__')){    // Object from ExAM package
                            string wthOutNobjectListApi = objApi.removeStart('ExAM__');
                            fieldApiName = 'PA_' + wthOutNobjectListApi;
                            FieldLevelSecurity.checkFieldAccessByCriteria(nameSpace+fieldApiName, 'create', 'ExAM__Public_Assessment__c', true); //Do Not add namespace before check
                            pa.put(fieldApiName, sob.Id);
                        }else if(nameSpace != '' && objApi.startsWith(nameSpace)){  // Object from Local Org. check local Org have NameSpace 
                            string wthOutNobjectListApi = objApi.removeStart(nameSpace);
                            fieldApiName = 'PA_' + wthOutNobjectListApi;
                            FieldLevelSecurity.checkFieldAccessByCriteria(nameSpace+fieldApiName, 'create', 'ExAM__Public_Assessment__c', true); //Do Not add namespace before check
                            pa.put(fieldApiName, sob.Id);                            
                        }else{  // Object from Local Org without NameSpace
                            fieldApiName = 'PA_' + objApi;
                            FieldLevelSecurity.checkFieldAccessByCriteria(nameSpace+fieldApiName, 'create', 'ExAM__Public_Assessment__c', true); //Do Not add namespace before check
                            pa.put(fieldApiName, sob.Id);
                        }
                    }else{  // whether Standard Object
                        fieldApiName = 'PA_' + objApi + '__c';
                        FieldLevelSecurity.checkFieldAccessByCriteria(nameSpace+fieldApiName, 'create', 'ExAM__Public_Assessment__c', true); //Do Not add namespace before check
                        pa.put(fieldApiName, sob.Id);
                    }
                }
                insert pa;
                
                Public_Assessment__c PAObj = [SELECT Id, Public_Assessment_URL__c FROM Public_Assessment__c WHERE Id =:pa.Id];
                AMTemplate.Public_Assessment_URL__c = PAObj.Public_Assessment_URL__c;
                FieldLevelSecurity.checkFieldAccessByCriteria('ExAM__Public_Assessment_URL__c', 'update', 'ExAM__IssueRequest_Life_Cycle__c', true); //Do Not add namespace before check
                update AMTemplate;
                
                return AMTemplate;
                
            }else{
                throw new CustomOwnException('Invalid Object');
            }
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
        
    }
    
    global static List<SObject> getObjList(string objApi, string objFields, string objFilter, string objOrder) {
        
        try{
            if(Schema.getGlobalDescribe().containsKey(objApi)){
                List<SObject> objList = new List<SObject>();
                if (objApi != null && objFields != null){
                    
                    List<fieldWrapper> fieldList = (List<fieldWrapper>) JSON.deserialize(objFields, List<fieldWrapper>.class);
                    if(fieldList == null){
                        throw new CustomOwnException('No Fields');
                    }
                    
                    DescribeSObjectResult describeObj = Schema.getGlobalDescribe().get(objApi).getDescribe();
                    Map<string,Schema.SObjectField> fieldsMap = describeObj.fields.getMap();
                    string objectName = describeObj.getName();
                    string queryFields = '';
                    string securityCheckFields = '';
                    
                    for(fieldWrapper wrapper: fieldList){
                        string fieldName = wrapper.fieldApi;
                        if(fieldName.indexOf('__r') > 0) {
                            fieldName = fieldName.substring(0,fieldName.indexOf('__r'))+'__c';
                        }
                        if(!fieldsMap.containsKey(fieldName)){
                            continue;
                        }
                        securityCheckFields += fieldName+',';
                        queryFields +=  wrapper.fieldApi+',';
                    }
                    securityCheckFields = securityCheckFields.removeEnd(',');
                    queryFields = queryFields.removeEnd(',');
                    string objFieldStr;
                    
                    FieldLevelSecurity.checkFieldAccessByCriteria(securityCheckFields, 'view', objApi, true); //Do Not add namespace before check
                    
                    string query = 'SELECT ' + queryFields + ' FROM ' + objApi;
                    objFilter = objFilter.contains('%currentuser%') ? objFilter.replace('%currentuser%', '\'' + UserInfo.getUserId() + '\''): objFilter;
                    query = objFilter != '' ? query += ' WHERE ' + objFilter: query;
                    query = objOrder != '' ? query += ' ORDER BY ' + objOrder : query;
                    
                    objList = Database.query(query);
                } else {
                    throw new CustomOwnException('Malformed parameters');
                }
                
                return objList;
                
            }else{
                throw new CustomOwnException('Invalid Object');
            }
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
        
    }
    global static List<SObject> fetchObjList(List<Id> ObjId, string fieldSet, string preDefinedFields){

        List<SObject> objList = new List<SObject>();
        try{
            if(ObjId.size() > 0){
                string objectListName = ObjId[0].getSObjectType().getDescribe().getName();
                string fields = 'Id';
                
                if(preDefinedFields != '' && preDefinedFields != null){
                    fields = fields + ',' + preDefinedFields;
                }
                
                if(fieldSet != '' && fieldSet != null){
                    Schema.DescribeSObjectResult DescribeSObjectResultObj = Schema.getGlobalDescribe().get(objectListName).getDescribe();
                    Schema.FieldSet fieldSetObj = DescribeSObjectResultObj.FieldSets.getMap().get(fieldSet);
                    
                    if(fieldSetObj != null){
                        
                        for(Schema.FieldSetMember f : fieldSetObj.getFields()) {
                            
                            if(!fields.contains(f.getFieldPath())){
                                fields += ', ' + f.getFieldPath();
                            }
                        }
                        
                    }else{
                        throw new CustomOwnException('Invalid fieldSet');
                    }
                    
                }
                FieldLevelSecurity.checkFieldAccessByCriteria(fields, 'view', objectListName, true); //Do Not add namespace before check
                string strQuery = 'SELECT ' + fields + ' FROM ' + objectListName + ' WHERE Id IN :ObjId';
                objList = Database.query(strQuery);
            }
            return objList;
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }

    global static List<SObject> fetchRelatedAnswers(string objId, string objFilter){
        List<SObject> objList = new List<SObject>();
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
    global static string generatePublicAssessmentLink( string ParamOfPALinks ) {
            
        string PAObjAssessbleField = '';
        Date expDate;

        List<IssueRequest_Life_Cycle__c> amList = new List<IssueRequest_Life_Cycle__c>();
        List<Public_Assessment__c> paList = new List<Public_Assessment__c> (); 
        List<SObject> sobList = new List<SObject>();
        List<IssueRequest_Life_Cycle__c> amUpdateList;

        Map<Id, IssueRequest_Life_Cycle__c> amMap;

        ParamOfPALinksClass paramRec;
        
        ReturnPALinksClass returnRecs = new ReturnPALinksClass();
        returnRecs.objectList = sobList;
        returnRecs.amList = amList;
        returnRecs.paList = paList;
        returnRecs.message = 'Failure!';
               
        Savepoint sp = Database.setSavepoint();
        try {
            if(ParamOfPALinks != null && ParamOfPALinks != '') {
                paramRec = (ParamOfPALinksClass) JSON.deserialize(ParamOfPALinks, ParamOfPALinksClass.class);
            }
            string AMApi = (paramRec != null && paramRec.AMApi != null )? paramRec.AMApi: '';
            string assessmentGroupJunctionFieldApi = (paramRec != null && paramRec.assessmentGroupJunctionFieldApi != null )? paramRec.assessmentGroupJunctionFieldApi: '';
            string selectedGroupId = (paramRec != null && paramRec.selectedGroupId != null )? paramRec.selectedGroupId: '';
            string selectedTemplateId = (paramRec != null && paramRec.selectedTemplateId != null )? paramRec.selectedTemplateId: '';
            string noofrecords = (paramRec != null && paramRec.noofrecords != null )? paramRec.noofrecords: '';
            string AssessableObjectApi = (paramRec != null && paramRec.AssessableObjectApi != null )? paramRec.AssessableObjectApi: '';
            string selectedobjectLabel = (paramRec != null && paramRec.selectedobjectLabel != null )? paramRec.selectedobjectLabel: '';
            string assessableRecId = (paramRec != null && paramRec.assessableRecId != null )? paramRec.assessableRecId: '';
            string expDateStr = (paramRec != null && paramRec.expDate != null )? paramRec.expDate: '';
            string userId = (paramRec != null && paramRec.userId != null )? paramRec.userId: '';
            if (string.isNotBlank(expDateStr) && expDateStr.contains('/')) {
                expDate = date.parse(expDateStr);
            }
        
            if (AMApi != null && selectedTemplateId != null && selectedTemplateId != '') {
            
                FieldLevelSecurity.checkFieldAccessByCriteria('ExAM__InvestigationType__c,ExAM__Assessor_Resource__c', 'create', 'ExAM__IssueRequest_Life_Cycle__c', true); //Do Not add namespace before check
                FieldLevelSecurity.checkFieldAccessByCriteria('ExAM__Assignment_Manager__c,ExAM__Expiration_Date__c', 'create', 'ExAM__Public_Assessment__c', true);
                FieldLevelSecurity.checkFieldAccessByCriteria('ExAM__Public_Assessment_URL__c', 'update', 'ExAM__IssueRequest_Life_Cycle__c', true); //Do Not add namespace before check
                if ( assessmentGroupJunctionFieldApi != null && selectedGroupId != null && selectedGroupId != '') {
                    FieldLevelSecurity.checkFieldAccessByCriteria('ExAM__Assessment_Group__c', 'view', 'ExAM__Assessment_Group_Junction__c', true); 

                    string queryStr = 'SELECT Id, Name, ExAM__Assessment_Group__c, '+assessmentGroupJunctionFieldApi+' FROM ExAM__Assessment_Group_Junction__c ';
                    queryStr += ' WHERE ExAM__Assessment_Group__c =:selectedGroupId AND '+assessmentGroupJunctionFieldApi +'!= NULL';

                    List<Assessment_Group_Junction__c> agjList = Database.query(queryStr);
                    if(agjList.size() > 0) {

                        for (Assessment_Group_Junction__c agj : agjList) {
                            IssueRequest_Life_Cycle__c am = new IssueRequest_Life_Cycle__c();
                            am.put('ExAM__InvestigationType__c', selectedTemplateId);
                            am.put(AMApi, agj.get(assessmentGroupJunctionFieldApi));
                            if(userId != null && userId != '') {
                                am.put('ExAM__Assessor_Resource__c',userId);
                            }
                            amList.add(am);
                        }
                        if(amList != null && amList.size() > 0) {
                    
                            insert amList;
                            amMap = new Map<Id, IssueRequest_Life_Cycle__c>( amList );
    
                            if (AMApi.startsWithIgnoreCase('AM_')) {
                                PAObjAssessbleField = AMApi.replaceFirst('AM_','PA_');
                            }
                            for (IssueRequest_Life_Cycle__c am : amMap.Values()) {
                                Public_Assessment__c pa = new Public_Assessment__c();
                                pa.put('ExAM__Assignment_Manager__c',am.Id);
                                pa.put('ExAM__Expiration_Date__c', expDate);
                                paList.add(pa);
                            }
                            if (paList != null && paList.size() > 0) {

                                insert paList;

                                amUpdateList = new List<IssueRequest_Life_Cycle__c>();
                                for (ExAM__Public_Assessment__c pa : [SELECT ExAM__Assignment_Manager__c, ExAM__Expiration_Date__c, ExAM__Public_Assessment_URL__c, Id, Name FROM ExAM__Public_Assessment__c WHERE Id IN :paList]) {
                                    if (amMap.containsKey(pa.ExAM__Assignment_Manager__c) && amMap.get(pa.ExAM__Assignment_Manager__c) != null) {
                                        IssueRequest_Life_Cycle__c am = amMap.get(pa.ExAM__Assignment_Manager__c);
                                        am.ExAM__Public_Assessment_URL__c = pa.ExAM__Public_Assessment_URL__c;
                                        amUpdateList.add( am );
                                    }
                                }
                                update amUpdateList;
                            } 
                            returnRecs.message = 'Success';
                        }  
                    } else {
                        returnRecs.message = 'The given Assessment Group Id does not have assessable records';
                    }

                } else if ( AssessableObjectApi != null && AssessableObjectApi != '') {
                    Integer numberofRecords = 0;
                    if(noofrecords != null && noofrecords != '' && noofrecords.isNumeric()) {
                        numberofRecords = Integer.valueOf(noofrecords);
                    } else {
                        numberofRecords = 1;
                    }

                    if ((assessableRecId == null || assessableRecId == '') && selectedobjectLabel != null && selectedobjectLabel != '') {
                        
                        Boolean isAutonumber = true;  
                        
                        if (!AssessableObjectApi.equalsIgnoreCase('Contact') && !AssessableObjectApi.equalsIgnoreCase('Lead') && !AssessableObjectApi.equalsIgnoreCase('Case')) {
                        
                            Map<string, Schema.SObjectField> fldMap = Schema.getGlobalDescribe().get(AssessableObjectApi).getDescribe().fields.getMap();
                            Schema.DescribeFieldResult desribeResult = fldMap.get('Name').getDescribe();
                            if ( !desribeResult.isNillable() && !desribeResult.isDefaultedOnCreate()) {
                                isAutonumber = false; 
                            }
                        }
                       
                        for (Integer cnt = 1; cnt <= numberofRecords; cnt++) {
                            if (AssessableObjectApi.equalsIgnoreCase('Contact')) {
                                SObject sob = Schema.getGlobalDescribe().get(AssessableObjectApi).newSObject();
                                sob.put('lastname', 'Contact '+System.now()+' - '+ cnt);
                                sobList.add(sob);
                            } else if (AssessableObjectApi.equalsIgnoreCase('Lead')) {
                                SObject sob = Schema.getGlobalDescribe().get(AssessableObjectApi).newSObject();
                                sob.put('lastname', 'Lead '+System.now()+' - '+ cnt);
                                sob.put('Company', 'Company '+System.now()+' - '+ cnt);
                                sobList.add(sob);
                            } else {
                                SObject sob = Schema.getGlobalDescribe().get(AssessableObjectApi).newSObject();
                                if (!isAutonumber) {
                                    sob.put('Name', selectedobjectLabel+' '+System.now()+' - '+ cnt);
                                }
                                sobList.add(sob);
                            }
                        }
                        if (sobList != null && sobList.size() > 0) {
    
                            insert sobList;
    
                            for (Integer i=0; i< sobList.size(); i++) {
                                IssueRequest_Life_Cycle__c am = new IssueRequest_Life_Cycle__c();
                                am.put('ExAM__InvestigationType__c', selectedTemplateId);
                                am.put(AMApi, sobList[i].Id);
                                if(userId != null && userId != '') {
                                    am.put('ExAM__Assessor_Resource__c',userId);
                                }                            
                                amList.add(am);
                            }
                        }
                        if(amList != null && amList.size() > 0) {

                            insert amList;
                            amMap = new Map<Id, IssueRequest_Life_Cycle__c>( amList );
    
                            if (AMApi.startsWithIgnoreCase('AM_')) {
                                PAObjAssessbleField = AMApi.replaceFirst('AM_','PA_');
                            }
                            for (IssueRequest_Life_Cycle__c am : amMap.Values()) {
                                Public_Assessment__c pa = new Public_Assessment__c();
                                pa.put('ExAM__Assignment_Manager__c',am.Id);
                                pa.put('ExAM__Expiration_Date__c', expDate);
                                paList.add(pa);
                            }
                            if (paList != null && paList.size() > 0) {

                                insert paList;

                                amUpdateList = new List<IssueRequest_Life_Cycle__c>();
                                for (ExAM__Public_Assessment__c pa : [SELECT ExAM__Assignment_Manager__c, ExAM__Expiration_Date__c, ExAM__Public_Assessment_URL__c, Id, Name FROM ExAM__Public_Assessment__c WHERE Id IN :paList]) {
                                    if (amMap.containsKey(pa.ExAM__Assignment_Manager__c) && amMap.get(pa.ExAM__Assignment_Manager__c) != null) {
                                        IssueRequest_Life_Cycle__c am = amMap.get(pa.ExAM__Assignment_Manager__c);
                                        am.ExAM__Public_Assessment_URL__c = pa.ExAM__Public_Assessment_URL__c;
                                        amUpdateList.add( am );
                                    }
                                }
                                update amUpdateList;
                            }
                            returnRecs.message = 'Success';                        
                        }   
                    } else {
                        for (integer cnt = 0; cnt < numberofRecords; cnt++) {

                            IssueRequest_Life_Cycle__c am = new IssueRequest_Life_Cycle__c();
                            am.put('ExAM__InvestigationType__c', selectedTemplateId);
                            am.put(AMApi, assessableRecId);
                            if(userId != null && userId != '') {
                                am.put('ExAM__Assessor_Resource__c',userId);
                            }  
                            amList.add(am);
                        }
                        if(amList != null && amList.size() > 0) {
                    
                            insert amList;
                            amMap = new Map<Id, IssueRequest_Life_Cycle__c>( amList );
    
                            if (AMApi.startsWithIgnoreCase('AM_')) {
                                PAObjAssessbleField = AMApi.replaceFirst('AM_','PA_');
                            }
                            for (IssueRequest_Life_Cycle__c am : amMap.Values()) {
                                Public_Assessment__c pa = new Public_Assessment__c();
                                pa.put('ExAM__Assignment_Manager__c',am.Id);
                                pa.put('ExAM__Expiration_Date__c', expDate);
                                paList.add(pa);
                            }
                            if (paList != null && paList.size() > 0) {

                                insert paList;

                                amUpdateList = new List<IssueRequest_Life_Cycle__c>();
                                for (ExAM__Public_Assessment__c pa : [SELECT ExAM__Assignment_Manager__c, ExAM__Expiration_Date__c, ExAM__Public_Assessment_URL__c, Id, Name FROM ExAM__Public_Assessment__c WHERE Id IN :paList]) {
                                    if (amMap.containsKey(pa.ExAM__Assignment_Manager__c) && amMap.get(pa.ExAM__Assignment_Manager__c) != null) {
                                        IssueRequest_Life_Cycle__c am = amMap.get(pa.ExAM__Assignment_Manager__c);
                                        am.ExAM__Public_Assessment_URL__c = pa.ExAM__Public_Assessment_URL__c;
                                        amUpdateList.add( am );
                                    }
                                }
                                update amUpdateList;
                            } 
                            returnRecs.message = 'Success';
                        }   
                    }
                }
            }
            returnRecs.objectList = sobList;
            returnRecs.amList = amUpdateList;
            returnRecs.paList = paList;
        } catch (Exception ex) {
            Database.rollback(sp);
            returnRecs.message = ex.getMessage();
            throw new CustomException(ex.getMessage(), null);
        } 
        return JSON.serialize(returnRecs);
    }
    global class fieldWrapper {
        public string fieldLabel;
        public string fieldApi;
        public Boolean fieldDisplay;
        public string fieldValue;
    }
    public class ReturnPALinksClass {
        public List<SObject> objectList;
        public List<IssueRequest_Life_Cycle__c> amList;
        public List<Public_Assessment__c> paList;
        public string message;
    }
    public class ParamOfPALinksClass {
        public string AMApi;
        public string assessmentGroupJunctionFieldApi;
        public string selectedGroupId;
        public string selectedTemplateId;
        public string noofrecords;
        public string AssessableObjectApi;
        public string selectedobjectLabel;
        public string assessableRecId;
        public string expDate;
        public string userId;
    }
    public class CustomOwnException extends Exception {

    }
}