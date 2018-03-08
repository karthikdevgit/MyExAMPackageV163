@isTest
public class TestMyController {

    static testMethod void method1() {

        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('', '--None--'));
        
        Account[] accList = new Account[]{
            new Account(Name = 'test acc 1'),
            new Account(Name = 'test acc 2')    
        };
        insert accList;
        
        Account acc = new Account(Id = accList[1].Id, ParentId =accList[0].Id);
        update acc;
        
        MyController mc = new MyController();
        mc.accountId = acc.Id;
        mc.accountOptions = options;
        List<SelectOption> so = mc.accountOptions;
        system.assertEquals(so.size(), 3);
    }
}