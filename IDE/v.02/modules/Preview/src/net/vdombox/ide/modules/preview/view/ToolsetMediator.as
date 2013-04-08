package net.vdombox.ide.modules.preview.view
{
	import flash.events.MouseEvent;

	import mx.resources.IResourceManager;
	import mx.resources.ResourceManager;

	import net.vdombox.ide.common.controller.Notifications;
	import net.vdombox.ide.common.model.StatesProxy;
	import net.vdombox.ide.common.model._vo.ApplicationVO;
	import net.vdombox.ide.modules.preview.view.components.Toolset;

	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;

	public class ToolsetMediator extends Mediator implements IMediator
	{
		public static const NAME : String = "ToolsetMediator";

		public function ToolsetMediator( viewComponent : Object = null )
		{
			super( NAME, viewComponent );
		}

		private var resourceManager : IResourceManager = ResourceManager.getInstance();

		private var statesProxy : StatesProxy;

		public function get toolset() : Toolset
		{
			return viewComponent as Toolset;
		}

		override public function onRegister() : void
		{
			addEventListeners()
			statesProxy = facade.retrieveProxy( StatesProxy.NAME ) as StatesProxy;
		}

		private function addEventListeners() : void
		{
			toolset.toolsetButton.addEventListener( MouseEvent.CLICK, toolsetButton_clickHandler );
			toolset.popUpImage.addEventListener( MouseEvent.CLICK, popUpImage_clickHandler )
		}

		private function toolsetButton_clickHandler( event : MouseEvent ) : void
		{

			sendNotification( Notifications.SELECT_MODULE );
		}

		private function popUpImage_clickHandler( event : MouseEvent ) : void
		{
			sendNotification( StatesProxy.GET_ALL_STATES, toolset.toolsetButton );
		}
	}
}
