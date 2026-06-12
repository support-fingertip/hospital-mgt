({
	doInit : function(component, event, helper) {
        component.set('v.account',{'Name':'','Phone':'','Approval_Status__c':'','Email__c':'','Contact_Person__c':'','Alternate_Mobile__c':'','Warehouse__c':'','Routes__c':'','Street_Name__c':'','Store_Category__c':'','Grade__c':'','State__c':'','GST__c':'','District__c':'','Panchayath__c':'','City__c':'','Pin_code__c':'','Description':''});
         helper.getWarehouses(component,event,helper); 
        helper.fetchStatePicklist(component,event,helper); 
       
    },
    closeExpense: function (component, event, helper) {
       var navEvent = $A.get("e.force:navigateToList");
            navEvent.setParams({
                "listViewId": component.get('v.listId'),
                "listViewName": null,
                "scope": "Account"
            });
            navEvent.fire();

    },
    gotoRecord : function (component, event, helper) {
       var navEvt = $A.get("e.force:navigateToSObject");
   			 navEvt.setParams({
      		"recordId": component.get('v.account.Id'),
      		"slideDevName": "detail"
    });
    navEvt.fire();

    },
  
     getdisricts: function(component, event, helper) {
        helper.districtPickList(component, event, helper);
    },
     dosave : function (component, event, helper) {
        
        let isAllValid = component.find('field1').reduce(function(isValidSoFar, inputCmp){
            inputCmp.showHelpMessageIfInvalid();
            return isValidSoFar && inputCmp.checkValidity();
        },true);
        
        if(isAllValid == true){
        if(component.get('v.account.Warehouse__c')==''){
                helper.showToast("Please select warehouse","error");
            }else if(component.get('v.account.Routes__c')==''){
                helper.showToast("Please select route","error");
            }else{
			helper.createStore(component, event, helper);                
            }
        }
    },
    doPrevious: function (component, event, helper) {
        component.set('v.showAccount',true);
         component.set('v.showUpdate',true);
                 component.set('v.showUpload',false);
    },
     donext: function (component, event, helper) {
        component.set('v.showUpdate',false);
          component.set('v.showAccount',false);
      component.set('v.showUpload',true);
    },
    doSubmit : function (component, event, helper) {
        helper.approvalSubmit(component, event, helper);
        
    },
    doSearch : function (component, event, helper) {
         var whs= component.get('v.warehouse');
        var searchText= component.get('v.searchText');
        var matchwhs=[];
        if(searchText !=''){
        for(var i=0;i<whs.length; i++){ 
            if(whs[i].Name.toLowerCase().indexOf(searchText.toLowerCase())  != -1  ){
               matchwhs.push( whs[i] )
            } 
         } 
           
            if(matchwhs.length >0){
		 component.set('v.matchWarehouse',matchwhs);
            }else{
                 component.set('v.matchWarehouse',[]);
            }
        }else{
            component.set('v.matchWarehouse',[]);
            component.set('v.routeSearchText','');
            component.set('v.account.Routes__c','');
            component.set('v.account.Warehouse__c','');
        }
        
    },
   update: function(component, event, helper) {
        component.set('v.account.Warehouse__c', event.currentTarget.dataset.id);
        var storeId = component.get('v.account.Warehouse__c');
         var matchwhsList= component.get('v.matchWarehouse');
        for(var i=0;i<matchwhsList.length; i++){ 
            if(matchwhsList[i].Id ===  storeId ){
               component.set('v.searchText', matchwhsList[i].Name);
                break;
            } 
         } 
         component.set('v.matchWarehouse',[]);
      helper.fecthRoute(component, event, helper);
   
    },
  doRouteSearch : function (component, event, helper) {
         var rts= component.get('v.Routes');
        var searchText= component.get('v.routeSearchText');
        var matchrts=[];
        if(searchText !=''){
        for(var i=0;i<rts.length; i++){ 
            if(rts[i].Name.toLowerCase().indexOf(searchText.toLowerCase())  != -1  ){
               matchrts.push( rts[i] );
            } 
         } 
            if(matchrts.length >0){
		 component.set('v.matchRoutes',matchrts);
            }else{
                component.set('v.matchRoutes',[]);
            }
        }else{
            component.set('v.matchRoutes',[]);
            component.set('v.routeSearchText','');
            component.set('v.account.Routes__c','');
        }
        
    },
   updateRoute: function(component, event, helper) {
        component.set('v.account.Routes__c', event.currentTarget.dataset.id);
        var routeId = component.get('v.account.Routes__c');
         var matchrtsList= component.get('v.matchRoutes');
        for(var i=0;i<matchrtsList.length; i++){ 
            if(matchrtsList[i].Id ===  routeId ){
               component.set('v.routeSearchText', matchrtsList[i].Name);
                break;
            } 
         } 
         component.set('v.matchRoutes',[]);
    },
})