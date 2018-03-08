@isTest
public class TestKnowledgeArticleConfigurationCntrlr {
    
    static testMethod void method1(){

        KnowledgeArticleConfigurationController kACC = new KnowledgeArticleConfigurationController();
        List<KnowledgeArticleConfigurationController.ArticleTypeDetails> atdList = KnowledgeArticleConfigurationController.returnKnowledgeArticleTypes();
        KnowledgeArticleConfigurationController.ErrorClass ec = new KnowledgeArticleConfigurationController.ErrorClass('test1','test2');

        Map<String, Schema.SObjectField> userFieldMap = Schema.SObjectType.User.fields.getMap();
        if (userFieldMap.containsKey('UserPermissionsKnowledgeUser')) {
            system.assertEquals(atdList[0].typeApiName, 'ExAM__Knowledge__ka');
        }
    }
}