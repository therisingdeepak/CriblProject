
/**
 * Trigger: MondayTaskTrigger
 * 
 * This trigger is executed before insert, update, or delete operations on the Monday_Task__c object.
 * 
 * Events Handled:
 * - Before Insert: Calls MondayTaskHelper.handleBeforeInsert with the new records.
 * - Before Update: Calls MondayTaskHelper.handleBeforeUpdate with the new and old records.
 * - Before Delete: Calls MondayTaskHelper.handleBeforeDelete with the old records.
 * 
 * Helper Methods:
 * - MondayTaskHelper.handleBeforeInsert(List<Monday_Task__c> newRecords)
 * - MondayTaskHelper.handleBeforeUpdate(List<Monday_Task__c> newRecords, Map<Id, Monday_Task__c> oldMap)
 * - MondayTaskHelper.handleBeforeDelete(Map<Id, Monday_Task__c> oldMap)
 * 
 * Note: This trigger only handles before events.
 */
trigger MondayTaskTrigger on Monday_Task__c (after insert, after update, after delete) {
    if (Trigger.isafter) {
        if (Trigger.isInsert) {
            MondayTaskHelper.handleAfterInsert(Trigger.new);
        } else if (Trigger.isUpdate) {
            MondayTaskHelper.handleAfterUpdate(Trigger.new, Trigger.oldMap);
        } else if (Trigger.isDelete) {
            MondayTaskHelper.handleAfterDelete(Trigger.oldMap);
        }
    }
}