package net.vdombox.ide.modules.tree.view
{
	import flash.display.DisplayObjectContainer;
	import flash.events.MouseEvent;
	
	import mx.events.FlexEvent;
	
	import net.vdombox.ide.common.vo.ApplicationVO;
	import net.vdombox.ide.common.vo.PageVO;
	import net.vdombox.ide.modules.tree.ApplicationFacade;
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

		public function get body() : Body
		{
			return viewComponent as Body;
		}

		

		override public function onRegister() : void
		{
			addHandlers();
		}

		override public function onRemove() : void
		{
			removeHandlers();
		}

		override public function listNotificationInterests() : Array
		{
			var interests : Array = super.listNotificationInterests();

			

			return interests;
		}

		override public function handleNotification( notification : INotification ) : void
		{
			var messageName : String = notification.getName();
			var messageBody : Object = notification.getBody();

//			switch ( messageName )
//			{
//				case ApplicationFacade.PAGE_DELETED:
//				{
//					var pageVO : PageVO = messageBody.pageVO;
//					
//					break;
//				}
//			}
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
		}
	}
}