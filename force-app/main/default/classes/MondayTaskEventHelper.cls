
/**
 * @file MondayTaskEventHelper.cls
 * @description This class handles the processing of task events from Monday.com. It supports creating, updating, and deleting tasks asynchronously.
 * 
 * @class MondayTaskEventHelper
 * @public
 * @withSharing
 * 
 * @method processTaskEvents(List<Monday_Task_Event__e> events) - Processes a list of task events and calls the appropriate method based on the action type.
 * @method createMondayTaskAsync(Id recordId, String boardId, String taskName, String status) - Asynchronously creates a task on Monday.com and updates the corresponding Salesforce record with the Monday task ID.
 * @method updateMondayTaskAsync(String mondayId, String status) - Asynchronously updates the status of a task on Monday.com.
 * @method deleteMondayTaskAsync(String mondayId) - Asynchronously deletes a task on Monday.com.
 * 
 * @future(callout=true) - Indicates that the method is executed asynchronously and allows callouts to external services.
 */
public with sharing class MondayTaskEventHelper {
    
    public static void processTaskEvents(List<Monday_Task_Event__e> events) {
        for (Monday_Task_Event__e event : events) {
            if (event.Action__c == 'Create') {
                createMondayTaskAsync(event.Record_Id__c, event.Board_Id__c, event.Task_Name__c, event.Status__c);
            } else if (event.Action__c == 'Update') {
                updateMondayTaskAsync(event.Monday_Task_Id__c, event.Status__c);
            } else if (event.Action__c == 'Delete') {
                deleteMondayTaskAsync(event.Monday_Task_Id__c);
            }
        }
    }
    
    @future(callout=true)
    public static void createMondayTaskAsync(Id recordId, String boardId, String taskName, String status) {
        String mondayTaskId = MondayService.createTask(boardId, taskName, status);
        if (mondayTaskId != null) {
            Monday_Task__c task = [SELECT Id FROM Monday_Task__c WHERE Id = :recordId LIMIT 1];
            task.Monday_Task_Id__c = mondayTaskId;
            update task;
        }
    }

    @future(callout=true)
    public static void updateMondayTaskAsync(String mondayId, String status) {
        if (mondayId != null) {
            MondayService.updateTask(mondayId, status);
        }
    }

    @future(callout=true)
    public static void deleteMondayTaskAsync(String mondayId) {
        if (mondayId != null) {
            MondayService.deleteTask(mondayId);
        }
    }
}