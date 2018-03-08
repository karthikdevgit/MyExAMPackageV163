@isTest
private class TestKnowledgeArticleController {

    static testMethod void knowledgeQuery() { 
        new KnowledgeArticleController(); 
        ExAM_Configuration__c[] configList = new ExAM_Configuration__c[]{
            new ExAM_Configuration__c(Name = 'test', Knowledge_Article_Type_Name__c = 'Know__c',
                                     Knowledge_Article_Content_Field_Name__c = 'ArticleNumber'
                                     )    
        };
        insert configList;
        KnowledgeArticleController.KnowledgeArticles sobj = KnowledgeArticleController.returnKnowledgeArticles();
        System.assertEquals(null, sobj.summaryField);
        List<ExAM_Configuration__c> configList1 = [SELECT Id, Knowledge_Article_Content_Field_Name__c FROM ExAM_Configuration__c];
        //System.assertEquals('ArticleNumber', sobj.summaryField );
        delete configList1;
        KnowledgeArticleController.KnowledgeArticles sobj1 = KnowledgeArticleController.returnKnowledgeArticles();
    }
    static testMethod void knowledgeQuery1() {
        ExAM_Configuration__c[] configList = new ExAM_Configuration__c[]{
            new ExAM_Configuration__c(Name = 'test', Knowledge_Article_Type_Name__c = 'Account',
                                     Knowledge_Article_Content_Field_Name__c = 'Name'
                                     )    
        };
        insert configList;
        KnowledgeArticleController.KnowledgeArticles sobj = KnowledgeArticleController.returnKnowledgeArticles();
        System.assertEquals(null, sobj.summaryField);
        List<ExAM_Configuration__c> configList1 = [SELECT Id, Knowledge_Article_Content_Field_Name__c FROM ExAM_Configuration__c];
        delete configList1;
        KnowledgeArticleController.KnowledgeArticles sobj1 = KnowledgeArticleController.returnKnowledgeArticles();
    }
}