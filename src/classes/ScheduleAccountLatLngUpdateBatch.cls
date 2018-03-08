global class ScheduleAccountLatLngUpdateBatch implements Schedulable {

    global void execute(SchedulableContext context) {

        Map<String, ExAM__GoogleMapsAPIKey__c> allKeys = ExAM__GoogleMapsAPIKey__c.getAll();
        String GoogleMapsAPIKey = (allKeys.containskey('GoogleMapsAPIKey')? allKeys.get('GoogleMapsAPIKey').ExAM__API_Key__c : '');

        if( String.isNotBlank(GoogleMapsAPIKey) ) {

            Database.executeBatch(new UpdateAccountLocationBasedOnAddressBatch(), 100);
        }
        else {

            List<Messaging.SingleEmailMessage> msgList = new List<Messaging.SingleEmailMessage>();

            Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
            msg.setSubject('Google Maps API Key not found');
            msg.setPlainTextBody('Google Maps API Key is not found in the custom settings. Please create Google Maps API key via Exam Configuration');
            msg.setToAddresses(new List<String>{ UserInfo.getUserEmail() });
            msgList.add( msg );

            if (msgList != null && msgList.size() > 0) {
                Messaging.SendEmailResult[] results = Messaging.sendEmail(msgList);
            }
        }
    }
}