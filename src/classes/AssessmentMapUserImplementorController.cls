public with sharing class AssessmentMapUserImplementorController {

    private string showUsers { get; set; }
    public string GoogleMapsAPIKey { get; set; }
    //public string AssessmentCompletion { get; set; }
    // public string status { get; set; }
    //public string priority { get; set; }
    public string ColorBy { get; set; }

    //Add new code 
    public string AMStatus { get; set; }
    public string AMPriority { get; set; }
    public string AMAssesmentCompletion { get; set; }
    public string AMAssessmentType { get; set; }

    public string addressFieldApi;
    public string streetFieldApi;
    public string cityFieldApi;
    public string postalFieldApi;
    public string CountryFieldApi;

    public string assignmentManagerRelationShipApi;
    public string assessableobjectApi;
    public string assessmentGroupId;
    public string assessmentEventId;

    public string userRecordsJson{get; set;}
    public string assessibleObjRecordsJson{get; set;}

    public string scheduledFrom{get; set;}
    public string scheduledTo{get; set;}

    public List<User> useraccLists { get; set; }
    public List<Locations> accounts;
    public List<SObject> sObjectLists { get; set; }
    //public List<Account> allaccounts=new List<Account>();

    public class ErrorClass {
        public string errorType;
        public string errorMsg;
    }

    public AssessmentMapUserImplementorController() {

        try {

            Map<string, ExAM__GoogleMapsAPIKey__c> allKeys = ExAM__GoogleMapsAPIKey__c.getAll();
            GoogleMapsAPIKey = (allKeys.containskey('GoogleMapsAPIKey')? allKeys.get('GoogleMapsAPIKey').ExAM__API_Key__c : '');
            showUsers=System.currentPageReference().getParameters().get('showUsers');//if(showUsers==null){showUsers='false';}
            string accountMapGroup = apexpages.currentpage().getparameters().get('AccMapGroup');
            List<string> selectedValuesList = new List<string>();

            assessableobjectApi = apexpages.currentpage().getparameters().get('AssessableObj');
            assessmentGroupId = apexpages.currentpage().getparameters().get('AssessmentGrp');
            assessmentEventId = apexpages.currentpage().getparameters().get('AssessmentEvt');

            scheduledFrom = apexpages.currentpage().getparameters().get('scheduledFrom');
            scheduledTo = apexpages.currentpage().getparameters().get('scheduledTo');

            string agjParentApiName = '';
            Set<Id> parentIdSet = new Set<Id>();

            ExAMUtilClass.AssessableObjectDetails objectDetail = ExAMUtilClass.getAssessableObjectDetails('ExAM__IssueRequest_Life_Cycle__c');
            Map<string, string> fieldsAPIMap = objectDetail.assessableObjectAPIMap;
            Map<string, string> assessableObjectChildRelationshipNameMapInAM = objectDetail.assessableObjectChildRelationshipMapWeb;

            for (string referenceFieldAPIInAM : fieldsAPIMap.keySet()) {

                string AssessableObjectAPIName = fieldsAPIMap.get(referenceFieldAPIInAM);
                if ( AssessableObjectAPIName == assessableobjectApi ) {
                    assignmentManagerRelationShipApi = assessableObjectChildRelationshipNameMapInAM.get(referenceFieldAPIInAM);
                    agjParentApiName = (assessableobjectApi == 'Account') ? referenceFieldAPIInAM : 'AGJ_'+AssessableObjectAPIName;
                }
            }

            if (assessableobjectApi != null && assessableobjectApi != '') {      

                SFDCAccessController accessMAAC = ExAMUtilClass.AccessController;
                List<string> fieldsListMAAC = new List<string>{'ExAM__Address__c', 'ExAM__City_Field_Name__c', 'ExAM__Country_Field_Name__c', 'ExAM__Postal_Code_Field_Name__c', 'ExAM__Street_Field_Name__c'};
                accessMAAC.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Map_Anything_Address_Configuration__c'), fieldsListMAAC);

                List<Map_Anything_Address_Configuration__c> mapAnyObjectList = [
                    SELECT Address__c, City_Field_Name__c, Country_Field_Name__c, Id, Name, Postal_Code_Field_Name__c, Street_Field_Name__c
                    FROM   Map_Anything_Address_Configuration__c 
                    WHERE (Name = :assessableobjectApi AND ((Address__c != NULL) OR (Street_Field_Name__c != NULL AND City_Field_Name__c != NULL AND 
                           Postal_Code_Field_Name__c != NULL AND Country_Field_Name__c != NULL))) LIMIT 1
                ];
                if (mapAnyObjectList != null && mapAnyObjectList.size() > 0) {  
                    if ( string.isNotBlank(mapAnyObjectList[0].Address__c) ) {
                        addressFieldApi = mapAnyObjectList[0].Address__c;
                    }
                    else {
                        streetFieldApi = mapAnyObjectList[0].Street_Field_Name__c;
                        cityFieldApi = mapAnyObjectList[0].City_Field_Name__c; 
                        postalFieldApi = mapAnyObjectList[0].Postal_Code_Field_Name__c;
                        CountryFieldApi = mapAnyObjectList[0].Country_Field_Name__c;
                    }
                    if( accountMapGroup != null && accountMapGroup != '') {
                        selectedValuesList = accountMapGroup.split(';'); 
                    }
                    AMStatus = apexpages.currentpage().getparameters().get('AMStatus');
                    AMPriority = apexpages.currentpage().getparameters().get('AMpriority');
                    AMAssesmentCompletion = apexpages.currentpage().getparameters().get('AMassessmentCompletion');
                    AMAssessmentType = apexpages.currentpage().getparameters().get('AMassessmentType');
                    sObjectLists = new List<SObject> ();

                    /*AssessmentCompletion=System.currentPageReference().getParameters().get('AssessmentCompletion');
                    if(AssessmentCompletion==null){AssessmentCompletion='false';}
                    status=System.currentPageReference().getParameters().get('status');
                    if( status==null){ status='false';}
                    priority=System.currentPageReference().getParameters().get('priority');if(priority==null){priority='false';}
                    ColorBy=System.currentPageReference().getParameters().get('ColorBy');*/
                    accounts= new Locations[]{};

                    string assessibleFieldStr = '';
                    ColorBy = System.currentPageReference().getParameters().get('ColorBy');
                    if (ColorBy != '' && ColorBy != null && ColorBy != 'null') {
                        ColorBy = string.EscapeSingleQuotes( ColorBy );
                        assessibleFieldStr = ColorBy.split('~')[0];
                    }

                    if(showUsers.equalsIgnoreCase('true'))
                    {

                        SFDCAccessController accessUser = ExAMUtilClass.AccessController;
                        List<string> fieldsListUser = new List<string>{'ExAM__Location__c'};
                        accessUser.assertAuthorizedToView(Schema.getGlobalDescribe().get('User'), fieldsListUser);

                        string user_query_str = '';
                        user_query_str = 'SELECT Email, Id, IsActive, Location__Latitude__s, Location__Longitude__s, Name';
                        //if ( string.isNotBlank(assessibleFieldStr) ) {
                            //user_query_str += ', '+assessibleFieldStr;
                        //}
                        user_query_str += ' FROM User';
                        user_query_str += ' WHERE  IsActive = true AND Location__Latitude__s != NULL AND Location__Longitude__s != NULL';

                        if (user_query_str.length() > 0) {
                            useraccLists = Database.query( user_query_str );
                        }
                        if (useraccLists != null && useraccLists.size() > 0) {
                            userRecordsJson = Json.serialize(useraccLists);
                        }
                        //accounts.add(new Locations(useraccLists));
                    }
                    if (string.isNotBlank(agjParentApiName)) {

                        SFDCAccessController accessAGJ = ExAMUtilClass.AccessController;

                        List<string> fieldsListAGJ = new List<string>{'ExAM__Assessment_Group__c'};
                        fieldsListAGJ.add( agjParentApiName );

                        accessAGJ.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Assessment_Group_Junction__c'), fieldsListAGJ);

                        //Query Assessment Group Junction to get the Assessible Object Id Set
                        string agj_queryStr = 'SELECT Id, Name, Assessment_Group__c, '+string.EscapeSingleQuotes(agjParentApiName);
                        agj_queryStr += ' FROM Assessment_Group_Junction__c';
                        if (assessmentGroupId != null && assessmentGroupId != '' && assessmentGroupId != 'null') {
                            agj_queryStr += ' WHERE Assessment_Group__c = \'' + string.EscapeSingleQuotes(assessmentGroupId) + '\' AND '+string.EscapeSingleQuotes(agjParentApiName)+' != NULL';
                        }
                        system.debug(agj_queryStr);

                        List<SObject> agjList = new List<SObject>();
                        agjList = Database.query(agj_queryStr);

                        if (agjList != null && agjList.size() > 0) {
                            for (SObject agj : agjList) {
                                parentIdSet.add( (Id)agj.get(agjParentApiName) );
                            }
                        }
                    }

                    SFDCAccessController accessSObj = ExAMUtilClass.AccessController;
                    List<string> fieldsListSObj = new List<string>();

                    string queryStr = '';
                    if (assessableobjectApi == 'Case') {
                        queryStr = 'SELECT Id, CaseNumber,';
                    } else {
                        queryStr = 'SELECT Id, Name,';
                    }
                    if ( string.isNotBlank(addressFieldApi) ) {
                        queryStr += string.EscapeSingleQuotes(addressFieldApi)+', ';
                        if (addressFieldApi.endsWithIgnoreCase('__c')) {
                            fieldsListSObj.add(addressFieldApi);
                        }
                    }
                    else {
                        queryStr += string.EscapeSingleQuotes(streetFieldApi)+', '+string.EscapeSingleQuotes(cityFieldApi)+', '+string.EscapeSingleQuotes(postalFieldApi)+', '+string.EscapeSingleQuotes(CountryFieldApi)+', ';
                        if (string.isNotBlank(streetFieldApi) && streetFieldApi.endsWithIgnoreCase('__c')) {
                            fieldsListSObj.add(streetFieldApi);
                        }
                        if (string.isNotBlank(cityFieldApi) && cityFieldApi.endsWithIgnoreCase('__c')) {
                            fieldsListSObj.add(cityFieldApi);
                        }
                        if (string.isNotBlank(postalFieldApi) && postalFieldApi.endsWithIgnoreCase('__c')) {
                            fieldsListSObj.add(postalFieldApi);
                        }
                        if (string.isNotBlank(CountryFieldApi) && CountryFieldApi.endsWithIgnoreCase('__c')) {
                            fieldsListSObj.add(CountryFieldApi);
                        }
                    }
                    if (assessableobjectApi == 'Account') {
                        queryStr += 'BillingLatitude, BillingLongitude, ';
                    }
                    else if (assessableobjectApi == 'User') {
                        queryStr += 'Location__Latitude__s, Location__Longitude__s, ';
                        fieldsListSObj.add('ExAM__Location__c');
                    }
                    else {
                        queryStr += 'EX_Location__Latitude__s, EX_Location__Longitude__s, ';
                        fieldsListSObj.add('EX_Location__c');
                    }
                    if ( string.isNotBlank(assessibleFieldStr) && !queryStr.containsIgnoreCase(assessibleFieldStr) ) {
                        queryStr += string.EscapeSingleQuotes(assessibleFieldStr)+', ';
                        if (assessibleFieldStr.endsWithIgnoreCase('__c')) {
                            fieldsListSObj.add(assessibleFieldStr);
                        }
                    }
                    queryStr += '( SELECT Assessment_Form_Completion__c, CreatedDate, Facility_Name__c, Id, InvestigationType__c, ';
                    queryStr += 'InvestigationType__r.Template_name__c, Name, Priority__c, Status__c FROM '+string.EscapeSingleQuotes(assignmentManagerRelationShipApi); 

                    if (AMAssessmentType.equalsIgnoreCase('All')) {
                        queryStr += ' WHERE InvestigationType__c != null ';
                    }
                    else {
                        queryStr += ' WHERE InvestigationType__c = \''+string.EscapeSingleQuotes(AMAssessmentType)+'\'';
                    }

                    if (assessmentGroupId != null && assessmentGroupId != '' && assessmentGroupId != 'null') {
                        queryStr += ' AND Assessment_Group__c = \''+string.EscapeSingleQuotes(assessmentGroupId)+'\'';
                    }                    
                    if (assessmentEventId != null && assessmentEventId != '' && assessmentEventId != 'null') {
                        queryStr += ' AND Assessment_Event__c = \''+string.EscapeSingleQuotes(assessmentEventId)+'\'';
                    }
                    if (AMStatus != null && AMStatus != '' && AMStatus != 'All') {
                        queryStr += ' AND Status__c = \''+string.EscapeSingleQuotes(AMStatus)+'\'';
                    }
                    if (AMPriority != null && AMPriority != '' && AMPriority != 'All') {
                        queryStr += ' AND Priority__c = \''+string.EscapeSingleQuotes(AMPriority)+'\'';
                    }
                    if (AMAssesmentCompletion != null && AMAssesmentCompletion != '' && AMAssesmentCompletion != 'All') {
                        queryStr += ' AND Assessment_Form_Completion__c = \''+string.EscapeSingleQuotes(AMAssesmentCompletion)+'\'';
                    }   
                    if ( (scheduledFrom != null && scheduledFrom != '' && scheduledFrom != 'null') &&
                         (scheduledTo != null && scheduledTo != '' && scheduledTo != 'null') ) {

                        DateTime startRange = DateTime.newInstance(Integer.valueOf(scheduledFrom.split('/')[2]), Integer.valueOf(scheduledFrom.split('/')[0]), Integer.valueOf(scheduledFrom.split('/')[1]), 0, 0, 0);
                        DateTime endRange = DateTime.newInstance(Integer.valueOf(scheduledTo.split('/')[2]), Integer.valueOf(scheduledTo.split('/')[0]), Integer.valueOf(scheduledTo.split('/')[1]), 23, 59, 59);

                        queryStr += ' AND Scheduled_Start_Date__c >= :startRange AND Scheduled_Start_Date__c <= :endRange';
                    }
                    queryStr += ') FROM '+string.EscapeSingleQuotes(assessableobjectApi)+' WHERE Id IN :parentIdSet AND ';

                    if (string.isNotBlank(addressFieldApi)) {

                        queryStr += '(('+addressFieldApi+' <> NULL) OR ';
                        if (assessableobjectApi == 'Account') {
                            queryStr += '(BillingLatitude <> NULL AND BillingLongitude <> NULL))';
                        }
                        else if (assessableobjectApi == 'User') {
                            queryStr += '(Location__Latitude__s <> NULL AND Location__Longitude__s <> NULL))';
                        }
                        else {
                            queryStr += '(EX_Location__Latitude__s <> NULL AND EX_Location__Longitude__s <> NULL))';
                        }
                    }
                    else {

                        queryStr += '((('+streetFieldApi+' <> NULL OR '+cityFieldApi+' <> NULL) AND '+postalFieldApi+' <> NULL) OR ';
                        if (assessableobjectApi == 'Account') {
                            queryStr += '(BillingLatitude <> NULL AND BillingLongitude <> NULL))';
                        }
                        else if (assessableobjectApi == 'User') {
                            queryStr += '(Location__Latitude__s <> NULL AND Location__Longitude__s <> NULL))';
                        }
                        else {
                            queryStr += '(EX_Location__Latitude__s <> NULL AND EX_Location__Longitude__s <> NULL))';
                        }
                    }
                    system.debug('queryStr'+queryStr);

                    accessSObj.assertAuthorizedToView(Schema.getGlobalDescribe().get(assessableobjectApi), fieldsListSObj);

                    SFDCAccessController accessAT = ExAMUtilClass.AccessController;
                    List<string> fieldsListAT = new List<string>{'ExAM__Template_name__c'};
                    accessAT.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__Main_questionaire__c'), fieldsListAT);

                    SFDCAccessController accessAM = ExAMUtilClass.AccessController;
                    List<string> fieldsListAM = new List<string>{'ExAM__Assessment_Form_Completion__c', 'ExAM__Facility_Name__c', 'ExAM__InvestigationType__c', 'ExAM__Priority__c', 'ExAM__Status__c'};
                    accessAM.assertAuthorizedToView(Schema.getGlobalDescribe().get('exam__IssueRequest_Life_Cycle__c'), fieldsListAM);

                    List<SObject> sObjectLists = Database.query( queryStr );
                    /*
                    for (SObject eachSObj : sObjList) {
                        if( eachSObj.getSObjects(assignmentManagerRelationShipApi) != null && eachSObj.getSObjects(assignmentManagerRelationShipApi).size() > 0 ) {
                            sObjectLists.add(eachSObj);     
                        }
                    }
                    */
                    if(sObjectLists != null && sObjectLists.size() > 0) {
                        for (SObject a : sObjectLists) {
                            Decimal lat, lng;
                            if (assessableobjectApi == 'Account') {
                                lat = (Decimal)a.get( 'BillingLatitude' );
                                lng = (Decimal)a.get( 'BillingLongitude' );
                            }
                            else if (assessableobjectApi == 'User') {
                                lat = (Decimal)a.get( 'Location__Latitude__s' );
                                lng = (Decimal)a.get( 'Location__Longitude__s' );
                            }
                            else {
                                lat = (Decimal)a.get( 'EX_Location__Latitude__s' );
                                lng = (Decimal)a.get( 'EX_Location__Longitude__s' );
                            }

                            Boolean hasLatLnggg = (lat != null && lng != null) ? true : false;

                            string addr = '';
                            string value = '';

                            if (string.isNotBlank(addressFieldApi)) {
                                addr = (string)a.get(addressFieldApi);
                            }
                            else {
                                addr = (string)a.get(streetFieldApi)+';'+(string)a.get(cityFieldApi)+';'+(string)a.get(postalFieldApi)+';'+(string)a.get(CountryFieldApi);
                            }

                            if ( string.isNotBlank(assessibleFieldStr) ) {
                                value = (string)a.get(assessibleFieldStr);
                            }
                            if (assessableobjectApi == 'Case') {
                                accounts.add( new Locations(a.id, (string)a.get('CaseNumber'), addr, a.getSObjects(assignmentManagerRelationShipApi), lat, lng, hasLatLnggg, value) );
                            } else { 
                                accounts.add( new Locations(a.id, (string)a.get('name'), addr, a.getSObjects(assignmentManagerRelationShipApi), lat, lng, hasLatLnggg, value) );
                            }                        
                        }

                        if (accounts != null && accounts.size() > 0) {

                            assessibleObjRecordsJson = Json.serialize(accounts);
                        }
                    }//end if sObjectLists list not null codn check
                }//end if queried address configuration list not null codn check
            }//end if assessableobjectApi string not null codn check
        }
        catch(Exception e) {
            System.debug('Exception is :::'+e);
            ErrorClass err = new ErrorClass();
            err.errorType = e.getTypeName();
            err.errorMsg = e.getMessage();
            assessibleObjRecordsJson = Json.serialize(err);
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()) );
        }
    }//end constructor

    @RemoteAction
    public static string updateAssessibleObjectLatLng(string jsonStr, string assessibleObj) {

        string recordUpdationResponse;

        try {

            List<SObject> updateList = new List<SObject>();        
            Map<string,Schema.SObjectType> gd = Schema.getGlobalDescribe();
            Schema.SObjectType s;

            if (gd.containsKey(assessibleObj) && gd.get(assessibleObj) != null) {

                s = gd.get(assessibleObj);

                if (jsonStr != null && jsonStr != '' && s != null) {

                    SFDCAccessController accessSObj = ExAMUtilClass.AccessController;
                    List<string> fieldsListSObj = new List<string>();

                    List<AddressToLatLongConversion> addressConversionClassList = (List<AddressToLatLongConversion>)Json.deserialize(jsonStr, List<AddressToLatLongConversion>.class);
                    for(AddressToLatLongConversion addressConversionClassIns : addressConversionClassList) {

                        Double lat = double.valueOf( addressConversionClassIns.Lat );
                        Double lon = double.valueOf( addressConversionClassIns.Lngg );

                        SObject sObj = Schema.getGlobalDescribe().get(assessibleObj).newSObject();
                        sObj.put('Id', addressConversionClassIns.RecordId);
                        if (assessibleObj == 'Account') {
                            sObj.put('BillingLatitude', lat);
                            sObj.put('BillingLongitude', lon);
                        }
                        else if (assessibleObj == 'User') {
                            fieldsListSObj.add( 'ExAM__Location__c' );
                            sObj.put('Location__Latitude__s', lat);
                            sObj.put('Location__Longitude__s', lon);
                        }
                        else {
                            fieldsListSObj.add( 'EX_Location__c' );
                            sObj.put('EX_Location__Latitude__s', lat);
                            sObj.put('EX_Location__Longitude__s', lon);
                        }
                        updateList.add( sObj );
                    }
                    if (updateList != null && updateList.size() > 0) {

                        accessSObj.assertAuthorizedToUpdate(s, fieldsListSObj);

                        update updateList;
                        recordUpdationResponse = 'Geolocation field in '+s+' updated successfully';
                    }
                }
            }
        }
        catch(DMLException dmlExp) {
            recordUpdationResponse = 'Exception-'+dmlExp.getDMLMessage(0);
        }
        catch(Exception exp) {
            recordUpdationResponse = 'Exception-'+exp.getMessage();
        }
        return recordUpdationResponse;
    }

    // Creates section List
    public List<Locations> getlistacc() {

        if(accounts!=null){
            return accounts;
        }
        return null;
    }

    // Create an inner class
    public class Locations{
        public string accountid { get; set;}
        public string accountname { get; set;}
        public string accountaddress { get; set; } 
        public Account accountobj { get; set; }
        public List<IssueRequest_Life_Cycle__c> issueLists { get; set; }
        public List<User> userLists { get; set; }
        public Decimal assessibleObjLat{get; set;}
        public Decimal assessibleObjLngg{get; set;}
        public Boolean hasLatLngg{get; set;}
        public string colorByFieldValue{get; set;}

        public  Locations(string aid, string aname, string aaddress, List<IssueRequest_Life_Cycle__c> ilist, Decimal lat, Decimal lngg, Boolean hasLatLng, string fieldVal)
        {
            accountid = aid;
            accountname = aname;
            accountaddress = aaddress;
            issueLists = new List<IssueRequest_Life_Cycle__c>();
            issueLists = ilist;
            assessibleObjLat = lat;
            assessibleObjLngg = lngg;
            hasLatLngg = hasLatLng;
            colorByFieldValue = fieldVal;
        }
        /*public  Locations(list<User> ulist)
        {            
            userLists =new List<User>();
            userLists =ulist;
        }*/
    }

    public class AddressToLatLongConversion {
        public string RecordId;
        public string Lat;
        public string Lngg;

        public AddressToLatLongConversion(string AccountId, string latitude, string longitude) {
            this.RecordId = AccountId;
            this.Lat = latitude;
            this.Lngg = longitude;
        }    
    }

    /*public static testMethod void testlistacc() {

        Test.startTest();

        Main_questionaire__c maintest1 = new Main_questionaire__c (Template_name__c = 'test2', PublishPlace__c = 'External Site');
        upsert maintest1;

        Account acc = new Account(BillingStreet = '2425 Wilson Blvd', BillingCity = 'arlington',BillingPostalCode = '22209',BillingCountry = 'USA',name = 'test account',Create_Survey__c = true);
        acc.Main_Questionnaire_Template__c = maintest1.id;
        upsert acc;

        System.currentPageReference().getParameters().put('showUsers','true');

        IssueRequest_Life_Cycle__c issue = new IssueRequest_Life_Cycle__c(Facility_Name__c = acc.id, Status__c = 'Open', Priority__c = 'Emergency', InvestigationType__c = maintest1.id);
        upsert issue;

        AssessmentMapUserImplementorController d = new AssessmentMapUserImplementorController();
        System.assert(d.getlistacc() != null);

        Test.stopTest();
    }*/
}