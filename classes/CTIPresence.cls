public class CTIPresence {

	//Custom setting
	private static final String HDAP_END_POINT = 'CTIEndpoint';

	//Script URLs
	private static final String LOGIN_URL = '/appserver/rest/user/null';
	private static final String GET_ALL_EXTENSIONS_URL = '/appserver/rest/userextension';
	private static final String MONITOR_EXTENSIONS_URL = '/presence/dashui';
	private static final String CLICK_TO_CALL_URL = '/presence/rest/clicktocall';

	//HTTP Methods
	public static final String GET = 'GET';

	//Handled HTTP status codes
	private static final Integer HTTP_OK = 200;
	private static final Integer HTTP_NOT_MODIFIED = 304;
	private static final Integer HTTP_UNAUTHORIZED = 401;
	private static final Integer HTTP_CONFLICT = 409;

	//Misc keys
	public static final String HDAP_TOKEN_KEY = 'Set-Cookie';
	public static final String HDAP_ID = 'HDAP-ID=';
	public static final String LOGIN = 'login';
	public static final String PASS = 'password';
	public static final String CACHE_BUSTER = '_dc=';

	//Misc
	public static final String LOGGED_OUT = 'Logged out';
	public static final String NOT_MODIFIED = 'Not modified';
	public static final String CONFLICT_DETECTED = 'Conflict detected';
	public static final String BAD_RESPONSE = 'Bad response from HDAP: ';
	public static final String NO_CALL_DATA = 'No call data';
	public static final Integer BLOCK_INTERVAL = 110; //110 seconds
	public static final Integer HTTP_TIMEOUT = 120000; //120 seconds

	private static String hdapEndpoint{
		get{
			if(Test.isRunningTest()){
				hdapEndpoint = 'test.vocalocity.com';
				return hdapEndpoint;
			}
			else if(hdapEndpoint == null){
		        hdapEndpoint = HdapEndpoint__c.getValues(HDAP_END_POINT).apiURL__c;
			}
			return hdapEndpoint;
		}set;
	}

	private static HttpResponse makeCallout(String baseURL, String params){

		HttpRequest request = new HttpRequest();
		request.setTimeout(HTTP_TIMEOUT);
		request.setMethod(GET);	
		request.setEndpoint(baseURL + params);
		
		try{
			if(Test.isRunningTest()){
				return CTIMockCallout.getResponse(params);
			}
			HttpResponse response = new Http().send(request);
			return response;
		}catch (CalloutException ex){
			CTIUtilities.printExceptionInfo(ex);
			return null;
		}
	}

	private static HttpResponse makeLoginCallout(String baseURL, String params, String username, String password){

		HttpRequest request = new HttpRequest();
		request.setTimeout(HTTP_TIMEOUT);
		request.setMethod(GET);	
		request.setHeader(LOGIN, username);
		request.setHeader(PASS, password);
		request.setEndpoint(baseURL + params);
		
		try{
			if(Test.isRunningTest()){
				return CTIMockCallout.getResponse(params);
			}
			HttpResponse response = new Http().send(request);
			return response;
		}catch (CalloutException ex){
			CTIUtilities.printExceptionInfo(ex);
			return null;
		}
	}

	public static CTIUser getUserLogin(String username, String password){

		HttpRequest request = new HttpRequest();
		request.setTimeout(HTTP_TIMEOUT);
		request.setMethod(GET);
		request.setEndpoint(hdapEndpoint + '?username='+username);
		
		String baseURL;

		try{

			if(Test.isRunningTest()){
				baseURL = 'test.vocalocity.com';
			}
			else{
				HttpResponse response = new Http().send(request);
				Map<String, Object> body = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
				baseURL = ((String)body.get('dashboardHost')).replace('http:','https:');
			}
			
		}catch (CalloutException ex){
			CTIUtilities.printExceptionInfo(ex);
			return null;
		}

		HttpResponse response = makeLoginCallout(baseURL, LOGIN_URL, username, password); 
		if(response == null || response.getStatusCode() != HTTP_OK){
			return null;
		}

		CTIUser user = (CTIUser)JSON.deserialize(response.getBody(), CTIUser.class);
		user.sessionId 			= UserInfo.getSessionId(); 
		user.password 			= password;
		user.url 				= baseURL;
		user.displayed 			= false;
		user.extensions 		= getUserExtensions(user);
		user.selectedExtensions = user.extensions;
		user.hdapToken 			= EncodingUtil.urlEncode(response.getHeader(HDAP_TOKEN_KEY).substringBetween(HDAP_ID, ';'),'UTF-8');
		return user;
    }

    public static List<String> getUserExtensions(CTIUser user){
		HttpResponse response = makeLoginCallout(user.url, GET_ALL_EXTENSIONS_URL + '/' + user.userId, user.loginName, user.password);
		if(response == null || response.getStatusCode() != HTTP_OK){
			return new List<String>();
		}
	
		List<String> extensions = new List<String>();
		Dom.Document document = response.getBodyDocument();
		for (Dom.XMLNode ext : document.getRootElement().getChildElements()){
			extensions.add(ext.getChildElement('extension', null).getText());
		}

		return extensions;
	}	

	public static String clickToCall(String phoneNumber, CTIUser user){
		HttpResponse response = makeLoginCallout(user.url, CLICK_TO_CALL_URL + '/' + phoneNumber,
												user.loginName,
												user.password);
		return response.getBody();
	}

	public static List<CTICallInfo> getCallStatus(CTIUser user, boolean refresh){ 
		String params = MONITOR_EXTENSIONS_URL +
						'?hdapid=' + user.hdapToken + 
						'&mysession=' + user.hdapToken +
						'&filterExtension=' + user.getSelectedExtensionsForURL() +
						'&' + CACHE_BUSTER + randomString(user.loginName);
		if(refresh){
			params += '&firstRequest=true';
		}
		else{
			params += '&firstRequest=false' +
					  '&blockInterval=' + BLOCK_INTERVAL;
		}

		HttpResponse response = makeCallout(user.url, params);
		Integer statusCode = response.getStatusCode();
		String body = response.getBody();
					
		if(statusCode == HTTP_UNAUTHORIZED){
			return new List<CTICallInfo>{new CTICallInfo(LOGGED_OUT)};
		}
		else if(statusCode == HTTP_NOT_MODIFIED){
			return new List<CTICallInfo>{new CTICallInfo(NOT_MODIFIED)};
		}
		else if(statusCode == HTTP_CONFLICT){
			return new List<CTICallInfo>{new CTICallInfo(CONFLICT_DETECTED)};
		}
		else if(statusCode != HTTP_OK){
			System.debug('BAD RESPONSE FROM PRESENCE\n' 
						+ statusCode + '\n' + 
						+ body);
			return new List<CTICallInfo>{new CTICallInfo(BAD_RESPONSE + statusCode + body)};
		}
		
		Map<String, Object> jsn = (Map<String, Object>)JSON.deserializeUntyped(body);
		List<Object> extensions = (List<Object>)jsn.get('extensions');

		List<CTICallInfo> activeCalls = new List<CTICallInfo>();

		Map<String, String> phoneToUID = new Map<String, String>();
		for(Object m : extensions){
			Map<String, Object> mso = (Map<String, Object>)m;
			CTICallInfo call = new CTICallInfo(
									(String)mso.get('name'),
									(String)mso.get('status'),
									(String)mso.get('onCallWith'),
									(Map<String, Object>)mso.get('statusItems')
								);
			if( !call.isIntrapbx() &&
				!(call.startedWithClickToCall() && call.isInboundCall()) ){
				activeCalls.add(call);
			}
		}
		if(activeCalls.isEmpty()){
			activeCalls.add(new CTICallInfo(NOT_MODIFIED));	
		}
		return activeCalls;
	}

	private static String randomString(String username) 
    {
		Integer result = (Integer)(Math.random() * 1000000000);
		String randomString = String.valueOf(result);
		return randomString;
    }  
}