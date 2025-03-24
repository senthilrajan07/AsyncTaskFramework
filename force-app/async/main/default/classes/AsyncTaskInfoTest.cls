@IsTest(isParallel=true)
private class AsyncTaskInfoTest {
    @IsTest
    private static void testConstructor() {
        AsyncTask__c task = new AsyncTask__c();
        task.Description__c = 'desc';
        task.ExecutionCount__c = 4;
        task.HandlerclassName__c = 'DummyClass';
        task.OnHold__c = true;
        insert task;

        AsyncTaskInfo info = new AsyncTaskInfo(task);
        System.assertEquals('desc', info.getDescription(), 'incorrect getDescription() value');
        System.assertEquals(task.CreatedDate, info.getCreatedDate(), 'incorrect getCreatedDate() value');
        System.assertEquals(4, info.getExecutionCount(), 'incorrect getExecutionCount() value');
        System.assertNotEquals(null, info.getTaskId(), 'taskId is null');
    }

    @IsTest
    private static void testOnHold() {
        AsyncTask__c task = new AsyncTask__c();
        AsyncTaskInfo info = new AsyncTaskInfo(task);
        System.assertEquals(false, info.isOnHold(), 'incorrect isOnHold() value');
        info.setOnHold(true);
        System.assert(info.isOnHold(), 'incorrect isOnHold() value');
    }

    @IsTest
    private static void testSkipUntil() {
        AsyncTask__c task = new AsyncTask__c();
        AsyncTaskInfo info = new AsyncTaskInfo(task);
        System.assertEquals(null, info.getSkipUntil(), 'incorrect skipUntil() value');
        DateTime now = DateTime.now();
        info.setSkipUntil(now);
        System.assertEquals(now, info.getSkipUntil(), 'incorrect skipUntil() value');
    }

    @IsTest
    private static void testPriority() {
        AsyncTask__c task = new AsyncTask__c();
        AsyncTaskInfo info = new AsyncTaskInfo(task);
        System.assertEquals(0, info.getPriority(), 'incorrect getPriority() value');
        info.setPriority(100);
        System.assertEquals(100, info.getPriority(), 'incorrect getPriority() value');
    }
}
