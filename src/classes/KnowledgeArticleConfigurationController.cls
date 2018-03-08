public class KnowledgeArticleConfigurationController {

    public class ArticleTypeDetails {
        public string typeApiName { get; set; }
        public string typeLabel { get; set; }
        public List<ArticleFieldDetails> fieldDtls { get; set; }
        public ErrorClass err { get; set; }
    }

    public class ArticleFieldDetails {
        public string fieldApiName { get; set; }
        public string fieldLabel { get; set; }
    }

    public class ErrorClass {
        public string errType{get; set;}
        public string errMsg{get; set;}

        public ErrorClass(string etype, string eMsg) {

            this.errType = etype;
            this.errMsg = eMsg; 
        }
    }

    public KnowledgeArticleConfigurationController() {
    }

    @RemoteAction
    public static List<ArticleTypeDetails> returnKnowledgeArticleTypes() {

        List<ArticleTypeDetails> typeList = new List<ArticleTypeDetails>();
        Map<String, List<ArticleFieldDetails>> articleNameKeyFieldsListMap = new Map<String, List<ArticleFieldDetails>>();

        Map<String, Schema.SObjectField> userFieldMap = Schema.SObjectType.User.fields.getMap();
        if (userFieldMap.containsKey('UserPermissionsKnowledgeUser')) {

            try {

                Map<String, Schema.SObjectType> obj = schema.getGlobalDescribe();
                for(Schema.SObjectType sObjType : obj.Values()) {

                    Schema.DescribeSObjectResult dsor = sObjType.getDescribe();

                    if (dsor.getName().endsWith('__ka')) {

                        ArticleTypeDetails typeDtl = new ArticleTypeDetails();
                        typeDtl.typeApiName = dsor.getName();
                        typeDtl.typeLabel = dsor.getLabel();
                        typeList.add( typeDtl );
                    }
                    if (dsor.getName().endsWith('__kav')) {

                        List<ArticleFieldDetails> fieldDtlList = new List<ArticleFieldDetails>();
                        String articleName_String = dsor.getName().replace('__kav', '__ka');

                        for(Schema.SObjectField sObjField : dsor.fields.getMap().Values()) {

                            Schema.DescribeFieldResult dfr = sObjField.getDescribe();
                            if (dfr.getType() == Schema.DisplayType.STRING
                                 || dfr.getType() == Schema.DisplayType.TEXTAREA
                            ) {

                                ArticleFieldDetails fieldDtl = new ArticleFieldDetails();
                                fieldDtl.fieldApiName = dfr.getName();
                                fieldDtl.fieldLabel = dfr.getLabel();
                                fieldDtlList.add( fieldDtl );
                            }
                            articleNameKeyFieldsListMap.put(articleName_String, fieldDtlList);
                        }
                    }
                }

                for(ArticleTypeDetails atDtl : typeList) {
                    atDtl.fieldDtls = articleNameKeyFieldsListMap.get(atDtl.typeApiName);
                }
            } catch (Exception ex) {

                ErrorClass error = new ErrorClass(ex.getTypeName(), ex.getMessage());

                ArticleTypeDetails typeDtl = new ArticleTypeDetails();
                typeDtl.err = error;
                typeList.add( typeDtl );
            }
        }
        return typeList;        
    }
}