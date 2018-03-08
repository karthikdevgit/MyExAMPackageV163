public with sharing class StaticResourceLookupController {
    
    @AuraEnabled
    public static List<StaticResource> fetchSRC(string searchString){
        List<StaticResource> srcList;
            String query = 'SELECT Id, Name FROM StaticResource WHERE Name Like \'%'+ searchString + '%\'' ;
            srcList = Database.query(query);
            return srcList;
    }
    
}