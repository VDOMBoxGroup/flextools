package net.vdombox.ide.modules.applicationsManagment.view
{
	import flash.events.MouseEvent;
	
	import net.vdombox.ide.modules.applicationsManagment.view.components.Toolset;
	
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;

	public class ToolsetMediator extends Mediator implements IMediator
	{
		public static const NAME : String = "ToolsetMediator";

		public function ToolsetMediator( viewComponent : Object = null )
		{
			super( NAME, viewComponent );
		}

		private function get toolset() : Toolset
		{
			return viewComponent as Toolset;
		}

		override public function onRegister() : void
		{
			toolset.addEventListener( MouseEvent.CLICK, toolset_clickHandler );
		}
		
		private function toolset_clickHandler( event : MouseEvent ) : void
		{
			
		}
	}
}