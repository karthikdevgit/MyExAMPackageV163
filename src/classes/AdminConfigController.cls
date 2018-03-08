public class AdminConfigController {
    
    //custom field create code
    public string selectedObj { get; set; }
    public string Objs { get; set; }

    public Boolean showEdit{get;set;}
    public Boolean errorMsg { get; set; }
    
    public List<SelectOption> Objes { get; set; }

    public Set<string> alreadyCreateFieldSet;
    
    public Map<string, string> objectAPILabelMap = new Map<string, string>();
    
    public GoogleMapsAPIKey__c gleMapAPI{get;set;}

    public AdminConfigController(){

        List<GoogleMapsAPIKey__c> qryList = new List<GoogleMapsAPIKey__c>();
        gleMapAPI = new GoogleMapsAPIKey__c();
        gleMapAPI.Name = 'GoogleMapsAPIKey';
        showEdit = false;
        qryList = [SELECT Name,API_Key__c FROM GoogleMapsAPIKey__c WHERE Name = 'GoogleMapsAPIKey' LIMIT 1];
        if(qryList != null && qryList.size()>0){
            gleMapAPI =qryList[0];
            showEdit = true ;
        }
        
        alreadyCreateFieldSet = new Set<string>();
        //custom field create code
        selectedObj = '';
        errorMsg = false;         
        alreadyCreatedFields();
        
        
        Objes = new List<SelectOption>();
        loadObjects();
    }

    public void alreadyCreatedFields() {

        alreadyCreateFieldSet = new Set<string>();        

        ExAMUtilClass.AssessableObjectDetails objectDetail = ExAMUtilClass.getAssessableObjectDetails('ExAM__IssueRequest_Life_Cycle__c');
        Map<string, string> fieldsMap = objectDetail.assessableObjectAPIMap;
        for (string field : fieldsMap.keySet()) {
            alreadyCreateFieldSet.add( field.toUpperCase() );
        }
    }
    
    public pagereference updateCustomSetting(){
        if(string.isNotBlank(gleMapAPI.Name)){
            try{
                upsert gleMapAPI;
                showEdit = true;
            }catch(Exception e){
                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage() );
                ApexPages.addMessage(msg);  
                showEdit = false;  
            }
        }
        return null;
    }

    public pagereference showEditFlag(){
        showEdit = false; 
        return null;
    }
    
    public void loadObjects() {
        Objes = new List<SelectOption>();
        List<SelectOption> options = new List<SelectOption>();
        
        if( !alreadyCreateFieldSet.contains(('AM_Contact__c').toUpperCase()) ) {
            options.add(new SelectOption('Contact', 'Contact'));
        }
        if( !alreadyCreateFieldSet.contains(('AM_User__c').toUpperCase()) ) {
            options.add(new SelectOption('User', 'User'));
        } 
        if( !alreadyCreateFieldSet.contains(('AM_Opportunity__c').toUpperCase()) ) {
            options.add(new SelectOption('Opportunity', 'Opportunity'));
        }
        
        objectAPILabelMap.put('User','User');
        objectAPILabelMap.put('Contact','Contact');
        objectAPILabelMap.put('Opportunity','Opportunity');
         
        Map<string, Schema.SObjectType> gd = schema.getGlobalDescribe();
        set<string> objectSet = new Set<string>();
        
        for(SObjectType sObj : gd.values()) {
            Schema.DescribeSObjectResult objDescription = sObj.getDescribe();
            if( objDescription.isCustom() == true && 
                objDescription.customSetting == false ) {
                //&& objDescription.getName() != namespace+'IssueRequest_Life_Cycle__c' &&
                //objDescription.getName() != namespace+'Questionnaire_Response__c') {
                
                //string lookupFieldName = namespace+'AM_'+objDescription.getLocalName();
                string lookupFieldName = 'AM_'+objDescription.getLocalName();
                
                if( !alreadyCreateFieldSet.contains(lookupFieldName.toUpperCase()) ) {
                    options.add(new SelectOption(objDescription.getName(), objDescription.getLabel()));    
                }                
                
                
                objectAPILabelMap.put(objDescription.getName(),objDescription.getLabel());
            }
            System.debug(':::sobj:::'+sObj);
        }
        Objes = options;
        System.debug(':Objes:::::'+Objes);
    }
    public pageReference createLookupField()
    {
        try {
            string createdFieldApiName = '';
            errorMsg = false;
            if( selectedObj != null && selectedObj != '' ) {
                MetadataService.MetadataPort service = new MetadataService.MetadataPort();
                service.SessionHeader = new MetadataService.SessionHeader_element();
                service.SessionHeader.sessionId = UserInfo.getSessionId();
                MetadataService.CustomField customField = new MetadataService.CustomField();
                
                MetadataService.CustomField answerCustomField = new MetadataService.CustomField();
                string relationshipName = selectedObj != null ? selectedObj : '';
                
                //string selectedObjLocalName = selectedObj.replaceFirst(namespace,'');
                string selectedObjLocalName = selectedObj;
                if (selectedObj.countMatches('__') == 2) {
                    selectedObjLocalName = selectedObj.substringAfter('__');
                }
                
                if( selectedObjLocalName.contains('__c') ) {
                    relationshipName = selectedObjLocalName.replace('__c','');
                    System.debug('::::relationshipName :::>>>'+relationshipName );                
                    //createdFieldApiName = namespace+'AM_'+selectedObjLocalName;
                    createdFieldApiName = 'AM_'+selectedObjLocalName;
                    customField.fullName = 'ExAM__IssueRequest_Life_Cycle__c.AM_'+selectedObjLocalName;
                    answerCustomField.fullName = 'ExAM__Questionnaire_Response__c.ANS_'+selectedObjLocalName;
                    
                } else {
                    customField.fullName = 'ExAM__IssueRequest_Life_Cycle__c.AM_'+selectedObjLocalName+'__c';
                    //createdFieldApiName = namespace+'AM_'+selectedObjLocalName+'__c';
                    createdFieldApiName = 'AM_'+selectedObjLocalName+'__c';
                    answerCustomField.fullName = 'ExAM__Questionnaire_Response__c.ANS_'+selectedObjLocalName+'__c';
                }
                
                if(objectAPILabelMap != null && objectAPILabelMap.keySet() != null && objectAPILabelMap.containsKey(selectedObj) ) {
                    customField.label = objectAPILabelMap.get(selectedObj);
                    answerCustomField.label = objectAPILabelMap.get(selectedObj);
                } else {
                    customField.label = relationshipName;
                    answerCustomField.label = relationshipName;
                }
                customField.type_x = 'Lookup';
                answerCustomField.type_x = 'Lookup';
                customField.relationshipLabel = 'Assignment Managers';
                answerCustomField.relationshipLabel = 'Answers';
                customField.relationshipName = 'AM_'+relationshipName;
                answerCustomField.relationshipName = 'ANS_'+relationshipName;
                
                System.debug('::customField.fullName:::'+customField.fullName);
                System.debug('::customField.label:::'+customField.label);
                System.debug(':::customField.relationshipName::'+customField.relationshipName);
                
                
                customField.referenceTo = selectedObj;
                answerCustomField.referenceTo = selectedObj;
                List<MetadataService.SaveResult> results = new List<MetadataService.SaveResult>();
                if (!Test.isRunningTest()) { 
                    results = service.createMetadata( new MetadataService.Metadata[] { customField,answerCustomField });
                }
                System.debug(':::::results::::'+results); 
                
                if (results != null && results.size() > 0 ) {
                    for (MetadataService.SaveResult result : results) {
                        if (!result.success) {
                            if (result.errors != null && result.errors.size() > 0 ) {
                                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, result.errors[0].message));  
                                errorMsg = true;      
                            }
                        }
                    }                
                }
    
                if (!errorMsg) {
                    alreadyCreateFieldSet.add(createdFieldApiName.toUpperCase());
                }
                 
            }
            loadObjects();
        } catch(Exception e) {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Please check salesforce Domain Name and Remote Site Setting values' );
            ApexPages.addMessage(msg);  
        }
            //e.getMessage()
        return null;
    }
}