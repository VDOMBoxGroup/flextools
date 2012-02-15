package net.vdombox.ide.modules.events.view.components
{
	import net.vdombox.ide.common.controller.messages.ProxyMessage;
	import net.vdombox.ide.common.model._vo.ApplicationEventsVO;

	public class UndoStackItem
	{
		private var _message : ApplicationEventsVO; 
		private var _undoMessage : ApplicationEventsVO;
		
		public function UndoStackItem( message : ApplicationEventsVO )
		{
			_message = message.copy();;
			_undoMessage = _message;
		}
		
		public function undo() : ApplicationEventsVO
		{
			return _undoMessage.copy();
		}
		
		public function redo() : ApplicationEventsVO
		{
			return _message.copy();
		}
	}
}