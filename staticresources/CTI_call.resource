CTI.namespace("call");
CTI.call = (function($){
	var activeCalls = {};

	var CLEAR_CALL_TIMEOUT 	= 5000; // 5 seconds
	var CLEAR_ID			= null;
	var MAX_CALLS_DISPLAYED = 3;

	//Call status constants
	var IDLE 				= "Idle",
		RINGING 			= "Ringing",
		CONNECTED 			= "Connected",
		DISCONNECTED 		= "Disconnected",
		CONFLICT_DETECTED 	= "Conflict detected",
		IDLE 				= "Idle",
		INTRAPBX 			= "intrapbx",
		INBOUND 			= "inbound",
		OUTBOUND 			= "outbound";

	//log status constants
	var SUCCESS 	= "Success",
		ERROR 		= "Error",
		NOT_CREATED	= "Not Created",
		NO_LOG		= "No Log",
		INCOMPLETE 	= "Incomplete";

	//prefix constants
	var CONTACT_PREFIX = '003',
		LEAD_PREFIX = '00Q';

	//color constants
	var RED = 'rgb(223, 63, 63)',
		GRN	= 'rgb(72, 188, 55)',
		BLU	= 'rgb(23, 151, 192)';

	var callInfoList;

	function init(){
		//store frequently accessed DOM elements
		callInfoList = $('[id$="callInfoList"]');

		//fields to populate on a call log
		CTIController.getNamespace(function(namespace){
			IdField					= "Id",
			uidField 				= namespace + "uid__c",
			subjectField 			= "Subject",
			durationField 			= "CallDurationInSeconds",
			statusField 			= "Status",
			commentsField 			= "Description",
			activityDate			= "ActivityDate",
			agentNameField 			= namespace + "Agent__c",
			customTagField			= namespace + "Call_Tag__c",
			callTypeField 			= namespace + "Call_Type__c",
			callDetailsField 		= namespace + "Call_Details__c",
			startTimeField 			= namespace + "Start_Time__c",
			endTimeField 			= namespace + "End_Time__c",
			formattedDurationField	= namespace + "Formatted_Duration__c";
		});
	}

	//Data control logic//

	var statusLabels = {
		"Ringing" 		: "Active Call: ",
		"Connected" 	: "Active Call: ",
		"Disconnected" 	: "Previous Call: "
	};
	function getNewCallInstance(callInfo){
		return {
			agentName			: callInfo.agentName,
			callerName			: (callInfo.callerName 		== 'null' ? '' : callInfo.callerName),
			callerNumber		: (callInfo.callerNumber 	== 'null' ? '' : callInfo.callerNumber),
			customTag			: (callInfo.customTag 		== 'null' ? '' : callInfo.customTag),
			startTime			: parseInt(callInfo.startTime)  || Date.now(),
			callStatus			: callInfo.callStatus,
			callType			: callInfo.callType,
			extension			: callInfo.extension,
			recordingLink		: callInfo.recordingLink,
			clickToCall 		: callInfo.clickToCall,
			comments 			: null,
			duration 			: 0,
			formattedPhone		: formatLocal("US", callInfo.callerNumber),
			formattedDuration 	: "00:00:00",
			callLabel			: statusLabels[callInfo.callStatus] 
									+ (callInfo.callerName == 'null' ? '' : callInfo.callerName),
			logId				: null,
			objectId 			: null,
			objectName			: "",
			displayed			: callInfo.callStatus == DISCONNECTED,
			expanded			: false,
			logCreated			: false,
			userLogged			: false,
			hangUpLogged		: false,
			uidList				: null,
			drawn				: false,
			logStatus			: NOT_CREATED,
			duplicate			: false
			
		};
	}

	function updateFromPresence(rawData){
		loadFromCookie();

		var callInfoData = {}
		for(var i=0; i<rawData.length;i++){
			callInfoData[rawData[i].uid] = rawData[i];
		}
		
		var phoneToActiveCalls = {};
		var isIdle = false;
		for(var uid in callInfoData){ 
			
			if(callInfoData[uid].callStatus == IDLE){
				for(var uid in activeCalls){
					if(activeCalls[uid].callStatus == CONNECTED || activeCalls[uid].callStatus == RINGING){
						activeCalls[uid].callStatus = DISCONNECTED;
					}
				}
				continue;
			}
			else if(callInfoData[uid].callStatus == DISCONNECTED && !activeCalls[uid] ){
				continue;
			}

			if(callInfoData[uid].callStatus != DISCONNECTED){
				var phone = callInfoData[uid].callerNumber; 
				var prevUID = phoneToActiveCalls[phone];
				if(!prevUID){
					phoneToActiveCalls[phone] = uid;
					if(!activeCalls[uid]){
						activeCalls[uid] = getNewCallInstance(callInfoData[uid]);
					}
				}
				else{
					if(!activeCalls[prevUID].uidList){
						var newList = new Object();
						newList[prevUID] = callInfoData[prevUID].callStatus;
						activeCalls[prevUID].uidList = newList;
					}					
					activeCalls[uid] = activeCalls[prevUID];
					activeCalls[uid].uidList = activeCalls[prevUID].uidList;
				}
			}
			
			if(activeCalls[uid].uidList){
				activeCalls[uid].uidList[uid] = "";
				for(var u in activeCalls[uid].uidList){
					if(callInfoData[u]){
						activeCalls[uid].uidList[u] = callInfoData[u].callStatus;
					}
				}
				
				activeCalls[uid].callStatus	= determineCallStatus(activeCalls[uid].uidList);
				activeCalls[uid].callType	= callInfoData[uid].callType;
				activeCalls[uid].callLabel	= statusLabels[activeCalls[uid].callStatus] 
											+ (activeCalls[uid].callerName || "");
			}
			else{
				activeCalls[uid].callStatus	= callInfoData[uid].callStatus;
				activeCalls[uid].callType	= callInfoData[uid].callType;
				activeCalls[uid].callLabel	= statusLabels[activeCalls[uid].callStatus] 
											+ (activeCalls[uid].callerName || "");
			}
		
		}
		
		saveToCookie();
	}

	function determineCallStatus(uidList){
		
		var possibleDuplicateUids = [];
		var status = DISCONNECTED;
		
		for(var uid in uidList){
			
			if(uidList[uid] != DISCONNECTED && status != CONNECTED){
				status = uidList[uid];
			}
			else if( uidList[uid] == DISCONNECTED ){
				possibleDuplicateUids.push(uid);
			}
		}
		
		if( status != DISCONNECTED ){
			for(var i=0;i<possibleDuplicateUids.length;i++){		
				activeCalls[possibleDuplicateUids[i]].duplicate = true;
			}
		} 
		
		return status;
	}

	//UI Logic//
	
	var focusedTextArea, focusedTextAreaId, redraw, focusedText, caretStart, caretEnd;
	function displayCallInfo(){
		var htmlString = "";
		var callActive = false;
		var uids = getSortedUIDs();

		for(var uid in activeCalls){ activeCalls[uid].drawn = false;}

		var callsDrawn = 0;
		for(var i=0;i<uids.length;i++){
			if(activeCalls[uids[i]].callStatus == RINGING || activeCalls[uids[i]].callStatus == CONNECTED){
				callActive = true;
			}
			if(callsDrawn >= MAX_CALLS_DISPLAYED){
				delete activeCalls[uids[i]];
			}
			else if(!activeCalls[uids[i]].drawn){
				activeCalls[uids[i]].drawn = true;
				htmlString += generateHTML(uids[i]);
				callsDrawn++;
			}
		}
		if(!callActive){
			htmlString  = '<li style="margin-bottom:3px;"><a href="#" class="head" >Listening for Call...</a></li>' 
        				+ htmlString;
        	stopCallDurationTimer();
		}
		else{
			startCallDurationTimer();
		}
		
		if(focusedTextArea){
			console.debug(focusedTextArea.val());
			focusedText = focusedTextArea.val();
			caretStart = focusedTextArea.prop('selectionStart');
			caretEnd = focusedTextArea.prop('selectionEnd');
		}
		
		redraw = true;
		callInfoList.html(htmlString);
		redraw = false;

		focusTextArea();
		
		for(var uid in activeCalls){
			var callBar = $("#bar_"+uid);
			if(activeCalls[uid].callStatus == RINGING){
				$('#comments_'+uid).hide();
				if(!activeCalls[uid].displayed){
					callBar.css('background',RED);
					callBar.effect( "pulsate",{times:4}, 200);
				}
				else{
					callBar.css('background',GRN);
				}
			}
			else if(activeCalls[uid].callStatus == CONNECTED){
				
				if(!activeCalls[uid].logCreated && !activeCalls[uid].duplicate){
					
					createLog(uid);
				}

				if(!activeCalls[uid].displayed){
					callBar.css('background',RED);
				}
				else{
					callBar.css('background',GRN);
				}
			}
			else if(activeCalls[uid].callStatus == DISCONNECTED && !activeCalls[uid].duplicate){
				if(!activeCalls[uid].hangUpLogged){
					updateLog(uid);
				}
				if(activeCalls[uid].userLogged || activeCalls[uid].logStatus == NO_LOG){
					CLEAR_ID = uid;
					setTimeout(clearLoggedCall, CLEAR_CALL_TIMEOUT);
				}
			}

			if(!activeCalls[uid].expanded){
				$('#call_info_'+uid).hide();	
			} 

			displayLogMessage(uid);
		}
	}

	function generateHTML(uid){
		var callInfo = activeCalls[uid];

		var t = new Date(callInfo.startTime);
        var date = t.toLocaleDateString();
        var time = t.toLocaleTimeString();
        return '<li><a href="#" class="head" id="bar_' + uid + '" '
        				+ 'onclick="CTI.call.callClicked(\''+uid+'\');">' + callInfo.callLabel + '</a> '
				+ '<div id="call_info_'+uid+'">'
				+ '<table id="info_table_'+uid+'" cellpadding="0" cellspacing="0" class="caller-info">'
					+ '<tr class="info_row">'
						+ '<td class="info_label">Caller ID</td>'
						+ '<td style="border:none;padding:0px">'
							+ callInfo.callerName
						+ '</td>'
					+'</tr>'
					+ '<tr class="info_row">'
						+ '<td class="info_label">Number</td>'
						+ '<td>'
							+ '<a href="#" onclick="CTI.ui.clickToCall(\''+callInfo.callerNumber+'\')">' + callInfo.callerNumber + '</a>'
						+ '</td>'
					+ '</tr>'
					+ '<tr class="info_row">'
						+ '<td class="info_label">Call Tag</td>'
						+ '<td> ' + callInfo.customTag + '</td>'
					+ '</tr>    '
					+ '<tr class="info_row">'
						+ '<td class="info_label" >Date</td>'
						+ '<td>' + date + '</td>'
					+ '</tr>'
					+ '<tr class="info_row">'
						+ '<td class="info_label">Time</td>'
						+ '<td>' + time + '</td>'
					+ '</tr>'
					+ '<tr class="info_row">'
						+ '<td class="info_label">Duration</td>'
						+ '<td id="duration_'+uid+'">' 
							+ callInfo.formattedDuration 
						+ '</td>'
					+ '</tr>'
				+ '</table> '
				+ '<div id="comments_'+uid+'" >'
					+ '<h1 class="info_label">Comments</h1>'
					+ (!focusedTextArea ?
						'<textarea id="comments_field_' + uid + '" '
						+ 'class="comments_field" '
						+ 'cols="25" rows="3"'
						+ 'onchange="CTI.call.saveComments(\''+uid+'\')" '
						+ 'onfocus="CTI.call.setFocusArea(\'comments_field_' + uid + '\', \''+uid+'\');"'
						+ 'onblur="CTI.call.clearFocus()">'
						+ ( ($('#comments_field_'+uid).val() 
							|| activeCalls[uid].comments )
							|| '')
						+ '</textarea><br/>' : '')
						+ '<button type="button" class="btnLogin" id="btnLogCall" style="float:right;"'
						+ 'onclick="CTI.call.logCall(\'' + uid + '\');">'
							+ 'Log Call'
						+ '</button>'
					+ '<br class="float_clear"/>'
				+ '</div>'
				+ '<div id="message_'+uid+'" ></div>'
			+'</div></li>';
	}

	var savedCommentText = '';
	function setFocusArea(id, uid){
		focusedTextAreaId = uid;
		focusedTextArea = $('#'+id);
		return true;
	}

	function focusTextArea(){
		if(focusedTextArea){
			var commentsDiv = $('div#comments_'+focusedTextAreaId);
			commentsDiv.html('<h1 class="info_label">Comments</h1>');
			commentsDiv.append(focusedTextArea);
			focusedTextArea.val(focusedText);
			focusedTextArea.prop('selectionStart', caretStart);
			focusedTextArea.prop('selectionEnd', caretEnd);
			commentsDiv.append('<button type="button" class="btnLogin" id="btnLogCall" style="float:right;"'
								+ 'onclick="CTI.call.logCall(\'' + focusedTextAreaId + '\');">'
								+ 'Log Call'
								+ '</button>'
								+ '<br class="float_clear"/>');
			focusedTextArea.focus();
		}
	}

	function clearFocus(){
		if(!redraw){
			focusedTextAreaId = null;
			focusedTextArea = null;
			focusedText = '';
			caretStart = 0;
			caretEnd = 0;
		}
	}

	function displayLogMessage(uid){
		var msgDiv 		= $('#message_'+uid);
		var infoTable 	= $('#info_table_'+uid);
		var commentsDiv = $('#comments_'+uid);
		msgDiv.hide();
		switch(activeCalls[uid].logStatus){
			case SUCCESS:
				var msg = '<h1 class="log_success">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Success!</h1>'
						+ 'The <a href="/' + activeCalls[uid].logId+'" target="_parent">Call Log</a> has been saved to '
						+ '<a href="/' + activeCalls[uid].objectId+'" target="_parent">'+activeCalls[uid].objectName+'</a>';
				msgDiv.html(msg);
				msgDiv.show();
				infoTable.hide();
				commentsDiv.hide();
				break;
			case ERROR:
				var msg = '<h1 class="log_error">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Error!</h1>'
						+ '<p>You must be on a record detail page to log a call.</p>';
				msgDiv.html(msg);
				msgDiv.show();
				break;
			case NO_LOG:
				var msg = '<h1>No Log Created!</h1>';
				msgDiv.html(msg);
				msgDiv.show();
				infoTable.hide();
				commentsDiv.hide();
				break;
		}
	}

	function callClicked(uid){
		if(!activeCalls[uid]) return;
		if( (activeCalls[uid].callStatus == RINGING ||
				activeCalls[uid].callStatus == CONNECTED) 
			&& !activeCalls[uid].expanded ){
			for(call in activeCalls){
				$('#call_info_'+call).hide();
				activeCalls[call].expanded = false;
			}
			$('#call_info_'+uid).show('fast');
			activeCalls[uid].expanded = true;
		}else{
			$('#call_info_'+uid).toggle('fast');
			activeCalls[uid].expanded = !activeCalls[uid].expanded;
		}

		if(!activeCalls[uid].displayed){
			$('#bar_'+uid).css('background', GRN);
			activeCalls[uid].displayed = true;
			saveToCookie();
			CTI.ui.screenPop(activeCalls[uid]);
			return;
		}

		saveToCookie();
	}

	function saveComments(uid){
		if(!activeCalls[uid]) return;
		activeCalls[uid].comments = $('#comments_field_'+uid).val();
		saveToCookie();
	}

	//Call Logging//

	//fields to populate on a call log
	var IdField,
		uidField,
		subjectField,
		durationField,
		statusField,
		commentsField,
		activityDate,
		agentNameField,
		customTagField,
		callTypeField,
		callDetailsField,
		startTimeField,
		endTimeField,
		formattedDurationField;

	//creates the initial log when the CTI detects a call
	function createLog(uid){
		if(!activeCalls[uid]) return;
		if(activeCalls[uid].logId || !CTI.monitor.isMonitoring()) return;
		
		var callInfo = activeCalls[uid];
		var params = {};
		params[uidField] 	    = uid;
		params[subjectField]    = "Call:Auto-Log";
		params[agentNameField]  = callInfo.agentName;
		params[customTagField]  = (callInfo.customTag || '');
		params[callTypeField]   = (callInfo.clickToCall ? OUTBOUND : INBOUND);
		params[activityDate] 	= callInfo.startTime;
		params[callDetailsField]= callInfo.recordingLink;
		params[startTimeField]  = (new Date(callInfo.startTime)).toLocaleString();
		CTIController.saveLog(params, function(response){
			if(response.error){
				CTI.debug.logError({
						message: error,
						line : 434,
						url : "CTI_call.resource"
					});
				return;
			}
			activeCalls[uid].logId = response.result;
			activeCalls[uid].logStatus = INCOMPLETE;
			saveToCookie();
			
		});
	}

	//updates log after call ends with correct end time
	function updateLog(uid){
		if(!activeCalls[uid]) return;
		if(!CTI.monitor.isMonitoring())return;
		var callInfo = activeCalls[uid];
		if(callInfo.logId == null){
			
			callInfo.logStatus = NO_LOG;
			saveToCookie();
			return;
		}
		
		var endTime = (new Date(callInfo.startTime+(callInfo.duration*1000))).toLocaleString();
		var params 	= {};
			params[IdField] 				= callInfo.logId ;
			params[statusField]				= "Completed";
			params[durationField]			= callInfo.duration;
			params[formattedDurationField] 	= callInfo.formattedDuration;
			params[endTimeField] 			= endTime;
		CTIController.saveLog(params, function(response){
			if(response.error){
				CTI.debug.logError({
					message: error,
					line : 469,
					url : "CTI_call.resource"
				});
				return;
			}
			if(activeCalls[uid]){
				activeCalls[uid].hangUpLogged = true;
			}
			saveToCookie();
		});
	}

	//assigns log to an object when user presses 'Log Call' button
	function logCall(uid){
		if(!activeCalls[uid]) return;
		var callInfo = activeCalls[uid];
		sforce.interaction.getPageInfo(function(response){
			var pageInfo = $.parseJSON(response.result)
			var objectId = pageInfo.objectId;

			if(!objectId || !isSearchObject(objectId)){
				activeCalls[uid].logStatus = ERROR;
				saveToCookie();
				return;
			}
			
			var prefix = objectId.substring(0, 3);
			var relatedField = (prefix == CONTACT_PREFIX || prefix == LEAD_PREFIX 
								? "whoId"
								: "whatId");
			var params 	= {};	
			params[IdField] 			= callInfo.logId;
			params[relatedField] 		= objectId;
			params[commentsField] 		= $('#comments_field_'+uid).val();
			CTIController.saveLog(params, function(response){
				if(response.error){
					activeCalls[uid].logStatus = ERROR;
					CTI.debug.logError({
						message: error,
						line : 509,
						url : "CTI_call.resource"
					});
				}
				else{
					activeCalls[uid].logStatus = SUCCESS;
					activeCalls[uid].objectId = objectId;
					activeCalls[uid].objectName = 'Record';
					activeCalls[uid].userLogged = true;
					saveToCookie();
				}
			});
		});
	}

	//Call Duration Logic//

    var timerOn;
    function startCallDurationTimer(){
        if(!timerOn){
            timerOn = setInterval(function(){getCallDuration();}, 1000);
        }
    }

    function stopCallDurationTimer(){
        if(timerOn){
            clearInterval(timerOn);
            timerOn = null;
        }
    }

    function getCallDuration(){
    	for(var uid in activeCalls){
    		if(activeCalls[uid].callStatus == DISCONNECTED || 
    			activeCalls[uid].callStatus == IDLE) continue;
	        CTIController.getCallDuration(activeCalls[uid].startTime, function(r){
	        	if(!r)return;
	            var d = new XDate()
	                   .clearTime()
	                   .addSeconds(r)
	                   .toString("HH:mm:ss");
	            activeCalls[uid].duration = r;
	            activeCalls[uid].formattedDuration = d;
	            $('#duration_'+uid).text(d);
	        });
    	}
    }

    //Cookie functions//

	function saveToCookie(){
		Cookie.write_map(CTI.cookies.callInfo, activeCalls);
		Cookie.write(CTI.cookies.timestamp, Date.now());
	}

	function loadFromCookie(){
		var temp = {};
		for(uid in activeCalls){
			if(activeCalls[uid].duration){
				temp[uid+'_d'] = activeCalls[uid].duration;
				temp[uid+'_f'] = activeCalls[uid].formattedDuration;
			}
		}
		activeCalls = Cookie.read_map(CTI.cookies.callInfo) || {};

		for(uid in activeCalls){
			if(temp[uid+'_d']){
				 activeCalls[uid].duration = temp[uid+'_d'];
				 activeCalls[uid].formattedDuration = temp[uid+'_f'];	
			}
		}
	}

    //Utility functions//

	function isInternalCall(uid){
		if(!activeCalls[uid]) return false;
		return activeCalls[uid].callType == INTRAPBX;
	}

	function clearActiveCalls(){
		callInfoList.html('');
		activeCalls = {};
	}

	function clearLoggedCall(){
        if(CLEAR_ID){
           	if(activeCalls[CLEAR_ID] && activeCalls[CLEAR_ID].uidList){
				for(child in activeCalls[CLEAR_ID].uidList){
					if( activeCalls[child] )
						delete activeCalls[child];
				}
			}
            
			delete activeCalls[CLEAR_ID];
			CLEAR_ID = null;
			saveToCookie();
        }
   }

	function isSearchObject(objectId){
		var prefix = objectId.substring(0,3);
		var prefixes = CTI.ui.getLayout().prefixes;
		console.debug(prefixes);
		for(var i=0;i<prefixes.length;i++){
			if(prefix == prefixes[i]){
				return true;
			}
		}
		return false;
	}

	function getSortedUIDs(){
		var arr = [], hash = {}, ids = [];
		for(uid in activeCalls){
			if(activeCalls[uid].callType == INTRAPBX || activeCalls[uid].callStatus == IDLE || activeCalls[uid].duplicate) continue;
			arr.push(activeCalls[uid].startTime);
			hash[activeCalls[uid].startTime] = uid;
		}

		for(var i=1;i<arr.length;i++){
			for(var k=i;k>0 && arr[k] > arr[k-1];k--){
				var temp = arr[k];
				arr[k] = arr[k-1];
				arr[k-1] = temp;
			}
		}

		for(var i=0;i<arr.length;i++){
			ids.push(hash[arr[i]]);
		}

		return ids;
	}

	function getActiveCallsList(){
		return activeCalls;
	}

	return { getActiveCallsList : getActiveCallsList,
		init 				: init,
		callClicked			: callClicked,
		clearActiveCalls	: clearActiveCalls,
		loadFromCookie		: loadFromCookie,
		updateFromPresence 	: updateFromPresence,
		displayCallInfo		: displayCallInfo,
		saveComments		: saveComments,
		clearFocus			: clearFocus,
		setFocusArea		: setFocusArea,
		logCall				: logCall
	};

})(jQuery);