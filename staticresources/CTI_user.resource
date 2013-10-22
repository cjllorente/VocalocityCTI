CTI.namespace("user");
CTI.user = (function($){
	//private variables
	var loggedIn = false;

	//public variables
	var firstName,
		lastName,
		loginName,
		password,
		hdapToken,
		sessionId,
		softPhoneObjects,
		userId,
		url,
		extensions,
		selectedExtensions,
		uid;

	function init(){
		var cookie = Cookie.read_map(CTI.cookies.user);
		if(cookie){
			firstName 			= cookie.firstName;
			lastName 			= cookie.lastName;
			loginName 			= cookie.loginName;
			password 			= cookie.password;
			hdapToken 			= cookie.hdapToken;
			sessionId 			= cookie.sessionId;
			url					= cookie.url;
			softPhoneObjects 	= cookie.softPhoneObjects;
			userId 				= cookie.userId;
			extensions 			= cookie.extensions;
			selectedExtensions 	= cookie.selectedExtensions;
		}
	}

	function saveToCookie(){
		var info = getInfo();
		Cookie.write_map(CTI.cookies.user, info);
	}

	//getters
	function getExtensions(){return extensions;}
	function getSelectedExtensions(){return selectedExtensions;}
	function getAgentName(){
		return firstName + " " + lastName;
	}
	function getInfo(){
		return{
			firstName 			: firstName,
			lastName 			: lastName,
			loginName 			: loginName,
			password 			: password,
			hdapToken 			: hdapToken,
			sessionId 			: sessionId,
			url					: url,
			softPhoneObjects 	: CTI.ui.getLayout().objects,
			userId 				: userId,
			extensions 			: extensions,
			selectedExtensions 	: selectedExtensions
		};
	}
	
	return {
		init 					: init,
		saveToCookie			: saveToCookie,
		getExtensions 			: getExtensions,
		getSelectedExtensions 	: getSelectedExtensions,
		getAgentName			: getAgentName,
		getInfo 				: getInfo
	};

})(jQuery);