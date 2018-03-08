@isTest
private class TestPublicAssessmentLinkCSVcontroller {

    static testMethod void PAMethod() {
        
        Account acc = new Account();
        acc.Name = 'Test';
        insert acc;
        
        Viewer_Custom_Configuration__c viewerRec = new Viewer_Custom_Configuration__c();
        insert viewerRec;
        
        List<Main_questionaire__c> assTemp = new List<Main_questionaire__c> {
            new Main_questionaire__c(Viewer_Configuration__c =viewerRec.Id,Template_name__c= 'testTemplate1'),
            new Main_questionaire__c(Viewer_Configuration__c =viewerRec.Id,Template_name__c= 'testTemplate2'),
            new Main_questionaire__c(Viewer_Configuration__c =viewerRec.Id,Template_name__c= 'testTemplate3')
        };
        insert assTemp;
        
        List<Section_Template__c> secTemp = new List<Section_Template__c> {
            new Section_Template__c(Questionnaire_Section__c = assTemp[0].Id),
            new Section_Template__c(Questionnaire_Section__c = assTemp[1].Id),
            new Section_Template__c(Questionnaire_Section__c = assTemp[2].Id)
        };
        insert secTemp;
        
        List<Question_Template__c> quesTemp = new List<Question_Template__c> {
            new Question_Template__c(Section_Question__c = secTemp[0].Id)
        };
        insert quesTemp;
        
        IssueRequest_Life_Cycle__c amList = new IssueRequest_Life_Cycle__c ();
        amList.InvestigationType__c = assTemp[0].Id;
        amList.Facility_Name__c = acc.Id;
        insert amList;
        
        Assignment_Generator_Batch__c assGen = new Assignment_Generator_Batch__c();
        assGen.Assessment_Template__c = assTemp[0].Id;
        assGen.No_Of_Records__c = 3;
        insert assGen;
        
        List<Public_Assessment__c> paList = new  List<Public_Assessment__c> {
            new Public_Assessment__c(Assessment_Template__c =assTemp[0].Id,Facility_Name__c= acc.Id,Assignment_Manager__c = amList.Id,Assignment_Generator_Batch__c =assGen.Id),
            new Public_Assessment__c(Assessment_Template__c =assTemp[0].Id,Facility_Name__c= acc.Id,Assignment_Manager__c = amList.Id,Assignment_Generator_Batch__c =assGen.Id),
            new Public_Assessment__c(Assessment_Template__c =assTemp[0].Id,Facility_Name__c= acc.Id,Assignment_Manager__c = amList.Id,Assignment_Generator_Batch__c =assGen.Id)
        };
        insert paList;
        
        ApexPages.currentPage().getParameters().put('agId',assGen.Id);
        String PAQueryFields = '';
        List<Schema.FieldSetMember> PAObjFieldsList = new List<Schema.FieldSetMember>();
        
        if(paList != null && paList.size() >0) {

             if(assGen.Id != null) {
        
                PAObjFieldsList = SObjectType.Public_Assessment__c.FieldSets.ExAM__Link_Generator.getFields();
                
                if( PAObjFieldsList != null && PAObjFieldsList.size() > 0) {
                
                    PAQueryFields += 'Id,Name,';
                    
                    for(Schema.FieldSetMember f : PAObjFieldsList) { 
                        if(!PAQueryFields.contains(f.getFieldPath())) {
                            PAQueryFields += f.getFieldPath() + ',';
                        }
                    }
                    
                } else {
                    PAQueryFields += 'Id,Name,ExAM__Public_Assessment_URL__c';
                }
                if (PAQueryFields.endsWith(',')) {
                    PAQueryFields = PAQueryFields.substring(0, PAQueryFields.length()-1);
                }
            }
        }
        
        String queryStr = 'SELECT '+PAQueryFields+' FROM ExAM__Public_Assessment__c WHERE';
        queryStr += ' ExAM__Assignment_Generator_Batch__c = \''+assGen.Id+'\'';
        PublicAssessmentLinkCSVcontroller PALink = new PublicAssessmentLinkCSVcontroller();
        PublicAssessmentLinkCSVcontroller.PARecordClass paRecs = PublicAssessmentLinkCSVcontroller.queryPArecords(queryStr,true,new List<String>());
        
        system.assertEquals(paRecs.statusMsg, 'Processing');
    }
}