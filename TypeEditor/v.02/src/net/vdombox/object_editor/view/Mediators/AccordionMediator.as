package net.vdombox.object_editor.view.Mediators
{
	import flash.events.Event;
	
	import net.vdombox.object_editor.model.ObjectShowing;
	import net.vdombox.object_editor.view.ObjectsAccordion;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	import spark.components.NavigatorContent;

	public class AccordionMediator extends Mediator implements IMediator
	{		
		public static const NAME:String = "AccordionMediator";		
		
		public function AccordionMediator( viewComponent:Object ) 
		{			
			super( NAME, viewComponent );			
			objAccordion.addEventListener( ObjectsAccordion.CHOSE_OBJECT, openObject );
			objAccordion.addEventListener( ApplicationFacade.NEW_NAVIGATOR_CONTENT, newContent );
		}
		
		public function openObject( event:Event = null ) : void
		{
			sendNotification( ApplicationFacade.OPEN_OBJECT );
		}	
			
//TODO: загрузка не по такому параметру, по по note		
		public function newContent( objShowing:ObjectShowing ) : void
		{
			var navContent:NavigatorContent = new NavigatorContent;
			navContent.label = objShowing.objectName;
			
//TODO: какое событие должно быть на наивгаторе? нужен-то doubleClick			
//			navContent.addEventListener(Event.ACTIVATE, choseObject);
			objAccordion.addChild(navContent);
		}
		
		protected function get objAccordion():ObjectsAccordion
		{
			return viewComponent as ObjectsAccordion;
		}
	}
}