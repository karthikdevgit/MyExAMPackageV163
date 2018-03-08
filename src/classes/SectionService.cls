public with sharing class SectionService {
    
    public static String sObjectName = 'Section_Template__c';
    
    public static List<String> fieldSets = new List<String>{('ExAM__lightningComp_SectionOptions_FieldSet'), 	    
	        									('ExAM__lightningCmp_AdvanceSecOptions_FieldSet')};
    
    
    public static List<Section_Template__c> moveSectionUpOrDown(String assessmentId, Decimal index, String direction){
        Integer indexInteger = (Integer) index;
        
        List<Section_Template__c> sectionTemplates = getSectionsByAssessmentId(assessmentId);
        
        if(direction == 'up'){
            sectionTemplates[indexInteger].Order_No__c = sectionTemplates[indexInteger].Order_No__c - 1; // current Section move up so decrement orderNo - 1 
            sectionTemplates[indexInteger-1].Order_No__c = sectionTemplates[indexInteger].Order_No__c + 1; // previous section move down so increment orderNo + 1
        }
        
        if(direction == 'down'){
            sectionTemplates[indexInteger].Order_No__c = sectionTemplates[indexInteger].Order_No__c + 1; // current Section move Down so increment orderNo + 1
            sectionTemplates[indexInteger+1].Order_No__c = sectionTemplates[indexInteger+1].Order_No__c - 1; // next section move up so decrement orderNo - 1
        }
        try{
            String fields = 'Order_No__c';
            FieldLevelSecurity.checkFieldAccessByCriteria(fields, 'update', sObjectName);
            update sectionTemplates;
            AssessmentService.updateAssessmentDueToChildUpdates(assessmentId);
        }
        catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
        return sectionTemplates;
    }
    
    
    // get Without Archive Sections By Assessment Id
    public static List<Section_Template__c> getSectionsByAssessmentId(String assessementId){
        try{
            String fields = 'Name, Section_label__c, isArchive__c, Questionnaire_Section__c, No_of_Questions_Section__c, Order_No__c';
            
            fields = ExamDescribeHelper.getFieldsFromFieldSet(fieldSets, fields, 'ExAM__Section_Template__c'); // call method for field set 
            
            FieldLevelSecurity.checkFieldAccessByCriteria(fields, 'view', sObjectName);
            
            String sectionQuery = 'SELECT '+fields+ 
                +' FROM Section_Template__c WHERE Questionnaire_Section__c =\''+ assessementId+'\'' +' and isArchive__c = false ORDER BY Order_No__c ASC';
            
            List<Section_Template__c> sec = Database.query(sectionQuery);
            
            
            return sec;
        }
        catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    // get Sections By Assessment Id
    public static List<Section_Template__c> getSectionsWthArchiveByAssessmentId(String assessementId){
        try{
            String fields = 'Name, Section_label__c, isArchive__c, Questionnaire_Section__c, No_of_Questions_Section__c, Order_No__c';
            fields = ExamDescribeHelper.getFieldsFromFieldSet(fieldSets, fields, 'ExAM__Section_Template__c'); // call method for field set 
            FieldLevelSecurity.checkFieldAccessByCriteria(fields, 'view', sObjectName);
            
            String sectionQuery = 'SELECT '+fields+ 
                +' FROM Section_Template__c WHERE Questionnaire_Section__c =\''+ assessementId+'\'' +' ORDER BY Order_No__c ASC';
            List<Section_Template__c> sec = Database.query(sectionQuery);
            
            
            return sec;
        }
        catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    // Archive Section 
    public static Section_Template__c archiveSection(String sectionId, String assessmentId){
        Section_Template__c sectionTemplate = new Section_Template__c();
        sectionTemplate.Id = sectionId;
        sectionTemplate.isArchive__c = true;
        
        try{
            String fields = 'isArchive__c';
            FieldLevelSecurity.checkFieldAccessByCriteria(fields, 'update', sObjectName);
            update sectionTemplate;
            //String assessmentId = sectionTemplates[0].Questionnaire_Section__c;
            AssessmentService.updateAssessmentDueToChildUpdates(assessmentId);
        }
        catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
        
        return sectionTemplate;
    }
    // create New Section 
    public static List<Section_Template__c> createSection(Section_Template__c section, Integer orderNo){
        orderNo = Integer.valueOf(orderNo);
        String assessmentId = section.Questionnaire_Section__c;
        Integer position;
        List<Section_Template__c> sectionTemplates = getSectionsWthArchiveByAssessmentId(assessmentId);
        
        if(orderNo == null){ 	// if orderNo is null, set orderNo and Index position value as sectionTemplates size 
            orderNo = sectionTemplates.size(); 
            position = orderNo;
        }else{					// else set index position as orderNo
            position = orderNo;
        }
        
        orderNo++;  // increament orderNo 
        
        if(sectionTemplates.size() == position){ 
            sectionTemplates.add(section); 	// Add Section to sectionTemplates last 
        }else{
            sectionTemplates.add(position,section); // Add Section to sectionTemplates position
        }
        
        for(Integer i = position; i < sectionTemplates.size(); i++){
            sectionTemplates[position].Order_No__c = orderNo;	// change orderNo From which index add Section 
            position++;
            orderNo++;
        }
        try{
            String fields = 'Order_No__c, Section_label__c, Section_Description__c';
            FieldLevelSecurity.checkFieldAccessByCriteria(fields, 'create', sObjectName);
            fields = 'Order_No__c';
            FieldLevelSecurity.checkFieldAccessByCriteria(fields, 'update', sObjectName);
            upsert sectionTemplates;
        }
        catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
        
        AssessmentService.updateAssessmentDueToChildUpdates(assessmentId); // update Assessment
        sectionTemplates = filterWthOutArchiveSection(sectionTemplates);
        return sectionTemplates;
    }
    // get Section by Section Id
    public static Section_Template__c getSection(String recordId){
        try{
            String fields = 'Section_label__c, Questionnaire_Section__c, Order_No__c';
            fields = ExamDescribeHelper.getFieldsFromFieldSet(fieldSets, fields, 'ExAM__Section_Template__c'); // call method for field set 
            FieldLevelSecurity.checkFieldAccessByCriteria(fields, 'view', 'ExAM__Section_Template__c');
            
            String sectionQuery = 'SELECT '+fields+ 
                +' FROM Section_Template__c WHERE Id =\''+ recordId+'\'';
            List<Section_Template__c> sec = Database.query(sectionQuery);
            
           
            return sec[0];
        }
        catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
        
    }
    // move Section 
    public static Map<String, List<Section_Template__c>> moveSection(String oldAssessmentId, String newAssessmentId, String direction, Integer index, String recordId){
        String fields = 'Order_No__c';
        
        Integer removePosition;
        Integer orderNo;
        Integer indexpos = Integer.valueOf(index);
        Map<String, List<Section_Template__c>> oldToNewSectionTemplate = new Map<String, List<Section_Template__c>>();
        List<Section_Template__c> fromSectionTemplate;
        List<Section_Template__c> toSectionTemplate;
        
        Section_Template__c moveSection = getSection(recordId); // get move Section by section Id
        
        fromSectionTemplate = getSectionsWthArchiveByAssessmentId(oldAssessmentId); // get Source SectionTemplates
        
        
        for(Integer i = 0; i < fromSectionTemplate.size(); i++){
            
            if(fromSectionTemplate[i].Id == recordId){ // find Remove Position 
                removePosition = i;
                break;
            }
            
        }
        
        
        if(newAssessmentId != null){ 
            toSectionTemplate = getSectionsWthArchiveByAssessmentId(newAssessmentId); // get destination SectionTemplates
            moveSection.Questionnaire_Section__c = newAssessmentId; // Move Section's Assessment Id changed
            fields +=', Questionnaire_Section__c';
        }else{		
            toSectionTemplate = fromSectionTemplate; 	// set source as destination sectionTemplates
            if(removePosition > indexpos){
                removePosition++;
            }
        }
        
        
        
        if(toSectionTemplate.isEmpty()){ // destination is Empty
            indexpos = 0;
            orderNo = indexpos+1;
            moveSection.Order_No__c = orderNo;
            toSectionTemplate.add(moveSection);
        }else{
            // check direction 
            if(direction == 'After'){
                orderNo = indexpos+2; 
                moveSection.Order_No__c = orderNo;
                
                if(toSectionTemplate.size() == indexpos+1){ // check SectionTemplates size and Position equal? 
                    toSectionTemplate.add(moveSection); // add Section in Last position of SectionTemplates 
                }else{
                    toSectionTemplate.add(indexpos+1, moveSection); // add Section in which position moved  
                }
                
            }else{
                
                orderNo = indexpos + 1;
                moveSection.Order_No__c = orderNo;
                toSectionTemplate.add(indexpos, moveSection);
            }
            
        }
        
        
        Integer position = orderNo;
        
        // update orderNo From which position added Section
        for(Integer i = position; i < toSectionTemplate.size(); i++){
            toSectionTemplate[position].Order_No__c = toSectionTemplate[position].Order_No__c + 1; 
            position++;
            orderno++;
        }
        
        if(newAssessmentId != null){
            
            try{
                FieldLevelSecurity.checkFieldAccessByCriteria(fields, 'update', sObjectName);
                update toSectionTemplate;
                AssessmentService.updateAssessmentDueToChildUpdates(newAssessmentId); // update Assessment
                //toSectionTemplate = upsertRecords(toSectionTemplate);
            }
            catch(Exception e){
                throw new AuraHandledException(e.getMessage());
            }
            
            toSectionTemplate = filterWthOutArchiveSection(toSectionTemplate);
            
            oldToNewSectionTemplate.put('toSectionTemplate',toSectionTemplate);
        }else{
            fromSectionTemplate = toSectionTemplate;
        }
        
        if(!fromSectionTemplate.isEmpty()){
            String assessmentId = fromSectionTemplate[0].Questionnaire_Section__c;
            if(fromSectionTemplate.size() == 1){
                List<Section_Template__c> emptyList = new List<Section_Template__c>();
                fromSectionTemplate = emptyList;
            }else{
                fromSectionTemplate.remove(removePosition); // remove move Section From Source Section Templates
                orderNo = removePosition;
                // update orderNo from remove Section position
                for(Integer i = removePosition; i < fromSectionTemplate.size(); i++){
                    fromSectionTemplate[removePosition].Order_No__c = fromSectionTemplate[removePosition].Order_No__c - 1;
                    removePosition++;
                    orderno++;
                }
                try{
                    FieldLevelSecurity.checkFieldAccessByCriteria(fields, 'update', sObjectName);
                    update fromSectionTemplate;
                    //fromSectionTemplate = upsertRecords(fromSectionTemplate);
                }
                catch(Exception e){
                    throw new AuraHandledException(e.getMessage());
                }
                
                fromSectionTemplate = filterWthOutArchiveSection(fromSectionTemplate);
            }
            AssessmentService.updateAssessmentDueToChildUpdates(assessmentId);
            oldToNewSectionTemplate.put('formSectionTemplate', fromSectionTemplate);
        }
        
        return oldToNewSectionTemplate;
    }
    
    public static Map<String, List<Object>> copySectionWithRelatedQuestions(String toassessmentId, String direction, Integer index, String recordId){
        Map<String, List<Object>> copySectionWithQuestionAndAttachment = new Map<String, List<Object>>();
        
        Map<String,object> responseMap = SectionService.copySection(toassessmentId, direction, index, recordId);
        String newSectionId = String.valueOf(responseMap.get('newSectionId'));
        copySectionWithQuestionAndAttachment.put('copySection',(List<object>)responseMap.get('updateRecords'));
        
        Map<String, object> infoQuesIdWithQues = QuestionService.cloneQuestionsBySectionId(newSectionId, recordId);
        Map<String,String> questionOldIdWthNewId = (Map<String,String>)infoQuesIdWithQues.get('questionId');
        Map<String,String> questionOldIdWthNewIdWthOutAnswer = (Map<String,String>)infoQuesIdWithQues.get('AttachmentCopyByQuestionId');
        
        
        Map<String, Answer_Option__c> cloneAnswerOptions = AnswerOptionService.cloneAnswerOptionsByQuesId(questionOldIdWthNewId);
        List<Attachment> cloneAttachments = AttachmentService.copyAttachments(cloneAnswerOptions);
        List<Attachment> cloneAttachmentsByQuestion = AttachmentService.copyAttachmentsByQuesId(questionOldIdWthNewIdWthOutAnswer);
        List<Attachment> cloneImageQuestion = AttachmentService.copyQuestionImage(questionOldIdWthNewId);
        
        List<Question_Template__c> copyQuestions = QuestionService.filterGetNonDependentQuestions((List<Question_Template__c>)infoQuesIdWithQues.get('questionTemp'));
        copySectionWithQuestionAndAttachment.put('copyQuestion', copyQuestions);
        
        Map<Id, Question_Template__c> non_dependentQuestionsWthId = new Map<Id, Question_Template__c>(copyQuestions);
        Set<Id> nonDependentQuestionIds = non_dependentQuestionsWthId.keySet();
        Map<Id, Answer_Option__c> idWthAnswers = new Map<Id, Answer_Option__c>();
        Set<Id> AnswersIdsOfnonDependentQuestion = idWthAnswers.keySet();
        
        for(Answer_Option__c answerOption : cloneAnswerOptions.values()){
            if(nonDependentQuestionIds.contains(answerOption.Question_Template__c)){
                idWthAnswers.put(answerOption.Id, answerOption);
            }
        }
        
        List<Attachment> AttachmentsOfnonDependentQuestions = new List<Attachment>();
        for(Attachment attach : cloneAttachments){
            if(AnswersIdsOfnonDependentQuestion.contains(attach.ParentId)){
                AttachmentsOfnonDependentQuestions.add(attach);
            }
        }

		List<Attachment> cloneImageQuestionOfNonDependentQuestions = new List<Attachment>();
        for(Attachment attach : cloneImageQuestion){
            if(nonDependentQuestionIds.contains(attach.ParentId)){
            	cloneImageQuestionOfNonDependentQuestions.add(attach);
            }
        }
        
        List<Attachment> AttachmentsOfnonDependentQuestionsWthOutAns = new List<Attachment>();
        for(Attachment attach : cloneAttachmentsByQuestion){
            if(nonDependentQuestionIds.contains(attach.ParentId)){
                AttachmentsOfnonDependentQuestionsWthOutAns.add(attach);
            }
        }
        
        //Map<String,Answer_Option__c> idWthAnswers = new Map<String,Answer_Option__c>((List<Answer_Option__c>)cloneAnswerOptions.values());
        List<Answer_Option__c> answerOptionsList = [SELECT Id,Name,Order_No__c,Dependent_Question__r.Name,Dependent_Question__r.Question_Label__c,Help_Text__c,Next_Question__r.Name,Next_Question__r.Question_Label__c, Weight__c,Question_Template__c FROM Answer_Option__c WHERE Id IN :idWthAnswers.keySet()];
        copySectionWithQuestionAndAttachment.put('answerOptions',answerOptionsList);
        
        
        
        AssessmentService.updateAssessmentDueToChildUpdates(toassessmentId); // update Assessment
        
        copySectionWithQuestionAndAttachment.put('copyAttachment',AttachmentsOfnonDependentQuestions); 
        copySectionWithQuestionAndAttachment.put('cloneAttachmentsByQuestion',AttachmentsOfnonDependentQuestionsWthOutAns); 
        copySectionWithQuestionAndAttachment.put('cloneImageQuestion',cloneImageQuestionOfNonDependentQuestions);
        
        return copySectionWithQuestionAndAttachment;
    }
    
    public static Map<String,object> copySection(String toAssessmentId, String direction, Integer index, String recordId){
        String fields = 'Order_No__c';
        
        Integer indexPos = Integer.valueOf(index);
        Integer orderno;
        Integer position;
        
        Map<String,object> responseMap = new Map<String,Object>();
        List<Section_Template__c> sectionTemplates = getSectionsWthArchiveByAssessmentId(toAssessmentId); //get destination sectionTemplates
        
        Section_Template__c copySectionTemplate = getSection(recordId); // get Copy Section 
        
        copySectionTemplate.Id = null;  // set copy Section Id null 
        
        
        if(copySectionTemplate.Questionnaire_Section__c != toAssessmentId){  // check copy Section's Assessment Id and destination Assessment Id not Equal?
            copySectionTemplate.Questionnaire_Section__c = toAssessmentId; // change copy Section's Assessment Id to destination Assessment Id
            fields += ', Questionnaire_Section__c';
        }
        
        
        if(sectionTemplates.isEmpty()){
            indexPos = 0;
            orderno = indexPos+1;
            copySectionTemplate.Order_No__c = orderno;
            sectionTemplates.add(copySectionTemplate);
        }else{ // check direction 
            
            if(direction == 'After'){
                orderno = indexPos+2;
                copySectionTemplate.Order_No__c = orderno;
                indexPos = indexPos+1;
                
                if(sectionTemplates.size() == indexPos){
                    sectionTemplates.add(copySectionTemplate); // Add copy Section in last Position of SectionTemplates, if templates's size and index Position Equal
                }else{
                    sectionTemplates.add(indexPos, copySectionTemplate);    //Add copy Section in Which position Copied in SectionTemplates 
                }
                
            }
            
            if(direction == 'Before'){
                orderno = indexPos+1;
                copySectionTemplate.Order_No__c = orderno;
                sectionTemplates.add(indexPos, copySectionTemplate); 
            }
            
        }
        
        
        position = orderno;
        
        // update OrderNo From Which position copied in sectionTemplates 
        for(Integer i = position; i < sectionTemplates.size(); i++){
            sectionTemplates[position].Order_No__c = sectionTemplates[position].Order_No__c + 1;
            position++;
            orderno++;
        }
        try{
            FieldLevelSecurity.checkFieldAccessByCriteria(fields, 'create', sObjectName);
            fields ='Order_No__c';
            FieldLevelSecurity.checkFieldAccessByCriteria(fields, 'update', sObjectName);
            upsert sectionTemplates;
            
        }
        catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
        
        responseMap.put('newSectionId', sectionTemplates[indexPos].Id);
        sectionTemplates = filterWthOutArchiveSection(sectionTemplates);
        responseMap.put('updateRecords', sectionTemplates);
        return responseMap;
    }
    // filter without Archive Sections From Sections
    public static List<Section_Template__c> filterWthOutArchiveSection(List<Section_Template__c> sectionTemplates){
        List<Section_Template__c> sectionTemplatesWthoutArchive = new List<Section_Template__c>();
        for(Integer i = 0; i < sectionTemplates.size(); i++){
            
            if(sectionTemplates[i].isArchive__c == false){
                sectionTemplatesWthoutArchive.add(sectionTemplates[i]); // added in list whitout Archive Section 
            }
            
        }
        return sectionTemplatesWthoutArchive;
    }
    
}