({
    doInit : function(cmp, event, helper) {
        
        var SectionTemplates = cmp.get("v.SectionTemplates");
        
        if(SectionTemplates && SectionTemplates.length){
            helper.findOrderNoOfLastSection(cmp, event, helper, SectionTemplates);
        }
        
        if(cmp.get("v.showSection")){
            var hideBtn = cmp.find("addBtnlast");
            var div = cmp.find("newSectionLast");
            var position = 0;
            var orderNo;
            helper.builtNewSection(cmp, event, helper, hideBtn, div, "last", position, orderNo);
        }
        
    },
    addNewSectionLast : function(cmp, event, helper){
        var hideBtn = cmp.find("addBtnlast");
        var div = cmp.find("newSectionLast");
        var position = event.currentTarget.getAttribute("data-index");
        cmp.set("v.position", cmp.get("v.SectionTemplates").length);
        var orderNo = parseInt(event.currentTarget.getAttribute("data-item"), 10);
        helper.builtNewSection(cmp, event, helper, hideBtn, div, "last", position, orderNo);
    },
    addNewSection: function(cmp, event, helper) {
        var hideBtn = cmp.find("addBtn");
        var div = cmp.find("newSection");
        var position = event.currentTarget.getAttribute("data-index");
        cmp.set("v.position", parseInt(position, 10));
        var orderNo = event.currentTarget.getAttribute("data-item");
        helper.builtNewSection(cmp, event, helper, hideBtn, div, "", position, orderNo);
        
    },
    changeAssessmentTemplate : function(cmp, event,helper){
        var assessmentId = event.getParam("assessmentId");
        
        
        if(cmp.get("v.assessmentId") === assessmentId){
            var isExpand = event.getParam("isExpand");
            
            window.Exam.SectionServiceComponent.fetchSecTemplate(assessmentId, $A.getCallback(function(sectionTemplates) {
                if(cmp.isValid()){
                    
                    cmp.set("v.SectionTemplates", sectionTemplates);
                    
                    if(sectionTemplates.length){
                         helper.findOrderNoOfLastSection(cmp, event, helper, sectionTemplates);
                    }else{
                        cmp.set("v.lastSec_OrderNo", null);
                    }
                    
                    window.setTimeout(
                        $A.getCallback(function() {
                            
                            if (cmp.isValid()) {
                                
                                var sectionEditor = cmp.find("sectionEditor");
                                
                                
                                if(sectionEditor && !Array.isArray(sectionEditor)){
                                    sectionEditor = [sectionEditor];
                                }
                                
                                if(isExpand && sectionEditor){
                                    var position = cmp.get("v.position");
                                    if(sectionTemplates.length > position ){
                                        
                                        sectionEditor[position].set("v.position", position);
                                        sectionEditor[position].doInitMethod();
                                        helper.toggleExpanded(cmp, position);
                                    }
                                    
                                }
                                
                            }
                            
                        }), 0
                    );
                }
            }), null);
            
        }
        
    },
    toggleExpanded : function(cmp, event, helper){
        var index = event.getParam("index");
        
        cmp.set("v.position", parseInt(index, 10));
        helper.toggleExpanded(cmp, index);
        
    },
    cancelAction : function(cmp, event){
        var position = event.getParam("position");
        var whichBtn = event.getParam("whichBtn");
        var hideBtn;
        if(whichBtn === 'last'){
            hideBtn = cmp.find("addBtnlast");
            
            if(!Array.isArray(hideBtn)){
                hideBtn = [hideBtn];
            }
            
        }else{
            hideBtn = cmp.find("addBtn");
            
        }
        $A.util.toggleClass(hideBtn[position], "slds-hide");
    },
    editStateOn : function(cmp, event, helper){
        var type = event.getParam("type");
        if(type === "sectionContainer"){
            event.stopPropagation();
            helper.editViewOnRelatedToChild(cmp, helper);
        }
    },
    viewStateOn : function(cmp, event, helper){
        var type = event.getParam("type");
        if(type === "sectionContainer"){
            event.stopPropagation();
            helper.fireToggleEditView(cmp, cmp.get("v.assessmentId"), "doneEditingView");
            cmp.set("v.showBtns", true);
            var sectionEditors = cmp.find("sectionEditor");
            
            if(sectionEditors){
                sectionEditors = helper.constructArrayElements(sectionEditors);
                var Id = event.getParam("Id");
                for(var index = 0; index < sectionEditors.length; index++){
                    // child has sectiontemplate? then get id 
                    if(sectionEditors[index].get("v.SectionTemplate") && Id == sectionEditors[index].get("v.SectionTemplate").Id){
                        
                        if($A.util.hasClass(sectionEditors[index].find("ctrlLink"), "disable")){		// CtrlLinkMenu is disable?
                            $A.util.removeClass(sectionEditors[index].find("ctrlLink"), "disable");
                            $A.util.removeClass(sectionEditors[index].find("expand"), "disable");
                        }else{
                            $A.util.removeClass(sectionEditors[index].find("sectionView"), "disable");	
                        }
                        
                        sectionEditors[index].enableQuestionView();
                    }else{
                        $A.util.removeClass(sectionEditors[index], "disable");
                    }
                }
            }
            
        }
    }
})