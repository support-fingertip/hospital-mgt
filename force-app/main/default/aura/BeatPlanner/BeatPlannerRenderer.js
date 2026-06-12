({
    afterRender: function(component,helper){
        this.superAfterRender();
        console.log('afterRender event handler is running now');
            window.addEventListener('message', function(e) {
                 component.set('v.selectedaccounts', JSON.parse( e.data ) ); 
                 component.set('v.selectedRowsCount', JSON.parse( e.data ).length ); 
                
            }, false );    
    }
})