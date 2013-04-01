package net.vdombox.ide.modules.scripts.view
{
	import flash.events.Event;
	
	import mx.events.FlexEvent;
	
	import net.vdombox.ide.common.controller.Notifications;
	import net.vdombox.ide.common.model.StatesProxy;
	import net.vdombox.ide.common.model.TypesProxy;
	import net.vdombox.ide.modules.scripts.model.SaveParametersTabsProxy;
	import net.vdombox.ide.modules.scripts.view.components.Body;
	
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;

	public class BodyMediator extends Mediator implements IMediator
	{
		public static const NAME : String = "BodyMediator";

		public function BodyMediator( viewComponent : Object = null )
		{
			super( NAME, viewComponent );
		}

		private var isReady : Boolean;
		
		public function get body() : Body
		{
			return viewComponent as Body;
		}

		override public function onRegister() : void
		{
			isReady = false;
			
			addHandlers();
		}

		override public function onRemove() : void
		{
			isReady = false;
			
			removeHandlers();
		}
		
		override public function listNotificationInterests() : Array
		{
			var interests : Array = super.listNotificationInterests();
			
			interests.push( StatesProxy.ALL_STATES_GETTED );
			
			interests.push( Notifications.PIPES_READY );
			interests.push( Notifications.MODULE_DESELECTED );

			return interests;
		}

		override public function handleNotification( notification : INotification ) : void
		{
			switch ( notification.getName())
			{
				case Notifications.PIPES_READY:
				{
					sendNotification( StatesProxy.GET_ALL_STATES );
					sendNotification( TypesProxy.GET_TYPES );
					
					break;
				}
					
				case StatesProxy.ALL_STATES_GETTED:
				{
					isReady = true;
					
					checkConditions();
					
					break;
				}
					
				case Notifications.MODULE_DESELECTED:
				{
					isReady = false;
					
					sendNotification( Notifications.BODY_STOP );
					
					break;
				}
			}
		}

		private function addHandlers() : void
		{
			body.addEventListener( FlexEvent.CREATION_COMPLETE, creationCompleteHandler );
		}
		
		private function removeHandlers() : void
		{
			body.librariesBox.removeEventListener( Event.RESIZE, resizeHandler );
			body.actionsBox.removeEventListener( Event.RESIZE, resizeHandler );
			
			body.removeEventListener( FlexEvent.CREATION_COMPLETE, creationCompleteHandler );
		}
		
		private function creationCompleteHandler( event : FlexEvent ) : void
		{
			var saveParametersTabsProxy : SaveParametersTabsProxy = facade.retrieveProxy( SaveParametersTabsProxy.NAME ) as SaveParametersTabsProxy;
			body.librariesBox.width = saveParametersTabsProxy.libraryWidth;
			body.actionsBox.width = saveParametersTabsProxy.actionsWidth;
			
			if ( saveParametersTabsProxy.containersHeight != 0 && saveParametersTabsProxy.globalScriptsHeight != 0 )
			{
				body.containersPanel.percentHeight = saveParametersTabsProxy.containersHeight * 100;
				body.globalScriptsPanel.percentHeight = saveParametersTabsProxy.globalScriptsHeight * 100;
				body.serverScriptsPanel.percentHeight = 100.0 - body.containersPanel.percentHeight - body.globalScriptsPanel.percentHeight;
			}
				
			body.librariesBox.addEventListener( Event.RESIZE, resizeHandler, false, 0 , true );
			body.actionsBox.addEventListener( Event.RESIZE, resizeHandler, false, 0 , true );
			body.containersPanel.addEventListener( Event.RESIZE, resizeHandler, false, 0 , true );
			body.globalScriptsPanel.addEventListener( Event.RESIZE, resizeHandler, false, 0 , true );
			
			
			sendNotification( Notifications.BODY_CREATED, body );
			
			checkConditions();
		}
		
		private function resizeHandler( event : Event ) : void
		{
			sendNotification( Notifications.SAVE_PARAMETERS_TABS, { librariesBox : body.librariesBox.width, actionsBox : body.actionsBox.width,
																	containersPanel : body.containersPanel.height / body.actionsBox.height, globalScriptsPanel : body.globalScriptsPanel.height / body.actionsBox.height } );
		}
		
		private function checkConditions() : void
		{
			if ( isReady && body.initialized )
				sendNotification( Notifications.BODY_START );
		}
	}
}