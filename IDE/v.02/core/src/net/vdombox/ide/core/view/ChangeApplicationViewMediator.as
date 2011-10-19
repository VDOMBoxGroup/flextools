package net.vdombox.ide.core.view
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.collections.ArrayList;
	import mx.events.FlexEvent;
	
	import net.vdombox.ide.common.vo.ApplicationVO;
	import net.vdombox.ide.common.vo.ResourceVO;
	import net.vdombox.ide.core.ApplicationFacade;
	import net.vdombox.ide.core.events.ApplicationManagerWindowEvent;
	import net.vdombox.ide.core.model.SettingsProxy;
	import net.vdombox.ide.core.model.StatesProxy;
	import net.vdombox.ide.core.model.vo.ModulesCategoryVO;
	import net.vdombox.ide.core.model.vo.SettingsVO;
	import net.vdombox.ide.core.view.components.ApplicationListItemRenderer;
	import net.vdombox.ide.core.view.components.ChangeApplicationView;
	
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;
	
	import spark.components.List;
	import spark.events.IndexChangeEvent;

	public class ChangeApplicationViewMediator extends Mediator implements IMediator
	{
		public static const NAME : String = "ChangeApplicationViewMediator";
		
		private var applications : Array;
		private var applicationsChanged : Boolean;
		
		private var _settingsVO : SettingsVO;
		
		private var _selectedApplicationVO : ApplicationVO;
		private var selectedApplicationChanged : Boolean;
		
		public function ChangeApplicationViewMediator(viewComponent : Object = null )
		{
			super( NAME, viewComponent );
		}
		
		public function get settingsVO():SettingsVO
		{
			var settingsProxy : SettingsProxy = facade.retrieveProxy( SettingsProxy.NAME ) as SettingsProxy;
			return  settingsProxy.settings;
		}
		
		public function get statesProxy():StatesProxy
		{
			return facade.retrieveProxy( StatesProxy.NAME ) as StatesProxy;
		}
		
			

		public function get selectedApplicationVO():ApplicationVO
		{
			return _selectedApplicationVO;
		}

		public function set selectedApplicationVO(value:ApplicationVO):void
		{
			_selectedApplicationVO = value;
			applicationList.selectedItem = value;

			// scroll to index
			applicationList.validateNow();
			applicationList.ensureIndexIsVisible(applicationList.selectedIndex);
			
			if ( value )
			{
				changeApplicationView.applicationName.text = selectedApplicationVO.name;
				changeApplicationView.applicationDescription.text = selectedApplicationDescriptions
			}
			else
			{
				changeApplicationView.applicationName.text = "";
				changeApplicationView.applicationDescription.text = "";
			}
		}
		
		private function get selectedApplicationDescriptions():String
		{
			return selectedApplicationVO.numberOfPages +" - pages, "
				+selectedApplicationVO.numberOfObjects +" - objects \n\n"
				+selectedApplicationVO.description;
		}

		public function get changeApplicationView() : ChangeApplicationView
		{
			return viewComponent as ChangeApplicationView;
		}
		
		public function get applicationList() : List
		{
			return changeApplicationView.applicationList as List;
		}
		
		override public function listNotificationInterests() : Array
		{
			var interests : Array = super.listNotificationInterests();
			
			interests.push( ApplicationFacade.SERVER_APPLICATIONS_GETTED );
			interests.push( ApplicationFacade.CLOSE_APPLICATION_MANAGER );
			
			return interests;
		}
		
		override public function handleNotification( notification : INotification ) : void
		{
			var body : Object = notification.getBody();
			var applicationVO : ApplicationVO;
			
			switch ( notification.getName() )
			{
				case ApplicationFacade.SERVER_APPLICATIONS_GETTED:
				{
					changeApplicationView.visible = true;
					
					applications = notification.getBody() as Array;
					applicationList.dataProvider = new ArrayList( applications );
					selectApplication();
					
					break;
				}
					
				case ApplicationFacade.CLOSE_APPLICATION_MANAGER:
				{
					facade.removeMediator( mediatorName );
					
					break;
				}	
			}
		}
		
		
		
		/**
		 * 
		 *  Set selected Application. It is a selectedApplication or last opened 
		 * or first of existed.
		 * 
		 */
		private function  selectApplication(): void
		{
			if ( !applications || applications.length == 0 )
				return ;
			
			selectedApplicationVO = statesProxy.selectedApplication
									|| getApplicationsFromSettings()
									|| applications[ 0 ];
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
					return	applications[ i ] as ApplicationVO;
			}
			
			return null;
		}
		
		override public function onRegister() : void
		{
			sendNotification( ApplicationFacade.GET_APPLICATIONS_LIST );

			addHandlers();
		}
		
		override public function onRemove() : void
		{
			removeHandlers();
		}
		
		private function addHandlers() : void
		{
			applicationList.addEventListener( FlexEvent.CREATION_COMPLETE, rendererCreatedHandler, true );
			applicationList.addEventListener( IndexChangeEvent.CHANGE, applicationList_changeHandler, false, 0, true );
			applicationList.addEventListener( MouseEvent.DOUBLE_CLICK, applicationList_dubleClickHandler, true );
			
			changeApplicationView.addApplication.addEventListener(MouseEvent.CLICK, addApplicationClickHandler, false, 0, true );
			changeApplicationView.changeApplication.addEventListener(MouseEvent.CLICK, changeApplicationClikHandler, false, 0, true );
			changeApplicationView.setSelectApplication.addEventListener(MouseEvent.CLICK, setSelectApplication, false, 0, true );
		}
		
		private function removeHandlers() : void
		{
			applicationList.removeEventListener( FlexEvent.CREATION_COMPLETE, rendererCreatedHandler, true );
			applicationList.removeEventListener( IndexChangeEvent.CHANGE, applicationList_changeHandler );
			applicationList.removeEventListener( MouseEvent.DOUBLE_CLICK, applicationList_dubleClickHandler, true );
			
			changeApplicationView.addApplication.removeEventListener(MouseEvent.CLICK, addApplicationClickHandler);
			changeApplicationView.changeApplication.removeEventListener(MouseEvent.CLICK, changeApplicationClikHandler);
			changeApplicationView.setSelectApplication.removeEventListener(MouseEvent.CLICK, setSelectApplication);
		}
		
		
		private function setSelectApplication( event : MouseEvent ) : void
		{
			sendNotification(ApplicationFacade.SET_SELECTED_APPLICATION, selectedApplicationVO); 
//			sendNotification( ApplicationFacade.CLOSE_APPLICATION_MANAGER );
		}
		
		private function changeApplicationClikHandler( event : MouseEvent ) : void
		{
			changeApplicationView.visible = false;
			sendNotification( ApplicationFacade.EDIT_APPLICATION_PROPERTY, selectedApplicationVO );
		}
		
		
		private function applicationList_dubleClickHandler ( event : MouseEvent ) : void
		{
			var applicationListItemRenderer : ApplicationListItemRenderer = event.target as ApplicationListItemRenderer;
			
			if ( applicationListItemRenderer )
			{
				changeApplicationView.visible = false;
				
				sendNotification( ApplicationFacade.EDIT_APPLICATION_PROPERTY, applicationListItemRenderer.resourceVO );
			}
		}
		
		private function addApplicationClickHandler( event : MouseEvent ) : void
		{
			changeApplicationView.visible = false;
			
			sendNotification( ApplicationFacade.EDIT_APPLICATION_PROPERTY );
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
		
		/**
		 * 
		 *  To registred mediators for ApplicationListItemRenderer
		 * 
		 */ 
		private function rendererCreatedHandler( event : Event ) : void
		{
			if( event.target is ApplicationListItemRenderer)
			{
				var mediator : ApplicationListItemRendererMediator = new ApplicationListItemRendererMediator(  event.target );
				facade.registerMediator( mediator );
			}
		}
	}
}