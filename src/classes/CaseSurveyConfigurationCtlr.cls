public with sharing class  CaseSurveyConfigurationCtlr {

    public string caseConfigJSON {get;set;}
    public string fieldDetail {get;set;}
    public string tempName {get;set;}
    public string emailTemplate {get;set;}
    public Boolean isConfig {get;set;}
    
    public List<fieldDetailsClass> fieldDetailsList;
    public List<ConfigFieldClass> configFieldList;
    public List<assTempClass> assTempNameList;  
    public List<EmailTempClass> emailTempList;
    
    public class fieldDetailsClass {
        public string fieldName;
        public string fieldType;
        public string fieldApiName;
        public List<string> fieldOptions;
       
        public fieldDetailsClass(string fn, string ft, string fan, List<string> fo) {
            this.fieldName = fn;
            this.fieldType = ft;
            this.fieldApiName = fan;
            this.fieldOptions = fo;
        }
        
    }
    public class ConfigFieldClass {
        public string configFieldName;
        public string configFieldValue;
        public string configTempName;
        public string configEmailTemp;
        
        public ConfigFieldClass(string fn, string ft, string tn, string et) {
            this.configFieldName = fn;
            this.configFieldValue = ft;
            this.configTempName = tn;
            this.configEmailTemp = et;
        }
    } 
    public class EmailTempClass {
        public string emailTempId;
        public string emailTempName;
        
        public EmailTempClass(string eid,string eName) {
            this.emailTempId = eid;
            this.emailTempName = eName;
        }
    }
    public class assTempClass {
        public string assId;
        public string assTempName;
        public string name;
        
        public assTempClass(string an, string atn,string name) {
            this.assId = an;
            this.assTempName = atn;
            this.name = name;
        }
    }
    public CaseSurveyConfigurationCtlr() {
        try{
            fieldDetailsList = new List<fieldDetailsClass>{new fieldDetailsClass('---None---','','---None---',new List<String>{'---None---'})};
            configFieldList = new List<ConfigFieldClass>{new ConfigFieldClass('---None---','---None---','---None---','---None---')};
            assTempNameList = new List<assTempClass>{new assTempClass('---None---','---None---','')};
            emailTempList = new List<EmailTempClass>{new EmailTempClass('---None---','---None---')};
            
            Map <string, Schema.SObjectField> caseFieldNameAndAPINameMap = Schema.SObjectType.case.fields.getMap(); 
            isConfig = false;
            
            for(Schema.SObjectField objField : caseFieldNameAndAPINameMap.Values()) {
                Schema.DescribeFieldResult res = objField.getdescribe();
                if(string.valueOf(res.getType()).toupperCase()== 'PICKLIST') {
                    List<string> pickListFieldOption = new List<string>();
                    for (Schema.PicklistEntry f : res.getPicklistValues()) {
                        pickListFieldOption.add(f.getValue());
                    }
                    fieldDetailsClass fieldIns = new fieldDetailsClass(res.getLabel(),string.valueOf(res.getType()).toupperCase(),res.getName(),pickListFieldOption);
                    fieldDetailsList.add(fieldIns);
                }
            }
            
            fieldDetail =  Json.serialize(fieldDetailsList);
            
            SFDCAccessController accessObj = ExAMUtilClass.AccessController;
            List<string> fieldsListAT = new List<string>{'ExAM__Template_name__c'};
            accessObj.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Main_questionaire__c'), fieldsListAT);
            for(Main_questionaire__c assTemp : [SELECT Id,Name,Template_name__c FROM Main_questionaire__c ORDER BY CreatedDate DESC LIMIT 1000]) {
                if(assTemp.Template_name__c != null && assTemp.Template_name__c !='') {
                    assTempClass ass = new assTempClass(assTemp.Id,assTemp.Template_name__c,assTemp.Name);
                    assTempNameList.add(ass); 
                }     
            }
            tempName = Json.serialize(assTempNameList);
            
            List<Folder> folderList = [Select Id, Name From Folder Where Type = 'Email' AND DeveloperName = 'Case_Closure' LIMIT 1];
            if(folderList != null && folderList.size() > 0) {
                List<EmailTemplate> emailTemplates = [SELECT Id, Name, IsActive 
                                                      FROM EmailTemplate 
                                                      WHERE IsActive = true
                                                      AND Folder.Id = :folderList[0].Id]; 
                
                if(emailTemplates != null && emailTemplates.size() > 0) {
                    for(EmailTemplate e : emailTemplates) {
                        emailTempList.add(new EmailTempClass(e.Id,e.Name));
                    }
                }
                
            }
            emailTemplate = JSON.serialize(emailTempList);
            
            List<string> fieldsListEC = new List<string>{'ExAM__Enable_Case_Survey__c','ExAM__Case_Configuration__c'};
            accessObj.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__ExAM_Configuration__c'), fieldsListEC);
            List<ExAM_Configuration__c> config = new List<ExAM_Configuration__c>();
            config = [SELECT Id,Enable_Case_Survey__c,Case_Configuration__c FROM ExAM_Configuration__c WHERE Name ='Configuration' ORDER BY CreatedDate DESC LIMIT 1];
            if(config != null && config.size()>0 ) {
                isConfig = config[0].Enable_Case_Survey__c;            
                if (config[0].Case_Configuration__c != null && config[0].Case_Configuration__c !='') {
                    configFieldList = (List<ConfigFieldClass>)JSON.deserialize(config[0].Case_Configuration__c,List<ConfigFieldClass>.Class);
                } 
            } 
            caseConfigJSON = Json.serialize(configFieldList);
        } catch (Exception e){
             ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()) );
        }
    }
    @RemoteAction 
    public static string saveFieldConfiguration(string configJSON, string isConfigured) {
       
        string responseMsg = '';
        try{
            if(isConfigured != null && isConfigured !='' &&configJSON != null && configJSON != '') {
                
            SFDCAccessController accessObj = ExAMUtilClass.AccessController;
            List<string> fieldsListEC = new List<string>{'ExAM__Enable_Case_Survey__c','ExAM__Case_Configuration__c'};
            accessObj.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__ExAM_Configuration__c'), fieldsListEC);
            List<ExAM_Configuration__c> config = new List<ExAM_Configuration__c>();
            config = [SELECT Id,Enable_Case_Survey__c,Case_Configuration__c FROM ExAM_Configuration__c WHERE Name ='Configuration' ORDER BY CreatedDate DESC LIMIT 1];
            
                if(config != null && config.size()>0) {
                    config[0].Case_Configuration__c = configJSON;
                    config[0].Enable_Case_Survey__c = Boolean.valueOf(isConfigured);
                    
                    accessObj.assertAuthorizedToUpdate(Schema.getGlobalDescribe().get('exam__ExAM_Configuration__c'), fieldsListEC);
                    update config;
                    responseMsg ='success';
                } else {
                    ExAM_Configuration__c examConfig = new ExAM_Configuration__c();
                    examConfig.Name = 'Configuration';
                    examConfig.Case_Configuration__c = configJSON;
                    examConfig.Enable_Case_Survey__c = Boolean.valueOf(isConfigured);
                    
                    accessObj.assertAuthorizedToCreate(Schema.getGlobalDescribe().get('exam__ExAM_Configuration__c'), fieldsListEC);
                    insert examConfig;
                    responseMsg ='success';
                }
                
            }
        } catch(Exception e){
            responseMsg = e.getMessage();
        }
        return responseMsg;
    }
}