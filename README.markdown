# Actionscript 3 Rest Client library

## Summary
This library is a wrapper class for httpservice and urlloader objects that was created to get around the problem with the flash player not being able to use PUT, DELETE requests with rest services.
I created it for use with my mobile app [Remote Admin](http://www.remoteadmin.co).
There are other http rest clients available for AS3 but some of them lacked HTTPS functionality.

## Features
1. HTTP and HTTPS support
2. Supports GET, POST, PUT, DELETE commands.  Other commands can easily be accommodated. 
3. Works with Adobe Air
4. Only Supports JSON encoding at this time, but can easily be changed

## Example Usage
<pre>
        // create the restclient
	restclient = new RestClient();
        
	// sets up the restclient
	if (creds.length > 0){
        // creds is a username, password Base64 encoded String, optional
		restclient.credentials = creds;
	}
		restclient.host = host;
		restclient.port = port
		// secure is a boolean value
		restclient.secure = true;
	}
	restclient.setupRequest(RestClient.METHOD_GET, "puppetclasses");
	restclient.addparam("format","json");
	restclient.addEventListener(RestEvent.RESULT, onResult);
	restclient.sendrequest();
        
        //example onResult Handler
        // Note: there is no fault handler as I combined them into one Event
        private function onResult(event:RestEvent):void{
		restclient.removeEventListener(RestEvent.RESULT, onResult);
		switch(event.description){
			case RestClient.SUCCESS:
				this.dispatch(new ClientEvent(this.eventtype, data, event.statuscode, ForemanClientEvent.SUCCESS_RESULT));
				break;
			case RestClient.ACCESS_DENIED:
				this.dispatch(new ClientEvent(ForemanClientEvent.ACCESS_DENIED, null, event.statuscode, event.message));
				break;
			case RestClient.FAILURE:
				this.dispatch(new ClientEvent(ForemanClientEvent.FAILED_RESULT, null, event.statuscode, event.message));
				break;
			
			default:
				break;
		}
       }
</pre>

## Want to Contribute?
Please if you see any mistakes, or want to add features, email me.  

PATCHES: corey@logicminds.biz