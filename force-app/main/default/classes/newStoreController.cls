public class newStoreController {
 public class dataBox{
@AuraEnabled
public List<Warehouse__c> whList {get; set;} 
 @AuraEnabled
public string listId {get; set;} 
     }

            @AuraEnabled
         public static dataBox getwarehouseList(){
             dataBox db = new dataBox();
           db.whList = [SELECT Id,Name FROM Warehouse__c];
             system.debug(db.whList);
              List<ListView> listviews = [SELECT Id, Name, DeveloperName, SobjectType FROM ListView WHERE SobjectType ='Account' and DeveloperName='AllAccounts'];
			db.listId = listviews[0].Id;
             return db;
         }
    
    @AuraEnabled
    public static Account insertAccount(Account acc){ 
        if(acc !=null ){
        upsert acc;
            system.debug(acc.id);
            return acc;
          
        }else{
            return null;
        }
        
    }
     @AuraEnabled
    public static List<Route__c> getRouteList(string whId) {
        return [SELECT Id,Name FROM Route__c WHERE warehouse__c =:whId AND ownerId =: userinfo.getUserId()];
    }
      @AuraEnabled
    public static void submitapproval(string storeId){ 
        
        List<Approval.ProcessSubmitRequest> requests = new List<Approval.ProcessSubmitRequest>();
    
          Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
          req.setObjectId(storeId);
        
          requests.add(req);
    	
    	Approval.ProcessResult[] processResults = Approval.process(requests);
    
    
    }
}