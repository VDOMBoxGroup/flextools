package net.vdombox.ide.modules.applicationsManagment.view
{
	import flash.events.Event;
	
	import mx.resources.IResourceManager;
	import mx.resources.ResourceManager;
	
	import net.vdombox.ide.modules.applicationsManagment.ApplicationFacade;
	import net.vdombox.ide.modules.applicationsManagment.events.ToolsetEvent;
	import net.vdombox.ide.modules.applicationsManagment.view.components.Toolset;
	
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
					break;
				}

				case ApplicationFacade.MODULE_DESELECTED:
				{
					break;
				}
			}
		}
		
		private function addEventListeners() : void
		{
			toolset.addEventListener( ToolsetEvent.OPEN_CREATE_APPLICATION, toolset_openCreateApplicationHandler );
		}

		private function toolset_openCreateApplicationHandler( event : ToolsetEvent ) : void
		{
			sendNotification( ApplicationFacade.OPEN_CREATE_APPLICATION_VIEW );
		}
	}
}