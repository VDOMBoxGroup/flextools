package net.vdombox.ide.modules.tree.view
{
	import flash.events.MouseEvent;
	
	import mx.resources.IResourceManager;
	import mx.resources.ResourceManager;
	
	import net.vdombox.ide.common.controller.Notifications;
	import net.vdombox.ide.modules.tree.view.components.Toolset;
	
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;

	public class ToolsetMediator extends Mediator implements IMediator
	{
		public static const NAME : String = "ToolsetMediator";

		public function ToolsetMediator( viewComponent : Object = null )
		{
			super( NAME, viewComponent );
		}

		private var resourceManager : IResourceManager = ResourceManager.getInstance();

		public function get toolset() : Toolset
		{
			return viewComponent as Toolset;
		}

		override public function onRegister() : void
		{
			addHandlers()
		}

		override public function listNotificationInterests() : Array
		{
			var interests : Array = super.listNotificationInterests();

			interests.push( Notifications.MODULE_SELECTED );
			interests.push( Notifications.MODULE_DESELECTED );

			return interests;
		}

		override public function handleNotification( notification : INotification ) : void
		{
			switch ( notification.getName() )
			{
				case Notifications.MODULE_SELECTED:
				{
					toolset.toolsetButton.selected = true;
					
					break;
				}

				case Notifications.MODULE_DESELECTED:
				{
					toolset.toolsetButton.selected = false;
					
					break;
				}
			}
		}

		private function addHandlers() : void
		{
			toolset.toolsetButton.addEventListener( MouseEvent.CLICK, toolsetButton_clickHandler )
		}

		private function toolsetButton_clickHandler( event : MouseEvent ) : void
		{
			toolset.toolsetButton.selected = !toolset.toolsetButton.selected;
			sendNotification( Notifications.SELECT_MODULE );
		}
	}
}