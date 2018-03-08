public with sharing class LookupSObjectController {
    
    @AuraEnabled
    public static Result[] lookup(String searchString, String sObjectAPIName){
        try{
            FieldLevelSecurity.checkObjectAccessByView(sObjectAPIName);
            // Sanitze the input
            String sanitizedSearchString = String.escapeSingleQuotes(searchString);
            
            String sanitizedSObjectAPIName = String.escapeSingleQuotes(sObjectAPIName);
            String SELECT_CLAUSE = 'Id, Name';
            
            if(sObjectAPIName.equalsIgnoreCase('Case')){
                SELECT_CLAUSE = 'Id, CaseNumber';
            }
            
            List<Result> results = new List<Result>();
            
            // Build our SOSL query
            String searchQuery = 'FIND \'' + sanitizedSearchString + '*\' IN NAME FIELDS RETURNING ' + sanitizedSObjectAPIName + '(' +SELECT_CLAUSE +
                ' ORDER BY LastModifiedDate DESC LIMIT 10)';
            
            System.debug('searchQuery::::'+searchQuery);
            // Execute the Query
            List<List<SObject>> searchList = search.query(searchQuery);
            
            // Create a list of matches to return
            for (SObject so : searchList[0])
            {
                
                results.add(new Result((String)so.get(SELECT_CLAUSE.substringAfterLast(',').trim()), so.Id));
            }
            
            return results;
            
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
        
    }
    
    /**
* Inner class to wrap up an SObject Label and its Id
*/
    public class Result
    {
        @AuraEnabled public String SObjectLabel {get; set;}
        @AuraEnabled public Id SObjectId {get; set;}
        
        public Result(String sObjectLabel, Id sObjectId)
        {
            this.SObjectLabel = sObjectLabel;
            this.SObjectId = sObjectId;
        }
    }
    
   /* @AuraEnabled
    public static sObject fetchSpecifyRecord(Id recordId, String sObjectAPIName, String questionId){
        
        
        String objectQuery = 'SELECT Id,Name FROM '+sObjectAPIName+' WHERE Id = '+'\''+recordId+'\'' + 
                            'AND Id != :questionId';
        
        System.debug('objectQuery::::::::::'+objectQuery);
        
        sObject record = Database.query(objectQuery);
        return record;
    }*/
    
    @AuraEnabled
    public static String fetchSpecifyRecord(Id recordId, String sObjectAPIName){
        
        try{
            FieldLevelSecurity.checkObjectAccessByView(sObjectAPIName);
            String objectQuery = 'SELECT Id,Name FROM '+sObjectAPIName+' WHERE Id = '+'\''+recordId+'\'';
            
            
            System.debug('objectQuery::::::::::'+objectQuery);
            
            sObject record = Database.query(objectQuery);
            return String.valueOf(record.get('Name'));
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
        
    }
}