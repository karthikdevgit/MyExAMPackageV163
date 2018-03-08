global class DelTemporaryReportBuilder_schedule implements Schedulable {
    
    global void execute(SchedulableContext scMain) {
        
        try{
            SFDCAccessController accessForobj = ExAMUtilClass.AccessController;
            List<String> fieldsList = new List<String>{'ExAM__Is_Temporary__c'};
            accessForobj.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Report_Builder_Configuration__c'), fieldsList);

            if ( accessForobj.isAuthorizedToDelete(Schema.getGlobalDescribe().get('exam__Report_Builder_Configuration__c')) ) {
                DelTemporaryReportBuilderController delTempList = new DelTemporaryReportBuilderController();
                ID idBatch = Database.executeBatch(delTempList);
            }
            else {
                notifyUser( 'OBJECT_ACCESS_VIOLATION - NO_DELETE - ExAM__Report_Builder_Configuration__c' );
            }
        }catch(Exception e){
            notifyUser( e.getMessage() );
        } 
    }

    global void notifyUser(string errorMsg) {

        String userId = UserInfo.getUserId();
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();       
        mail.setTargetObjectId( UserInfo.getUserId() );
        mail.setSubject('Delete Report Builder Configuration Batch Failed');
        mail.setUseSignature(false);
        mail.setBccSender(false);
        mail.setSaveAsActivity(false); 
        mail.setplainTextBody( errorMsg );
        Messaging.SendEmailResult[] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail}); 
    }
}