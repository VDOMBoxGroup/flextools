package net.vdombox.ide.common
{
	import org.puremvc.as3.multicore.utilities.pipes.messages.Message;

	public class ProxiesPipeMessage extends Message
	{
		public function ProxiesPipeMessage( operation : String, place : String, target : String, parameters : Object )
		{
			var headers : Object = {};
			headers.place = place;
			headers.target = target;
			
			super( operation, headers, parameters, priority );
		}
		
		public function get operation() : String
		{
			return type;
		}
		
		public function get place() : String
		{
			return header.place;
		}
		
		public function get target() : String
		{
			return header.target;			
		}
		
		public function get parameters() : Object
		{
			return body;			
		}
	}
}