@isTest
private class CTIPresenceTest {

	static String username = 'user';
	static String password = 'pass';
	static String phone = '15555555555';

    static testMethod void testUserLogin() {
        test.startTest();
            CTIUser user = CTIPresence.getUserLogin(username, password);
        test.stopTest();

        System.assertEquals(user.loginName, username);
        System.assertEquals(user.password, password);
        System.assertEquals(user.extensions, new List<String>{'456'});
        System.assertEquals(user.hdapToken, 'hdapToken'); 
    }

    static testMethod void testClickToCall(){
    	CTIUser user = CTIPresence.getUserLogin(username, password);
    	
        test.startTest();
            String response = CTIPresence.clickToCall(phone, user);
        test.stopTest();

        System.assertEquals(response, 'OK');
    }

    static testMethod void testGetCallStatus(){
    	CTIUser user = CTIPresence.getUserLogin(username, password);
    	
    	test.startTest();
    		List<CTICallInfo> calls = CTIPresence.getCallStatus(user, true);
    	test.stopTest();

        System.assertEquals('Test User', calls[0].agentName);
        System.assertEquals('Idle', calls[0].callStatus);
        System.assertEquals('321', calls[0].uid);
    }
}