({
    doInit : function(component, event, helper) {
        helper.setVariable(component, event, helper);
        helper.warehouseDetails(component, event, helper);
        helper.productCategoryDetails(component, event, helper);
        helper.fetchPicklist(component, event, helper);
        
    },
    handleRowAction: function (component, event, helper) {
        var buttonName = event.getParam('action').name;
        const action = event.getParam('action');
        const row = event.getParam('row');
        component.set("v.selectedRecord",row);
        component.set("v.selectedItem",row);
        var data = component.get("v.selectedRecord");
        var stocktype;
        if(buttonName == 'add_button'){
            stocktype = 'inward';
        }else if(buttonName == 'delete_button'){
            stocktype = 'outward';
        }
        var processedData = {
            'sObjectName': 'Stock_Item__c',
            'Name': data.Name,
            'Product__c': data.Product__c,
            'Stock__c': data.Id,
            'Stock_Type__c': stocktype,
            'Sku_Name__c': data.Sku_Name__c,
            'Hsn_Code__c': data.Hsn_Code__c,
            'Quantity__c': 0,
            'Selling_Price__c': 0,
            'Purchase_Price__c': 0,
            'Bin_Location__c':''
            
        };
        component.set("v.selectedItem", processedData);
        
        if(buttonName == 'add_button'){
            helper.addRow(component,event,helper, row);
        }else if(buttonName == 'delete_button'){
            helper.deleteRow(component,event,helper, row);
        }
        
    },
    defaultCloseAction : function(component, event, helper) {
        component.set("v.isHidden", true);
    },
    updateSelectedText4: function (component, event, helper) {
        var selectedRows = event.getParam('selectedRows');
        component.set('v.selectedRowsCount4', selectedRows.length);
        const action = event.getParam('action');
        const row = event.getParam('row');
        switch (action.name) {
            case 'delete':
                helper.disableDeleteButton(component, row);
                break;
        }
        var totalWeight = 0;
        selectedRows.forEach(function (row) {
            totalWeight += row.Weight__c;
        });
        var vehCap = component.get('v.maxWeight');
        if(totalWeight < vehCap){
            component.set("v.selectedRecord", selectedRows);
            component.set("v.totalWeight", totalWeight);
        }else{
            //alert(JSON.stringify(component.get("v.selectedRows")));
            const rows = selectedRows;
            //alert('You can only select up to 5 rows.');
            component.set("v.selectedRecord", rows);
            const dataTable = component.find("lgtngCmp");
            //alert(JSON.stringify(component.get("v.selectedRows")));
            dataTable.set("v.selectedRows", selectedRows);
            
            helper.showMessage('Maximum capacity of vehicle reached', 'error');
        }
        
    },    
    searchWarehouse : function(component, event, helper) {
        
        var warehouses= component.get('v.warehouses');
        var searchText= component.get('v.searchtext');
        var matchWarehouses=[];
        if(searchText !=''){
            for(var i=0;i<warehouses.length; i++){ 
                if(warehouses[i].Name.toLowerCase().indexOf(searchText.toLowerCase())  != -1  ){
                    matchWarehouses.push( warehouses[i] );
                } 
            } 
            if(matchWarehouses.length >0){
                component.set('v.matchWarehouses',matchWarehouses);
            }
        }else{
            component.set('v.matchWarehouses',[]);
        }
    },
    searchProductCategory : function(component, event, helper) {
        var productCategories= component.get('v.productCategories');
        var searchText= component.get('v.searchProductCatgText');
        var matchProductCategories=[];
        if(searchText !=''){
            for(var i=0;i<productCategories.length; i++){ 
                if(productCategories[i].Name.toLowerCase().indexOf(searchText.toLowerCase())  != -1  ){
                    matchProductCategories.push( productCategories[i] )
                } 
            } 
            if(productCategories.length >0){
                component.set('v.matchProductCategories',matchProductCategories);
            }
        }else{
            component.set('v.matchProductCategories',[]);
        }
    },
    update: function(component, event, helper) {
        
        component.set('v.selectedWareHouse', event.currentTarget.dataset.id);
        component.set('v.showUsers',true);
        var rdi = event.currentTarget.dataset.id;
        var warehouses= component.get('v.matchWarehouses');
        for(var i=0;i<warehouses.length; i++){ 
            if(warehouses[i].Id ===  rdi ){
                component.set('v.searchtext', warehouses[i].Name);
                break;
            } 
        } 
        
        component.set('v.matchWarehouses',[]);
        component.set('v.stockname','Stocks');
        helper.setColumn(component, event, helper);
        helper.getData(component, event, helper);
        
    },
    update2: function(component, event, helper) {
        component.set("v.selectedProdCatg", event.currentTarget.dataset.id);
        
        var rdi =  event.currentTarget.dataset.id;
        var drivers= component.get('v.matchProductCategories');
        for(var i=0;i<drivers.length; i++){ 
            if(drivers[i].Id ===  rdi ){
                component.set('v.searchProductCatgText', drivers[i].Name);
                break;
            } 
        } 
        component.set('v.matchProductCategories',[]);
        
        helper.setColumn(component, event, helper);
        helper.validateData(component, event, helper);
        
    },
    productCatChange: function(component, event, helper) {
        var status = component.get("v.inTransitStatus");
        var namestock = component.get('v.stockname');
        if(namestock == "Stocks"){
            helper.setColumn(component, event, helper);
            helper.validateData(component, event, helper);
        }else if(namestock == "Outward Stocks"){
            component.set("v.showUsers",true);
            component.set("v.isShowButton",false);
            helper.filterTableData(component, event, helper);
            //helper.getOutwardData(component, event, helper);
        }else if(namestock == "Inward Stocks"){
            component.set("v.showUsers",true);
            component.set("v.isShowButton",false);
            helper.filterTableData(component, event, helper);
        }
        else if(namestock == "In-Transit Stocks" && status == "Delivered"){
            helper.fetchIntransitItem(component, event, helper);
        }
        else if(namestock == "In-Transit Stocks" && status == "In-Transit"){
            //component.set("v.showUsers",true);
            //component.set("v.isShowButton",false);
            helper.getProducts(component, event, helper);
        }
    },
    handleSave: function(component, event, helper) {
        var draftValues = event.getParam('draftValues');
        helper.saveChanges(component, draftValues);
    },
    addStockItem: function(component, event, helper) {
        helper.addStockItem(component, event, helper);
    },
    AddInwardStock: function(component, event, helper) {
        component.set("v.selectedType",'Create Inward Stock');
        component.set('v.stockname','');
        component.set('v.stockname','Inward Stocks');
        component.set("v.showUsers",true);
        component.set("v.isShowButton",false);
        //component.set("v.isShowType",true);
        helper.getProducts(component, event, helper);
        // helper.addStockItem(component, event, helper);
    },
    outwardStock: function(component, event, helper) {
        component.set("v.selectedType",'Create Outward Stock');
        component.set('v.stockname','Outward Stocks');
        component.set("v.showUsers",true);
        component.set("v.isShowButton",false);
        //component.set("v.isShowType",true);
        helper.getOutwardData(component, event, helper);
    },
    showPreview: function(component, event, helper) {
        var status = component.get("v.inTransitStatus");
        var type = component.get("v.entryType");
        if(type == 'In-Transit' && status == ""){
            helper.showMessage("Please Select Status","error");
        }else{
            helper.showPreview(component, event, helper);
        }
        
    },
    createStock: function(component, event, helper) {
        var stockname = component.get("v.stockname");
        var status = component.get("v.inTransitStatus");
        if(stockname == "Inward Stocks"){
            helper.createStock(component, event, helper);
        }else if(stockname == "Outward Stocks"){
            helper.createOutwardStock(component, event, helper);
        }else if(stockname == "In-Transit Stocks" && status == "In-Transit"){
            
            helper.createInTransitStock(component, event, helper);
        }else if(stockname == "In-Transit Stocks" && status == "Delivered"){
            helper.updateInTransitStock(component, event, helper);
        }
        
    },
    doEntryTypeChange: function(component, event, helper) {
        var type = component.get("v.entryType");
        if(type =="Inward"){
            component.set("v.stockname","Inward Stocks");
            helper.getProducts(component, event, helper);
        }else if(type =="In-Transit"){
            component.set("v.stockname","In-Transit Stocks");
            helper.getProducts(component, event, helper);
        }else if(type =="Damaged"){
            component.set("v.stockname","Damaged Stocks");
        }
            else if(type ==""){
                component.set('v.tableData',[]);
                component.set("v.stockname","");
            }
        component.set("v.showUsers",true);
        
    },
    inTransitStatusChange: function(component, event, helper) {
        var type = component.get("v.entryType");
        component.set("v.showUsers",true);
        var status = component.get("v.inTransitStatus");
        if(status == "In-Transit"){
            helper.getProducts(component, event, helper);
            component.set("v.disableInTrQty",false);
        }else if(status == "Delivered" && type =="In-Transit"){
            component.set("v.disableInTrQty",true);
            helper.fetchIntransitItem(component, event, helper);
            
        }else if(status ==""){
            component.set('v.tableData',[]);
        }
        component.set("v.stockname","In-Transit Stocks");
    },
    docancel: function (component, event, helper) {
        helper.doCancel(component,event,helper);
    },
    goBack: function(component, event, helper) {
        helper.goBack(component, event, helper);
    },
    commentedCode: function(component, event, helper) {
        //Product Category as searchable
        
        /*    <div class="slds-float_left slds-p-bottom_small">
                            <p>
                                <div class="slds-size_1-of-11 slds-p-horizontal_small">
                                    <div class="slds-form-element">
                                        <div class="slds-form-element__control">
                                            <div class="slds-combobox_container">
                                                <div class="slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-is-open">
                                                    <div class="slds-combobox__form-element slds-input-has-icon slds-input-has-icon_right" role="none">
                                                        <lightning:input value="{!v.searchProductCatgText}" onchange="{!c.searchProductCategory}" aura:id="enter-search" label="Select Product Category" type="search" autocomplete="off"/>
                                                    </div>
                                                    <aura:if isTrue="{!not(empty(v.matchProductCategories))}">
                                                        <div id="listbox-id-4" class="slds-dropdown slds-dropdown_length-with-icon-7 slds-dropdown_fluid" role="listbox" aria-label="{{Placeholder for Dropdown Items}}" tabindex="0" aria-busy="false">
                                                            <ul class="slds-listbox slds-listbox_vertical" role="presentation">
                                                                <aura:iteration items="{!v.matchProductCategories}" var="item" start="0" end="9">
                                                                    <li role="presentation" class="slds-listbox__item">
                                                                        <div id="option268" class="slds-media slds-listbox__option slds-listbox__option_entity slds-listbox__option_has-meta" role="option">
                                                                            <span class="slds-media__body">
                                                                                <span class="slds-listbox__option-meta slds-listbox__option-meta_entity">
                                                                                    <div class="slds-lookup__result-text" data-id="{!item.Id}" onclick="{!c.update2 }">
                                                                                        <a role="option" >
                                                                                            <lightning:icon iconName="standard:product_item" size="xx-small"/>&nbsp;{!item.Name}
                                                                                        </a>
                                                                                    </div>
                                                                                </span>
                                                                            </span>
                                                                        </div>
                                                                    </li>
                                                                </aura:iteration>
                                                            </ul>
                                                        </div>
                                                    </aura:if>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </p>
                        </div> */
    },
})