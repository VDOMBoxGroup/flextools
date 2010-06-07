package net.vdombox.ide.common
{
	import org.puremvc.as3.multicore.utilities.pipes.messages.Message;

	public class ProxyMessage extends Message
	{
		public const PROXY_MESSAGE : String = "proxyMessage";
		
		public function ProxyMessage( place : String, operation : String, target : String, body : Object = null )
		{
			_place = place;
			_operation = operation;
			_target = target;
			
			super( MessageTypes.PROXY_MESSAGE, place, body );
		}

		protected var _place : String;
		
		protected var _operation : String;

		protected var _target : String;
		
		public function get place() : String
		{
			return _place;
		}
		
		public function get operation() : String
		{
			return _operation;
		}
		
		public function get target() : String
		{
			return _target;			
		}
	}
}