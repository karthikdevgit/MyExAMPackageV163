/**
    Batch class to send email to Contact/Lead/User based on which target record ids populated in Distribution record
    This batch class is called from SendDistributionScheduler with batch size equals 75.
    This batch class uses renderStoredEmailTemplate method in Messaging class to send email to User
    and each call to this method counts toward the SOQL governor limit as one query.
    So we explicitly set batch size as 75 to avoid hitting Too many SOQL queries exception. 
    So always set the batch size as 75 if this is batch class is invoked from any other component. 
**/
public class SendDistributionBatch implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts {
    
    public Distribution__c distribution;
    String errormessage = '';
    Boolean emailLimitMayExceed = false;
    Boolean sendEmailToUsers = false;
    
    public Iterable<SObject> start(Database.BatchableContext BC) {
        
        Boolean isRunFirstTime = true;
        List<SObject> sObjList = new List<SObject>();

        try {

            if( distribution != null && distribution.Target_Object_Ids__c != null && distribution.Target_Object_Ids__c != '') {

                List<Id> targetRecordIds = new List<Id>();
                targetRecordIds = distribution.Target_Object_Ids__c.split(',');

                for (Id recId : targetRecordIds) {

                    string objectApiName = recId.getSObjectType().getDescribe().getName();
                    if (objectApiName == 'User' && isRunFirstTime) {
                        sendEmailToUsers = true;
                        isRunFirstTime = false;
                    }
                    SObject sobj = Schema.getGlobalDescribe().get(objectApiName).newSObject();        
                    sobj.put('Id', recId);
                    sObjList.add( sobj );
                }
                
                if(sObjList.size() > 0) {

                    if((sendEmailToUsers == false)) {

                        ExAMUtilClass.LimitClass emailLimit = new ExAMUtilClass.LimitClass();
                        emailLimit = ExAMUtilClass.getDailyEmailLimit(); 
                        if(emailLimit != null && emailLimit.remaining != null && (emailLimit.remaining < sObjList.size())) {

                            errormessage = 'Email Limit Exceeded';
                            emailLimitMayExceed = true;
                            sObjList.clear();
                        }
                    }
                }
            }                
        } catch(Exception exp) {
            System.debug('un handled exception::::'+exp);
            errormessage = exp.getMessage();
            sObjList.clear();
        } 
        return sObjList;
    }

    public void execute(Database.BatchableContext BC, List<SObject> sObjList) {

        try {

            if(sObjList.size() > 0) {

                Id paRecId = distribution.Public_Assessments__r[0].Id;
                List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();

                for(SObject sObj : sObjList) {

                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();       
                    mail.setTargetObjectId( sObj.Id );
                    mail.setSaveAsActivity( false ); 

                    //Set whatId and templateId only when target object is Contact or Lead
                    if (sendEmailToUsers == false) {

                        mail.setWhatId( paRecId );
                        mail.setTemplateId( distribution.Email_Template__c );
                    }
                    else {

                        Messaging.SingleEmailMessage sem = Messaging.renderStoredEmailTemplate(distribution.Email_Template__c, sObj.Id, paRecId);
                        system.debug(':::sem::::'+sem);
                        mail.setSubject( sem.getSubject() );
                        if (sem.getPlainTextBody() != null && sem.getPlainTextBody() != '') {
                            mail.setPlainTextBody( sem.getPlainTextBody() );
                        }else if (sem.getHtmlBody() != null && sem.getHtmlBody() != '') {
                            mail.setHtmlBody( sem.getHtmlBody() );
                        }
                    }
                    system.debug(':::mail::::'+mail);
                    emailList.add( mail );
                }
                if( emailList.size() > 0 ) {
                    Messaging.SendEmailResult[] result = Messaging.sendEmail( emailList );
                }
            }
        } catch(Exception exp) {
            errormessage += exp.getMessage()+'\n';
        }
    }

    public void finish(Database.BatchableContext BC) {  
    
        if (string.isNotBlank(errormessage)) {

            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();       
            mail.setTargetObjectId( UserInfo.getUserId() );
            mail.setSaveAsActivity(false);
            if (emailLimitMayExceed) {
                List<EmailTemplate> templateList = new List<EmailTemplate>([SELECT DeveloperName, Id, IsActive FROM EmailTemplate WHERE DeveloperName = 'Exam_Email_Limits_Notification' AND IsActive = true LIMIT 1]);
                if (templateList != null && templateList.size() > 0) {
                    mail.setTemplateId( templateList[0].Id );
                    Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
                }
            }
            else {
                mail.setSubject('Exception on '+distribution.Name);
                mail.setHtmlBody( errormessage );
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
            }
        }
    }
}