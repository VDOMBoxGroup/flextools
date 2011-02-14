package net.vdombox.object_editor.view.mediators
{	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import net.vdombox.object_editor.view.ObjectsAccordion;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	import spark.components.Button;
	
	//TODO: rename to loadButtonMediator
	public class CreateObjectMediator extends Mediator implements IMediator
	{		
		public static const NAME:String = "CreateObjectMediator";
		
		public function CreateObjectMediator( viewComponent:Object ) 
		{			
			super( NAME, viewComponent );
			view.addEventListener( MouseEvent.CLICK, newObject );			
		}		
		
		private function newObject( event:Event = null ) : void
		{
			sendNotification( ApplicationFacade.CRAETE_OBJECT );
		}
				
		protected function get view():Button
		{
			return viewComponent as Button;
		}
	}
}