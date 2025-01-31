/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an org are executed whenever Apex code is deployed
 * to a production org to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production org. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the org size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
public class MondayTaskHelperTest {
    @testSetup
    static void setupTestData() {
        // Create test data to be used across multiple test methods
        Monday_Task__c task = new Monday_Task__c(
            Task_Name__c = 'Initial Task',
            Board_id__c = '123456',
            Monday_Task_id__c = 'MT-001'
        );
        insert task;
    }

    @isTest
    static void testAfterInsert() {
        Test.startTest();
        
        // Create a new Monday Task
        Monday_Task__c newTask = new Monday_Task__c(
            Task_Name__c = 'New Task',
            Board_id__c = '123456',
            Monday_Task_id__c = 'MT-002'
        );
        insert newTask;

        Test.stopTest();

        // Verify the task was inserted
        Monday_Task__c insertedTask = [SELECT Id, Task_Name__c FROM Monday_Task__c WHERE Id = :newTask.Id];
        System.assertEquals('New Task', insertedTask.Task_Name__c);
    }

    @isTest
    static void testAfterUpdate() {
        // Fetch existing test record
        Monday_Task__c existingTask = [SELECT Id, Task_Name__c FROM Monday_Task__c LIMIT 1];

        Test.startTest();
        
        // Update task name
        existingTask.Task_Name__c = 'Updated Task Name';
        update existingTask;

        Test.stopTest();

        // Verify the update
        Monday_Task__c updatedTask = [SELECT Id, Task_Name__c FROM Monday_Task__c WHERE Id = :existingTask.Id];
        System.assertEquals('Updated Task Name', updatedTask.Task_Name__c);
    }

    @isTest
    static void testAfterDelete() {
        // Fetch existing test record
        Monday_Task__c taskToDelete = [SELECT Id FROM Monday_Task__c LIMIT 1];

        Test.startTest();
        
        // Delete task
        delete taskToDelete;

        Test.stopTest();

        // Verify that the record was deleted
        Integer count = [SELECT COUNT() FROM Monday_Task__c WHERE Id = :taskToDelete.Id];
        System.assertEquals(0, count);
    }
}