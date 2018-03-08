@RestResource(urlMapping='/GetAMandAccountData/*')
global class RestGetAMAndAccountData {

    @HttpPost
    global static ResponseClass getAMandAccountData() {

        string inputString = '';            
        string msg = '';
        List<ExAM__IssueRequest_Life_Cycle__c> queriedAMs = new List<ExAM__IssueRequest_Life_Cycle__c>();
        List<Account> queriedAccts = new List<Account>();
        List<string> amExternalIdSet = new List<string>();
        List<string> acctExternalIdSet = new List<string>();
        Set<Id> amIdSet = new Set<Id>();
        Set<Id> acctIdSet = new Set<Id>();
        Set<string> amFieldSet = new Set<string>{'Id', 'Name'};
        Set<string> acctFieldSet = new Set<string>{'Id', 'Name'};

        try {

            RestRequest req = RestContext.request;
            if (req != null && req.requestBody != null) {

                inputString = req.requestBody.tostring();
                if (string.isNotBlank(inputString)) {

                    UserDataInput usrInput = (UserDataInput)Json.deserialize(inputString, UserDataInput.class);
                    if (usrInput.amData != null
                        && ((usrInput.amData.recIds != null && usrInput.amData.recIds.size() > 0)
                            ||(usrInput.amData.externalIds != null && usrInput.amData.externalIds.size() > 0))
                    ) {

                        amIdSet.addAll( usrInput.amData.recIds );
                        amExternalIdSet.addAll( usrInput.amData.externalIds );

                        string AM_SELECT_CLAUSE = 'Id, Name';
                        if (usrInput.amData.fields != null && usrInput.amData.fields.size() > 0) {
                            for(string field : usrInput.amData.fields) {
                                if (!amFieldSet.contains(field) ) {
                                    AM_SELECT_CLAUSE += ', ' + field;
                                    amFieldSet.add( field );
                                }
                            }
                        }
                        string AM_FROM_CLAUSE = 'ExAM__IssueRequest_Life_Cycle__c';
                        string AM_WHERE_CLAUSE = 'Id IN :amIdSet OR ExAM__Assignment_External_Id__c IN :amExternalIdSet';
                        string AM_QUERY = 'SELECT '+AM_SELECT_CLAUSE+' FROM '+AM_FROM_CLAUSE+' WHERE '+AM_WHERE_CLAUSE;
                        List<ExAM__IssueRequest_Life_Cycle__c> amList = Database.query( AM_QUERY );
                        if (amList != null && amList.size() > 0) {
                            queriedAMs = amList;
                        }
                    }
                    if (usrInput.acctData != null
                        && ((usrInput.acctData.recIds != null && usrInput.acctData.recIds.size() > 0)
                            || (usrInput.acctData.externalIds != null && usrInput.acctData.externalIds.size() > 0))
                    ) {

                        acctIdSet.addAll( usrInput.acctData.recIds );
                        acctExternalIdSet.addAll( usrInput.acctData.externalIds );

                        string ACCT_SELECT_CLAUSE = 'Id, Name';
                        if (usrInput.acctData.fields != null && usrInput.acctData.fields.size() > 0) {
                            for(string field : usrInput.acctData.fields) {
                                if (!acctFieldSet.contains(field) ) {
                                    ACCT_SELECT_CLAUSE += ', ' + field;
                                    acctFieldSet.add( field );
                                }
                            }
                        }
                        string ACCT_FROM_CLAUSE = 'Account';
                        string ACCT_WHERE_CLAUSE = 'Id IN :acctIdSet OR ExAM__Account_External_Id__c IN :acctExternalIdSet';
                        string ACCT_QUERY = 'SELECT '+ACCT_SELECT_CLAUSE+' FROM '+ACCT_FROM_CLAUSE+' WHERE '+ACCT_WHERE_CLAUSE;
                        List<Account> acctList = Database.query( ACCT_QUERY );
                        if (acctList != null && acctList.size() > 0) {
                            queriedAccts = acctList;
                        }
                    }
                }
            }
            if (inputString == null || inputString == '' || inputString == 'null') {
                msg = 'Please provide a valid request to get Assignment Manager and Account data';
            }
            else if (queriedAMs.isEmpty() && queriedAccts.isEmpty()) {
                msg = 'Data not exists for given request. Please make sure that supplied ids are valid';
            }
            else {
                msg = 'SUCCESS';
            }
        }
        catch(Exception exp) {
            msg = exp.getMessage();
        }
        ResponseClass resp = new ResponseClass(msg, queriedAMs, queriedAccts);
        return resp;
    }
    global class UserDataInput {
        global AssignmentManagerDetails amData;
        global AccountDetails acctData;
    }
    public class AssignmentManagerDetails {
        public List<Id> recIds;
        public List<string> externalIds;
        public List<string> fields;
    }
    public class AccountDetails {
        public List<Id> recIds;
        public List<string> externalIds;
        public List<string> fields;
    }
    global class ResponseClass {
        global string message;
        global List<ExAM__IssueRequest_Life_Cycle__c> AssignmentManagers;
        global List<Account> Accounts;

        global ResponseClass(string message, List<ExAM__IssueRequest_Life_Cycle__c> AssignmentManagers, List<Account> Accounts) {
            this.message = message;
            this.AssignmentManagers = AssignmentManagers;
            this.Accounts = Accounts;
        }
    }
}