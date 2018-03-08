({
    geneateRptAM : function(cmp, event, helper) {
        var chartdiv = cmp.find("chart").getElement();
        
        if(cmp.get("v.chartType") == 'serial'){
            var chart = AmCharts.makeChart(chartdiv, {
                "theme": "light",
                "type": "serial",
                "startDuration": 2,
                "dataProvider": cmp.get("v.analyticResponses"),
                "graphs": [{
                    "balloonText": "<b>[[value]]</b>",
                    "fillColorsField": "color",
                    "fillAlphas": 1,
                    "lineAlpha": 0.1,
                    "type": "column",
                    "valueField": "Yaxis"
                }],
                "depth3D": 20,
                "angle": 30,
                "rotate": true,
                "chartCursor": {
                    "categoryBalloonEnabled": false,
                    "cursorAlpha": 0,
                    "zoomable": false
                },
                "categoryField": "Xaxis",
                "categoryAxis": {
                    "gridPosition": "start",
                    "labelRotation": 90
                },
                "export": {
                    "enabled": true
                }
            });
        }else if(cmp.get("v.chartType") == "pie"){
            var chart = AmCharts.makeChart(chartdiv, {
                "type": "pie",
                "theme": "light",
                "dataProvider": cmp.get("v.analyticResponses"),
                "valueField": "Yaxis",
                "titleField": "Xaxis",
                "outlineAlpha": 0.4,
                "labelText" : "[[title]]",
                "depth3D": 15,
                "legend": {
                    "maxColumns" : 2,
                    "textClickEnabled" : true,
                    "align" : "center",
                    "enabled" : false
                },
                "colors" : ['#3366CC', '#DC3912', '#FF9900', '#109618',
                            '#990099', '#3B3EAC', '#0099C6', '#DD4477', 
                            '#66AA00', '#B82E2E', '#316395', '#994499',
                            '#22AA99', '#AAAA11', '#6633CC', '#E67300', 
                            '#8B0707', '#329262', '#5574A6', '#3B3EAC'],
                "balloonText": "<span style='font-size:14px'><b>[[value]]</b></span>",
                "angle": 30,
                "export": {
                    "enabled": true
                }
            });
        }
        
    },
    fetchAMAnalyticsResponse : function(cmp, event, helper){
        var methodName = cmp.get("v.apexMethodName");
        var amRptWthResponseByCriteria = cmp.get("v.amRptWthResponseByCriteria") || {};
        var searchCriteria = cmp.get("v.analyticsRptParams").searchingCriteria || 'status';
        var searchCriteriaResponse = amRptWthResponseByCriteria[methodName] || {};
        
        if(!amRptWthResponseByCriteria.hasOwnProperty(methodName) || !searchCriteriaResponse.hasOwnProperty(searchCriteria)){
           
            helper.toggleSpinner(cmp, event, helper);
            var action = cmp.get("c."+methodName);
            action.setParams(cmp.get("v.analyticsRptParams"));
            action.setCallback(this, function(response){
                helper.toggleSpinner(cmp, event, helper);
                var status = response.getState();
                
                if(status === "SUCCESS"){
                    searchCriteriaResponse[searchCriteria] = response.getReturnValue();
                    amRptWthResponseByCriteria[methodName] = searchCriteriaResponse;
                    cmp.set("v.amRptWthResponseByCriteria", JSON.parse(JSON.stringify(amRptWthResponseByCriteria)));
                    cmp.set("v.analyticResponses", response.getReturnValue());
                    helper.geneateRptAM(cmp, event, helper);
                }else if(state === "ERROR"){
                    helper.buildErrorMsg(cmp, response.getError(), null, helper);
                }else if(state === "INCOMPLETE"){
                    helper.buildOffLineMsg(cmp, helper, null);
                }
            });
            $A.enqueueAction(action);
            
            
        }else{
            searchCriteriaResponse = amRptWthResponseByCriteria[methodName];
            cmp.set("v.analyticResponses", searchCriteriaResponse[searchCriteria]);
            helper.geneateRptAM(cmp, event, helper);
        }
        
    },
    toggleSpinner : function(cmp, event, helper) {
        var loading = cmp.find("loading");
        $A.util.toggleClass(loading, "slds-hide");
    },
    showNotificationEvt : function(cmp, status, message, time){
        var showNotificationEvent = $A.get("e.c:notificationEvt");
        showNotificationEvent.setParams({
            "action" : status,
            "message" : message,
            "time" : time
        });
        showNotificationEvent.fire();
    },
    buildErrorMsg : function(cmp, errors, time, helper){
        var errorMsg = "";
        
        if(errors[0] && errors[0].message){  // To show other type of exceptions
            errorMsg = errors[0].message;
        }else if(errors[0] && errors[0].pageErrors.length) {  // To show DML exceptions
            errorMsg = errors[0].pageErrors[0].message; 
        }else if(errors[0] && errors[0].fieldErrors){  // To show field exceptions
            var fields = Object.keys(errors[0].fieldErrors);
            var field = fields[0];
            errorMsg = errors[0].fieldErrors[field];
            errorMsg = errorMsg[0].message;
        }else if(errors[0] && errors[0].duplicateResults.length){ // To show duplicateResults exceptions
            errorMsg = errors[0].duplicateResults[0].message;
        }else{
            errorMsg = "Unknown errors";
        }
        
        helper.showNotificationEvt(cmp, "error", errorMsg, time);
    },
    buildOffLineMsg : function(cmp, helper, time){
        var errorMsg = "No response from server or client is offline.";
        helper.showNotificationEvt(cmp, "error", errorMsg, time);
    }
})