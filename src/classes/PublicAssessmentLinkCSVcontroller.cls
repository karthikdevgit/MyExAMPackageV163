public with sharing class PublicAssessmentLinkCSVcontroller{

    public string PAFieldsLabel {get;set;}
    public string PAQueryFields {get;set;}
    
    public PublicAssessmentLinkCSVcontroller() {  
    
        PAFieldsLabel = '';
        paQueryFields = '';

        List<Schema.FieldSetMember> PAObjFieldsList = new List<Schema.FieldSetMember>();
        string assGeneratorId = ApexPages.currentPage().getParameters().get('agId');
        string distributionId = ApexPages.currentPage().getParameters().get('distId');
        
        if((assGeneratorId != null && assGeneratorId != '') || (distributionId != null && distributionId != '')) {
        
            PAObjFieldsList = SObjectType.Public_Assessment__c.FieldSets.Link_Generator.getFields();
            
            if( PAObjFieldsList != null && PAObjFieldsList.size() > 0) {
                PAQueryFields += 'Id,Name,';
                PAFieldsLabel += 'Id,Name,';
                
                for(Schema.FieldSetMember f : PAObjFieldsList) { 
                    if(!PAQueryFields.contains(f.getFieldPath())) {
                        PAQueryFields += f.getFieldPath() + ',';
                        PAFieldsLabel += f.getlabel() + ',';
                    }
                }
            } else {
                PAQueryFields += 'Id,Name,ExAM__Public_Assessment_URL__c';
                PAFieldsLabel += 'Id,Name,Public Assessment URL';
            }
            if (PAQueryFields.endsWith(',') && PAFieldsLabel.endsWith(',') ) {
                PAQueryFields = PAQueryFields.substring(0, PAQueryFields.length()-1);
                PAFieldsLabel = PAFieldsLabel.substring(0, PAFieldsLabel.length()-1);
            }
        }
    }
    @RemoteAction 
    public static PARecordClass queryPArecords(string queryStr,Boolean isFirstTime,List<string> queriedPARecordsIdList) {
        
        PARecordClass paRec;
        try {                
            List<String> fieldsList = new List<string>();
            List<Public_Assessment__c> paList = new List<Public_Assessment__c>();
            paRec = new PARecordClass();
            List<Schema.FieldSetMember> PAObjFieldsList = new List<Schema.FieldSetMember>(SObjectType.Public_Assessment__c.FieldSets.Link_Generator.getFields());
            
            if( PAObjFieldsList != null && PAObjFieldsList.size() > 0) {
                for(Schema.FieldSetMember f : PAObjFieldsList) { 
                    fieldsList.add(f.getFieldPath());
                }
            } else {
                fieldsList.add('EXAM__Public_Assessment_URL__c');
            }
            
            SFDCAccessController accessForAT = ExAMUtilClass.AccessController;
            List<string> fieldsListAT = fieldsList;
            accessForAT.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Public_Assessment__c'), fieldsListAT);
            
            if(queryStr != null && queryStr != '') {
                if(isFirstTime) {
                    queryStr += ' ORDER BY CreatedDate ASC LIMIT 10000'; 
                } else {
                    queryStr += ' AND Id NOT IN :queriedPARecordsIdList ORDER BY CreatedDate ASC LIMIT 10000'; 
                }
                
                paList = Database.query(queryStr);
                if(paList.size() > 0) {
                    for(Public_Assessment__c pa : paList) {
                        queriedPARecordsIdList.add(pa.Id);
                    }
                     
                    paRec.paRecordsList = paList;
                    paRec.queriedPARecordsId = queriedPARecordsIdList;
                    paRec.statusMsg = 'Processing';
                } else {
                    if(isFirstTime) {
                        paRec.paRecordsList = new List<Public_Assessment__c>();
                        paRec.queriedPARecordsId = new List<string>();
                        paRec.statusMsg = 'Empty';
                    } else {
                        paRec.paRecordsList= new List<Public_Assessment__c>();
                        paRec.queriedPARecordsId = new List<string>();
                        paRec.statusMsg = 'Finish';
                    }
                }
                
            }

        } catch (Exception e){
            paRec = new PARecordClass();
            paRec.paRecordsList = new List<Public_Assessment__c>();
            paRec.queriedPARecordsId = new List<string>();
            paRec.statusMsg = e.getMessage();
        }
        return paRec;
    }
    
    public class PARecordClass {
        public List<Public_Assessment__c> paRecordsList;
        public List<string> queriedPARecordsId;
        public string statusMsg;
        
    }
}