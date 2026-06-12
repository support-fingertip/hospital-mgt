public  class GooleMapSearch {
    
    @remoteaction
    public static string createLead(string name,string address,string website,string ph ){
        
        Account acc  =  new Account ();
        acc.name = name;
        acc.Street_Name__c = address;
       // l.Approval_Status__c= 'Pending';
        acc.phone = ph;
        acc.Alternate_Mobile__c = ph;
        insert acc;
        
        return 'Success';
        
    }

}