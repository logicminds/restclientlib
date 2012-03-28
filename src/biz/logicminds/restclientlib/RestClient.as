package biz.logicminds.restclientlib
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.HTTPStatusEvent;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	
	import mx.rpc.AsyncResponder;
	import mx.rpc.AsyncToken;
	import mx.rpc.IResponder;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;
	
	public class RestClient extends EventDispatcher
	{
		private var endpoint:String;
		// used to read data
		private var conn:HTTPService;
		// used to write data
		private var loader:URLLoader;
		private var request:URLRequest;
		public var host:String;
		public var url:String;
		private var _resource:String;
		public var resourceid:String;
		public var port:String;
		public var secure:Boolean;
		private var _sslauth:Boolean;
	
		
		//public var hostname:String;
		private var restparams:Array = [];
		
		
		public static const SUCCESS:String = "success";
		public static const FAILURE:String = "failure";
		public static const ACCESS_DENIED:String = "accessdenied";
		public static const METHOD_GET:String = "GET";
		public static const METHOD_POST:String = "POST";
		public static const METHOD_DELETE:String = "DELETE";
		public static const METHOD_PUT:String = "PUT";
		public static const JSONFORMAT:String = "application/json";
		
		public function RestClient(target:IEventDispatcher=null)
		{
			super(target);
			loader = new URLLoader();
			request = new URLRequest();
			// Lets create the http object and then set the attributes
			conn = new HTTPService();
			createhttpobject();
			createloader();
		}
		private function createloader():void{
			
			loader.dataFormat = "text";
			loader.addEventListener ( IOErrorEvent.IO_ERROR, handleIOError );
			loader.addEventListener ( HTTPStatusEvent.HTTP_STATUS, handleHttpStatus );
			// This gives a null exception when enabled
			//	loader.addEventListener ( HTTPStatusEvent.HTTP_RESPONSE_STATUS, handleHttpResponseStatus );
			loader.addEventListener ( SecurityErrorEvent.SECURITY_ERROR, handleSecurityError );
			loader.addEventListener ( Event.COMPLETE, handleComplete );
			// set the credentials
			
		}
		
		private function createhttpobject():void{
		
			// Set the type of data we expect to get back
			this.conn.resultFormat = "text";
			
			// Set the default method to Get
			method = RestClient.METHOD_GET;
			
			// default security is false http
			this.secure = false;
			
			this.setcontentType();
			
			this.conn.request.authenticate = false;
			
			// Set the timeout to 15 seconds
			this.timeout = 15;
			
		}
		public function setupRequest(httpmethod:String, httpresource:String):void{
			method = httpmethod;
			resource = httpresource;
			clearparams();
		}
		public function set resource(res:String):void{
			_resource = res;
			this.resourceid = null;
		}
		public function get resource():String{
			return _resource;
		}
		
		public function set method(method:String):void{
			this.conn.method = method;
			this.request.method = method;
		}
		public function get method():String{
			return this.conn.method;	
		}
		public function set timeout(time:int):void{
			this.conn.requestTimeout = time;
			
		}
		public function get timeout():int{
			return this.conn.requestTimeout;
		}
		public function addparam(param:String, paramvalue:String):void{
			
			this.restparams.push(param + "=" + paramvalue);
		}
		public function getparams():Array{
			return restparams;
		}
		public function clearparams():Boolean{
			restparams = [];
			return true;
		}
		public function set credentials(encoded:String):void{
			// this makes the user skip the ssl verify popup
			//this.conn.request.authenticate = false;
			if (encoded){
			// Set the other headers too
				var header:Object=new Object();
				header["Accept"] = "application/json";
				header["Authorization"] = "Basic " + encoded;
				this.conn.headers = header;
				var urlheader:URLRequestHeader = new URLRequestHeader("Authorization","Basic " + encoded);
				request.requestHeaders.push(urlheader);
			}
			//this.request.authenticate = false;
			//URLRequestDefaults.setLoginCredentialsForHost();
		}
		
		private function gethttpformat():String{
			if (secure){
				return "https://"; 
			}
			else{
				return "http://";
			}
			
		}
		private function buildurl():String{
			var url:String = gethttpformat() + this.host + ":" + port + "/" + resource;
			if (resourceid){
				url = url.concat("/" + resourceid);
			}
			if (restparams.length > 0){
				url = url.concat("?" + restparams.join("&"));
			}
			return url;
			
		}
		
		public function setcontentType(type:String=RestClient.JSONFORMAT):void{
			switch(type){
				case RestClient.JSONFORMAT:
					this.conn.contentType = RestClient.JSONFORMAT;
					request.contentType = RestClient.JSONFORMAT;
					var header:URLRequestHeader = new URLRequestHeader("Accept", RestClient.JSONFORMAT); 
					request.requestHeaders.push(header);
					break;
			
				
			}
		}
		public function sendrequest(dataobj:Object=null):AsyncToken{
			// this will build the url and set it each time sendrequest is called
			var asyncToken:AsyncToken;
			var iresponder:IResponder;
			var url:String = buildurl();
			if (dataobj){
				var dataString:String = JSON.stringify(dataobj);
			}
			switch(method){
				case RestClient.METHOD_GET:
					this.conn.url = url;
					iresponder = new AsyncResponder(onResult, onFault, asyncToken);
					asyncToken = this.conn.send();
					asyncToken.addResponder(iresponder);
					break;
				case RestClient.METHOD_POST:
					this.conn.url = url;
					iresponder = new AsyncResponder(onResult, onFault, asyncToken);
					asyncToken = this.conn.send(dataString);
					asyncToken.addResponder(iresponder);
					break;
				case RestClient.METHOD_PUT:
					request.url = url;
					request.data = unescape(dataString);
					loader.load(request);
					break;
				case RestClient.METHOD_DELETE:
					request.url = url;
					request.data = unescape(dataString);
					loader.load(request);
					break;
				
			}
			return asyncToken;
		
		}
		
		/// RESULTS EVENTS BELOW
		private function onResult(event:ResultEvent,token:Object=null):void
		{
			trace("Reached onResult handler");
			var rawData:String = String(event.result);
			event.token.dispatchEvent(new RestEvent(RestEvent.RESULT, RestClient.SUCCESS, rawData,event.statusCode,null,event.token));
		
		}
		private function onFault(event:FaultEvent, token:Object=null):void{
			// Lets try and parse the error to be more meaningful
			trace("Reached onfault handler");
			var error:String;
			switch (event.statusCode){
				case 401:
					error = event.statusCode + ": Access denied,\n check credentials";
					event.token.dispatchEvent(new RestEvent(RestEvent.RESULT, RestClient.ACCESS_DENIED, null, event.statusCode,  event.fault.faultString,event.token));
					break;
				//redirected but still ok, difficult to determine if its ok
				case 302:
					var rawData:String = String(event.fault);
					event.token.dispatchEvent(new RestEvent(RestEvent.RESULT, RestClient.SUCCESS, rawData,event.statusCode,null,event.token));
				case 201:
					// item created
					event.token.dispatchEvent(new RestEvent(RestEvent.RESULT, RestClient.SUCCESS, null,event.statusCode,null,event.token));
					break;
				case 422:
					//already exists
					trace(event.message.body);
					event.token.dispatchEvent(new RestEvent(RestEvent.RESULT, RestClient.FAILURE,null,event.statusCode,event.message.body.toString(),event.token));
					break;
				default:
					error = event.statusCode + ": " +event.fault.faultString;
					event.token.dispatchEvent(new RestEvent(RestEvent.RESULT, RestClient.FAILURE,null, event.statusCode,  event.fault.faultString, event.token));
					break;
			}
		
			
			trace(event.fault.faultString);
			
		}
		//request.requestHeaders.push(new URLRequestHeader({Accept:"application/json"}));
		
		//request.requestHeaders.push(new URLRequestHeader("X-HTTP-Method-Override", URLRequestMethod.PUT));
		
		// Attempt to load some data
		
		private function handleIOError ( event:IOErrorEvent ):void
		{
			trace ( "Reached handleIOError : Load failed: IO error: " + event.text );
			this.dispatchEvent(new RestEvent(RestEvent.IOERROR,null,event.target.data));
			// event.target.data  --> this contains the json data
			//this.dispatchEvent(new RestEvent(RestEvent.RESULT, RestClient.FAILURE,null, event.statusCode,  event.fault.faultString));

		}
		private function handleHttpStatus ( event:HTTPStatusEvent ):void
		{
			trace("reached handlehttpstatus handler");
			switch (event.status){
				case 200:
					// Ok, everything went good
					trace("200, everything went good with http method");
					this.dispatchEvent(new Event("SuccessfulChange"));
					this.dispatchEvent(new RestEvent(RestEvent.RESULT, RestClient.SUCCESS, null,event.status));
					break;
						
				default:
					this.dispatchEvent(new RestEvent(RestEvent.RESULT, RestClient.SUCCESS,null,event.status));

					
			}
			trace ( "Load Status Result: HTTP Status = " + event.status );
		}
		private function handleHttpResponseStatus (event:HTTPStatusEvent):void
		{

			trace ( "Load Response Status: HTTP Status = " + event.toString() );
		}
		private function handleSecurityError ( event:SecurityErrorEvent ):void
		{
			
			trace ( "Load failed: Security Error: " + event.text );
		}
		private function handleComplete(event:Event ):void
		{
			// loader has completed everything
			trace ( "The data has successfully loaded" );
		}
		
				
				
		
	}
}