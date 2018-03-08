@RestResource(urlMapping='/ASMFieldset/*')
global with sharing class RestGetAssignmentManagerFieldset {

  @HttpPost
  global static String getAssignmentManagerFieldset() {


    return MobileAppUtill.returnASMFieldset(null);
  }
}