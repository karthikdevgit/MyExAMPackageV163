public with sharing class FieldLevelSecurity {
    public static SFDCAccessController access = ExAMUtilClass.AccessController;
    public static String NameSpacePrefix = ExAMUtilClass.getNameSpacePrefix();
    
    public static void checkFieldAccessByCriteria(String fields, String criteria, String sObjectName){
        List<String> fieldsWthNameSpace = new List<String>();
        Set<String> SystemFields = new Set<String>{'Id'};
            if(fields != null){
                for(String field : fields.split(',')){
                    field = field.trim();
                    if(!SystemFields.contains(field)){
                        
                        if(field.startsWith(NameSpacePrefix)){
                            fieldsWthNameSpace.add(field);
                        }else if(field.endsWith('__c')){
                            fieldsWthNameSpace.add(NameSpacePrefix+field);
                        }else{
                            fieldsWthNameSpace.add(field);
                        }
                        
                    }
                }
                if(sObjectName != null && !sObjectName.startsWith(NameSpacePrefix) && sObjectName.endsWith('__c')){
                    sObjectName = NameSpacePrefix + sObjectName;
                }
            }
        
        checkCriteria(criteria, sObjectName, fieldsWthNameSpace);
    }
    
    public static void checkFieldAccessByCriteria(String fields, String criteria, String sObjectName, Boolean doNotAddNS){
        
        List<String> fieldsList = new List<String>();
        Set<String> SystemFields = new Set<String>{'Id'};
            
        	if(fields != null){
                
                for(String field : fields.split(',')){
                    field = field.trim();
                    if(!SystemFields.contains(field)){
                        
                        if(doNotAddNS){ //Do Not add Namespace
                            fieldsList.add(field);
                        } else { //Check and add Namespace if applicable
                            if(field.startsWith(NameSpacePrefix)){
                                fieldsList.add(field);
                            } else if(field.endsWith('__c')){
                                fieldsList.add(NameSpacePrefix+field);
                            } else{
                                fieldsList.add(field);
                            }
                        }
                    }
                }
            }   
            
			if(!doNotAddNS && sObjectName != null && !sObjectName.startsWith(NameSpacePrefix) && sObjectName.endsWith('__c')){
            	sObjectName = NameSpacePrefix + sObjectName;
            }

    	checkCriteria(criteria, sObjectName, fieldsList);
    }
    
    public static void checkObjectAccessByDelete(String sObjectName){
        if(sObjectName != null && !sObjectName.startsWith(NameSpacePrefix) && sObjectName.endsWith('__c')){
            sObjectName = NameSpacePrefix + sObjectName;
        }
        access.isAuthorizedToDelete(Schema.getGlobalDescribe().get(sObjectName));
        
        
    }
    
    public static Void checkObjectAccessByCreate(String sObjectName){
        if(sObjectName != null && !sObjectName.startsWith(NameSpacePrefix) && sObjectName.endsWith('__c')){
            sObjectName = NameSpacePrefix + sObjectName;
        }
        access.isAuthorizedToCreate(Schema.getGlobalDescribe().get(sObjectName));
        
        
    }
    public static Void checkObjectAccessByView(String sObjectName){
        if(sObjectName != null && !sObjectName.startsWith(NameSpacePrefix) && sObjectName.endsWith('__c')){
            sObjectName = NameSpacePrefix + sObjectName;
        }
        access.isAuthorizedToView(Schema.getGlobalDescribe().get(sObjectName));
        
        
    }
    public static Void checkObjectAccessByUpdate(String sObjectName){
        if(sObjectName != null && !sObjectName.startsWith(NameSpacePrefix) && sObjectName.endsWith('__c')){
            sObjectName = NameSpacePrefix + sObjectName;
        }
        access.isAuthorizedToUpdate(Schema.getGlobalDescribe().get(sObjectName));
        
    }
    
    public static void checkCriteria(String criteria, String sObjectName, List<String> fieldsWthNameSpace){
        if(criteria != null){
            
            if(criteria == 'create'){
                access.assertAuthorizedToCreate(Schema.getGlobalDescribe().get(sObjectName), fieldsWthNameSpace);
            }else if(criteria == 'view'){
                access.assertAuthorizedToView(Schema.getGlobalDescribe().get(sObjectName), fieldsWthNameSpace);
            }else if(criteria == 'update'){
                access.assertAuthorizedToUpdate(Schema.getGlobalDescribe().get(sObjectName), fieldsWthNameSpace);
            }
            
        }
        
    }
}