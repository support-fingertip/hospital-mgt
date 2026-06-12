({
    doInit : function(component, event, helper) {
        
        // Create a new Date object for the current date
        const currentDate = new Date();
        
        // Calculate the month and year of the previous month
        let previousMonth = currentDate.getMonth() - 1;
        let previousYear = currentDate.getFullYear();
        console.log(previousMonth)
        if (previousMonth < 0) {
            // If the previous month is negative, subtract 1 from the year and set the month to 12 (December)
            previousMonth = 12;
            previousYear -= 1;
        }
        
        // Create a new Date object for the first day of the previous month
        const previousMonthDate = new Date(previousYear, previousMonth, 1);
        
        var lastMonth = previousMonthDate.toLocaleString('default', { month: 'short' }) +'-' + previousYear;
         console.log(lastMonth);
        var curMonth = currentDate.toLocaleString('default', { month: 'short' }) +'-' + currentDate.getFullYear();
         console.log(curMonth);
        component.set('v.lastMonth',lastMonth );
       component.set('v.curMonth',curMonth );
        
     var result = [ 'Anil Kumar','Sunil George']
      component.set('v.topSellers', result);
        var data = {}
        data.targets = [{'targetName':'Visits','target':45,'actual':23},{'targetName':'New Hospitals','target':10,'actual':3},{'targetName':'Coverage','target':78,'actual':63} ]
          
        
         data.visits = [ {'cusType':'Hospital','planned':45,'completed':23}, {'cusType':'Distributers','planned':56,'completed':43} ]

         
      component.set('v.data', data);

        
        
    }
})