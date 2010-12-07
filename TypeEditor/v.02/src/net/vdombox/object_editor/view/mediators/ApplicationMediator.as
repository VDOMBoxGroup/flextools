/*
  Class ApplicationMediator register all Mediators
*/
package net.vdombox.object_editor.view.mediators
{
	import net.vdombox.object_editor.controller.OpenDirectoryCommand;
	import net.vdombox.object_editor.view.mediators.AccordionMediator;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.facade.Facade;
	import org.puremvc.as3.patterns.mediator.Mediator;

	public class ApplicationMediator extends Mediator implements IMediator
	{
		public static const NAME:String = "ApplicationMediator";
				
		protected function get app():ObjectEditor2
		{
			return viewComponent as ObjectEditor2
		}
		
		public function ApplicationMediator( viewComponent:Object ) 
		{			
			super( NAME, viewComponent );	
			
			facade.registerMediator( new OpenMediator( app.openButton ) ); 		
			facade.registerMediator( new AccordionMediator( app.objAccordion ) );
		}
	}
}