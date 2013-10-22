@isTest
private class CTICallInfoTest {

	static CTIUser testUser;
	static CTICallInfo testInfo;
	static Contact testContact;

	static void setup(){
		testUser = CTIPresence.getUserLogin('user', 'pass');
		testInfo = CTIPresence.getCallStatus(testUser, true).get(0);
		testContact = new Contact(LastName = 'test');
		insert testContact;
	}

    
    
    static testMethod void testCodeCoverage(){
    	CTICallInfo info = new CTICallInfo();
    	info = new CTICallInfo('');
    	info.uid = '';
		info.agentName = '';
		info.callerName = '';
		info.callerNumber = '';
		info.customTag = '';
		info.startTime = '';
		info.callStatus	 = '';
		info.callType = '';	
		info.duration = '';
		info.extension = '';
		info.clickToCall = false;

		System.assert(info.uid == '');
		System.assert(info.agentName == '');
		System.assert(info.callerName == '');
		System.assert(info.callerNumber == '');
		System.assert(info.customTag == '');
		System.assert(info.startTime == '');
		System.assert(info.callStatus == '');
		System.assert(info.callType	 == '');
		System.assert(info.duration == '');
		System.assert(info.extension == '');
		System.assert(info.clickToCall == false);
    }
}