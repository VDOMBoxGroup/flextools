/*
	Class ErrorLogMediator is a wrapper over the ErrorLog.mxml.
*/
package net.vdombox.object_editor.view.mediators
{
	import flash.events.Event;
	
	import mx.events.FlexEvent;
	
	import net.vdombox.object_editor.model.ErrorLogger;
	import net.vdombox.object_editor.model.vo.ObjectTypeVO;
	import net.vdombox.object_editor.view.essence.ErrorLog;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.patterns.mediator.Mediator;

	public class ErrorLogMediator  extends Mediator implements IMediator
	{
		public static const NAME:String = "ErrorLogMediator";
		
		
		public function ErrorLogMediator( viewComponent:Object ) 
		{			
			super( NAME, viewComponent );			
			view.addEventListener( FlexEvent.CREATION_COMPLETE, showErrorLog );			
		}
		
		private function showErrorLog(event: FlexEvent): void
		{			
			view.errorLogDataGrid.dataProvider = ErrorLogger.errorArray;
			view.validateNow();
		}
		
		protected function get view():ErrorLog
		{
			return viewComponent as ErrorLog;
		}
	}
}