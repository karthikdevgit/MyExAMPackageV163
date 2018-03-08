public class SendDistributionScheduler implements Schedulable {

    public Id distId;

    public SendDistributionScheduler(Id recordId) {
        distId = recordId;
    }
    
    public void execute (SchedulableContext SC){ 
     
       List<Distribution__c> distList = new List<Distribution__c>([
            SELECT Assessable_Object_API__c, Assessable_Record__c, Distribution_Group__c, Distribution_Group__r.Target_Object__c,
                   Distribution_Group__r.Target_Object_Filter__c, Distribution_DateTime__c, Email_Template__c,
                   Id, Name, Target_Object_Ids__c,
                   (SELECT Id, Public_Assessment_URL__c FROM Public_Assessments__r)
            FROM   Distribution__c
            WHERE  Id = :distId AND Email_Template__c != null LIMIT 1]); 

        if( distList.size() > 0 ) {
            SendDistributionBatch dist = new SendDistributionBatch();
            dist.distribution = distList[0];
            Database.executeBatch(dist, 75);
        }
    }
}