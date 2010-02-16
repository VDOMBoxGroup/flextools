package net.vdombox.ide.modules.scripts.view
{
	import net.vdombox.ide.common.vo.LibraryVO;
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

		private var libraries : Array;
		
		public function get librariesPanel() : LibrariesPanel
		{
			return viewComponent as LibrariesPanel;
		}

		override public function onRegister() : void
		{
			addHandlers();
		}

		override public function onRemove() : void
		{
			removeHandlers();
		}

		override public function listNotificationInterests() : Array
		{
			var interests : Array = super.listNotificationInterests();

			interests.push( ApplicationFacade.SELECTED_APPLICATION_GETTED );
			interests.push( ApplicationFacade.LIBRARIES_GETTED );
			interests.push( ApplicationFacade.LIBRARY_CREATED );

			return interests;
		}

		override public function handleNotification( notification : INotification ) : void
		{
			var name : String = notification.getName();
			var body : Object = notification.getBody();

			switch ( name )
			{
				case ApplicationFacade.SELECTED_APPLICATION_GETTED:
				{
					sendNotification( ApplicationFacade.GET_LIBRARIES, body )

					break;
				}

				case ApplicationFacade.LIBRARIES_GETTED:
				{
					libraries = body as Array;
					librariesPanel.libraries = libraries;

					break;
				}
					
				case ApplicationFacade.LIBRARY_CREATED:
				{
					if( libraries )
					{
						libraries.push( body as LibraryVO );
						librariesPanel.libraries = libraries;
					}
					
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

		private function createLibraryHandler( event : LibrariesPanelEvent ) : void
		{
			sendNotification( ApplicationFacade.OPEN_CREATE_ACTION_WINDOW, ApplicationFacade.LIBRARY );
		}

		private function deleteLibraryHandler( event : LibrariesPanelEvent ) : void
		{
			
		}

		private function selectedLibraryChangedHandler( event : LibrariesPanelEvent ) : void
		{

		}
	}
}