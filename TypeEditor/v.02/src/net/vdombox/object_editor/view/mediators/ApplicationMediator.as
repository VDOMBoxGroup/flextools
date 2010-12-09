/*
  Class ApplicationMediator register all Mediators
*/
package net.vdombox.object_editor.view.mediators
{
	import net.vdombox.object_editor.controller.OpenDirectoryCommand;
	import net.vdombox.object_editor.model.vo.ObjectTypeVO;
	import net.vdombox.object_editor.view.mediators.AccordionMediator;
	
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
			
			facade.registerMediator( new OpenMediator( app.openButton ) ); 		
			facade.registerMediator( new AccordionMediator( app.objAccordion ) );
//			facade.registerMediator( new AccordionMediator( app.objAccordion ) );
		}
		
		public function newObjectView( objTypeVO:ObjectTypeVO ) : void
		{			
			app.addObjectView( objTypeVO );
			trace("newObjectView");
		}
		
		override public function listNotificationInterests():Array 
		{			
			return [ ApplicationFacade.OBJECT_COMPLIT ];
		}
			
		override public function handleNotification( note:INotification ):void 
		{
			switch ( note.getName() ) 
			{				
				case ApplicationFacade.OBJECT_COMPLIT:
					trace("ApplicationMediator");
					newObjectView(note.getBody() as ObjectTypeVO);
					break;				
			}
		}
		
		protected function get app():ObjectEditor2
		{
			return viewComponent as ObjectEditor2
		}
	}
}