package net.vdombox.ide.modules.applicationsSearch.view
{
	import flash.events.MouseEvent;
	
	import mx.resources.IResourceManager;
	import mx.resources.ResourceManager;
	
	import net.vdombox.ide.modules.applicationsSearch.view.components.Toolset;
	
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
		
		public function set selected ( value : Boolean ) : void
		{
			toolset.selected = value;
		}
		
		private function get toolset() : Toolset
		{
			return viewComponent as Toolset;
		}

		override public function onRegister() : void
		{
			toolset.label = resourceManager.getString( "Modules", "applicationManagment" );
			toolset.addEventListener( MouseEvent.CLICK, toolset_clickHandler );
		}
		
		private function toolset_clickHandler( event : MouseEvent ) : void
		{
			
		}
	}
}