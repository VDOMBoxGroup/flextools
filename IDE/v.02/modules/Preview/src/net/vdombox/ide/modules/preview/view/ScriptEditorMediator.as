package net.vdombox.ide.modules.preview.view
{
	import net.vdombox.ide.common.vo.ApplicationVO;
	import net.vdombox.ide.common.vo.LibraryVO;
	import net.vdombox.ide.common.vo.ServerActionVO;
	import net.vdombox.ide.modules.preview.ApplicationFacade;
	import net.vdombox.ide.modules.preview.events.ScriptEditorEvent;
	import net.vdombox.ide.modules.preview.model.SessionProxy;
	import net.vdombox.ide.modules.preview.view.components.ScriptEditor;
	
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;

	public class ScriptEditorMediator extends Mediator implements IMediator
	{
		public static const NAME : String = "ScriptEditorMediator";

		public function ScriptEditorMediator( viewComponent : Object )
		{
			super( NAME, viewComponent );
		}

		private var sessionProxy : SessionProxy;

		private var isActive : Boolean;
		
		private var serverActionVO : ServerActionVO;
		private var libraryVO : LibraryVO;

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

			return interests;
		}

		override public function handleNotification( notification : INotification ) : void
		{
			var name : String = notification.getName();
			var body : Object = notification.getBody();

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
							scriptEditor.syntax = sessionProxy.selectedApplication.scriptingLanguage;
						
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
						currentVO = serverActionVO;
					}
					else
					{
						scriptEditor.enabled = false;
						scriptEditor.script = "";
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
						currentVO = libraryVO;
					}
					else
					{
						scriptEditor.enabled = false;
						scriptEditor.script = "";
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
			if( currentVO is ServerActionVO || currentVO is LibraryVO )
				currentVO.script = scriptEditor.script;
			
			sendNotification( ApplicationFacade.SAVE_SCRIPT_REQUEST, currentVO );
		}
	}
}