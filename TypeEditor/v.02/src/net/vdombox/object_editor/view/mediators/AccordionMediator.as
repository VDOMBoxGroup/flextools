package net.vdombox.object_editor.view.mediators
{
	import flash.events.Event;
	
	import mx.core.ClassFactory;
	import mx.states.AddChild;
	import mx.utils.object_proxy;
	
	import net.vdombox.object_editor.model.Item;
	import net.vdombox.object_editor.view.AccordionNavigatorContent;
	import net.vdombox.object_editor.view.ListItemRenderer;
	import net.vdombox.object_editor.view.ObjectsAccordion;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	import spark.components.List;
	import spark.components.NavigatorContent;
	import spark.components.supportClasses.ItemRenderer;

	public class AccordionMediator extends Mediator implements IMediator
	{		
		public static const NAME:String = "AccordionMediator";			
		
		public function AccordionMediator( viewComponent:Object ) 
		{			
			super( NAME, viewComponent );			
			objAccordion.addEventListener( ObjectsAccordion.CHOSE_OBJECT, openObject );
//			facade.addEventListener( ApplicationFacade.NEW_NAVIGATOR_CONTENT, newContent );			
		}
		
		public function openObject( event:Event = null ) : void
		{
			sendNotification( ApplicationFacade.OPEN_OBJECT );
		}	
			
//TODO: загрузка не по такому параметру, по note		
		public function newContent( item:Item ) : void
		{
			var list:AccordionNavigatorContent =  objAccordion.getObjectdByName(item.groupName) as AccordionNavigatorContent;
			if (!list)
			{
				trace("new list: " + item.groupName)
				 list  = new AccordionNavigatorContent();
				 list.name = item.groupName;
				 list.label = item.groupName;
				 objAccordion.addObject(list);
			}			
			list.appendObject(item);
		}
	
		protected function get objAccordion():ObjectsAccordion
		{
			return viewComponent as ObjectsAccordion;
		}	
		
		public function removeAllObjects():void
		{
			objAccordion.removeAllObjects();
		}
	}
}