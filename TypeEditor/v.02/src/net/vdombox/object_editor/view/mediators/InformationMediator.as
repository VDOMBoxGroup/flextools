package net.vdombox.object_editor.view.mediators
{
	import flash.events.Event;

	import mx.collections.ArrayCollection;
	import mx.events.FlexEvent;

	import net.vdombox.object_editor.model.proxy.componentsProxy.ObjectTypeProxy;
	import net.vdombox.object_editor.model.vo.ObjectTypeVO;
	import net.vdombox.object_editor.view.ObjectView;
	import net.vdombox.object_editor.view.essence.Information;

	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;

	public class InformationMediator extends Mediator implements IMediator
	{
		public static const NAME:String = "InformationMediator";
		private var objectTypeVO:ObjectTypeVO;

		public function InformationMediator( viewComponent:Object, objTypeVO:ObjectTypeVO ) 
		{			
			super( NAME+objTypeVO.id, viewComponent );
			this.objectTypeVO = objTypeVO;	
			information.addEventListener( FlexEvent.CREATION_COMPLETE, showInformation );
			information.addEventListener( Event.CHANGE, validateObjectTypeVO );
			trace("InformationMediator: " + objTypeVO.id);
//			information.addEventListener( FlexEvent.SHOW, showInformation );
		}

		public function validateObjectTypeVO(event:Event):void
		{
			information.label= "Information*";
			facade.sendNotification( ObjectViewMediator.OBJECT_TYPE_CHAGED, objectTypeVO);
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
					trace("InformationMediatior - ");
					compliteInformation();
					break;				
			}
		}

		protected function compliteInformation( ):void
		{	
			information.label= "Information";

//			var objTypeProxy:ObjectTypeProxy = facade.retrieveProxy(ObjectTypeProxy.NAME) as ObjectTypeProxy;
//			var objType: ObjectTypeVO = objTypeProxy.getObjectTypeVO( inf.ID );

			information.fname.text 			= objectTypeVO.name;
			information.fClassName.text		= objectTypeVO.className;
			information.fID.text 			= objectTypeVO.id;
			information.fCategory.text		= objectTypeVO.category;
			information.fDynamic.selected	=  objectTypeVO.dynamic;
			information.fMoveable.selected	=  objectTypeVO.moveable;
			information.fVersion.text 		= objectTypeVO.version;

			information.fResizable.selectedIndex 	 = objectTypeVO.resizable;
			information.fContainer.selectedIndex 	 = objectTypeVO.container;			
			information.fInterfaceType.selectedIndex = objectTypeVO.interfaceType;
			information.fOptimizationPriority.value  = objectTypeVO.optimizationPriority;
			trace("compliteInformation");
		}		

		protected function get information():Information
		{
			return viewComponent as Information;
		}
	}
}

