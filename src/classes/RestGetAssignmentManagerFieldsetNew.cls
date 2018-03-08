@RestResource(urlMapping='/ASMFieldsetNew/*')
global with sharing class RestGetAssignmentManagerFieldsetNew {

    @HttpPost
    global static String getAssignmentManagerFieldsetNew() {
    
        String showInspection;
        Map<String,String> customLabelMap = new Map<String,String>();
        customLabelMap.put('Primary_Assessment_Type',Label.Primary_Assessment_Type);
        customLabelMap.put('Related_Assessment_Type_1',Label.Related_Assessment_Type_1);
        customLabelMap.put('Related_Assessment_Type_2',Label.Related_Assessment_Type_2);
        customLabelMap.put('Related_Assessment_Type_3',Label.Related_Assessment_Type_3);
        customLabelMap.put('Related_Assessment_Type_4',Label.Related_Assessment_Type_4);
        customLabelMap.put('Related_Decision_Tree_Chain_Button',Label.Related_Decision_Tree_Chain_Button);
        customLabelMap.put('Assessable_Record_Tab_Name',Label.Assessable_Record_Tab_Name);
        customLabelMap.put('Mobile_Assignment_Manager_Label',Label.Mobile_Assignment_Manager_Label);
        customLabelMap.put('Mobile_File_Upload_Label',Label.Mobile_File_Upload_Label);
        
        List<string> fieldset = new List<String>{'Unit_City__c','Unit_ST__c','Unit_Zip__c','Year_Built__c','Housing_Type__c','Other_Housing_Type_Comments__c','Special_Housing_Type__c','Lead_Free_Certificate__c','General_Unit_Comments__c','Number_of_Sleeping_Rooms__c','Unit_Qualification_Comments__c','Rooms_Tenant_is_Using_for_Sleeping__c','Agent_Email_Address__c','PHA_Code__c','Unit_Size__c','Living_Room_Present__c','Kitchen_Present__c','Bathroom_Present__c','Number_of_Full_Bathrooms__c','Number_of_Half_Bathrooms__c','Separate_Entrance__c','SRO_Space_Requirement__c','Name','Owner.Name','Parent.Name','Description'};
        List<string> fieldset1 = new List<String>{'UPCS_V_Pass_or_Fail__c','Room__c','LTE__c','Location__c','Section_Name__c','Floor_Number__c',
                      'Responsibility_of_Repair__c','Defect_Level__c','ExAM__Question_Label__c','ExAM__Comment__c','ExAM__Issue_Request__c'};
        
        showInspection = MobileAppUtill.returnASM('Account',fieldset,'');
        if(showInspection == 'true'){
        
            showInspection = MobileAppUtill.returnASM('ExAM__Questionnaire_Response__c',fieldset1,'');
        }
        customLabelMap.put('showInspection',showInspection);
        ExAMUtilClass.AssessableObjectDetails assObjWrapperInstance = new ExAMUtilClass.AssessableObjectDetails();
        assObjWrapperInstance = ExAMUtilClass.getAssessableObjectDetails('ExAM__IssueRequest_Life_Cycle__c');
        
        for(String assApi:assObjWrapperInstance.objectAndFieldAPIMap.keySet()){
            Map<String, String> tempParentReferenceMap = new Map<String, String>();
            tempParentReferenceMap = ExAMUtilClass.getParentReferenceMapFromSobject(assApi);
            if(tempParentReferenceMap.size() > 0){
                assObjWrapperInstance.objectAndFieldAPIMap.put(assApi,tempParentReferenceMap.get(assApi));
            }else{
                assObjWrapperInstance.objectAndFieldAPIMap.remove(assApi);
            }
        }
        
        AssessableObjectFieldset assObjFieldset = new AssessableObjectFieldset();
        assObjFieldset.ASMFieldset = MobileAppUtill.returnASMFieldset(null);
        assObjFieldset.customLabelMap = customLabelMap;
        assObjFieldset.assObjWrapperInstance = assObjWrapperInstance;
        
        return JSON.serialize(assObjFieldset);
    }
    
    global class AssessableObjectFieldset {
        ExAMUtilClass.AssessableObjectDetails assObjWrapperInstance;
        Map<String,String> customLabelMap = new Map<String,String>();
        String ASMFieldset;
    }
}