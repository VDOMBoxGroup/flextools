package net.vdombox.ide.modules.scripts.view
{
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	
	import mx.events.FlexEvent;
	
	import net.vdombox.editors.BaseScriptEditor;
	import net.vdombox.editors.PythonScriptEditor;
	import net.vdombox.ide.common.controller.Notifications;
	import net.vdombox.ide.common.events.FindBoxEvent;
	import net.vdombox.ide.common.model._vo.GlobalActionVO;
	import net.vdombox.ide.common.model._vo.LibraryVO;
	import net.vdombox.ide.common.model._vo.ObjectVO;
	import net.vdombox.ide.common.model._vo.PageVO;
	import net.vdombox.ide.common.model._vo.ServerActionVO;
	import net.vdombox.ide.modules.scripts.events.ScriptEditorEvent;
	import net.vdombox.ide.modules.scripts.model.HashLibraryProxy;
	import net.vdombox.ide.modules.scripts.view.components.FindBox;
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
		private var hashLibraryProxy : HashLibraryProxy;
		
		override public function listNotificationInterests() : Array
		{
			var interests : Array = super.listNotificationInterests();
			
			interests.push( HashLibraryProxy.HASH_LIBRARIES_CHANGE );
			
			return interests;
		}
		
		override public function handleNotification( notification : INotification ) : void
		{
			var name : String = notification.getName();
			var body : Object = notification.getBody();
			
			switch ( name )
			{					
				case HashLibraryProxy.HASH_LIBRARIES_CHANGE:
				{
					scriptEditor.hashLibraryArray = hashLibraryProxy.hashLibraries;
					
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
			hashLibraryProxy = facade.retrieveProxy( HashLibraryProxy.NAME ) as HashLibraryProxy;
			
			scriptEditor.hashLibraryArray = hashLibraryProxy.hashLibraries;
			scriptEditor.setActionVO();
			
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
			scriptEditor.addEventListener( ScriptEditorEvent.OPEN_FIND, scriptEditor_openFindHandler, false, 0, true );
			scriptEditor.addEventListener( FlexEvent.CREATION_COMPLETE, compliteSourceCode, false, 0, true );
		}
		
		private function compliteSourceCode( event : FlexEvent = null ):void
		{	
			var pythonScriptEditor: BaseScriptEditor = scriptEditor.scriptEditor;
			
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
			hashLibraryProxy = null;
		}
		
		private function scriptEditor_saveHandler( event : ScriptEditorEvent ) : void
		{
			/*if( currentVO is ServerActionVO || currentVO is LibraryVO || currentVO is GlobalActionVO )
				currentVO.script = scriptEditor.script;*/
			
			sendNotification( Notifications.GET_SCRIPT_REQUEST, { actionVO : currentVO, check : true } );
			//sendNotification( Notifications.SAVE_SCRIPT_REQUEST, currentVO );
		}
		
		private function scriptEditor_openFindHandler( event : ScriptEditorEvent ) : void
		{			
			sendNotification( Notifications.OPEN_FIND_SCRIPT );
		}
	}
}