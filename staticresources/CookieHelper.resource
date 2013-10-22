Date.now = Date.now || function() { return +new Date; }; 

var Cookie = {

	write : function (name,value,hours) {
		var expiration = ";expires=";

		if (hours) {
			expiration += new Date(Date.now()+(hours*60*60*1000)).toUTCString();
		}
		else{
			expiration += new Date(Date.now()+(24*60*60*1000)).toUTCString();
		}

		document.cookie = name+"="+value+expiration+"; path=/";
	},

	write_map : function (name,map,hours) {
		var expiration = ";expires=";

		if (hours) {
			expiration += new Date(Date.now()+(hours*60*60*1000)).toUTCString();
		}
		else{
			expiration += new Date(Date.now()+(24*60*60*1000)).toUTCString();
		}

		document.cookie = name+"="+JSON.stringify(map)+expiration+"; path=/";
	},

	read : function (name) {

		var nameEQ = name + "=";
		var ca = document.cookie.split(';');
		for(var i=0;i < ca.length;i++) {
			var c = ca[i];
			while (c.charAt(0)==' ') {
				c = c.substring(1,c.length);
			}

			if (c.indexOf(nameEQ) == 0){
				return c.substring(nameEQ.length,c.length);
			}
		}
		return null;
	},

	read_map : function (name) {

		var nameEQ = name + "=";
		var ca = document.cookie.split(';');
		for(var i=0;i < ca.length;i++) {
			var c = ca[i];
			while (c.charAt(0)==' ') {
				c = c.substring(1,c.length);
			}

			if (c.indexOf(nameEQ) == 0){
				return jQuery.parseJSON(c.substring(nameEQ.length,c.length));
			}

		}
		return null;
	},

	clear : function (name) {
		this.write(name,"",-1);
	}

}
