/**
 * The MondayService class provides methods to interact with the Monday.com API.
 * It allows creating, fetching, updating, and deleting tasks on a Monday.com board.
 * 
 * Methods:
 * - createTask(String boardId, String taskName, String status): Creates a new task on the specified board with the given name and status.
 * - fetchTasks(String boardId): Fetches all tasks from the specified board.
 * - updateTask(String itemId, String status): Updates the status of the specified task.
 * - deleteTask(String itemId): Deletes the specified task.
 * - callMondayAPI(String query): A helper method to send requests to the Monday.com API.
 * 
 * Constants:
 * - NAMED_CREDENTIAL: The named credential for the Monday.com API.
 *  */
//
public class MondayService {
    private static final String NAMED_CREDENTIAL = 'MondayAPI';

    // Create Task in Monday.com
    public static String createTask(String boardId, String taskName, String status) {         
         // Construct column values properly
        Map<String, Object> columnValues = new Map<String, Object>{
            'status' => new Map<String, Object>{ 'label' => status }
        };
        String columnValuesJson = JSON.serialize(columnValues);

        // Properly formatted GraphQL query
        String query = 'mutation{create_item (board_id:' + boardId + 
               ', item_name:"' + taskName + '") {id} }';
        // Prepare request body
        Map<String, Object> requestBody = new Map<String, Object>{
            'query' => query
        };
        String body = JSON.serialize(requestBody);
        String response = callMondayAPI(body);
        
        if (response != null) {
            Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(response);
            Map<String, Object> data = (Map<String, Object>) result.get('data');
            Map<String, Object> createItem = (Map<String, Object>) data.get('create_item');
            return (String) createItem.get('id');
        }
        return null;
    }

    // Fetch All Tasks from Monday.com Board
 public static List<Map<String, Object>> fetchTasks(String boardId) {
    // Construct the GraphQL query
    String query = 'query { boards(ids: ' + boardId + ') { items_page { cursor items { id name } } } }';

    // Prepare the request body
    Map<String, Object> requestBody = new Map<String, Object>{
        'query' => query
    };
    String body = JSON.serialize(requestBody);
    String response = callMondayAPI(body);

    if (response != null) {
        Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(response);
        Map<String, Object> data = (Map<String, Object>) result.get('data');

        // Correctly cast 'boards' as a List<Object> first
        List<Object> boards = (List<Object>) data.get('boards');

        if (!boards.isEmpty()) {
            // Since 'boards' contains a single map, safely cast it
            Map<String, Object> firstBoard = (Map<String, Object>) boards[0];

            // Extract 'items_page' correctly
            Map<String, Object> itemsPage = (Map<String, Object>) firstBoard.get('items_page');

            // Extract 'items' from 'items_page'
            List<Object> items = (List<Object>) itemsPage.get('items');

            // Convert List<Object> to List<Map<String, Object>>
            List<Map<String, Object>> taskList = new List<Map<String, Object>>();
            for (Object item : items) {
                taskList.add((Map<String, Object>) item);
            }

            return taskList;
        }
    }

    // Return an empty list if no tasks are found
    return new List<Map<String, Object>>();
}


public static void syncTasksFromMonday(String boardId) {
        List<Map<String, Object>> mondayTasks = fetchTasks(boardId);

        if (mondayTasks.isEmpty()) {
            System.debug('No tasks retrieved from Monday.com.');
            return;
        }

        // Fetch existing Monday tasks in Salesforce
        Map<String, Monday_Task__c> existingTasksMap = new Map<String, Monday_Task__c>();
        for (Monday_Task__c task : [SELECT Id, Monday_Task_id__c, Task_Name__c FROM Monday_Task__c WHERE Board_id__c = :boardId]) {
            existingTasksMap.put(task.Monday_Task_id__c, task);
        }

        List<Monday_Task__c> tasksToUpsert = new List<Monday_Task__c>();

        for (Map<String, Object> mondayTask : mondayTasks) {
            String taskId = String.valueOf(mondayTask.get('id'));
            String taskName = String.valueOf(mondayTask.get('name'));

            if (existingTasksMap.containsKey(taskId)) {
                // Update existing task if name has changed
                Monday_Task__c existingTask = existingTasksMap.get(taskId);
                if (existingTask.Task_Name__c != taskName) {
                    existingTask.Task_Name__c = taskName;
                    existingTask.Board_id__c = boardId;
                    existingTask.Monday_Task_id__c = taskId;
                    existingTask.Status__c = 'New';
                    tasksToUpsert.add(existingTask);
                }
            } else {
                // Create new task
                Monday_Task__c newTask = new Monday_Task__c(
                    Board_id__c = boardId,
                    Task_Name__c = taskName,
                    Monday_Task_id__c = taskId
                );
                tasksToUpsert.add(newTask);
            }
        }

        if (!tasksToUpsert.isEmpty()) {
            upsert tasksToUpsert Monday_Task_id__c;
            System.debug('Upserted ' + tasksToUpsert.size() + ' tasks.');
        } else {
            System.debug('No new or updated tasks to upsert.');
        }
    }

    // Update Task Status
    public static Boolean updateTask(String itemId, String status) {
        String query = 'mutation { change_column_value (board_id: 123456789, item_id: ' + itemId + ', column_id: "status", value: "{\\\"label\\\": \\\"' + status + '\\\"}") { id } }';
        String response = callMondayAPI(query);
        return response != null;
    }

    // Delete a Task
    public static Boolean deleteTask(String itemId) {
        String query = 'mutation { delete_item (item_id: ' + itemId + ') { id } }';
        String response = callMondayAPI(query);
        return response != null;
    }

    // Common method to call Monday.com API
    private static String callMondayAPI(String query) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:MondayAPI');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setBody(query);
        System.debug(request.getBody());
        try {
            HttpResponse response = http.send(request);
            if (response.getStatusCode() == 200) {
                return response.getBody();
            } else {
                System.debug('Error: ' + response.getStatusCode() + ' - ' + response.getBody());
            }
        } catch (Exception e) {
            System.debug('Exception: ' + e.getMessage());
        }
        return null;
    }
}