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
	
	import net.vdombox.ide.common.vo.ApplicationVO;
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
	 * Description
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
			applicationManagerWindow.addEventListener( FlexEvent.REMOVE, closeHandler );
			applicationManagerWindow.addEventListener( Event.CLOSE, closeHandler );
		}

		private function closeHandler( event : * ) : void
		{
			closeWindow();
		}

		
		private function closeWindow() : void
		{
			if ( serverProxy.applications.length > 0 && statesProxy.selectedApplication )
				sendNotification( ApplicationFacade.CLOSE_APPLICATION_MANAGER );
			else
				NativeApplication.nativeApplication.exit();
		}

		private function createCompleteHandler( event : FlexEvent ) : void
		{
			registerMediators();
			openNecessaryView();
		}
		
		private function openNecessaryView():void
		{
			if ( serverProxy.applications.length > 0 )
				sendNotification(ApplicationFacade.OPEN_APPLICATIONS_VIEW);
			else
				sendNotification( ApplicationFacade.EDIT_APPLICATION_PROPERTY );
		}
		
		private function registerMediators():void
		{
			facade.registerMediator( new ApplicationsViewMediator(  applicationManagerWindow.applicationsView   ) );
			facade.registerMediator( new ApplicationPropertiesViewMediator( applicationManagerWindow.applicationPropertiesView ) );
		}

		private function removeHandlers() : void
		{
			applicationManagerWindow.removeEventListener( Event.CLOSE, closeHandler );
		}
		
		public function get statesProxy() : StatesProxy
		{
			return facade.retrieveProxy( StatesProxy.NAME ) as StatesProxy;
		}
		
		private function get serverProxy():ServerProxy
		{
			return facade.retrieveProxy( ServerProxy.NAME ) as ServerProxy;
		}
	}
}
