@isTest
public class TestResultTemplateConfigurationCtrller {

    static testmethod void method1() {

        Viewer_Custom_Configuration__c vc = new Viewer_Custom_Configuration__c();
        vc.Name ='Viewer 1';
        insert vc;

        Main_questionaire__c[] templateList = new Main_questionaire__c[] {
            new Main_questionaire__c(Template_name__c = 'General Safety', Viewer_Configuration__c = vc.Id),
            new Main_questionaire__c(Decision_Tree__c = 'exam__deficiency_status__c:true:false~exam__Priority__c:true:true', Template_name__c = 'General Instructions', Viewer_Configuration__c = vc.Id)
        };
        insert templateList;

        Section_Template__c[] sectionTemplateList = new Section_Template__c[] {
            new Section_Template__c(Questionnaire_Section__c = templateList[0].Id, Section_label__c = 'General Safety Section'),
            new Section_Template__c(Questionnaire_Section__c = templateList[1].Id, Section_label__c = 'General Instructions Section')
        };
        insert sectionTemplateList;

        Question_Template__c[] questionTemplateList = new Question_Template__c[] {
            new Question_Template__c(Question_Label__c = 'Result Question 1', Question_Type__c = 'Result', Section_Question__c = sectionTemplateList[0].Id),
            new Question_Template__c(Decision_Tree__c = 'exam__deficiency_status__c:Open~exam__Priority__c:High', Question_Label__c = 'Result Question 2', Question_Type__c = 'Result', Section_Question__c = sectionTemplateList[1].Id)
        };
        insert questionTemplateList;

        List<ResultTemplateConfigurationController.FieldVisibilityClass> fieldVisibilityList1 = new List<ResultTemplateConfigurationController.FieldVisibilityClass>();
        List<ResultTemplateConfigurationController.FieldDefaultValueClass> fieldDefaultValueList1 = new List<ResultTemplateConfigurationController.FieldDefaultValueClass>();

        ApexPages.currentPage().getParameters().put('assessmentTemplateId', templateList[0].Id);
        ApexPages.currentPage().getParameters().put('questionTemplateId', questionTemplateList[0].Id);
        ResultTemplateConfigurationController resultTemplateConfigCtrller1 = new ResultTemplateConfigurationController();

        for(ResultTemplateConfigurationController.FieldVisibilityClass f : resultTemplateConfigCtrller1.fieldVisibilityList) {
            f.hasSelected = true;
            fieldVisibilityList1.add( f );
        }

        Integer i1 = 1;
        for(ResultTemplateConfigurationController.FieldDefaultValueClass f : resultTemplateConfigCtrller1.fieldDefaultValueList) {

            f.defaultValue = 'TEST DEFAULT VALUE '+i1;
            fieldDefaultValueList1.add( f );
            i1++;
        }

        List<ExAM__Main_questionaire__c> tempListBeforeSave = new List<ExAM__Main_questionaire__c>([SELECT ExAM__Decision_Tree__c, Id, Name FROM ExAM__Main_questionaire__c WHERE Id = :templateList[0].Id]);
        system.assertEquals(tempListBeforeSave[0].ExAM__Decision_Tree__c, null);
        
        ResultTemplateConfigurationController.TemplateClass templateCls = new ResultTemplateConfigurationController.TemplateClass();
        templateCls.id = templateList[0].Id;
        templateCls.resultQuesButtonText = 'Submit';
        templateCls.fieldVisibilityList = fieldVisibilityList1;
        ResultTemplateConfigurationController.saveFieldVisibility(JSON.serializePretty(templateCls));
        resultTemplateConfigCtrller1.saveFieldDefaultValues();
        
        
        List<ResultTemplateConfigurationController.FieldVisibilityClass> fieldVisibilityList2 = new List<ResultTemplateConfigurationController.FieldVisibilityClass>();
        List<ResultTemplateConfigurationController.FieldDefaultValueClass> fieldDefaultValueList2 = new List<ResultTemplateConfigurationController.FieldDefaultValueClass>();

        ApexPages.currentPage().getParameters().put('assessmentTemplateId', templateList[1].Id);
        ApexPages.currentPage().getParameters().put('questionTemplateId', questionTemplateList[1].Id);
        ResultTemplateConfigurationController resultTemplateConfigCtrller2 = new ResultTemplateConfigurationController();

        for(ResultTemplateConfigurationController.FieldVisibilityClass f : resultTemplateConfigCtrller2.fieldVisibilityList) {

            f.hasSelected = true;
            fieldVisibilityList2.add( f );
        }

        Integer i2 = 1;
        for(ResultTemplateConfigurationController.FieldDefaultValueClass f : resultTemplateConfigCtrller2.fieldDefaultValueList) {

            f.defaultValue = 'TEST DEFAULT VALUE '+i2;
            fieldDefaultValueList2.add( f );
            i2++;
        }
        ResultTemplateConfigurationController.TemplateClass tempCls = new ResultTemplateConfigurationController.TemplateClass();
        tempCls.id = templateList[0].Id;
        tempCls.resultQuesButtonText = 'Submit';
        tempCls.fieldVisibilityList = fieldVisibilityList2;
        ResultTemplateConfigurationController.saveFieldVisibility(JSON.serializePretty(tempCls));
        resultTemplateConfigCtrller2.saveFieldDefaultValues();

        List<ExAM__Main_questionaire__c> tempListAfterSave = new List<ExAM__Main_questionaire__c>([SELECT ExAM__Decision_Tree__c, Id, Name FROM ExAM__Main_questionaire__c WHERE Id = :templateList[0].Id]);
        system.assertNotEquals(tempListAfterSave[0].ExAM__Decision_Tree__c, null);
    }
}