/**
 * This code is PROPRIETARY AND CONFIDENTIAL to Vocalocity, Inc.
 * -- DO NOT RE-DISTRIBUTE THIS SOURCE CODE WITHOUT EXPRESS PERMISSION. --
 *
 * This source code is Copyright (c) 2013 by Vocalocity, Inc.
 * All Rights Reserved.
 *
 * The source code for this program is not published or
 * otherwise divested of its trade secrets, irrespective
 * of what has been deposited with the US Copyright Office.
 *
 */

@isTest
public class CTIControllerTest {    

    static String phone = '1555555555';
    static CTIUser testUser;
    static CTICallInfo testInfo;
    
    static final String uidField = CTIController.NAMESPACE + 'uid__c';

    static void setup(){
        testUser = CTIController.login('user', 'password');
        testInfo = CTIController.monitor(testUser, true).get(0);
        testUser.softPhoneObjects = new List<String>{'Contact'};
    }

    static testMethod void testGetObjectPrefix(){
        setup();
        System.assertEquals('003', CTIController.getObjectPrefix('Contact'));
    }
 
    static testMethod void testGetObjectPrefixBlank(){
        setup();
        System.assertEquals('', CTIController.getObjectPrefix(''));
    }

    static testMethod void testSearchForScreenPop(){
        setup();
        Contact testContact = new Contact( LastName = 'testVocalCont', phone = '6465657766');
        Contact testContact2 = new Contact( LastName = 'testVocalCont', phone = '6465657767');
        Contact testContact3 = new Contact( LastName = 'testVocalCont', phone = '6465657767');
        insert new List<Contact>{testContact, testContact2, testContact3};
        
        System.assertEquals('0', CTIController.searchForScreenPop('15555555555', testUser.softPhoneObjects));
        System.assertEquals(testContact.Id, CTIController.searchForScreenPop('6465657766', testUser.softPhoneObjects));
        System.assertEquals('multiple', CTIController.searchForScreenPop('6465657767', testUser.softPhoneObjects));
    }

    static testMethod void testGetCallDuration(){
        test.startTest();
            Long duration = CTIController.getCallDuration(DateTime.now().getTime()-60000);
        test.stopTest();

        System.assert(duration >= 0);
    }
    
    static testMethod void testSaveLog(){
    	String uid = '1234';
    	Map<String, String> params = new Map<String, String>();
    	params.put(uidField , uid);
    	
    	test.startTest();
    		String id = CTIController.saveLog(params).get('result');
    	test.stopTest();	
    	
        String q = 'SELECT Id, ' + uidField + ' FROM Task WHERE ' + uidField + ' = :uid LIMIT 1';
    	Task t = Database.query(q);
    	
    	System.assert(t != null);
    	System.assertEquals(id, t.id);
    	System.assertEquals(uid, t.get(uidField));
    }
    
    static testMethod void testUpdateLog(){
    	String uid = '1234';
    	Integer newDuration = 30; 
    	Task t = new Task(CallDurationInSeconds = 0);
    	t.put(uidField, uid);
    	insert t;
    	
    	Map<String, Object> params = new Map<String, Object>();
    	params.put('Id', t.Id);
    	params.put('CallDurationInSeconds', newDuration);
    	
    	test.startTest();
    		String id = CTIController.saveLog(params).get('result');
    	test.stopTest();	
    	
    	t = [SELECT Id, CallDurationInSeconds FROM Task WHERE Id = :t.Id LIMIT 1].get(0);
    	
    	System.assert(t != null);
    	System.assertEquals(id, t.id);
    	System.assertEquals(newDuration, t.CallDurationInSeconds);
    }
    
    static testMethod void testSaveDuplicateLog(){
    	String uid = '1234';
    	Task t = new Task();
    	t.put(uidField, uid);
    	insert t;
    	
    	Map<String, Object> params = new Map<String, Object>();
    	params.put(uidField, uid);
    	
    	test.startTest();
    		String id = CTIController.saveLog(params).get('result');
    	test.stopTest();
    	
    	System.assertEquals(id, t.Id);
    	
    }
}