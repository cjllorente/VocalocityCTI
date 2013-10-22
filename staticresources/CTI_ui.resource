CTI.namespace("ui");
CTI.ui = (function($){

    //Frequently accessed DOM Elements
    var ctiPane,
        loginPane,
        failurePane,
        usernameInput,
        passwordInput,
        agentNameField,
        selectedExtensionsDiv,
        loginForm;

    //UI Messages
    var LOGIN_FAILURE = "Login failed. Ensure username/password are correct and that remote site settings are correctly configured.";

    var layout = {
        target : null,
        noMatchSettings : null,
        multipleMatchSettings : null, 
        singleMatchSettings : null,
        objects : [],
        prefixes : [],
        noMatchURL : null
    };
    function getLayout(){return layout;}

    function init(){
        ctiPane                 = $('#ctiPage');
        loginPane               = $('#loginPage');
        failurePane             = $('#failurePane');
        usernameInput           = $('#username');
        passwordInput           = $('#password');
        agentNameField			= $('#agentNameField');
        selectedExtensionsDiv   = $('#selectedExtensionsDiv');
        loginForm               = $('#loginForm');

        sforce.interaction.cti.enableClickToDial();
        sforce.interaction.cti.onClickToDial(onClickToDialListener);
        sforce.interaction.cti.getSoftphoneLayout(function(response){
            var SoftphoneLayout = $.parseJSON(response.result);
        
            layout.target = SoftphoneLayout.Inbound.screenPopSettings.screenPopsOpenWithin;
            layout.noMatchSettings          = SoftphoneLayout.Inbound.screenPopSettings.NoMatch;
            layout.multipleMatchSettings    = SoftphoneLayout.Inbound.screenPopSettings.MultipleMatches;
            layout.singleMatchSettings      = SoftphoneLayout.Inbound.screenPopSettings.SingleMatch;
            for (var o in SoftphoneLayout.Inbound.objects ){
                layout.objects.push(o);
            }   

            CTIController.getObjectPrefixes(layout.objects, function(response){
                layout.prefixes = response;
            });

            Cookie.write(CTI.cookies.searchObjects, getCSVString(layout.objects));

            if(layout.noMatchSettings.screenPopType == 'PopToEntity'){
                CTIController.getObjectPrefix(layout.noMatchSettings.screenPopData, function(result, event){                   
                    if (event.status){
                        layout.noMatchSettings.screenPopData = result + '/e';
                    }
                    else{
                        CTI.debug.logError({
                            message : result,
                            line : 53,
                            url : "CTI_ui.resource"
                        });
                    }
                }); 
            }
        }); 
    }

    function displayCTIPane(){
    	agentNameField.text(CTI.user.getAgentName());
        var htm = '<select id="selectedExtensions" class="s1" multiple="multiple" size="3" >';
        var extensions = CTI.user.getExtensions();
        var selectedExtensions = CTI.user.getSelectedExtensions();
        if(extensions.length == selectedExtensions.length){
            for (var i=0;i<extensions.length; i++){
                htm += '<option value="' + extensions[i] + '" selected="selected">' + extensions[i] + '</option>';
            }
        }
        else{
            for (var i=0;i<extensions.length;i++){
                var isSelected = false;
                for(var j=0;j<selectedExtensions.length;j++){
                    if(extensions[i] == selectedExtensions[j]){
                        isSelected = true;
                        break;
                    }
                }
                if(selected){
                    htm += '<option value="' + extensions[i] + '" selected="selected">' + extensions[i] + '</option>';
                }
                else{
                    htm += '<option value="' + extensions[i] + '">' + extensions[i] + '</option>';
                }
            }
        }
        
        htm += '</select>';
        selectedExtensionsDiv.html(htm);

        //sets up the dialer pad
        $('#dialpad a').bind("click", function(e){
            var dialerField = $('#dialerField')
            var phoneNumber = dialerField.val();
            dialerField.val(phoneNumber + $(this).text());
        });

        loginPane.hide();
        ctiPane.show();
        
        $('[id$="selectedExtensions"]').dropdownchecklist({
            width: 100
        });
    }
    
    var PHONE = "con10=";
    var FIRST_NAME = "&name_firstcon2=";
    var LAST_NAME ="&name_lastcon2=";      
    var UID = "00NG0000009Soc2";
    function screenPop(callInfo){
        if(callInfo.clickToCall || callInfo.callerNumber == "Restricted")return;
        CTIController.searchForScreenPop(callInfo.formattedPhone, layout.objects, function(result, event){  
            
            if(!event.status){
        		CTI.debug.logError({
                    message : result,
                    line : 121,
                    url : "CTI_ui.resource"
                });
                return;
            }

            var names = callInfo.callerName.split(' ');
            var queryString = '?' 
                            + PHONE + callInfo.formattedPhone
                            + FIRST_NAME + names[0]
                            + LAST_NAME + names[names.length-1];
            var url;
            if( result == '0' ){
                switch(layout.noMatchSettings.screenPopType){
                    case 'PopToEntity':
                        url = '/' + layout.noMatchSettings.screenPopData
                            + queryString;
                        break;
                    case 'PopToVisualforce':
                        url = '/' + layout.noMatchSettings.screenPopData
                            + queryString;
                        break;
                    default: break;
                }
            }       
            else if( result == 'multiple' ){
                switch(layout.multipleMatchSettings.screenPopType){
                    case 'PopToSearch':
                        url = '/_ui/search/ui/UnifiedSearchResults'
                            + queryString + '&searchType=2' ;
                        break;
                    case 'PopToVisualforce':
                        url = '/apex/' 
                            + layout.multipleMatchSettings.screenPopData
                            + queryString
                            + "&objs=" + getCSVString(layout.objects);
                            
                        break;
                    default : break;
                }
                
                //Before we open a new tab for the multiple results
	            // store the cookie info
	            if( layout.target == 'NewWindow')
	            	CTI.user.saveToCookie();
            }       
            else{
                switch(layout.singleMatchSettings.screenPopType){
                    case 'PopToEntity':
                        url = '/' + result;
                        break;
                    case 'PopToVisualforce':
                        url = '/' + layout.singleMatchSettings.screenPopData
                            + queryString;
                        break;
                    default : break;
                }
            }    

            if(url){
                sforce.interaction.screenPop(url);
            }
        });
        
    }
    
    function displayLoginPane(){
        ctiPane.hide();
        loginPane.show();
        usernameInput.val("");
        passwordInput.val("");
    }

    function login(username, password){
        
        if(!username || !password){
            if(!loginForm.valid()){return;}
            username = usernameInput.val();
            password = passwordInput.val();
        }
        
        CTIController.login(username, password, function(user, event){       
            if (event.status && user != null) {
                Cookie.write_map(CTI.cookies.user, user);
                Cookie.write(CTI.cookies.login, 1);
                CTI.user.init();
                displayCTIPane();
                CTI.monitor.start();
            }
            else{
                alert(LOGIN_FAILURE);
                CTI.debug.logError({
                    message : event,
                    line : 203,
                    url : "CTI_ui.resource"
                });
            }
        });   
    }

    function logout(){
        CTI.clearCookies();
        CTI.call.clearActiveCalls();
        
        //CTI.resetCallDisplayed();
        CTI.monitor.stop();
        displayLoginPane();
    }

    function onClickToDialListener(response){
        var objectId = $.parseJSON(response.result).objectId;
        var phoneNumber = $.parseJSON(response.result).number.replace(/[\(\)+\-\s]/g,'');
        
        if(phoneNumber.length == 10){
            phoneNumber = '1' + phoneNumber;
        }
		
        clickToCall(phoneNumber);
    }    

    function clickToCall(phoneNumber){
        if(!phoneNumber)return;
        if(phoneNumber == "DEBUG"){
            return CTI.debug && CTI.debug.display();
        }
        
        CTIController.clickToCall(phoneNumber, CTI.user.getInfo(), function(result, event){                   
            if (!event.status){
                CTI.debug.logError({
                    message : result,
                    line : 246,
                    url : "CTI_ui.resource"
                });
            }
        });     
    }

    function getCSVString(list){
        var str = "";
        var first = true;
        for(var i=0;i<list.length;i++){
            str += (first?'':',') + list[i];
            first = false;
        }
        return str;
    }

    function displayApplicationFailure(){
        ctiPane.hide();
        loginPane.hide();
        failurePane.show();
    }

    return{
        init : init,
        login : login,
        logout : logout,
        getLayout : getLayout,
        screenPop   : screenPop,
        clickToCall : clickToCall,
        displayCTIPane : displayCTIPane,
        displayLoginPane : displayLoginPane,
        displayApplicationFailure : displayApplicationFailure
    }

})(jQuery);