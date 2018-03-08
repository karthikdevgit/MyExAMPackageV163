public with sharing class AssessmentMapBuilderController
{
    public string ColorBy{get;set;}
    public string assessmentCompletionVal { get; set; }
    public string priorityVal { get; set; }
    public string statusVal { get; set; }
    public string assessmentTypeVal { get; set; }
    public string assessableObject { get; set;}
    public string assessmentGroup { get; set; }
    public string assessmentEvent { get; set; }
    public string colormapping { get; set; }
    public string scheduledFrom { get; set; }
    public string scheduledTo { get; set; }

    public boolean showUsers{get;set;}

    public List<string> selectedmappingValues { get; set; }
    public List<string> MapType{get;set;}

    public List<SelectOption> assessableObjects { get; set; }    
    public List<SelectOption> assessmentGroups { get; set; }
    public List<SelectOption> assessmentEvents { get; set; }
    public List<SelectOption> pinColorConfigurationList { get; set; }

    public List<Main_questionaire__c> assessmentTempList = new List<Main_questionaire__c>();

    public AssessmentMapBuilderController()
    {

        try {

            assessmentCompletionVal = '';
            priorityVal = '';
            statusVal = '';
            assessmentTypeVal = '';
            scheduledFrom = '';
            scheduledTo = '';
            assessableObject = '';
            assessmentGroup = '';
            assessmentEvent = '';
            colormapping = '';

            MapType = new List<string>();
            selectedmappingValues = new List<string>();

            assessableObjects = new List<SelectOption>();
            assessmentGroups = new List<SelectOption>();
            assessmentEvents = new List<SelectOption>();
            pinColorConfigurationList = new List<SelectOption>();

            SFDCAccessController accessAT = ExAMUtilClass.AccessController;
            List<string> fieldsListAT = new List<string>{'ExAM__Template_name__c'};
            accessAT.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Main_questionaire__c'), fieldsListAT);

            assessmentTempList = [ SELECT Id, Template_name__c FROM Main_questionaire__c WHERE Template_name__c != NULL ORDER BY Template_name__c ASC];   

            Boolean firstField = true;
            assessableObject = 'Account';

            ExAMUtilClass.AssessableObjectDetails objectDetail = ExAMUtilClass.getAssessableObjectDetails('ExAM__IssueRequest_Life_Cycle__c');
            Map<string, string> fieldsAPIMap = objectDetail.assessableObjectAPIMap;
            Map<string, string> fieldsLabelMap = objectDetail.assessableObjectLabelMap;

            for (string referenceFieldAPIInAM : fieldsAPIMap.keySet()) {

                string AssessableObjectAPIName = fieldsAPIMap.get(referenceFieldAPIInAM);
                string AssessableObjectLabel = fieldsLabelMap.get(referenceFieldAPIInAM);
                assessableObjects.add(new SelectOption(AssessableObjectAPIName, AssessableObjectLabel));  
            }
            if (assessableObjects.size() > 0) {
                assessableObjects = sortSelectOptionList(assessableObjects);
            }

            firstField = true;        
            if (assessableObject != null && assessableObject != '') {
                assessmentGroups.add(new SelectOption('','--None--'));
                SFDCAccessController accessAG = ExAMUtilClass.AccessController;
                List<string> fieldsListAG = new List<string>{'ExAM__Type__c'};
                accessAG.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Assessment_Group__c'), fieldsListAG);

                for (Assessment_Group__c assGrp : [SELECT Id, Name, Type__c FROM Assessment_Group__c WHERE Type__c =:assessableObject Limit 1000]) {
                    assessmentGroups.add(new SelectOption(assGrp.Id, assGrp.Name));    
                    /*if (firstField) { 
                        assessmentGroup = assGrp.Id;    
                        firstField = false;
                    }*/
                }
                assessmentGroups = sortSelectOptionList(assessmentGroups);
                //assessmentGroups 

                SFDCAccessController accessMPCC = ExAMUtilClass.AccessController;
                List<string> fieldsListMPCC = new List<string>{'ExAM__Assessible_Object__c', 'ExAM__Assessible_Object_Field__c', 'ExAM__Color_Mapping__c'};
                accessMPCC.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Map_Pin_Color_Configuration__c'), fieldsListMPCC);

                for (Map_Pin_Color_Configuration__c pincolorconfig : [SELECT Assessible_Object__c, Assessible_Object_Field__c, Color_Mapping__c, Id, Name FROM Map_Pin_Color_Configuration__c WHERE Assessible_Object__c = :assessableObject Limit 1000]) {
                    pinColorConfigurationList.add(new SelectOption( pincolorconfig.Assessible_Object_Field__c+'~'+pincolorconfig.Color_Mapping__c, pincolorconfig.Name));
                }
                pinColorConfigurationList = sortSelectOptionList(pinColorConfigurationList);
            }

            if (assessmentGroup != null && assessmentGroup != '') {

                assessmentEvents.add(new SelectOption('','--None--'));
                Set<Id> eventIdSet = new Set<Id>();

                SFDCAccessController accessAM = ExAMUtilClass.AccessController;
                List<string> fieldsListAM = new List<string>{'ExAM__Assessment_Group__c', 'ExAM__Assessment_Event__c'};
                accessAM.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__IssueRequest_Life_Cycle__c'), fieldsListAM);

                for (IssueRequest_Life_Cycle__c am : [SELECT Assessment_Group__c, Assessment_Event__c, Assessment_Event__r.Name, Id, Name
                                                      FROM   IssueRequest_Life_Cycle__c 
                                                      WHERE  Assessment_Group__c != null 
                                                             AND Assessment_Event__c != null
                                                             AND Assessment_Group__c =: assessmentGroup]) {

                    if (!eventIdSet.contains(am.Assessment_Event__c)) {
                        assessmentEvents.add(new SelectOption( am.Assessment_Event__c, am.Assessment_Event__r.Name));
                        eventIdSet.add(am.Assessment_Event__c);
                    }
                }
                assessmentEvents = sortSelectOptionList(assessmentEvents);
            }

            if (assessableObjects.size() == 0) {
                assessableObjects.add(new SelectOption('','--None--'));
            }
            if (assessmentGroups.size() == 0) {
                assessmentGroups.add(new SelectOption('','--None--'));
            }
            if (assessmentEvents.size() == 0) {
                assessmentEvents.add(new SelectOption('','--None--'));
            }
            if (pinColorConfigurationList.size() == 0) {
                pinColorConfigurationList.add(new SelectOption('','--None--'));
            }
        }
        catch(Exception e) {
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()) );
        }
    }

    public void assessableObjectChanged()
    {

        try {
            assessmentGroup = '';
            assessmentEvent = '';
            colormapping = '';
            assessmentGroups = new List<SelectOption>();
            assessmentEvents = new List<SelectOption>();
            pinColorConfigurationList = new List<SelectOption>();

            Boolean firstField = true;        
            if (assessableObject != null && assessableObject != '') {
                assessmentGroups.add(new SelectOption('','--None--'));

                SFDCAccessController accessAG = ExAMUtilClass.AccessController;
                List<string> fieldsListAG = new List<string>{'ExAM__Type__c'};
                accessAG.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Assessment_Group__c'), fieldsListAG);

                for (Assessment_Group__c assGrp : [SELECT Id, Name, Type__c FROM Assessment_Group__c WHERE Type__c =:assessableObject Limit 1000]) {
                    assessmentGroups.add(new SelectOption(assGrp.Id, assGrp.Name));    
                    /*if (firstField) { 
                        assessmentGroup = assGrp.Id;    
                        firstField = false;
                    }*/
                }
                assessmentGroups = sortSelectOptionList(assessmentGroups);
                //assessmentGroups 

                SFDCAccessController accessMPCC = ExAMUtilClass.AccessController;
                List<string> fieldsListMPCC = new List<string>{'ExAM__Assessible_Object__c', 'ExAM__Assessible_Object_Field__c', 'ExAM__Color_Mapping__c'};
                accessMPCC.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Map_Pin_Color_Configuration__c'), fieldsListMPCC);

                for (Map_Pin_Color_Configuration__c pincolorconfig : [SELECT Assessible_Object__c, Assessible_Object_Field__c, Color_Mapping__c, Id, Name FROM Map_Pin_Color_Configuration__c WHERE Assessible_Object__c = :assessableObject Limit 1000]) {
                    pinColorConfigurationList.add(new SelectOption( pincolorconfig.Assessible_Object_Field__c+'~'+pincolorconfig.Color_Mapping__c, pincolorconfig.Name));
                }
                pinColorConfigurationList = sortSelectOptionList(pinColorConfigurationList);
            }
        
            if (assessmentGroup != null && assessmentGroup != '') {
        
                assessmentEvents.add(new SelectOption('','--None--'));
                Set<Id> eventIdSet = new Set<Id>();

                SFDCAccessController accessAM = ExAMUtilClass.AccessController;
                List<string> fieldsListAM = new List<string>{'ExAM__Assessment_Group__c', 'ExAM__Assessment_Event__c'};
                accessAM.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__IssueRequest_Life_Cycle__c'), fieldsListAM);

                for (IssueRequest_Life_Cycle__c am : [SELECT Id, Name, Assessment_Group__c, Assessment_Event__c, Assessment_Event__r.Name 
                                                      FROM   IssueRequest_Life_Cycle__c 
                                                      WHERE  Assessment_Group__c != null 
                                                             AND Assessment_Event__c != null
                                                             AND Assessment_Group__c =: assessmentGroup]) {

                    if (!eventIdSet.contains(am.Assessment_Event__c)) {
                        assessmentEvents.add(new SelectOption( am.Assessment_Event__c, am.Assessment_Event__r.Name));
                        eventIdSet.add(am.Assessment_Event__c);
                    }   
                }
                assessmentEvents = sortSelectOptionList(assessmentEvents);
            }
            if (assessmentGroups.size() == 0) {
                assessmentGroups.add(new SelectOption('','--None--'));
            }
            if (assessmentEvents.size() == 0) {
                assessmentEvents.add(new SelectOption('','--None--'));
            }
            if (pinColorConfigurationList.size() == 0) {
                pinColorConfigurationList.add(new SelectOption('','--None--'));
            }
        }
        catch(Exception e) {
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()) );
        }
    }

    public void assessmentGroupChanged()
    {

        try {
            assessmentEvent = '';
            assessmentEvents = new List<SelectOption>();

            if (assessmentGroup != null && assessmentGroup != '') {
                assessmentEvents.add(new SelectOption('','--None--'));

                Set<Id> eventIdSet = new Set<Id>();

                SFDCAccessController accessAM = ExAMUtilClass.AccessController;
                List<string> fieldsListAM = new List<string>{'ExAM__Assessment_Group__c', 'ExAM__Assessment_Event__c'};
                accessAM.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__IssueRequest_Life_Cycle__c'), fieldsListAM);

                for (IssueRequest_Life_Cycle__c am : [SELECT Id, Name, Assessment_Group__c, Assessment_Event__c, Assessment_Event__r.Name 
                                                        FROM IssueRequest_Life_Cycle__c 
                                                        WHERE Assessment_Group__c != null 
                                                        AND Assessment_Event__c != null
                                                        AND Assessment_Group__c =: assessmentGroup]) {

                    if (!eventIdSet.contains(am.Assessment_Event__c)) {
                        assessmentEvents.add(new SelectOption( am.Assessment_Event__c, am.Assessment_Event__r.Name));
                        eventIdSet.add(am.Assessment_Event__c);
                    }   
                }
                assessmentEvents = sortSelectOptionList(assessmentEvents);
            }
            if (assessmentEvents.size() == 0) {
                assessmentEvents.add(new SelectOption('','--None--'));
            }
        }
        catch(Exception e) {
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()) );
        }
    }
    
    public boolean getshowhead()
    {
        string userAgent =ApexPages.currentPage().getHeaders().get('USER-AGENT');
        if(userAgent.contains('iPhone')) {
            return false;
        }
        else {
            return true;
        }
    }

    public PageReference submitmap()
    {
        if (assessmentGroup == '' || assessmentGroup == null || assessmentGroup == '--None--') {
            ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select a Assessment Group');
            ApexPages.addMessage( errMsg );
            return null;
        }
        else {

            System.debug(':::::selectedmappingValues::::'+selectedmappingValues);
            string MappingGroup = '';
            /*Boolean flag = true;
            for (string mappingG : selectedmappingValues) {
                if(flag) {
                    MappingGroup += mappingG;
                    flag = false;
                } else {
                    MappingGroup += ';'+mappingG;
                }
            }*/

            MappingGroup = string.join(selectedmappingValues, ';');
            System.debug(':::::MappingGroup::::'+MappingGroup);
            string url;boolean priority=false;boolean status=false;boolean AssessmentCompletion=false;
            PageReference newocp;
            for(string ss:MapType)
            {
                if(ss.equalsIgnoreCase('priority'))
                {
                    priority=true;
                }
                if(ss.equalsIgnoreCase('status'))
                {
                    status=true;
                }
                if(ss.equalsIgnoreCase('AssessmentCompletion'))
                {
                    AssessmentCompletion=true;      
                }
            }
            string encodedcolormapping = (string.isNotBlank(colormapping) ) ? EncodingUtil.urlEncode(colormapping, 'UTF-8') : '';
            string encodedscheduledFrom = (string.isNotBlank(scheduledFrom) ) ? EncodingUtil.urlEncode(scheduledFrom, 'UTF-8') : '';
            string encodedscheduledTo = (string.isNotBlank(scheduledTo) ) ? EncodingUtil.urlEncode(scheduledTo, 'UTF-8') : '';

            if((showUsers==null) || (showUsers==false))
            {
                newocp = new PageReference( '/apex/AssessmentMapUserImplementor?priority='+priority+'&status='+status+'&AssessmentCompletion='+AssessmentCompletion+'&ColorBy='+encodedcolormapping+'&showUsers=false'+'&AccMapGroup='+MappingGroup+'&AMStatus='+statusVal+'&AMpriority='+priorityVal+'&AMassessmentCompletion='+assessmentCompletionVal+'&AMassessmentType='+assessmentTypeVal+'&AssessableObj='+assessableObject+'&AssessmentGrp='+assessmentGroup+'&AssessmentEvt='+assessmentEvent+'&scheduledFrom='+encodedscheduledFrom+'&scheduledTo='+encodedscheduledTo );
            }
            else
            {
                newocp = new PageReference( '/apex/AssessmentMapUserImplementor?priority='+priority+'&status='+status+'&AssessmentCompletion='+AssessmentCompletion+'&ColorBy='+encodedcolormapping+'&showUsers=true'+'&AccMapGroup='+MappingGroup+'&AMStatus='+statusVal+'&AMpriority='+priorityVal+'&AMassessmentCompletion='+assessmentCompletionVal+'&AMassessmentType='+assessmentTypeVal+'&AssessableObj='+assessableObject+'&AssessmentGrp='+assessmentGroup+'&AssessmentEvt='+assessmentEvent+'&scheduledFrom='+encodedscheduledFrom+'&scheduledTo='+encodedscheduledTo );
            }
            newocp.setRedirect(true);
            return newocp;
        }
        return null;
    }

    public List<SelectOption> getMappingGroup() {
        List<SelectOption> options = new List<SelectOption>();        
        Schema.DescribeFieldResult fieldResult =  Account.Mapping_Group__c.getDescribe();        
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();        
        for( Schema.PicklistEntry f : ple) {
            options.add(new SelectOption(f.getLabel(), f.getValue()));
        }
        options = sortSelectOptionList(options);
        return options;
    }

    public List<SelectOption> getAMStatus() {
        List<SelectOption> options = new List<SelectOption>();        
        Schema.DescribeFieldResult fieldResult =  IssueRequest_Life_Cycle__c.Status__c.getDescribe();        
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();        
        options.add(new SelectOption('All','All'));
        for (Schema.PicklistEntry f : ple) {
            options.add(new SelectOption(f.getLabel(), f.getValue()));
        }
        options = sortSelectOptionList(options);
        return options;
    }

    public List<SelectOption> getAMPriority() {
        List<SelectOption> options = new List<SelectOption>();        
        Schema.DescribeFieldResult fieldResult =  IssueRequest_Life_Cycle__c.Priority__c.getDescribe();        
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();        
        options.add(new SelectOption('All','All'));
        for (Schema.PicklistEntry f : ple) {
            options.add(new SelectOption(f.getLabel(), f.getValue()));
        }
        options = sortSelectOptionList(options);
        return options;
    }

    public List<SelectOption> getAMAssessmentCompletion() {
        List<SelectOption> options = new List<SelectOption>();        
        Schema.DescribeFieldResult fieldResult =  IssueRequest_Life_Cycle__c.Assessment_Form_Completion__c.getDescribe();        
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();        
        options.add(new SelectOption('All','All'));
        for (Schema.PicklistEntry f : ple) {
            options.add(new SelectOption(f.getLabel(), f.getValue()));
        }
        options = sortSelectOptionList(options);
        return options;
    }    
    public List<SelectOption> getAMAssessmentType() {
        List<SelectOption> options = new List<SelectOption>();        
        options.add(new SelectOption('All', 'All'));
        Schema.DescribeFieldResult fieldResult =  IssueRequest_Life_Cycle__c.Investigation_Type__c.getDescribe();        
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();        
        for (Main_questionaire__c assTemp : assessmentTempList) {
            options.add(new SelectOption(assTemp.Id, assTemp.Template_name__c));
        }
        return options;
    }
    public static List<SelectOption> sortSelectOptionList(List<SelectOption> source) {
        List<string> sortable = new  LIst<string>();
        Map<string,string> valAndlabelMap = new Map<string,string>();
        
        for(SelectOption so: source)
        {
            if(string.isNotBlank(so.getLabel()) && string.isNotBlank(so.getValue())) {
                sortable.Add(so.getLabel().toUpperCase() + '@!@' + so.getValue());
                valAndlabelMap.put(so.getValue(),so.getLabel());
            }
        }
        // sort the list
        sortable.sort();
        List<SelectOption> targetList = new  List<SelectOption>();
        // split the value/name components and re create the list
        for(string s: sortable)
        {
            string val = s.split('@!@')[1];
            string label = valAndlabelMap.get(s.split('@!@')[1]);
            targetList.Add(new SelectOption(val, label));
         
        }
        return targetList;
    }
    /*public List<SelectOption> getAssessableObjects() {
        List<SelectOption> options = new List<SelectOption>();
        Map<string, Schema.SObjectField> schemaFieldMap = Schema.SObjectType.IssueRequest_Life_Cycle__c.fields.getMap();
        for (Schema.SObjectField fld : schemaFieldMap.values()) {
            Schema.DescribeFieldResult res = fld.getdescribe();
            System.debug('res::1::'+res);
            if (string.valueOf(res.getType()).touppercase() == 'REFERENCE' && res.isCustom() && res.getName().startsWithIgnoreCase('AM_')) {
                System.debug('::::::3:::'+res.getReferenceTo().size());
                if (res.getReferenceTo() != null && res.getReferenceTo().size() > 0) {
                    List<Schema.sObjectType> sobTypeList = res.getReferenceTo();
                    Schema.DescribeSObjectResult assessableObject = sobTypeList[0].getDescribe();
                    System.debug(':::::::'+assessableObject.getName()+'::::'+assessableObject.getLabel());
                    options.add(new SelectOption(assessableObject.getName(),assessableObject.getLabel()));    
                }
                //options.add(new SelectOption(,'test'));
            }                
        }
        return options;
    }*/

    public static testMethod void testlistacc()
    {
        AssessmentMapBuilderController d= new AssessmentMapBuilderController();
        Test.startTest();  
        ApexPages.currentPage().getHeaders().put('USER-AGENT','iPhone');
        d.MapType.add('status');
        d.getshowhead();d.submitmap();
        System.assert(d.MapType!=null);
        Test.stopTest();   
    }
}