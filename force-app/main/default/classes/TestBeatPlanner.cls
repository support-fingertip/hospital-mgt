@isTest
public class TestBeatPlanner {
   @isTest public static void testBeat(){
        Id u=userinfo.getUserId();
        list<Visit__c>lstVist = new list<Visit__c>();
        list< Route__c>lstRoute =new list<Route__c>();
         beat__c bt = new beat__c();
        bt.Executive__c = userinfo.getUserId();
        bt.From_Day__c = date.today();
        bt.To_Day__c  = date.today().adddays(1);
        bt.Off_Days__c = 'Sunday';
        bt.Number_Days__c = 1;
        insert bt;
   
     
     
        Route__c rt =new Route__c (Name='TestMuncipality' );
        lstRoute.add(rt);
        Route__c rt1 =new Route__c (Name='TestMuncipality1' );
        lstRoute.add(rt1);
        insert lstRoute;
       
        
        List<account> lstacc = new List<account>();
       
        
        Account acc=new Account(Name='Test',Approval_Status__c='approved',phone='1111111111',State__c='Kerala',District__c='Kannur',Routes__c=rt.Id,ownerId=UserInfo.getUserId());
        insert acc;
        lstacc.add(acc);
        
        Account acc1=new Account(Name='Test122',Approval_Status__c='approved',phone='1111111111',State__c='Kerala',District__c='Kannur',Routes__c=rt.Id,ownerId=UserInfo.getUserId());
        insert acc1;
        
        lstacc.add(acc1);
     
     
        beat_line__c bl = new beat_line__c();
        bl.Day__c = 1;
        bl.Beat__c = bt.id;
        bl.account__c = acc.id; 
        insert bl;
        bl = new beat_line__c();
        bl.account__c = acc.id; 
        bl.Day__c = 2;
        bl.Beat__c = bt.id; 
        insert bl;
     
         Visit__c vst = new Visit__c();
         vst.Planned_Start_Time__c = system.now();
         vst.Status__c = 'Planned';
         vst.OwnerId =UserInfo.getUserId();
        vst.Account1__c = acc1.Id;
        lstVist.add(vst);
        Visit__c vst1 = new Visit__c();
        vst1.Planned_Start_Time__c = system.now();
        vst1.Account1__c =acc.Id;
        vst1.Status__c = 'Planned';
         vst1.OwnerId =UserInfo.getUserId();
        lstVist.add(vst1);
         Visit__c vst2 = new Visit__c();
        vst2.Planned_Start_Time__c = system.now();
        vst2.Account1__c =acc.Id;
        vst2.Status__c = 'Planned';
        vst2.OwnerId =UserInfo.getUserId();
        lstVist.add(vst2);
        insert lstVist;
        Test.startTest();
        
        Pagereference p =  page.beatplanner;
         p.getParameters().put('id',  bt.id);
      
       Test.setCurrentPage(p);//Applying page context here
 
       ApexPages.currentPage().getParameters().put('id', bt.id);
      
         beatplanner.createBeatLines(userinfo.getUserId(),bt.id, '1',lstacc ); 
         beatplanner.createVisits(bt.Id);
        
         Test.stopTest();   
        
    }
  @isTest public static void testBeat1(){
        Id u=userinfo.getUserId();
        
        list<Visit__c>lstVist = new list<Visit__c>();
        list< Route__c>lstRoute =new list<Route__c>();
        list<Account> lstacc = new list<Account>();
        beat__c bt = new beat__c();
        bt.Executive__c = userinfo.getUserId();
        bt.From_Day__c = date.today();
        bt.To_Day__c  = date.today().adddays(1);
        bt.Off_Days__c = 'Sunday';
        bt.Number_Days__c = 1;
        insert bt;
   
     
     
        Route__c rt =new Route__c (Name='TestMuncipality' );
        lstRoute.add(rt);
        Route__c rt1 =new Route__c (Name='TestMuncipality1' );
        lstRoute.add(rt1);
        insert lstRoute;
        
        
      
       
        
        Account acc=new Account(Name='Test',Approval_Status__c='approved',phone='1111111111',State__c='Kerala',District__c='Kannur',Routes__c=rt.Id,ownerId=UserInfo.getUserId());
        insert acc;
        lstacc.add(acc);
        
        Account acc1=new Account(Name='Test122',Approval_Status__c='approved',phone='1111111111',State__c='Kerala',District__c='Kannur',Routes__c=rt.Id,ownerId=UserInfo.getUserId());
        insert acc1;
        
        lstacc.add(acc1);
     
     
          beat_line__c bl = new beat_line__c();
        bl.account__c = acc.id;
        bl.Day__c = 1;
        bl.Beat__c = bt.id;
        insert bl;
     
         Visit__c vst = new Visit__c();
        vst.Planned_Start_Time__c = system.now();
         vst.Status__c = 'Planned';
         vst.OwnerId =UserInfo.getUserId();
        vst.Account1__c =acc.Id;
        lstVist.add(vst);
        Visit__c vst1 = new Visit__c();
        vst1.Planned_Start_Time__c = system.now();
        vst1.Account1__c =acc.Id;
        vst1.Status__c = 'Planned';
         vst1.OwnerId =UserInfo.getUserId();
        lstVist.add(vst1);
         Visit__c vst2 = new Visit__c();
        vst2.Planned_Start_Time__c = system.now();
        vst2.Account1__c =acc.Id;
        vst2.Status__c = 'Planned';
        vst2.OwnerId =UserInfo.getUserId();
        lstVist.add(vst2);
        insert lstVist;
        Test.startTest();
        
        Pagereference p =  page.beatplanner;
         p.getParameters().put('id',  bt.id);
      
       Test.setCurrentPage(p);//Applying page context here
 
        ApexPages.currentPage().getParameters().put('id', bt.id);
      
        beatplanner.getRouteList();
        beatplanner.getAccountList(UserInfo.getUserId(),rt.Id,bt.id);
        beatplanner.getbeatLineList();
 
         Test.stopTest();   
        
    }
}