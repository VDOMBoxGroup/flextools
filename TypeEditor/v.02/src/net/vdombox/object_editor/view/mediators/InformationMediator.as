package net.vdombox.object_editor.view.mediators
{
	import flash.events.Event;
	import flash.events.MouseEvent;

	import mx.collections.ArrayCollection;
	import mx.events.CloseEvent;
	import mx.events.FlexEvent;

	import net.vdombox.object_editor.model.proxy.componentsProxy.LanguagesProxy;
	import net.vdombox.object_editor.model.proxy.componentsProxy.ObjectTypeProxy;
	import net.vdombox.object_editor.model.proxy.componentsProxy.ResourcesProxy;
	import net.vdombox.object_editor.model.vo.ObjectTypeVO;
	import net.vdombox.object_editor.view.ObjectView;
	import net.vdombox.object_editor.view.essence.Information;
	import net.vdombox.object_editor.view.essence.SelectFormItem;

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
		}

		public function validateObjectTypeVO(event:Event):void
		{
			view.label= "Information*";
//			trace("CHANGECHANGE");
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

		private function showInformation( event:FlexEvent ): void
		{			
			compliteInformation();
		}

		public function changeCurrentLocation( event: Event ): void
		{
			objectTypeVO.languages.currentLocation = view.fcurrentLocation.selectedLabel;
			view.fDisplayName.curentLanguage = objectTypeVO.languages.currentLocation;
			view.fDisplayName.apdateFild();	
			view.fDescription.curentLanguage = objectTypeVO.languages.currentLocation;
			view.fDescription.apdateFild();
		}

		protected function compliteInformation():void
		{			
			view.label= "Information";

			view.fname.text 			= objectTypeVO.name;
			view.fClassName.text		= objectTypeVO.className;
			view.fID.text 				= objectTypeVO.id;
			view.fCategory.text			= objectTypeVO.category;
			view.fDynamic.selected		= objectTypeVO.dynamic;			
			view.fMoveable.selected		= objectTypeVO.moveable;
			view.fVersion.text 			= objectTypeVO.version;

			view.fDisplayName.completeStructure( objectTypeVO.languages, objectTypeVO.displayName );
			view.fDescription.completeStructure( objectTypeVO.languages, objectTypeVO.description );

			view.fResizable.selectedIndex		= objectTypeVO.resizable;
			view.fContainerI.selectedIndex      = objectTypeVO.container;	
//			view.fContainers.fselectComboBox.textInput.text = langsProxy.getRegExpWord(objectTypeVO.languages, objectTypeVO.containers);
			view.fInterfaceType.selectedIndex 	= objectTypeVO.interfaceType;
			view.fOptimizationPriority.value  	= objectTypeVO.optimizationPriority;
			view.fcurrentLocation.dataProvider	= objectTypeVO.languages.locales;

			view.ficon.source = resourcesProxy.getByteArray(objectTypeVO.icon);
			view.ficon2.source = resourcesProxy.getByteArray(objectTypeVO.structureIcon);
			view.ficon3.source = resourcesProxy.getByteArray(objectTypeVO.editorIcon);

			view.fcurrentLocation.addEventListener(Event.CHANGE, changeCurrentLocation);
			view.validateNow();
		}
		override public function listNotificationInterests():Array 
		{			
			return [ ObjectViewMediator.OBJECT_TYPE_VIEW_SAVED ];
		}

		override public function handleNotification( note:INotification ):void 
		{
			switch ( note.getName() ) 
			{				
				case ObjectViewMediator.OBJECT_TYPE_VIEW_SAVED:
					if (objectTypeVO == note.getBody() )
						view.label= "Information";
					break;	
			}
		}


		protected function get view():Information
		{
			return viewComponent as Information;
		}

		protected function get resourcesProxy():ResourcesProxy
		{
			return facade.retrieveProxy(ResourcesProxy.NAME) as ResourcesProxy;
		}
	}
}

