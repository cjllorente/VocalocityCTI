@isTest
private class CTIUtilitiesTest {

    static testMethod void testExceptionPrinting() {
		Account testAccount = new Account(Id = '001000008586858');
		
		try{
			insert testAccount;
			system.assert(false, 'Error should have occurred');
		}
		catch (exception ex){
			System.assert( String.isNotBlank( CTIUtilities.printExceptionInfo(ex) ) );
		}
    }
}