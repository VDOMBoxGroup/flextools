package view
{
	import controller.OpenFileCommand;
	
	import flash.events.Event;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	import view.components.ControlPanel;

	public class OpenMediator extends Mediator implements IMediator
	{
		// Cannonical name of the Mediator
		public static const NAME:String = "OpenMediator";
//		public static const OPEN_BUTTON_PRESSED :String = "openButtonPressed";
		
		/**
		 * Constructor. 
		 */
		public function OpenMediator( viewComponent:Object ) 
		{
			trace("set lisenner");
			super( NAME, viewComponent );					
			controlPanel.addEventListener( ControlPanel.OPEN_BUTTON_PRESSED, load );	
			trace("OpenMediator конец");
		}		
		
		private function load( event:Event = null ) : void
		{
			sendNotification( ApplicationFacade.LOAD_FILE );
		}
				
		protected function get controlPanel():ControlPanel
		{
			return viewComponent as ControlPanel;
		}
		
		private var openFileCommand:OpenFileCommand;
	}
}