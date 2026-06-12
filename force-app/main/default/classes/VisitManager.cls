public class VisitManager {
    
    
    public class dataBox{
        @AuraEnabled
        public List<Visit__c> visits {get; set;}
        @AuraEnabled
        public dailylog__c dailyLog {get; set;} 
        @AuraEnabled
        public List<Account> accounts {get; set;}
    }
    public VisitManager (){  
       usersList = [select id ,name from user where isactive = true and ( profile.name = 'Guest profile' or profile.name = 'System Administrator'   )];
 
    }
    public static List<Visit__c> visitList {get;set;} 
    public List<user> usersList {get;set;} 
    @remoteaction
    public static  List<Visit__c>  loadVisits(id userid){  
       visitList = [select id ,name,Visit_Type__c, Account1__r.Specialization__c,Account1__r.Account_Type__c,   Account__r.GeoLocation__latitude__s,Account__r.GeoLocation__longitude__s, status__c,    CheckedInLatitude__c, CheckedInLongitude__c from Visit__c  where createdbyid =:userid ];
       return visitList ;
    }
    
    
    @AuraEnabled
    public static List<Account> getAccounts(){
        List<Account> accountsList = new  List<Account>();        
        accountsList = [SELECT Id,Phone,Name,EId__c,Specialization__c,Account_Type__c,Contact_Person__c,GeoLocation__Latitude__s,GeoLocation__Longitude__s,Alternate_Mobile__c,Email__c,Store_Category__c,Grade__c,Approval_Status__c   from  Account   where /*ownerId =: userinfo.getUserId() and*/ Approval_Status__c=:'Approved' ];        
        return accountsList;
    }
    
    
    
    @AuraEnabled
    public static DailyLog__c getDailyLog(){
        List<DailyLog__c> clockinClockout = [SELECT id,Clock_In_Location__Latitude__s,Clock_In_Location__Longitude__s,Clock_Out_Location__Latitude__s,Clock_Out_Location__Longitude__s,Clock_In__c,Clock_Out__c from  DailyLog__c  WHERE    Clock_In__c = TODAY AND OwnerId =:UserInfo.getUserId() limit 1]; 
        if(clockinClockout.size() == 0){
            return null;
        }else{
            system.debug(clockinClockout[0]);
        } return clockinClockout[0]; 
    }
    @AuraEnabled
    public static List<Visit__c> getTodaysVisits(){     
        List<Visit__c> listVisits =  [SELECT Id,Visit_Type__c,Account1__r.Specialization__c,Account1__r.Account_Type__c,  Revisit__c,Store_EID__c,Account1__r.GeoLocation__Latitude__s,TA_DA_Applicable__c,Account1__r.GeoLocation__Longitude__s,EId__c,Meet_and_greet__c,Placements__c,Checked_expiry__c,Product_introduction__c,presentation__c,marketing_material__c,AccountName__c,CheckedOutLatitude__c,CheckedOutLongitude__c,ClockIn_Latitude__c,Clockin_Longitude__c,Account1__r.EId__c,Clockout_Longitude__c,Comments__c,Name,OwnerId,Actual_Start_Time__c,Actual_End_Time__c,Missed_PostPone_Reason__c,Planned_Start_Time__c,Status__c,Account1__r.Phone,Account1__r.Contact_Person__c,Account1__r.Name from Visit__c where  Test_Names__c = null and  Planned_Start_Time__c = TODAY  and  OwnerId =:userinfo.getUserId()  ORDER BY status__c asc ]; 
        return  listVisits;    
    }
        @AuraEnabled
    public static List<Visit__c> getTodaysVisitsP(){     
        List<Visit__c> listVisits =  [SELECT Id,Visit_Type__c,Patient__c,Patient__r.Name, Account1__r.Specialization__c,Account1__r.Account_Type__c,  Revisit__c,Store_EID__c,Account1__r.GeoLocation__Latitude__s,TA_DA_Applicable__c,Account1__r.GeoLocation__Longitude__s,EId__c,Meet_and_greet__c,Placements__c,Checked_expiry__c,Product_introduction__c,presentation__c,marketing_material__c,AccountName__c,CheckedOutLatitude__c,CheckedOutLongitude__c,ClockIn_Latitude__c,Clockin_Longitude__c,Account1__r.EId__c,Clockout_Longitude__c,Comments__c,Name,OwnerId,Actual_Start_Time__c,Actual_End_Time__c,Missed_PostPone_Reason__c,Planned_Start_Time__c,Status__c,Account1__r.Phone,Account1__r.Contact_Person__c,Account1__r.Name from Visit__c where Test_Names__c != null and  Planned_Start_Time__c = TODAY  and  OwnerId =:userinfo.getUserId()  ORDER BY status__c asc ]; 
        return  listVisits;    
    }
    @AuraEnabled
    public static List<account> upsertAccounts(List<account> accountList ){
        List<account> updatelist = new List<account>();
        for(account acc : accountList){
            if(acc.Approval_Status__c == 'Approved' || acc.Approval_Status__c == ''){
                updatelist.add(acc);
            }
        }
        system.debug(updatelist);
        upsert updatelist;
        List<account> newaccList = [SELECT Id,Phone,Name,EId__c,Account_Type__c,Contact_Person__c,GeoLocation__Latitude__s,GeoLocation__Longitude__s,Alternate_Mobile__c,Email__c,Store_Category__c,Grade__c,Approval_Status__c   from  Account   where ownerId =: userinfo.getUserId() and Approval_Status__c=:'Approved']; 
        return newaccList; 
    }
    @AuraEnabled
    public static List<Visit__c> upsertVisits(string visitList ){ 
        system.debug(visitList);
        List<visit__c> vlist = (List<visit__c>)JSON.deserialize( visitList, List<visit__c>.class);
        database.upsert(vlist);
        List<Visit__c> listVisits =  [SELECT Id,Visit_Type__c,EId__c,Revisit__c,Store_EID__c,AccountName__c,CheckedOutLatitude__c,TA_DA_Applicable__c,CheckedOutLongitude__c,Meet_and_greet__c,Placements__c,Checked_expiry__c,Product_introduction__c,presentation__c,marketing_material__c,ClockIn_Latitude__c,Clockin_Longitude__c,Account1__r.EId__c,Account1__r.GeoLocation__Latitude__s,Account1__r.GeoLocation__Longitude__s,Clockout_Longitude__c,Account_Name__c,Comments__c,Account1__r.Name,Name,OwnerId,Actual_Start_Time__c,Actual_End_Time__c,Missed_PostPone_Reason__c,Planned_Start_Time__c,Status__c,Account1__r.Phone,Account1__r.Contact_Person__c from Visit__c where  Planned_Start_Time__c = TODAY  and  ownerId =:userinfo.getUserId()  ORDER BY status__c asc ];
        return listVisits; 
    }
    @AuraEnabled
    public static DailyLog__c upsertDailyLog(DailyLog__c dailylog){ 
        system.debug(dailylog);
        if(dailylog !=null ){
            List<Employee__c> emp = [select id,Email__c from Employee__c where Email__c =:UserInfo.getUserEmail() limit 1];
            if(emp.size() > 0){
                dailylog.Employee__c = emp[0].Id;
            }
            dailyLog.Present__c = true;
            upsert dailylog;
        }
        List<DailyLog__c> dl = [SELECT Id,Clock_In_Location__Latitude__s,Clock_In_Location__Longitude__s,Clock_Out_Location__Latitude__s,Clock_Out_Location__Longitude__s,Clock_In__c,Clock_Out__c from  DailyLog__c  WHERE    Clock_In__c = TODAY AND OwnerId =:UserInfo.getUserId() limit 1];
        if(dl.size() == 0){
            return null;
        }else{
            return dl[0];
        }
    }
    @AuraEnabled
    public static List<Product__c> getproductList(){    
        List<Product__c> listproducts =  [SELECT Id,Name,MRP__c,Product_Image_Url__c ,  Distributive_Price_10__c,TAX_Per_GST__c FROM Product__c];
        return listproducts;
    }
    @AuraEnabled
    public static List<Order__c> getOrders(){    
        List<Order__c> orderList =  [SELECT Id,EID__c, Name, Order_Date__c, Order_Status__c, Store__c,Store__r.EID__c, Store_name__c, Visit__c, Grand_Total__c,Visit__r.EID__c FROM Order__c WHERE CreatedDate=TODAY AND OwnerId=:userinfo.getUserId()];
        return orderList;
    }
    @AuraEnabled
    public static List<Order_Item__c> getOrderItems(){    
        List<Order_Item__c> orderList =  [SELECT Id,Order__r.EID__c,Visit__r.EID__c,Store__r.EID__c, Name, Unit_Price__c,Visit__c,Store__c, Price_MRP__c, Order__c, Product__c, Product_Name__c, Quantity__c, TAX_Per_GST__c, Tax_Value__c, Total_Amount__c, Total_Price__c FROM Order_Item__c WHERE CreatedDate=TODAY  AND Order__r.OwnerId=:userinfo.getUserId()];
        return orderList;
    }
    
     @AuraEnabled
    public static List<Order__c> upsertNewOrder(string orderList ){
        system.debug(orderList);
        List<Order__c> ordList = (List<Order__c>)JSON.deserialize( orderList, List<Order__c>.class);
        database.upsert(ordList);
        //Upsert ordList;
       List<Order__c> updatedOrderList =  [SELECT Id,EID__c, Name, Order_Date__c, Order_Status__c, Store__c,Store__r.EID__c, Store_name__c, Visit__c, Grand_Total__c,Visit__r.EID__c FROM Order__c WHERE CreatedDate=TODAY  AND OwnerId=:userinfo.getUserId()];
        return updatedOrderList;
    }
    @AuraEnabled
    public static List<Order_Item__c> upsertOrderItem(string  orderItemList ){
      
      /*  List<Order_Item__c> ordItList = new List<Order_Item__c>();
        for(Order_Item__c ord : orderItemList){
          Order_Item__c orl = ord;
            ordItList.add(orl);
        }
          upsert orderItemList;*/
        system.debug(orderItemList);
        string newstring = orderItemList.replace('[','');
        string newstring2 = newstring.replace(']','');
        string newstring3 = '['+newstring2+']';
         List<Order_Item__c> ordList = (List<Order_Item__c>)JSON.deserialize( newstring3, List<Order_Item__c>.class);
        Upsert ordList;
      
       /* system.debug(orderItemList + ' '+storeId);
        List<Order_Item__c> orList = new List<Order_Item__c>();
        Order__c ord = new Order__c();
        ord.Store__c = storeId;
        ord.Order_Date__c = system.today();
        //ord.Grand_Total__c = grandtotal;
        insert ord;
        
        for(Order_Item__c ol : orderItemList){
            ol.Order__c = ord.id; 
            orList.add(ol);
            
        }
        insert orList;*/
        List<Order_Item__c> orderList =  [SELECT Id, Name,Order__r.EID__c,Visit__r.EID__c,Store__r.EID__c, Unit_Price__c,Visit__c,Store__c, Price_MRP__c, Order__c, Product__c, Product_Name__c, Quantity__c, TAX_Per_GST__c, Tax_Value__c, Total_Amount__c, Total_Price__c FROM Order_Item__c WHERE CreatedDate=TODAY  AND Order__r.OwnerId=:userinfo.getUserId()];

        return orderList;
    }
    
    @auraEnabled
    Public static List<Asset__c> getAssetData(){
        
        return [SELECT Id,Name,File_Url__c FROM Asset__c];
    }
    
    @auraEnabled
    Public static string upsertAssetActivity(string assetId, string activityId, Datetime startTime,Datetime endTime){
        Asset_Activity__c ass = new Asset_Activity__c();
        if(activityId !=null){
            ass.Id = activityId;
        }
         ass.Asset__c = assetId;
        ass.Start_Time__c = startTime;
        ass.End_Time__c = endTime;
        
        upsert ass;
        return ass.Id;
    }
    
    @AuraEnabled
public static List<Store_Stock__c> upsertStockEntry(String stockList) {
    System.debug('Stock List: ' + stockList);
    
    List<Store_Stock__c> stList = (List<Store_Stock__c>)JSON.deserialize(stockList, List<Store_Stock__c>.class);
    
    Database.upsert(stList);
    
    List<Store_Stock__c> updatedStockList = [
        SELECT Id, Name, Product__c, Available_Stock__c, Account__c, Visit__c 
        FROM Store_Stock__c 
        WHERE CreatedDate = TODAY 
        AND CreatedById = :UserInfo.getUserId()
    ];
    
    return updatedStockList;
}
    
     @AuraEnabled
public static Order__c upsertOrderEntry(String stockList, String visitId, string accountId) {
    System.debug('Stock List: ' + stockList);
    
    List<Order_Item__c> stList = (List<Order_Item__c>)JSON.deserialize(stockList, List<Order_Item__c>.class);
    
    Order__c ord = new Order__c();
    ord.Store__c = accountId;
    ord.Visit__c = visitId;
    insert ord;
    for(Order_Item__c ordLi : stList){
        ordLi.Order__c = ord.Id;
        ordLi.Unit_Price__c = 140;
    }
    Database.upsert(stList);
    
   
    return Ord;
}
    

}