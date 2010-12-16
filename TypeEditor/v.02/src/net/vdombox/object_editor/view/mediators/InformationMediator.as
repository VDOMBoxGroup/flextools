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
			view.addEventListener( FlexEvent.CREATION_COMPLETE, showInformation );
			view.addEventListener( Event.CHANGE, validateObjectTypeVO );
			trace("InformationMediator: " + objTypeVO.id);
		}

		public function validateObjectTypeVO(event:Event):void
		{
			view.label= "Information*";
			trace("CHANGECHANGE");
			facade.sendNotification( ObjectViewMediator.OBJECT_TYPE_CHAGED, objectTypeVO);
		
//			objectTypeVO.name 			= view.fname.text;
			objectTypeVO.className		= view.fClassName.text;
			objectTypeVO.id				= view.fID.text ;
			objectTypeVO.category		= view.fCategory.text;
			objectTypeVO.dynamic		= view.fDynamic.selected;
			objectTypeVO.moveable		= view.fMoveable.selected;
			objectTypeVO.version 		= view.fVersion.text;
			
			objectTypeVO.resizable	 	= view.fResizable.selectedIndex ;
			objectTypeVO.container 	 	= view.fContainer.selectedIndex;			
			objectTypeVO.interfaceType 	= view.fInterfaceType.selectedIndex;
			objectTypeVO.optimizationPriority  =  view.fOptimizationPriority.value;			
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
			view.label= "Information";

			view.fname.text 			= objectTypeVO.name;
			view.fClassName.text		= objectTypeVO.className;
			view.fID.text 				= objectTypeVO.id;
			view.fCategory.text			= objectTypeVO.category;
			view.fDynamic.selected		= objectTypeVO.dynamic;
			view.fMoveable.selected		= objectTypeVO.moveable;
			view.fVersion.text 			= objectTypeVO.version;

			view.fResizable.selectedIndex		= objectTypeVO.resizable;
			view.fContainer.selectedIndex		= objectTypeVO.container;			
			view.fInterfaceType.selectedIndex 	= objectTypeVO.interfaceType;
			view.fOptimizationPriority.value  	= objectTypeVO.optimizationPriority;
			view.currentLocation				= objectTypeVO.languages.locales;
			trace("compliteInformation");
		}		

		protected function get view():Information
		{
			return viewComponent as Information;
		}
	}
}

