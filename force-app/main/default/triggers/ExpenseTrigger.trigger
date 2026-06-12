trigger ExpenseTrigger on Expense__c (before update,after insert) {
    if(Trigger.isupdate){
         for(Expense__c exp : Trigger.new){
        if(exp.Approval_Status__c == 'Approved' && exp.ApprovalChek__c == false){
           
            CustomNotificationType notificationType = [SELECT Id, DeveloperName
                                                       FROM CustomNotificationType
                                                       WHERE DeveloperName='Expense_Approval_Notification'];
            
            Messaging.CustomNotification notification = new Messaging.CustomNotification();
          
            notification.setTitle('Expense Approved');
            notification.setBody(exp.Expense_Date__c+' Expense is Approved');
          
            notification.setNotificationTypeId(notificationType.Id);
            notification.setTargetId(exp.Id);
            
            Set<String> addressee = new Set<String>();
            addressee.add(exp.OwnerId);
           
            try {
                notification.send(addressee);
            }
            catch (Exception e) {
                System.debug('Problem sending notification: ' + e.getMessage());
            }
            exp.ApprovalChek__c = true;
            //expLIst.add(exp);
        }else if(exp.Approval_Status__c == 'Rejected' && exp.RejectCheck__c == false){
             CustomNotificationType notificationType = [SELECT Id, DeveloperName
                                                       FROM CustomNotificationType
                                                       WHERE DeveloperName='Expense_Approval_Notification'];
            
            Messaging.CustomNotification notification = new Messaging.CustomNotification();
          
            notification.setTitle('Expense Rejected');
            notification.setBody(exp.Expense_Date__c+' Expense is Rejected');
            notification.setNotificationTypeId(notificationType.Id);
            notification.setTargetId(exp.Id);
            Set<String> addressee = new Set<String>();
            addressee.add(exp.OwnerId);
           
            try {
                notification.send(addressee);
            }
            catch (Exception e) {
                System.debug('Problem sending notification: ' + e.getMessage());
            }
            exp.RejectCheck__c = true;
        }
        
    }
  
        
    }else{
         /*for(Expense__c exp : Trigger.new){
            CustomNotificationType notificationType = [SELECT Id, DeveloperName
                                                       FROM CustomNotificationType
                                                       WHERE DeveloperName='Expense_Approval_Notification'];
            
            Messaging.CustomNotification notification = new Messaging.CustomNotification();
          
            notification.setTitle('Upload Bills');
            notification.setBody('Please Upload bills before submitting Approval ');
          
            notification.setNotificationTypeId(notificationType.Id);
            notification.setTargetId(exp.Id);
            
            Set<String> addressee = new Set<String>();
            addressee.add(exp.OwnerId);
           
            try {
                notification.send(addressee);
            }
            catch (Exception e) {
                System.debug('Problem sending notification: ' + e.getMessage());
            }
           
        }*/
  
    }
   
}