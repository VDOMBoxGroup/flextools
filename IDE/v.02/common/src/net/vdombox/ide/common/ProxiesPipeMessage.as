package net.vdombox.ide.common
{
	import org.puremvc.as3.multicore.utilities.pipes.messages.Message;

	public class ProxiesPipeMessage extends Message
	{
		public function ProxiesPipeMessage( place : String, operation : String, target : String, body : Object = null )
		{
			_place = place;
			_operation = operation;
			_target = target;
			
			super( Message.NORMAL, place, body );
		}

		protected var _place : String;
		
		protected var _operation : String;

		protected var _target : String;
		
		public function getPlace() : String
		{
			return _place;
		}
		
		public function getOperation() : String
		{
			return _operation;
		}
		
		public function getTarget() : String
		{
			return _target;			
		}
	}
}