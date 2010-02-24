package net.vdombox.ide.modules.wysiwyg.view
{
	import net.vdombox.ide.modules.wysiwyg.ApplicationFacade;
	import net.vdombox.ide.modules.wysiwyg.events.ItemEvent;
	import net.vdombox.ide.modules.wysiwyg.model.vo.ItemVO;
	import net.vdombox.ide.modules.wysiwyg.view.components.Item;

	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;

	public class ItemMediator extends Mediator implements IMediator
	{
		public static const NAME : String = "ItemMediator";

		public function ItemMediator( viewComponent : Item )
		{
			var itemVO : ItemVO = viewComponent.data as ItemVO;

			super( NAME + ApplicationFacade.DELIMITER + itemVO.id, viewComponent );
		}

		public function get item() : Item
		{
			return viewComponent as Item;
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

//			interests.push( ApplicationFacade.SELECTED_PAGE_CHANGED );

			return interests;
		}

		override public function handleNotification( notification : INotification ) : void
		{
			var name : String = notification.getName();
			var body : Object = notification.getBody();

			switch ( name )
			{
//				case ApplicationFacade.SELECTED_PAGE_CHANGED:
//				{
//					isSelectedPageVOChanged = true;
//					commitProperties();
//					break;
//				}
			}
		}

		private function addHandlers() : void
		{
			item.addEventListener( ItemEvent.GET_RESOURCE, item_getResourceHandler, true, 0, true );
		}

		private function removeHandlers() : void
		{
			item.removeEventListener( ItemEvent.GET_RESOURCE, item_getResourceHandler, true )
		}

		private function item_getResourceHandler( event : ItemEvent ) : void
		{
			var d : * = "";
		}
	}
}