
/**
 * @file MondayTaskHelper.cls
 * @description This class provides helper methods to handle after insert, update, and delete events for Monday_Task__c records.
 * It publishes platform events to notify other systems of changes to Monday_Task__c records.
 * 
 * @class MondayTaskHelper
 * @version 1.0
 * @date 2023-10-05
 * 
 * @method handleAfterInsert
 * @description Handles after insert events for Monday_Task__c records. Publishes a platform event for each new record.
 * @param {List<SObject>} newRecords - List of newly inserted Monday_Task__c records.
 * 
 * @method handleAfterUpdate
 * @description Handles after update events for Monday_Task__c records. Publishes a platform event for each updated record if the status has changed.
 * @param {List<SObject>} newRecords - List of updated Monday_Task__c records.
 * @param {Map<Id, SObject>} oldMap - Map of old Monday_Task__c records keyed by their Ids.
 * 
 * @method handleAfterDelete
 * @description Handles after delete events for Monday_Task__c records. Publishes a platform event for each deleted record.
 * @param {Map<Id, SObject>} oldMap - Map of deleted Monday_Task__c records keyed by their Ids.
 */
public with sharing class MondayTaskHelper {
    public MondayTaskHelper() {}
    
    public static void handleAfterInsert(List<SObject> newRecords) {
        List<Monday_Task_Event__e> events = new List<Monday_Task_Event__e>();
        for (SObject record : newRecords) {
            Monday_Task__c task = (Monday_Task__c) record;
            if(task.Monday_Task_Id__c == null) {
                events.add(new Monday_Task_Event__e(
                Action__c = 'Create',
                Record_Id__c = task.Id,
                Board_Id__c = task.Board_Id__c,
                Task_Name__c = task.Task_Name__c,
                Status__c = task.Status__c
            ));
            }
            
        }
        EventBus.publish(events);
    }
    
    public static void handleAfterUpdate(List<SObject> newRecords, Map<Id, SObject> oldMap) {
        List<Monday_Task_Event__e> events = new List<Monday_Task_Event__e>();
        for (SObject record : newRecords) {
            Monday_Task__c task = (Monday_Task__c) record;
            Monday_Task__c oldTask = (Monday_Task__c) oldMap.get(task.Id);
            if (task.Status__c != oldTask.Status__c) {
                events.add(new Monday_Task_Event__e(
                    Board_Id__c = task.Board_Id__c,
                    Action__c = 'Update',
                    Record_Id__c = task.Id,
                    Monday_Task_Id__c = task.Monday_Task_Id__c,
                    Status__c = task.Status__c
                ));
            }
        }
        EventBus.publish(events);

    }
    
    public static void handleAfterDelete(Map<Id, SObject> oldMap) {
        List<Monday_Task_Event__e> events = new List<Monday_Task_Event__e>();
        for (SObject record : oldMap.values()) {
            Monday_Task__c task = (Monday_Task__c) record;
            events.add(new Monday_Task_Event__e(
                Board_Id__c = task.Board_Id__c,
                Action__c = 'Delete',
                Record_Id__c = task.Id,
                Monday_Task_Id__c = task.Monday_Task_Id__c
            ));
        }
        EventBus.publish(events);
    }
}



