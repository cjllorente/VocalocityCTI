public class CTIUtilities{   
    public static String printExceptionInfo(Exception ex){
        String info = '--> ' + ex.getMessage() + '\n' + ex.getStackTraceString();
        System.debug(LoggingLevel.ERROR, info);
        return info;
    }   
    
    public static String getObjectTypeById(String id){
        String idPrefix = id.substring(0,3);
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe(); 
        for(Schema.SObjectType stype : gd.values()){
            Schema.DescribeSObjectResult r = stype.getDescribe();
            String prefix = r.getKeyPrefix();
            if(prefix!=null && prefix == idPrefix){
                return r.getName();
            }
        }
        return '';
    }
}