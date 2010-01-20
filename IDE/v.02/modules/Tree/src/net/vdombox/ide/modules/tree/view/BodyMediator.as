package net.vdombox.ide.modules.tree.view
{
	import mx.events.FlexEvent;

	import net.vdombox.ide.common.vo.ApplicationVO;
	import net.vdombox.ide.common.vo.ResourceVO;
	import net.vdombox.ide.modules.tree.ApplicationFacade;
	import net.vdombox.ide.modules.tree.view.components.Body;

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

		public var selectedResource : ResourceVO;

		public var selectedApplication : ApplicationVO;

		public function get body() : Body
		{
			return viewComponent as Body;
		}

		override public function onRegister() : void
		{
			body.addEventListener( FlexEvent.CREATION_COMPLETE, creationCompleteHandler );
		}

		override public function listNotificationInterests() : Array
		{
			var interests : Array = super.listNotificationInterests();

			interests.push( ApplicationFacade.PIPES_READY );

			return interests;
		}

		override public function handleNotification( notification : INotification ) : void
		{
			var resourceVO : ResourceVO;

			switch ( notification.getName())
			{
				case ApplicationFacade.PIPES_READY:
				{
					break;
				}
			}
		}

		private function addEventListeners() : void
		{
			body.addEventListener( FlexEvent.CREATION_COMPLETE, creationCompleteHandler );
		}

		private function creationCompleteHandler( event : FlexEvent ) : void
		{
			addEventListeners();
		}
	}
}