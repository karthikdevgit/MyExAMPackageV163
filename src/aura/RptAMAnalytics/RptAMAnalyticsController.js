({
    handleSelect : function(cmp, event, helper){
        var selectedItem = event.getParam("value");     
        var analyticsRptParams = cmp.get("v.analyticsRptParams");
        analyticsRptParams["searchingCriteria"] = selectedItem;
        cmp.set("v.analyticsRptParams", analyticsRptParams);
        helper.fetchAMAnalyticsResponse(cmp, event, helper);
    },
    scriptsLoaded : function(cmp, event, helper){
        helper.fetchAMAnalyticsResponse(cmp, event, helper);
    }
})