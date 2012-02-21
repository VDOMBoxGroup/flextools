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
	import net.vdombox.ide.common.controller.Notifications;
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
		
		private var serverActionVO : ServerActionVO;
		private var libraryVO : LibraryVO;
		private var globalActionVO : GlobalActionVO;

		
		
		public function get scriptEditor() : ScriptEditor
		{
			return viewComponent as ScriptEditor;
		}
		
		private function get currentVO() : Object
		{
			return scriptEditor.actionVO;
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
		}
		
		private function showHandler(event:FlexEvent):void
		{
			scriptEditor.removeEventListener(FlexEvent.SHOW, showHandler);
			compliteSourceCode();
		}
		
		protected function compliteSourceCode( ):void
		{	
			var pythonScriptEditor: PythonScriptEditor = scriptEditor.pythonScriptEditor;
			pythonScriptEditor.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
			//pythonScriptEditor.addEventListener( Event.CHANGE, validateObjectTypeVO );
			pythonScriptEditor.addedToStageHadler(null);
			pythonScriptEditor.loadSource( "", "zzz" );
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
			serverActionVO = null;
			libraryVO = null;
			globalActionVO = null;
		}
		
		private function scriptEditor_saveHandler( event : ScriptEditorEvent ) : void
		{
			if( currentVO is ServerActionVO || currentVO is LibraryVO || currentVO is GlobalActionVO )
				currentVO.script = scriptEditor.script;
			
			if ( scriptEditor.objectVO is PageVO )
				sendNotification( Notifications.SAVE_SCRIPT_REQUEST, { pageVO : scriptEditor.objectVO, currentVO :  currentVO } );
			else if ( scriptEditor.objectVO is ObjectVO )
				sendNotification( Notifications.SAVE_SCRIPT_REQUEST, { objectVO : scriptEditor.objectVO, currentVO :  currentVO } );
		}
	}
}