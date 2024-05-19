@isTest
public class SampleFailingTestClass {

    public static testmethod void failingTest() {
        Account acc = new Account(Name= 'fredfredfred');
        insert acc;

        Account retAcc = [select id, phone from Account where id=:acc.id][0];
        System.assertNotEquals('867-5309', retAcc.phone); // Always fails.
    }
}
