package net.vdombox.ide.modules.events.view.components
{
	import net.vdombox.ide.common.controller.messages.ProxyMessage;
	import net.vdombox.ide.common.model._vo.ApplicationEventsVO;

	public class UndoStackItem
	{
		private var _message : ProxyMessage; 
		private var _undoMessage : ProxyMessage;
		
		public function UndoStackItem( message : ProxyMessage )
		{
			_message = getUndoContent( message );
			_undoMessage = _message;
		}
		
		private function getUndoContent( message : ProxyMessage ) : ProxyMessage
		{
			var body : Object = message.getBody();
			var undoBody : Object = [];
			
			if ( body.hasOwnProperty("applicationEventsVO") )
			{
				var applicationEventsVO : ApplicationEventsVO =  (body.applicationEventsVO as ApplicationEventsVO).copy();
				undoBody.needForUpdate = true;
				undoBody.applicationEventsVO = applicationEventsVO;
				return new ProxyMessage(message.proxy, message.operation, message.target, undoBody );
			}
			
			return null;
		}
		
		public function undo() : ProxyMessage
		{
			return _undoMessage;
		}
		
		public function redo() : ProxyMessage
		{
			return _message;
		}
	}
}