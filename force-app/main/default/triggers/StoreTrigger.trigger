trigger StoreTrigger on Account (before insert,before update) {
    if(Trigger.isinsert){
        for(Account acc: Trigger.new)
    {
        if(acc.EId__c ==null){
        Datetime x =  Datetime.now();
        string userid = UserInfo.getUserId();
        String format = userid.mid(10, 8);
        acc.EId__c = 'S'+format+x.year()+x.month()+x.day()+x.millisecond()+'S';
    }
    }
        
    }else{
        for(Account acc: Trigger.new)
        if(acc.Approval_Status__c == 'Approved' && acc.ApprovalChek__c == false){
           
            CustomNotificationType notificationType = [SELECT Id, DeveloperName
                                                       FROM CustomNotificationType
                                                       WHERE DeveloperName='StoreApprovalNotification'];
            
            Messaging.CustomNotification notification = new Messaging.CustomNotification();
          
            notification.setTitle('Store Approved');
            notification.setBody(acc.Name+' Store is Approved');
          
            notification.setNotificationTypeId(notificationType.Id);
            notification.setTargetId(acc.Id);
            
            Set<String> addressee = new Set<String>();
            addressee.add(acc.OwnerId);
           
            try {
                notification.send(addressee);
            }
            catch (Exception e) {
                System.debug('Problem sending notification: ' + e.getMessage());
            }
            acc.ApprovalChek__c = true;
            //expLIst.add(exp);
        }else if(acc.Approval_Status__c == 'Rejected' && acc.RejectCheck__c == false){
             CustomNotificationType notificationType = [SELECT Id, DeveloperName
                                                       FROM CustomNotificationType
                                                       WHERE DeveloperName='StoreApprovalNotification'];
            
            Messaging.CustomNotification notification = new Messaging.CustomNotification();
          
            notification.setTitle('Store Rejected');
            notification.setBody(acc.Name+' Store is Rejected');
            notification.setNotificationTypeId(notificationType.Id);
            notification.setTargetId(acc.Id);
            Set<String> addressee = new Set<String>();
            addressee.add(acc.OwnerId);
           
            try {
                notification.send(addressee);
            }
            catch (Exception e) {
                System.debug('Problem sending notification: ' + e.getMessage());
            }
            acc.RejectCheck__c = true;
        }
        
    }
        
    }