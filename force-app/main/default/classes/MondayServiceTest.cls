@isTest
/**
 * The MondayServiceTest class tests the MondayService class.
 * It ensures that task creation, fetching, updating, and deletion work correctly
 * using mock HTTP responses to avoid actual API calls.
 */
public class MondayServiceTest {
    
    // Test Setup: Mock HTTP Callout Response
    private class MockHttpResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            
            // Handle different API calls
            if (req.getBody().contains('create_item')) {
                res.setBody('{"data": {"create_item": {"id": "1001"}}}');
            } else if (req.getBody().contains('boards')) {
                res.setBody('{"data": {"boards": [{"items_page": {"cursor": "nextPage", "items": [{"id": "1001", "name": "Test Task"}]}}]}}');
            } else if (req.getBody().contains('change_column_value')) {
                res.setBody('{"data": {"change_column_value": {"id": "1001"}}}');
            } else if (req.getBody().contains('delete_item')) {
                res.setBody('{"data": {"delete_item": {"id": "1001"}}}');
            } else {
                res.setStatusCode(400);
                res.setBody('{"error": "Invalid request"}');
            }
            
            return res;
        }
    }

    @testSetup
    static void setupTestData() {
        Monday_Task__c task = new Monday_Task__c(
            Board_id__c = '8349247067',
            Task_Name__c = 'Sample Task',
            Monday_Task_id__c = '1001'
        );
        insert task;
    }

    @isTest
    static void testCreateTask() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());

        String taskId = MondayService.createTask('8349247067', 'New Task', 'In Progress');
        
        Test.stopTest();
        
        System.assertNotEquals(taskId, null, 'Task ID should not be null');
        System.assertEquals(taskId, '1001', 'Task ID should match mock response');
    }

    @isTest
    static void testFetchTasks() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());

        List<Map<String, Object>> tasks = MondayService.fetchTasks('8349247067');

        Test.stopTest();
        
        System.assert(tasks.size() > 0, 'Tasks list should not be empty');
        System.assertEquals(tasks[0].get('id'), '1001', 'Fetched task ID should match mock response');
    }

    @isTest
    static void testSyncTasksFromMonday() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());

        MondayService.syncTasksFromMonday('8349247067');

        Test.stopTest();

        Monday_Task__c task = [SELECT Monday_Task_id__c FROM Monday_Task__c WHERE Monday_Task_id__c = '1001' LIMIT 1];
        System.assertNotEquals(task, null, 'Task should exist in Salesforce');
    }

    @isTest
    static void testUpdateTask() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());

        Boolean success = MondayService.updateTask('1001', 'Done');

        Test.stopTest();
        
        System.assert(success, 'Task update should be successful');
    }

    @isTest
    static void testDeleteTask() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());

        Boolean success = MondayService.deleteTask('1001');

        Test.stopTest();
        
        System.assert(success, 'Task deletion should be successful');
    }
}