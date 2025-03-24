@IsTest(isParallel=true)
private class AsyncResultTest {
    @IsTest
    private static void testFailureConstructor() {
        AsyncResult result = AsyncResult.failure();
        System.assert(!result.isSuccess, 'expected isSuccess() to be false, got ' + result.isSuccess);
        System.assert(
            String.isBlank(result.errorMessage),
            'expected errorMessage to be blank, got " ' +
            result.errorMessage +
            '"'
        );
    }

    @IsTest
    private static void testFailureWithMessageConstructor() {
        String errMsg = 'there was a failure';
        AsyncResult result = AsyncResult.failure(errMsg);
        System.assert(!result.isSuccess, 'expected isSuccess() to be false, got ' + result.isSuccess);
        System.assertEquals(
            errMsg,
            result.errorMessage,
            'expected errorMessage to be ' +
            errMsg +
            ', got " ' +
            result.errorMessage +
            '"'
        );
    }

    @IsTest
    private static void testSuccessConstructor() {
        AsyncResult result = AsyncResult.success();
        System.assert(result.isSuccess, 'expected isSuccess to be true, got ' + result.isSuccess);
        System.assert(
            String.isBlank(result.errorMessage),
            'expected errorMessage to be blank, got " ' +
            result.errorMessage +
            '"'
        );
    }

    @IsTest
    private static void testSuccessMessageWithObject() {
        String successMessage = 'Success, but note this...';
        AsyncResult result = AsyncResult.success(successMessage, new Account());
        System.assert(result.isSuccess, 'expected isSuccess to be true, got ' + result.isSuccess);
        System.assert(
            String.isBlank(result.errorMessage),
            'expected errorMessage to be blank, got " ' +
            result.errorMessage +
            '"'
        );
        System.assertEquals(successMessage, result.successMessage, 'expected a success message');
        System.assert(result.data != null, 'expected data, got null');
        System.assert(result.data instanceof Account, 'expected data to be an Account, got ' + result.data);
    }

    @IsTest
    private static void testSuccessWithObject() {
        String successMessage = 'Success, but note this...';
        AsyncResult result = AsyncResult.success(new Account());
        System.assert(result.isSuccess, 'expected isSuccess to be true, got ' + result.isSuccess);
        System.assert(
            String.isBlank(result.errorMessage),
            'expected errorMessage to be blank, got " ' +
            result.errorMessage +
            '"'
        );
        System.assert(
            String.isBlank(result.successMessage),
            'expected successMessage to be blank, got " ' +
            result.successMessage +
            '"'
        );
        System.assert(result.data != null, 'expected data, got null');
        System.assert(result.data instanceof Account, 'expected data to be an Account, got ' + result.data);
    }

    @IsTest
    private static void testConstructorWithObject() {
        String successMessage = 'It worked';
        AsyncResult result = new AsyncResult(true, successMessage, new Account());
        System.assert(result.isSuccess, 'expected isSuccess to be true, got ' + result.isSuccess);
        System.assertEquals(
            successMessage,
            result.successMessage,
            'expected successMessage to be "It worked", got " ' +
            result.successMessage +
            '"'
        );
        System.assert(result.data != null, 'expected data, got null');
        System.assert(result.data instanceof Account, 'expected data to be an Account, got ' + result.data);
    }
}
