public class StockManagementCntrl {
    
    // ========== WAREHOUSE & PRODUCT METHODS ==========
    
    @AuraEnabled
    public static List<Warehouse__c> getWareHouse(){
        return [SELECT Id, Name, Email__c, Warehouse_Id__c 
                FROM Warehouse__c 
                WHERE Active__c = true 
                ORDER BY Name];
    }
    
    @AuraEnabled
    public static List<String> getProductCategories(){
        List<String> catNameList = new List<String>();
        List<Product_Category__c> categories = [SELECT Name 
                                                 FROM Product_Category__c 
                                                 WHERE active__c = true 
                                                 ORDER BY Name];
        for(Product_Category__c pc : categories){ 
            catNameList.add(pc.Name);
        }
        return catNameList;
    }
    
    @AuraEnabled
    public static List<SObject> getRecords(String productcategory, String warehouse){
        if(productcategory == ''){
            return [SELECT Id, Name, Daily_Consumption__c, Days_Left__c, Lead_Time__c, Price__c, 
                    Re_Order_Quanity__c, Available_Qty__c, Warehouse__c, Product_category__c, Product__c, 
                    Product__r.Name, Hsn_Code__c, Uom__c, Sku_Name__c, In_Transit_qty__c, 
                    Damaged_Qty__c, Total_Price__c, Warehouse__r.Name, Batch_Series_No__c
                    FROM Stock__c 
                    WHERE Active__c = true AND warehouse__c = :warehouse 
                    ORDER BY Sku_Name__c];
        } else {
            return [SELECT Id, Name, Daily_Consumption__c, Days_Left__c, Lead_Time__c, Price__c, 
                    Re_Order_Quanity__c, Available_Qty__c, Warehouse__c, Product_category__c, Product__c, 
                    Product__r.Name, Hsn_Code__c, Uom__c, Sku_Name__c, In_Transit_qty__c, 
                    Damaged_Qty__c, Total_Price__c, Warehouse__r.Name, Batch_Series_No__c
                    FROM Stock__c 
                    WHERE Product_category__c = :productcategory AND warehouse__c = :warehouse 
                    ORDER BY Sku_Name__c];
        }
    }
    
    @AuraEnabled
    public static List<SObject> fetchOutwardData(String productcategory, String warehouse){
        if(productcategory == ''){
            return [SELECT Id, Name, Available_Qty__c, Product_category__c, Product__c, 
                    Hsn_Code__c, Uom__c, Sku_Name__c, In_Transit_qty__c, Damaged_Qty__c, Total_Price__c 
                    FROM Stock__c 
                    WHERE warehouse__c = :warehouse];
        } else {
            return [SELECT Id, Name, Available_Qty__c, Product_category__c, Product__c, 
                    Hsn_Code__c, Uom__c, Sku_Name__c, In_Transit_qty__c, Damaged_Qty__c, Total_Price__c 
                    FROM Stock__c 
                    WHERE Product__r.Product_Category__c = :productcategory AND warehouse__c = :warehouse];
        }
    }
    
    @AuraEnabled
    public static List<String> fetchPicklistValue(String objectName, String fieldName) {
        List<String> picklistLabels = new List<String>();
        
        Schema.SObjectType sObjectType = Schema.getGlobalDescribe().get(objectName);
        Schema.DescribeSObjectResult sObjectDescribe = sObjectType.getDescribe();
        Schema.DescribeFieldResult fieldDescribe = sObjectDescribe.fields.getMap().get(fieldName).getDescribe();
        
        if (fieldDescribe.getType() == Schema.DisplayType.Picklist) {
            List<Schema.PicklistEntry> picklistValues = fieldDescribe.getPicklistValues();
            for (Schema.PicklistEntry picklistEntry : picklistValues) {
                picklistLabels.add(picklistEntry.getLabel());
            }
        }
        
        return picklistLabels;
    }
    
    @AuraEnabled
    public static List<SObject> getproductRecords(String productcategory){
        if(productcategory == ''){
            return [SELECT Id, Name, HSN_Code__c, Product_Category_Name__c, Sku_Name__c, Product_category__c 
                    FROM Product__c 
                    WHERE Sku_Name__c != null 
                    ORDER BY Sku_Name__c];
        } else {
            return [SELECT Id, Name, HSN_Code__c, Product_Category_Name__c, Sku_Name__c, Product_category__c 
                    FROM Product__c 
                    WHERE Product_Category_Name__c = :productcategory AND Sku_Name__c != null
                    ORDER BY Sku_Name__c];
        }
    }
    
    // ========== STOCK TRANSACTION METHODS ==========
    
    @AuraEnabled
    public static void saveStock(List<Stock__c> stocks) {
        Map<String, Stock__c> existingStocksMap = new Map<String, Stock__c>();
        Set<String> skuWarehouseKeys = new Set<String>();
        
        for (Stock__c d : stocks) {
            String stockKey = d.Sku_Name__c + '_' + d.Warehouse__c;
            skuWarehouseKeys.add(stockKey);
        }

        if (!skuWarehouseKeys.isEmpty()) {
            List<Stock__c> existingStocks = [SELECT Id, Sku_Warehouse__c 
                                             FROM Stock__c 
                                             WHERE Sku_Warehouse__c IN :skuWarehouseKeys];
            for (Stock__c s : existingStocks) {
                existingStocksMap.put(s.Sku_Warehouse__c, s);
            }
        }

        List<Stock__c> stocksToInsert = new List<Stock__c>();
        List<Stock_Item__c> stockItemsToInsert = new List<Stock_Item__c>();

        for (Stock__c d : stocks) {
            Stock__c s;
            String stockKey = d.Sku_Name__c + '_' + d.Warehouse__c;

            if (existingStocksMap.containsKey(stockKey)) {
                s = existingStocksMap.get(stockKey);
            } else {
                s = new Stock__c();
                s.Product__c = d.Product__c;
                s.Warehouse__c = d.Warehouse__c;
                s.Purchased_Price_qty__c = d.Purchased_Price_qty__c;
                stocksToInsert.add(s);
                existingStocksMap.put(stockKey, s);
            }

            Stock_Item__c si = new Stock_Item__c();
            si.Stock__c = s.Id;
            si.Product__c = d.Product__c;
            si.Expiry_Date__c = d.Expire_date__c;
            si.Stock_Type__c = 'Inward';
            si.Quantity__c = d.Sold_Quantity__c;
            si.Purchase_Price__c = d.Purchased_Price_qty__c;
            stockItemsToInsert.add(si);
        }

        if (!stocksToInsert.isEmpty()) {
            insert stocksToInsert;
            for (Stock__c insertedStock : stocksToInsert) {
                existingStocksMap.put(insertedStock.Sku_Warehouse__c, insertedStock);
            }
        }

        for (Stock_Item__c si : stockItemsToInsert) {
            if (si.Stock__c == null) {
                String stockKey = null;
                for (Stock__c d : stocks) {
                    if (d.Product__c == si.Product__c) {
                        stockKey = d.Sku_Name__c + '_' + d.Warehouse__c;
                        break;
                    }
                }
                if (stockKey != null && existingStocksMap.containsKey(stockKey)) {
                    si.Stock__c = existingStocksMap.get(stockKey).Id;
                }
            }
        }
        insert stockItemsToInsert;
    }
    
    @AuraEnabled
    public static void saveInTransitStock(List<Stock__c> stocks) {
        Map<String, Stock__c> existingStocksMap = new Map<String, Stock__c>();
        Set<String> skuWarehouseKeys = new Set<String>();
        
        for (Stock__c d : stocks) {
            String stockKey = d.Sku_Name__c + '_' + d.Warehouse__c;
            skuWarehouseKeys.add(stockKey);
        }

        if (!skuWarehouseKeys.isEmpty()) {
            List<Stock__c> existingStocks = [SELECT Id, Sku_Warehouse__c 
                                             FROM Stock__c 
                                             WHERE Sku_Warehouse__c IN :skuWarehouseKeys];
            for (Stock__c s : existingStocks) {
                existingStocksMap.put(s.Sku_Warehouse__c, s);
            }
        }

        List<Stock__c> stocksToInsert = new List<Stock__c>();
        List<In_Transit_Item__c> stockItemsToInsert = new List<In_Transit_Item__c>();

        for (Stock__c d : stocks) {
            Stock__c s;
            String stockKey = d.Sku_Name__c + '_' + d.Warehouse__c;

            if (existingStocksMap.containsKey(stockKey)) {
                s = existingStocksMap.get(stockKey);
            } else {
                s = new Stock__c();
                s.Product__c = d.Product__c;
                s.Warehouse__c = d.Warehouse__c;
                s.Purchased_Price_qty__c = d.Purchased_Price_qty__c;
                stocksToInsert.add(s);
                existingStocksMap.put(stockKey, s);
            }

            In_Transit_Item__c si = new In_Transit_Item__c();
            si.Stock__c = s.Id;
            si.Product__c = d.Product__c;
            si.Exp_Delv_Date__c = d.Expire_date__c;
            si.Status__c = 'In-Transit';
            si.In_Transit_qty__c = d.Sold_Quantity__c;
            si.Purchase_Price__c = d.Purchased_Price_qty__c;
            stockItemsToInsert.add(si);
        }

        if (!stocksToInsert.isEmpty()) {
            insert stocksToInsert;
            for (Stock__c insertedStock : stocksToInsert) {
                existingStocksMap.put(insertedStock.Sku_Warehouse__c, insertedStock);
            }
        }

        for (In_Transit_Item__c si : stockItemsToInsert) {
            if (si.Stock__c == null) {
                String stockKey = null;
                for (Stock__c d : stocks) {
                    if (d.Product__c == si.Product__c) {
                        stockKey = d.Sku_Name__c + '_' + d.Warehouse__c;
                        break;
                    }
                }
                if (stockKey != null && existingStocksMap.containsKey(stockKey)) {
                    si.Stock__c = existingStocksMap.get(stockKey).Id;
                }
            }
        }
        insert stockItemsToInsert;
    }
    
    @AuraEnabled
    public static List<SObject> getIntransitItems(String productcategory, String warehouse){
        if(productcategory == ''){
            return [SELECT Id, Name, Exp_Delv_Date__c, Product_category__c, Quantity__c, 
                    Purchase_Price__c, Status__c, Stock__c, Product__c, Product__r.Name, 
                    HSN_Code__c, Uom__c, Sku_Name__c, In_Transit_qty__c 
                    FROM In_Transit_Item__c 
                    WHERE Stock__r.warehouse__c = :warehouse AND Status__c = 'In-Transit'
                    ORDER BY Sku_Name__c]; 
        } else {
            return [SELECT Id, Name, Exp_Delv_Date__c, In_Transit_qty__c, Purchase_Price__c, 
                    Quantity__c, Status__c, Product_category__c, Stock__c, Product__c, 
                    Product__r.Name, HSN_Code__c, Uom__c, Sku_Name__c 
                    FROM In_Transit_Item__c 
                    WHERE Product_category__c = :productcategory 
                    AND Stock__r.warehouse__c = :warehouse AND Status__c = 'In-Transit'
                    ORDER BY Sku_Name__c];
        }
    }
    
    @AuraEnabled
    public static void saveStockItem(Stock_Item__c stockItems){
        insert stockItems;
    }
    
    @AuraEnabled
    public static void saveOutwardStockItem(List<Stock_Item__c> stockItems){
        insert stockItems;
    }
    
    // Called when In-Transit items are marked as Delivered
    // Updates In_Transit_Item__c status, then creates Stock_Item__c (Inward) for each
    @AuraEnabled
    public static void updateData(List<In_Transit_Item__c> stockItems){
        update stockItems;
        
        List<Stock_Item__c> stockItemList = new List<Stock_Item__c>();
        for(In_Transit_Item__c s : stockItems){
            Stock_Item__c si = new Stock_Item__c();
            si.Stock__c = s.Stock__c;
            si.Product__c = s.Product__c;
            si.Stock_Type__c = 'Inward';
            si.Quantity__c = s.Delivered_Quantity__c;
            si.Purchase_Price__c = s.Purchase_Price__c;
            stockItemList.add(si);
        }
        insert stockItemList;
    }
    
    // ========== DASHBOARD & ANALYTICS ==========
    
    @AuraEnabled
    public static DashboardData getDashboardData(String warehouse) {
        DashboardData data = new DashboardData();
        
        if(String.isBlank(warehouse)) {
            return data;
        }
        
        List<AggregateResult> results = [
            SELECT SUM(Available_Qty__c) availQty, 
                   SUM(In_Transit_qty__c) transitQty, 
                   SUM(Damaged_Qty__c) damagedQty, 
                   SUM(Total_Price__c) totalValue
            FROM Stock__c 
            WHERE Warehouse__c = :warehouse AND Active__c = true
        ];
        
        if(!results.isEmpty()) {
            AggregateResult ar = results[0];
            data.totalAvailable = ar.get('availQty') != null ? (Decimal)ar.get('availQty') : 0;
            data.totalInTransit = ar.get('transitQty') != null ? (Decimal)ar.get('transitQty') : 0;
            data.totalDamaged = ar.get('damagedQty') != null ? (Decimal)ar.get('damagedQty') : 0;
            data.totalValue = ar.get('totalValue') != null ? (Decimal)ar.get('totalValue') : 0;
        }
        
        // Low stock = Available_Qty__c < 50
        Decimal threshold = 50;
        List<AggregateResult> lowStockResult = [
            SELECT COUNT(Id) cnt
            FROM Stock__c 
            WHERE Warehouse__c = :warehouse 
            AND Active__c = true
            AND Available_Qty__c < :threshold
        ];
        data.lowStockCount = !lowStockResult.isEmpty() && lowStockResult[0].get('cnt') != null
            ? Integer.valueOf(lowStockResult[0].get('cnt'))
            : 0;
        
        // Expiry count — items expiring within 90 days
        Date expiryDate = Date.today().addDays(90);
        List<AggregateResult> expiryResult = [
            SELECT COUNT(Id) cnt
            FROM Stock_Item__c 
            WHERE Stock__r.Warehouse__c = :warehouse 
            AND Expiry_Date__c <= :expiryDate
            AND Expiry_Date__c >= :Date.today()
            AND Stock_Type__c = 'Inward'
        ];
        data.expiryCount = !expiryResult.isEmpty() && expiryResult[0].get('cnt') != null 
            ? Integer.valueOf(expiryResult[0].get('cnt')) 
            : 0;
        
        return data;
    }
    
    // ========== LOW STOCK — returns all Stock__c where Available_Qty < 50 ==========
    @AuraEnabled
    public static List<Stock__c> getLowStockProducts(String warehouse) {
        Decimal threshold = 50;
        return [SELECT Id, Sku_Name__c, Hsn_Code__c, Product_category__c, 
                       Available_Qty__c, In_Transit_qty__c, Total_Price__c
                FROM Stock__c 
                WHERE Warehouse__c = :warehouse 
                AND Active__c = true
                AND Available_Qty__c < :threshold
                ORDER BY Available_Qty__c ASC];
    }
    
    // ========== STOCK HISTORY — all Stock_Item__c for a warehouse ==========
    // This is the full audit trail: every Inward, Outward, Damaged, Sample, Return transaction
    @AuraEnabled
    public static List<HistoryWrapper> getStockHistory(String warehouse, String productcategory, String stockType) {
        List<HistoryWrapper> historyList = new List<HistoryWrapper>();
        
        if(String.isBlank(warehouse)) {
            return historyList;
        }
        
        // Build query dynamically based on filters
        String query = 'SELECT Id, CreatedDate, Stock_Type__c, Quantity__c, Purchase_Price__c, Expiry_Date__c, '
                     + 'Stock__r.Sku_Name__c, Stock__r.Product_category__c, Stock__r.Batch_Series_No__c '
                     + 'FROM Stock_Item__c '
                     + 'WHERE Stock__r.Warehouse__c = \'' + warehouse + '\'';
        
        if(String.isNotBlank(productcategory)) {
            query += ' AND Stock__r.Product_category__c = \'' + productcategory + '\'';
        }
        if(String.isNotBlank(stockType)) {
            query += ' AND Stock_Type__c = \'' + stockType + '\'';
        }
        
        query += ' ORDER BY CreatedDate DESC LIMIT 500';
        
        List<Stock_Item__c> items = Database.query(query);
        
        for(Stock_Item__c item : items) {
            HistoryWrapper hw = new HistoryWrapper();
            hw.Id = item.Id;
            hw.CreatedDate = item.CreatedDate;
            hw.StockType = item.Stock_Type__c;
            hw.Quantity = item.Quantity__c;
            hw.PurchasePrice = item.Purchase_Price__c;
            hw.skuName = item.Stock__r.Sku_Name__c;
            hw.productCategory = item.Stock__r.Product_category__c;
            hw.batchNumber = item.Stock__r.Batch_Series_No__c;
            historyList.add(hw);
        }
        
        return historyList;
    }
    
    // ========== BATCH TRACKING ==========
    
    @AuraEnabled
    public static List<BatchWrapper> getBatchData(String warehouse, Integer daysThreshold) {
        List<BatchWrapper> batchList = new List<BatchWrapper>();
        
        if(String.isBlank(warehouse)) {
            return batchList;
        }
        
        List<Stock__c> stocks = [
            SELECT Id, Name, Sku_Name__c, Product_category__c, Warehouse__r.Name,
                   Batch_Series_No__c, Available_Qty__c, CreatedDate,
                   (SELECT Id, Expiry_Date__c, Quantity__c 
                    FROM Stock_Items__r 
                    WHERE Stock_Type__c = 'Inward' AND Expiry_Date__c != null
                    ORDER BY Expiry_Date__c ASC LIMIT 1)
            FROM Stock__c 
            WHERE Warehouse__c = :warehouse
            AND Active__c = true
            AND Batch_Series_No__c != null
            ORDER BY Batch_Series_No__c ASC
            LIMIT 200
        ];
        
        for(Stock__c stock : stocks) {
            BatchWrapper bw = new BatchWrapper();
            bw.id = stock.Id;
            bw.batchNumber = stock.Batch_Series_No__c;
            bw.skuName = stock.Sku_Name__c;
            bw.productCategory = stock.Product_category__c;
            bw.warehouse = stock.Warehouse__r.Name;
            bw.quantity = stock.Available_Qty__c;
            bw.createdDate = stock.CreatedDate;
            
            if(!stock.Stock_Items__r.isEmpty()) {
                Stock_Item__c item = stock.Stock_Items__r[0];
                bw.expiryDate = item.Expiry_Date__c;
                
                if(item.Expiry_Date__c != null) {
                    bw.daysToExpiry = Date.today().daysBetween(item.Expiry_Date__c);
                    
                    if(bw.daysToExpiry <= 30) {
                        bw.priority = 'Critical';
                    } else if(bw.daysToExpiry <= 60) {
                        bw.priority = 'High';
                    } else {
                        bw.priority = 'Medium';
                    }
                }
            }
            
            if(daysThreshold != null && bw.daysToExpiry != null) {
                if(bw.daysToExpiry <= daysThreshold) {
                    batchList.add(bw);
                }
            } else {
                batchList.add(bw);
            }
        }
        
        return batchList;
    }
    
    @AuraEnabled
    public static List<BatchWrapper> searchBatchData(String warehouse, String searchTerm) {
        List<BatchWrapper> batchList = new List<BatchWrapper>();
        
        if(String.isBlank(warehouse) || String.isBlank(searchTerm)) {
            return batchList;
        }
        
        String searchPattern = '%' + searchTerm + '%';
        
        List<Stock__c> stocks = [
            SELECT Id, Name, Sku_Name__c, Product_category__c, Warehouse__r.Name,
                   Batch_Series_No__c, Available_Qty__c, CreatedDate,
                   (SELECT Id, Expiry_Date__c, Quantity__c 
                    FROM Stock_Items__r 
                    WHERE Stock_Type__c = 'Inward' AND Expiry_Date__c != null
                    ORDER BY Expiry_Date__c ASC LIMIT 1)
            FROM Stock__c 
            WHERE Warehouse__c = :warehouse
            AND Active__c = true
            AND (Batch_Series_No__c LIKE :searchPattern OR Sku_Name__c LIKE :searchPattern)
            ORDER BY Batch_Series_No__c ASC
            LIMIT 100
        ];
        
        for(Stock__c stock : stocks) {
            BatchWrapper bw = new BatchWrapper();
            bw.id = stock.Id;
            bw.batchNumber = stock.Batch_Series_No__c;
            bw.skuName = stock.Sku_Name__c;
            bw.productCategory = stock.Product_category__c;
            bw.warehouse = stock.Warehouse__r.Name;
            bw.quantity = stock.Available_Qty__c;
            bw.createdDate = stock.CreatedDate;
            
            if(!stock.Stock_Items__r.isEmpty()) {
                Stock_Item__c item = stock.Stock_Items__r[0];
                bw.expiryDate = item.Expiry_Date__c;
                
                if(item.Expiry_Date__c != null) {
                    bw.daysToExpiry = Date.today().daysBetween(item.Expiry_Date__c);
                    
                    if(bw.daysToExpiry <= 30) {
                        bw.priority = 'Critical';
                    } else if(bw.daysToExpiry <= 60) {
                        bw.priority = 'High';
                    } else {
                        bw.priority = 'Medium';
                    }
                }
            }
            
            batchList.add(bw);
        }
        
        return batchList;
    }
    
    // ========== BULK SAVE — Stock_Item__c ==========
    // BATCH BUG FIX:
    //   - Batch number is NO LONGER overwritten on Stock__c on every save.
    //   - Stock__c.Batch_Series_No__c is set only when the Stock__c is first created.
    //   - Each Stock_Item__c gets its own Expiry_Date__c (already working).
    //   - If you need per-item batch tracking, add a Batch_Number__c field to Stock_Item__c
    //     and we will populate it here. For now we set it on Stock__c at creation only.
    
    @AuraEnabled
    public static String saveBulkStockTransactions(List<String> productIds, 
                                                   String warehouseId, 
                                                   String transactionType,
                                                   List<Decimal> quantities,
                                                   List<Decimal> prices,
                                                   String batchNumber, 
                                                   Date expiryDate) {
        try {
            if(String.isBlank(warehouseId)) {
                throw new AuraHandledException('Warehouse ID is missing.');
            }
            if(productIds == null || productIds.isEmpty()) {
                throw new AuraHandledException('No products provided.');
            }
            if(productIds.size() != quantities.size()) {
                throw new AuraHandledException('Product and quantity lists do not match.');
            }
            
            List<Warehouse__c> warehouses = [SELECT Id FROM Warehouse__c WHERE Id = :warehouseId LIMIT 1];
            if(warehouses.isEmpty()) {
                throw new AuraHandledException('Warehouse not found.');
            }
            
            String stockType = mapTransactionType(transactionType);
            
            // Load all products
            Set<String> productIdSet = new Set<String>(productIds);
            Map<Id, Product__c> productMap = new Map<Id, Product__c>(
                [SELECT Id, Sku_Name__c FROM Product__c WHERE Id IN :productIdSet]
            );
            
            // Build sku_warehouse keys
            Set<String> skuWarehouseKeys = new Set<String>();
            for(String pid : productIds) {
                Product__c prod = productMap.get(pid);
                if(prod != null && prod.Sku_Name__c != null) {
                    skuWarehouseKeys.add(prod.Sku_Name__c + '_' + warehouseId);
                }
            }
            
            // Fetch existing Stock__c
            Map<String, Stock__c> existingStockMap = new Map<String, Stock__c>();
            if(!skuWarehouseKeys.isEmpty()) {
                List<Stock__c> existingStocks = [
                    SELECT Id, Sku_Warehouse__c, Batch_Series_No__c
                    FROM Stock__c 
                    WHERE Sku_Warehouse__c IN :skuWarehouseKeys
                ];
                for(Stock__c s : existingStocks) {
                    existingStockMap.put(s.Sku_Warehouse__c, s);
                }
            }
            
            // Create new Stock__c only for products that don't have one yet
            // Batch number set ONLY on new Stock__c — never overwrite existing
            List<Stock__c> stocksToInsert = new List<Stock__c>();
            Map<String, Stock__c> pendingNewStocks = new Map<String, Stock__c>();
            
            for(Integer i = 0; i < productIds.size(); i++) {
                String pid = productIds[i];
                Product__c prod = productMap.get(pid);
                if(prod == null) continue;
                
                String skuKey = prod.Sku_Name__c + '_' + warehouseId;
                
                if(!existingStockMap.containsKey(skuKey) && !pendingNewStocks.containsKey(skuKey)) {
                    Stock__c newStock = new Stock__c();
                    newStock.Product__c = pid;
                    newStock.Warehouse__c = warehouseId;
                    newStock.Batch_Series_No__c = batchNumber;
                    stocksToInsert.add(newStock);
                    pendingNewStocks.put(skuKey, newStock);
                }
            }
            
            if(!stocksToInsert.isEmpty()) {
                insert stocksToInsert;
                for(Stock__c s : stocksToInsert) {
                    existingStockMap.put(s.Sku_Warehouse__c, s);
                }
            }
            
            // NO update loop for batch number — that was the bug causing overwrites
            
            // Build Stock_Item__c list
            List<Stock_Item__c> stockItemsToInsert = new List<Stock_Item__c>();
            
            for(Integer i = 0; i < productIds.size(); i++) {
                String pid = productIds[i];
                Decimal qty = quantities[i];
                Decimal price = (prices != null && i < prices.size()) ? prices[i] : 0;
                
                Product__c prod = productMap.get(pid);
                if(prod == null) continue;
                
                String skuKey = prod.Sku_Name__c + '_' + warehouseId;
                Stock__c stock = existingStockMap.get(skuKey);
                if(stock == null) continue;
                
                Stock_Item__c item = new Stock_Item__c();
                item.Stock__c = stock.Id;
                item.Product__c = pid;
                item.Quantity__c = qty;
                item.Expiry_Date__c = expiryDate;
                item.Stock_Type__c = stockType;
                
                if(stockType == 'Inward' || stockType == 'Return') {
                    item.Purchase_Price__c = price;
                }
                
                stockItemsToInsert.add(item);
            }
            
            if(!stockItemsToInsert.isEmpty()) {
                insert stockItemsToInsert;
            }
            
            return 'SUCCESS: ' + stockItemsToInsert.size() + ' items saved.';
            
        } catch(AuraHandledException e) {
            throw e;
        } catch(Exception e) {
            throw new AuraHandledException('Save failed: ' + e.getMessage());
        }
    }
    
    // ========== BULK SAVE — In_Transit_Item__c ==========
    // Same Stock__c get-or-create logic, but creates In_Transit_Item__c instead of Stock_Item__c
    
    @AuraEnabled
    public static String saveBulkInTransitItems(List<String> productIds, 
                                                String warehouseId,
                                                List<Decimal> quantities,
                                                List<Decimal> prices,
                                                String batchNumber,
                                                Date expectedDeliveryDate) {
        try {
            if(String.isBlank(warehouseId)) {
                throw new AuraHandledException('Warehouse ID is missing.');
            }
            if(productIds == null || productIds.isEmpty()) {
                throw new AuraHandledException('No products provided.');
            }
            if(productIds.size() != quantities.size()) {
                throw new AuraHandledException('Product and quantity lists do not match.');
            }
            
            List<Warehouse__c> warehouses = [SELECT Id FROM Warehouse__c WHERE Id = :warehouseId LIMIT 1];
            if(warehouses.isEmpty()) {
                throw new AuraHandledException('Warehouse not found.');
            }
            
            // Load all products
            Set<String> productIdSet = new Set<String>(productIds);
            Map<Id, Product__c> productMap = new Map<Id, Product__c>(
                [SELECT Id, Sku_Name__c FROM Product__c WHERE Id IN :productIdSet]
            );
            
            // Build sku_warehouse keys
            Set<String> skuWarehouseKeys = new Set<String>();
            for(String pid : productIds) {
                Product__c prod = productMap.get(pid);
                if(prod != null && prod.Sku_Name__c != null) {
                    skuWarehouseKeys.add(prod.Sku_Name__c + '_' + warehouseId);
                }
            }
            
            // Fetch existing Stock__c
            Map<String, Stock__c> existingStockMap = new Map<String, Stock__c>();
            if(!skuWarehouseKeys.isEmpty()) {
                List<Stock__c> existingStocks = [
                    SELECT Id, Sku_Warehouse__c
                    FROM Stock__c 
                    WHERE Sku_Warehouse__c IN :skuWarehouseKeys
                ];
                for(Stock__c s : existingStocks) {
                    existingStockMap.put(s.Sku_Warehouse__c, s);
                }
            }
            
            // Create new Stock__c for products that don't have one
            List<Stock__c> stocksToInsert = new List<Stock__c>();
            Map<String, Stock__c> pendingNewStocks = new Map<String, Stock__c>();
            
            for(Integer i = 0; i < productIds.size(); i++) {
                String pid = productIds[i];
                Product__c prod = productMap.get(pid);
                if(prod == null) continue;
                
                String skuKey = prod.Sku_Name__c + '_' + warehouseId;
                
                if(!existingStockMap.containsKey(skuKey) && !pendingNewStocks.containsKey(skuKey)) {
                    Stock__c newStock = new Stock__c();
                    newStock.Product__c = pid;
                    newStock.Warehouse__c = warehouseId;
                    newStock.Batch_Series_No__c = batchNumber;
                    stocksToInsert.add(newStock);
                    pendingNewStocks.put(skuKey, newStock);
                }
            }
            
            if(!stocksToInsert.isEmpty()) {
                insert stocksToInsert;
                for(Stock__c s : stocksToInsert) {
                    existingStockMap.put(s.Sku_Warehouse__c, s);
                }
            }
            
            // Build In_Transit_Item__c list
            List<In_Transit_Item__c> transitItemsToInsert = new List<In_Transit_Item__c>();
            
            for(Integer i = 0; i < productIds.size(); i++) {
                String pid = productIds[i];
                Decimal qty = quantities[i];
                Decimal price = (prices != null && i < prices.size()) ? prices[i] : 0;
                
                Product__c prod = productMap.get(pid);
                if(prod == null) continue;
                
                String skuKey = prod.Sku_Name__c + '_' + warehouseId;
                Stock__c stock = existingStockMap.get(skuKey);
                if(stock == null) continue;
                
                In_Transit_Item__c item = new In_Transit_Item__c();
                item.Stock__c = stock.Id;
                item.Product__c = pid;
                item.In_Transit_qty__c = qty;
                item.Purchase_Price__c = price;
                item.Exp_Delv_Date__c = expectedDeliveryDate;
                item.Status__c = 'In-Transit';
                
                transitItemsToInsert.add(item);
            }
            
            if(!transitItemsToInsert.isEmpty()) {
                insert transitItemsToInsert;
            }
            
            return 'SUCCESS: ' + transitItemsToInsert.size() + ' in-transit items created.';
            
        } catch(AuraHandledException e) {
            throw e;
        } catch(Exception e) {
            throw new AuraHandledException('Save failed: ' + e.getMessage());
        }
    }
    
    // Maps frontend menuItem -> Stock_Type__c (if-else, Apex has no String switch)
    private static String mapTransactionType(String type) {
        if (String.isBlank(type)) {
            return 'Inward';
        } else if (type == 'inward_mfg') {
            return 'Inward';
        } else if (type == 'inward_return') {
            return 'Return';
        } else if (type == 'outward_sales') {
            return 'Outward';
        } else if (type == 'outward_damaged') {
            return 'Damaged';
        } else if (type == 'outward_sample') {
            return 'Sample';
        } else {
            return 'Inward';
        }
    }
    
    // Single-item save — kept for backward compatibility
    @AuraEnabled
    public static String saveStockTransaction(String productId, String warehouseId, 
                                             String transactionType, Decimal quantity, 
                                             String batchNumber, Date expiryDate, 
                                             Decimal purchasePrice, String binLocation, String remarks) {
        try {
            if(String.isBlank(productId)) {
                throw new AuraHandledException('Product ID is missing or empty');
            }
            if(String.isBlank(warehouseId)) {
                throw new AuraHandledException('Warehouse ID is missing or empty');
            }
            
            List<Product__c> products = [SELECT Id, Sku_Name__c FROM Product__c WHERE Id = :productId LIMIT 1];
            if(products.isEmpty()) {
                throw new AuraHandledException('Product not found with ID: ' + productId);
            }
            String skuName = products[0].Sku_Name__c;
            
            List<Warehouse__c> warehouses = [SELECT Id FROM Warehouse__c WHERE Id = :warehouseId LIMIT 1];
            if(warehouses.isEmpty()) {
                throw new AuraHandledException('Warehouse not found with ID: ' + warehouseId);
            }
            
            String stockKey = skuName + '_' + warehouseId;
            
            List<Stock__c> existingStocks = [SELECT Id FROM Stock__c 
                                             WHERE Sku_Warehouse__c = :stockKey LIMIT 1];
            
            Stock__c stock;
            if(!existingStocks.isEmpty()) {
                stock = existingStocks[0];
                // Do NOT overwrite batch number on existing Stock__c
            } else {
                stock = new Stock__c();
                stock.Product__c = productId;
                stock.Warehouse__c = warehouseId;
                stock.Batch_Series_No__c = batchNumber;
                insert stock;
            }
            
            String stockType = mapTransactionType(transactionType);
            
            Stock_Item__c item = new Stock_Item__c();
            item.Stock__c = stock.Id;
            item.Product__c = productId;
            item.Quantity__c = quantity;
            item.Expiry_Date__c = expiryDate;
            item.Purchase_Price__c = purchasePrice;
            item.Stock_Type__c = stockType;
            
            insert item;
            
            return 'SUCCESS: Transaction saved successfully';
            
        } catch(Exception e) {
            throw new AuraHandledException('Error: ' + e.getMessage());
        }
    }
    
    // ========== WRAPPER CLASSES ==========
    
    public class DashboardData {
        @AuraEnabled public Decimal totalAvailable { get; set; }
        @AuraEnabled public Decimal totalInTransit { get; set; }
        @AuraEnabled public Decimal totalDamaged { get; set; }
        @AuraEnabled public Decimal totalValue { get; set; }
        @AuraEnabled public Integer lowStockCount { get; set; }
        @AuraEnabled public Integer expiryCount { get; set; }
        
        public DashboardData() {
            this.totalAvailable = 0;
            this.totalInTransit = 0;
            this.totalDamaged = 0;
            this.totalValue = 0;
            this.lowStockCount = 0;
            this.expiryCount = 0;
        }
    }
    
    public class BatchWrapper {
        @AuraEnabled public String id { get; set; }
        @AuraEnabled public String batchNumber { get; set; }
        @AuraEnabled public String skuName { get; set; }
        @AuraEnabled public String productCategory { get; set; }
        @AuraEnabled public String warehouse { get; set; }
        @AuraEnabled public Date expiryDate { get; set; }
        @AuraEnabled public Decimal quantity { get; set; }
        @AuraEnabled public DateTime createdDate { get; set; }
        @AuraEnabled public Integer daysToExpiry { get; set; }
        @AuraEnabled public String priority { get; set; }
    }
    
    public class HistoryWrapper {
        @AuraEnabled public Id Id { get; set; }
        @AuraEnabled public DateTime CreatedDate { get; set; }
        @AuraEnabled public String StockType { get; set; }
        @AuraEnabled public Decimal Quantity { get; set; }
        @AuraEnabled public Decimal PurchasePrice { get; set; }
        @AuraEnabled public String skuName { get; set; }
        @AuraEnabled public String productCategory { get; set; }
        @AuraEnabled public String batchNumber { get; set; }
    }
}