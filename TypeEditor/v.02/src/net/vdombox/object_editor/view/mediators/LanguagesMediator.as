package net.vdombox.object_editor.view.mediators
{
	import mx.events.FlexEvent;
	
	import net.vdombox.object_editor.model.proxy.componentsProxy.ObjectTypeProxy;
	import net.vdombox.object_editor.model.vo.ObjectTypeVO;	
	import net.vdombox.object_editor.view.essence.Languages;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	public class LanguagesMediator extends Mediator implements IMediator
	{
		public static const NAME:String = "LanguagesMediator";
		private var objectTypeVO:ObjectTypeVO;
		
		public function LanguagesMediator( viewComponent:Object, objTypeVO:ObjectTypeVO ) 
		{			
			super( NAME+objTypeVO.id, viewComponent );
			this.objectTypeVO = objTypeVO;	
			view.addEventListener( FlexEvent.SHOW, showLanguages );
		}
		
		private function showLanguages(event: FlexEvent): void
		{			
			compliteLanguages();
			view.validateNow();
		}
		
		protected function compliteLanguages( ):void
		{			
			//			atributes.sourceCode.text = objectTypeVO.atribute;			
			trace("compliteLanguages");
		}		
		
		protected function get view():Languages
		{
			return viewComponent as Languages;
		}
	}
}