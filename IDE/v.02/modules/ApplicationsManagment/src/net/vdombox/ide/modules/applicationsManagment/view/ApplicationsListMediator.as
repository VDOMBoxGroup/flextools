package net.vdombox.ide.modules.applicationsManagment.view
{
	import flash.events.Event;
	
	import mx.collections.ArrayList;
	import mx.core.ClassFactory;
	import mx.events.FlexEvent;
	
	import net.vdombox.ide.common.vo.ApplicationVO;
	import net.vdombox.ide.modules.applicationsManagment.ApplicationFacade;
	import net.vdombox.ide.modules.applicationsManagment.model.vo.SettingsVO;
	import net.vdombox.ide.modules.applicationsManagment.view.components.ApplicationItemRenderer;
	
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;
	
	import spark.components.List;
	import spark.events.IndexChangeEvent;

	public class ApplicationsListMediator extends Mediator implements IMediator
	{
		public function ApplicationsListMediator( viewComponent : Object = null )
		{
			super( NAME, viewComponent );
		}

		public const NAME : String = "ApplicationsListMediator";

		private var applications : Array;
		private var selectedApplication : ApplicationVO;
		
		private var saveLastApplication : Boolean;
		
		private var lastApplicationID : String;

		override public function listNotificationInterests() : Array
		{
			var interests : Array = super.listNotificationInterests();

			interests.push( ApplicationFacade.APPLICATIONS_LIST_GETTED );
			interests.push( ApplicationFacade.SELECTED_APPLICATION_CHANGED );
			
			interests.push( NAME + "/" + ApplicationFacade.SETTINGS_GETTED );
			interests.push( ApplicationFacade.SETTINGS_SETTED );

			return interests;
		}

		override public function onRegister() : void
		{
			addHandlers();
			
			saveLastApplication = false;
			
			applicationsList.itemRenderer = new ClassFactory( ApplicationItemRenderer );

			sendNotification( ApplicationFacade.GET_SETTINGS, NAME );
			sendNotification( ApplicationFacade.GET_APPLICATIONS_LIST );
		}

		override public function handleNotification( notification : INotification ) : void
		{
			switch ( notification.getName())
			{
				case ApplicationFacade.APPLICATIONS_LIST_GETTED:
				{
					applications = notification.getBody() as Array;
					applicationsList.dataProvider = new ArrayList( applications );

					sendNotification( ApplicationFacade.GET_SELECTED_APPLICATION );
					break;
				}

				case ApplicationFacade.SELECTED_APPLICATION_CHANGED:
				{
					var newSelectedApplication : ApplicationVO = notification.getBody() as ApplicationVO;
					
					if ( !applications || applications.length == 0 )
						return;
					
					if( newSelectedApplication == null )
					{
						for ( var i : int = 0; i < applications.length; i++ )
						{
							if ( applications[ i ].id == lastApplicationID )
							{
								newSelectedApplication = applications[ i ];
								var index : int = applications.lastIndexOf( newSelectedApplication );
								
								if ( index == -1 )
									return;
								
								applicationsList.selectedIndex = index;
								return;
							}
						}
					}
					
					var index : int = applications.lastIndexOf( newSelectedApplication );

					if ( index == -1 )
						return;
					
					applicationsList.selectedIndex = index;
					selectedApplication = newSelectedApplication;

					if( saveLastApplication )
					{
						var settingsVO : SettingsVO = 
							new SettingsVO( { lastApplicationID : selectedApplication.id, saveLastApplication : saveLastApplication } )
						
						lastApplicationID = settingsVO.lastApplicationID;
							
						sendNotification( ApplicationFacade.SET_SETTINGS, settingsVO );
					}
					
					break;
				}
					
				case NAME + "/" + ApplicationFacade.SETTINGS_GETTED:
				{
					
				}
					
				case ApplicationFacade.SETTINGS_SETTED:
				{
					var settingsVO : SettingsVO = notification.getBody() as SettingsVO;
					
					saveLastApplication = settingsVO.saveLastApplication;
					
					if( saveLastApplication && !lastApplicationID )
					{
						lastApplicationID = settingsVO.lastApplicationID;
					}
					
					break;
				}
			}
		}

		private function get applicationsList() : List
		{
			return viewComponent as List;
		}
		
		private function addHandlers() : void
		{
			applicationsList.addEventListener( ApplicationItemRenderer.RENDERER_CREATED, applicationItemRenderer_rendererCreatedHandler, true )
			applicationsList.addEventListener( IndexChangeEvent.CHANGE, changeHandler );
		}
		
		private function applicationItemRenderer_rendererCreatedHandler( event : Event ) : void
		{
			var renderer : ApplicationItemRenderer = event.target as ApplicationItemRenderer;

			var mediator : ApplicationItemRendererMediator = new ApplicationItemRendererMediator( renderer );
			facade.registerMediator( mediator );
		}
		
		private function changeHandler( event : IndexChangeEvent ) : void
		{
			if( event.newIndex == -1 )
				return;
			
			var newSelectedApplication : ApplicationVO = applications[ event.newIndex ] as ApplicationVO;
			
			if( selectedApplication == newSelectedApplication )
				return;
			
			sendNotification( ApplicationFacade.SET_SELECTED_APPLICATION, newSelectedApplication );
		}
	}
}