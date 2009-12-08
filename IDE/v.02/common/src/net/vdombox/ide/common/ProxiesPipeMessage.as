package net.vdombox.ide.common
{
	import org.puremvc.as3.multicore.utilities.pipes.messages.Message;

	public class ProxiesPipeMessage extends Message
	{
		public function ProxiesPipeMessage( place : String, operation : String, target : String, parameters : Object = null )
		{
			
			_operation = operation;
			
			_target = target;
			
			super( Message.NORMAL, place, parameters );
		}
		
		protected var _operation : String;
		
		protected var _target : String;
		
		public function getPlace() : String
		{
			return header.toString();
		}
		
		public function getOperation() : String
		{
			return _operation;
		}
		
		public function getTarget() : String
		{
			return _target;			
		}
		
		public function getParameters() : Object
		{
			return body;			
		}
		
		public function setParameters( value : Object ) : void
		{
			body = value;			
		}
	}
}