/**
 * @description AsyncProcessorBatch loads the async tasks from the database and
 * execute those tasks one by one. Once all the tasks have been executed the class
 * reschedule itself for the next run.
 */
public without sharing class AsyncProcessorBatch implements Database.Batchable<AsyncTask__c>, Database.AllowsCallouts {
    private static final Integer BATCH_SIZE = 1; // DO NOT CHANGE !! (otherwise you will get a 'You have uncommitted work pending. Please commit or rollback before calling out' error)
    private static final Integer DELAY_IN_MINUTES = 1;
    private static final String BATCH_NAME = AsyncProcessorBatch.class.getName();

    /** @description base exception type for this batch */
    public virtual class BatchProcessorException extends Exception {
    }
    /** @description exception raised when a batch processor is already running */
    public class BatchProcessorAlreadyRunningException extends BatchProcessorException {
    }

    /**
     * @description implementation of Batchable.start()
     *
     * @param ctx the batchable context
     * @return a list of invocable asynctasks
     */
    public Iterable<AsyncTask__c> start(Database.BatchableContext ctx) {
        return AsyncProcessorBatch.getInvokableTasks();
    }

    /**
     * @description runs all invocableTask
     *
     * @param bc the batchable context
     * @param scope the list of tasks to execute (retrieved in start())
     */
    public void execute(Database.BatchableContext bc, List<AsyncTask__c> scope) {
        for (AsyncTask__c task: scope) {
            new AsyncTaskRunner().run(task.Id);
        }
    }

    /**
     * @description schedule the next execution of the batch
     *
     * @param bc the batchable context
     */
    public void finish(Database.BatchableContext bc) {
        // is there anymore tasks in the queue ?
        List<AsyncTask__c> tasks = getInvokableTasks();

        if (tasks.isEmpty()) {
            // queue empty, let's pause for a moment.
            if (!Test.isRunningTest()) {
                System.scheduleBatch(
                    new AsyncProcessorBatch(),
                    BATCH_NAME,
                    DELAY_IN_MINUTES,
                    BATCH_SIZE
                );
            }
        } else {
            // schedule the next run, and give a chance to other async apex jobs to run
            Database.executeBatch(new AsyncProcessorBatch(), BATCH_SIZE);
        }
    }

    /**
     * @description helper method to start the batch.
     */
    public static void start() {
        // FIXME: make sure we only one instance is running in the org.
        System.scheduleBatch(
            new AsyncProcessorBatch(),
            BATCH_NAME,
            DELAY_IN_MINUTES,
            BATCH_SIZE
        );
    }

    /**
     * @description Returns all tasks that have not been completed.
     *
     * @return A list of all task objects have not been executed.
     */
    private static List<AsyncTask__c> getInvokableTasks() {
        DateTime now = DateTime.now();
        return [
            SELECT Id
            FROM AsyncTask__c
            WHERE IsCompleted__c = false
                AND OnHold__c = false
                AND (SkipUntil__c = NULL OR SkipUntil__c <= :now)
            ORDER BY Priority__c, CreatedDate DESC
        ];
    }
}