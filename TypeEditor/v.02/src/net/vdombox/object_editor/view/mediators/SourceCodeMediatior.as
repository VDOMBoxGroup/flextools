package net.vdombox.object_editor.view.mediators
{
	import mx.events.FlexEvent;
	
	import net.vdombox.object_editor.model.proxy.componentsProxy.ObjectTypeProxy;
	import net.vdombox.object_editor.model.proxy.componentsProxy.SourceCodeProxy;
	import net.vdombox.object_editor.model.vo.ObjectTypeVO;
	import net.vdombox.object_editor.view.essence.SourceCode;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	public class SourceCodeMediatior extends Mediator implements IMediator
	{
		public static const NAME:String = "SourceCodeMediatior";
		private var objectTypeVO:ObjectTypeVO;
		
		public function SourceCodeMediatior( viewComponent:Object, objTypeVO:ObjectTypeVO ) 
		{			
			super( NAME+objTypeVO.id, viewComponent );
			this.objectTypeVO = objTypeVO;	
			sourceCode.addEventListener( FlexEvent.SHOW, showSourceCode );
		}
		
		private function showSourceCode(event: FlexEvent): void
		{			
			compliteSourceCode();
			sourceCode.validateNow();
		}
	
		protected function compliteSourceCode( ):void
		{			
			sourceCode.sourceCode.text = objectTypeVO.sourceCode;
			trace("compliteSourceCode");
		}		
		
		protected function get sourceCode():SourceCode
		{
			return viewComponent as SourceCode;
		}
	}
}