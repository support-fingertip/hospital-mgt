({
    storedTableData: {},
    setColumn : function(component, event,helper) {
         
         var type = component.get("v.selectedType");
         type = 'View Stock';
         component.set("v.selectedType",type);
         if(type == 'View Stock'){
             component.set('v.mycolumns3', [
                 {label: 'SKU Name', fieldName: 'skuUrl', type: 'url', typeAttributes: { label: { fieldName: 'Sku_Name__c' }, target: '_blank'}},
                 {label: 'HSN Code', fieldName: 'Hsn_Code__c', type: 'text'},
                 {label: 'BIN Location', fieldName: 'Bin_Location__c', type: 'text'},
                 {label: 'Product category', fieldName: 'Product_category__c', type: 'text'},
                 {label: 'UOM', fieldName: 'Uom__c', type: 'text'},
                 {label: 'Available Qty', fieldName: 'Available_Qty__c', type: 'number'},
                 {label: 'Damaged Qty', fieldName: 'Damaged_Qty__c', type: 'number'},
                 {label: 'In-Transit Qty', fieldName: 'In_Transit_qty__c', type: 'number'},
                 {label: 'Total Price', fieldName: 'Total_Price__c', type: 'number'},
                 
             
                 {
                type: 'button',
                initialWidth: 75,
                typeAttributes: {
                    label: '',
                    name: 'add_button',
                    iconName: 'utility:add',
                    variant: 'success'
                }
            },
            {
                type: 'button',
                initialWidth: 90,
                typeAttributes: {
                    label: '',
                    name: 'delete_button',
                    iconName: 'utility:dash',
                    variant: 'destructive'
                }
            }
             ]); 
         }
         
         /*  
            {label: 'Created Date', fieldName: 'CreatedDate', type: 'date',typeAttributes: {
                day: 'numeric',
                month: 'short',
                year: 'numeric',
                hour: '2-digit',
                minute: '2-digit',
                second: '2-digit',
                hour12: true
            }},
            
            
             * component.set('v.mycolumns4', [
            {label: 'VisitId', fieldName: 'Name', type: 'text'},
            {label: 'Store Name', fieldName: 'Account_Name__c', type: 'text'},
            {label: 'Status', fieldName: 'Status__c', type: 'text'}
           
        ]);*/
    },
    getData : function(component, event,helper) {
        //var prodcat = component.get('v.selectedProdCatg');
        var prodcat = component.get('v.selectedDistrict');
        var warehouse = component.get('v.selectedWareHouse');
        
        component.set('v.spinner',true);
        var action = component.get("c.getRecords");
        action.setParams({
            'productcategory': prodcat,
            'warehouse': warehouse,
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                let processedData = result.map(record => {
                    return Object.assign({}, record, { 
                        skuUrl: '/' + record.Id,
                        buttonLabel: '',
                        buttonName :'add',
                        deleteIcon : 'utility:add',
                        buttonVariant: 'success',
                        buttonLabel1: '',
                        buttonName1 :'delete',
                        deleteIcon1 : 'utility:dash',
                        buttonVariant1: 'brand'
                    });
            });
            component.set('v.mydata3', processedData);
            component.set('v.showUsers',true);
        }
        component.set('v.spinner',false);
    });
    $A.enqueueAction(action);
    
    
},  
    setVariable : function(component, event, helper){
        var trip = {
            'Sku_Name__c': '',
            'Hsn_Code__c': '',
            'Available_Quantity__c': 0,
            'Unit_Price__c': 0,
        };
        
        /* component.set("v.selectedItem", trip);
        var stockData = {
            'sObjectName' : 'Stock_Item__c',
            'Stock__c': '',
            'Quantity__c': 0,
            'Stock_Type__c': '',
            'Selling_Price__c': 0,
        };
        

        component.set("v.stockData", stockData);*/
        
    },
    warehouseDetails : function(component, event,helper) {
        var action = component.get("c.getWareHouse");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                component.set('v.warehouses', result);
                
            }
        });
        $A.enqueueAction(action);
    },
    productCategoryDetails : function(component, event,helper) {
        var action = component.get("c.getProductCategories");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                component.set('v.productCategories', result);
                
            }
        });
        $A.enqueueAction(action);
    },
    saveChanges: function(component, draftValues) {
        // Call the Apex method to save the data
        var action = component.get("c.saveData"); 
        
        action.setParams({
            updatedRecords: draftValues
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                // Refresh the data after successful save
                component.set("v.mydata3", response.getReturnValue());
                component.set("v.draftValues", []);
            } else {
                // Handle error
                console.error(response.getError());
            }
        });
        
        $A.enqueueAction(action);
    },
    showMessage: function(message, type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type": type,
            "message": message
        });
        toastEvent.fire();
    },
    validateData : function(component, event,helper) {
        //var prodcat = component.get('v.selectedProdCatg');
        var prodcat = component.get('v.selectedDistrict');
        var warehouse = component.get('v.selectedWareHouse');
        if(warehouse == '' || warehouse == undefined){
            helper.showMessage('Select Warehouse', 'error');
            component.set("v.isShowButton",true);
            return;
        }else{
            helper.getData(component, event, helper);
        }
    },
    getProducts : function(component, event,helper) {
        // var prodcat = component.get('v.selectedProdCatg');
        var prodcat = component.get('v.selectedDistrict');
        var warehouse = component.get('v.selectedWareHouse');
        if(warehouse == '' || warehouse == undefined){
            helper.showMessage('Select Warehouse', 'error');
            component.set("v.isShowButton",true);
            return;
        }else{
            component.set('v.spinner',true);
            var stockName = component.get("v.stockname");
            var action = component.get("c.getproductRecords");
            action.setParams({
                'productcategory': prodcat,
                
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var result = response.getReturnValue();
                    component.set("v.tableData",result);
                    result.forEach(row => {
                        this.storedTableData[row.Id] = row; 
                    });
                        component.set('v.showUsers',true);
                    }
                component.set('v.spinner',false);
            });
            $A.enqueueAction(action);
        }
    },
    getOutwardData : function(component, event,helper) {
        //var prodcat = component.get('v.selectedProdCatg');
        var prodcat = component.get('v.selectedDistrict');
        var warehouse = component.get('v.selectedWareHouse');
        if(warehouse == '' || warehouse == undefined){
            helper.showMessage('Select Warehouse', 'error');
            return;
        }else{
            component.set('v.spinner',true);
            var stockName = component.get("v.stockname");
            var action = component.get("c.getRecords");
            action.setParams({
                'productcategory': prodcat,
                'warehouse': warehouse,
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var result = response.getReturnValue();
                    result.forEach(row => {
                        this.storedTableData[row.Id] = row; 
                    });
                    component.set("v.tableData",result);
                    component.set('v.showUsers',true);
                }
                component.set('v.spinner',false);
            });
            $A.enqueueAction(action);
        }
    },
    showPreview: function(component, event, helper) {
        let tableData = component.get("v.tableData");
        var status = component.get("v.inTransitStatus");
        var namestock = component.get('v.stockname');
        if(namestock == 'In-Transit Stocks' && status == "In-Transit"){
            component.set("v.previewTableData",component.get("v.tableData"));
            let filteredData = tableData.filter(row => row.In_Transit_qty__c > 0);
            component.set("v.tableData", filteredData);
        }else{
            component.set("v.previewTableData",component.get("v.tableData"));
            let filteredData = tableData.filter(row => row.Quantity__c > 0);
            component.set("v.tableData", filteredData);
            let columns3 = component.get('v.mycolumns3');  
        }
        
        component.set('v.showPreview',true);
        component.set('v.showFilter',false);
    },
    goBack: function(component, event, helper) {
        if(component.get('v.showPreview')){
            component.set("v.tableData",component.get("v.previewTableData"));
            component.set('v.showPreview',false);
            component.set('v.showFilter',true);  
        }else{
            component.set("v.stockname",'Stocks');
            component.set('v.tableData',[]);
            component.set('v.previewTableData',[]);
            component.set("v.inTransitStatus","");
            component.set("v.isShowButton",true);
            component.set("v.isShowType",false);
            component.set("v.entryType","")
            this.storedTableData = {};
        }
        
    },
    filterTableData: function(component, event, helper) {
        
        component.set('v.spinner',true);
        var sname = component.get("v.stockname");
        const selectedCategory = component.get("v.selectedDistrict");
        const allData = Object.values(this.storedTableData);

        let filteredData;
        if (selectedCategory === '') {
            filteredData = allData;
        } else {
            if(sname == 'Inward Stocks'){
                filteredData = allData.filter(row => row.Product_Category_Name__c === selectedCategory);
            }else if(sname == 'Outward Stocks'){
                filteredData = allData.filter(row => row.Product_category__c === selectedCategory);
            }
            
        }

        component.set("v.tableData", filteredData);
        component.set('v.spinner',false);
    },
    deleteRow: function(component,event,helper, row) {
        component.set("v.isHidden",false);
        component.set("v.selectedType",'Outward Stocks');
        component.set("v.stockname",'Stocks');
        
        
    },
    addRow: function(component,event,helper, row) {
        component.set("v.isHidden",false);
        component.set("v.selectedType",'Inward Stocks');
        component.set("v.stockname",'Stocks');
        
    },
    createStock: function(component, event, helper) {
        var warehouseId = component.get('v.selectedWareHouse');
        var stocks = component.get("v.stockData");    
        var data = component.get("v.previewTableData");
        let tableData = component.get("v.tableData");
        let stockData = [];
        tableData.forEach(function(item) {
            
            if (item.Quantity__c > 0) {
                let record = {
                    'Product__c': item.Id,
                    'Sku_Name__c': item.Sku_Name__c,
                    'Sold_Quantity__c': Number(item.Quantity__c),
                    'Warehouse__c': warehouseId,
                    'Uom__c': 'No',
                    'Price__c': Number(item.Selling_Price__c),
                    'Purchased_Price_qty__c': Number(item.Purchased_Price_qty__c),
                    'Expire_date__c': item.Expiry_Date__c,
                };
                stockData.push(record);
            }
        });
        
        component.set("v.stockData", stockData);
        
        var action = component.get("c.saveStock");
        action.setParams({
            'stocks': stockData,
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var tripId = response.getReturnValue();
                helper.showMessage('Stock added', 'success');
                this.doCancel(component, event,helper);
                
            }
        });
        $A.enqueueAction(action);
        
    },
    createOutwardStock: function(component, event, helper) {
        var warehouseId = component.get('v.selectedWareHouse');
        var stocks = component.get("v.stockData");    
        var data = component.get("v.previewTableData");
        let tableData = component.get("v.tableData");
        let stockData = [];
        
        tableData.forEach(function(item) {
            if (item.Quantity__c > 0) {
                let record = {
                    'sObjectName' : 'Stock_Item__c',
                    'Stock__c': item.Id,
                    'Product__c': item.Product__c,
                    'Quantity__c': Number(item.Quantity__c),
                    'Stock_Type__c': 'Outward',
                    'Selling_Price__c': Number(item.Selling_Price__c),
                };
                stockData.push(record);
            }
        });
        
        component.set("v.stockData", stockData);
        
        var action = component.get("c.saveOutwardStockItem");
        action.setParams({
            'stockItems': component.get("v.stockData"),
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var tripId = response.getReturnValue();
                helper.showMessage('Stock added', 'success');
                this.doCancel(component, event,helper);
                
            }
        });
        $A.enqueueAction(action);
        
},
    createInTransitStock: function(component, event, helper) {
        var warehouseId = component.get('v.selectedWareHouse');
        var stocks = component.get("v.stockData");    
        var data = component.get("v.previewTableData");
        let tableData = component.get("v.tableData");
        let stockData = [];
        tableData.forEach(function(item) {
            
            if (item.In_Transit_qty__c > 0) {
                let record = {
                    'Product__c': item.Id,
                    'Sku_Name__c': item.Sku_Name__c,
                    'Sold_Quantity__c': Number(item.In_Transit_qty__c),
                    'Warehouse__c': warehouseId,
                    'Uom__c': 'No',
                    'Price__c': Number(item.Selling_Price__c),
                    'Purchased_Price_qty__c': Number(item.Purchase_Price__c),
                    'Expire_date__c': item.Exp_Delv_Date__c,
                };
                stockData.push(record);
            }
        });
        
        component.set("v.stockData", stockData);
        
        var action = component.get("c.saveInTransitStock");
        action.setParams({
            'stocks': stockData,
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var tripId = response.getReturnValue();
                helper.showMessage('Stock added', 'success');
                this.doCancel(component, event,helper);
                
            }
        });
        $A.enqueueAction(action);
    },
    fetchIntransitItem: function(component, event, helper) {
        var prodcat = component.get('v.selectedDistrict');
        var warehouse = component.get('v.selectedWareHouse');
        if(warehouse == '' || warehouse == undefined){
            helper.showMessage('Select Warehouse', 'error');
            return;
        }else{
            component.set('v.spinner',true);
            var stockName = component.get("v.stockname");
            var action = component.get("c.getIntransitItems");
            action.setParams({
                'productcategory': prodcat,
                'warehouse': warehouse,
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var result = response.getReturnValue();
                    component.set("v.tableData",result);
                    component.set('v.showUsers',true);
                }
                component.set('v.spinner',false);
            });
            $A.enqueueAction(action);
        }
    },
    updateInTransitStock: function(component, event, helper) {
        var warehouseId = component.get('v.selectedWareHouse');
        var stocks = component.get("v.stockData");    
        var data = component.get("v.previewTableData");
        let tableData = component.get("v.tableData");
        let stockData = [];
        tableData.forEach(function(item , index) {
            if (item.Delivered_Quantity__c > 0) {
                if (Number(item.Delivered_Quantity__c) !== Number(item.In_Transit_qty__c)) {
                    helper.showMessage("Row " + (index + 1) + ": Delivered Quantity should be the same as In-Transit Quantity.", "error");
                }else {
                    let record = {
                        'sObjectName' : 'In_Transit_Item__c',
                    'Id': item.Id,
                    'Stock__c': item.Stock__c,
                    'Product__c': item.Product__c,
                    'Delivered_Quantity__c': Number(item.Delivered_Quantity__c),
                    'Status__c': 'Delivered',
                    'Purchase_Price__c': item.Purchase_Price__c,
                };
                stockData.push(record);
            }
        }
        });
        if(stockData.length > 0){
            component.set("v.stockData", stockData);
        var action = component.get("c.updateData");
        action.setParams({
            'stockItems': component.get("v.stockData"),
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var tripId = response.getReturnValue();
                helper.showMessage('Stock added', 'success');
                this.doCancel(component, event,helper);
            }
        });
        $A.enqueueAction(action);
        }
        
        
    },
    addStockItem: function(component, event, helper) {
        /* var data = component.get("v.selectedRecord");
                var data1 = component.get("v.selectedItem");
                var processedData = data.map(function(item) {
                    return {
                        'sObjectName': 'Stock_Item__c',
                        'Name': item.Name,
                        'Product__c': item.Product__c,
                        'HSN_Code__c': item.HSN_Code__c,
                        'Quantity__c': data1.Quantity__c,
                        'Selling_Price__c': data1.Selling_Price__c,
                        'Stock__c': item.Id,
                        'Stock_Type__c': 'Inward',
                        
                    };
                });
                component.set("v.selectedRecord", processedData);*/
        var action = component.get("c.saveStockItem");
        action.setParams({
            'stockItems': component.get("v.selectedItem"),
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var tripId = response.getReturnValue();
                helper.showMessage('Stock added', 'success');
                component.set("v.isHidden",true);
                component.set("v.selectedItem",'');
                helper.getData(component, event, helper);
            }
        });
        $A.enqueueAction(action);
        
        
        
        
},
    fetchPicklist : function(component, event,helper) {
        var action = component.get("c.getProductCategories");
        /*action.setParams({
            'objectName': 'Product__c',
            'fieldName': 'Product_category__c',
        });*/
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                component.set("v.productCategoriesPicklist",result);
            }
            
        });
        $A.enqueueAction(action);
        
        
},
    doCancel : function(component, event,helper){
        component.set("v.isShowButton",true);
        component.set('v.showFilter',true);
        component.set('v.showSelection',true);
        component.set('v.showUsers',false);
        component.set('v.showPreview',false);
        component.set('v.mydata3',[]);
        component.set('v.mycolumns3',[]);
        component.set('v.selectedRecord','');
        component.set('v.selectedRowsCount4',0);
        component.set("v.searchtext",'');
        component.set("v.searchProductCatgText",'');
        component.set("v.selectedType",'');
        component.set("v.stockname",'Stocks');
        component.set('v.stockData',[]);
        component.set('v.tableData',[]);
        component.set('v.previewTableData',[]);
        component.set('v.selectedDistrict','');
        component.set('v.selectedWareHouse','');
        component.set("v.inTransitStatus","");
        component.set("v.isShowType",false);
        component.set("v.entryType","")
        this.storedTableData = {};
},
    
})