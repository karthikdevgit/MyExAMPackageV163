({
    /** Attach Exam NameSpace in Window Object becz it's one step improved security level 
     * methods/variables added in window Object it might potentially override of
     * another subscribers/customers inject variables/methods in window Object
     ***/
    doInit : function(cmp, event, helper) {
        window.Exam = {
            
        };
        cmp.set("v.generateChlidCmp", true);
    }
})