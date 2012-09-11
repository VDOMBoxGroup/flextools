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
	import flash.events.MouseEvent;

	import mx.collections.ArrayList;
	import mx.events.FlexEvent;

	import net.vdombox.ide.common.model._vo.ApplicationVO;
	import net.vdombox.ide.common.model._vo.ResourceVO;
	import net.vdombox.ide.core.ApplicationFacade;
	import net.vdombox.ide.core.events.ApplicationManagerEvent;
	import net.vdombox.ide.core.model.SettingsProxy;
	import net.vdombox.ide.core.model.StatesProxy;
	import net.vdombox.ide.core.model.vo.SettingsVO;
	import net.vdombox.ide.core.view.components.ApplicationListItemRenderer;
	import net.vdombox.ide.core.view.components.ApplicationsView;

	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;

	import spark.components.Application;
	import spark.components.List;
	import spark.events.IndexChangeEvent;

	/**
	 * <P>
	 *   <b>Notification Interests:</b>
	 * <UL>
	 *   <LI>ApplicationFacade.OPEN_APPLICATION_PROPERTY_VIEW
	 *   <LI>ApplicationFacade.OPEN_APPLICATIONS_VIEW
	 *   <LI>ApplicationFacade.SERVER_APPLICATIONS_GETTED
	 * </UL></P>
	 * <P>
	 *  <b>Notification send:</b>
	 * <UL>
	 *   <LI>ApplicationFacade.CLOSE_APPLICATION_MANAGER
	 *   <LI>ApplicationFacade.GET_APPLICATIONS_LIST
	 *   <LI>ApplicationFacade.LOAD_RESOURCE
	 *   <LI>ApplicationFacade.OPEN_APPLICATION_PROPERTY_VIEW
	 *   <LI>ApplicationFacade.SET_SELECTED_APPLICATION
	 * </UL>
	 * </P>
	 *
	 * @author andreev ap
	 */
	public class ApplicationsViewMediator extends Mediator implements IMediator
	{
		/**
		 *
		 * @default
		 */
		public static const NAME : String = "ChangeApplicationViewMediator";

		/**
		 *
		 * @param viewComponent
		 */
		public function ApplicationsViewMediator( viewComponent : Object = null )
		{
			super( NAME, viewComponent );
		}

		private var _selectedApplicationVO : ApplicationVO;

		private var _settingsVO : SettingsVO;

		private var applications : Array;

		private var applicationsChanged : Boolean;

		private var selectedApplicationChanged : Boolean;

		/**
		 *
		 * @return
		 */
		public function get applicationList() : List
		{
			return applicationsView.applicationList as List;
		}

		/**
		 *
		 * @return
		 */
		public function get applicationsView() : ApplicationsView
		{
			return viewComponent as ApplicationsView;
		}

		override public function handleNotification( notification : INotification ) : void
		{
			var body : Object = notification.getBody();

			switch ( notification.getName() )
			{
				case ApplicationFacade.SERVER_APPLICATIONS_GETTED:
				{
					var applicationVO : ApplicationVO;

					applications = notification.getBody() as Array;

					applicationList.dataProvider = new ArrayList( applications );

					selectApplication();

					break;
				}

				case ApplicationFacade.OPEN_APPLICATION_PROPERTY_VIEW:
				{
					applicationsView.visible = false;

					applicationList.dataProvider = null;

					break;
				}

				case ApplicationFacade.OPEN_APPLICATIONS_VIEW:
				{
					applicationsView.visible = true;

					sendNotification( ApplicationFacade.GET_APPLICATIONS_LIST );

					break;
				}
			}
		}

		override public function listNotificationInterests() : Array
		{
			var interests : Array = super.listNotificationInterests();

			interests.push( ApplicationFacade.SERVER_APPLICATIONS_GETTED );

			interests.push( ApplicationFacade.OPEN_APPLICATION_PROPERTY_VIEW );

			interests.push( ApplicationFacade.OPEN_APPLICATIONS_VIEW );

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
		
		/**
		 *
		 * @return
		 */
		public function get selectedApplicationVO() : ApplicationVO
		{
			return _selectedApplicationVO;
		}

		/**
		 *
		 * @param value
		 */
		public function set selectedApplicationVO( value : ApplicationVO ) : void
		{
			_selectedApplicationVO = value;

			applicationsView.selectedApplication = _selectedApplicationVO;
		}

		/**
		 *
		 * @return
		 */
		public function get settingsVO() : SettingsVO
		{
			var settingsProxy : SettingsProxy = facade.retrieveProxy( SettingsProxy.NAME ) as SettingsProxy;

			return settingsProxy.settings;
		}

		/**
		 *
		 * @return
		 */
		public function get statesProxy() : StatesProxy
		{
			return facade.retrieveProxy( StatesProxy.NAME ) as StatesProxy;
		}

		private function addApplicationClickHandler( event : MouseEvent ) : void
		{
			sendNotification( ApplicationFacade.OPEN_APPLICATION_PROPERTY_VIEW );
		}

		private function addHandlers() : void
		{
			applicationList.addEventListener( Event.CHANGE, applicationList_changeHandler, false, 0, true );
			
			applicationList.addEventListener( ApplicationListItemRenderer.RENDERER_DOUBLE_CLICK, applicationList_dubleClickHandler, true, 0, true );

			applicationsView.addApplication.addEventListener( MouseEvent.CLICK, addApplicationClickHandler, false, 0, true );
			
			applicationsView.changeApplication.addEventListener( MouseEvent.CLICK, changeApplicationClikHandler, false, 0, true );
			
			applicationsView.setSelectApplication.addEventListener( MouseEvent.CLICK, setSelectApplication, false, 0, true );

			applicationsView.addEventListener( ApplicationListItemRenderer.ICON_REQUEST, iconRequestHandler, true, 0, true );
		}

		private function iconRequestHandler( event : Event ) : void
		{
			var applicationListItemRenderer : ApplicationListItemRenderer = event.target as ApplicationListItemRenderer;

			sendNotification( ApplicationFacade.LOAD_RESOURCE, { resourceVO: applicationListItemRenderer.resourceVO } );
		}

		/**
		 *
		 * Function for change value selectedApplicationVO on change selectedItem
		 * of applicationList.
		 *
		 */
		private function applicationList_changeHandler( event : Event ) : void
		{
			var newSelectedApplication : ApplicationVO = event.target.selectedItem as ApplicationVO;

			if ( selectedApplicationVO != newSelectedApplication )
				selectedApplicationVO = newSelectedApplication;
		}


		private function applicationList_dubleClickHandler( event : Event ) : void
		{
			var applicationListItemRenderer : ApplicationListItemRenderer = event.target as ApplicationListItemRenderer;

			if ( applicationListItemRenderer )
			{
				applicationsView.visible = false;

				sendNotification( ApplicationFacade.SET_SELECTED_APPLICATION, applicationListItemRenderer.applicationVO );
				
				sendNotification( ApplicationFacade.CLOSE_APPLICATION_MANAGER );
			}
		}

		private function changeApplicationClikHandler( event : MouseEvent ) : void
		{
			sendNotification( ApplicationFacade.SET_SELECTED_APPLICATION, selectedApplicationVO );

			sendNotification( ApplicationFacade.OPEN_APPLICATION_PROPERTY_VIEW, selectedApplicationVO );
		}

		/**
		 *
		 * Get last opened application.
		 *
		 */
		private function getApplicationsFromSettings() : ApplicationVO
		{
			for ( var i : int = 0; i < applications.length; i++ )
			{
				if ( applications[ i ].id == settingsVO.lastApplicationID )
					return applications[ i ] as ApplicationVO;
			}

			return null;
		}

		private function removeHandlers() : void
		{
			applicationList.removeEventListener( Event.CHANGE, applicationList_changeHandler );
			
			applicationList.removeEventListener( ApplicationListItemRenderer.RENDERER_DOUBLE_CLICK, applicationList_dubleClickHandler, true );

			applicationsView.addApplication.removeEventListener( MouseEvent.CLICK, addApplicationClickHandler );
			
			applicationsView.changeApplication.removeEventListener( MouseEvent.CLICK, changeApplicationClikHandler );
			
			applicationsView.setSelectApplication.removeEventListener( MouseEvent.CLICK, setSelectApplication );

			applicationsView.removeEventListener( ApplicationListItemRenderer.ICON_REQUEST, iconRequestHandler, true );
		}



		/**
		 *
		 *  Set selected Application. It is a selectedApplication or last opened
		 * or first of existed.
		 *
		 */
		private function selectApplication() : void
		{
			if ( !applications || applications.length == 0 )
				return;

			selectedApplicationVO = statesProxy.selectedApplication || applications[ 0 ];
		}

		private function get selectedApplicationDescriptions() : String
		{
			return selectedApplicationVO.numberOfPages + " - pages, " + selectedApplicationVO.numberOfObjects + " - objects \n\n" + selectedApplicationVO.description;
		}


		private function setSelectApplication( event : MouseEvent ) : void
		{
			sendNotification( ApplicationFacade.SET_SELECTED_APPLICATION, selectedApplicationVO );
			
			sendNotification( ApplicationFacade.CLOSE_APPLICATION_MANAGER );
		}
	}
}
