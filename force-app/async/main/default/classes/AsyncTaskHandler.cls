/**
 * @description all task handlers must implement the AsyncTaskHandler interface
 */
public interface AsyncTaskHandler {
    /**
     * @description this method is called by the asynctaskrunner
     * when executing the task. This method needs to return an AsyncResult
     * to indicate success or failure, or throw an exception.
     *
     * @param info information about the current task execution
     * @param payload the deserialized task payload.
     * @return AsyncResult the result of the task execution
     */
    AsyncResult execute(AsyncTaskInfo info, Object payload);

    /**
     * @description indicates if the task is retryable (if the execution was a failure)
     * The AsyncResult returned by execute() is passed to this method to provide
     * more information about the failure.
     *
     * @param info information about the current task execution
     * @param result the result from execute()
     * @return true if the task is retryable, false otherwise
     */
    Boolean isRetryable(AsyncTaskInfo info, AsyncResult result);

    /**
     * @description indicates if the task is retryable (if the execution threw an exception)
     * The Exception throwned by execute() is passed to this method to provide
     * more information about the failure.
     *
     * @param info information about the current task execution
     * @param e the exception thrown by execute()
     * @return true if the task is retryable, false otherwise
     */
    Boolean isRetryable(AsynctaskInfo info, Exception e);

    /**
     * @description returns the payload type for this task.
     * @return the payload task or null if no payload is required.
     */
    System.Type getPayloadType();
}
