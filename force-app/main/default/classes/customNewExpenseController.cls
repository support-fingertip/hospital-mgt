public class customNewExpenseController {

     public class dataBox{
        @AuraEnabled
        public Date Todaydate {get; set;}
        @AuraEnabled
        public Date yersterdaydate {get; set;}         
        @AuraEnabled
        public Date twodaydate {get; set;} 
        @AuraEnabled
        public string listId {get; set;} 
        @AuraEnabled
        public integer inprogressCount {get; set;}  
        @AuraEnabled
        public integer plannedCount {get; set;}   
     }
     @AuraEnabled
     public static dataBox getDates(){
             dataBox db = new dataBox();
             db.Todaydate = system.today();
             date mydate = system.today();
             db.twodaydate = mydate.addDays(-2);
             db.yersterdaydate = mydate.addDays(-1);
              List<ListView> listviews = [SELECT Id, Name FROM ListView WHERE SobjectType = 'Expense__c' and Name='All'];
			db.listId = listviews[0].Id;
             List<visit__c> inprogressList= [SELECT id,Name,Status__c FROM visit__c WHERE Status__c = 'In Progress' AND Planned_Start_Time__c = TODAY AND ownerId =:userinfo.getUserId()];
             db.inprogressCount = inprogressList.size();
              List<visit__c> plannedList= [SELECT id,Name,Status__c FROM visit__c WHERE Status__c = 'Planned' AND Planned_Start_Time__c = TODAY AND ownerId =:userinfo.getUserId()];
             db.plannedCount = plannedList.size();
             return db;
     }    
     @AuraEnabled
     public static Expense__c insertExpense(Expense__c expense){ 
        if(expense !=null ){
            upsert expense;
            return expense;
        }else{
            return null;
        }
        
    }
    @AuraEnabled
    public static void submitapproval(string expId){ 
        List<Approval.ProcessSubmitRequest> requests = new List<Approval.ProcessSubmitRequest>();
        Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
        req.setObjectId(expId);
        requests.add(req);
    	Approval.ProcessResult[] processResults = Approval.process(requests);
    
    
    }
    
}