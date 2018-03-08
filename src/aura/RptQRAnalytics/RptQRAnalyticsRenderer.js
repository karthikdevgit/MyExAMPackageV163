({
    // Your renderer method overrides go here
    afterRender: function (cmp, helper) {
        this.superAfterRender();
        var googleColors = ['#3366CC', '#DC3912', '#FF9900', '#109618',
                            '#990099', '#3B3EAC', '#0099C6', '#DD4477', 
                            '#66AA00', '#B82E2E', '#316395', '#994499',
                            '#22AA99', '#AAAA11', '#6633CC', '#E67300', 
                            '#8B0707', '#329262', '#5574A6', '#3B3EAC'];
        var chartDiv = cmp.find("chartdiv").getElement();
        var chart = cmp.find("chart");
        $A.util.addClass(chart, "eclair-component-chart");
        if(cmp.get("v.questionResponse").optionBased){
            var legendContainer = cmp.find("legendContainer").getElement();
            
            var chart = AmCharts.makeChart( chartDiv, {
                "type": "pie",
                "theme": "light",
                "dataProvider": cmp.get("v.questionResponse").answer,            
                "valueField": "weight",
                "titleField": "name",
                //"marginRight": 240,
                //"marginLeft": 50,
                //"startX": -500,
                "depth3D": 15,
                "angle": 30,
                "outlineAlpha": 0.4,
                //"outlineColor": "#FFFFFF",
                //"outlineThickness": 2,
                //"labelPosition": "right",
                "labelText" : "[[title]]",
                "balloonText": "<span style='font-size:14px'><b>[[value]]</b></span>",
                "legend": {
                    "divId" : legendContainer,
                    "position" : "absolute",
                    "top" : 60+"px",
                    "left" : 40+"px",
                    "periodValueText" : "[[value.sum]]"
                },
                colors : googleColors
            });
            
            $A.util.addClass(cmp.find("legend"), "slds-hide");
            
        }else{
            
            Highcharts.chart(chartDiv, {
                series: [{
                    type: 'wordcloud',
                    data: cmp.get("v.questionResponse").answer,
                    name: 'Occurrences',
                    "colors" : googleColors
                }]
            });
        }
    }
})