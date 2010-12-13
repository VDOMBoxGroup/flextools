package net.vdombox.object_editor.view.mediators
{
	import mx.events.FlexEvent;
	
	import net.vdombox.object_editor.model.proxy.componentsProxy.ObjectTypeProxy;
	import net.vdombox.object_editor.model.vo.ObjectTypeVO;
	import net.vdombox.object_editor.view.essence.Atributes;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	public class AtributeMediator extends Mediator implements IMediator
	{
		public static const NAME:String = "AtributeMediator";
		private var objectTypeVO:ObjectTypeVO;
		
		public function AtributeMediator( viewComponent:Object, objTypeVO:ObjectTypeVO ) 
		{			
			super( NAME+objTypeVO.id, viewComponent );
			this.objectTypeVO = objTypeVO;	
			atributes.addEventListener( FlexEvent.SHOW, showAtributes );
		}
		
		private function showAtributes(event: FlexEvent): void
		{			
			compliteAtributes();
			atributes.validateNow();
		}
		
		protected function compliteAtributes( ):void
		{			
//			atributes.sourceCode.text = objectTypeVO.atribute;
			trace("compliteAtributes");
		}		
		
		protected function get atributes():Atributes
		{
			return viewComponent as Atributes;
		}
	}
}