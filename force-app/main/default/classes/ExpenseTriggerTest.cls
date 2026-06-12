@isTest
public class ExpenseTriggerTest {
    public static testmethod void testexpense(){
        Expense__c e = new Expense__c();
        e.Expense_Date__c = system.today();
        e.TA__c = 500;
        insert e;
        e.Approval_Status__c = 'Approved';
        update e;
         e.Approval_Status__c = 'Rejected';
        update e;
    }
}