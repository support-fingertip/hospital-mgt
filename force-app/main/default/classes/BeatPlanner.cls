global class BeatPlanner {   
    
    @AuraEnabled
    public static List<Route__c> getRouteList(String uId) {
        return  [SELECT Id,Geolocation__Latitude__s , Geolocation__Longitude__s, Name FROM Route__c where ownerId =: uId]; 
        
    }
  public static string accountList {get;set;} 
  public static Route__c route  {get;set;} 
 
   public static pagereference getAccountsList( ) { 
   
   
       string beatId = ApexPages.currentPage().getParameters().get('id');
       string uId = ApexPages.currentPage().getParameters().get('eid');
       string routeId  = ApexPages.currentPage().getParameters().get('rid'); 
        if(routeId != null && routeId != ''){
          route =  [select id,Geolocation__Latitude__s , Geolocation__Longitude__s from Route__c where id=:routeId  ];
        }else{
            route =  [select id,Geolocation__Latitude__s , Geolocation__Longitude__s from Route__c  ][0];

        }

        List<Beat_Line__c> blist = [select id,Account__c from Beat_Line__c where beat__c =: beatId];  
        List<id> existds = new list<id>();
        for(Beat_Line__c b: blist){ 
           existds.add( b.Account__c); 
        }  
        
        
        accountList = JSON.serialize( [SELECT Id, Name,Owner.Name,Specialization__c, Geolocation__Latitude__s , Geolocation__Longitude__s FROM Account WHERE OwnerId=:uId AND Routes__c=:routeId and id not in : existds ]);
        return null; 
        
    }
   
    
    @AuraEnabled @remoteaction
    public static List<Account> getAccountList( string uId,string routeId , string beatId) { 
        
        route =  [select id,Geolocation__Latitude__s , Geolocation__Longitude__s from Route__c where id=:routeId  ];
        List<Beat_Line__c> blist = [select id,Account__c from Beat_Line__c where beat__c =: beatId]; 
        List<id> existds = new list<id>();
        for(Beat_Line__c b: blist){ 
           existds.add( b.Account__c);
        }  
        
        return [SELECT Id, Name,Owner.Name, Geolocation__Latitude__s ,Specialization__c, Geolocation__Longitude__s FROM Account WHERE OwnerId=:uId AND Routes__c=:routeId and id not in : existds ]; 
        
    }
    
    

    
    public static  Map<decimal, List<Beat_Line__c>> bmap  {get;set;}
    @AuraEnabled
    public static void getbeatLineList() {
        string   beatId = apexpages.currentPage().getParameters().get('id'); 
        bmap  =  new  Map<decimal, List<Beat_Line__c>>();
        Beat__c beat = [select id, Number_Days__c from beat__c where id=: beatId];
        List<Beat_Line__c>  blist = [ SELECT Id, day__c, Name,  Beat__c, Account__c,  Account__r.Name FROM Beat_Line__c where beat__c=:BeatId order by Day__c asc ];
        for(Beat_Line__c b: blist){ 
            if(bmap.containsKey(b.day__c)) 
            {
                bmap.get(b.day__c).add(b);
            }else{
                bmap.put(b.day__c, new list<Beat_Line__c>{b} );
            }
        } 
        for(decimal i=1;i<=beat.Number_Days__c;i++){
            
            if(bmap.get(i) ==null){
                bmap.put(i, new List<Beat_Line__c>()) ;
                system.debug(i);
            }
            
           
        }
        system.debug( 'bmap'+bmap);
    }
   
    
    @AuraEnabled
    public static void createBeatLines( string uId, string  beatId,string day,List<sobject> lines) {
        List<Beat_Line__c> bList = new List<Beat_Line__c>();
       //SELECT Id, Day__c, Today_Selection__c, Sub_Mode_of_transport__c, Number_of_Visits_Required__c,
       // Beat_User__c, Assigned_Beat_User__c, With__c, With_Executive_2__c, Where__Longitude__s, 
       // Where__Latitude__s, When__c, Type_of_Visit__c, Mode_of_Transport__c, Day_Order__c, Accounts__c,
       //  Account__c, Beat__c, Name FROM Beat_Line__c
       //  
    
        for(sobject so: lines){
            
            Account  a = (Account )so;
            Beat_Line__c bl= new Beat_Line__c();
            bl.Beat__c = beatId;
            bl.Day__c = integer.valueof( day );
            bl.Account__c = a.id;
            bList.add(bl); 
            
            
        }
        insert bList;
         
        
     }
    @remoteaction
    public static string deleteVisitPlan(String deleteId){
        delete [select id from beat_line__c where id=: deleteId];  
        return 'success';
        
    }
     @AuraEnabled
    public static void createVisits(  string beatId) { 
        Beat__c beat = [SELECT Id, Name, Next_Day_Order__c, To_Day__c, Executive__c, From_Day__c, Number_Days__c, Off_Days__c FROM Beat__c where id=:beatId ];
        List<Beat_Line__c>  blist = [ SELECT Id, day__c, Name,  Beat__c, Account__c,  Account__r.Name, Day_Order__c, Mode_of_Transport__c, Type_of_Visit__c, When__c, Where__Latitude__s, Where__Longitude__s, Where__c,         Sub_Mode_of_transport__c FROM Beat_Line__c where beat__c=:BeatId order by Day__c asc ];
        List<visit__c> visitExList = [select id,status__c from visit__c where Beat_Line__c in:blist and status__c = 'Planned' ];
       List<Holiday__c> hlist = [select id,date__c from Holiday__c];
        List<Beat_Skip__c> bslist = [select id,Date_Skipped__c from Beat_Skip__c]; 
        
         delete visitExList;
        
         Set<Id> beatLines = new  Set<Id>();
         Set<date> skipset = new  Set<date>();
         List<visit__c> vlist = new  List<visit__c>(); 

         for(Holiday__c h: hlist){
            skipset.add(h.date__c);
         } 
         for(Beat_Skip__c b: bslist){
             skipset.add(b.Date_Skipped__c);
         }  
        
        datetime startdate = beat.From_Day__c;
        datetime enddate = beat.To_Day__c;
        datetime currDate =  startdate;
        decimal oldday = 1;
        while(currDate <= enddate){
              
              for(Beat_Line__c bl : blist){ 
                 visit__c v = new visit__c();
                 
                  if(oldday !=  bl.Day__c){
                      oldday =  bl.Day__c;
                      currDate = currDate.addDays( 1 );
                  }
                   
               
                  while((beat.Off_Days__c != null && beat.Off_Days__c.contains(currDate.format('EEEE') )) ||   skipset.contains( date.valueof( currDate ) )  ){
                      currDate = currDate.addDays(1);
                  } 
                  
                  v.Planned_Start_Time__c = currDate;
                  v.Status__c = 'Planned';  
                  v.Account1__c = bl.Account__c;
                  v.Beat_Line__c = bl.id;
                  currDate = v.Planned_Start_Time__c;
                  v.ownerId = beat.Executive__c;
                  vlist.add(v); 
                  
            }
 
         }
       
        insert vlist;
    
    }
 
}