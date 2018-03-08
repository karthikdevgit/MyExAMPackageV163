@RestResource(urlMapping='/ASMFieldsetWithASM/*')
global with sharing class RestGetAssignmentManagerWithFieldset {

  @HttpPost
  global static String getAssignmentManagerWithFieldset(String ASMId) {


    return MobileAppUtill.returnASMFieldset(ASMId);
  }
}