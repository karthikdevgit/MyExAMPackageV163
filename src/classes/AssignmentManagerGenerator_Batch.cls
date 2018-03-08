global class AssignmentManagerGenerator_Batch implements Database.Batchable<sObject>, Database.Stateful {

    public List<IssueRequest_Life_Cycle__c> assignmentManagerList;
    public String assessbleObjAPI;
    public String selectedobjectLabel;
    public String AMApi;
    public String templateId;
    public Integer totalNoOfRecords;
    public String errorMsg = '';
    public Integer noOfRecordProcess = 0;
    public Id assGenObjId;
    public Date expDate;

    global Iterable<SObject> start(Database.BatchableContext BC) { 

        Assignment_Generator_Batch__c assGenObj = new Assignment_Generator_Batch__c();
        assGenObj.Assessment_Template__c = templateId;
        assGenObj.Assessable_Object_Api__c = AMApi;
        insert assGenObj;
        assGenObjId = assGenObj.Id;
        return assignmentManagerList; 
    }     
    
    global void execute(Database.BatchableContext BC, List<IssueRequest_Life_Cycle__c> assManagerList) {

        if(assManagerList != null && assManagerList.size() > 0 && AMApi != null && AMApi != '') {
            
            Savepoint sp = Database.setSavepoint();
            try {
                List<Public_Assessment__c> paList = new List<Public_Assessment__c> ();
                
                if(assessbleObjAPI != null && assessbleObjAPI != '') {
                
                    Integer numberofRecords = assManagerList.size();
                    Boolean isAutonumber = true;                       
                    List<SObject> sobList = new List<SObject>();
                    
                    if (!assessbleObjAPI.equalsIgnoreCase('Contact') && !assessbleObjAPI.equalsIgnoreCase('Lead') && !assessbleObjAPI.equalsIgnoreCase('Case')) {
                    
                        Map<String, Schema.SObjectField> fldMap = Schema.getGlobalDescribe().get(assessbleObjAPI).getDescribe().fields.getMap();
                        Schema.DescribeFieldResult desribeResult = fldMap.get('Name').getDescribe();
                        if ( !desribeResult.isNillable() && !desribeResult.isDefaultedOnCreate()) {
                            isAutonumber = false; 
                        }
                    }
                   
                    for (integer cnt = 1; cnt <= numberofRecords; cnt++) {
                        if (assessbleObjAPI.equalsIgnoreCase('Contact')) {
                            SObject sob = Schema.getGlobalDescribe().get(assessbleObjAPI).newSObject();
                            sob.put('lastname', 'Contact '+System.now()+' - '+ cnt);
                            sobList.add(sob);
                        } else if (assessbleObjAPI.equalsIgnoreCase('Lead')) {
                            SObject sob = Schema.getGlobalDescribe().get(assessbleObjAPI).newSObject();
                            sob.put('lastname', 'Lead '+System.now()+' - '+ cnt);
                            sob.put('Company', 'Company '+System.now()+' - '+ cnt);
                            sobList.add(sob);
                        } else {
                            SObject sob = Schema.getGlobalDescribe().get(assessbleObjAPI).newSObject();
                            if (!isAutonumber) {
                                sob.put('Name', selectedobjectLabel+' '+System.now()+' - '+ cnt);
                            }
                            sobList.add(sob);
                        }
                    }

                    if (sobList != null && sobList.size() > 0) {

                        insert sobList;

                        for (Integer i=0; i< sobList.size(); i++) {
                            assManagerList[i].put(AMApi, sobList[i].Id);
                        }

                        insert assManagerList;
                        String PAObjAssessbleField = AMApi;
                        if (AMApi.startsWithIgnoreCase('AM_')) {
                            PAObjAssessbleField = AMApi.replaceFirst('AM_','PA_');
                        }
                        for (IssueRequest_Life_Cycle__c am :assManagerList) {
                            Public_Assessment__c pa = new Public_Assessment__c();
                            pa.put('ExAM__Assignment_Manager__c',am.Id);
                            /*comment for PA Object creating via AM Only
                            pa.put(PAObjAssessbleField,am.get(AMApi));
                            pa.put('ExAM__Assessible_Object_ID__c',am.get(AMApi));
                            pa.put('ExAM__Assessment_Template__c',am.InvestigationType__c);*/
                            pa.put('ExAM__Assignment_Generator_Batch__c',assGenObjId);
                            pa.put('ExAM__Expiration_Date__c', expDate);
                            paList.add(pa);
                        }
                        if (paList != null && paList.size() > 0) {
                            insert paList;
                        }
                        noOfRecordProcess =  noOfRecordProcess + assManagerList.size();
                    }
                } else {

                    insert assManagerList;

                    String PAObjAssessbleField = AMApi;
                    if (AMApi.startsWithIgnoreCase('AM_')) {
                        PAObjAssessbleField = AMApi.replaceFirst('AM_','PA_');
                    }
                    for (IssueRequest_Life_Cycle__c am :assManagerList) {
                        Public_Assessment__c pa = new Public_Assessment__c();
                        pa.put('ExAM__Assignment_Manager__c',am.Id);
                        /*comment for PA Object creating via AM Only
                        pa.put(PAObjAssessbleField,am.get(AMApi));
                        pa.put('ExAM__Assessible_Object_ID__c',am.get(AMApi));
                        pa.put('ExAM__Assessment_Template__c',am.InvestigationType__c);*/
                        pa.put('ExAM__Assignment_Generator_Batch__c',assGenObjId);
                        pa.put('ExAM__Expiration_Date__c', expDate);
                        paList.add(pa);
                    }
                    if (paList != null && paList.size() > 0) {
                        insert paList;
                        system.debug('Entering11');
                    } 
                    noOfRecordProcess =  noOfRecordProcess + assManagerList.size();
                }
            } catch(exception e) {
            
                System.debug('::error::'+e.getMessage());
                errorMsg = e.getMessage();
                Database.rollback(sp);
            }
            
        }     
    } 
        
    global void finish(Database.BatchableContext BC) {  
    
        String userId = UserInfo.getUserId();
        String htmlBody ='';
        Integer failureNoOfRecords = totalNoOfRecords - noOfRecordProcess;
        
        Assignment_Generator_Batch__c assGenObj = new Assignment_Generator_Batch__c();
        assGenObj.No_Of_Records__c = noOfRecordProcess;
        assGenObj.Id = assGenObjId;
        update assGenObj;
        
        Messaging.singleEmailMessage mail = new Messaging.singleEmailMessage();       
        mail.setTargetObjectId(userId);
        //mail.toAddresses = new List<String>{('arthig@softsquare.biz')};
        mail.setSubject('Assignment Generator Batch Completed');
        mail.setUseSignature(false);
        mail.setBccSender(false);
        mail.setSaveAsActivity(false); 
        system.debug(':::errorMsg:::'+errorMsg);
        if(errorMsg != '') {
            htmlBody = '<b> Inserted Records : </b>'+ noOfRecordProcess +'<br>'
            +'<b> Failure Records : </b>'+ failureNoOfRecords +'<br>'
            +'<b> Error Message : <b>'+errorMsg;
        } else {
           htmlBody ='<b> Inserted Records : </b>'+ noOfRecordProcess +'<br>'
           +'<b> Failure Records : </b>'+ failureNoOfRecords +'<br>'
           +'<b>Generated global Assessment Link : </b><a href="'+System.URL.getSalesforceBaseUrl().toExternalForm()+'/apex/ExAM__publicAssessmentLinkCSV?agId='+assGenObjId+'">Click Here</a>';
        }
        mail.setHtmlBody(htmlBody);
        try{
            Messaging.SendEmailResult[] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail}); 
            if (r[0].isSuccess()) {
                System.debug('The email was sent successfully.');
            } else {
                System.debug('The email failed to send:'+ r[0].getErrors()[0].getMessage());
            } 
        }catch(Exception e){  
            System.debug('The email failed to send:'+ e.getMessage());
        }
    } 
}