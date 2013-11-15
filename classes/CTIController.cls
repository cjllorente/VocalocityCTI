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

global with sharing class CTIController{
	
	//namespaces change based on environment
	private static final String DEVELOPMENT = 'vocalocitysfcti__'; 
	private static final String MANAGED = 'vocalocitysfcti__';
	private static final String UNMANAGED = '';
	
	global static final String NAMESPACE = MANAGED;
	
	@RemoteAction
	global static String getNamespace(){
		return NAMESPACE;
	} 

    @RemoteAction
    global static List<CTICallInfo> monitor(CTIUser user, boolean refresh){
        return CTIPresence.getCallStatus(user, refresh);
    }
    
    @RemoteAction
    global static String getObjectPrefix(String obj){
        if (String.isBlank(obj)){
            return '';
        }

        Map<String, Schema.SObjectType> objects = Schema.getGlobalDescribe();
        return  objects
                .get(obj)
                .getDescribe()
                .getKeyPrefix();
    }

    @RemoteAction
    global static List<String> getObjectPrefixes(List<String> objectList){
        if (objectList.isEmpty()){
            return null;
        }

        Map<String, Schema.SObjectType> objects = Schema.getGlobalDescribe();
        List<String> prefixes = new List<String>();

        for(String obj : objectList){
            prefixes.add(objects.get(obj).getDescribe().getKeyPrefix());
        }
        
        return prefixes;
    }
    
    @RemoteAction
    global static String searchForScreenPop( String phone, List<String> objectsToSearch){
        CTISearch queries = new CTISearch(phone, objectsToSearch);
        Map<SObjectType, CTISearchResults> searchResults = queries.getSearchResults();
        Integer recordsFound = 0;
        String firstId;
        for(CTISearchResults result : searchResults.values()){
            recordsFound += result.size;
            if(firstId == null){
                firstId = result.getFirstId();
            }
        }
        
        if (recordsFound == 0){
            return '0';
        }
        else if (recordsFound == 1){
            return firstId;
        }
        return 'multiple';
    }
    
    @RemoteAction
    global static Long getCallDuration(Long startTime){
        Long endTime = DateTime.now().getTime();
        Long duration = (endTime - startTime)/1000;
        return  (duration > 0 ? duration : 0);
    }

    @RemoteAction
    global static String clickToCall(String phoneNumber, CTIUser user){
        return CTIPresence.clickToCall(phoneNumber, user);
    }
    
    @RemoteAction
    global static Map<String, String> saveLog(Map<String, Object> params){
    	Map<String, String> response = new Map<String, String>();

    	Task t = new Task(Id = (String)params.get('Id'));
    	
    	Decimal activityDate = ((Decimal)params.get('ActivityDate')); 
    	if(activityDate != null){
    		t.ActivityDate = (DateTime.newInstance(activityDate.longValue())).date(); 	
    	}
		for(String field : params.keySet()){
			if(field == 'Id' || field == 'ActivityDate')continue;
			Object value = params.get(field);
			if(value instanceof Decimal){
				t.put(field, ((Decimal)value).intValue());
			}
			else{
				t.put(field, value);	
			}
		}
    	if(t.Id == null){
    		try{
    			insert t;
    		}catch(DmlException e){
    			String msg = e.getDmlMessage(0);
    			if(e.getDmlType(0) == System.StatusCode.DUPLICATE_VALUE){
                    String uidField = NAMESPACE+'uid__c';
    				String taskUID = (String)params.get(uidField);
                    String q    = 'SELECT Id FROM Task WHERE ' 
                                + uidField + ' = :taskUID';
    				Task dupe = Database.query(q);
    				response.put('result', dupe.Id);
					return response;
				}
				System.debug(LoggingLevel.ERROR, msg);
				response.put('error', msg);
				return response;
    		}
    	}
    	else{
    		try{
    			update t;
    		}catch(DmlException e){
    			String msg = e.getDmlMessage(0);
				System.debug(LoggingLevel.ERROR, msg);
				response.put('error', msg);
				return response;
    		}    		
    	}
		response.put('result', t.Id);
    	return response;    	
    }

    @RemoteAction
    global static CTIUser login(String username, String password){
        return CTIPresence.getUserLogin(username, password);
    }

    /* TODO: determine if some action must be taken when a user logs out
    @RemoteAction
    global static boolean logout(){
        //placeholder
        return true;
    }*/
}