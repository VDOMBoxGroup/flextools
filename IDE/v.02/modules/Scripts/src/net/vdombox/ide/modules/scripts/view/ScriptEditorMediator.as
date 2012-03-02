package net.vdombox.ide.modules.scripts.view
{
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	
	import mx.events.FlexEvent;
	
	import net.vdombox.editors.PythonScriptEditor;
	import net.vdombox.ide.common.controller.Notifications;
	import net.vdombox.ide.common.model._vo.GlobalActionVO;
	import net.vdombox.ide.common.model._vo.LibraryVO;
	import net.vdombox.ide.common.model._vo.ObjectVO;
	import net.vdombox.ide.common.model._vo.PageVO;
	import net.vdombox.ide.common.model._vo.ServerActionVO;
	import net.vdombox.ide.modules.scripts.events.ScriptEditorEvent;
	import net.vdombox.ide.modules.scripts.view.components.ScriptEditor;
	
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;

	public class ScriptEditorMediator extends Mediator implements IMediator
	{
		public static const NAME : String = "ScriptEditorMediator";

		public function ScriptEditorMediator( viewComponent : Object )
		{
			var instanceName : String = NAME + viewComponent.editorID;
			super( instanceName, viewComponent );
			compliteSourceCode();
		}
		
		private var isActive : Boolean;
		
		override public function listNotificationInterests() : Array
		{
			var interests : Array = super.listNotificationInterests();
			
			interests.push( Notifications.BODY_START );
			interests.push( Notifications.BODY_STOP );
			
			
			return interests;
		}
		
		override public function handleNotification( notification : INotification ) : void
		{
			var name : String = notification.getName();
			var body : Object = notification.getBody();
			
			//var objectVO : ObjectVO;
			var editor : ScriptEditor;
			
			if ( !isActive && name != Notifications.BODY_START )
				return;
			
			
			
			switch ( name )
			{
				case Notifications.BODY_START:
				{
					isActive = true;
					
					break;
				}
					
				case Notifications.BODY_STOP:
				{
					clearData();
					
					isActive = false;
					
					break;
				}
					
			}
		}

		
		
		public function get scriptEditor() : ScriptEditor
		{
			return viewComponent as ScriptEditor;
		}
		
		private function get currentVO() : Object
		{
			return scriptEditor.actionVO;
		}
		
		private function set currentVO( value : Object ) : void
		{
			scriptEditor.actionVO = value;
		}

		override public function onRegister() : void
		{

			addHandlers();
		}

		override public function onRemove() : void
		{
			removeHandlers();

			clearData();
		}

		private function addHandlers() : void
		{
			scriptEditor.addEventListener( ScriptEditorEvent.SAVE, scriptEditor_saveHandler, false, 0, true );
			scriptEditor.addEventListener( FlexEvent.CREATION_COMPLETE, compliteSourceCode, false, 0, true );
		}
		
		private function compliteSourceCode( event : FlexEvent = null ):void
		{	
			var pythonScriptEditor: PythonScriptEditor = scriptEditor.pythonScriptEditor;
			
			if ( !pythonScriptEditor )
				return;
			
			pythonScriptEditor.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
			//pythonScriptEditor.addEventListener( Event.CHANGE, validateObjectTypeVO );
			pythonScriptEditor.addedToStageHadler(null);
			pythonScriptEditor.loadSource( "", "zzz" );
			pythonScriptEditor.scriptAreaComponent.text = scriptEditor.script;
		}	
		
		private function keyDownHandler(event:KeyboardEvent):void
		{
			event.stopPropagation();
			event.stopImmediatePropagation();
		}

		private function removeHandlers() : void
		{
			scriptEditor.removeEventListener( ScriptEditorEvent.SAVE, scriptEditor_saveHandler );
		}

		private function clearData() : void
		{
			
		}
		
		private function scriptEditor_saveHandler( event : ScriptEditorEvent ) : void
		{
			if( currentVO is ServerActionVO || currentVO is LibraryVO || currentVO is GlobalActionVO )
				currentVO.script = scriptEditor.script;
			
			sendNotification( Notifications.SAVE_SCRIPT_REQUEST, currentVO );
		}
	}
}