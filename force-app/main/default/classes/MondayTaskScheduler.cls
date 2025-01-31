
/**
 * The MondayTaskScheduler class implements the Schedulable interface to schedule a batch job.
 * This class is designed to enqueue a batch job of type MondayTaskBatch when the scheduled 
 * job is executed.
 * 
 * Usage:
 * This class can be scheduled to run at a specific time using the System.schedule method.
 * 
 * Example:
 * String cronExp = '0 0 12 ? * MON *'; // Every Monday at 12 PM
 * System.schedule('Monday Task Scheduler', cronExp, new MondayTaskScheduler());
 * 
 * Note:
 * Ensure that the MondayTaskBatch class is defined and implements the Database.Batchable interface.
 * 
 * @see Schedulable
 * @see System#schedule(String, String, Schedulable)
 * @see System#enqueueJob(Queueable)
 */
global class MondayTaskScheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
        System.enqueueJob(new MondayTaskBatch());
    }
}