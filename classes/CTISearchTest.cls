@isTest
private class CTISearchTest {

	static final String phoneNumber = '(555) 555 - 5555';
	static final Integer NUMBER_OF_OBJECTS = 3;
	static List<String> objects = new List<String>{'Contact', 'Lead', 'Account'};

	static CTISearch searchTest;

	static Contact testContact;
	static Account testAccount;
	static Lead testLead;

	static void setup(){
		searchTest = new CTISearch(phoneNumber, objects);

		testContact = new Contact(LastName = 'test', Phone = phoneNumber);
		testAccount = new Account(Name = 'test', Phone = phoneNumber);
		testLead = new Lead(LastName = 'test', Company = 'test co.', Phone = phoneNumber);

		List<SObject> objs = new List<SObject>{testContact, testAccount, testLead};
		insert objs;
	}

	static testMethod void testGetSearchResults(){
		setup();
		test.startTest();
			Map<SObjectType, CTISearchResults> testResults = searchTest.getSearchResults();
		test.stopTest();

		System.assertEquals(NUMBER_OF_OBJECTS, testResults.size());
		System.assertEquals(testContact.Id, testResults.get(testContact.getSObjectType()).getFirstId());
		System.assertEquals(testAccount.Id, testResults.get(testAccount.getSObjectType()).getFirstId());
		System.assertEquals(testLead.Id, testResults.get(testLead.getSObjectType()).getFirstId());
	}

	static testMethod void testInvalidObjectException(){
		boolean exceptionThrown = false;
		CTISearch invalidSearch = new CTISearch(phoneNumber, new List<String>{'qwerqwerqwerqwer'});
		test.startTest();
		try{
			invalidSearch.getSearchResults();
		}catch(CTITypeException ex){
			exceptionThrown = true;
		}
		test.stopTest();

		System.assert(exceptionThrown);
	}
	
    static testMethod void testPhoneFormatting() {
    	List<String> testNumbers = new List<String>{
    		'(123)456-7890',
    		' ( 123 ) 456 - 7890 '
		};
    	test.startTest();
    		for(Integer i=0;i<testNumbers.size();i++){
    			testNumbers[i] = CTISearch.formatPhoneNumber(testNumbers[i], '%');
    		}
    	test.stopTest();

    	System.assert(testNumbers.size() > 0);
    	for(String num : testNumbers){
    		System.assertEquals('%123%456%7890', num);
    	}
    }
}