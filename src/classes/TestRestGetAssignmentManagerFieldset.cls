@isTest

public class TestRestGetAssignmentManagerFieldset {
    
    static testmethod void method1(){
        String ret = RestGetAssignmentManagerFieldset.getAssignmentManagerFieldset();
    
        System.assert( ret != Null);
    }
}