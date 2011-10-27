package net.vdombox.ide.modules.scripts.view
{
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	
	import mx.events.FlexEvent;
	
	import net.vdombox.editors.PythonScriptEditor;
	import net.vdombox.ide.common.vo.ApplicationVO;
	import net.vdombox.ide.common.vo.GlobalActionVO;
	import net.vdombox.ide.common.vo.LibraryVO;
	import net.vdombox.ide.common.vo.ServerActionVO;
	import net.vdombox.ide.modules.scripts.ApplicationFacade;
	import net.vdombox.ide.modules.scripts.events.ScriptEditorEvent;
	import net.vdombox.ide.modules.scripts.model.SessionProxy;
	import net.vdombox.ide.modules.scripts.view.components.ScriptEditor;
	
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;

	public class ScriptEditorMediator extends Mediator implements IMediator
	{
		public static const NAME : String = "ScriptEditorMediator";

		public function ScriptEditorMediator( viewComponent : Object )
		{
			super( NAME, viewComponent );
			scriptEditor.addEventListener( FlexEvent.SHOW, showHandler );
			compliteSourceCode();
		}

		private var sessionProxy : SessionProxy;

		private var isActive : Boolean;
		
		private var serverActionVO : ServerActionVO;
		private var libraryVO : LibraryVO;
		private var globalActionVO : GlobalActionVO;

		private var currentVO : Object;
		
		public function get scriptEditor() : ScriptEditor
		{
			return viewComponent as ScriptEditor;
		}

		override public function onRegister() : void
		{
			scriptEditor.enabled = false;
			isActive = false;

			sessionProxy = facade.retrieveProxy( SessionProxy.NAME ) as SessionProxy;

			addHandlers();
		}

		override public function onRemove() : void
		{
			scriptEditor.enabled = false;
			removeHandlers();

			clearData();
		}

		override public function listNotificationInterests() : Array
		{
			var interests : Array = super.listNotificationInterests();

			interests.push( ApplicationFacade.BODY_START );
			interests.push( ApplicationFacade.BODY_STOP );

			interests.push( ApplicationFacade.SELECTED_SERVER_ACTION_CHANGED );
			interests.push( ApplicationFacade.SELECTED_LIBRARY_CHANGED );
			interests.push( ApplicationFacade.SELECTED_GLOBAL_ACTION_CHANGED );

			return interests;
		}

		override public function handleNotification( notification : INotification ) : void
		{
			var name : String = notification.getName();
			var body : Object = notification.getBody();
			//var pythonScriptEditor: PythonScriptEditor = scriptEditor.pythonScriptEditor;

			if ( !isActive && name != ApplicationFacade.BODY_START )
				return;

			switch ( name )
			{
				case ApplicationFacade.BODY_START:
				{
					if ( sessionProxy.selectedApplication )
					{
						isActive = true;

						if( sessionProxy.selectedApplication )
							//scriptEditor.syntax = sessionProxy.selectedApplication.scriptingLanguage;
						
						break;
					}
				}

				case ApplicationFacade.BODY_STOP:
				{
					isActive = false;

					clearData();

					break;
				}

				case ApplicationFacade.SELECTED_SERVER_ACTION_CHANGED:
				{
					serverActionVO = body as ServerActionVO;

					if ( serverActionVO )
					{
						scriptEditor.enabled = true;
						scriptEditor.script = serverActionVO.script;
						//pythonScriptEditor.loadSource( serverActionVO.script, "zzz" );
						currentVO = serverActionVO;
					}
					else
					{
						scriptEditor.enabled = false;
						scriptEditor.script = "";
						//pythonScriptEditor.loadSource( "", "zzz" );
						currentVO = null;
					}

					break;
				}

				case ApplicationFacade.SELECTED_LIBRARY_CHANGED:
				{
					libraryVO = body as LibraryVO

					if ( libraryVO )
					{
						scriptEditor.enabled = true;
						scriptEditor.script = libraryVO.script;
						//pythonScriptEditor.loadSource( libraryVO.script, "zzz" );
						currentVO = libraryVO;
					}
					else
					{
						scriptEditor.enabled = false;
						scriptEditor.script = "";
						//pythonScriptEditor.loadSource( "", "zzz" );
						currentVO = null;
					}

					break;
				}
					
				case ApplicationFacade.SELECTED_GLOBAL_ACTION_CHANGED:
				{
					globalActionVO = body as GlobalActionVO;
					
					if ( globalActionVO )
					{
						scriptEditor.enabled = true;
						scriptEditor.script = globalActionVO.script;
						//pythonScriptEditor.loadSource( globalActionVO.script, "zzz" );
						currentVO = globalActionVO;
					}
					else
					{
						scriptEditor.enabled = false;
						scriptEditor.script = "";
						//pythonScriptEditor.loadSource( "", "zzz" );
						currentVO = null;
					}
					
					break;
				}
			}
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
			currentVO = null;
		}
		
		private function scriptEditor_saveHandler( event : ScriptEditorEvent ) : void
		{
			if( currentVO is ServerActionVO || currentVO is LibraryVO || currentVO is GlobalActionVO )
				currentVO.script = scriptEditor.script;
			
			sendNotification( ApplicationFacade.SAVE_SCRIPT_REQUEST, currentVO );
		}
	}
}