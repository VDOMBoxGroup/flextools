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
	
	import net.vdombox.ide.common.vo.ApplicationVO;
	import net.vdombox.ide.common.vo.ResourceVO;
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
			var applicationVO : ApplicationVO;

			switch ( notification.getName() )
			{
				case ApplicationFacade.SERVER_APPLICATIONS_GETTED:
				{
//					applicationsView.visible = true;

					applications = notification.getBody() as Array;
					
					if (applications.length == 0)
					{
						applicationsView.applicationDescription.text = "PleAce Add nEw AppLicAtIonS";
					}
					else
					{
						applicationList.dataProvider = new ArrayList( applications );
						selectApplication();
					}
						

					break;
				}

				case ApplicationFacade.EDIT_APPLICATION_PROPERTY :
				{
					applicationsView.visible = false;

					break;
				}
				case ApplicationFacade.OPEN_APPLICATIONS_VIEW :
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
			
			interests.push( ApplicationFacade.EDIT_APPLICATION_PROPERTY );
			
			interests.push( ApplicationFacade.OPEN_APPLICATIONS_VIEW ); 

			return interests;
		}

		override public function onRegister() : void
		{
//			sendNotification( ApplicationFacade.GET_APPLICATIONS_LIST );

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
			applicationList.selectedItem = value;

			// scroll to index
			applicationList.validateNow();
			applicationList.ensureIndexIsVisible( applicationList.selectedIndex );

			if ( value )
			{
				applicationsView.applicationName.text = selectedApplicationVO.name;
				applicationsView.applicationDescription.text = selectedApplicationDescriptions
			}
			else
			{
				applicationsView.applicationName.text = "";
				applicationsView.applicationDescription.text = "";
			}
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
//			applicationsView.visible = false;

			sendNotification( ApplicationFacade.EDIT_APPLICATION_PROPERTY );
		}

		private function addHandlers() : void
		{
			applicationList.addEventListener( FlexEvent.CREATION_COMPLETE, rendererCreatedHandler, true, 0, true );
			applicationList.addEventListener( IndexChangeEvent.CHANGE, applicationList_changeHandler, false, 0, true );
			applicationList.addEventListener( ApplicationListItemRenderer.RENDERER_DOUBLE_CLICK, applicationList_dubleClickHandler, true, 0, true );

			applicationsView.addApplication.addEventListener( MouseEvent.CLICK, addApplicationClickHandler, false, 0, true );
			applicationsView.changeApplication.addEventListener( MouseEvent.CLICK, changeApplicationClikHandler, false, 0, true );
			applicationsView.setSelectApplication.addEventListener( MouseEvent.CLICK, setSelectApplication, false, 0, true );
		}

		/**
		 *
		 * Function for change value selectedApplicationVO on change selectedItem
		 * of applicationList.
		 *
		 */
		private function applicationList_changeHandler( event : IndexChangeEvent ) : void
		{
			var newSelectedApplication : ApplicationVO;

			if ( event.newIndex != -1 )
				newSelectedApplication = applications[ event.newIndex ] as ApplicationVO;

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
//			applicationsView.visible = false;
			sendNotification( ApplicationFacade.EDIT_APPLICATION_PROPERTY, selectedApplicationVO );
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
			applicationList.removeEventListener( FlexEvent.CREATION_COMPLETE, rendererCreatedHandler, true );
			applicationList.removeEventListener( IndexChangeEvent.CHANGE, applicationList_changeHandler );
			applicationList.removeEventListener( ApplicationListItemRenderer.RENDERER_DOUBLE_CLICK, applicationList_dubleClickHandler, true );

			applicationsView.addApplication.removeEventListener( MouseEvent.CLICK, addApplicationClickHandler );
			applicationsView.changeApplication.removeEventListener( MouseEvent.CLICK, changeApplicationClikHandler );
			applicationsView.setSelectApplication.removeEventListener( MouseEvent.CLICK, setSelectApplication );
		}

		/**
		 *
		 *  To registred mediators for ApplicationListItemRenderer
		 *
		 */
		private function rendererCreatedHandler( event : Event ) : void
		{
			if ( event.target is ApplicationListItemRenderer )
			{
				var mediator : ApplicationListItemRendererMediator = new ApplicationListItemRendererMediator( event.target );
				facade.registerMediator( mediator );
			}
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

			selectedApplicationVO = statesProxy.selectedApplication || getApplicationsFromSettings() || applications[ 0 ];
			
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
