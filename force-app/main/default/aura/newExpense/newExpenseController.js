({
	doInit : function(component, event, helper) {
		component.set('v.Expense',{'Expense_Date__c':'','TA__c':'' ,'DA__c':'','Other_Expenses__c':'','Mode_of_transport__c':'','Expense_Comments__c':''})
	 	   var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
         helper.getdates(component,event,helper); 
       
    },
    closeExpense: function (component, event, helper) {
       var navEvent = $A.get("e.force:navigateToList");
            navEvent.setParams({
                "listViewId": component.get('v.listId'),
                "listViewName": null,
                "scope": "Expense__c"
            });
            navEvent.fire();

    },
    gotoRecord : function (component, event, helper) {
       var navEvt = $A.get("e.force:navigateToSObject");
   			 navEvt.setParams({
      		"recordId": component.get('v.Expense.Id'),
      		"slideDevName": "detail"
    });
    navEvt.fire();

    },
  
     dosave : function (component, event, helper) {
        
        let isAllValid = component.find('field1').reduce(function(isValidSoFar, inputCmp){
            inputCmp.showHelpMessageIfInvalid();
            return isValidSoFar && inputCmp.checkValidity();
        },true);
        
        if(isAllValid == true){
            if(component.get('v.Expense.TA__c')=='' && component.get('v.Expense.DA__c') =='' && component.get('v.Expense.Other_Expenses__c')==''){
                helper.showToast("Please enter amount","error");
            }else{
                helper.createExpense(component, event, helper);
            }
         
        }
    },
    doPrevious: function (component, event, helper) {
        component.set('v.showexpense',true);
         component.set('v.showUpdate',true);
        component.set('v.showUpload',false);
    },
     donext: function (component, event, helper) {
        component.set('v.showUpdate',false);
          component.set('v.showexpense',false);
      component.set('v.showUpload',true);
    },
    doSubmit : function (component, event, helper) {
        helper.approvalSubmit(component, event, helper);
        
    }
})