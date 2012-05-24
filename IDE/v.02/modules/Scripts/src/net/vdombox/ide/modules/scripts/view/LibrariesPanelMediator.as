package net.vdombox.ide.modules.scripts.view
{
	import net.vdombox.ide.common.controller.Notifications;
	import net.vdombox.ide.common.events.PopUpWindowEvent;
	import net.vdombox.ide.common.model.StatesProxy;
	import net.vdombox.ide.common.model._vo.LibraryVO;
	import net.vdombox.ide.common.view.components.windows.NameObjectWindow;
	import net.vdombox.ide.modules.scripts.events.LibrariesPanelEvent;
	import net.vdombox.ide.modules.scripts.view.components.LibrariesPanel;
	import net.vdombox.utils.WindowManager;
	
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;

	public class LibrariesPanelMediator extends Mediator implements IMediator
	{
		public static const NAME : String = "LibrariesPanelMediator";

		public function LibrariesPanelMediator( viewComponent : Object )
		{
			super( NAME, viewComponent );
		}

		private var statesProxy : StatesProxy;
		
		private var isActive : Boolean;
		
		private var libraries : Array;

		public function get librariesPanel() : LibrariesPanel
		{
			return viewComponent as LibrariesPanel;
		}

		override public function onRegister() : void
		{
			isActive = false;
			
			statesProxy = facade.retrieveProxy( StatesProxy.NAME ) as StatesProxy;
			
			addHandlers();
		}

		override public function onRemove() : void
		{
			removeHandlers();
			
			clearData();
		}

		override public function listNotificationInterests() : Array
		{
			var interests : Array = super.listNotificationInterests();

			interests.push( Notifications.BODY_START );
			interests.push( Notifications.BODY_STOP );
			
			interests.push( Notifications.SERVER_ACTION_GETTED );
			
			interests.push( Notifications.LIBRARIES_GETTED );
			interests.push( Notifications.LIBRARY_CREATED );
			interests.push( Notifications.LIBRARY_DELETED );

			return interests;
		}

		override public function handleNotification( notification : INotification ) : void
		{
			var name : String = notification.getName();
			var body : Object = notification.getBody();

			if ( !isActive && name != Notifications.BODY_START )
				return;
			
			switch ( name )
			{
				case Notifications.BODY_START:
				{
					if ( statesProxy.selectedApplication )
					{
						isActive = true;
						sendNotification( Notifications.GET_LIBRARIES, statesProxy.selectedApplication );
						
						break;
					}
				}
					
				case Notifications.BODY_STOP:
				{
					isActive = false;
					
					clearData();
					
					break;
				}
				
				case Notifications.SERVER_ACTION_GETTED:
				{
					if ( body )
						librariesPanel.selectedLibrary = null;

					break;
				}

				case Notifications.LIBRARIES_GETTED:
				{
					libraries = body as Array;
					librariesPanel.libraries = libraries.slice();

					break;
				}

				case Notifications.LIBRARY_CREATED:
				{
					if ( libraries )
					{
						libraries.push( body as LibraryVO );
						librariesPanel.libraries = libraries.slice();
					}

					break;
				}

				case Notifications.LIBRARY_DELETED:
				{
					var libraryVO : LibraryVO = body as LibraryVO;

					if ( !libraries || !libraryVO )
						return;
					
					for ( var i : uint = 0; i < libraries.length; i++ )
					{
						if ( libraries[ i ].name == libraryVO.name )
						{
							libraries.splice( i, 1 );
							break;
						}
					}

					librariesPanel.libraries = libraries.slice();

					break;
				}
			}
		}

		private function addHandlers() : void
		{
			librariesPanel.addEventListener( LibrariesPanelEvent.CREATE_LIBRARY, createLibraryHandler, false, 0, true );
			librariesPanel.addEventListener( LibrariesPanelEvent.DELETE_LIBRARY, deleteLibraryHandler, false, 0, true );
			librariesPanel.addEventListener( LibrariesPanelEvent.SELECTED_LIBRARY_CHANGED, selectedLibraryChangedHandler, false, 0, true );
		}

		private function removeHandlers() : void
		{
			librariesPanel.removeEventListener( LibrariesPanelEvent.CREATE_LIBRARY, createLibraryHandler );
			librariesPanel.removeEventListener( LibrariesPanelEvent.DELETE_LIBRARY, deleteLibraryHandler );
			librariesPanel.removeEventListener( LibrariesPanelEvent.SELECTED_LIBRARY_CHANGED, selectedLibraryChangedHandler );
		}

		private function clearData() : void
		{
			libraries = null;
			librariesPanel.libraries = null;
		}
		
		private function createLibraryHandler( event : LibrariesPanelEvent ) : void
		{
			var renameWindow : NameObjectWindow = new NameObjectWindow( "" );	
			renameWindow.addEventListener( PopUpWindowEvent.APPLY, applyHandler );
			renameWindow.addEventListener( PopUpWindowEvent.CANCEL, cancelHandler );
			
			WindowManager.getInstance().addWindow(renameWindow, librariesPanel.skin, true);
			
			function applyHandler( event : PopUpWindowEvent ) : void
			{
				WindowManager.getInstance().removeWindow( renameWindow );
				
				sendNotification( Notifications.CREATE_SCRIPT_REQUEST, { name : event.name, target : Notifications.LIBRARY } );
				
			}
			
			function cancelHandler( event : PopUpWindowEvent ) : void
			{
				WindowManager.getInstance().removeWindow( renameWindow );
			}
		}

		private function deleteLibraryHandler( event : LibrariesPanelEvent ) : void
		{
			var libraryVO : LibraryVO = event.object as LibraryVO;

			if ( libraryVO )
				sendNotification( Notifications.DELETE_LIBRARY_REQUEST, libraryVO );
		}

		private function selectedLibraryChangedHandler( event : LibrariesPanelEvent ) : void
		{
			sendNotification( Notifications.GET_SCRIPT_REQUEST, { actionVO : librariesPanel.selectedLibrary, check : false } );
		}
	}
}