package net.vdombox.object_editor.view.mediators
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.collections.ArrayCollection;
	import mx.collections.IList;
	import mx.collections.Sort;
	import mx.collections.SortField;
	import mx.events.FlexEvent;
	import mx.messaging.management.Attribute;
	
	import net.vdombox.object_editor.model.proxy.componentsProxy.LanguagesProxy;
	import net.vdombox.object_editor.model.vo.AttributeVO;
	import net.vdombox.object_editor.model.vo.ObjectTypeVO;
	import net.vdombox.object_editor.view.essence.Attributes;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;

	public class AttributeMediator extends Mediator implements IMediator
	{
		public static const NAME:String = "AttributeMediator";
		private var objectTypeVO:ObjectTypeVO;
		private var currentAttributeVO: AttributeVO;

		public function AttributeMediator( viewComponent:Object, objTypeVO:ObjectTypeVO ) 
		{			
			super( NAME+objTypeVO.id, viewComponent );
			this.objectTypeVO = objTypeVO;	
			view.addEventListener( FlexEvent.SHOW, showAttributes );
			view.addEventListener( Event.CHANGE,   validateObjectTypeVO );			
//			attributes.addEventListener( FlexEvent.HIDE, hideAttributes );
		}

		private function changeName( event:Event ):void
		{ 
			view.currentAttribute.label = event.target.text;
			
			currentAttributeVO.name = view.fname.text;
			view.attributesList.dataProvider.itemUpdated(view.currentAttribute);
//			sortAttributes();
			view.attributesList.selectedItem = view.currentAttribute;
			view.attributesList.ensureIndexIsVisible(view.attributesList.selectedIndex);
			view.attributesList.validateNow();
//			view.attributesList.selectedItems //scrollRect = view.currentItem;			
		}
		
		public function validateObjectTypeVO(event:Event):void
		{
			view.label= "Attributes*";			
			facade.sendNotification( ObjectViewMediator.OBJECT_TYPE_CHAGED, objectTypeVO);
			if( currentAttributeVO )
			{				
				currentAttributeVO.defaultValue		= view.defaultValue.text;
				currentAttributeVO.visible			= view.visibleAtr.selected;
				currentAttributeVO.interfaceType	= view.interfaceType.selectedIndex;
				currentAttributeVO.colorgroup		= view.colorgroup.selectedIndex;
				currentAttributeVO.codeInterface	= view.codeInterface.textInput.text;//selectedItem.data;
				currentAttributeVO.regularExpressionValidation = view.regExp.text;
			}
		}

		private function selectAtribute(event:Event):void
		{ 
			currentAttributeVO = view.attributesList.selectedItem.data as AttributeVO;
			fillAttributeFilds(currentAttributeVO);	
		}

		private function fillAttributeFilds(attributeVO:AttributeVO):void
		{
			view.fname.text 					= attributeVO.name;	
			view.defaultValue.text				= attributeVO.defaultValue;		
			view.visibleAtr.selected			= attributeVO.visible;	
			view.interfaceType.selectedIndex 	= attributeVO.interfaceType;
			view.colorgroup.selectedIndex 		= attributeVO.colorgroup;
			view.regExp.text					= attributeVO.regularExpressionValidation;
			view.codeInterface.textInput.text	= attributeVO.codeInterface;
			
			view.displayName.completeStructure( objectTypeVO.languages, attributeVO.displayName );
			view.help.completeStructure       ( objectTypeVO.languages, attributeVO.help );
			view.errMessage.completeStructure ( objectTypeVO.languages, attributeVO.errorValidationMessage );
		}

		private function showAttributes(event: FlexEvent): void
		{			
			view.attributesList.addEventListener       ( Event.CHANGE, selectAtribute);
			view.fname.addEventListener                ( Event.CHANGE, changeName );
			view.addAttributeButton.addEventListener   ( MouseEvent.CLICK, addAttribute );
			view.deleteAttributeButton.addEventListener( MouseEvent.CLICK, deleteAttribute );
			compliteAtributes();
			view.validateNow();
		}

		private function addAttribute(event:MouseEvent): void
		{			
			var attribVO:AttributeVO = new AttributeVO( "newAttribute"+ objectTypeVO.attributes.length );
			objectTypeVO.attributes.addItem( {label:attribVO.name, data:attribVO} );
			var langsProxy:LanguagesProxy 	= facade.retrieveProxy( LanguagesProxy.NAME ) as LanguagesProxy;
			attribVO.displayName            = langsProxy.getNextId(objectTypeVO.languages, "1", attribVO.name+" displayName");
			attribVO.errorValidationMessage = langsProxy.getNextId(objectTypeVO.languages, "2", attribVO.name+" errValMess");
			attribVO.help                   = langsProxy.getNextId(objectTypeVO.languages, "3", attribVO.name+" help");
			fillAttributeFilds(attribVO);
			view.currentAttribute = getCurrentAttribute(attribVO.name);
			currentAttributeVO    = view.currentAttribute.data;
			view.attributesList.selectedItem = view.currentAttribute;
			view.attributesList.validateNow();
//			view.attributesList.scrollToIndex(view.languagesDataGrid.selectedIndex);
		}
		
		private function getCurrentAttribute(nameAttib:String):Object
		{			
			for each(var attr:Object in objectTypeVO.attributes )
			{
				if( attr["label"] == nameAttib )
				{
					return attr;
					break;
				}
			}
			return new Object();
		}

		private function deleteAttribute(event:MouseEvent): void
		{
			var selectInd:uint = view.attributesList.selectedIndex;
			objectTypeVO.attributes.removeItemAt(selectInd);
			languagesProxy.deleteWord(objectTypeVO, currentAttributeVO.help);
			languagesProxy.deleteWord(objectTypeVO, currentAttributeVO.displayName);
			languagesProxy.deleteWord(objectTypeVO, currentAttributeVO.errorValidationMessage);
			setCurrentAttribute(selectInd - 1);
		}
		
		private function setCurrentAttribute(listIndex:int = 0):void
		{
			if ( listIndex < 0 )
			{
				listIndex = 0;
			}
			if( objectTypeVO.attributes.length > 0 )
			{				
				currentAttributeVO = objectTypeVO.attributes[listIndex].data;
				view.attributesList.selectedIndex = listIndex;
				view.currentAttribute = view.attributesList.dataProvider[listIndex];
				fillAttributeFilds( currentAttributeVO );
			}			
			else
			{
				view.clearAttributeFields();
				view.currentAttribute = null;
				currentAttributeVO	  = null;
			}
		}

		private  function hideAttributes(event: FlexEvent):void
		{
			view.attributesList.removeEventListener(Event.CHANGE, selectAtribute);
		}

		private function sortAttributes():void 
		{
			objectTypeVO.attributes.sort = new Sort();
			objectTypeVO.attributes.sort.fields = [ new SortField( 'label' ) ];
			objectTypeVO.attributes.refresh();
		}
		
		protected function compliteAtributes( ):void
		{	
//			sortAttributes();
			view.attributesList.dataProvider = objectTypeVO.attributes;
			setCurrentAttribute();
		}		
		override public function listNotificationInterests():Array 
		{			
			return [ ObjectViewMediator.OBJECT_TYPE_VIEW_SAVED, ApplicationFacade.CHANGE_CURRENT_LANGUAGE ];
		}

		override public function handleNotification( note:INotification ):void 
		{
			switch ( note.getName() ) 
			{				
				case ObjectViewMediator.OBJECT_TYPE_VIEW_SAVED:
					if (objectTypeVO == note.getBody() )
						view.label= "Attributes";
					break;
				case ApplicationFacade.CHANGE_CURRENT_LANGUAGE:
					if (view.attributesList)
						changeFildWithCurrentLanguage( );
					break;
			}
		}
		
		private function changeFildWithCurrentLanguage( ):void
		{
			view.displayName.currentLanguage = objectTypeVO.languages.currentLocation;
			view.displayName.apdateFild();
			
			view.errMessage.currentLanguage = objectTypeVO.languages.currentLocation;
			view.errMessage.apdateFild();
			
			view.help.currentLanguage = objectTypeVO.languages.currentLocation;
			view.help.apdateFild();			
		}

		protected function get view():Attributes
		{
			return viewComponent as Attributes;
		}
		
		private function get languagesProxy():LanguagesProxy
		{
			return facade.retrieveProxy(LanguagesProxy.NAME) as LanguagesProxy;
		}
	}
}

