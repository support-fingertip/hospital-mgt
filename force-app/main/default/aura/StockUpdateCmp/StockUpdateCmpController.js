({
    doInit: function(component, event, helper) {
        // Get products
        var action = component.get("c.getproductList");
        action.setCallback(this, function(response) {
            if(response.getState() == "SUCCESS") {
                component.set('v.Products', response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
        
        // Add first empty row
        helper.addStockRecord(component, event);
    },
    
    searchText: function(component, event, helper) {
        var products = component.get('v.Products');
        var searchText = component.get('v.searchText');
        var matchproducts = [];
        
        if(searchText != '') {
            for(var i = 0; i < products.length; i++) {
                if(products[i].Name.toLowerCase().indexOf(searchText.toLowerCase()) != -1) {
                    if(matchproducts.length < 50) {
                        matchproducts.push(products[i]);
                    } else {
                        break;
                    }
                }
            }
            if(matchproducts.length > 0) {
                component.set('v.matchproducts', matchproducts);
            }
        } else {
            component.set('v.matchproducts', []);
        }
    },
    
    selectProduct: function(component, event, helper) {
        var index = event.currentTarget.dataset.record;
        var pid = event.currentTarget.dataset.id;
        var prds = component.get('v.matchproducts');
        var stockList = component.get('v.stockList');
        
        for(var i = 0; i < prds.length; i++) {
            if(prds[i].Id === pid) {
                stockList[index].Product__c = prds[i].Id;
                stockList[index].Product_Name__c = prds[i].Name;
                component.set('v.searchText', '');
                break;
            }
        }
        
        component.set('v.stockList', stockList);
        component.set('v.matchproducts', []);
    },
    
    addRow: function(component, event, helper) {
        helper.addStockRecord(component, event);
    },
    
    removeRow: function(component, event, helper) {
        var stockList = component.get("v.stockList");
        var selectedItem = event.currentTarget;
        var index = selectedItem.dataset.record;
        
        stockList.splice(index, 1);
        component.set("v.stockList", stockList);
        
        if(stockList.length < 1) {
            helper.addStockRecord(component, event);
        }
    },
    
    save: function(component, event, helper) {
        if(helper.validateStockList(component, event)) {
            component.set('v.spinner', true);
            helper.saveStock(component, event, helper);
        }
    },
    
    cancel: function(component, event, helper) {
        // Fire event to close stock entry and show visits view
        var appEvent = $A.get("e.c:StockEntryEvent");
        appEvent.setParams({
            "action": "cancel"
        });
        appEvent.fire();
    }
})