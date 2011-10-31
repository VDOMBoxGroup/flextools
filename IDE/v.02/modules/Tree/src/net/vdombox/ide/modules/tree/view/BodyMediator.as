package net.vdombox.ide.modules.tree.view
{
	import flash.display.DisplayObjectContainer;
	import flash.events.MouseEvent;

	import mx.events.FlexEvent;
	import mx.managers.PopUpManager;

	import net.vdombox.ide.common.vo.ApplicationVO;
	import net.vdombox.ide.common.vo.PageVO;
	import net.vdombox.ide.modules.tree.ApplicationFacade;
	import net.vdombox.ide.modules.tree.model.SessionProxy;
	import net.vdombox.ide.modules.tree.model.vo.LinkageVO;
	import net.vdombox.ide.modules.tree.model.vo.TreeElementVO;
	import net.vdombox.ide.modules.tree.model.vo.TreeLevelVO;
	import net.vdombox.ide.modules.tree.view.components.Body;
	import net.vdombox.ide.modules.tree.view.components.Linkage;
	import net.vdombox.ide.modules.tree.view.components.TreeElement;

	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;

	import spark.components.Group;
	import spark.effects.Move;
	import spark.effects.easing.EaseInOutBase;

	public class BodyMediator extends Mediator implements IMediator
	{
		public static const NAME : String = "BodyMediator";

		public function BodyMediator( viewComponent : Object )
		{
			super( NAME, viewComponent );
		}

		private var sessionProxy : SessionProxy;

		private var isAllStatesGetted : Boolean;
		private var isPagesGetted : Boolean;
		private var isApplicationStructureGetted : Boolean;
		
		private var isBodyStarted : Boolean;

		public function get body() : Body
		{
			return viewComponent as Body;
		}

		override public function onRegister() : void
		{
			isAllStatesGetted = false;
			isPagesGetted = false;
			isApplicationStructureGetted = false;
			isBodyStarted = false;

			sessionProxy = facade.retrieveProxy( SessionProxy.NAME ) as SessionProxy;

			addHandlers();
		}

		override public function onRemove() : void
		{
			isAllStatesGetted = false;
			isPagesGetted = false;
			isApplicationStructureGetted = false;

			isBodyStarted = false;
			
			removeHandlers();
		}

		override public function listNotificationInterests() : Array
		{
			var interests : Array = super.listNotificationInterests();

			interests.push( ApplicationFacade.ALL_STATES_GETTED );
			interests.push( ApplicationFacade.PAGES_GETTED );
			interests.push( ApplicationFacade.APPLICATION_STRUCTURE_GETTED );
			interests.push( ApplicationFacade.SELECTED_APPLICATION_CHANGED );

			interests.push( ApplicationFacade.PIPES_READY );
			interests.push( ApplicationFacade.MODULE_DESELECTED );

			return interests;
		}

		override public function handleNotification( notification : INotification ) : void
		{
			var messageName : String = notification.getName();
			var messageBody : Object = notification.getBody();

			switch ( notification.getName() )
			{
				case ApplicationFacade.PIPES_READY:
				{
					sendNotification( ApplicationFacade.GET_ALL_STATES );

					break;
				}
				
				case ApplicationFacade.SELECTED_APPLICATION_CHANGED:
				{
					isAllStatesGetted = true;
					
					if ( sessionProxy.selectedApplication )
					{
						sendNotification( ApplicationFacade.GET_PAGES, sessionProxy.selectedApplication );
						sendNotification( ApplicationFacade.GET_APPLICATION_STRUCTURE, sessionProxy.selectedApplication );
					}
					
					checkConditions();
					
					break;
				}
					
				case ApplicationFacade.ALL_STATES_GETTED:
				{
					isAllStatesGetted = true;

					if ( sessionProxy.selectedApplication )
					{
						sendNotification( ApplicationFacade.GET_PAGES, sessionProxy.selectedApplication );
						sendNotification( ApplicationFacade.GET_APPLICATION_STRUCTURE, sessionProxy.selectedApplication );
					}

					checkConditions();

					break;
				}

				case ApplicationFacade.PAGES_GETTED:
				{
					isPagesGetted = true;

					checkConditions();

					break;
				}

				case ApplicationFacade.APPLICATION_STRUCTURE_GETTED:
				{
					isApplicationStructureGetted = true;

					checkConditions();

					break;
				}

				case ApplicationFacade.MODULE_DESELECTED:
				{
					isAllStatesGetted = false;
					isApplicationStructureGetted = false;
					isPagesGetted = false;

					sendNotification( ApplicationFacade.BODY_STOP );
					
					isBodyStarted = false;

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
			body.removeEventListener( FlexEvent.CREATION_COMPLETE, creationCompleteHandler );
		}

		private function creationCompleteHandler( event : FlexEvent ) : void
		{
			sendNotification( ApplicationFacade.BODY_CREATED, body );

			checkConditions();
		}

		private function checkConditions() : void
		{
			if ( isAllStatesGetted && isPagesGetted && isApplicationStructureGetted && body.initialized && !isBodyStarted )
			{
				isBodyStarted = true;
				sendNotification( ApplicationFacade.BODY_START );
			}
		}
	}
}