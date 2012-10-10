//------------------------------------------------------------------------------
//
//   Copyright 2011 
//   VDOMBOX Resaerch  
//   All rights reserved. 
//
//------------------------------------------------------------------------------

package net.vdombox.ide.core.view
{
	import flash.desktop.NativeApplication;
	import flash.events.Event;
	
	import mx.events.FlexEvent;
	
	import net.vdombox.ide.common.model._vo.ApplicationVO;
	import net.vdombox.ide.core.ApplicationFacade;
	import net.vdombox.ide.core.events.ApplicationManagerEvent;
	import net.vdombox.ide.core.model.GalleryProxy;
	import net.vdombox.ide.core.model.ServerProxy;
	import net.vdombox.ide.core.model.SettingsProxy;
	import net.vdombox.ide.core.model.StatesProxy;
	import net.vdombox.ide.core.view.components.ApplicationManagerWindow;
	import net.vdombox.utils.WindowManager;
	
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;

	/**
	 *  <P>
	 *  <b>Notification send:</b>
	 * <UL>
	 *   <LI>ApplicationFacade.CLOSE_APPLICATION_MANAGER
	 *   <LI>ApplicationFacade.OPEN_APPLICATIONS_VIEW
	 *   <LI>ApplicationFacade.OPEN_APPLICATION_PROPERTY_VIEW
	 * </UL>
	 * </P>
	 *
	 * @author andreev ap
	 */
	public class ApplicationManagerWindowMediator extends Mediator implements IMediator
	{
		/**
		 *
		 * @default
		 */
		public static const NAME : String = "ApplicationManagerWindowMediator";

		/**
		 *
		 * @param viewComponent
		 */
		public function ApplicationManagerWindowMediator( viewComponent : Object = null )
		{
			super( NAME, viewComponent );
		}

		/**
		 *
		 * @return
		 */
		public function get applicationManagerWindow() : ApplicationManagerWindow
		{
			return viewComponent as ApplicationManagerWindow;
		}

		override public function handleNotification( notification : INotification ) : void
		{
			var body : Object = notification.getBody();

			switch ( notification.getName() )
			{

			}
		}

		override public function listNotificationInterests() : Array
		{
			var interests : Array = super.listNotificationInterests();

			return interests;
		}

		override public function onRegister() : void
		{
			addHandlers();
		}

		override public function onRemove() : void
		{
			removeHandlers();
		}

		private function addHandlers() : void
		{
			applicationManagerWindow.addEventListener( FlexEvent.CREATION_COMPLETE, createCompleteHandler );
		
			applicationManagerWindow.addEventListener( FlexEvent.REMOVE, removeHandler );
			
			applicationManagerWindow.addEventListener( Event.CLOSE, closeHandler );
			
			applicationManagerWindow.addEventListener( ApplicationManagerEvent.LOGOUT, logoutHandler );
		}
		
		private function removeHandler( event : FlexEvent ) : void
		{
			closeWindow( false, true );
		}

		private function closeHandler( event : Event ) : void
		{
			closeWindow();
		}
		
		private function logoutHandler( event : ApplicationManagerEvent ) : void
		{
			closeWindow(true);
		}


		private function closeWindow( logOff : Boolean = false, close : Boolean = false ) : void
		{
			if (serverProxy.applications && serverProxy.applications.length > 0 )
				sendNotification( ApplicationFacade.CLOSE_APPLICATION_MANAGER, { logOff : logOff, close : close } );
			else
				NativeApplication.nativeApplication.exit();
		}

		private function createCompleteHandler( event : FlexEvent ) : void
		{
			var serverProxy : ServerProxy = facade.retrieveProxy( ServerProxy.NAME ) as ServerProxy;
			
			applicationManagerWindow.title += "  |  " + serverProxy.authInfo.hostname; 
			
			registerMediators();
			openNecessaryView();
		}

		private function openNecessaryView() : void
		{
			//if ( serverProxy.applications && serverProxy.applications.length > 0 )
				sendNotification( ApplicationFacade.OPEN_APPLICATIONS_VIEW );
			/*else
				sendNotification( ApplicationFacade.OPEN_APPLICATION_PROPERTY_VIEW );*/
		}

		private function registerMediators() : void
		{
			facade.registerMediator( new ApplicationsViewMediator( applicationManagerWindow.applicationsView ) );
			
			facade.registerMediator( new ApplicationPropertiesViewMediator( applicationManagerWindow.applicationPropertiesView ) );
		}

		private function removeHandlers() : void
		{
			applicationManagerWindow.removeEventListener( Event.CLOSE, closeHandler );
			
			applicationManagerWindow.removeEventListener( ApplicationManagerEvent.LOGOUT, logoutHandler );
		}

		public function get statesProxy() : StatesProxy
		{
			return facade.retrieveProxy( StatesProxy.NAME ) as StatesProxy;
		}

		private function get serverProxy() : ServerProxy
		{
			return facade.retrieveProxy( ServerProxy.NAME ) as ServerProxy;
		}
	}
}
