package net.vdombox.object_editor.view.mediators
{
	import mx.events.FlexEvent;
	
	import net.vdombox.object_editor.model.proxy.componentsProxy.ObjectTypeProxy;
	import net.vdombox.object_editor.model.vo.ObjectTypeVO;
	import net.vdombox.object_editor.view.essence.Resourses;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	public class ResoursesMediator extends Mediator implements IMediator
	{
		public static const NAME:String = "ResoursesMediator";
		private var objectTypeVO:ObjectTypeVO;
		
		public function ResoursesMediator( viewComponent:Object, objTypeVO:ObjectTypeVO ) 
		{			
			super( NAME+objTypeVO.id, viewComponent );
			this.objectTypeVO = objTypeVO;	
			resourses.addEventListener( FlexEvent.SHOW, showResourses );
		}
		
		private function showResourses(event: FlexEvent): void
		{			
			compliteLibraries();
			resourses.validateNow();
		}
		
		protected function compliteLibraries( ):void
		{			
			//			atributes.sourceCode.text = objectTypeVO.atribute;			
			trace("compliteLanguages");
		}		
		
		protected function get resourses():Resourses
		{
			return viewComponent as Resourses;
		}
	}
}