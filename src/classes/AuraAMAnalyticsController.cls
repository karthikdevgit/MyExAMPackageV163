public with sharing class AuraAMAnalyticsController {
    
    public static List<String> newColor = new List<String>{'#3366CC', '#DC3912', '#FF9900', '#109618',
        '#990099', '#3B3EAC', '#0099C6', '#DD4477', 
        '#66AA00', '#B82E2E', '#316395', '#994499',
        '#22AA99', '#AAAA11', '#6633CC', '#E67300', 
        '#8B0707', '#329262', '#5574A6', '#3B3EAC'
        };
            
    @AuraEnabled
    public static List<AMAnalytic> getAmByOverallStatus(string assessmentId, string searchingCriteria){
        try{
            String fields = 'Status__c';
            String query_str = 'SELECT Count(Id), Status__c FROM IssueRequest_Life_Cycle__c WHERE InvestigationType__c = \''+assessmentId+'\'';
            
            
            if (searchingCriteria != '' && searchingCriteria != null) {
                query_str += ' AND Scheduled_Start_Date__c ='+searchingCriteria;
            }
            
            query_str += ' GROUP BY Status__c';
            
            FieldLevelSecurity.checkFieldAccessByCriteria(fields, 'view', 'IssueRequest_Life_Cycle__c');
            List<AMAnalytic> AMAnalyticResponses = new List<AMAnalytic>();
            
            for(AggregateResult amResponseAggregate : Database.query(query_str)){
                AMAnalytic newAMAnalyticResponse = new AMAnalytic();
                newAMAnalyticResponse.Yaxis = Integer.valueOf(amResponseAggregate.get('expr0'));
                newAMAnalyticResponse.Xaxis = String.valueOf(amResponseAggregate.get('ExAM__Status__c'));
                newAMAnalyticResponse.color = newColor[Integer.valueOf(Math.floor((Math.random() * 17)))];
                AMAnalyticResponses.add(newAMAnalyticResponse);
            }
            
            return AMAnalyticResponses;
            
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
        
        
    }
    @AuraEnabled
    public static List<AMAnalytic> getAmByCreatedDate(String assessmentId, String searchingCriteria){
        List<AggregateResult> amList = new List<AggregateResult>();
        String query_str = constructQueryOfDateTime(assessmentId, searchingCriteria, null, 'CreatedDate');
        amList = Database.query(query_str);
        List<AMAnalytic> responseOfAMAnalytic = generateJSON_RptStructure(searchingCriteria, amList);
        
        return responseOfAMAnalytic;
        
    }
    
    @AuraEnabled
    public static List<AMAnalytic> getAmByCompletedDate(string assessmentId, string searchingCriteria){
        
        List<AggregateResult> amList = new List<AggregateResult>();
        String query_str = constructQueryOfDateTime(assessmentId, searchingCriteria, null, 'Date_Completed__c');
        amList = Database.query(query_str);
        List<AMAnalytic> responseOfAMAnalytic = generateJSON_RptStructure(searchingCriteria, amList);
        
        return responseOfAMAnalytic;
        
        
    }
    public static String constructQueryOfDateTime(String assessmentId, String searchCriteria, String searchViewer, String fieldNameApi){
        try{
            String query_str = '';
            if (IssueRequest_Life_Cycle__c.sObjectType.getDescribe().isQueryable()
                && IssueRequest_Life_Cycle__c.sObjectType.getDescribe().isAccessible()
               ) {
                   String Criteria;
                   String filter_str;
                   
                   if (searchCriteria != null) {
                       
                       if (searchCriteria == 'THIS_WEEK') {
                           Criteria = ' DAY_IN_WEEK(' +fieldNameApi+ ')';
                           filter_str = ' AND '+fieldNameApi+ '= THIS_WEEK';
                           filter_str += ' GROUP BY DAY_IN_WEEK('+fieldNameApi+ ')';
                       }
                       else if (searchCriteria == 'LAST_WEEK') {
                           Criteria = ' DAY_IN_WEEK('+fieldNameApi+')';
                           filter_str = ' AND '+fieldNameApi+'= LAST_WEEK';
                           filter_str += ' GROUP BY DAY_IN_WEEK('+fieldNameApi+')';
                       }
                       else if (searchCriteria == 'THIS_MONTH') {
                           Criteria = ' WEEK_IN_MONTH('+fieldNameApi+')';
                           filter_str = ' AND '+fieldNameApi+' = THIS_MONTH';
                           filter_str += ' GROUP BY WEEK_IN_MONTH('+fieldNameApi+')';
                       }
                       else if (searchCriteria == 'LAST_MONTH') {
                           Criteria = ' WEEK_IN_MONTH('+fieldNameApi+')';
                           filter_str = ' AND '+fieldNameApi+' = LAST_MONTH';
                           filter_str += ' GROUP BY WEEK_IN_MONTH('+fieldNameApi+')';
                       }
                       else if (searchCriteria == 'THIS_YEAR') {
                           Criteria = ' CALENDAR_MONTH('+fieldNameApi+')';
                           filter_str = ' AND '+fieldNameApi+' = THIS_YEAR';
                           filter_str += ' GROUP BY CALENDAR_MONTH('+fieldNameApi+')';
                       }
                       else if (searchCriteria == 'LAST_YEAR') {
                           Criteria = 'CALENDAR_MONTH('+fieldNameApi+')';
                           filter_str = ' AND '+fieldNameApi+' = LAST_YEAR';
                           filter_str += ' GROUP BY CALENDAR_MONTH('+fieldNameApi+')';
                       }
                       else if (searchCriteria == 'LAST_N_YEARS:2') {
                           Criteria = ' CALENDAR_YEAR('+fieldNameApi+')';
                           filter_str = ' AND '+fieldNameApi+' = LAST_N_YEARS:2';
                           filter_str += ' GROUP BY CALENDAR_YEAR('+fieldNameApi+')';
                       }
                   }
                   
                   query_str = 'SELECT count(Id),'+Criteria+' From IssueRequest_Life_Cycle__c';
                   
                   if (assessmentId != null) {
                       query_str += ' WHERE InvestigationType__c = \''+assessmentId+'\'';
                   }
                   if(searchViewer != null && searchViewer == 'Current_User'){
                       query_str = query_str + ' AND OwnerId =\''+UserInfo.getUserId()+'\'';
                   }
                   
                   query_str += filter_str;
                   
               }
            return query_str;
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
        
    }
    
    public static List<AMAnalytic> generateJSON_RptStructure(string searchCriteria, List<AggregateResult> amList){
        
        Date todayDate = System.today();
        List<Object> range = new List<Object>();
        
        if(searchCriteria == 'THIS_WEEK'){
            range = generateWeekDate(todayDate);
        }else if(searchCriteria == 'LAST_WEEK'){
            Date lastWeekDate = Date.newInstance(todayDate.year(), todayDate.month(), todayDate.day() - 7);
            range = generateWeekDate(lastWeekDate);            
        }else if(searchCriteria == 'THIS_MONTH'){
            range = getWeeksInMonth(todayDate.month(), todayDate.year());
        }else if(searchCriteria == 'LAST_MONTH'){
            range = getWeeksInMonth(todayDate.month()-1, todayDate.year());
        }else if(searchCriteria == 'THIS_YEAR'){
            range = getMonthInyear();
        }else if(searchCriteria == 'LAST_YEAR'){
            range = getMonthInyear();
        }else{
            List<String> noOfYears = searchCriteria.split(':');
            range = getYears(todayDate.year(), Integer.valueOf(noOfYears[1]));
        }
        
        return JSON_RptStructure(amList, range, searchCriteria);
    }
    
    public static List<AMAnalytic> JSON_RptStructure(List<AggregateResult> amList, List<Object> range, String searchCriteria){
        List<AMAnalytic> AMAnalyticResponses = new List<AMAnalytic>();
        
        Integer k = 0;
        Integer value;
        
        for(Integer i = 0; i < range.size(); i++){
            AMAnalytic newAMAnalyticResponse = new AMAnalytic();
            
            if(searchCriteria == 'LAST_N_YEARS:2'){
                value = Integer.valueOf(range[i]);
            }else{
                value = 1+i;
            }
            
            if(amList.size() > k && amList[k] != null && Integer.valueOf(amList[k].get('expr1')) == value){
                newAMAnalyticResponse.Yaxis  = Integer.valueOf(amList[k].get('expr0'));
                k++;
            }else{
                newAMAnalyticResponse.Yaxis  = 0;
            }
            newAMAnalyticResponse.color = newColor[Integer.valueOf(Math.floor((Math.random() * 17)))];
            newAMAnalyticResponse.Xaxis = string.valueOf(range[i]) ;
            AMAnalyticResponses.add(newAMAnalyticResponse);
        }
        return AMAnalyticResponses;
    }
    
    public static List<String> generateWeekDate(Date calculateDate){
        
        List<String> weekDate = new List<String>();
        
        Integer firstDay = calculateDate.day() - getDay(calculateDate); // First day is the day of the month - the day of the week
        Integer lastDay = firstDay + 6; // last day is the first day + 6
        
        // push day as label
        for(Integer i = firstDay; i <= lastDay; i++){
            Date dateOfWeek = Date.newInstance(calculateDate.year(), calculateDate.month(), i);
            weekDate.add(dateOfWeek.format());
        }
        return weekDate;
    }
    public static List<String> getWeeksInMonth(Integer year, Integer month){
        
        Boolean leapYear = false;
        if((Math.mod(year, 4) == 0 && Math.mod(year, 100) != 0) || Math.mod(year, 400) == 0){
            leapYear = true;
        }
        List<String> weeks = new List<String>{'Week 1', 'Week 2', 'Week 3', 'Week 4', 'Week 5'};
        if(leapYear == false && month == 2){
            weeks = new List<String>{'Week 1', 'Week 2', 'Week 3', 'Week 4'};
        }
          
        return weeks;
    }
    public static List<String> getMonthInyear(){
        List<String> months = new List<String>{'January','February',
            'March','April','May','June',
            'July','August','September','October',
            'November','December'};
                return months;
    }
    public static List<Integer> getYears(Integer year, Integer noOfyears){
        List<Integer> years = new List<Integer>();
        Integer j = noOfyears;
        for(Integer i = 1; i <= noOfyears; i++){
            years.add(year - j);
            j--;
        }
        
        return years;
    }
    public static Integer getDay(Date todayDate){
        
        DateTime todayDateTime = (DateTime) todayDate;
        String dayOfWeek = todayDateTime.format('E');
        
        Integer dayOfnumber = 1;
        
        if(dayOfWeek == 'Mon'){
            dayOfnumber = 2;
        }else if(dayOfWeek == 'Tue'){
            dayOfnumber = 3;
        }else if(dayOfWeek == 'Wed'){
            dayOfnumber = 4;
        }else if(dayOfWeek == 'Thu'){
            dayOfnumber = 5;
        }else if(dayOfWeek == 'Fri'){
            dayOfnumber = 6;
        }else if(dayOfWeek == 'Sat'){
            dayOfnumber = 7;
        }
        
        return dayOfnumber;
    }
    
    
    public class AMAnalytic{
        @AuraEnabled
        public String Xaxis; // xaxis value
        @AuraEnabled
        Public Integer Yaxis; // yaxis value
        @AuraEnabled
        public String color;
    }
}