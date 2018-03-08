trigger AssignmentManagerCustomLookupValuesPopulateInAnswerObject on Questionnaire_Response__c (before insert, before update, after insert, after update) {
    
    if (Trigger.isBefore) {

        Map <string, Schema.SObjectField> answerFieldNameAPIMap = Schema.SObjectType.Questionnaire_Response__c.fields.getMap();
        Map <String, Schema.SObjectField> assignmentManagerFieldNameAPIMap = Schema.SObjectType.IssueRequest_Life_Cycle__c.fields.getMap();
        try{
            //String namespace = IssueRequest_Life_Cycle__c.SObjectType.getDescribe().getName().removeEndIgnoreCase(IssueRequest_Life_Cycle__c.SObjectType.getDescribe().getLocalName());
            //System.debug('::namespace::'+namespace);
            
            system.debug('::::answerFieldNameAPIMap :::'+answerFieldNameAPIMap );
            system.debug('::::assignmentManagerFieldNameAPIMap :::'+assignmentManagerFieldNameAPIMap );
            
            Map<String,String> assignmentManagerFieldAnswerFieldMap = new Map<String,String>(); 
            assignmentManagerFieldAnswerFieldMap.put('ExAM__Facility_Name__c','ExAM__Account_to_Response__c'); //Account lookup field
            
            for (Schema.SObjectField ansfield : answerFieldNameAPIMap.values()) {
            
                Schema.DescribeFieldResult res = ansfield.getdescribe();
                //if (String.valueOf(res.getType()).touppercase() == 'REFERENCE' && res.isCustom() && res.getName().startsWithIgnoreCase(namespace+'ANS_')) 
                if (String.valueOf(res.getType()).touppercase() == 'REFERENCE' && res.isCustom() && res.getName().startsWithIgnoreCase('ANS_')) {
                
                    String assignmentManagerField = res.getLocalName().replaceFirst('ANS_','AM_');
                    System.debug('::::assignmentManagerField ::::'+assignmentManagerField );
                    if (assignmentManagerFieldNameAPIMap.containsKey(assignmentManagerField.toLowerCase())) {
                        
                        assignmentManagerFieldAnswerFieldMap.put( assignmentManagerFieldNameAPIMap.get(assignmentManagerField.toLowerCase()).getdescribe().getName() , res.getName());
                    } 
                } 
            }
             
            System.debug('::assignmentManagerFieldAnswerFieldMap.keyset():::'+assignmentManagerFieldAnswerFieldMap.keyset());
            
            Map<Id, List<Questionnaire_Response__c>> AMIdWithListofAnswerMap = new Map<Id, List<Questionnaire_Response__c>>();
            
            if ((Trigger.isInsert || Trigger.isUpdate) && assignmentManagerFieldAnswerFieldMap.size() > 0 ) {
            
                for (Questionnaire_Response__c ans : Trigger.New) {
                
                    if( ans.Issue_Request__c != null ) {
                        
                        if (!AMIdWithListofAnswerMap.containskey(ans.Issue_Request__c)) {
                        
                            AMIdWithListofAnswerMap.put(ans.Issue_Request__c, new List<Questionnaire_Response__c>());            
                        }        
                        AMIdWithListofAnswerMap.get(ans.Issue_Request__c).add(ans);
                    }
                }
                
                if (AMIdWithListofAnswerMap.size() > 0 ) {
                    
                    List<String> listStrings = new List<String>(assignmentManagerFieldAnswerFieldMap.keySet());
                    String fieldsStr = String.join(listStrings,',');
                    Set<Id> assignManagerIdSet = new Set<Id>();
                    assignManagerIdSet.addAll(AMIdWithListofAnswerMap.keySet());
                    String queryStr = 'SELECT Id,'+fieldsStr+' FROM IssueRequest_Life_Cycle__c WHERE Id IN :assignManagerIdSet';   
                    
                    System.debug('::queryStr :::'+queryStr );

                    List<IssueRequest_Life_Cycle__c> assignmentManagerList = Database.query(queryStr);
                    System.debug('::assignmentManagerList :::'+assignmentManagerList );
                    
                    Map<id, IssueRequest_Life_Cycle__c> AMIdwithRecordMap = new Map<Id, IssueRequest_Life_Cycle__c>(assignmentManagerList);
                    for(Id amId : AMIdWithListofAnswerMap.keySet()) {
                        
                        List<Questionnaire_Response__c> ansList = AMIdWithListofAnswerMap.get(amId); 
                        for( Questionnaire_Response__c ans : ansList ) {
                            
                            for( String amfieldName : assignmentManagerFieldAnswerFieldMap.keySet() ) {
                                if(AMIdwithRecordMap.size() > 0 && AMIdwithRecordMap.get(amId).get(amfieldName) != null ) {
                                    System.debug('::::assignmentManagerFieldAnswerFieldMap.get(amfieldName):::'+assignmentManagerFieldAnswerFieldMap.get(amfieldName));
                                    ans.put(assignmentManagerFieldAnswerFieldMap.get(amfieldName),AMIdwithRecordMap.get(amId).get(amfieldName));
                                }
                            }
                        }
                    }
                    
                }
            }
        }catch(Exception e){
            throw e;
        }
    }
    if (trigger.isUpdate) {
        // Calculate answer scores and rollup to assignment manager object
        try{
            if (Trigger.isInsert || Trigger.isUpdate) {
                Set<ID> amIdSet = new Set<ID>();
                List<IssueRequest_Life_Cycle__c> updateScoreAssignmentManagerList = new List<IssueRequest_Life_Cycle__c>();
                
                for (Questionnaire_Response__c ans : Trigger.New) {
                
                    if (Trigger.isInsert && ans.Issue_Request__c != null && ans.Weight_Response__c != null) {
                        
                        amIdSet.add(ans.Issue_Request__c); 
                    } else if (Trigger.isUpdate && ( ans.Weight_Response__c != Trigger.oldMap.get(ans.Id).Weight_Response__c || 
                                                     ans.Issue_Request__c != Trigger.oldMap.get(ans.Id).Issue_Request__c )) {
                        amIdSet.add(ans.Issue_Request__c); 
                        amIdSet.add(Trigger.oldMap.get(ans.Id).Issue_Request__c);
                    }
                    system.debug('::::amIdSet::::'+amIdSet);
                }
                if (amIdSet.size() > 0) {
                    Map<Id, Decimal> amIdwithTodalScoreMap = new Map<Id, Decimal>();
                    Map<Id, Decimal> amIdwithMaxScoreMap = new Map<Id, Decimal>();

                    for(Questionnaire_Response__c ans : [SELECT ID, Weight_Response__c, Total_Score__c, Max_Score__c, Issue_Request__c, 
                                                                Question_Template__c, Question_Template__r.Question_Type__c, Issue_Request__r.Status__c  
                                                            FROM Questionnaire_Response__c 
                                                            WHERE Issue_Request__c IN:amIdSet
                                                            AND Weight_Response__c != null 
                                                            AND Weight_Response__c >= 0 
                                                            AND Question_Template__r.Question_Type__c IN ('RadioPicklist','Dropdown Picklist')
                                                            AND Issue_Request__r.Status__c = 'Completed']) {
                        
                        if (!amIdwithTodalScoreMap.containsKey(ans.Issue_Request__c)) {
                            amIdwithTodalScoreMap.put(ans.Issue_Request__c, 0);
                        }
                        if (!amIdwithMaxScoreMap.containsKey(ans.Issue_Request__c)) {
                            amIdwithMaxScoreMap.put(ans.Issue_Request__c, 0);
                        }               
                        amIdwithTodalScoreMap.put(ans.Issue_Request__c, amIdwithTodalScoreMap.get(ans.Issue_Request__c) + ans.Total_Score__c);
                        amIdwithMaxScoreMap.put(ans.Issue_Request__c, amIdwithMaxScoreMap.get(ans.Issue_Request__c) + ans.Max_Score__c);
                    }
                    system.debug('::::amIdwithTodalScoreMap::::'+amIdwithTodalScoreMap);
                    system.debug('::::amIdwithMaxScoreMap::::'+amIdwithMaxScoreMap);
                    
                    for (Id amId : amIdwithTodalScoreMap.KeySet()) {
                        if (amIdwithTodalScoreMap.get(amId) != 0 && amIdwithMaxScoreMap != null && amIdwithMaxScoreMap.containsKey(amId) && amIdwithMaxScoreMap.get(amId) != 0) {
                            IssueRequest_Life_Cycle__c amRec = new IssueRequest_Life_Cycle__c(Id = amId);
                            amRec.Total_Score__c = amIdwithTodalScoreMap.get(amId);
                            amRec.Max_Score__c = amIdwithMaxScoreMap.get(amId);
                            updateScoreAssignmentManagerList.add(amRec);
                            system.debug('::::Answer trigger End update Score::::');
                        }
                    }
                    if (updateScoreAssignmentManagerList.size() > 0) {

                        update updateScoreAssignmentManagerList;
                    }
                }
            }
        }catch(Exception e){
            throw e;
        }
    }
    
}