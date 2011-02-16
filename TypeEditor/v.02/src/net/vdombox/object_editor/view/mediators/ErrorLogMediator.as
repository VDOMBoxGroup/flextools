package net.vdombox.object_editor.view.mediators
{
	import mx.events.FlexEvent;
	
	import net.vdombox.object_editor.model.vo.ObjectTypeVO;
	import net.vdombox.object_editor.view.essence.ErrorLog;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.patterns.mediator.Mediator;

	public class ErrorLogMediator  extends Mediator implements IMediator
	{
		public static const NAME:String = "ErrorLogMediator";
		
		private var objectTypeVO:ObjectTypeVO;
		
		
		public function ErrorLogMediator( viewComponent:Object, objTypeVO:ObjectTypeVO ) 
		{			
			super( NAME+objTypeVO.id, viewComponent );
			this.objectTypeVO = objTypeVO;	
			view.addEventListener( FlexEvent.SHOW, showErrorLog );			
		}
		
		private function showErrorLog(event: FlexEvent): void
		{			
			view.errorLogDataGrid.dataProvider = objectTypeVO.languages.words;
			view.validateNow();
		}
		
		protected function get view():ErrorLog
		{
			return viewComponent as ErrorLog;
		}
	}
}