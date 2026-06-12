({
    loadWarehouses: function(component) {
        const action = component.get("c.getWareHouse");
        
        action.setCallback(this, function(response) {
            const state = response.getState();
            if (state === "SUCCESS") {
                const warehouses = response.getReturnValue();
                component.set('v.warehouses', warehouses);
                
                if(warehouses.length === 1) {
                    component.set('v.selectedWarehouse', warehouses[0].Id);
                    component.set('v.searchtext', warehouses[0].Name);
                    this.loadDashboardStats(component);
                    this.loadStockData(component);
                }
            } else {
                this.handleError(response.getError());
            }
        });
        
        $A.enqueueAction(action);
    },
    
    loadProductCategories: function(component) {
        const action = component.get("c.getProductCategories");
        
        action.setCallback(this, function(response) {
            const state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.productCategoriesPicklist", response.getReturnValue());
            }
        });
        
        $A.enqueueAction(action);
    },
    
    setupColumns: function(component) {
        // Stock columns — no BIN Location
        component.set('v.mycolumns3', [
            {label: 'SKU Name', fieldName: 'skuUrl', type: 'url', 
             typeAttributes: { label: { fieldName: 'Sku_Name__c' }, target: '_blank'}},
            {label: 'HSN Code', fieldName: 'Hsn_Code__c', type: 'text'},
            {label: 'Product Category', fieldName: 'Product_category__c', type: 'text'},
            {label: 'Batch Series', fieldName: 'Batch_Series_No__c', type: 'text'},
            {label: 'Available Qty', fieldName: 'Available_Qty__c', type: 'number'},
            {label: 'In-Transit Qty', fieldName: 'In_Transit_qty__c', type: 'number'},
            {label: 'Damaged Qty', fieldName: 'Damaged_Qty__c', type: 'number'},
            {label: 'Total Price', fieldName: 'Total_Price__c', type: 'currency', 
             typeAttributes: { currencyCode: 'INR' }}
        ]);
        
        // Batch columns — no BIN Location
        component.set('v.batchColumns', [
            {label: 'Priority', fieldName: 'priority', type: 'text',
             cellAttributes: { iconName: { fieldName: 'priorityIcon' }, iconPosition: 'left' }},
            {label: 'Batch Number', fieldName: 'batchNumber', type: 'text'},
            {label: 'SKU Name', fieldName: 'skuName', type: 'text'},
            {label: 'Category', fieldName: 'productCategory', type: 'text'},
            {label: 'Expiry Date', fieldName: 'expiryDate', type: 'date'},
            {label: 'Days to Expiry', fieldName: 'daysToExpiry', type: 'number'},
            {label: 'Quantity', fieldName: 'quantity', type: 'number'}
        ]);
        
        // Expiry columns — same as batch
        component.set('v.expiryColumns', component.get('v.batchColumns'));
        
        // In-Transit columns
        component.set('v.inTransitColumns', [
            {label: 'SKU Name', fieldName: 'Sku_Name__c', type: 'text'},
            {label: 'HSN Code', fieldName: 'HSN_Code__c', type: 'text'},
            {label: 'Category', fieldName: 'Product_category__c', type: 'text'},
            {label: 'In-Transit Qty', fieldName: 'In_Transit_qty__c', type: 'number'},
            {label: 'Purchase Price', fieldName: 'Purchase_Price__c', type: 'currency',
             typeAttributes: { currencyCode: 'INR' }},
            {label: 'Expected Delivery', fieldName: 'Exp_Delv_Date__c', type: 'date'},
            {label: 'Status', fieldName: 'Status__c', type: 'text'}
        ]);
        
        // Low Stock columns
        component.set('v.lowStockColumns', [
            {label: 'SKU Name', fieldName: 'Sku_Name__c', type: 'text'},
            {label: 'HSN Code', fieldName: 'Hsn_Code__c', type: 'text'},
            {label: 'Category', fieldName: 'Product_category__c', type: 'text'},
            {label: 'Available Qty', fieldName: 'Available_Qty__c', type: 'number'},
            {label: 'In-Transit Qty', fieldName: 'In_Transit_qty__c', type: 'number'},
            {label: 'Total Price', fieldName: 'Total_Price__c', type: 'currency',
             typeAttributes: { currencyCode: 'INR' }}
        ]);
        
        // Stock History columns
        component.set('v.stockHistoryColumns', [
            {label: 'Date', fieldName: 'CreatedDate', type: 'date',
             typeAttributes: { year: 'numeric', month: 'short', day: '2-digit', hour: '2-digit', minute: '2-digit' }},
            {label: 'SKU Name', fieldName: 'skuName', type: 'text'},
            {label: 'Category', fieldName: 'productCategory', type: 'text'},
            {label: 'Transaction Type', fieldName: 'Stock_Type__c', type: 'text'},
            {label: 'Batch Number', fieldName: 'batchNumber', type: 'text'},
            {label: 'Quantity', fieldName: 'Quantity__c', type: 'number'},
            {label: 'Price', fieldName: 'Purchase_Price__c', type: 'currency',
             typeAttributes: { currencyCode: 'INR' }}
        ]);
    },
    
    loadDashboardStats: function(component) {
        const warehouseId = component.get("v.selectedWarehouse");
        if(!warehouseId) return;
        
        this.showSpinner(component, true);
        const action = component.get("c.getDashboardData");
        action.setParams({ warehouse: warehouseId });
        
        action.setCallback(this, function(response) {
            const state = response.getState();
            if (state === "SUCCESS") {
                const data = response.getReturnValue();
                
                const dashboardData = {
                    totalAvailable: this.formatNumber(data.totalAvailable),
                    totalInTransit: this.formatNumber(data.totalInTransit),
                    totalDamaged: this.formatNumber(data.totalDamaged),
                    totalValue: this.formatNumber(data.totalValue),
                    expiryCount: data.expiryCount,
                    lowStockCount: data.lowStockCount
                };
                
                component.set('v.dashboardData', dashboardData);
            } else {
                this.handleError(response.getError());
            }
            this.showSpinner(component, false);
        });
        
        $A.enqueueAction(action);
    },
    
    loadStockData: function(component) {
        const warehouseId = component.get("v.selectedWarehouse");
        const category = component.get("v.selectedDistrict");
        
        if (!warehouseId) {
            component.set('v.mydata3', []);
            return;
        }
        
        this.showSpinner(component, true);
        const action = component.get("c.getRecords");
        action.setParams({
            'productcategory': category || '',
            'warehouse': warehouseId
        });
        
        action.setCallback(this, function(response) {
            const state = response.getState();
            if (state === "SUCCESS") {
                let data = response.getReturnValue();
                
                // Add URL for navigation — no BIN Location mapping
                data = data.map(item => {
                    return Object.assign({}, item, {
                        skuUrl: '/' + item.Id
                    });
                });
                
                component.set('v.mydata3', data);
            } else {
                this.handleError(response.getError());
            }
            this.showSpinner(component, false);
        });
        
        $A.enqueueAction(action);
    },
    
    // ========== IN-TRANSIT ==========
    loadInTransitData: function(component) {
        const warehouseId = component.get("v.selectedWarehouse");
        const category = component.get("v.selectedDistrict");
        
        if (!warehouseId) {
            component.set('v.inTransitData', []);
            return;
        }
        
        this.showSpinner(component, true);
        const action = component.get("c.getIntransitItems");
        action.setParams({
            productcategory: category || '',
            warehouse: warehouseId
        });
        
        action.setCallback(this, function(response) {
            const state = response.getState();
            if (state === "SUCCESS") {
                component.set('v.inTransitData', response.getReturnValue());
            } else {
                this.handleError(response.getError());
            }
            this.showSpinner(component, false);
        });
        
        $A.enqueueAction(action);
    },
    
    // Calls existing updateData Apex — converts In_Transit_Item__c to Stock_Item__c
    markItemsDelivered: function(component, itemsToDeliver) {
        this.showSpinner(component, true);
        
        const action = component.get("c.updateData");
        action.setParams({ stockItems: itemsToDeliver });
        
        action.setCallback(this, function(response) {
            const state = response.getState();
            if (state === "SUCCESS") {
                this.showSpinner(component, false);
                this.showToast('Success', itemsToDeliver.length + ' item(s) marked as delivered successfully', 'success');
                
                // Reset selection and reload
                component.set('v.selectedInTransitItems', []);
                this.loadInTransitData(component);
                this.loadDashboardStats(component);
                this.loadStockData(component);
            } else {
                this.showSpinner(component, false);
                this.handleError(response.getError());
            }
        });
        
        $A.enqueueAction(action);
    },
    
    // Saves bulk products as In_Transit_Item__c
    saveBulkInTransitItems: function(component, productIds, quantities, prices, warehouseId, batchNumber, expiryDate) {
        this.showSpinner(component, true);
        
        const action = component.get("c.saveBulkInTransitItems");
        action.setParams({
            productIds: productIds,
            warehouseId: warehouseId,
            quantities: quantities,
            prices: prices,
            batchNumber: batchNumber,
            expectedDeliveryDate: expiryDate
        });
        
        action.setCallback(this, function(response) {
            const state = response.getState();
            if (state === "SUCCESS") {
                this.showSpinner(component, false);
                this.showToast('Success', response.getReturnValue(), 'success');
                
                // Reset modal
                component.set("v.showBulkEntry", false);
                component.set("v.bulkProducts", []);
                component.set("v.commonBatchNumber", "");
                component.set("v.commonExpiryDate", null);
                component.set("v.selectedCount", 0);
                component.set("v.totalQuantity", 0);
                
                // Refresh
                this.loadDashboardStats(component);
                this.loadInTransitData(component);
            } else {
                this.showSpinner(component, false);
                this.handleError(response.getError());
            }
        });
        
        $A.enqueueAction(action);
    },
    
    // ========== LOW STOCK ==========
    loadLowStockData: function(component) {
        const warehouseId = component.get("v.selectedWarehouse");
        if (!warehouseId) return;
        
        this.showSpinner(component, true);
        const action = component.get("c.getLowStockProducts");
        action.setParams({ warehouse: warehouseId });
        
        action.setCallback(this, function(response) {
            const state = response.getState();
            if (state === "SUCCESS") {
                component.set('v.lowStockData', response.getReturnValue());
            } else {
                this.handleError(response.getError());
            }
            this.showSpinner(component, false);
        });
        
        $A.enqueueAction(action);
    },
    
    // ========== STOCK HISTORY ==========
    loadStockHistory: function(component) {
        const warehouseId = component.get("v.selectedWarehouse");
        const category = component.get("v.selectedDistrict");
        const historyType = component.get("v.selectedHistoryType");
        
        if (!warehouseId) {
            component.set('v.stockHistoryData', []);
            return;
        }
        
        this.showSpinner(component, true);
        const action = component.get("c.getStockHistory");
        action.setParams({
            warehouse: warehouseId,
            productcategory: category || '',
            stockType: historyType || ''
        });
        
        action.setCallback(this, function(response) {
            const state = response.getState();
            if (state === "SUCCESS") {
                component.set('v.stockHistoryData', response.getReturnValue());
            } else {
                this.handleError(response.getError());
            }
            this.showSpinner(component, false);
        });
        
        $A.enqueueAction(action);
    },
    
    // ========== BATCH ==========
    loadBatchData: function(component) {
        const warehouseId = component.get("v.selectedWarehouse");
        
        if (!warehouseId) {
            component.set('v.batchData', []);
            return;
        }
        
        this.showSpinner(component, true);
        const action = component.get("c.getBatchData");
        action.setParams({ 
            warehouse: warehouseId,
            daysThreshold: null
        });
        
        action.setCallback(this, function(response) {
            const state = response.getState();
            if (state === "SUCCESS") {
                let data = response.getReturnValue();
                
                data = data.map(item => {
                    let icon;
                    if(item.priority === 'Critical') {
                        icon = 'utility:error';
                    } else if(item.priority === 'High') {
                        icon = 'utility:warning';
                    } else {
                        icon = 'utility:info';
                    }
                    return Object.assign({}, item, { priorityIcon: icon });
                });
                
                component.set('v.batchData', data);
            } else {
                this.handleError(response.getError());
            }
            this.showSpinner(component, false);
        });
        
        $A.enqueueAction(action);
    },
    
    // ========== EXPIRY ==========
    loadExpiryAlerts: function(component) {
        const warehouseId = component.get("v.selectedWarehouse");
        const alertDays = component.get("v.alertDays") || 90;
        
        if (!warehouseId) {
            component.set('v.expiryAlerts', []);
            return;
        }
        
        this.showSpinner(component, true);
        const action = component.get("c.getBatchData");
        action.setParams({ 
            warehouse: warehouseId,
            daysThreshold: alertDays
        });
        
        action.setCallback(this, function(response) {
            const state = response.getState();
            if (state === "SUCCESS") {
                let data = response.getReturnValue();
                
                data = data.map(item => {
                    let icon;
                    if(item.priority === 'Critical') {
                        icon = 'utility:error';
                    } else if(item.priority === 'High') {
                        icon = 'utility:warning';
                    } else {
                        icon = 'utility:info';
                    }
                    return Object.assign({}, item, { priorityIcon: icon });
                });
                
                component.set('v.expiryAlerts', data);
            } else {
                this.handleError(response.getError());
            }
            this.showSpinner(component, false);
        });
        
        $A.enqueueAction(action);
    },
    
    // ========== BULK ENTRY ==========
    updateSummary: function(component) {
        const products = component.get("v.bulkProducts");
        
        let selectedCount = 0;
        let totalQuantity = 0;
        
        products.forEach(function(prod) {
            if(prod.selected) {
                selectedCount++;
                if(prod.quantity && prod.quantity > 0) {
                    totalQuantity += parseFloat(prod.quantity);
                }
            }
        });
        
        component.set("v.selectedCount", selectedCount);
        component.set("v.totalQuantity", totalQuantity);
    },
    
    loadBulkProducts: function(component) {
        const warehouseId = component.get("v.selectedWarehouse");
        const category = component.get("v.selectedDistrict");
        
        this.showSpinner(component, true);
        
        const productAction = component.get("c.getproductRecords");
        productAction.setParams({ 
            productcategory: category || ''
        });
        
        productAction.setCallback(this, function(response) {
            const state = response.getState();
            if (state === "SUCCESS") {
                let products = response.getReturnValue();
                
                const stockAction = component.get("c.getRecords");
                stockAction.setParams({ 
                    productcategory: category || '',
                    warehouse: warehouseId
                });
                
                stockAction.setCallback(this, function(stockResponse) {
                    const stockState = stockResponse.getState();
                    let stockMap = {};
                    
                    if (stockState === "SUCCESS") {
                        let stocks = stockResponse.getReturnValue();
                        stocks.forEach(stock => {
                            stockMap[stock.Product__c] = stock.Available_Qty__c || 0;
                        });
                    }
                    
                    let bulkProducts = products.map(function(prod) {
                        return {
                            productId: prod.Id,
                            skuName: prod.Sku_Name__c || prod.Name,
                            hsnCode: prod.HSN_Code__c || '',
                            productCategory: prod.Product_Category_Name__c || '',
                            currentStock: stockMap[prod.Id] || 0,
                            selected: false,
                            quantity: 0,
                            price: 0
                        };
                    });
                    
                    component.set('v.bulkProducts', bulkProducts);
                    component.set('v.showBulkEntry', true);
                    this.showSpinner(component, false);
                });
                
                $A.enqueueAction(stockAction);
                
            } else {
                this.handleError(response.getError());
                this.showSpinner(component, false);
            }
        });
        
        $A.enqueueAction(productAction);
    },
    
    // Single Apex call — saves all selected products as Stock_Item__c
    saveBulkStockTransactions: function(component, productIds, quantities, prices, warehouseId, transactionType, batchNumber, expiryDate) {
        this.showSpinner(component, true);
        
        const action = component.get("c.saveBulkStockTransactions");
        action.setParams({
            productIds: productIds,
            warehouseId: warehouseId,
            transactionType: transactionType,
            quantities: quantities,
            prices: prices,
            batchNumber: batchNumber,
            expiryDate: expiryDate
        });
        
        action.setCallback(this, function(response) {
            const state = response.getState();
            if (state === "SUCCESS") {
                this.showSpinner(component, false);
                this.showToast('Success', response.getReturnValue(), 'success');
                
                component.set("v.showBulkEntry", false);
                component.set("v.bulkProducts", []);
                component.set("v.commonBatchNumber", "");
                component.set("v.commonExpiryDate", null);
                component.set("v.selectedCount", 0);
                component.set("v.totalQuantity", 0);
                
                this.loadDashboardStats(component);
                this.loadStockData(component);
            } else {
                this.showSpinner(component, false);
                this.handleError(response.getError());
            }
        });
        
        $A.enqueueAction(action);
    },
    
    // ========== UTILITIES ==========
    formatNumber: function(num) {
        if (!num) return '0';
        return num.toLocaleString('en-IN');
    },
    
    showSpinner: function(component, show) {
        component.set("v.spinner", show);
    },
    
    showToast: function(title, message, type) {
        const toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message": message,
            "type": type,
            "mode": "dismissible",
            "duration": 5000
        });
        toastEvent.fire();
    },
    
    handleError: function(errors) {
        let message = 'Unknown error';
        if (errors && Array.isArray(errors) && errors.length > 0) {
            message = errors[0].message;
        } else if (errors && errors.body && errors.body.message) {
            message = errors.body.message;
        }
        this.showToast('Error', message, 'error');
        console.error('Error:', errors);
    }
})