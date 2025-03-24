@IsTest(isParallel=true)
@SuppressWarnings('PMD.ExcessivePublicCount')
private class AsyncTaskRunnerTest {
    private static String SUCESS_MESSAGE = 'Success';
    private static String ERROR_MESSAGE = 'An error occurred';

    @IsTest
    private static void testRun() {
        AsyncTask.Configuration conf = new AsyncTask.Configuration('test', MockTaskHandler.class);
        String taskId = AsyncTask.newTask(conf);

        AsyncTaskRunner runner = new AsyncTaskRunner();
        runner.run(taskId);
        AsyncTask__c task = [
            SELECT
                Id,
                ExecutionCount__c,
                IsCompleted__c,
                IsFailure__c,
                IsSuccess__c,
                LastErrorMessage__c,
                LastSuccessMessage__c
            FROM AsyncTask__c
            WHERE Id = :taskId
        ];
        System.assert(task != null, 'could not find task in database');
        System.assertEquals(1, task.ExecutionCount__c, 'The task should have been executed once.');
        System.assert(task.IsCompleted__c, 'the task should have been marked as completed');
        System.assertEquals(null, task.LastErrorMessage__c, 'the task should not have an error message');
        System.assert(!task.IsFailure__c, 'the task should not have been marked as failed');
        System.assert(task.IsSuccess__c, 'the task should have been marked as successful');
    }

    @IsTest
    private static void testTaskNotFound() {
        AsyncTaskRunner runner = new AsyncTaskRunner();
        try {
            runner.run('bogus');
            System.assert(false, 'should have thrown a TaskNotFoundException');
        } catch (AsynctaskRunner.TaskNotFoundException e) {
            System.assert(e != null, 'exception should not be null');
        }
    }

    @IsTest
    private static void testTaskAlreadyCompleted() {
        AsyncTask.Configuration conf = new AsyncTask.Configuration('test', MockFailingTaskHandler.class);
        String taskId = AsyncTask.newTask(conf);
        AsyncTask__c task = [SELECT Id, HandlerClassName__c FROM AsyncTask__c WHERE Id = :taskId];
        task.IsCompleted__c = true;
        update task;

        AsyncTaskRunner runner = new AsyncTaskRunner();
        try {
            runner.run(taskId);
            System.assert(false, 'should have thrown a TaskAlreadyCompletedException');
        } catch (AsynctaskRunner.TaskAlreadyCompletedException e) {
            System.assert(e != null, 'exception should not be null');
        }
    }

    @IsTest
    private static void testWithNullTaskId() {
        AsyncTaskRunner runner = new AsyncTaskRunner();
        try {
            runner.run(null);
            System.assert(false, 'should have thrown a TaskNotFoundException');
        } catch (AsynctaskRunner.TaskNotFoundException e) {
            System.assert(e != null, 'exception should not be null');
        }
    }

    @IsTest
    private static void testInitException() {
        AsyncTask.Configuration conf = new AsyncTask.Configuration('test', MockFailingTaskHandler.class);
        String taskId = AsyncTask.newTask(conf);
        AsyncTask__c task = [SELECT Id, HandlerClassName__c FROM AsyncTask__c WHERE Id = :taskId];
        task.HandlerClassName__c = 'bogus';
        update task;

        AsyncTaskRunner runner = new AsyncTaskRunner();
        runner.run(taskId);

        AsyncTask__c updatedTask = [SELECT Id, IsFailure__c, IsCompleted__c FROM AsyncTask__c WHERE Id = :taskId];
        System.assert(updatedTask.IsFailure__c, 'task should have been marked as failed');
        System.assert(updatedTask.IsCompleted__c, 'task should have been marked as completed');
    }

    @IsTest
    private static void testRunFailingTask() {
        AsyncTask.Configuration conf = new AsyncTask.Configuration('test', MockFailingTaskHandler.class);

        String taskId = AsyncTask.newTask(conf);

        Test.startTest();
        AsyncTaskRunner runner = new AsyncTaskRunner();
        runner.run(taskId);
        Test.stopTest();

        AsyncTask__c task = [
            SELECT
                Id,
                ExecutionCount__c,
                IsCompleted__c,
                IsFailure__c,
                IsSuccess__c,
                LastErrorMessage__c,
                LastSuccessMessage__c
            FROM AsyncTask__c
            WHERE Id = :taskId
        ];
        System.assert(task != null, 'could not find task in database');
        System.assertEquals(1, task.ExecutionCount__c, 'the task should have been marked as executed');
        System.assert(task.IsCompleted__c, 'the task should have been marked as complteted');
        System.assert(task.IsFailure__c, 'the task should have been marked as failure');
        System.assert(!task.IsSuccess__c, 'the task should not have been marked as successful');
        System.assertEquals(ERROR_MESSAGE, task.LastErrorMessage__c, 'the task should have an error message');
        System.assertEquals(null, task.LastSuccessMessage__c, 'the task should not have a success message');
    }

    @IsTest
    private static void testRunSuccessTask() {
        String payload = '{payload}';
        AsyncTask.Configuration conf = new AsyncTask.Configuration(
            'test',
            MockTaskHandlerWithPayloadType.class,
            payload
        );

        String taskId = AsyncTask.newTask(conf);

        Test.startTest();
        AsyncTaskRunner runner = new AsyncTaskRunner();
        runner.run(taskId);
        Test.stopTest();

        AsyncTask__c task = [
            SELECT
                Id,
                ExecutionCount__c,
                IsCompleted__c,
                IsFailure__c,
                IsSuccess__c,
                LastErrorMessage__c,
                LastSuccessMessage__c
            FROM AsyncTask__c
            WHERE Id = :taskId
        ];
        System.assert(task != null, 'could not find task in database');
        System.assertEquals(1, task.ExecutionCount__c, 'the task should have been marked as executed');
        System.assert(task.IsCompleted__c, 'the task should have been marked as complteted');
        System.assert(!task.IsFailure__c, 'the task should not have been marked as failure');
        System.assert(task.IsSuccess__c, 'the task should have been marked as successful');
        System.assertEquals(null, task.LastErrorMessage__c, 'the task should not have an error message');
        System.assertEquals(SUCESS_MESSAGE, task.LastSuccessMessage__c, 'the task should have a success message');
    }

    @IsTest
    private static void testMissingPayload() {
        String payload = null;
        AsyncTask.Configuration conf = new AsyncTask.Configuration(
            'test',
            MockTaskHandlerWithPayloadType.class,
            payload
        );

        String taskId = AsyncTask.newTask(conf);
        AsyncTaskRunner runner = new AsyncTaskRunner();
        runner.run(taskId);

        AsyncTask__c updatedTask = [SELECT Id, IsFailure__c, IsCompleted__c FROM AsyncTask__c WHERE Id = :taskId];
        System.assert(updatedTask.IsFailure__c, 'task should have been marked as failed');
        System.assert(updatedTask.IsCompleted__c, 'task should have been marked as completed');
    }

    @IsTest
    private static void testRunRetryableFailingTask() {
        AsyncTask.Configuration conf = new AsyncTask.Configuration('test', MockRetryableTaskHandler.class);
        String taskId = AsyncTask.newTask(conf);

        AsyncTaskRunner runner = new AsyncTaskRunner();
        runner.run(taskId);

        AsyncTask__c task = [
            SELECT Id, ExecutionCount__c, IsCompleted__c, IsFailure__c, IsSuccess__c
            FROM AsyncTask__c
            WHERE Id = :taskId
        ];
        System.assert(task != null, 'could not find task in database');
        System.assertEquals(1, task.ExecutionCount__c, 'the task should have been marked as executed');
        System.assert(!task.IsCompleted__c, 'the task should not have been marked as completed');
        System.assert(task.IsFailure__c, 'the task should be marked as failure');
        System.assert(!task.IsSuccess__c, 'the task should not have been markd successful');
    }

    @IsTest
    private static void testRunFailingTaskWithException() {
        AsyncTask.Configuration conf = new AsyncTask.Configuration('test', MockExceptionTaskHandler.class);
        String taskId = AsyncTask.newTask(conf);

        AsyncTaskRunner runner = new AsyncTaskRunner();
        runner.run(taskId);

        AsyncTask__c task = [
            SELECT Id, ExecutionCount__c, IsCompleted__c, IsFailure__c, IsSuccess__c
            FROM AsyncTask__c
            WHERE Id = :taskId
        ];
        System.assert(task != null, 'could not find task in database');
        System.assertEquals(1, task.ExecutionCount__c, 'the task should have been marked as executed');
        System.assert(task.IsCompleted__c, 'the task should have been marked as completed');
        System.assert(task.IsFailure__c, 'the task should have been marked as failure');
        System.assert(!task.IsSuccess__c, 'the task should not be marked as successful');
    }

    /**
     * @description mock task handler
     */
    @SuppressWarnings('PMD.ApexDoc')
    public class MockTaskHandler implements AsyncTaskHandler {
        private final Logger logger = LoggerFactory.getLogger(MockTaskHandler.class);
        public AsyncResult execute(AsyncTaskInfo info, Object payload) {
            logger.info('taskStarted');
            AsyncResult result = AsyncResult.success(SUCESS_MESSAGE, 'plop');
            logger.info('taskCompleted');
            return result;
        }
        public boolean isRetryable(AsyncTaskInfo info, AsyncResult result) {
            return false;
        }
        public boolean isRetryable(AsyncTaskInfo info, Exception ex) {
            return false;
        }
        public System.Type getPayloadType() {
            return null;
        }
    }

    /**
     * @description mock task which always returns a failure
     */
    @SuppressWarnings('PMD.ApexDoc')
    public class MockFailingTaskHandler implements AsyncTaskHandler {
        public AsyncResult execute(AsyncTaskInfo info, Object payload) {
            return AsyncResult.failure(ERROR_MESSAGE);
        }
        public boolean isRetryable(AsyncTaskInfo info, AsyncResult result) {
            return false;
        }
        public boolean isRetryable(AsyncTaskInfo info, Exception ex) {
            return false;
        }
        public System.Type getPayloadType() {
            return null;
        }
    }

    /**
     * @description mock task handler which is retryable
     */
    @SuppressWarnings('PMD.ApexDoc')
    public class MockRetryableTaskHandler implements AsyncTaskHandler {
        public AsyncResult execute(AsyncTaskInfo info, Object payload) {
            return AsyncResult.failure(ERROR_MESSAGE);
        }
        public boolean isRetryable(AsyncTaskInfo info, AsyncResult result) {
            return true;
        }
        public boolean isRetryable(AsyncTaskInfo info, Exception ex) {
            return true;
        }
        public System.Type getPayloadType() {
            return null;
        }
    }

    /**
     * @description mock handler which always throws an exception
     */
    @SuppressWarnings('PMD.ApexDoc')
    public class MockExceptionTaskHandler implements AsyncTaskHandler {
        public AsyncResult execute(AsyncTaskInfo info, Object payload) {
            throw new CustomException();
        }
        public boolean isRetryable(AsyncTaskInfo info, AsyncResult result) {
            return false;
        }
        public boolean isRetryable(AsyncTaskInfo info, Exception ex) {
            return false;
        }
        public System.Type getPayloadType() {
            return null;
        }
    }

    /**
     * @description mock handler with expected payload
     */
    @SuppressWarnings('PMD.ApexDoc')
    public class MockTaskHandlerWithPayloadType implements AsyncTaskHandler {
        public AsyncResult execute(AsyncTaskInfo info, Object payload) {
            return AsyncResult.success(SUCESS_MESSAGE, payload);
        }
        public boolean isRetryable(AsyncTaskInfo info, AsyncResult result) {
            return false;
        }
        public boolean isRetryable(AsyncTaskInfo info, Exception ex) {
            return false;
        }
        public System.Type getPayloadType() {
            return String.class;
        }
    }

    /**
     * @description custom exception for testing only
     */
    private class CustomException extends Exception {
    }
}
