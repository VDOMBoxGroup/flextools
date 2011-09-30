package net.vdombox.ide.core.view
{
	import flash.events.Event;
	
	import mx.collections.ArrayList;
	
	import net.vdombox.ide.common.vo.ApplicationVO;
	import net.vdombox.ide.core.ApplicationFacade;
	import net.vdombox.ide.core.events.ApplicationManagerWindowEvent;
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
		
		private var settings : SettingsVO;
		
		private var selectedApplicationVO : ApplicationVO;
		private var selectedApplicationChanged : Boolean;
		
		public function ChangeApplicationViewMediator(viewComponent : Object = null )
		{
			super( NAME, viewComponent );
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
			interests.push( ApplicationFacade.SELECTED_APPLICATION_CHANGED );
			interests.push( ApplicationFacade.CHANGE_RESOURCE );
			interests.push( ApplicationFacade.CLOSE_APPLICATION_MANAGER );
			interests.push( ApplicationFacade.SETTINGS_GETTED + "/" + mediatorName);
			interests.push( ApplicationFacade.SETTINGS_CHANGED);
			interests.push( ApplicationFacade.APPLICATION_INFORMATION_UPDATED);	
			interests.push( ApplicationFacade.SERVER_APPLICATION_CREATED);	
			
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
					applications = notification.getBody() as Array;
					applicationsChanged = true;
					selectedApplicationChanged = true;
					
					break;
				}
					
				case ApplicationFacade.SELECTED_APPLICATION_CHANGED:
				{
					var newSelectedApplication : ApplicationVO = notification.getBody() as ApplicationVO;
					
					if ( newSelectedApplication && newSelectedApplication == selectedApplicationVO )
						return;
					
					selectedApplicationVO = newSelectedApplication;
					selectedApplicationChanged = true;
					
					break;
				}	
					
				case ApplicationFacade.CHANGE_RESOURCE:
				{
					applicationVO = notification.getBody() as ApplicationVO;
					setInfoApplication( applicationVO );
					
					break;
				}	
					
				case ApplicationFacade.SETTINGS_GETTED + "/" + mediatorName:
				{
					settings = body as SettingsVO;
					
					selectedApplicationChanged = true;
					break;
				}		
					
				case ApplicationFacade.SETTINGS_CHANGED:
				{
					selectedApplicationChanged = true;
					
					break;
				}
					
				case ApplicationFacade.CLOSE_APPLICATION_MANAGER:
				{
					facade.removeMediator( mediatorName );
					
					break;
				}	
				
				case ApplicationFacade.APPLICATION_INFORMATION_UPDATED:
				{
					applicationVO = body as ApplicationVO;
					
					if ( applicationVO === selectedApplicationVO )
						refreshApplicationProperties();
					
					break;
				}
					
				case ApplicationFacade.SERVER_APPLICATION_CREATED:
				{
					sendNotification( ApplicationFacade.GET_APPLICATIONS_LIST );
					sendNotification( ApplicationFacade.GET_SELECTED_APPLICATION );
				}	
					
			
			}
			
			commitProperties();
		}
		
		private function setInfoApplication( applicationVO : ApplicationVO ) : void
		{
			if ( !applicationVO )
				return;
			changeApplicationView.applicationName.text = applicationVO.name;
			changeApplicationView.applicationDescription.text = applicationVO.description;
			selectedApplicationChanged = true;
		}
		
		private function commitProperties() : void
		{
			if ( applicationsChanged )
			{
				applicationsChanged = false;
				applicationList.dataProvider = new ArrayList( applications );
			}
			if ( selectedApplicationChanged )
			{
				selectedApplicationChanged = false;
				
				if ( selectedApplicationVO )
				{
					applicationList.selectedItem = selectedApplicationVO;
					
					
					refreshApplicationProperties();
					
					if ( settings && settings.saveLastApplication && settings.lastApplicationID != selectedApplicationVO.id )
					{
						settings.lastApplicationID = selectedApplicationVO.id
					}
					
					sendNotification( ApplicationFacade.SET_SELECTED_APPLICATION, selectedApplicationVO );
				}
				else
				{
					var newSelectedApplication : ApplicationVO;
					
					if ( !applications || applications.length == 0 )
						return;
					
					if ( settings )
					{
						for ( var i : int = 0; i < applications.length; i++ )
						{
							if ( applications[ i ].id == settings.lastApplicationID )
							{
								newSelectedApplication = applications[ i ];
								break;
							}
						}
						
						
					}
					
					if( !newSelectedApplication )
						newSelectedApplication = applications[ 0 ];
					
					sendNotification( ApplicationFacade.SET_SELECTED_APPLICATION, newSelectedApplication );
				}
			}
		}
		
		private function refreshApplicationProperties() : void
		{
			changeApplicationView.applicationName.text = selectedApplicationVO.name;
			
			
			changeApplicationView.applicationDescription.text = selectedApplicationVO.description;
			
		}
		
		override public function onRegister() : void
		{
			sendNotification( ApplicationFacade.GET_SETTINGS_MANAGER, mediatorName );
			sendNotification( ApplicationFacade.GET_APPLICATIONS_LIST );
			sendNotification( ApplicationFacade.GET_SELECTED_APPLICATION );
			sendNotification( ApplicationFacade.GET_SETTINGS, mediatorName );
			sendNotification( ApplicationFacade.GET_TYPES);

			addHandlers();
		}
		
		override public function onRemove() : void
		{
			removeHandlers();
		}
		
		private function addHandlers() : void
		{
			applicationList.addEventListener( ApplicationListItemRenderer.RENDERER_CREATED, rendererCreatedHandler, true );
			applicationList.addEventListener( IndexChangeEvent.CHANGE, applicationList_changeHandler );
			changeApplicationView.addEventListener( ApplicationManagerWindowEvent.OPEN_IN_EDITOR, openApplicationInEditor );
			changeApplicationView.addEventListener( ApplicationManagerWindowEvent.OPEN_IN_EDIT_VIEW, openApplicationInEditView );
			changeApplicationView.addEventListener( ApplicationManagerWindowEvent.OPEN_IN_CREATE_VIEW, openApplicationInCreateView );
		}
		
		private function removeHandlers() : void
		{
			applicationList.removeEventListener( ApplicationListItemRenderer.RENDERER_CREATED, rendererCreatedHandler, true );
			applicationList.removeEventListener( IndexChangeEvent.CHANGE, applicationList_changeHandler );
			changeApplicationView.removeEventListener( ApplicationManagerWindowEvent.OPEN_IN_EDITOR, openApplicationInEditor );
			changeApplicationView.removeEventListener( ApplicationManagerWindowEvent.OPEN_IN_EDIT_VIEW, openApplicationInEditView );
			changeApplicationView.removeEventListener( ApplicationManagerWindowEvent.OPEN_IN_CREATE_VIEW, openApplicationInCreateView );
		}
		
		private function openApplicationInEditor( event : ApplicationManagerWindowEvent ) : void
		{
			sendNotification( ApplicationFacade.OPEN_APPLICATION_IN_EDITOR);
			sendNotification( ApplicationFacade.CLOSE_APPLICATION_MANAGER );
		}
		
		private function openApplicationInEditView( event : ApplicationManagerWindowEvent ) : void
		{
			sendNotification( ApplicationFacade.OPEN_APPLICATION_IN_EDIT_VIEW, selectedApplicationVO );
		}
		
		private function openApplicationInCreateView( event : ApplicationManagerWindowEvent ) : void
		{
			sendNotification( ApplicationFacade.OPEN_APPLICATION_IN_CREATE_VIEW );
		}
		
		private function applicationList_changeHandler( event : IndexChangeEvent ) : void
		{
			var newSelectedApplication : ApplicationVO;
			
			if ( event.newIndex != -1 )
				newSelectedApplication = applications[ event.newIndex ] as ApplicationVO;
			
			if ( selectedApplicationVO != newSelectedApplication )
			{
				selectedApplicationVO = newSelectedApplication;
				selectedApplicationChanged = true;
				setInfoApplication( selectedApplicationVO );
				commitProperties();
			}
		}
		
		private function rendererCreatedHandler( event : Event ) : void
		{
			var renderer : ApplicationListItemRenderer = event.target as ApplicationListItemRenderer;
			
			var mediator : ApplicationListItemRendererMediator = new ApplicationListItemRendererMediator( renderer );
			facade.registerMediator( mediator );
		}
	}
}