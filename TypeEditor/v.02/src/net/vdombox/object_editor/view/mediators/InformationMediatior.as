package net.vdombox.object_editor.view.mediators
{
	import net.vdombox.object_editor.model.proxy.componentsProxy.ObjectTypeProxy;
	import net.vdombox.object_editor.model.vo.ObjectTypeVO;
	import net.vdombox.object_editor.view.essence.Information;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	public class InformationMediatior extends Mediator implements IMediator
	{
		public static const NAME:String = "InformationMediatior";
		
		public function InformationMediatior( viewComponent:Object ) 
		{			
			super( NAME, viewComponent );			
		}
				
		override public function listNotificationInterests():Array 
		{			
			return [ ApplicationMediator.LOAD_INFORMATION ];
		}

		override public function handleNotification( note:INotification ):void 
		{
			switch ( note.getName() ) 
			{				
				case ApplicationMediator.LOAD_INFORMATION:
					trace("InformationMediatior");
					compliteInformation(note.getBody() as XML);
					break;				
			}
		}
		
		protected function compliteInformation( inf:XML):void
		{	
			var objTypeProxy:ObjectTypeProxy = facade.retrieveProxy(ObjectTypeProxy.NAME) as ObjectTypeProxy;
			var objType: ObjectTypeVO = objTypeProxy.getObjectTypeVO( inf.ID );
		
			information.fname.text 		= inf.Name;
			information.fClassName.text = inf.ClassName;
			information.fID.text 		= inf.ID;
			information.fCategory.text	= inf.Category;
		}		
		
		protected function get information():Information
		{
			return viewComponent as Information;
		}
	}
}