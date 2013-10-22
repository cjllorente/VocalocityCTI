@isTest
public class CTISearchControllerTest {

	static Contact testContact;
	static Task testTask;
	static void setup(){
		testTask = new Task();
		testContact = new Contact(LastName='test',  phone = '155555555555');
	}
	
	static testMethod void testFindSearchResults(){
		setup();
		insert testContact;
		insert testTask;
		List<CTISearchResults> searchResults;
		
		test.startTest();
			CTISearchController controller = new CTISearchController();
			searchResults = controller.searchResults;
		test.stopTest();

		System.assertEquals(1, searchResults.size());
		System.assertEquals(testContact.Id, searchResults[0].getFirstId());
	}
}