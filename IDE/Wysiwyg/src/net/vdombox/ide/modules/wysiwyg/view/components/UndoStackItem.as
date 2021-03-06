package net.vdombox.ide.modules.wysiwyg.view.components
{
	import net.vdombox.ide.common.controller.messages.ProxyMessage;
	import net.vdombox.ide.common.model._vo.VdomObjectAttributesVO;

	public class UndoStackItem
	{
		private var _message : ProxyMessage;

		private var _undoMessage : ProxyMessage;

		public function UndoStackItem( message : ProxyMessage )
		{
			_message = clone( message, false );
			_undoMessage = clone( _message, true );
		}

		private function clone( message : ProxyMessage, getUndo : Boolean ) : ProxyMessage
		{
			var body : Object = message.getBody();
			if ( body is VdomObjectAttributesVO )
			{
				var vdomObjectAttributeVO : VdomObjectAttributesVO = body.clone( getUndo );
				return new ProxyMessage( message.proxy, message.operation, message.target, vdomObjectAttributeVO );
			}

			return null;
		}

		public function undo() : ProxyMessage
		{
			return clone( _undoMessage, false );
		}

		public function redo() : ProxyMessage
		{
			return clone( _message, false );;
		}
	}
}
