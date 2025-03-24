@IsTest(isParallel = true)
private class AsyncTaskTest {
    @IsTest
    private static void testNewTask() {
        AsyncTask.Configuration conf = new AsyncTask.Configuration(
            'test',
            AsyncTaskTest.DummyHandler.class,
            new Account()
        );
        Id taskId = AsyncTask.newTask(conf);
        System.assert(taskId != null, 'newTask returned a null task Id');

        AsyncTask__c task = [SELECT Id FROM AsyncTask__c WHERE ID = :taskId];
        System.assert(
            task != null,
            'task with id ' +
            taskId +
            ' could not be found inthe db'
        );
    }

    @IsTest
    private static void testNewTasks() {
        AsyncTask.Configuration conf1 = new AsyncTask.Configuration(
            'test1',
            AsyncTaskTest.DummyHandler.class,
            new Account()
        );
        AsyncTask.Configuration conf2 = new AsyncTask.Configuration(
            'test2',
            AsyncTaskTest.DummyHandler.class,
            new Account()
        );
        AsyncTask.newTasks(new List<AsyncTask.Configuration>{conf1, conf2});

        List<AsyncTask__c> tasks = [SELECT Id FROM AsyncTask__c];
        System.assertEquals(
            2,
            tasks.size(),
            'expected 2 tasks in the database, got: ' + tasks.size()
        );
    }

    @SuppressWarnings('PMD.ApexDoc')
    private class DummyHandler implements AsyncTaskHandler {
        public AsyncResult execute(AsyncTaskInfo info, Object payload) {
            return null;
        }
        public Boolean isRetryable(AsyncTaskInfo info, AsyncResult result) {
            return false;
        }
        public Boolean isRetryable(AsyncTaskInfo info, Exception e) {
            return false;
        }
        public System.Type getPayloadType() {
            return Account.class;
        }
    }
}
