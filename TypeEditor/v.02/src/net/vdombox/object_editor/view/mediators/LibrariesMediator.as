package net.vdombox.object_editor.view.mediators
{
	import mx.events.FlexEvent;
	
	import net.vdombox.object_editor.model.proxy.componentsProxy.ObjectTypeProxy;
	import net.vdombox.object_editor.model.vo.ObjectTypeVO;
	import net.vdombox.object_editor.view.essence.Libraries;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	public class LibrariesMediator extends Mediator implements IMediator
	{
		public static const NAME:String = "LibrariesMediator";
		private var objectTypeVO:ObjectTypeVO;
		
		public function LibrariesMediator( viewComponent:Object, objTypeVO:ObjectTypeVO ) 
		{			
			super( NAME+objTypeVO.id, viewComponent );
			this.objectTypeVO = objTypeVO;	
			view.addEventListener( FlexEvent.SHOW, showLibraries );
		}
		
		private function showLibraries(event: FlexEvent): void
		{			
			compliteLibraries();
			view.validateNow();
		}
		
		protected function compliteLibraries( ):void
		{			
			//			atributes.sourceCode.text = objectTypeVO.atribute;			
			trace("compliteLanguages");
		}		
		
		protected function get view():Libraries
		{
			return viewComponent as Libraries;
		}
	}
}