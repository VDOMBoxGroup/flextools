package net.vdombox.object_editor.view.mediators
{
	import flash.events.Event;

	import flash.events.MouseEvent;


	import mx.collections.ArrayCollection;
	import mx.events.CloseEvent;
	import mx.events.FlexEvent;

	import mx.managers.PopUpManager;


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

			/*	var selectFormItem:SelectFormItem  = new SelectFormItem();
			   selectFormItem.id = "ffDisplayName";
			   selectFormItem.label="====++====================================="
			   selectFormItem.x = 50;
			   selectFormItem.y = 50;
			   view.addElement(selectFormItem);


			 facade.registerMediator( new SelectFormItemMediator( selectFormItem, objectTypeVO ) );*/

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
//			objectTypeVO.container 	 	= view.fContainera.selectedIndex;			
			objectTypeVO.interfaceType 	= view.fInterfaceType.selectedIndex;
			objectTypeVO.optimizationPriority  =  view.fOptimizationPriority.value;			
		}

		private function changeDisplayName ( event: MouseEvent):void
		{		
			var langsProxy:LanguagesProxy = facade.retrieveProxy(LanguagesProxy.NAME) as LanguagesProxy;
			var popup:ChangeWord = ChangeWord(PopUpManager.createPopUp(view, ChangeWord, true));
			popup.addEventListener(FlexEvent.CREATION_COMPLETE, setListWord);
			popup.addEventListener(CloseEvent.CLOSE, closeHandler);

			function setListWord(event:FlexEvent):void
			{
				var arrCol:ArrayCollection = langsProxy.getWordsOnCarentLocal(objectTypeVO.languages);
				popup.showWordsList( arrCol );	
			}
			function closeHandler(event:CloseEvent):void
			{
				var wordCode:Object = event.target.wordCode;					
				if(wordCode == null)return;					
				view.fDisplayName.text = langsProxy.getWord(objectTypeVO.languages,wordCode["ID"]);	
				objectTypeVO.displayName = wordCode["name"];
			}		
		}	

		private function showInformation(event: FlexEvent): void
		{
			facade.registerMediator( new SelectFormItemMediator( view.ffDisplayName, objectTypeVO ) );
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
			view.fchangeDisplayName.addEventListener( MouseEvent.CLICK, changeDisplayName );

			view.label= "Information";

			view.fname.text 			= objectTypeVO.name;
			view.fClassName.text		= objectTypeVO.className;
			view.fID.text 				= objectTypeVO.id;
			view.fCategory.text			= objectTypeVO.category;
			view.fDynamic.selected		= objectTypeVO.dynamic;
			view.fMoveable.selected		= objectTypeVO.moveable;
			view.fVersion.text 			= objectTypeVO.version;

			view.fResizable.selectedIndex		= objectTypeVO.resizable;
//			view.fContainera.selectedIndex		= 2;//objectTypeVO.container;	
			view.fContainerI.selectedIndex      = 2;	
			view.fInterfaceType.selectedIndex 	= objectTypeVO.interfaceType;
			view.fOptimizationPriority.value  	= objectTypeVO.optimizationPriority;



			view.fcurrentLocation.dataProvider	= objectTypeVO.languages.locales;
			view.validateNow();
			trace("compliteInformation");			

		}		

		protected function get view():Information
		{
			return viewComponent as Information;
		}
	}
}

