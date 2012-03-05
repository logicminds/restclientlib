package biz.logicminds.restclientlib
{
	import flash.events.Event;
	
	public class RestEvent extends Event
	{
		public static const RESULT:String = "result";
		
		private var _data:*;
		private var _description:String;
		private var _statuscode:int;
		private var _message:String;
		
		public function RestEvent(type:String, desc:String=null, data:*=null,  statuscode:int=-1, message:String=null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			_data = data;
			_description = desc;
			_statuscode = statuscode;
			_message = message;
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
	
	}
}