({
    addStockRecord: function(component, event) {
        var stockList = component.get("v.stockList");
        var visitId = component.get("v.visitId");
        var accountId = component.get("v.accountId");
        
        stockList.push({
            'sobjectType': 'Store_Stock__c',
            'Product__c': '',
            'Available_Stock__c': 0,
            'Product_Name__c': '',
            'Account__c': accountId,
            'Visit__c': visitId
        });
        
        component.set("v.stockList", stockList);
    },
    
    validateStockList: function(component, event) {
        var isValid = true;
        var stockList = component.get("v.stockList");
        
        for(var i = 0; i < stockList.length; i++) {
            if(stockList[i].Product__c == '' || stockList[i].Product__c == null) {
                isValid = false;
                this.showToast('Product Name cannot be blank on row number ' + (i + 1), 'Warning');
                break;
            } else if(stockList[i].Available_Stock__c == '' || 
                     stockList[i].Available_Stock__c == null || 
                     stockList[i].Available_Stock__c < 0) {
                isValid = false;
                this.showToast('Please enter valid quantity on row number ' + (i + 1), 'Warning');
                break;
            }
        }
        
        return isValid;
    },
    
    saveStock: function(component, event, helper) {
        var stockList = component.get("v.stockList");
        
        var action = component.get("c.upsertStockEntry");
        action.setParams({
            'stockList': JSON.stringify(stockList)
        });
        
        action.setCallback(this, function(response) {
            component.set('v.spinner', false);
            
            if(response.getState() == "SUCCESS") {
                this.showToast('Stock entry saved successfully', 'Success');
                
                // Clear the form
                component.set("v.stockList", []);
                component.set("v.Products", []);
                component.set("v.matchproducts", []);
                
                // Fire event to close stock entry
                var appEvent = $A.get("e.c:StockEntryEvent");
                appEvent.setParams({
                    "action": "save"
                });
                appEvent.fire();
                
            } else if(response.getState() === "ERROR") {
                var errors = response.getError();
                if(errors && errors[0] && errors[0].message) {
                    this.showToast('Error: ' + errors[0].message, 'Error');
                }
            }
        });
        
        $A.enqueueAction(action);
    },
    
    showToast: function(message, type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type": type,
            "message": message
        });
        toastEvent.fire();
    }
})