({
    doInit: function(component, event, helper) {
        helper.loadWarehouses(component);
        helper.loadProductCategories(component);
        helper.setupColumns(component);
        
        component.set('v.dashboardData', {
            totalAvailable: '0',
            totalInTransit: '0',
            totalDamaged: '0',
            totalValue: '0',
            expiryCount: 0,
            lowStockCount: 0
        });
    },
    
    handleTabChange: function(component, event, helper) {
        const tabId = event.getSource().get("v.id");
        component.set("v.currentTab", tabId);
        
        const warehouse = component.get("v.selectedWarehouse");
        
        if(!warehouse && tabId !== 'dashboard') {
            helper.showToast('Info', 'Please select a warehouse from the dashboard first', 'info');
            component.set("v.currentTab", 'dashboard');
            return;
        }
        
        switch(tabId) {
            case 'dashboard':
                if (warehouse) {
                    helper.loadDashboardStats(component);
                }
                break;
            case 'stock':
                helper.loadStockData(component);
                break;
            case 'intransit':
                helper.loadInTransitData(component);
                break;
            case 'batch':
                helper.loadBatchData(component);
                break;
            case 'expiry':
                helper.loadExpiryAlerts(component);
                break;
            case 'history':
                helper.loadStockHistory(component);
                break;
        }
    },
    
    searchWarehouse: function(component, event, helper) {
        const searchText = component.get('v.searchtext');
        const warehouses = component.get('v.warehouses');
        
        if (!warehouses || warehouses.length === 0) {
            helper.loadWarehouses(component);
            return;
        }
        
        if (searchText && searchText.length > 0) {
            const matches = warehouses.filter(wh => 
                wh.Name.toLowerCase().includes(searchText.toLowerCase()) ||
                (wh.Warehouse_Id__c && wh.Warehouse_Id__c.toLowerCase().includes(searchText.toLowerCase()))
            );
            component.set('v.matchWarehouses', matches);
        } else {
            component.set('v.matchWarehouses', warehouses);
        }
    },
    
    selectWarehouse: function(component, event, helper) {
        event.stopPropagation();
        
        const warehouseId = event.currentTarget.dataset.id;
        const warehouses = component.get('v.warehouses');
        const selected = warehouses.find(wh => wh.Id === warehouseId);
        
        if (selected) {
            component.set('v.searchtext', selected.Name);
            component.set('v.selectedWarehouse', warehouseId);
            component.set('v.matchWarehouses', []);
            
            helper.loadDashboardStats(component);
            helper.loadStockData(component);
            
            helper.showToast('Success', 'Warehouse "' + selected.Name + '" selected', 'success');
        }
    },
    
    filterStock: function(component, event, helper) {
        helper.loadStockData(component);
    },
    
    filterInTransit: function(component, event, helper) {
        helper.loadInTransitData(component);
    },
    
    filterHistory: function(component, event, helper) {
        helper.loadStockHistory(component);
    },
    
    searchBatch: function(component, event, helper) {
        const searchTerm = event.getSource().get("v.value");
        if(!searchTerm || searchTerm.length < 2) {
            helper.loadBatchData(component);
        } else {
            const batchData = component.get('v.batchData');
            const filtered = batchData.filter(item =>
                (item.batchNumber && item.batchNumber.toLowerCase().includes(searchTerm.toLowerCase())) ||
                (item.skuName && item.skuName.toLowerCase().includes(searchTerm.toLowerCase()))
            );
            component.set('v.batchData', filtered);
        }
    },
    
    loadExpiryAlerts: function(component, event, helper) {
        helper.loadExpiryAlerts(component);
    },
    
    goToExpiryTab: function(component, event, helper) {
        component.set('v.currentTab', 'expiry');
        helper.loadExpiryAlerts(component);
    },
    
    goToStockTab: function(component, event, helper) {
        component.set('v.currentTab', 'stock');
        helper.loadStockData(component);
    },
    
    // ========== LOW STOCK MODAL ==========
    openLowStockModal: function(component, event, helper) {
        helper.loadLowStockData(component);
        component.set('v.showLowStockModal', true);
    },
    
    closeLowStockModal: function(component, event, helper) {
        component.set('v.showLowStockModal', false);
    },
    
    // ========== IN-TRANSIT ROW SELECTION ==========
    handleInTransitRowSelection: function(component, event, helper) {
        const selectedRows = event.getParam('selectedRows');
        component.set('v.selectedInTransitItems', selectedRows);
    },
    
    // ========== MARK DELIVERED ==========
    markDelivered: function(component, event, helper) {
        const selectedRows = component.get('v.selectedInTransitItems');
        
        if(!selectedRows || selectedRows.length === 0) {
            helper.showToast('Warning', 'Please select at least one item to mark as delivered', 'warning');
            return;
        }
        
        // Build list matching what updateData expects
        let itemsToDeliver = selectedRows.map(function(row) {
            return {
                Id: row.Id,
                Stock__c: row.Stock__c,
                Product__c: row.Product__c,
                Delivered_Quantity__c: row.In_Transit_qty__c,
                Purchase_Price__c: row.Purchase_Price__c,
                Status__c: 'Delivered'
            };
        });
        
        helper.markItemsDelivered(component, itemsToDeliver);
    },
    
    // ========== BULK ENTRY MODAL ==========
    openTransactionModal: function(component, event, helper) {
        const menuItem = event.getParam('value') || event.getSource().get('v.value');
        const warehouse = component.get("v.selectedWarehouse");
        
        if(!warehouse) {
            helper.showToast('Warning', 'Please select a warehouse first', 'warning');
            return;
        }
        
        let title = "";
        let expiryLabel = "Expiry Date";
        
        if(menuItem === 'inward_mfg') {
            title = "Manufacturing Stock - Bulk Entry";
        } else if(menuItem === 'inward_transit') {
            title = "Stock In-Transit - Bulk Entry";
            expiryLabel = "Expected Delivery Date";
        } else if(menuItem === 'inward_return') {
            title = "Distributor Returns - Bulk Entry";
        } else if(menuItem === 'outward_sales') {
            title = "Sales to Distributors - Bulk Entry";
        } else if(menuItem === 'outward_damaged') {
            title = "Damaged Stock - Bulk Entry";
        } else if(menuItem === 'outward_sample') {
            title = "Free Samples - Bulk Entry";
        }
        
        component.set("v.modalTitle", title);
        component.set("v.expiryDateLabel", expiryLabel);
        component.set("v.transactionType", menuItem);
        
        // Auto-generate batch number
        const today = new Date();
        const dateStr = today.toISOString().split('T')[0].replace(/-/g, '');
        component.set("v.commonBatchNumber", 'BATCH-' + dateStr);
        component.set("v.commonExpiryDate", null);
        
        component.set("v.selectedCount", 0);
        component.set("v.totalQuantity", 0);
        
        helper.loadBulkProducts(component);
    },
    
    closeBulkEntry: function(component, event, helper) {
        component.set("v.showBulkEntry", false);
        component.set("v.bulkProducts", []);
        component.set("v.commonBatchNumber", "");
        component.set("v.commonExpiryDate", null);
        component.set("v.selectedCount", 0);
        component.set("v.totalQuantity", 0);
    },
    
    handleSelectAll: function(component, event, helper) {
        const isChecked = event.getSource().get("v.checked");
        let products = component.get("v.bulkProducts");
        
        products.forEach(function(prod) {
            prod.selected = isChecked;
        });
        
        component.set("v.bulkProducts", products);
        helper.updateSummary(component);
    },
    
    handleRowSelection: function(component, event, helper) {
        const index = parseInt(event.getSource().get("v.name"));
        const isChecked = event.getSource().get("v.checked");
        
        let products = component.get("v.bulkProducts");
        products[index].selected = isChecked;
        
        component.set("v.bulkProducts", products);
        helper.updateSummary(component);
    },
    
    handleQuantityChange: function(component, event, helper) {
        const index = parseInt(event.getSource().get("v.name"));
        const value = event.getSource().get("v.value");
        
        let products = component.get("v.bulkProducts");
        products[index].quantity = value;
        component.set("v.bulkProducts", products);
        
        helper.updateSummary(component);
    },
    
    handlePriceChange: function(component, event, helper) {
        const index = parseInt(event.getSource().get("v.name"));
        const value = event.getSource().get("v.value");
        
        let products = component.get("v.bulkProducts");
        products[index].price = value;
        component.set("v.bulkProducts", products);
    },
    
    saveBulkStock: function(component, event, helper) {
        const products = component.get("v.bulkProducts");
        const warehouse = component.get("v.selectedWarehouse");
        const transactionType = component.get("v.transactionType");
        const batchNumber = component.get("v.commonBatchNumber");
        const expiryDate = component.get("v.commonExpiryDate");
        
        if(!warehouse) {
            helper.showToast('Error', 'Please select a warehouse first', 'error');
            return;
        }
        if(!batchNumber || batchNumber.trim() === '') {
            helper.showToast('Error', 'Please enter Batch Number', 'error');
            return;
        }
        if(!expiryDate) {
            const label = transactionType === 'inward_transit' ? 'Expected Delivery Date' : 'Expiry Date';
            helper.showToast('Error', 'Please enter ' + label, 'error');
            return;
        }
        
        const selectedProducts = products.filter(p => p.selected);
        if(selectedProducts.length === 0) {
            helper.showToast('Warning', 'Please select at least one product', 'warning');
            return;
        }
        
        const isOutward = transactionType && transactionType.startsWith('outward');
        const isInTransit = transactionType === 'inward_transit';
        
        for(let i = 0; i < selectedProducts.length; i++) {
            const prod = selectedProducts[i];
            
            if(!prod.productId) {
                helper.showToast('Error', 'Product ID missing for ' + prod.skuName, 'error');
                return;
            }
            if(!prod.quantity || prod.quantity <= 0) {
                helper.showToast('Error', 'Quantity must be > 0 for: ' + prod.skuName, 'error');
                return;
            }
            // Price required for inward_mfg and inward_return only
            if(!isOutward && !isInTransit && (!prod.price || prod.price <= 0)) {
                helper.showToast('Error', 'Unit Price must be > 0 for: ' + prod.skuName, 'error');
                return;
            }
        }
        
        let productIds = [];
        let quantities = [];
        let prices = [];
        
        selectedProducts.forEach(function(prod) {
            productIds.push(prod.productId);
            quantities.push(prod.quantity);
            prices.push(prod.price || 0);
        });
        
        // In-Transit goes to separate Apex method
        if(transactionType === 'inward_transit') {
            helper.saveBulkInTransitItems(component, productIds, quantities, prices, warehouse, batchNumber, expiryDate);
        } else {
            helper.saveBulkStockTransactions(component, productIds, quantities, prices, warehouse, transactionType, batchNumber, expiryDate);
        }
    }
})