({
    doInit : function(cmp, event, helper) {
        
        var menuItems = [
            {label: "This Week", value: "THIS_WEEK"},
            {label: "Last Week", value: "LAST_WEEK"},
            {label: "This Month", value: "THIS_MONTH"},
            {label: "Last Month", value: "LAST_MONTH"},
            {label: "This Year", value: "THIS_YEAR"},
            {label: "Last Year", value: "LAST_YEAR"},
            {label: "Last 2 Years", value: "LAST_N_YEARS:2"}
        ];
        
        var analyticsRptParams = {
            "assessmentId" : cmp.get("v.assessmentId"),
            "searchingCriteria" : cmp.get("v.selectedItem")
        };
        cmp.set("v.analyticsRptParams", analyticsRptParams);
        cmp.set("v.menuItems", menuItems);
        
        /*helper.toggleSpinner(cmp, event, helper);
        $A.createComponent(
            "c:RptAMAnalytics",
            {
                "apexMethodName" : cmp.get("v.apexMethodName"),
                "analyticsRptParams" : analyticsRptParams,
                "title" : cmp.get("v.title"),
                "chartType" : cmp.get("v.chartType"),
                "menuItems" : menuItems
            },
            function(AmRptChartCmp, status, errorMessage){
                helper.toggleSpinner(cmp, event, helper);
                if(status === "SUCCESS"){
                    var widgetContainer = cmp.find("widgetContainer");
                    var body = widgetContainer.get("v.body");
                    body.push(AmRptChartCmp);
                    widgetContainer.set("v.body", body);
                    
                }else if(status === "ERROR"){
                    message = message.split('at org')[0];
                    helper.showNotificationEvt('error', message);
                }else if(status === "INCOMPLETE"){
                    var errorMsg = 'No response from server or client is offline';
                    helper.showNotificationEvt('error', errorMsg);
                }
            }
        );*/
    },
    
})