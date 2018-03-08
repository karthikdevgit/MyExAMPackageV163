@RestResource(urlMapping='/InspectionReportASM/*')
global with sharing class RestGetInspectionReportASM {

  @HttpPost
  global static String getInspectionReportASM(String objectName,List<String> fieldNameList,String IdValue) {
    
    String resultString;
    if(String.isNotEmpty(objectName) && String.isNotEmpty(IdValue) && fieldNameList.size()> 0){
       resultString = MobileAppUtill.returnASM(objectName,fieldNameList,IdValue);
    }else{
        resultString = 'false';
    }
    return resultString;
  }
   
}