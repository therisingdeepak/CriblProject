

/**
 * @file MondayTaskController.cls
 * @brief This class provides methods to interact with Monday_Task__c records and Monday_Board__mdt metadata.
 * 
 * This controller includes methods to:
 * - Fetch the last 20 Monday_Task__c records.
 * - Retrieve the Board ID from Monday_Board__mdt.
 * - Refresh Monday_Task__c data by calling an external service.
 * 
 * @class MondayTaskController
 * @note This class is marked with 'with sharing' to enforce the sharing rules.
 */
public with sharing class MondayTaskController {
    
    // Fetch the last 20 Monday_Task__c records
    @AuraEnabled(cacheable=true)
    public static List<Monday_Task__c> getLast20Tasks() {
        return [SELECT Board_id__c, Task_Name__c, Monday_Task_Id__c, Status__c 
                FROM Monday_Task__c 
                ORDER BY CreatedDate DESC 
                LIMIT 20];
    }

    // Fetch the Board ID from Monday_Board__mdt
    @AuraEnabled(cacheable=true)
    public static String getBoardId() {
        Monday_Board__mdt config = [SELECT Board__c FROM Monday_Board__mdt LIMIT 1];
        return config.Board__c;
    }

    // Call MondayService to refresh Monday_Task__c data
    @AuraEnabled
    public static void refreshMondayTasks(String boardId) {
        MondayService.syncTasksFromMonday(boardId);
    }
}