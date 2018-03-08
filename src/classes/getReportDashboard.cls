public with sharing class getReportDashboard
{

public String documentname{ get; set; }
public String docid{ get; set; }
public List<Report> listReports{ get; set; }
public List<Dashboard> listDashboards{ get; set; }

public getReportDashboard()
{
 try{
folder[] ff = [select id,name from folder where name = 'DOI BI Reports'];
System.debug('~~~~~~~~~~~~~:'+ff);
id fid = (ff.isEmpty()) ? null : ff[0].id;
listReports = [select id, name from report where ownerid = : fid];
System.debug('docid:'+listReports);

List<Folder> fs = [select Id, Name from Folder where Type = 'Dashboard' and Name ='DOI BI Dashboards' limit 1];
System.debug('!!!!!!!!!!!!!!!!!dash:'+fs );
//Then use the Dashboard.FolderId to find the Dashboards in whatever folder you want.  
/*for (Folder f : fs) {
 
 List<Dashboard> d = [select Id,title from Dashboard where FolderId= :f.Id]; 
 System.debug('~~~~~~~~~~~dasss'+d);
}*/
 listDashboards = [select Id,title from Dashboard where FolderId= :fs[0].Id]; 
 }catch(Exception e){System.debug('--- exception'+e);}
}
/*public void documentId()
   {
        folder[] ff = [select id,name from folder where name = 'DOI BI Reports'];
        System.debug('~~~~~~~~~~~~~:'+ff);
        id fid = (ff.isEmpty()) ? null : ff[0].id;
        listReports = [select id, name from report where ownerid = : fid];
        System.debug('docid:'+listReports);
        
        System.debug('~~~~~~~~~~~doc name'+documentname);
        documentname=System.currentPageReference().getParameters().get('documentname');
        System.debug('doc name'+documentname);
        List<Report> lstDocument = [Select Id,Name from Report where Name =:documentname limit 1];
        string strOrgId = UserInfo.getOrganizationId();
        string strDocUrl = 'https://'+ApexPages.currentPage().getHeaders().get('Host')+ '/'+lstDocument[0].Id+'&oid=' + strOrgId;
        System.debug('doc url'+strDocUrl );
        docid=lstDocument[0].Id;

       
   }

public string getdocId()
{
return docid;
}*/

@isTest(SeeAllData=true)
public static void testlistacc()
 {    
     
     //List<Report> listReport=new List<report>;
     //List<Dashboard> listDashboard{ get; set; }
     
     Test.startTest();      
         getReportDashboard d= new getReportDashboard(); 
     Test.stopTest();       
     //assert results  
     System.assert(d!=null,' folder is null');  
                     
 }
 
 }