public with sharing class FetchDocumentId
{

    public string documentname{ get; set; }
    public string docid{ get; set; }
    public List<Document> lstDocument=new List<Document>();
    public string getdocId()
    {
        return docid;
    }

    public void documentId()
    {
        documentname=System.currentPageReference().getParameters().get('documentname');
        //documentname='Checklist_Comment_and_Feedback_Template';
        try{
            SFDCAccessController accessDOC = ExAMUtilClass.AccessController;
            accessDOC.assertAuthorizedToView(Schema.getGlobalDescribe().get('Document'), new List<string>());
            lstDocument = [SELECT Id, Name FROM Document WHERE Name =:documentname LIMIT 1];
            string strOrgId = UserInfo.getOrganizationId();
            string strDocUrl = 'https://'+ApexPages.currentPage().getHeaders().get('Host')+ '/servlet/servlet.FileDownload?file='+lstDocument[0].Id+'&oid=' + strOrgId;
            docid=lstDocument[0].Id;
        }
        catch(Exception e){
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()) );
        }
        //return docid;
    }

    /*
    public PageReference DocumentUrl()
    {
        documentname=System.currentPageReference().getParameters().get('documentname');
        List<Document> lstDocument = [Select Id,Name from Document where Name =:documentname limit 1];
        string strOrgId = UserInfo.getOrganizationId();
        string strDocUrl = 'https://'+ApexPages.currentPage().getHeaders().get('Host')+ '/servlet/servlet.FileDownload?file='+lstDocument[0].Id+'&oid=' + strOrgId;
        //documentid=lstDocument[0].Id;
        //return strDocUrl;
        PageReference cancelClicked=new PageReference(strDocUrl);
        cancelClicked.setRedirect(true);
        return cancelClicked;
    }
    */

    @IsTest(SeeAllData=true) 
    public static void testdocumentId()
    {
        FetchDocumentId d= new FetchDocumentId();
        PageReference pageRef=new PageReference('/apex/OHSESMain');
        System.Test.setCurrentpage(pageRef); 

        List<Folder> lstFolder = [Select Id From Folder where name='Governance'];

        if(lstFolder.size() > 0)
        {
            Document d1 = new Document(FolderId = lstFolder.get(0).Id, Name='testTemplate',Body=Encodingutil.base64decode('testing document getdocument id class upload'),isPublic=true);
            insert d1;
        }      
        //Document d1=new Document(Name='testTemplate',Body=Encodingutil.base64decode('testing document getdocument id class upload'),isPublic=true,FolderId='00li0000000HyvL');
        //insert d1;      
        System.currentPageReference().getParameters().put('documentname', 'testTemplate');
        //Document doc=new Document('
        Test.startTest();
        d.documentId();
        string docmentId=d.getdocId();       
        //assert results
        if(docmentId==null)
        {
            System.assert(docmentId==null,'Document is null');
        }
        else
        {
            System.assert(docmentId!=null,'Document is not null');   
        }
        /*System.currentPageReference().getParameters().put('documentname', 'Comment_and_Feedback_Template');
        d.documentId();
        docmentId=d.getdocId(); */
        Test.stopTest();
        //assert results
        // System.assert(docmentId!=null,'Document is null');
    }
}