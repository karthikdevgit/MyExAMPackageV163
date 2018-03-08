({
  doInit: function(cmp, event, helper) {
    window.Exam.svcResultAnalytics = (function() {
        var data = {
            "_backgroundColor" : [
                '#3366CC',
                '#DC3912',
                '#FF9900',
                '#109618',
                '#990099',
                '#3B3EAC',
                '#0099C6',
                '#DD4477',
                '#66AA00',
                '#B82E2E',
                '#316395',
                '#994499',
                '#22AA99',
                '#AAAA11',
                '#6633CC',
                '#E67300',
                '#8B0707',
                '#329262',
                '#5574A6',
                '#3B3EAC'
            ],
            "_borderColor" : [					
                'rgba(255,99,132,1)',			
                'rgba(54, 162, 235, 1)',
                'rgba(255, 206, 86, 1)',
                'rgba(75, 192, 192, 1)',
                'rgba(153, 102, 255, 1)',
                'rgba(255, 159, 64, 1)'
            ],
            "_borderWidth": 1
      }

      return {
        fetchReportByMethod: function(param, onSuccess, onError, apexMethodName, chartType) {
          if (apexMethodName) {
            helper.fetchReportByMethod(param, onSuccess, onError, apexMethodName, cmp, data, chartType, helper);
          }
        }
      };
    }());
  }
})