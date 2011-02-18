/*
  Class ObjectsAccordionMediator displays the objects in the list. Wrapper over the ObjectsAccordion.mxml.
*/
package net.vdombox.object_editor.view.mediators
{
	import flash.events.MouseEvent;

	import net.vdombox.object_editor.model.Item;
	import net.vdombox.object_editor.view.AccordionNavigatorContent;
	import net.vdombox.object_editor.view.ObjectsAccordion;

	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;

	public class ObjectsAccordionMediator extends Mediator implements IMediator
	{		
		public static const NAME:String = "AccordionMediator";			

		public function ObjectsAccordionMediator( viewComponent:Object ) 
		{			
			super( NAME, viewComponent );			
			view.addEventListener( MouseEvent.DOUBLE_CLICK, openObject );			
		}

		public function openObject( event:MouseEvent = null ) : void
		{
			sendNotification( ApplicationMediator.RUN_PROGRESS );
			var accordioNavigatorContent:AccordionNavigatorContent =  view.accordion.selectedChild as AccordionNavigatorContent;
			var item:Item = accordioNavigatorContent.selectedObject as Item;
			sendNotification( ApplicationFacade.OPEN_OBJECT, item);
			sendNotification( ApplicationMediator.END_PROGRESS);
		}	

		public function newContent( item:Item ) : void
		{
			var list:AccordionNavigatorContent =  view.getObjectByName(item.groupName) as AccordionNavigatorContent;
			if (!list)
			{
				list  	   = new AccordionNavigatorContent();
				list.name  = item.groupName;
				list.label = item.groupName;
				view.addObject(list);
			}			
			list.appendObject(item);			
		}

		public function removeAllObjects():void
		{
			view.removeAllObjects();
		}

		override public function listNotificationInterests():Array 
		{			
			return [ ApplicationFacade.NEW_NAVIGATOR_CONTENT,
					 ApplicationMediator.REMOVE_ALL_OBJECT ];
		}

		override public function handleNotification( note:INotification ):void 
		{
			switch ( note.getName() ) 
			{				
				case ApplicationFacade.NEW_NAVIGATOR_CONTENT:
				{
					newContent(note.getBody() as Item);
					break;
				}
					
				case ApplicationMediator.REMOVE_ALL_OBJECT:
				{
					removeAllObjects();
					break;
				}
			}
		}
		
		public function get view():ObjectsAccordion
		{
			return viewComponent as ObjectsAccordion;
		}
	}
}

