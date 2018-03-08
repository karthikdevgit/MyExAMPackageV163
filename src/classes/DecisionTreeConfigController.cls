public with sharing class DecisionTreeConfigController {
    
    //public Questionnaire_Response__c
    
    //Map <string, Schema.SObjectField> answerFieldNameAPIMap = Schema.SObjectType.Questionnaire_Response__c.fields.getMap();
    public String fieldsList {get; set;}
    
    public Map<integer, List<answerFieldDetailClass>> rowwithListOfAnswerMap { get; set; }
    public Map<integer, integer> rowwithSizeofColumn { get; set; }
    
    public Class answerFieldDetailClass {
        public String fieldAPIName { get; set; }
        public String fieldLabelName { get; set; }    
    }
    
    public DecisionTreeConfigController() {
        
        try{
            fieldsList = '';
            rowwithListOfAnswerMap = new Map<integer, List<answerFieldDetailClass>>();
            rowwithSizeofColumn = new Map<integer, integer> ();
            
            Map <string, Schema.SObjectField> answerFieldNameAPIMap = Schema.SObjectType.Questionnaire_Response__c.fields.getMap();
            integer rowcount = 1;
            integer columncount = 1;
            for (Schema.SObjectField ansfield : answerFieldNameAPIMap.values()) {
            
                Schema.DescribeFieldResult res = ansfield.getdescribe();
                System.debug(':>:::'+res.getName()+ ':::::'+String.valueOf(res.getType()).touppercase());
               
                if (res.isCustom() && res.getCalculatedFormula() == null && ((String.valueOf(res.getType()).touppercase() == 'STRING' ) ||
                        (String.valueOf(res.getType()).touppercase() == 'TEXTAREA') || (String.valueOf(res.getType()).touppercase() == 'PICKLIST'))) {
                    
                    answerFieldDetailClass anscls = new answerFieldDetailClass ();
                    anscls.fieldAPIName = res.getName();
                    anscls.fieldLabelName = res.getLabel();
                    
                    if( !rowwithListOfAnswerMap.containsKey(rowcount)) {
                        rowwithListOfAnswerMap.put(rowcount, new List<answerFieldDetailClass>());
                    }
                    rowwithListOfAnswerMap.get(rowcount).add(anscls);
                    rowwithSizeofColumn.put(rowcount, columncount);
                    
                    columncount++;
                    if (columncount > 2) {
                        rowcount++;
                        columncount = 1;
                    }
                    
                } 
            }
            
            answerFieldDetailClass anscls = new answerFieldDetailClass ();
            anscls.fieldAPIName = 'Pictures';
            anscls.fieldLabelName = 'Pictures';
            
            if( !rowwithListOfAnswerMap.containsKey(rowcount)) {
                rowwithListOfAnswerMap.put(rowcount, new List<answerFieldDetailClass>());
            }
            rowwithListOfAnswerMap.get(rowcount).add(anscls);
            rowwithSizeofColumn.put(rowcount, columncount);
            
            System.debug(':::::::rowwithListOfAnswerMap::::'+rowwithListOfAnswerMap);
            SFDCAccessController accessForobj = ExAMUtilClass.AccessController;
            List<String> fieldsList1 = new List<String>{'ExAM__Decision_Tree__c'};
            accessForobj.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__ExAM_Configuration__c'), fieldsList1);
            List<ExAM_Configuration__c> configurationList = [ SELECT Id, Name, Decision_Tree__c 
                                                           FROM ExAM_Configuration__c 
                                                           WHERE Name = 'Configuration'];
                                                           
            if (configurationList != null && configurationList.size() > 0 && configurationList[0].Decision_Tree__c != null) {
                fieldsList = configurationList[0].Decision_Tree__c; 
            }
        }catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));    
        }
        
    }
    
    @RemoteAction
    public static string saveDecisionTreeConfig(String fieldslist) {
        system.debug(':::::fieldslist:::::'+fieldslist);
        String resultMsg = '';
        if (fieldslist != null && fieldslist != '') {
            
            try {
                ExAM_Configuration__c decisionTreeUpsert = new ExAM_Configuration__c();
                SFDCAccessController accessForobj = ExAMUtilClass.AccessController;
                List<String> fieldsList1 = new List<String>{'ExAM__Decision_Tree__c'};
                accessForobj.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__ExAM_Configuration__c'), fieldsList1);
                List<ExAM_Configuration__c> configurationList = [SELECT Id, Name, Decision_Tree__c FROM ExAM_Configuration__c WHERE Name = 'Configuration'];
                if (configurationList != null && configurationList.size() > 0) {
                    decisionTreeUpsert.Id = configurationList[0].Id;
                }
                decisionTreeUpsert.Name = 'Configuration';
                decisionTreeUpsert.Decision_Tree__c = fieldslist;
                accessForobj.assertAuthorizedToCreate(Schema.getGlobalDescribe().get('exam__ExAM_Configuration__c'), fieldsList1);
                accessForobj.assertAuthorizedToUpdate(Schema.getGlobalDescribe().get('exam__ExAM_Configuration__c'), fieldsList1);
                upsert decisionTreeUpsert;
                resultMsg = 'success';
            } catch (Exception e) {
                System.debug(':::e::::'+e.getMessage());
                resultMsg = e.getMessage();
            }
        }        
        return resultMsg;
    }
}