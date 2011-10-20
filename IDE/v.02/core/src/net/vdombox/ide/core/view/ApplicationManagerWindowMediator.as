//------------------------------------------------------------------------------
//
//   Copyright 2011 
//   VDOMBOX Resaerch  
//   All rights reserved. 
//
//------------------------------------------------------------------------------

package net.vdombox.ide.core.view
{
	import flash.events.Event;
	import mx.events.FlexEvent;
	import net.vdombox.ide.common.vo.ApplicationVO;
	import net.vdombox.ide.core.ApplicationFacade;
	import net.vdombox.ide.core.events.ApplicationManagerWindowEvent;
	import net.vdombox.ide.core.model.GalleryProxy;
	import net.vdombox.ide.core.model.SettingsProxy;
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
				case ApplicationFacade.SET_SELECTED_APPLICATION:
				{

//					closeWindows();

					break;
				}
			}
		}

		override public function listNotificationInterests() : Array
		{
			var interests : Array = super.listNotificationInterests();

//			interests.push( ApplicationFacade.SET_SELECTED_APPLICATION );

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
			closeWindows();
		}

		private function closeWindows() : void
		{
			sendNotification( ApplicationFacade.CLOSE_APPLICATION_MANAGER );
		}

		private function createCompleteHandler( event : FlexEvent ) : void
		{
			facade.registerMediator( new ChangeApplicationViewMediator( applicationManagerWindow.changeApplicationView ) );
			facade.registerMediator( new CreateEditApplicationViewMediator( applicationManagerWindow.createEditApplicationView ) );
		}

		private function removeHandlers() : void
		{
			applicationManagerWindow.removeEventListener( Event.CLOSE, closeHandler );
		}
	}
}
