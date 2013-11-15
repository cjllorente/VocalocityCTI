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

global class CTICallInfo {

	//Call Log constants
	public static final String CALL_SUBJECT = 'Call: Auto-Log';
	public static final String STATUS_COMPLETED = 'Completed';
	public static final String INBOUND_LABEL = 'Inbound';
	public static final String OUTBOUND_LABEL = 'Outbound';	
	public static final String DATE_TIME_FORMAT = 'E MM.dd.yyyy HH:mm:ss a';
	public static final String YES = 'y';
	public static final String SCREEN_POP_ON_RING_OPTION = '0';
	public static final String SCREEN_POP_ON_ANSWER_OPTION = '1';

	//call type values
	public static final String INTRAPBX = 'intrapbx';
	public static final String INBOUND = 'inbound';
	public static final String OUTBOUND = 'outbound';

	//call status values
	public static final String CALL_RINGING = 'Ringing';
	public static final String CALL_CONNECTED = 'Connected';
	public static final String CALL_DISCONNECTED = 'Disconnected';
	public static final String CALL_IDLE = 'Idle';

	//instance variables
	public String uid;
	public String agentName;
	public String callerName;
	public String callerNumber;
	public String customTag;
	public String startTime;
	public String callStatus;		//Ringing, Connected, Disconnected, or Idle
	public String callType;			//Intrapbx, Inbound, or Outbound
	public String duration;
	public String extension;
	public String recordingLink;

	public boolean displayed = false;
	public boolean clickToCall;

	public CTICallInfo(){}
	
	public CTICallInfo(String s){
		callType = s;
	}

	public CTICallInfo(String name, String type, String phone, Map<String, Object> statusItems){
		agentName 		= name;
		callType 		= type;
		callerNumber	= phone;
		callerName 		= (String)statusItems.get('onCallWithName');
		uid 			= (String)statusItems.get('uid');
		callStatus 		= (String)statusItems.get('callStatus');
		customTag 		= (String)statusItems.get('customTag');
		startTime 		= (String)statusItems.get('StartTime');
		clickToCall 	= (String)statusItems.get('startedWithClickToCall') == 'true';
		if((String)statusItems.get('isRecorded') == 'true'){
			recordingLink	= 'This call was recorded. The recording(s) can be accessed at\n\n'
							+ 'https://my.vocalocity.com/ui/recordingsplayer/' 
							+ (String)statusItems.get('presenceCallId')
							+ '\n\n(Vocalocity login required)';
		}
		else{
			recordingLink = '';
		}
	}
	
	public boolean isConnected(){
		return callStatus == CALL_CONNECTED;
	}

	public boolean isRinging(){
		return callStatus == CALL_RINGING;
	}

	public boolean isActive(){
		return (callStatus == CALL_RINGING || callStatus == CALL_CONNECTED);
	}

	public boolean isDisconnected(){
		return callStatus == CALL_DISCONNECTED;
	}
	
	public boolean isIdle(){
		return callStatus == CALL_IDLE;
	}

	public boolean isIntrapbx(){
		return callType == INTRAPBX;
	}
	
	public boolean isInboundCall(){
		return callType == INBOUND;
	}
	
	public boolean startedWithClickToCall(){
		return clickToCall;
	}
}