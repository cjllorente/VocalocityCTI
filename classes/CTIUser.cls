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