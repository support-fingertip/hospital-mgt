@isTest
public class visitManagerTest {
	 public static testMethod void movetoNext(){
         Warehouse__c wh = new Warehouse__c();
        wh.name = 'test';
        insert wh;
        List<Route__c> rut = new List<Route__c>();
        Route__c r = new Route__c();
        r.warehouse__c = wh.id;
        r.Name = 'test route';
        rut.add(r);
        insert rut;
          List<Account> acLIst = new List<Account>();
        Account acc=new Account();
        acc.Name='testaccount';
        acc.Phone = '9985522322';
        acc.Contact_Person__c = 'test';
        acc.Store_Category__c = 'Hyper market';
        acc.Grade__c = 'A';
        acc.EId__c = 'S25321252hsb2';
      	acc.OwnerId = UserInfo.getUserId();
        acc.GeoLocation__latitude__s=23.733732;
        acc.GeoLocation__Longitude__s=69.859741;
        acc.warehouse__c = rut[0].warehouse__c;
        acc.routes__c = rut[0].id;
        acc.Approval_Status__c = 'Approved';
         acLIst.add(acc);
        insert acLIst;
      	
         List<Visit__c> visitList = new List<Visit__c>();
        /*Visit__c vst1 = new Visit__c();
        vst1.Actual_Start_Time__c = System.now();
        vst1.Planned_Start_Time__c = System.now();
        vst1.Account1__c=acc.id;
         vst1.Eid__c = 'mnh25ad221a5';
        vst1.Status__c = 'Planned';
        vst1.Comments__c = 'Reach ASAP';
        visitList.add(vst1);*/
         
        
        Visit__c vst2 = new Visit__c();
        vst2.Actual_Start_Time__c = system.now();
        vst2.Account1__c=acLIst[0].id;
        vst2.Planned_Start_Time__c = system.now();
        vst2.Eid__c = 'mnh25ad221a5';
        vst2.Status__c = 'Planned';
        vst2.Comments__c = 'Reachndhd';
         visitList.add(vst2);
        insert visitList;
         
         Product__c pro = new Product__c();
         pro.Name = 'test';
         insert pro;
         
         string acid= acc.id;
         string pid = pro.id;
         Order__c ord = new Order__c();
         ord.Store__c = acLIst[0].id;
         insert ord;
         List<Order_Item__c> oiList = new List<Order_Item__c>();
         Order_Item__c oitem = new Order_Item__c();
         oitem.order__c= ord.Id;
         
         oiList.add(oitem);
string ord1 = JSON.serialize(oitem);
         DailyLog__c dl = new DailyLog__c();
         dl.Clock_In__c = system.now();
         dl.Clock_In_Location__Latitude__s = 23.733732;
         dl.Clock_In_Location__Longitude__s = 69.859741;
         insert dl;
         string vs1 = JSON.serialize(visitList);
        // VisitManager.getdata();
        // VisitManager.getUserRoutes();
        // VisitManager.getWarehouses();
         VisitManager.getAccounts();
         VisitManager.upsertAccounts(acLIst);
         VisitManager.getTodaysVisits();
         VisitManager.upsertVisits(vs1);
         VisitManager.getDailyLog();
         VisitManager.upsertDailyLog(dl);
         VisitManager.getproductList();
         VisitManager.getOrderItems();
         VisitManager.upsertOrderItem(ord1);
     }
    
}