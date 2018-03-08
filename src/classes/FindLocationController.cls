public with sharing class FindLocationController {

   /* public PageReference cancel() {
       String urlform='/one/one.jsp';
           PageReference saveClicked=new PageReference(urlform);
           saveClicked.setRedirect(true);
           return saveClicked;
    }
 public PageReference callcancel() {
       String urlform='/one/one.jsp';
           PageReference saveClicked=new PageReference(urlform);
           saveClicked.setRedirect(true);
           return saveClicked;
    }*/
public User currentuser{get;set;}
public String userid{get;set;}
public FindLocationController() {
currentuser = [select id, name,Email ,Location__Latitude__s,Location__Longitude__s from User where id = :Userinfo.getUserId()];
    }


    
    public PageReference submit()
    {System.debug('----current user'+currentuser);
        update currentuser;
        String urlform='/one/one.jsp';
      
           PageReference saveClicked=new PageReference(urlform);
          
           saveClicked.setRedirect(true);
           return saveClicked;
    }    
     public static testMethod void testlistacc()
 {
    FindLocationController  d= new FindLocationController ();
    Test.startTest();  
   
    d.submit();
    System.assert(d.currentuser !=null);
    Test.stopTest();
     
 }
}