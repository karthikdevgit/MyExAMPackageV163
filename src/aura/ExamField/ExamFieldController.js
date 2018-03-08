({
    doInit : function(cmp, event, helper) {
        
        var type = cmp.get("v.valType");
        var cmpName;
        var attrs = {
            "fieldLabel" : cmp.get("v.fieldLabel"),
            "fieldName" : cmp.get("v.fieldName"),
            "record"  : cmp.getReference("v.record"),
            "Id" : cmp.get("v.Id"),
            "sObjectName" : cmp.get("v.sObjectAPI"),
            "options" : cmp.get("v.options") || '',
            "attachment" : cmp.get("v.attachment") || '',
            "defaultMode" : cmp.get("v.defaultMode"),
            "mode" : cmp.get("v.mode"),
            'newField' : cmp.get("v.newField"),
            "sourceDerivenCmp" : cmp.get("v.sourceDerivenCmp"),
            "identifierCmp" : cmp.get("v.identifierCmp"),
            "helpText" : cmp.get("v.helpText"),
            "validator" : cmp.getReference("v.validator"),
            "hasValidator": cmp.get("v.hasValidator"),
            "isValid" : cmp.get("v.isValid")
        };
      if(type === "TEXTAREA" ){
            cmpName = "c:ExamTextArea";
            helper.createExamField(cmp, event, helper, attrs, cmpName);
        }
        if(type === "STRING"){
            cmpName = "c:ExamTextFld";
            helper.createExamField(cmp, event, helper, attrs, cmpName);
        }
        if(type === "BOOLEAN"){
            cmpName = "c:ExamCheckBoxFld";
            helper.createExamField(cmp, event, helper, attrs, cmpName);
        }
        if(type === "URL"){
            cmpName = "c:ExamUrlFld";
            helper.createExamField(cmp, event, helper, attrs, cmpName);
        }
        if(type === "PICKLIST" ){
            cmpName = "c:ExamPickListFld";
            helper.createExamField(cmp, event, helper, attrs, cmpName);
        }
        if(type === "DOUBLE"){
            cmpName = "c:ExamDoubleFld";
            helper.createExamField(cmp, event, helper, attrs, cmpName);
        }
        if(type === "CURRENCY"){
            cmpName = "c:ExamCurrencyFld";
            helper.createExamField(cmp, event, helper, attrs, cmpName);
        }
        if(type === "PERCENT"){
            cmpName = "c:ExamPercentageFld";
            helper.createExamField(cmp, event, helper, attrs, cmpName);
        }
        if(type === "REFERENCE" && cmp.get("v.sObjectAPI") == "ExAM__Question_Template__c" ){
            cmpName = "c:ExamReferenceFld";
            helper.createExamField(cmp, event, helper, attrs, cmpName);
        }
        if(type === "DATE"){
            cmpName = "c:ExamDateFld";
            attrs["aura:id"] = "dateFld";
            helper.createExamField(cmp, event, helper, attrs, cmpName);
            
        }

    }
})