@isTest
private class CTIUserTest{
    static testMethod void TestUser(){
        CTIUser testUser = new CTIUser();
        testUser.sessionId='';
        testUser.userId='';
        testUser.firstName='';
        testUser.lastName='';
        testUser.loginName='';
        testUser.password='';
        testUser.hdapToken='';
        testUser.objectId='';
    
        testUser.extensions = new List<String>();
        testUser.selectedExtensions = new List<String>();
        
        testUser.displayed = false;

        System.assert(testUser.sessionId == '');
        System.assert(testUser.userId == '');
        System.assert(testUser.firstName == '');
        System.assert(testUser.lastName == '');
        System.assert(testUser.loginName == '');
        System.assert(testUser.password == '');
        System.assert(testUser.hdapToken == '');
        System.assert(testUser.objectId == '');
        System.assert(testUser.displayed  ==  false);
    }
}