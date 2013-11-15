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

global class CTISearchResults {

	public String objectName{get;set;}
	public Schema.SObjectType objectType{get;set;}

	public List<SObject> objects{get;set;}
	public String label{get;set;}
	public String labelPlural{get;set;}
	public String imageURL{get;set;}
	public String nameField{get;set;}
	public Integer size{get;set;}
	public List<String> phoneFields{get;set;}
	

	public CTISearchResults(){
		objectName = '';
		label = '';
		labelPlural = '';
		imageURL = '';
		nameField = '';
		size = 0;
		objects = new List<SObject>();
		phoneFields = new List<String>();
	}	

	//this method must be called immediately after construction
	public CTISearchResults setObjectType(String obj){
		objectName = obj;
		objectType = Schema.getGlobalDescribe().get(objectName);
		if(objectType == null){
			throw new CTITypeException('No SObject type exists for \'' + objectName + '\''); //placeholder
		}
		
		Schema.DescribeSObjectResult describe = objectType.getDescribe();
		label = describe.getLabel();
		labelPlural = describe.getLabelPlural();
		imageURL = '/img/icon/' + labelPlural.toLowercase() +'32.png';
		
		for(Schema.SObjectField sField : describe.fields.getMap().values()){
			Schema.DescribeFieldResult fieldDescribe = sField.getDescribe();
			if(fieldDescribe.getType() == Schema.DisplayType.Phone){
				phoneFields.add(fieldDescribe.getName());
			}
			else if(fieldDescribe.isNameField()){
				nameField = fieldDescribe.getName();
			}
		}
		return this;
	}

	public void add(SObject obj){
		if(objectType == null)return;
		if(obj.getSObjectType() == objectType){
			objects.add(obj);
			size++;
		}
	}

	public void addAll(List<SObject> objs){
		if(objectType == null)return;
		for(SObject obj : objs){
			add(obj);
		}
	}
	
	public String getFirstId(){
		if(objects.size() > 0){
			return objects[0].Id;
		}
		return null;
	}
}