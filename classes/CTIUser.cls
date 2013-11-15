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

global class CTIUser {

    public String sessionId;
    public String userId;
    public String firstName;
    public String lastName;
    public String loginName;
    public String password;
    public String hdapToken;
    public String objectId;
    public String uid;
    public String url;
    public Boolean clickToDial;

    public List<String> extensions;
    public List<String> selectedExtensions;
    
    public boolean displayed;
    public List<String> softPhoneObjects;

    public CTIUser(){
    }

    public String getSelectedExtensionsForURL(){
        String filterExtensions = '';
        boolean first = true;
        for(String ext : selectedExtensions){
            if(first){
                first = false;
                filterExtensions += ext;    
            } 
            else{
                filterExtensions += ','+ ext;
            }
        }
        return filterExtensions;
    }
}