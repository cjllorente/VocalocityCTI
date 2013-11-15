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

global with sharing class CTISearchController { 

	private static String PHONE = 'con10'; 
	private static String OBJECTS = 'objs';

	public List<CTISearchResults> searchResults{
		get{
			if(searchResults == null){
				List<String> searchObjects = getSearchObjects(); 
				Map<SObjectType, CTISearchResults> resultsMap = new CTISearch(getPhoneParam(), searchObjects).getSearchResults();
				searchResults = new List<CTISearchResults>(); 
				for(String obj : searchObjects){
					searchResults.add(resultsMap.get(Schema.getGlobalDescribe().get(obj)));
				}
			}
			
			return searchResults;
		}set;
	} 
	
	private static String getPhoneParam(){
		if(Test.isRunningTest()){
			return '155555555555';
		}
		else{
			return ApexPages.currentPage()
                   .getParameters()
                   .get(PHONE);	
		}
    }  

    private static List<String> getSearchObjects(){
        
		if(Test.isRunningTest()){
			return new List<String>{'Contact'};
		}
		else{
			System.Cookie searchObjects = ApexPages.currentPage().getCookies().get('search_objects');
			String objs = null;
			if(searchObjects != null){
				objs = searchObjects.getValue();
			}
			else{
				objs = ApexPages.currentPage()
					           .getParameters()
					           .get(OBJECTS);
			}
			
			return (objs!=null ? objs.split(',') : new List<String>{'Contact'});
		}     
    }    
}