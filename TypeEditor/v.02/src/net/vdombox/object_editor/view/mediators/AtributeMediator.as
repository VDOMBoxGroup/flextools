package net.vdombox.object_editor.view.mediators
{
	import mx.events.FlexEvent;
	
	import net.vdombox.object_editor.model.proxy.componentsProxy.ObjectTypeProxy;
	import net.vdombox.object_editor.model.proxy.componentsProxy.SourceCodeProxy;
	import net.vdombox.object_editor.model.vo.ObjectTypeVO;
	import net.vdombox.object_editor.view.essence.Atributes;
	import net.vdombox.object_editor.view.essence.SourceCode;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	public class AtributeMediatior extends Mediator implements IMediator
	{
		public static const NAME:String = "AtributeMediatior";
		private var objectTypeVO:ObjectTypeVO;
		
		public function AtributeMediatior( viewComponent:Object, objTypeVO:ObjectTypeVO ) 
		{			
			super( NAME+objTypeVO.id, viewComponent );
			this.objectTypeVO = objTypeVO;	
//			sourceCode.addEventListener( FlexEvent.CONTENT_CREATION_COMPLETE, showAtribute );
		}
		
		private function showAtribute(event: FlexEvent): void
		{
			compliteSourceCode();
		}
	
		protected function compliteAtribute( ):void
		{			
//			atributes.
			trace("compliteAtribute");
		}		
		
		protected function get atributes():Atributes
		{
			return viewComponent as Atributes;
		}
	}
}