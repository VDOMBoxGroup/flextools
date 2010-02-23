package net.vdombox.ide.modules.wysiwyg.view
{
	import flash.events.MouseEvent;
	
	import mx.resources.IResourceManager;
	import mx.resources.ResourceManager;
	
	import net.vdombox.ide.modules.wysiwyg.ApplicationFacade;
	import net.vdombox.ide.modules.wysiwyg.view.components.Toolset;
	
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

			interests.push( ApplicationFacade.MODULE_SELECTED );
			interests.push( ApplicationFacade.MODULE_DESELECTED );

			return interests;
		}

		override public function handleNotification( notification : INotification ) : void
		{
			switch ( notification.getName())
			{
				case ApplicationFacade.MODULE_SELECTED:
				{
					toolset.toolsetButton.selected = true;
					
					break;
				}
					
				case ApplicationFacade.MODULE_DESELECTED:
				{
					toolset.toolsetButton.selected = false;
					
					break;
				}
			}
		}
		
		private function addHandlers() : void
		{
			toolset.toolsetButton.addEventListener( MouseEvent.CLICK, toolsetButton_click )
		}
		
		private function toolsetButton_click( event : MouseEvent ) : void
		{
			sendNotification( ApplicationFacade.SELECT_MODULE );
		}
	}
}