/**
 * @description AsyncResult represents the outcome of the execution
 * of an async task.
 */
public class AsyncResult {
    /**
     * @description isSuccess returns true if the execution was successful, false otherwise
     */
    public Boolean isSuccess { get; set; }

    /**
     * @description successMessage holds an success message for the last execution
     * of the async task.
     */
    public String successMessage { get; set; }

    /**
     * @description errorMessage holds an error message for the last execution
     * of the async task.
     */
    public String errorMessage { get; set; }

    /**
     * @description data holds extra information about the execution of the task.
     * It is useful to pass extra information to the isRetryable()
     * function of the AsyncTaskHandler.
     */
    public Object data { get; set; }

    /**
     * @description constructor.
     *
     * @param success true if the execution was successful, false otherwise
     */
    public AsyncResult(Boolean success) {
        this.isSuccess = success;
    }

    /**
     * @description contructor.
     *
     * @param success true if the execution was successful, false otherwise
     * @param msg error or success message
     */
    public AsyncResult(Boolean success, String msg) {
        this.isSuccess = success;
        setMessage(success, msg);
    }

    /**
     * @description constructor.
     *
     * @param success true if the execution was successful, false otherwise
     * @param msg error or success message
     * @param data extra information about the previous execution
     */
    public AsyncResult(Boolean success, String msg, Object data) {
        this.isSuccess = success;
        this.data = data;
        setMessage(success, msg);
    }

    /**
     * @description returns a new 'successful' AsyncResult
     * @return a new 'successful' AsyncResult
     */
    public static AsyncResult success() {
        return new AsyncResult(true);
    }

    /**
     * @description returns a new 'successful' AsyncResult
     * @param msg error or success message
     * @param data extra information about the previous execution
     * @return a new 'successful' AsyncResult
     */
    public static AsyncResult success(String msg, Object data) {
        return new AsyncResult(true, msg, data);
    }

    /**
     * @description returns a new 'successful' AsyncResult
     * @param data extra information about the previous execution
     * @return a new 'successful' AsyncResult
     */
    public static AsyncResult success(Object data) {
        return new AsyncResult(true, null, data);
    }

    /**
     * @description Returns a new 'failed' AsyncResult with an empty message
     * @return a new 'failed' AsyncResult with an empty message
     */
    public static AsyncResult failure() {
        return new AsyncResult(false);
    }

    /**
     * @description Returns a new 'failed' AsyncResult with the provided message
     *
     * @param message the failure message
     * @return a new 'failed' AsyncResult with the provided message
     */
    public static AsyncResult failure(String message) {
        return new AsyncResult(false, message);
    }

    /**
     * @description Setting the success or error message.
     *
     * @param success true if the execution was successful, false otherwise
     * @param msg error or success message
     */
    private void setMessage(Boolean success, String msg) {
        if (success) {
            this.successMessage = msg;
        } else {
            this.errorMessage = msg;
        }
    }
}
