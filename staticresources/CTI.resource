var DEBUG = true;
var CTIController;
var CTI = CTI || (function($){

    function init(){
        $(window).bind("beforeunload", CTI.close);

        CTI.ui.init();
        CTI.user.init();
        CTI.call.init();
        if(isLoggedIn()){ 
            CTI.ui.displayCTIPane();
            if(DEBUG){
                CTI.debug.init();
            }
            CTI.monitor.start();
        }
        else{
            CTI.ui.displayLoginPane();
        }
    }

    function close(){
        if(isLoggedIn()){
            CTI.monitor.stop();
            CTI.user.saveToCookie();
        }
    }
    
    function namespace(name) {
        CTI[name] = CTI[name] || {};
    }

    function getActiveMonitors(){
        return Cookie.read(CTI.cookies.activeMonitors) || 0;
    }

    function setActiveMonitors(value){
        Cookie.write(CTI.cookies.activeMonitors, value);
    }

    function isLoggedIn(){
        return !!Cookie.read(CTI.cookies.login);
    }

    function clearCookies(){
        for(var i in CTI.cookies){
            Cookie.clear(CTI.cookies[i]);
        }
    }
    
    return {
        debug               : getDebugInstance(),
        init                : init,
        close               : close,
        namespace           : namespace,
        getActiveMonitors   : getActiveMonitors,
        setActiveMonitors   : setActiveMonitors,
        isLoggedIn          : isLoggedIn,
        clearCookies        : clearCookies
    };
})(jQuery);

CTI.namespace("cookies");
CTI.cookies = {
    user            : "cti_user",
    callInfo        : "cti_call_info",
    login           : "cti_login",
    activeMonitors  : "cti_active_monitors",
    timestamp       : "cti_timestamp",
    searchObjects   : "apex__search_objects"
};

//Debugging
function getDebugInstance(){

    if(!DEBUG){
        function nop(){};
        return {
            init : nop,
            log : nop,
            logError : nop,
            logFunction : nop,
            display : nop
        };
    }

    var startTime;
    var endTime;
    var callData = [];
    var errors = [];
    var stack = [];
    var scope = 0;
    var initd = false;

    function log(object){
        callData.push(object);
        if(callData.length > 200){
            callData = callData.slice(100);
        }
    }

    function logError(e){
        errors.push(e);
        if(errors.length > 200){
            errors = errors.slice(100);
        }
    }

    function logEnter(funcName, args){
        stack.push({
            timestamp : Date.now(),
            name : funcName,
            scope : scope, 
            params : JSON.stringify(args, null, 4)
        });
        scope++;
    }

    function logExit(funcName, ret){
        stack.push({
            timestamp : Date.now(),
            name: funcName,
            scope : scope,
            retValue : JSON.stringify(ret, null, 4),
            isExit : true
        });
        scope--;
    }

    function printCallData(){
        if(!startTime) startTime = new Date(callData[0].timestamp);
        endTime = new Date(Date.now());
        var totalRunningTime = (endTime - startTime)/1000;
        var time = 0;

        var dataString = "Displaying log info from " + startTime + " to " + endTime + ".\n\n" +
                        "User : " + CTI.user.getAgentName() + "\n" +
                        "Extensions : " + CTI.user.getSelectedExtensions() + "\n\n";
        for(var i=0;i<callData.length;i++){
            dataString += callData[i].timestamp + "--> Response Time: " + callData[i].responseTime + "\n";
            time += callData[i].responseTime;
            for(var k=0;k<callData[i].calls.length;k++){
                dataString += "     " + callData[i].calls[k].direction + " call : "
                        + callData[i].calls[k].phone + "-->" + callData[i].calls[k].status + "\n";
            }
            dataString += "\n"
        }
        
        dataString += "Total Running Time: " + totalRunningTime + "secs\n" 
                + "Avg Response Time: " + (time/callData.length).toFixed(3) + "secs\n\n";
        return dataString;
    }

    function printStackTrace(){
        var stackTrace = "\n\nStack Trace:\n";
        for(var i=0;i<stack.length;i++){
            for(var k=0;k<stack[k].scope;k++){
                stackTrace += "----";
            }
            if(stack[i].isExit){
                stackTrace  += stack[i].timestamp + "-->Exiting : " + stack[i].name + "\n    " 
                            + " returning : " + stack[i].retValue + "\n";
            }
            else{
                stackTrace  += stack[i].timestamp + "-->Entering : " + stack[i].name + "\n    " 
                            + " with parameters : " + stack[i].params + "\n";
            }
            stackTrace+="\n";
        }
        return stackTrace;
    }

    function printApplicationState(){
        var userInfo = Cookie.read_map(CTI.cookies.user);
        userInfo.password = "*********";
        var state = "\n\nApplication State-->\n\n"
                + "User Info:\n" + JSON.stringify(userInfo, null, 4)
                + "\n\nCall Info:\n" + JSON.stringify(Cookie.read_map(CTI.cookies.callInfo), null, 4)
                + "\n\nLast Update:\n" + (new Date(parseInt(Cookie.read(CTI.cookies.timestamp))))
                + "\n\nActive Monitors:" + Cookie.read(CTI.cookies.activeMonitors)
                + "\n\nLogged In: " + (Cookie.read(CTI.cookies.login)?true:false);
        return state;
    }

    function printErrors(){
        var errorString = "\n\nErrors: \n";
        for(var e=0;e<errors.length;e++){
            var msg = errors[e].message;
            if(typeof msg === "object"){
                msg = JSON.stringify(msg, null, 4);
            }
            errorString += "\n" + errors[e].url 
                        + " Line " + errors[e].line 
                        + " : " + errors[e].message + "\n";
        }
        return errorString;
    }

    function display(){
        
        var logInfo = printCallData() 
                    + printErrors() 
                    + printStackTrace()
                    + printApplicationState();

        var childWindow = window.open("about:blank", "_blank");
        childWindow.document.write("<pre>" + logInfo + "</pre>");

        init();
    }
    
    function init(){
        startTime = new Date(Date.now());
        endTime = null;
        callData = [];
        var errors = [];
        var stack = {};

        if(!initd){
            initd = true;
            window.onerror = function(msg, u, num) {
                CTI.debug.logError({
                    message : msg,
                    line : num,
                    url : u
                });
                return false;
            }
        }
    }

    function logFunction(name, func){
        return function(){
            logEnter(name, arguments);
            var ret = func(arguments[0], arguments[1], arguments[2]);
            logExit(name, ret);
            return ret;
        };
    }

    return {
        init : init,
        log : log,
        logError : logError,
        logFunction : logFunction,
        display : display
    };

}