package net.vdombox.object_editor.view.mediators
{
	import net.vdombox.object_editor.model.proxy.componentsProxy.ObjectTypeProxy;
	import net.vdombox.object_editor.model.vo.ObjectTypeVO;
	import net.vdombox.object_editor.view.ObjectView;
	import net.vdombox.object_editor.view.essence.Information;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;

	public class ObjectViewMediator extends Mediator implements IMediator
	{
		public static const NAME:String = "ObjectViewMediator";
		private var objectTypeVO:ObjectTypeVO;
			
		public function ObjectViewMediator( viewComponent:Object, objTypeVO:ObjectTypeVO ) 
		{	
			super( NAME+objTypeVO.id, viewComponent );		
			this.objectTypeVO = objTypeVO;			
			var information:Information  = new Information();
			objectView.tabNavigator.addChild(information);
			
			
			objectTypeProxy = ObjectTypeProxy( facade.retrieveProxy( ObjectTypeProxy.NAME ) );
			facade.registerMediator( new InformationMediatior( information, objTypeVO ) );
		}
		
		protected function compliteObject( objTypeVO: ObjectTypeVO ):void
		{
//TODO: registerMediator and retrieveMediator with GUID			
			var infMediator:InformationMediatior = InformationMediatior( facade.retrieveMediator( InformationMediatior.NAME ) );
//			infMediator.
		}
		
//		override public function listNotificationInterests():Array 
//		{			
////			return [ ApplicationFacade.OBJECT_COMPLIT ];
//		}
		
//		override public function handleNotification( note:INotification ):void 
//		{
//			switch ( note.getName() ) 
//			{				
//				case ApplicationFacade.OBJECT_COMPLIT:
//					trace("ObjectViewMediator");
//					compliteObject(note.getBody() as ObjectView);
//					break;				
//			}
//		}
		
		protected function get objectView():ObjectView
		{
			return viewComponent as ObjectView;
		}
		
		private var objectTypeProxy:ObjectTypeProxy;
	}
}