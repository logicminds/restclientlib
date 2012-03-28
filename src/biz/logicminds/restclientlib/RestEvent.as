package biz.logicminds.restclientlib
{
	import flash.events.Event;
	
	import mx.rpc.AsyncToken;
	
	public class RestEvent extends Event
	{
		public static const RESULT:String = "biz.logicminds.restclientlib.RestEvent.result";
		public static const IOERROR:String = "biz.logicminds.restclientlib.RestEvent.ioerror";
		
		private var _data:*;
		private var _description:String;
		private var _statuscode:int;
		private var _message:String;
		private var _token:AsyncToken;
		
		public function RestEvent(type:String, desc:String=null, data:*=null,  statuscode:int=-1, 
								  message:String=null, token:AsyncToken=null,bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			_data = data;
			_description = desc;
			_statuscode = statuscode;
			_message = message;
			_token = token;
		}
		public function get token():AsyncToken{
			return _token;
		}
		public function get data():*{
			return _data;
		}
		public function get description():String{
			return this._description;
		}
		public function get statuscode():int{
			return this._statuscode;
		}
		public function get message():String{
			return this._message;
		}
		public override function clone():Event{
			return new RestEvent(type, description, data, statuscode, message, token);
		}
	
	}
}