
/// <summary>
/// Trigger that handles after insert events for Monday_Task_Event__e objects.
/// </summary>
/// <remarks>
/// This trigger is executed after a new Monday_Task_Event__e record is inserted.
/// It retrieves the list of new events and processes them using the MondayTaskEventHelper.
/// </remarks>
trigger MondayTaskEventTrigger on Monday_Task_Event__e (after insert) {
    List<Monday_Task_Event__e> events = Trigger.new;
    MondayTaskEventHelper.processTaskEvents(events);
}