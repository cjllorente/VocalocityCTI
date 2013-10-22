CTI.namespace("monitor");
CTI.monitor = (function($){
        
    //Response types
    var LOGGED_OUT = "Logged out",
        CONFLICT_DETECTED = "Conflict detected",
        NOT_MODIFIED = "Not modified";

    //time constants
    var MONITOR_INTERVAL = 3000, //3 seconds
        LISTENER_INTERVAL = 1000, //1 second
        UPDATE_INTERVAL = 1000, //1 seconds
        RECOVERY_WAIT = 30000; // 30 seconds

    //state variables
    var monitoring, //monitoring Presence for new call data
        listening,  //listening for the active monitor to drop
        updating,   //updating call info from the local copy on the cookie
        checkingLogin, //checking if the user has logged out through another tab
        waiting = false,
        firstRequest = true;

    //misc
    var startWait,
        lastUpdate = 0;

    function start(){
    	
        var active_monitors = Cookie.read(CTI.cookies.activeMonitors);
        if(active_monitors == null || active_monitors == 0){
            if(!monitoring){
                CTI.setActiveMonitors(1);
                monitoring = setTimeout(monitor, 50);
            }
        }
        else{
            if(!listening){
                listening = setInterval(listen, LISTENER_INTERVAL);
            }
        }

        if(!updating){
            updating = setInterval(update, UPDATE_INTERVAL);
        }

        //Set an interval to check login status
        if(!checkingLogin){
            checkingLogin = setInterval(function(){
                return !CTI.isLoggedIn() && CTI.ui.logout();
            }, LISTENER_INTERVAL);
        }        
    }

    function stop(){
        if(monitoring){
            clearTimeout(monitoring);
            monitoring = null;

            CTI.setActiveMonitors(0);
            firstRequest = true;
        }

        if(listening){
            clearInterval(listening);
            listening = null;
        }

        if(updating){
            clearInterval(updating);
            updating = null;
        }

        if(checkingLogin){
            clearInterval(checkingLogin);
            checkingLogin = null;
        }
    }

    function listen(){
        var active_monitors = CTI.getActiveMonitors();
        if(active_monitors == 0){ 
            stop();
            start();
        }
    }

    function update(){
        var dataAge = Cookie.read(CTI.cookies.timestamp);
        if(lastUpdate < dataAge){
            lastUpdate = Date.now();
            CTI.call.loadFromCookie();
            CTI.call.displayCallInfo();
        }
    }
	
	function isListening(){
		return listening != null;
	}
	
	function isMonitoring(){
		return monitoring != null;
	}

    var monitorTimeout;
    function monitor(){
        monitorTimeout = null;
        if(!monitoring || !CTI.isLoggedIn()){return;}
        startWaiting();
        
        var s = new Date(Date.now());
        CTIController.monitor(  CTI.user.getInfo(), 
                                firstRequest, 
            function(callInfoList, event){   
                if (!monitoring || !CTI.isLoggedIn()){return;}


                /**********************************************************/
                /*********************** DEBUGGING ************************/
                /**********************************************************/
                if(DEBUG){
                    var e = new Date(Date.now());
                    var response = ((e-s).toFixed(3)/1000);

                    var logData = {
                        calls : [],
                        responseTime : response,
                        timestamp : new Date(Date.now()).toUTCString()
                    };

                    for(var i=0;i<callInfoList.length;i++){
                        logData.calls.push({
                            status : (callInfoList[i].callStatus || callInfoList[i].callType),
                            phone : (callInfoList[i].callerNumber || ""),
                            direction : callInfoList[i].callType || "no"
                        });
                    }

                    CTI.debug.log(logData);
                }

                /**********************************************************/
                /******************** END DEBUGGING ***********************/
                /**********************************************************/
                

                if(!event.status){
                    CTI.debug.logError({
                        message : event,
                        line : 111,
                        url : "CTI_monitor.resource"
                    });
                    return;
                }
                else if (callInfoList != null && callInfoList[0].callType != NOT_MODIFIED) {
                    if(callInfoList[0].callType == LOGGED_OUT){
                        firstRequest = true;
                        CTI.ui.logout();
                        return;
                    }
                    
                    if(callInfoList[0].callType != CONFLICT_DETECTED){
                        CTI.call.updateFromPresence(callInfoList);
                    }
                    firstRequest = false;
                }

                if(!waiting){
                    monitorTimeout = monitorTimeout || setTimeout(monitor, 10);
                }
                else{
                    var remainingWaitTime = MONITOR_INTERVAL - (Date.now() - startWait);
                    monitorTimeout = monitorTimeout || setTimeout(monitor, (remainingWaitTime > 20 ? remainingWaitTime : 20));
                }
                threshold = 0;
            }
        );   
    }

    function startWaiting(){
        waiting = true;
        startWait = Date.now();
        setTimeout(stopWaiting, MONITOR_INTERVAL);
    }

    function stopWaiting(){
        waiting = false;
        startWait = null;
    }

    var MAX_THRESHOLD = 1;
    var threshold = 0;
    function attemptRecovery(){        
        
        if(threshold < MAX_THRESHOLD){
            setTimeout(start, RECOVERY_WAIT);
            threshold++;
        }
        else{
            stop();
            CTI.ui.displayApplicationFailure();
        }
    }

    return{
        start : start,
        stop : stop,
        isListening : isListening,
        isMonitoring : isMonitoring
    };

})(jQuery);