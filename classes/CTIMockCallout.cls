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

public with sharing class CTIMockCallout {
	static final String LOGIN_URL = 'appserver/rest/user/null';
	static final String GET_ALL_EXTENSIONS_URL = 'appserver/rest/userextension';
	static final String MONITOR_EXTENSIONS_URL = 'presence/dashui';
	static final String CLICK_TO_CALL_URL = 'presence/rest/clicktocall';
	static final String HDAP_TOKEN_KEY = 'Set-Cookie';
	static final String HDAP_ID = 'HDAP-ID=';

	private static String loginOK = 
	'{' +
		'"accountId" : 12345,' +
		'"userStatusID" : 1,' +
		'"loginName" : "user",' +
		'"firstName" : "Test",' +
		'"lastName" : "User",' +
		'"email" : "noone@nowhere.com",' +
		'"phoneNumber" : "123456789",' +
		'"role" : 0,' +
		'"roleId" : [ 2 ],' +
		'"secretQuestionId" : 4,' +
		'"secretAnswer" : "hdap",' +
		'"dateLastUpdated" : "2013-03-06T16:45:26.803Z",' +
		'"lastUpdatedByUserId" : 1234,' +
		'"existingsuperuser" : 0,' +
		'"contactnumbers" : [ {' +
			'"userId" : 789' +
		'} ],' +
		'"updateMeWithAnnouncements" : 0,' +
		'"blockAccess" : 0,' +
		'"allowEndUserOutboundCallerId" : false,' +
		'"userId" : 789' +
	'}';

	private static String extensionsOK = 
		'<ns3:deviceList xmlns:ns2="http://vocalocity.com/HDAP/customers" xmlns:ns3="http://vocalocity.com/HDAP/users">' +
			'<device>' +
				'<extension>456</extension>' +
				'<type>Extension</type>' +
				'<sipid>VH1337</sipid>' +
				'<password>pass</password>' +
				'<registrar>sip-12345.accounts.vocalocity.com</registrar>' +
			'</device>' +
		'</ns3:deviceList>';

	private static String callStatusOK = 
		'{"extensions" : [ {'+
			'"name" : "Test User",'+
			'"status" : "Testing",'+
			'"extension" : "123",'+
			'"onCallWith" : "",'+
			'"phoneNumbers" : [ "15555555555" ],'+
			'"statusItems" : {' +
				'"uid" : "321",' +
				'"accountId" : "12345",' +
				'"lastCallTime" : "1367203850888",' +
				'"available" : "true",' +
				'"contactH" : "",' +
				'"callername" : "",' +
				'"contactM" : "",' +
				'"userId" : "789",' +
				'"StartTime" : "1367203850000",' +
				'"callStatus" : "Idle",' +
				'"contactF" : "",' +
				'"contactE" : "noone@nowhere.com",'+
				'"loginName" : "user"' +
			'},'+
			'"duration" : -1'+
		'} ],'+
		'"name" : "message",'+
		'"type" : "event",'+
		'"availability" : "AVAILABLE",'+
		'"numAvailableExts" : 1,'+
		'"numUnavailableExts" : 0,'+
		'"servicedBy" : "10.20.5.102"'+
		'}';

	public static HttpResponse getResponse(String params){
		HttpResponse response = new HttpResponse();
		response.setStatusCode(200);
		if(params.startsWith(LOGIN_URL)){
			response.setBody(loginOK);
			response.setHeader(HDAP_TOKEN_KEY, HDAP_ID+ 'hdapToken;');
		}
		else if(params.startsWith(GET_ALL_EXTENSIONS_URL)){
			response.setBody(extensionsOK);
		}
		else if(params.startsWith(MONITOR_EXTENSIONS_URL)){
			response.setBody(callStatusOK);
		}
		else if(params.startsWith(CLICK_TO_CALL_URL)){
			response.setBody('OK');
		}
		return response;
	}
}