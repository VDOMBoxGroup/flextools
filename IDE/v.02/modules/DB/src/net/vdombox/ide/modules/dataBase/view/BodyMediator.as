package net.vdombox.ide.modules.dataBase.view
{
	import flash.events.Event;
	
	import mx.collections.ArrayList;
	import mx.events.FlexEvent;
	
	import net.vdombox.ide.common.model.vo.ApplicationVO;
	import net.vdombox.ide.common.model.vo.ResourceVO;
	import net.vdombox.ide.modules.dataBase.ApplicationFacade;
	import net.vdombox.ide.modules.dataBase.view.components.Body;
	
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;
	
	import spark.events.IndexChangeEvent;

	public class BodyMediator extends Mediator implements IMediator
	{
		public static const NAME : String = "BodyMediator";

		public function BodyMediator( viewComponent : Object = null )
		{
			super( NAME, viewComponent );
		}

		private var isReady : Boolean;
		private var isAllStatesGetted : Boolean;
		private var isTypesChanged : Boolean;
		
		public var selectedResource : ResourceVO;

		public var selectedApplication : ApplicationVO;

		public function get body() : Body
		{
			return viewComponent as Body;
		}

		override public function onRegister() : void
		{
			isReady = false;
			isAllStatesGetted = false;
			isTypesChanged = false;
			
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

			interests.push( ApplicationFacade.ALL_STATES_GETTED );
			interests.push( ApplicationFacade.TYPES_CHANGED );
			
			interests.push( ApplicationFacade.PIPES_READY );
			interests.push( ApplicationFacade.MODULE_DESELECTED );
			
			return interests;
		}

		override public function handleNotification( notification : INotification ) : void
		{
			var resourceVO : ResourceVO;

			switch ( notification.getName() )
			{
				case ApplicationFacade.PIPES_READY:
				{
					sendNotification( ApplicationFacade.GET_ALL_STATES );
					sendNotification( ApplicationFacade.GET_TYPES );
					
					break;
				}
					
				case ApplicationFacade.ALL_STATES_GETTED:
				{
					isAllStatesGetted = true;
					
					checkConditions();
					
					break;
				}
					
				case ApplicationFacade.TYPES_CHANGED:
				{
					isTypesChanged = true;
					
					checkConditions();
					
					break;
				}
					
				case ApplicationFacade.MODULE_DESELECTED:
				{
					isReady = false;
					
					sendNotification( ApplicationFacade.BODY_STOP );
					
					break;
				}
			}
		}

		private function addHandlers() : void
		{
			body.addEventListener( FlexEvent.CREATION_COMPLETE, creationCompleteHandler, false, 0, true );
		}

		private function removeHandlers() : void
		{
			body.removeEventListener( FlexEvent.CREATION_COMPLETE, creationCompleteHandler );
		}
		
		private function checkConditions() : void
		{
			if ( isTypesChanged && isAllStatesGetted && body.initialized )
			{
				isReady = true;
				sendNotification( ApplicationFacade.BODY_START );
			}
		}

		private function creationCompleteHandler( event : FlexEvent ) : void
		{
			sendNotification( ApplicationFacade.BODY_CREATED, body );
			
			checkConditions();
		}
	}
}