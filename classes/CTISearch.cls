public class CTISearch{

    private static final String SOSL = '*';
    private static final String SOQL = '%';

    private String phoneSOSLFormat;
    private String phoneSOQLFormat;

    private List<String> searchObjects;

    private Map<SObjectType, CTISearchResults> results;

    public CTISearch(String num, List<String> objs){
       phoneSOSLFormat = formatPhoneNumber(num, SOSL);
       phoneSOQLFormat = formatPhoneNumber(num, SOQL);

       searchObjects = objs;
       results = new Map<SObjectType, CTISearchResults>();
    }

	public Map<SObjectType, CTISearchResults> getSearchResults(){
		
		for(String obj : searchObjects){
            CTISearchResults r = new CTISearchResults().setObjectType(obj);
			results.put(r.objectType, r);
		}

        getSOSLResults();
        getSOQLResults();

		return results;
	}

    private void getSOSLResults(){
        String query = 'Find \'' + phoneSOSLFormat +'\' IN PHONE FIELDS RETURNING ';

        boolean first = true;
        for(CTISearchResults searchObject : results.values()){
            query += (first ? '' : ',')
                  + searchObject.objectName 
                  + ' (Id, ' 
                  + searchObject.nameField 
                  + getPhoneFieldsString(searchObject.phoneFields)
                  + ' WHERE LastModifiedDate < TODAY '
                  + (searchObject.objectName == 'Lead'
                    ? 'AND IsConverted = false )'
                    : ')' );
            first = false;
        }

        List<List<SObject>> queryResults = Search.query(query);
        for(List<SObject> result : queryResults){
            if(!result.isEmpty()){
                SObjectType key = result[0].getSObjectType();
                results.get(key).addAll(result);
            }
        }
    }
    
    private void getSOQLResults(){
        List<List<SObject>> queryResults = new List<List<SObject>>();
        for(CTISearchResults searchObject : results.values()){
            if(!searchObject.phoneFields.isEmpty()){
                String query = 'SELECT Id, ' 
                             + searchObject.nameField 
                             + getPhoneFieldsString(searchObject.phoneFields)
                             + ' FROM ' + searchObject.objectName
                             + ' WHERE LastModifiedDate = TODAY ' 
                             + getPhoneFieldsQuery(searchObject.phoneFields)
                             + (searchObject.objectName == 'Lead'
			                    ? ' AND IsConverted = false'
			                    : '');
                queryResults.add(Database.query(query)); 
            }
        }

        for(List<SObject> result : queryResults){
            if(!result.isEmpty()){
                SOBjectType key = result[0].getSObjectType();
                results.get(key).addAll(result);
            }
        }
    }

    private String getPhoneFieldsString(List<String> fields){
        String str = '';
        for(String field : fields){
            str += ', '+field;
        }
        return str;
    }

    private String getPhoneFieldsQuery(List<String> fields){
        String str = '';
        boolean first = true;
        for(String field : fields){
            str += (first ? 'AND (' : ' OR ') + field + ' LIKE \'' + phoneSOQLFormat + '\'';
            first = false;
        }
        return (str != '' ? str + ')' : '');
    }
    
    private String getNameField(String obj){

        List<Schema.SObjectField> sfields = Schema.getGlobalDescribe()
                                                 .get(obj)
                                                 .getDescribe()
                                                 .fields
                                                 .getMap()
                                                 .values();
        
        for( Schema.SObjectField sField : sfields){
            if(sField.getDescribe().isNameField()){
                return sField.getDescribe().getName(); 
            }
        }
        
        return '';
    }

    private List<String> getPhoneFields(String obj){
        List<String> phoneFields = new List<String>();
        List<Schema.SObjectField> sfields = Schema.getGlobalDescribe()
                                                 .get(obj)
                                                 .getDescribe()
                                                 .fields
                                                 .getMap()
                                                 .values();
        
        for( Schema.SObjectField sField : sfields){
            if( sField.getDescribe().getType() == Schema.DisplayType.Phone){
                phoneFields.add(sField.getDescribe().getName());
            }
        }
        return phoneFields;
    }

    public static String formatPhoneNumber(String phoneNumber, String wildCard){
        String formattedPhoneNumber = String.escapeSingleQuotes(phoneNumber);
        
        if (String.isNotEmpty(phoneNumber)){
            formattedPhoneNumber = formattedPhoneNumber
                                    .deleteWhitespace()
                                    .replace('(' , wildCard)
                                    .replace(')' , wildCard)
                                    .replace('-' , wildCard);
        }
        return formattedPhoneNumber;
    }
}