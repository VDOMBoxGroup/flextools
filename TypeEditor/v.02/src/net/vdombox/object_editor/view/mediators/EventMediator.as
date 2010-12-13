package net.vdombox.object_editor.view.mediators
{
	import mx.events.FlexEvent;
	
	import net.vdombox.object_editor.model.proxy.componentsProxy.ObjectTypeProxy;
	import net.vdombox.object_editor.model.vo.ObjectTypeVO;
	import net.vdombox.object_editor.view.essence.Events;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	public class EventMediator extends Mediator implements IMediator
	{
		public static const NAME:String = "EventMediator";
		private var objectTypeVO:ObjectTypeVO;
		
		public function EventMediator( viewComponent:Object, objTypeVO:ObjectTypeVO ) 
		{			
			super( NAME+objTypeVO.id, viewComponent );
			this.objectTypeVO = objTypeVO;	
			events.addEventListener( FlexEvent.SHOW, showEvent );
		}
		
		private function showEvent(event: FlexEvent): void
		{			
			compliteEvents();
			events.validateNow();
		}
		
		protected function compliteEvents( ):void
		{			
//			atributes.sourceCode.text = objectTypeVO.atribute;S			
			trace("compliteEvents");
		}		
		
		protected function get events():Events
		{
			return viewComponent as Events;
		}
	}
}