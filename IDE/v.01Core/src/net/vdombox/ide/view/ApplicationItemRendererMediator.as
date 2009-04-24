package net.vdombox.ide.view
{
	import mx.events.FlexEvent;
	
	import net.vdombox.ide.view.controls.ApplicationItemRenderer;
	
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;

	public class ApplicationItemRendererMediator extends Mediator implements IMediator
	{
		public static const NAME : String = "ApplicationItemRendererMediator";

		public function ApplicationItemRendererMediator( viewComponent : Object = null )
		{
			super( NAME, viewComponent );
			applicationItemRenderer.addEventListener( FlexEvent.DATA_CHANGE, dataChangeHandler )
			
			if( applicationItemRenderer.data )
			{
				var dummy : * = ""; // FIXME remove dummy
			}
		}
		
		private var iconID : String;
		
		private function get applicationItemRenderer() : ApplicationItemRenderer
		{
			return viewComponent as ApplicationItemRenderer;
		}

		private function dataChangeHandler( event : FlexEvent ) : void
		{
			if( applicationItemRenderer.data )
			{
				var newIconID : String = applicationItemRenderer.data.Information.Icon;
				
				if( iconID == newIconID )
					return;
				iconID = newIconID;
			}
			
		}
	}
}