package net.vdombox.ide.modules.wysiwyg.view
{
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;
	
	public class ItemMediator extends Mediator implements IMediator
	{
		public static const NAME : String = "ItemMediator";
		
		public function ItemMediator( viewComponent : Object )
		{
			super( NAME, viewComponent );
		}
		
		public function get itemMediator() : Item
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
		}
		
		private function removeHandlers() : void
		{
		}
	}
}