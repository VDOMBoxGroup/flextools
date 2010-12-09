package net.vdombox.object_editor.view.mediators
{
	import mx.events.FlexEvent;
	
	import net.vdombox.object_editor.model.proxy.componentsProxy.ObjectTypeProxy;
	import net.vdombox.object_editor.model.vo.ObjectTypeVO;
	import net.vdombox.object_editor.view.essence.Information;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	public class InformationMediatior extends Mediator implements IMediator
	{
		public static const NAME:String = "InformationMediatior";
		private var objectTypeVO:ObjectTypeVO;
		
		public function InformationMediatior( viewComponent:Object, objTypeVO:ObjectTypeVO ) 
		{			
			super( NAME+objTypeVO.id, viewComponent );
			this.objectTypeVO = objTypeVO;	
			information.addEventListener( FlexEvent.CREATION_COMPLETE, showInformation );
//			information.addEventListener( FlexEvent.SHOW, showInformation );
		}
		
		private function showInformation(event: FlexEvent): void
		{
			compliteInformation();
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
					compliteInformation();
					break;				
			}
		}
		
		protected function compliteInformation( ):void
		{	
//			var objTypeProxy:ObjectTypeProxy = facade.retrieveProxy(ObjectTypeProxy.NAME) as ObjectTypeProxy;
//			var objType: ObjectTypeVO = objTypeProxy.getObjectTypeVO( inf.ID );
			
//TODO запускается каждый раз как переходим на вкладку!!!!!!!!
			
			information.fname.text 			= objectTypeVO.name;
			information.fClassName.text		= objectTypeVO.className;
			information.fID.text 			= objectTypeVO.id;
			information.fCategory.text		= objectTypeVO.category;
			information.fDynamic.selected	=  objectTypeVO.dynamic;
			trace("compliteInformation");
			
		}		
		
		protected function get information():Information
		{
			return viewComponent as Information;
		}
	}
}