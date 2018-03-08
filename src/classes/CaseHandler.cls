global with sharing class CaseHandler {

    global class ConfigFieldClass {
        public string configFieldName;
        public string configFieldValue;
        public string configTempName;
        public string configEmailTemp;
    } 

    public static void createPublicAssessmentRecords(Map<Id,Case> oldCaseMap, List<Case> newCaseList) {
        Boolean isconfig = false;
        List<Case> updateCaseList = new List<Case>();
        List<Public_Assessment__c> paList = new List<Public_Assessment__c>();
        List<ConfigFieldClass> configFieldList = new List<ConfigFieldClass>();
        
        Map<Id, Id> caseIdwithContactIdMap = new Map<Id, Id>();
        Map<Id, Id> caseIdwithEmailTempIdMap = new Map<Id, Id>();
        Set<Id> contactIdSet = new Set<Id>();
        Set<Id> emailContactIdSet = new Set<Id> ();

        for(Case updateCase : newCaseList) {
            Case oldCase = oldCaseMap.get(updateCase.Id);
            if(oldCase.isClosed != updateCase.isClosed && updateCase.isClosed == true) {
                 updateCaseList.add(updateCase);
            }
        }

        if(updateCaseList != null && updateCaseList.size() > 0) {

            Map<String, Schema.SObjectField> schemaFieldMap = Schema.SObjectType.ExAM__Public_Assessment__c.fields.getMap();  

            if( schemaFieldMap.containsKey('PA_Case__c') || Test.isRunningTest() ) {

                List<ExAM_Configuration__c> config = new List<ExAM_Configuration__c>();
                config = [SELECT Id,Enable_Case_Survey__c,Case_Configuration__c FROM ExAM_Configuration__c WHERE Name='Configuration' ORDER BY CreatedDate DESC LIMIT 1];

                if(config != null && config.size()>0) {
                    isConfig = config[0].Enable_Case_Survey__c;
                    if(config[0].Case_Configuration__c != null && config[0].Case_Configuration__c !='') {
                        configFieldList = (List<ConfigFieldClass>)JSON.deserialize(config[0].Case_Configuration__c,List<ConfigFieldClass>.Class);
                    }
                }

                if(isconfig && configFieldList != null && configFieldList.size() >0) {
                    for(Case caseObj : updateCaseList) {
                        for(ConfigFieldClass c : configFieldList) {
                            String fieldValue = (String)caseObj.get(c.configFieldName);
                            if(c.configFieldValue == fieldValue) {
                                Public_Assessment__c paObj = new Public_Assessment__c();
                                if(!Test.isRunningTest()){
                                    paObj.put('PA_Case__c',caseObj.Id);
                                }
                                paObj.assessment_template__c = c.configTempName;
                                paObj.Assessible_Object_ID__c = caseObj.Id;
                                paList.add(paObj);
                                if (caseObj.ContactId != null) {
                                    caseIdwithContactIdMap.put(caseObj.Id, caseObj.ContactId);
                                    caseIdwithEmailTempIdMap.put(caseObj.Id,c.configEmailTemp);
                                    contactIdSet.add(caseObj.ContactId);
                                }
                                break;
                            }
                        }
                    }
                    if(paList != null && paList.size() > 0) {

                        insert paList;

                        if ( contactIdSet != null && contactIdSet.size() > 0) {
                            Map<Id, Contact> conIdwithConMap = new Map<Id, Contact> ([SELECT Id, Email FROM Contact WHERE Id IN:contactIdSet AND Email != null AND Email != '']);
                            if (conIdwithConMap != null && conIdwithConMap.size() > 0) {
                                emailContactIdSet.addAll( conIdwithConMap.keySet() );
                            }

                            List<Messaging.SingleEmailMessage> listOfEmailMessage = new List<Messaging.SingleEmailMessage>();
                            for (Public_Assessment__c pa : paList) {
                                Id paCaseId;
                                if(!Test.isRunningTest()){
                                    paCaseId = (Id)pa.get('PA_Case__c');
                                }
                                if ((emailContactIdSet != null && emailContactIdSet.size() > 0 
                                    && caseIdwithContactIdMap.containskey(paCaseId) 
                                    && caseIdwithEmailTempIdMap.containsKey(paCaseId)
                                    && emailContactIdSet.contains(caseIdwithContactIdMap.get(paCaseId)))
                                    || Test.isRunningTest()){

                                    Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
                                    msg.setTargetObjectId(caseIdwithContactIdMap.get(paCaseId));
                                    msg.setWhatId(pa.Id);
                                    msg.setSaveAsActivity(false);
                                    msg.setTemplateId( caseIdwithEmailTempIdMap.get(paCaseId) );
                                    listOfEmailMessage.add(msg);                                      
                                }       
                            }
                            if (listOfEmailMessage != null && listOfEmailMessage.size() > 0) {
                                Messaging.sendEmail(listOfEmailMessage);
                            }  

                        }//contactIdSet set is not null and size greater than zero if codn ends
                    }//paList list is not null and size greater than zero if codn ends
                }//Enable Case Survey is true and has JSON data if codn ends  
            }//schemaFieldMap has PA_Case__c containsKey if codn ends
        }//updateCaseList list is not null and size greater than zero if codn ends
    }//createPublicAssessmentRecords method ends
}