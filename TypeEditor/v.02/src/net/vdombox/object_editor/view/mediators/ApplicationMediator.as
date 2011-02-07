/*
   Class ApplicationMediator register all Mediators
 */
package net.vdombox.object_editor.view.mediators
{
	import flash.events.Event;
	
	import mx.events.ChildExistenceChangedEvent;
	
	import net.vdombox.object_editor.controller.OpenDirectoryCommand;
	import net.vdombox.object_editor.model.vo.ObjectTypeVO;
	import net.vdombox.object_editor.view.ObjectView;
	import net.vdombox.object_editor.view.mediators.ObjectsAccordionMediator;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.facade.Facade;
	import org.puremvc.as3.patterns.mediator.Mediator;

	public class ApplicationMediator extends Mediator implements IMediator
	{
		public static const NAME			:String = "ApplicationMediator";				
		public static const LOAD_INFORMATION:String = "LoadInformation";

		public function ApplicationMediator( viewComponent:Object ) 
		{			
			super( NAME, viewComponent );	

			facade.registerMediator( new OpenMediator( view.openButton ) ); 		
			facade.registerMediator( new ObjectsAccordionMediator( view.objAccordion ) );

//			view.tabNavigator.addEventListener(ChildExistenceChangedEvent.CHILD_REMOVE, objViewRemoved);
		}

		public function newObjectView( objTypeVO:ObjectTypeVO ) : void
		{			
			var objView:ObjectView = new ObjectView();
			objView.label = objTypeVO.name;					

			view.tabNavigator.addChild(objView);
			facade.registerMediator( new ObjectViewMediator( objView, objTypeVO ) );	

			view.tabNavigator.selectedChild = objView;
		}
		
		/**
		 * remove:
		 *   - ObjectViewMediator
		 *   - ObjectView
		 *   - objTypeVO
		 **/
		public function removeObjectView( objView:ObjectView, objTypeVO:ObjectTypeVO ) : void
		{		
			
			facade.removeMediator( "ObjectViewMediator" + objTypeVO.id );	
			view.tabNavigator.removeChild(objView);
//			objTypeVO
			
//			view.tabNavigator.selectedChild = objView;
		}

		override public function listNotificationInterests():Array 
		{			
			return [ ApplicationFacade.OBJECT_COMPLIT, ApplicationFacade.OBJECT_EXIST, ObjectViewMediator.CLOSE_OBJECT_TYPE_VIEW ];
		}

		override public function handleNotification( note:INotification ):void 
		{
			switch ( note.getName() ) 
			{				
				case ApplicationFacade.OBJECT_COMPLIT:
				{
					newObjectView(note.getBody() as ObjectTypeVO);
					break;	
				}
					
				case ApplicationFacade.OBJECT_EXIST:
				{
					var toSelectedOjectName:String = note.getBody() as String;
					view.tabNavigator.selectedChild = view.tabNavigator.getChildByName( toSelectedOjectName) as ObjectView;
					break;	
				}
					
				case ObjectViewMediator.CLOSE_OBJECT_TYPE_VIEW:
				{
					removeObjectView(note.getBody()["objView"], note.getBody()["objVO"]);
					break;	
				}
			}
		}

		private function  objViewRemoved( event : ChildExistenceChangedEvent ):void
		{
			trace ("remouved is works!")
			var objView:ObjectView = event.relatedObject as ObjectView;
			objView.dispatchEvent( new Event(ObjectViewMediator.OBJECT_TYPE_VIEW_REMOVED));
		}

		protected function get view():ObjectEditor2
		{
			return viewComponent as ObjectEditor2
		}
	}
}