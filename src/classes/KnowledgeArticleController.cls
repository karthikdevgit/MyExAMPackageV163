public with sharing class KnowledgeArticleController {

    public class KnowledgeArticles {
        public String summaryField { get; set; }
        public List<SObject> sObjectRecords { get; set; }
        public ErrorClass err { get; set; }
    }

    public class ErrorClass {
        public string errType{get; set;}
        public string errMsg{get; set;}

        public ErrorClass(string etype, string eMsg) {

            this.errType = etype;
            this.errMsg = eMsg; 
        }
    }

    public KnowledgeArticleController() {
    }

    @RemoteAction
    public static KnowledgeArticles returnKnowledgeArticles() {

        List<SObject> kavList = new List<SObject>();
        KnowledgeArticles articles;

        Map<String, Schema.SObjectField> userFieldMap = Schema.SObjectType.User.fields.getMap();
        system.debug('::::::knowledgeUser:::'+userFieldMap.containsKey('UserPermissionsKnowledgeUser'));

        if (userFieldMap.containsKey('UserPermissionsKnowledgeUser')) {

            try {
                
                SFDCAccessController accessForobj = ExAMUtilClass.AccessController;
                List<String> fieldsList = new List<String>{'ExAM__Knowledge_Article_Type_Name__c','ExAM__Knowledge_Article_Content_Field_Name__c'};
                accessForobj.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__ExAM_Configuration__c'), fieldsList);

                List<ExAM_Configuration__c> configurationRecordsList = new List<ExAM_Configuration__c>();
                configurationRecordsList = [
                    SELECT Id, Knowledge_Article_Type_Name__c, Knowledge_Article_Content_Field_Name__c, Name
                    FROM   ExAM_Configuration__c LIMIT 1
                ];

                if ( (configurationRecordsList != null && configurationRecordsList.size() > 0)
                     && (String.isNotBlank(configurationRecordsList[0].Knowledge_Article_Type_Name__c))
                     && (String.isNotBlank(configurationRecordsList[0].Knowledge_Article_Content_Field_Name__c))
                ) {

                    String KAV_SELECT_CLAUSE = 'Id, Summary, Title';
                    if ( !KAV_SELECT_CLAUSE.contains(configurationRecordsList[0].Knowledge_Article_Content_Field_Name__c) ) {
                        KAV_SELECT_CLAUSE += ', '+configurationRecordsList[0].Knowledge_Article_Content_Field_Name__c;
                    }
                    String KAV_FROM_CLAUSE = configurationRecordsList[0].Knowledge_Article_Type_Name__c.replace('__ka', '__kav');
                    String KAV_WHERE_CLAUSE = 'PublishStatus = \'Online\' AND Language = \'en_US\'';
                    String KAV_LIMIT_CLAUSE = '1000';

                    String KAV_QUERY_STR = 'SELECT '+KAV_SELECT_CLAUSE+' FROM '+KAV_FROM_CLAUSE+' WHERE '+KAV_WHERE_CLAUSE+' LIMIT '+KAV_LIMIT_CLAUSE;
                    List<SObject> tempSobjectList = Database.query( KAV_QUERY_STR );

                    if (tempSobjectList != null && tempSobjectList.size() > 0) {
                        kavList.addAll( tempSobjectList );
                    }
                }
                system.debug(':::: kavList ::::'+ kavList );

                String KAV_SELECT_CLAUSE1 = 'ArticleNumber, ArticleType, FirstPublishedDate, Id, KnowledgeArticleId, Language, LastModifiedDate, ';
                KAV_SELECT_CLAUSE1 += 'OwnerId, PublishStatus, SourceId, Summary, Title, UrlName, VersionNumber';
                String KAV_FROM_CLAUSE1 = 'KnowledgeArticleVersion';
                String KAV_WHERE_CLAUSE1 = 'PublishStatus = \'Online\' AND Language = \'en_US\'';
                if ( kavList != null && kavList.size() > 0 ) {
                    KAV_WHERE_CLAUSE1 += ' AND Id NOT IN :kavList';
                }
                String KAV_LIMIT_CLAUSE1 = '1000';

                String KAV_QUERY_STR1 = 'SELECT '+KAV_SELECT_CLAUSE1+' FROM '+KAV_FROM_CLAUSE1+' WHERE '+KAV_WHERE_CLAUSE1+' LIMIT '+KAV_LIMIT_CLAUSE1;
                system.debug('::::KAV_QUERY_STR1 ::::'+ KAV_QUERY_STR1 );
                List<SObject> tempSobjectList1 = Database.query( KAV_QUERY_STR1 );

                if (tempSobjectList1 != null && tempSobjectList1.size() > 0) {
                    kavList.addAll( tempSobjectList1 );
                }
                system.debug('::::kavList ::::'+kavList );

                articles = new KnowledgeArticles();
                articles.summaryField = ( configurationRecordsList.size() > 0 && String.isNotBlank(configurationRecordsList[0].Knowledge_Article_Content_Field_Name__c) ) ? configurationRecordsList[0].Knowledge_Article_Content_Field_Name__c : null;
                articles.sObjectRecords = kavList;
            } catch (Exception ex) {

                ErrorClass error = new ErrorClass(ex.getTypeName(), ex.getMessage());

                articles = new KnowledgeArticles();
                articles.err = error;
            }
        }
        return articles;        
    }
}