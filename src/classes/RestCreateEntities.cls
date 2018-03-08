/**
    Rest class to create records for Account, Assignment Manager, Answer and Attachment objects
**/
@RestResource(urlMapping='/CreateAMAndAnswer/*')
global with sharing class RestCreateEntities {

    @HttpPost
    global static ResponseClass createEntities() {

        ResponseClass response;

        Set<string> sObjIdSet = new Set<string>();
        Set<string> acctExternalIdSet = new Set<string>();
        Set<string> amExternalIdSet = new Set<string>();
        Set<string> answerExternalIdSet = new Set<string>();

        List<SObject> sObjListToInsert = new List<SObject>();
        List<SObject> sObjListToUpdate = new List<SObject>();
        List<SObject> sObjWithParentIdList = new List<SObject>();
        List<ExAM__IssueRequest_Life_Cycle__c> amWithRelatedAMsList = new List<ExAM__IssueRequest_Life_Cycle__c>();

        Map<string, SObject> sObjMap = new Map<string, SObject>();
        Map<string, ExAM__IssueRequest_Life_Cycle__c> amMap = new Map<string, ExAM__IssueRequest_Life_Cycle__c>();
        Map<string, ExAM__Questionnaire_Response__c> answerMap = new Map<string, ExAM__Questionnaire_Response__c>();

        Map<string, Account> existingExternalIdAccountMap = new Map<string, Account>();
        Map<string, ExAM__IssueRequest_Life_Cycle__c> existingExternalIdAMMap = new Map<string, ExAM__IssueRequest_Life_Cycle__c>();
        Map<string, ExAM__Questionnaire_Response__c> existingExternalIdAnswerMap = new Map<string, ExAM__Questionnaire_Response__c>();

        Map<string, string> existingAcctIdExternalIdMap = new Map<string, string>();
        Map<string, string> existingAMIdExternalIdMap = new Map<string, string>();
        Map<string, string> existingAnswerIdExternalIdMap = new Map<string, string>();

        Map<string, Id> sObjIdMap = new Map<string, Id>();
        Map<string, string> sObjExternalIdMap = new Map<string, string>();
        Map<string, Id> amIdMap = new Map<string, Id>();
        Map<string, Id> answerIdMap = new Map<string, Id>();

        Map<string, string> externalIdWithRAM1ExternalIdMap = new Map<string, string>();
        Map<string, string> externalIdWithRAM2ExternalIdMap = new Map<string, string>();
        Map<string, string> externalIdWithRAM3ExternalIdMap = new Map<string, string>();
        Map<string, string> externalIdWithRAM4ExternalIdMap = new Map<string, string>();

        Map<string, Schema.SObjectType> sObjSchemaMap = Schema.getGlobalDescribe();
        Map<string, Schema.SObjectField> sObjFieldsMap;
        Map<string, Schema.SObjectField> amFieldsMap = ExAM__IssueRequest_Life_Cycle__c.sObjectType.getDescribe().fields.getMap();
        Map<string, Schema.SObjectField> answerFieldsMap = ExAM__Questionnaire_Response__c.sObjectType.getDescribe().fields.getMap();

        //Below message will be displayed only when record creation does not happens successfully
        //due to missing of required fields in Account, Assignment Manager or Answer object
        response = new ResponseClass(404, 'ERROR', 'Something went wrong when processing JSON Request', sObjIdMap, amIdMap, answerIdMap);

        Savepoint sp = Database.setSavepoint();

        try {

            string jsoninput = RestContext.request.requestBody.tostring();
            if (jsoninput != null && jsoninput != '') {

                UserDataInput usrInput = (UserDataInput)Json.deserialize(jsoninput, UserDataInput.class);
                system.debug('<<<<usrInput>>>>'+usrInput);

                if (usrInput != null) {

                    AssessableObjectDetails objDtl = usrInput.objDetails;
                    if (usrInput.objDetails != null) {

                        List<string> objFieldsList = objDtl.fields;
                        List<List<string>> objRecordsList = objDtl.data;

                        for (List<string> eachObj : objRecordsList) {
                            for (Integer i=0; i<eachObj.size(); i++) {
                                if (objFieldsList[i] == 'externalId') {
                                    if( string.isNotBlank(usrInput.uniquePrefix) && !eachObj[i].containsIgnoreCase(usrInput.uniquePrefix)) {
                                        acctExternalIdSet.add( usrInput.uniquePrefix+'-'+eachObj[i] );
                                    }
                                    else {
                                        acctExternalIdSet.add( eachObj[i] );
                                    }
                                }
                            }
                        }

                        for(Account acct : [SELECT ExAM__Account_External_Id__c, Id, Name FROM Account WHERE ExAM__Account_External_Id__c IN :acctExternalIdSet]) {
                            existingExternalIdAccountMap.put(acct.ExAM__Account_External_Id__c, acct);
                            existingAcctIdExternalIdMap.put(acct.Id, acct.ExAM__Account_External_Id__c);
                        }

                        for (List<string> eachObj : objRecordsList) {

                            string sObjExternalId = '';
                            string parentExtId = '';
                            SObject sObj;
                            for (Integer i=0; i<eachObj.size(); i++) {
                                if (eachObj[i] != null && eachObj[i] != '') {
                                    if (objFieldsList[i] == 'objName') {
                                        if (sObjSchemaMap.containsKey(eachObj[i]) != null && sObjSchemaMap.get(eachObj[i]) != null) {
                                            sObjFieldsMap = sObjSchemaMap.get(eachObj[i]).getDescribe().fields.getMap();
                                            sObj = sObjSchemaMap.get(eachObj[i]).newSObject();
                                        }
                                    }
                                    else if (objFieldsList[i] == 'name') {
                                        sObj.put('Name', eachObj[i]);
                                    }
                                    else if (objFieldsList[i] == 'externalId') {

                                        if (objDtl.saveExternalIds == 1) {
                                            if( string.isNotBlank(usrInput.uniquePrefix) && !eachObj[i].containsIgnoreCase(usrInput.uniquePrefix)) {
                                                sObjExternalId = usrInput.uniquePrefix+'-'+eachObj[i];
                                                sObj.put('ExAM__Account_External_Id__c', sObjExternalId);
                                            }
                                            else {
                                                sObjExternalId = eachObj[i];
                                                sObj.put('ExAM__Account_External_Id__c', sObjExternalId);
                                            }
                                        }
                                    }
                                    else if (objFieldsList[i] == 'salesforceId') {
                                        sObj.put('Id', eachObj[i]);
                                        sObjExternalId = eachObj[i];
                                    }
                                    else if (objFieldsList[i] == 'parentExtId') {
                                        if( string.isNotBlank(usrInput.uniquePrefix) && !eachObj[i].containsIgnoreCase(usrInput.uniquePrefix)) {
                                            parentExtId = usrInput.uniquePrefix+'-'+eachObj[i];
                                        }
                                        else {
                                            parentExtId = eachObj[i];
                                        }
                                    }
                                    else if (objFieldsList[i] == 'parentSfId') {
                                        sObj.put('ParentId', eachObj[i]);
                                    }
                                    else if (sObjFieldsMap.containsKey(objFieldsList[i]) && sObjFieldsMap.get(objFieldsList[i]) != null) {

                                        Schema.DescribeFieldResult acctFieldDescribeResult = sObjFieldsMap.get(objFieldsList[i]).getDescribe();
                                        if (Schema.DisplayType.DATETIME == acctFieldDescribeResult.getType()) {
                                            DateTime dateTimeValue = DateTime.valueOfGMT( eachObj[i] );
                                            sObj.put(objFieldsList[i], dateTimeValue);
                                        }
                                        else if (Schema.DisplayType.DATE == acctFieldDescribeResult.getType()) {
                                            Date dateValue = Date.valueOf( eachObj[i] );
                                            sObj.put(objFieldsList[i], dateValue);
                                        }
                                        else if (Schema.DisplayType.BOOLEAN == acctFieldDescribeResult.getType()) {
                                            sObj.put(objFieldsList[i], Boolean.valueOf(eachObj[i]));
                                        }
                                        else if ((Schema.DisplayType.CURRENCY == acctFieldDescribeResult.getType())
                                            || (Schema.DisplayType.DOUBLE == acctFieldDescribeResult.getType())
                                            || (Schema.DisplayType.INTEGER == acctFieldDescribeResult.getType()) ) {

                                            Integer numberValue = Integer.valueOf( eachObj[i] );
                                            sObj.put(objFieldsList[i], numberValue);
                                        }
                                        else {
                                            sObj.put(objFieldsList[i], eachObj[i]);
                                        }
                                    }
                                }
                            }
                            if ( string.isNotBlank(sObjExternalId) &&  string.isNotBlank(parentExtId) ) {
                                sObjExternalIdMap.put(sObjExternalId, parentExtId);
                            }
                            if ( string.isNotBlank(sObjExternalId)) {
                                sObjMap.put(sObjExternalId, sObj);
                            }
                            if (string.isNotBlank(sObjExternalId)
                                 && existingExternalIdAccountMap.containsKey(sObjExternalId)
                                 && existingExternalIdAccountMap.get(sObjExternalId) != null ) {

                                 sObj.put( 'Id', existingExternalIdAccountMap.get(sObjExternalId).Id );
                            }
                            if ( (sObj.get('Id') == null || sObj.get('Id') == '') ) {
                                string recExtId = (string)sObj.get('ExAM__Account_External_Id__c');
                                if (!sObjIdSet.contains(recExtId)) {
                                    sObjIdSet.add(recExtId);
                                    sObjListToInsert.add( sObj );
                                }
                            }
                            else {
                                string recId = (string)sObj.get('Id');
                                if (!sObjIdSet.contains(recId)) {
                                    sObjIdSet.add(recId);
                                    sObjListToUpdate.add( sObj );
                                }
                            }
                        }
                        if (!sObjMap.isEmpty()) {

                            if (sObjListToInsert != null && sObjListToInsert.size() > 0) {
                                insert sObjListToInsert;
                            }
                            else if (sObjListToUpdate != null && sObjListToUpdate.size() > 0) {
                                update sObjListToUpdate;
                            }

                            for(string externalId : sObjMap.keySet()) {
                                Id recId = sObjMap.get(externalId).Id;
                                if (existingAcctIdExternalIdMap.containsKey(externalId)
                                    && existingAcctIdExternalIdMap.get(externalId) != null) {

                                    sObjIdMap.put(existingAcctIdExternalIdMap.get(externalId), recId);
                                }
                                else {
                                    sObjIdMap.put(externalId, recId);
                                }
                            }

                            for (string externalId : sObjIdMap.keySet()) {

                                Id recId = sObjIdMap.get(externalId);
                                String sObjName = recId.getSObjectType().getDescribe().getName();

                                if (sObjSchemaMap.containsKey(sObjName) && sObjSchemaMap.get(sObjName) != null) {

                                    SObject sObj = sObjSchemaMap.get(sObjName).newSobject();
                                    sObj.put('Id', recId);
                                    if (sObjExternalIdMap.containsKey(externalId)
                                        && sObjExternalIdMap.get(externalId) != null
                                        && sObjExternalIdMap.get(externalId) != ''
                                    ) {

                                        string parentExtId = sObjExternalIdMap.get(externalId);
                                        if (sObjIdMap.containsKey(parentExtId) && sObjIdMap.get(parentExtId) != null) {

                                            Id parentRecordId = sObjIdMap.get(parentExtId);
                                            sObj.put('ParentId', parentRecordId);
                                            sObjWithParentIdList.add( sObj );
                                        }
                                    }
                                }
                            }
                            if (sObjWithParentIdList != null && sObjWithParentIdList.size() > 0) {
                                update sObjWithParentIdList;
                            }
                        }
                    }
                    AssignmentManagerDetails amDtl = usrInput.amDetails;
                    if (amDtl != null) {

                        List<string> amFieldsList = amDtl.fields;
                        List<List<string>> amRecordsList = amDtl.data;

                        for (List<string> eachAM : amRecordsList) {
                            for (Integer i=0; i<eachAM.size(); i++) {
                                if (amFieldsList[i] == 'externalId') {
                                    if( string.isNotBlank(usrInput.uniquePrefix) && !eachAM[i].containsIgnoreCase(usrInput.uniquePrefix)) {
                                        amExternalIdSet.add( usrInput.uniquePrefix+'-'+eachAM[i] );
                                    }
                                    else {
                                        amExternalIdSet.add( eachAM[i] );
                                    }
                                }
                            }
                        }

                        for(ExAM__IssueRequest_Life_Cycle__c am : [SELECT ExAM__Assignment_External_Id__c, ExAM__Facility_Name__c, Id, Name FROM ExAM__IssueRequest_Life_Cycle__c WHERE ExAM__Assignment_External_Id__c IN :amExternalIdSet]) {
                            existingExternalIdAMMap.put(am.ExAM__Assignment_External_Id__c, am);
                            existingAMIdExternalIdMap.put(am.Id, am.ExAM__Assignment_External_Id__c);
                        }

                        for (List<string> eachAM : amRecordsList) {

                            string amExternalId = '';
                            string relatedAM1ExtId = '';
                            string relatedAM2ExtId = '';
                            string relatedAM3ExtId = '';
                            string relatedAM4ExtId = '';
                            ExAM__IssueRequest_Life_Cycle__c am = new ExAM__IssueRequest_Life_Cycle__c();

                            for (Integer i=0; i<eachAM.size(); i++) {

                                if (eachAM[i] != null && eachAM[i] != '') {
                                    if (amFieldsList[i] == 'assessmentTemplateId') {
                                        am.put('ExAM__InvestigationType__c', eachAM[i]);
                                    }
                                    else if (amFieldsList[i] == 'parentObjSfId') {
                                        am.put('ExAM__Facility_Name__c', eachAM[i]);
                                    }
                                    else if (amFieldsList[i] == 'parentObjExtId') {
                                        if (sObjMap.containsKey(eachAM[i]) && sObjMap.get(eachAM[i]) != null) {
                                            am.put('ExAM__Facility_Name__c', sObjMap.get(eachAM[i]).Id);
                                        }
                                        else if (existingExternalIdAccountMap.containsKey(eachAM[i]) && existingExternalIdAccountMap.get(eachAM[i]) != null) {
                                            am.put('ExAM__Facility_Name__c', existingExternalIdAccountMap.get(eachAM[i]).Id);
                                        }
                                    }
                                    else if (amFieldsList[i] == 'overallStatus') {
                                        am.put('ExAM__Status__c', eachAM[i]);
                                    }
                                    else if (amFieldsList[i] == 'scheduledStartDate') {
                                        DateTime schStrDateTime = DateTime.valueOfGMT( eachAM[i] );
                                        am.put('ExAM__Scheduled_Start_Date__c', schStrDateTime);
                                    }
                                    else if (amFieldsList[i] == 'scheduledEndDate') {
                                        DateTime schEndDateTime = DateTime.valueOfGMT( eachAM[i] );
                                        am.put('ExAM__Scheduled_End_Date__c', schEndDateTime);
                                    }
                                    else if (amFieldsList[i] == 'externalId') {

                                        if (amDtl.saveExternalIds == 1) {
                                            if( string.isNotBlank(usrInput.uniquePrefix) && !eachAM[i].containsIgnoreCase(usrInput.uniquePrefix)) {
                                                amExternalId = usrInput.uniquePrefix+'-'+eachAM[i];
                                                am.put('ExAM__Assignment_External_Id__c', amExternalId);
                                            }
                                            else {
                                                amExternalId = eachAM[i];
                                                am.put('ExAM__Assignment_External_Id__c', amExternalId);
                                            }
                                        }
                                    }
                                    else if (amFieldsList[i] == 'salesforceId') {
                                        am.put('Id', eachAM[i]);
                                        amExternalId = eachAM[i];
                                    }
                                    else if (amFieldsList[i] == 'relatedAM1ExtId') {
                                        if( string.isNotBlank(usrInput.uniquePrefix) && !eachAM[i].containsIgnoreCase(usrInput.uniquePrefix)) {
                                            relatedAM1ExtId = usrInput.uniquePrefix+'-'+eachAM[i];
                                        }
                                        else {
                                            relatedAM1ExtId = eachAM[i];
                                        }
                                    }
                                    else if (amFieldsList[i] == 'relatedAM1SfId') {
                                        am.put('ExAM__Related_Assignment_Manager1__c', eachAM[i]);
                                    }
                                    else if (amFieldsList[i] == 'relatedAM2ExtId') {
                                        if( string.isNotBlank(usrInput.uniquePrefix) && !eachAM[i].containsIgnoreCase(usrInput.uniquePrefix)) {
                                            relatedAM2ExtId = usrInput.uniquePrefix+'-'+eachAM[i];
                                        }
                                        else {
                                            relatedAM2ExtId = eachAM[i];
                                        }
                                    }
                                    else if (amFieldsList[i] == 'relatedAM2SfId') {
                                        am.put('ExAM__Related_Assignment_Manager2__c', eachAM[i]);
                                    }
                                    else if (amFieldsList[i] == 'relatedAM3ExtId') {
                                        if( string.isNotBlank(usrInput.uniquePrefix) && !eachAM[i].containsIgnoreCase(usrInput.uniquePrefix)) {
                                            relatedAM3ExtId = usrInput.uniquePrefix+'-'+eachAM[i];
                                        }
                                        else {
                                            relatedAM3ExtId = eachAM[i];
                                        }
                                    }
                                    else if (amFieldsList[i] == 'relatedAM3SfId') {
                                        am.put('ExAM__Related_Assignment_Manager3__c', eachAM[i]);
                                    }
                                    else if (amFieldsList[i] == 'relatedAM4ExtId') {
                                        if( string.isNotBlank(usrInput.uniquePrefix) && !eachAM[i].containsIgnoreCase(usrInput.uniquePrefix)) {
                                            relatedAM4ExtId = usrInput.uniquePrefix+'-'+eachAM[i];
                                        }
                                        else {
                                            relatedAM4ExtId = eachAM[i];
                                        }
                                    }
                                    else if (amFieldsList[i] == 'relatedAM4SfId') {
                                        am.put('ExAM__Related_Assignment_Manager4__c', eachAM[i]);
                                    }
                                    else if (amFieldsMap.containsKey(amFieldsList[i]) && amFieldsMap.get(amFieldsList[i]) != null) {

                                        Schema.DescribeFieldResult amFieldDescribeResult = amFieldsMap.get(amFieldsList[i]).getDescribe();
                                        if (Schema.DisplayType.DATETIME == amFieldDescribeResult.getType()) {
                                            DateTime dateTimeValue = DateTime.valueOfGMT( eachAM[i] );
                                            am.put(amFieldsList[i], dateTimeValue);
                                        }
                                        else if (Schema.DisplayType.DATE == amFieldDescribeResult.getType()) {
                                            Date dateValue = Date.valueOf( eachAM[i] );
                                            am.put(amFieldsList[i], dateValue);
                                        }
                                        else if (Schema.DisplayType.BOOLEAN == amFieldDescribeResult.getType()) {
                                            am.put(amFieldsList[i], Boolean.valueOf(eachAM[i]));
                                        }
                                        else if ((Schema.DisplayType.CURRENCY == amFieldDescribeResult.getType())
                                            || (Schema.DisplayType.DOUBLE == amFieldDescribeResult.getType())
                                            || (Schema.DisplayType.INTEGER == amFieldDescribeResult.getType())
                                        ) {

                                            Integer numberValue = Integer.valueOf( eachAM[i] );
                                            am.put(amFieldsList[i], numberValue);
                                        }
                                        else {
                                            am.put(amFieldsList[i], eachAM[i]);
                                        }
                                    }
                                }
                            }
                            if (string.isNotBlank(amExternalId) ) {

                                if (existingExternalIdAMMap.containsKey(amExternalId) && existingExternalIdAMMap.get(amExternalId) != null ) {
                                     am.put( 'Id', existingExternalIdAMMap.get(amExternalId).Id );
                                }

                                amMap.put(amExternalId, am);

                                if (string.isNotBlank(relatedAM1ExtId)) {
                                    externalIdWithRAM1ExternalIdMap.put(amExternalId, relatedAM1ExtId);
                                }
                                if (string.isNotBlank(relatedAM2ExtId)) {
                                    externalIdWithRAM2ExternalIdMap.put(amExternalId, relatedAM2ExtId);
                                }
                                if (string.isNotBlank(relatedAM3ExtId)) {
                                    externalIdWithRAM3ExternalIdMap.put(amExternalId, relatedAM3ExtId);
                                }
                                if (string.isNotBlank(relatedAM4ExtId)) {
                                    externalIdWithRAM4ExternalIdMap.put(amExternalId, relatedAM4ExtId);
                                }
                            }
                        }
                        if (!amMap.isEmpty()) {

                            upsert amMap.values();

                            for(string externalId : amMap.keySet()) {
                                Id amId = amMap.get(externalId).Id;
                                if (existingAMIdExternalIdMap.containsKey(externalId)
                                    && existingAMIdExternalIdMap.get(externalId) != null) {

                                    amIdMap.put(existingAMIdExternalIdMap.get(externalId), amId);
                                }
                                else {
                                    amIdMap.put(externalId, amId);
                                }
                            }

                            for(string externalId : amMap.keySet()) {

                                ExAM__IssueRequest_Life_Cycle__c am = new ExAM__IssueRequest_Life_Cycle__c();
                                am.Id = amMap.get(externalId).Id;
                                if (externalIdWithRAM1ExternalIdMap.containsKey(externalId) && externalIdWithRAM1ExternalIdMap.get(externalId) != null) {
                                    string ram1ExternalId = externalIdWithRAM1ExternalIdMap.get(externalId);
                                    if (amIdMap.containsKey(ram1ExternalId) && amIdMap.get(ram1ExternalId) != null) {
                                        am.ExAM__Related_Assignment_Manager1__c = amIdMap.get(ram1ExternalId);
                                    }
                                }
                                if (externalIdWithRAM2ExternalIdMap.containsKey(externalId) && externalIdWithRAM2ExternalIdMap.get(externalId) != null) {
                                    string ram2ExternalId = externalIdWithRAM2ExternalIdMap.get(externalId);
                                    if (amIdMap.containsKey(ram2ExternalId) && amIdMap.get(ram2ExternalId) != null) {
                                        am.ExAM__Related_Assignment_Manager2__c = amIdMap.get(ram2ExternalId);
                                    }
                                }
                                if (externalIdWithRAM3ExternalIdMap.containsKey(externalId) && externalIdWithRAM3ExternalIdMap.get(externalId) != null) {
                                    string ram3ExternalId = externalIdWithRAM3ExternalIdMap.get(externalId);
                                    if (amIdMap.containsKey(ram3ExternalId) && amIdMap.get(ram3ExternalId) != null) {
                                        am.ExAM__Related_Assignment_Manager3__c = amIdMap.get(ram3ExternalId);
                                    }
                                }
                                if (externalIdWithRAM4ExternalIdMap.containsKey(externalId) && externalIdWithRAM4ExternalIdMap.get(externalId) != null) {
                                    string ram4ExternalId = externalIdWithRAM4ExternalIdMap.get(externalId);
                                    if (amIdMap.containsKey(ram4ExternalId) && amIdMap.get(ram4ExternalId) != null) {
                                        am.ExAM__Related_Assignment_Manager4__c = amIdMap.get(ram4ExternalId);
                                    }
                                }
                                amWithRelatedAMsList.add( am );
                            }
                            if (amWithRelatedAMsList != null && amWithRelatedAMsList.size() > 0) {
                                update amWithRelatedAMsList;
                            }
                        }
                    }
                    AnswerDetails answerDtl = usrInput.answerDetails;
                    if (answerDtl != null) {

                        List<string> answerFieldsList = answerDtl.fields;
                        List<List<string>> answerRecordsList = answerDtl.data;

                        for (List<string> eachAnswer : answerRecordsList) {
                            for (Integer i=0; i<eachAnswer.size(); i++) {
                                if (answerFieldsList[i] == 'externalId') {
                                    if( string.isNotBlank(usrInput.uniquePrefix) && !eachAnswer[i].containsIgnoreCase(usrInput.uniquePrefix)) {
                                        answerExternalIdSet.add( usrInput.uniquePrefix+'-'+eachAnswer[i] );
                                    }
                                    else {
                                        answerExternalIdSet.add( eachAnswer[i] );
                                    }
                                }
                            }
                        }

                        for(ExAM__Questionnaire_Response__c ans : [SELECT ExAM__Answer_External_Id__c, Id, Name FROM ExAM__Questionnaire_Response__c WHERE ExAM__Answer_External_Id__c IN :answerExternalIdSet]) {
                            existingExternalIdAnswerMap.put(ans.ExAM__Answer_External_Id__c, ans);
                            existingAnswerIdExternalIdMap.put(ans.Id, ans.ExAM__Answer_External_Id__c);
                        }

                        for (List<string> eachAnswer : answerRecordsList) {

                            string ansExternalId = '';
                            ExAM__Questionnaire_Response__c answer = new ExAM__Questionnaire_Response__c();

                            for (Integer i=0; i<eachAnswer.size(); i++) {

                                if (eachAnswer[i] != null && eachAnswer[i] != '') {

                                    if (answerFieldsList[i] == 'response') {
                                        answer.put('ExAM__Response__c', eachAnswer[i]);
                                    }
                                    else if (answerFieldsList[i] == 'questionTemplateId') {
                                        answer.put('ExAM__Question_Template__c', eachAnswer[i]);
                                    }
                                    else if (answerFieldsList[i] == 'amExtId') {
                                        string amExtIdTemp = '';
                                        if( string.isNotBlank(usrInput.uniquePrefix) && !eachAnswer[i].containsIgnoreCase(usrInput.uniquePrefix)) {
                                            amExtIdTemp = usrInput.uniquePrefix+'-'+eachAnswer[i];
                                        }
                                        else {
                                            amExtIdTemp = eachAnswer[i];
                                        }                                        
                                        if (amMap.containsKey(amExtIdTemp) && amMap.get(amExtIdTemp) != null) {
                                            answer.put('ExAM__Issue_Request__c', amMap.get(amExtIdTemp).Id);
                                            answer.put('ExAM__Account_to_Response__c', amMap.get(amExtIdTemp).ExAM__Facility_Name__c);
                                        }
                                        else if (existingExternalIdAMMap.containsKey(amExtIdTemp) && existingExternalIdAMMap.get(amExtIdTemp) != null) {
                                            answer.put('ExAM__Issue_Request__c', existingExternalIdAMMap.get(amExtIdTemp).Id);
                                            answer.put('ExAM__Account_to_Response__c', existingExternalIdAMMap.get(amExtIdTemp).ExAM__Facility_Name__c);
                                        }
                                    }
                                    else if (answerFieldsList[i] == 'amSfId') {
                                        answer.put('ExAM__Issue_Request__c', eachAnswer[i]);
                                    }
                                    else if (answerFieldsList[i] == 'externalId') {

                                        if (answerDtl.saveExternalIds == 1) {
                                            if( string.isNotBlank(usrInput.uniquePrefix) && !eachAnswer[i].containsIgnoreCase(usrInput.uniquePrefix)) {
                                                ansExternalId = usrInput.uniquePrefix+'-'+eachAnswer[i];
                                                answer.put('ExAM__Answer_External_Id__c', ansExternalId);
                                            }
                                            else {
                                                ansExternalId = eachAnswer[i];
                                                answer.put('ExAM__Answer_External_Id__c', ansExternalId);
                                            }
                                        }
                                    }
                                    else if (answerFieldsList[i] == 'salesforceId') {
                                        answer.put('Id', eachAnswer[i]);
                                        ansExternalId = eachAnswer[i];
                                    }
                                    else if (answerFieldsList[i] == 'comments') {
                                        answer.put('ExAM__Comment__c', eachAnswer[i]);
                                    }
                                    else if (answerFieldsList[i] == 'priority') {
                                        answer.put('ExAM__Priority__c', eachAnswer[i]);
                                    }
                                    else if (answerFieldsMap.containsKey(answerFieldsList[i]) && answerFieldsMap.get(answerFieldsList[i]) != null) {

                                        Schema.DescribeFieldResult answerFieldDescribeResult = answerFieldsMap.get(answerFieldsList[i]).getDescribe();
                                        if (Schema.DisplayType.DATETIME == answerFieldDescribeResult.getType()) {
                                            DateTime dateTimeValue = DateTime.valueOfGMT( eachAnswer[i] );
                                            answer.put(answerFieldsList[i], dateTimeValue);
                                        }
                                        else if (Schema.DisplayType.DATE == answerFieldDescribeResult.getType()) {
                                            Date dateValue = Date.valueOf( eachAnswer[i] );
                                            answer.put(answerFieldsList[i], dateValue);
                                        }
                                        else if (Schema.DisplayType.BOOLEAN == answerFieldDescribeResult.getType()) {
                                            answer.put(answerFieldsList[i], Boolean.valueOf(eachAnswer[i]));
                                        }
                                        else if ((Schema.DisplayType.CURRENCY == answerFieldDescribeResult.getType())
                                            || (Schema.DisplayType.DOUBLE == answerFieldDescribeResult.getType())
                                            || (Schema.DisplayType.INTEGER == answerFieldDescribeResult.getType()) ) {

                                            Integer numberValue = Integer.valueOf( eachAnswer[i] );
                                            answer.put(answerFieldsList[i], numberValue);
                                        }
                                        else {
                                            answer.put(answerFieldsList[i], eachAnswer[i]);
                                        }
                                    }
                                }
                            }
                            if (string.isNotBlank(ansExternalId) ) {
                                if (existingExternalIdAnswerMap.containsKey(ansExternalId) && existingExternalIdAnswerMap.get(ansExternalId) != null ) {
                                     answer.put( 'Id', existingExternalIdAnswerMap.get(ansExternalId).Id );
                                }
                                answerMap.put(ansExternalId, answer);
                            }
                        }
                        if (!answerMap.isEmpty()) {

                            upsert answerMap.values();

                            for(string externalId : answerMap.keySet()) {
                                Id answerId = answerMap.get(externalId).Id;
                                if (existingAnswerIdExternalIdMap.containsKey(externalId)
                                    && existingAnswerIdExternalIdMap.get(externalId) != null) {

                                    answerIdMap.put(existingAnswerIdExternalIdMap.get(externalId), answerId);
                                }
                                else {
                                    answerIdMap.put(externalId, answerId);
                                }
                            }
                        }
                    }
                    if (
                        (sObjIdMap != null && sObjIdMap.size() > 0)
                        || (amIdMap != null && amIdMap.size() > 0)
                        || (answerIdMap != null && answerIdMap.size() > 0)
                    ) {
                        response = new ResponseClass(200, 'SUCCESS', 'Records saved successfully', sObjIdMap, amIdMap, answerIdMap);
                    }
                }
            }
        }
        catch(DmlException dmlExp) {
            string exceptionMsg = 'Exception occured at line number <'+dmlExp.getLineNumber();
            exceptionMsg += '> with Exception Message as <'+dmlExp.getDmlMessage(0);
            exceptionMsg += '> and Exception Stack Trace is <'+dmlExp.getStackTracestring()+'>'; 
            response = new ResponseClass(400, dmlExp.getTypeName(), exceptionMsg, sObjIdMap, amIdMap, answerIdMap);
            Database.rollback(sp);
        }
        catch(Exception exp) {
            string exceptionMsg = 'Exception occured at line number <'+exp.getLineNumber();
            exceptionMsg += '> with Exception Message as <'+exp.getMessage();
            exceptionMsg += '> and Exception Stack Trace is <'+exp.getStackTracestring()+'>'; 
            response = new ResponseClass(400, exp.getTypeName(), exceptionMsg, sObjIdMap, amIdMap, answerIdMap);
            Database.rollback(sp);
        }
        return response;
    }

    global class UserDataInput {
        global string uniquePrefix;
        global AssessableObjectDetails objDetails;
        global AssignmentManagerDetails amDetails;
        global AnswerDetails answerDetails;
    }
    global class AssessableObjectDetails {
        global Integer saveExternalIds;
        global List<string> fields;
        global List<List<string>> data;
    }
    global class AssignmentManagerDetails {
        global Integer saveExternalIds;
        global List<string> fields;
        global List<List<string>> data;
    }
    global class AnswerDetails {
        global Integer saveExternalIds;
        global List<string> fields;
        global List<List<string>> data;
    }
    global class ResponseClass {
        global Integer code;
        global string status;
        global string message;
        global Map<string, Id> sObjIdMap;
        global Map<string, Id> amIdMap;
        global Map<string, Id> answerIdMap;

        global ResponseClass(Integer code, string status, string message, Map<string, Id> sObjMap, Map<string, Id> amMap, Map<string, Id> answerMap) {
            this.code = code;
            this.status = status;
            this.message = message;
            this.sObjIdMap = sObjMap;
            this.amIdMap = amMap;
            this.answerIdMap = answerMap;
        }
    }
}