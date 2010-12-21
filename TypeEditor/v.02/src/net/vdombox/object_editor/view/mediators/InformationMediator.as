package net.vdombox.object_editor.view.mediators
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.collections.ArrayCollection;
	import mx.events.CloseEvent;
	import mx.events.FlexEvent;
	import mx.managers.PopUpManager;
	import mx.messaging.channels.StreamingAMFChannel;
	
	import net.vdombox.object_editor.model.proxy.componentsProxy.LanguagesProxy;
	import net.vdombox.object_editor.model.proxy.componentsProxy.ObjectTypeProxy;
	import net.vdombox.object_editor.model.vo.ObjectTypeVO;
	import net.vdombox.object_editor.view.ObjectView;
	import net.vdombox.object_editor.view.essence.Information;
	import net.vdombox.object_editor.view.essence.SelectFormItem;
	import net.vdombox.object_editor.view.popups.ChangeWord;
	
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
//			view.addEventListener( ApplicationFacade.CHANGE_SELECT_FORM_ITEM, changeSelectFormItem );

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
			objectTypeVO.container 	 	= view.fContainerI.selectedIndex;			
			objectTypeVO.interfaceType 	= view.fInterfaceType.selectedIndex;
			objectTypeVO.optimizationPriority  =  view.fOptimizationPriority.value;			
		}
		
		private function showInformation( event:FlexEvent): void
		{			
			compliteInformation();
		}

		public function changeCurrentLocation(event: Event): void
		{
			objectTypeVO.languages.currentLocation = view.fcurrentLocation.selectedLabel;		
		}

		protected function compliteInformation():void
		{			
			//правильно?
//			view.removeEventListener( FlexEvent.CREATION_COMPLETE, showInformation );
			view.fcurrentLocation.addEventListener  ( Event.CHANGE, changeCurrentLocation );
			var langsProxy:LanguagesProxy = facade.retrieveProxy(LanguagesProxy.NAME) as LanguagesProxy;
			
			view.label= "Information";
		
			view.fname.text 			= objectTypeVO.name;
			view.fClassName.text		= objectTypeVO.className;
			view.fID.text 				= objectTypeVO.id;
			view.fCategory.text			= objectTypeVO.category;
			view.fDynamic.selected		= objectTypeVO.dynamic;
//			не правильно,00
//			view.fDisplayName.fselectComboBox.textInput.text = langsProxy.getRegExpWord(objectTypeVO.languages, objectTypeVO.displayName);
//			view.fDescription.fselectComboBox.textInput.text = langsProxy.getRegExpWord(objectTypeVO.languages, objectTypeVO.description);
			view.fMoveable.selected		= objectTypeVO.moveable;
			view.fVersion.text 			= objectTypeVO.version;

			view.fResizable.selectedIndex		= objectTypeVO.resizable;
			view.fContainerI.selectedIndex      = objectTypeVO.container;	
//			view.fContainers.fselectComboBox.textInput.text = langsProxy.getRegExpWord(objectTypeVO.languages, objectTypeVO.containers);
			view.fInterfaceType.selectedIndex 	= objectTypeVO.interfaceType;
			view.fOptimizationPriority.value  	= objectTypeVO.optimizationPriority;

			view.fcurrentLocation.dataProvider	= objectTypeVO.languages.locales;
			view.validateNow();
			trace("compliteInformation");			

		}
		
		override public function listNotificationInterests():Array 
		{			
			return [ ApplicationFacade.CHANGE_SELECT_FORM_ITEM ];
		}
		
		override public function handleNotification( note:INotification ):void 
		{
			switch ( note.getName() ) 
			{				
				case ApplicationFacade.CHANGE_SELECT_FORM_ITEM:
					var word:Object= note.getBody() as Object;
					var selectData:String = word["data"]
					var fildVO:String 	  = word["fildVO"];
					
					switch ( fildVO ) 
					{						
						case "displayName":
							objectTypeVO.displayName = selectData;
							break;
						case "description":
							objectTypeVO.description = selectData;
							break;
						case "containers":
							objectTypeVO.containers = selectData;
							break;							
					}
					break;						
			}
		}

		protected function get view():Information
		{
			return viewComponent as Information;
		}
	}
}

