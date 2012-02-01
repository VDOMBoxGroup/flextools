package net.vdombox.ide.modules.scripts.view
{
	import net.vdombox.ide.common.model.SessionProxy;
	import net.vdombox.ide.common.model._vo.LibraryVO;
	import net.vdombox.ide.modules.scripts.ApplicationFacade;
	import net.vdombox.ide.modules.scripts.events.LibrariesPanelEvent;
	import net.vdombox.ide.modules.scripts.view.components.LibrariesPanel;
	
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

		private var sessionProxy : SessionProxy;
		
		private var isActive : Boolean;
		
		private var libraries : Array;

		public function get librariesPanel() : LibrariesPanel
		{
			return viewComponent as LibrariesPanel;
		}

		override public function onRegister() : void
		{
			isActive = false;
			
			sessionProxy = facade.retrieveProxy( SessionProxy.NAME ) as SessionProxy;
			
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

			interests.push( ApplicationFacade.BODY_START );
			interests.push( ApplicationFacade.BODY_STOP );
			
			interests.push( ApplicationFacade.SELECTED_SERVER_ACTION_CHANGED );
			
			interests.push( ApplicationFacade.LIBRARIES_GETTED );
			interests.push( ApplicationFacade.LIBRARY_CREATED );
			interests.push( ApplicationFacade.LIBRARY_DELETED );

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
						sendNotification( ApplicationFacade.GET_LIBRARIES, sessionProxy.selectedApplication );
						
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
					if ( body )
						librariesPanel.selectedLibrary = null;

					break;
				}

				case ApplicationFacade.LIBRARIES_GETTED:
				{
					libraries = body as Array;
					librariesPanel.libraries = libraries.slice();

					break;
				}

				case ApplicationFacade.LIBRARY_CREATED:
				{
					if ( libraries )
					{
						libraries.push( body as LibraryVO );
						librariesPanel.libraries = libraries.slice();
					}

					break;
				}

				case ApplicationFacade.LIBRARY_DELETED:
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
			sendNotification( ApplicationFacade.OPEN_CREATE_ACTION_WINDOW, ApplicationFacade.LIBRARY );
		}

		private function deleteLibraryHandler( event : LibrariesPanelEvent ) : void
		{
			var libraryVO : LibraryVO = librariesPanel.selectedLibrary;

			if ( libraryVO )
				sendNotification( ApplicationFacade.DELETE_LIBRARY_REQUEST, libraryVO );
		}

		private function selectedLibraryChangedHandler( event : LibrariesPanelEvent ) : void
		{
			sendNotification( ApplicationFacade.SELECTED_LIBRARY_CHANGED, librariesPanel.selectedLibrary );
		}
	}
}