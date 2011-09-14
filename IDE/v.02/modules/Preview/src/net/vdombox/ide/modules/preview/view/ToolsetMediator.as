package net.vdombox.ide.modules.preview.view
{
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	
	import mx.resources.IResourceManager;
	import mx.resources.ResourceManager;
	
	import net.vdombox.ide.modules.preview.ApplicationFacade;
	import net.vdombox.ide.modules.preview.model.SessionProxy;
	import net.vdombox.ide.modules.preview.view.components.Toolset;
	
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
			addEventListeners()
		}

		override public function listNotificationInterests() : Array
		{
			var interests : Array = super.listNotificationInterests();

//			interests.push( ApplicationFacade.MODULE_SELECTED );
//			interests.push( ApplicationFacade.MODULE_DESELECTED );

			return interests;
		}

		override public function handleNotification( notification : INotification ) : void
		{
			switch ( notification.getName() )
			{
				
			}
		}

		private function addEventListeners() : void
		{
			toolset.toolsetButton.addEventListener( MouseEvent.CLICK, toolsetButton_clickHandler )
		}

		private function toolsetButton_clickHandler( event : MouseEvent ) : void
		{
			sendNotification( ApplicationFacade.SELECT_MODULE );
		}
	}
}