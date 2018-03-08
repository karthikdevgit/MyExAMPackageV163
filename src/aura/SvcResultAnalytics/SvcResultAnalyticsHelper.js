({
    //Make Report 
    fetchReportByMethod: function(param, onSuccess, onError, apexMethodName, cmp, data, chartType, helper) {
        helper.toggleSpinner(cmp);
        var action = cmp.get("c." + apexMethodName);
        action.setParams(param);
        action.setStorable();
        action.setCallback(this, function(response) {
            var state = response.getState();
            
            if (cmp.isValid() && state === "SUCCESS") {
                var returnData = response.getReturnValue();
                var hasData = false;
                
                if(returnData.length){
                    hasData = true;
                }
                
                var chartData = helper.createJSONStructure(cmp, helper, param.searchCriteria, returnData, apexMethodName, data, chartType);
                chartData = JSON.stringify(chartData);
                onSuccess(chartData, hasData);
            } else if(cmp.isValid() && state === "ERROR"){
                
                if (!onError) {
                    helper.buildErrorMsg(cmp, response.getError(), null, helper);
                } else {
                    onError(response.getError());
                }
            }else if(cmp.isValid() && state === "INCOMPLETE"){
                var errorMsg = "No response from server or client is offline.";
                helper.showNotificationEvt(cmp, "error", errorMsg, time);
            }
            helper.toggleSpinner(cmp);
        });
        
        $A.enqueueAction(action);
    },
    showBarChartByWeek : function(cmp, searchCriteria, labels, returnData, dataSet, helper){
        var currentDate; 
        
        if(searchCriteria === "THIS_WEEK"){
            currentDate = new Date(); // get current date
        }else if(searchCriteria === "LAST_WEEK"){
            currentDate = helper.getLastWeek(cmp);
        }
        
        var firstDay = currentDate.getDate() - currentDate.getDay(); // First day is the day of the month - the day of the week
        var lastDay = firstDay + 6; // last day is the first day + 6
       
        // push day as label
        for(var i = firstDay; i <= lastDay; i++){
            var date = new Date(currentDate.setDate(i));
            date = date.getFullYear() + '-' + (date.getMonth()+1) + '-' + date.getDate();
            labels.push(date);
        }
        
        // push dataSet value 
        helper.setDataSetValue(returnData, labels, dataSet);
        
    },
    getLastWeek : function(cmp){
        var today = new Date();
        var lastWeek = new Date(today.getFullYear(), today.getMonth(), today.getDate() - 7);
        return lastWeek ;
    },
    // get No Of Weeks In Month, The first week is from the first through the seventh day of the month.
    getWeeksInMonth : function(month, year){
        var weeks=[],
            //firstDate=new Date(year, month, 1),
            lastDate=new Date(year, month+1, 0), 
            numDays= lastDate.getDate();
        
        var start = 1;
        var end = 7;//-firstDate.getDay();
        while(start <= numDays){
            weeks.push({start : start, end : end, "numberOfDays" : numDays});
            start = end + 1;
            end = end + 7;
            
            if(end > numDays){
                end = numDays;      
            }
            
        }        
        return weeks;
    },
    showBarChartByMonth : function(cmp, searchCriteria, labels, returnData, dataSet, helper){
        var currentDate = new Date();
        var weeks = [];
        
        if(searchCriteria === "THIS_MONTH"){
            weeks = helper.getWeeksInMonth(currentDate.getMonth(), currentDate.getFullYear());
        }else if(searchCriteria === "LAST_MONTH"){
            weeks = helper.getWeeksInMonth(currentDate.getMonth()-1, currentDate.getFullYear());
        }
        // push week as label 
        for(var i = 0; i < weeks.length; i++){
            labels.push("week"+(1+i)); 
        }
        
        // push dataSet value 
        helper.setDataSetValue(returnData, labels, dataSet);
        
    },
    
    showBarChartByYear : function(cmp, searchCriteria, labels, returnData, dataSet, helper){
        var year,
            currentDate = new Date();
        
        if(searchCriteria === "THIS_YEAR"){
            year = currentDate.getFullYear();
        }else if(searchCriteria === "LAST_YEAR"){
            year = currentDate.getFullYear() - 1;
        }
        // constant value months of year 
        labels = ["January","February","March","April","May","June","July","August","September","October","November","December"];
        
        // push dataSet value 
        helper.setDataSetValue(returnData, labels, dataSet);
        
        return labels;
    },
    showBarChartByYears : function(cmp, searchCriteria, labels, returnData, dataSet, helper){
        var years = searchCriteria.split(':');
        var currentDate = new Date();
        var year = currentDate.getFullYear();
        
        if(years[1]){
            var n = years[1];
            var j = n;
            for(var i = 1; i <= n; i++){
                labels.push(year - j);
                j--;
            }
        }
        
        if(returnData.length){
            var k = 0;
            for(i = 0; i < labels.length; i++){
                if(returnData[k] && returnData[k].expr1 === labels[i]){
                    dataSet.push(returnData[k].expr0);
                    k++;
                }else{
                    dataSet.push(0);
                }
            }
        }
        
    },
    createJSONStructure : function(cmp, helper, searchCriteria, returnData, apexMethodName, data, chartType){
        var chartData = {};  
        var dataInfo = {};
        var labels = [];
        var datasets = [];
        var dataobj = {};
        var dataSet = [];
        
        dataobj["data"] = dataSet;
        dataobj["backgroundColor"] = data._backgroundColor;
        
        if(chartType === "bar"){
            dataobj["borderColor"] = data._borderColor;
            dataobj["borderWidth"] = data._borderWidth;
            dataobj["fill"] = false;
            
            if(searchCriteria === "THIS_WEEK" || 
               searchCriteria === "LAST_WEEK"){
                helper.showBarChartByWeek(cmp, searchCriteria, labels, returnData, dataSet, helper);
            }else if(searchCriteria === "THIS_MONTH" || 
                     searchCriteria === "LAST_MONTH"){
                helper.showBarChartByMonth(cmp, searchCriteria, labels, returnData, dataSet, helper);
            }else if(searchCriteria === "THIS_YEAR" || searchCriteria === "LAST_YEAR"){
                labels = helper.showBarChartByYear(cmp, searchCriteria, labels, returnData, dataSet, helper);
            }else{
                helper.showBarChartByYears(cmp, searchCriteria, labels, returnData, dataSet, helper);
            }
            
        }else if(chartType === "line"){
            dataobj["fill"] = false;
            dataobj["lineTension"] = 0.1;
        }else if(chartType === "pie"){
            for (var i = 0; i < returnData.length; i++) {
                dataSet.push(returnData[i].expr0);
                labels.push(returnData[i].ExAM__Status__c);
            }
        }
        
        dataobj["label"] = searchCriteria;
        dataInfo["labels"] = labels;
        datasets.push(dataobj);
        dataInfo["datasets"] = datasets;
        chartData["data"] = dataInfo;
        
        return chartData;
    },
    setDataSetValue : function(returnData, labels, dataSet){
        if(returnData.length){
            var k = 0;
            for(var i = 0; i < labels.length; i++){
                if(returnData[k] && returnData[k].expr1 === 1+i){
                    dataSet.push(returnData[k].expr0);
                    k++;
                }else{
                    dataSet.push(0);
                }
            }
        }
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
        }else if(errors[0] && errors[0].fieldErrors.Name){  // To show field exceptions
            errorMsg = errors[0].fieldErrors.Name[0].message;
        }else if(errors[0] && errors[0].duplicateResults.length){ // To show duplicateResults exceptions
            errorMsg = errors[0].duplicateResults[0].message;
        }
        helper.showNotificationEvt(cmp, "error", errorMsg, time);
    },
    toggleSpinner : function(cmp){
        var spinner_container = cmp.find("spinner_container");
        $A.util.toggleClass(spinner_container, "slds-hide");
    }
    
})