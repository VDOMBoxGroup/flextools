package net.vdombox.object_editor.view.mediators
{	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import net.vdombox.object_editor.view.ObjectsAccordion;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	import spark.components.Button;
	
	//TODO: rename to loadButtonMediator
	public class OpenMediator extends Mediator implements IMediator
	{		
		public static const NAME:String = "OpenMediator";
		
		public function OpenMediator( viewComponent:Object ) 
		{			
			super( NAME, viewComponent );
			view.addEventListener( MouseEvent.CLICK, load );			
		}		
		
		private function load( event:Event = null ) : void
		{
			sendNotification( ApplicationFacade.LOAD_XML_FILES );
		}
				
		protected function get view():Button
		{
			return viewComponent as Button;
		}
	}
}