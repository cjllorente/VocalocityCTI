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
private class CTIUtilitiesTest {

    static testMethod void testExceptionPrinting() {
		Account testAccount = new Account(Id = '001000008586858');
		
		try{
			insert testAccount;
			system.assert(false, 'Error should have occurred');
		}
		catch (exception ex){
			System.assert( String.isNotBlank( CTIUtilities.printExceptionInfo(ex) ) );
		}
    }
}