@isTest
public class TestStaticResourceLookupController {
    static testMethod void validateStaticResourceLookup() {
        
        List<StaticResource> staticResourceList = [SELECT Id, Name FROM StaticResource];
        Set<StaticResource> staticResourceSet = new Set<StaticResource>();
        staticResourceSet.addAll(staticResourceList);
        
        string searchString = 'an';
        List<StaticResource> srcLis = StaticResourceLookupController.fetchSRC(searchString);
        System.assertEquals(true, staticResourceSet.containsAll(srcLis));
        
         
    }
}