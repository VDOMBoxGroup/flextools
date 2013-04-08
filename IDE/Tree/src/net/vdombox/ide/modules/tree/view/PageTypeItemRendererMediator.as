package net.vdombox.ide.modules.tree.view
{
	import net.vdombox.ide.common.controller.Notifications;
	import net.vdombox.ide.common.events.ItemRendererEvent;
	import net.vdombox.ide.common.model._vo.ResourceVO;
	import net.vdombox.ide.common.model._vo.TypeVO;
	import net.vdombox.ide.common.view.components.itemrenderers.PageTypeItemRenderer;

	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;

	public class PageTypeItemRendererMediator extends Mediator implements IMediator
	{
		public function PageTypeItemRendererMediator( viewComponent : Object = null )
		{
			super( getNextID(), viewComponent );
		}

		public static var serial : Number = -1;

		private static const NAME : String = "PageTypeItemRendererMediator";

		private static function getNextID() : String
		{
			var id : String = NAME + "/" + ++serial;

			return id;
		}

		public function get pageTypeItemRenderer() : PageTypeItemRenderer
		{
			return viewComponent as PageTypeItemRenderer;
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
		}

		private function addHandlers() : void
		{
			pageTypeItemRenderer.addEventListener( ItemRendererEvent.CREATED, createdHandler, false, 0, true );
		}

		private function removeHandlers() : void
		{
			pageTypeItemRenderer.removeEventListener( ItemRendererEvent.CREATED, createdHandler );
		}

		private function createdHandler( event : ItemRendererEvent ) : void
		{
			var typeVO : TypeVO = event.currentTarget.data as TypeVO;

			var resourceVO : ResourceVO = new ResourceVO( typeVO.id );
			resourceVO.setID( typeVO.iconID );

			pageTypeItemRenderer.typeResource = resourceVO;

			sendNotification( Notifications.GET_RESOURCE, resourceVO );
		}
	}
}
