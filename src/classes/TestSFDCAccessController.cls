@isTest
public class TestSFDCAccessController {
    static testMethod void method1(){
        SFDCAccessController sfdc = new SFDCAccessController();
        Schema.sObjectType stype = Account.getSObjectType();
        sObject sObj = new Account();
        Map<String,Schema.SObjectField> fMap = sfdc.getFieldMap(stype);
        List<Schema.SObjectField> fieldList = sfdc.getViewableFields(stype);
        List<Schema.SObjectField>  fieldList1 = sfdc.getViewableFields(sObj);
        List<String> fldList = new List<String>{
            'Name'
        };
        sfdc.assertAuthorizedToView(stype, fieldList);
        //sfdc.assertAuthorizedToCreate(stype, fieldList);
        //sfdc.assertAuthorizedToUpdate(stype, fieldList);
        
    }
    static testMethod void method2(){
        SFDCAccessController sfdc = new SFDCAccessController();
        Schema.sObjectType stype = Account.getSObjectType();
        sObject sObj = new Account();
        Map<String,Schema.SObjectField> fMap = sfdc.getFieldMap(stype);
        List<Schema.SObjectField> fieldList = sfdc.getViewableFields(stype);
        List<Schema.SObjectField>  fieldList1 = sfdc.getViewableFields(sObj);
        List<String> fldList = new List<String>{
            'Name'
        };
        
        sfdc.assertAuthorizedToView(stype,fldList);
        sfdc.assertAuthorizedToCreate(stype, fldList);
        sfdc.assertAuthorizedToUpdate(stype, fldList);
    }
    static testMethod void method3(){
        SFDCAccessController sfdc = new SFDCAccessController();
        Schema.sObjectType stype = Account.getSObjectType();
        sObject sObj = new Account();
        Map<String,Schema.SObjectField> fMap = sfdc.getFieldMap(stype);
        List<Schema.SObjectField> fieldList = sfdc.getViewableFields(stype);
        List<Schema.SObjectField>  fieldList1 = sfdc.getViewableFields(sObj);
        List<String> fldList = new List<String>{
            'Name'
        };
        sfdc.isAuthorizedToView(stype, fieldList);
        sfdc.isAuthorizedToCreate(stype, fieldList);
        sfdc.isAuthorizedToUpdate(stype, fieldList);
        sfdc.isAuthorizedToDelete(stype);
        List<Schema.SObjectField> fList = sfdc.getUpdateableFields(fMap);
        List<Schema.SObjectField> fList1 = sfdc.getUpdateableFields(sObj);
        List<Schema.SObjectField> fList2 = sfdc.getCreatableFields(fMap);
        List<Schema.SObjectField> fList3 = sfdc.getCreatableFields(sObj);
    }
    static testMethod void method4(){
        SFDCAccessController sfdc = new SFDCAccessController();
        Schema.sObjectType stype = Account.getSObjectType();
        sObject sObj = new Account();
        Map<String,Schema.SObjectField> fMap = sfdc.getFieldMap(stype);
        List<Schema.SObjectField> fieldList = sfdc.getViewableFields(stype);
        List<Schema.SObjectField>  fieldList1 = sfdc.getViewableFields(sObj);
        List<String> fldList = new List<String>{
            'Name'
        };
        sfdc.isAuthorizedToView(stype, fldList);
        sfdc.isAuthorizedToCreate(stype, fldList);
        sfdc.isAuthorizedToUpdate(stype, fldList);
    }
}