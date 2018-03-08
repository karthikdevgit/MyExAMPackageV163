@RestResource(urlMapping='/RestGetIntercept')
global class RestGetIntercept {

    @HttpGet
    global static void doGet() {
     
        Public_Assessment_Configuration__c paConfig = Public_Assessment_Configuration__c.getOrgDefaults();
        String clientURL = '';
        String clientHeader = '';
        String wi_CSS_Override_Static_Resource_Name = '';
        String returnBody = '';
        List<Public_Assessment__c> publicAssessmentList = new List<Public_Assessment__c>(); 

        RestRequest req = RestContext.request;

        try{
        
            if(req.params.get('amId') != null && req.params.get('amId') != '') {

                String amId = req.params.get('amId');

                publicAssessmentList = [
                    SELECT   Assignment_Manager__c, Assignment_Manager__r.InvestigationType__r.Web_Intercept_Header__c,
                             Assignment_Manager__r.InvestigationType__r.Web_Intercept_Static_Resource_Name__c,
                             Assessible_Object_ID__c, Assessment_Template__c, CreatedDate, Id, Name, Public_Assessment_URL__c
                    FROM     Public_Assessment__c
                    WHERE    Assignment_Manager__c = :amId
                    ORDER BY CreatedDate DESC LIMIT 1
                ];     
                if( !publicAssessmentList.isEmpty() ) {     
                    clientURL = publicAssessmentList[0].Public_Assessment_URL__c+'&WebIntercept=true';
                    if (publicAssessmentList[0].Assignment_Manager__r.InvestigationType__r.Web_Intercept_Header__c != null && publicAssessmentList[0].Assignment_Manager__r.InvestigationType__r.Web_Intercept_Header__c != ''){
                        clientHeader = publicAssessmentList[0].Assignment_Manager__r.InvestigationType__r.Web_Intercept_Header__c;
                    }
                    if (publicAssessmentList[0].Assignment_Manager__r.InvestigationType__r.Web_Intercept_Static_Resource_Name__c != null && publicAssessmentList[0].Assignment_Manager__r.InvestigationType__r.Web_Intercept_Static_Resource_Name__c != ''){
                        wi_CSS_Override_Static_Resource_Name = publicAssessmentList[0].Assignment_Manager__r.InvestigationType__r.Web_Intercept_Static_Resource_Name__c;
                    }
                } else {

                    Public_Assessment__c pa = new Public_Assessment__c();       
                    pa.Assignment_Manager__c = amId;        
                    insert pa;
                    clientURL = paConfig.Site_URL__c+'/ExAM__AMAndAnswerCreationPage?paId='+pa.Id+'&WebIntercept=true';
                }
            }
            else if(req.params.get('tempId') != null && req.params.get('tempId') != ''
                    && req.params.get('objId') != null && req.params.get('objId') != '' ) {

                String tempId = req.params.get('tempId');
                String objId = req.params.get('objId');

                publicAssessmentList = [
                    SELECT Assessible_Object_ID__c, Assignment_Manager__c, Assessment_Template__c,
                           Assessment_Template__r.Web_Intercept_Header__c,
                           Assessment_Template__r.Web_Intercept_Static_Resource_Name__c,
                           CreatedDate, Id, Name, Public_Assessment_URL__c
                    FROM   Public_Assessment__c       
                    WHERE  Assessible_Object_ID__c = :objId AND Assessment_Template__c = :tempId
                    ORDER BY CreatedDate DESC LIMIT 1
                ];

                if( !publicAssessmentList.isEmpty() ) {      
                    clientURL = publicAssessmentList[0].Public_Assessment_URL__c+'&WebIntercept=true';
                    if (publicAssessmentList[0].Assessment_Template__r.Web_Intercept_Header__c != null && publicAssessmentList[0].Assessment_Template__r.Web_Intercept_Header__c != '' ){
                        clientHeader = publicAssessmentList[0].Assessment_Template__r.Web_Intercept_Header__c;
                    }
                    if (publicAssessmentList[0].Assessment_Template__r.Web_Intercept_Static_Resource_Name__c != null && publicAssessmentList[0].Assessment_Template__r.Web_Intercept_Static_Resource_Name__c != '' ){
                        wi_CSS_Override_Static_Resource_Name = publicAssessmentList[0].Assessment_Template__r.Web_Intercept_Static_Resource_Name__c;
                    }
                } else {

                    Public_Assessment__c pa = new Public_Assessment__c();       
                    pa.Assessment_Template__c = tempId;     
                    pa.Assessible_Object_ID__c = objId;     
                    insert pa;  
                    clientURL = paConfig.Site_URL__c+'/ExAM__AMAndAnswerCreationPage?paId='+pa.Id+'&WebIntercept=true';    
                }
            }
            if (clientHeader == '' ) {
                clientHeader = 'ExAM Survey';
            }

            StaticResource static_resource = [
                SELECT Id, Body, Name, SystemModStamp
                FROM   StaticResource
                WHERE  Name = 'exam2InterceptHtml' LIMIT 1
            ];

            String dynamicStyle = '';
            if( wi_CSS_Override_Static_Resource_Name != '' ){
    
                String queryDynamicStaticResource = 'SELECT Id, Body, Name, SystemModStamp FROM StaticResource WHERE Name = \''+wi_CSS_Override_Static_Resource_Name +'\' LIMIT 1';
                StaticResource css_Override_static_resource = Database.query(queryDynamicStaticResource);
                dynamicStyle = css_Override_static_resource.Body.toString();
            }
            returnBody = static_resource.Body.toString();
        
            Integer styleStartIndex = returnBody.indexOf('<style>');
            Integer styleEndIndex = returnBody.indexOf('</style>');
            styleEndIndex = styleEndIndex+8;
        
            if( dynamicStyle != '' ) {
                returnBody = returnBody.replace(returnBody.substring(styleStartIndex,styleEndIndex),'<style>'+ dynamicStyle +'</style>');
            }
            returnBody = returnBody.replace('{{clientHeader}}', clientHeader);
            returnBody = returnBody.replace('{{clientURL}}', clientURL);

        }
        catch(Exception e) {
            returnBody = e.getMessage();
        }
        System.debug('::::returnBody::::'+returnBody);
        RestContext.response.addHeader('Content-Type', 'text/html ');
        RestContext.response.addHeader('Access-Control-Allow-Origin','*');
        RestContext.response.addHeader('Access-Control-Allow-Headers','X-Custom-Header');
        RestContext.response.addHeader('Access-Control-Allow-Methods', 'POST, GET, PUT, OPTIONS, DELETE');
        RestContext.response.responseBody = Blob.valueOf(returnBody);
    }
}