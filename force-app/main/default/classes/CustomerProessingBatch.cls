//Batch Job for Processing the Records
global class CustomerProessingBatch implements Database.Batchable<sobject>{
  global String [] email = new String[] {'info@mytutorialrack.com'};//Add here your email address here
  
  //Start Method
  global Database.Querylocator start (Database.BatchableContext BC) {
    return Database.getQueryLocator('Select id, Name, APEX_Customer_Status__c, APEX_Customer_Description__c From APEX_Customer__c WHERE  APEX_Active__c = true');//Query which will be determine the scope of Records fetching the same
  }

  //Execute method
  global void execute (Database.BatchableContext BC, List<sobject> scope) {
    List<apex_customer__c> updatedCustomerList = new List<apex_customer__c>();//List to hold updated customer
    for (sObject objScope: scope) { 
        APEX_Customer__c newObjScope = (APEX_Customer__c)objScope ;//type casting from generic sOject to APEX_Customer__c
        newObjScope.APEX_Customer_Description__c = 'Updated Via Batch Job';
        newObjScope.APEX_Customer_Status__c = 'Paid';
        updatedCustomerList.add(newObjScope);//Add records to the List
        System.debug('Records updated '+updatedCustomerList);
    } 
        if (updatedCustomerList != null && updatedCustomerList.size()>0) {//Check if List is empty or not
            Database.update(updatedCustomerList); 
            System.debug('Records are successfully updated '+updatedCustomerList);//Update the Records
        }
  }

  //Finish Method
  global void finish(Database.BatchableContext BC){
  Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

  //Below code will fetch the job Id
  AsyncApexJob a = [Select a.TotalJobItems, a.Status, a.NumberOfErrors, a.JobType, a.JobItemsProcessed, a.ExtendedStatus, a.CreatedById, a.CompletedDate From AsyncApexJob a WHERE id = :BC.getJobId()];//get the job Id
  System.debug('Jobid is'+BC.getJobId());

  //below code will send an email to User about the status
  mail.setToAddresses(email);
  mail.setReplyTo('test@test.com');//Add here your email address
  mail.setSenderDisplayName('Apex Batch Processing Module');
  mail.setSubject('Batch Processing '+a.Status);
  mail.setPlainTextBody('The Batch Apex job processed  '+a.TotalJobItems+'batches with  '+a.NumberOfErrors+'failures'+'Job Item processed are'+a.JobItemsProcessed);
  Messaging.sendEmail(new Messaging.Singleemailmessage [] {mail});
  }
}