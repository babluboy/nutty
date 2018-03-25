
public class NuttyApp.Entities.Device : Object {
    public int device_id { get; set; default = -1; }
    public string device_ip { get; set; default = ""; }
    public string device_mac { get; set; default = ""; }
    public string device_hostname { get; set; default = ""; }
    public string device_manufacturer { get; set; default = ""; }
    public string device_hostname_custom { get; set; default = ""; }
    public string device_manufacturer_custom { get; set; default = ""; }
    public string device_alert { get; set; default = ""; }
    public string device_status { get; set; default = ""; }
    public string device_creation_date { get; set; default = ""; }
    public string device_last_seen_date { get; set; default = ""; }
    public bool is_device_updated {get;set;default = false; }
    
    public string to_string(){
        return 
            "device_id="+device_id.to_string()+" | "+
            "device_ip="+device_ip+" | "+
            "device_mac="+device_mac+" | "+
            "device_hostname="+device_hostname+" | "+
            "device_manufacturer="+device_manufacturer+" | "+
            "device_hostname_custom="+device_hostname_custom+" | "+
            "device_manufacturer_custom="+device_manufacturer_custom+" | "+
            "device_alert="+device_alert+" | "+
            "device_status="+device_status+" | "+
            "device_creation_date="+device_creation_date+" | "+
            "device_last_seen_date="+device_last_seen_date+" | "+
            "is_device_updated="+is_device_updated.to_string();
    }
}

