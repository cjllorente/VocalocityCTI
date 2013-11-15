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
public class CTISearchControllerTest {

	static Contact testContact;
	static Task testTask;
	static void setup(){
		testTask = new Task();
		testContact = new Contact(LastName='test',  phone = '155555555555');
	}
	
	static testMethod void testFindSearchResults(){
		setup();
		insert testContact;
		insert testTask;
		List<CTISearchResults> searchResults;
		
		test.startTest();
			CTISearchController controller = new CTISearchController();
			searchResults = controller.searchResults;
		test.stopTest();

		System.assertEquals(1, searchResults.size());
		System.assertEquals(testContact.Id, searchResults[0].getFirstId());
	}
}