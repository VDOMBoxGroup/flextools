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
		private var attributeVO: AttributeVO;

		public function AttributeMediator( viewComponent:Object, objTypeVO:ObjectTypeVO ) 
		{			
			super( NAME+objTypeVO.id, viewComponent );
			this.objectTypeVO = objTypeVO;	
			view.addEventListener( FlexEvent.SHOW, showAttributes );
			view.addEventListener( Event.CHANGE, validateObjectTypeVO );			
//			attributes.addEventListener( FlexEvent.HIDE, hideAttributes );
		}

		private function changeName( event:Event ):void
		{ 
			view.currentItem.label = event.target.text;
			
			attributeVO.name = view.fname.text;
			view.attributesList.dataProvider.itemUpdated(view.currentItem);
			sortAttributes();
			view.attributesList.selectedItem = view.currentItem;
			view.attributesList.ensureIndexIsVisible(view.attributesList.selectedIndex);//(view.attributesList.selectedIndex);
//			view.attributesList.selectedItems //scrollRect = view.currentItem;			
		}
		
		public function validateObjectTypeVO(event:Event):void
		{
			view.label= "Attributes*";			
			facade.sendNotification( ObjectViewMediator.OBJECT_TYPE_CHAGED, objectTypeVO);
			if( attributeVO )
			{				
				attributeVO.defaultValue	= view.defaultValue.text;
				attributeVO.visible			= view.visibleAtr.selected;
				attributeVO.interfaceType	= view.interfaceType.selectedIndex;
				attributeVO.colorgroup		= view.colorgroup.selectedIndex;
				attributeVO.codeInterface	= view.codeInterface.selectedItem.data;
				attributeVO.regularExpressionValidation = view.regExp.text;
			}
		}

		private function selectAtribute(event:Event):void
		{ 
			attributeVO = view.attributesList.selectedItem.data as AttributeVO;
			fillFilds(attributeVO);	
		}

		private function fillFilds(attributeVO:AttributeVO):void
		{
			view.fname.text 					= attributeVO.name;	
			view.defaultValue.text				= attributeVO.defaultValue;		
			view.visibleAtr.selected			= attributeVO.visible;	
			view.interfaceType.selectedIndex 	= attributeVO.interfaceType;
			view.colorgroup.selectedIndex 		= attributeVO.colorgroup;
			view.regExp.text					= attributeVO.regularExpressionValidation;
			view.codeInterface.selectedItem		= attributeVO.codeInterface;
			
			var langsProxy:LanguagesProxy = facade.retrieveProxy( LanguagesProxy.NAME ) as LanguagesProxy;
			view.DisplayName.completeStructure( objectTypeVO.languages, attributeVO.displayName );
			view.helpAtr.completeStructure    ( objectTypeVO.languages, attributeVO.help );
			view.fErrMessage.completeStructure( objectTypeVO.languages, attributeVO.errorValidationMessage );
		/*view.codeInterface.text 	= attributeVO.codeInterface;
		   view.regExp.text 			= attributeVO.regularExpressionValidation;
		 */	
		}

		private function showAttributes(event: FlexEvent): void
		{			
			view.attributesList.addEventListener(Event.CHANGE, selectAtribute);
//			view.attributesList.
			view.fname.addEventListener( Event.CHANGE, changeName );
			view.addAttributeButton.addEventListener   ( MouseEvent.CLICK, addAttribute );
			view.deleteAttributeButton.addEventListener( MouseEvent.CLICK, deleteAttribute );
			compliteAtributes();
			view.validateNow();
		}

		private function addAttribute(event:MouseEvent): void
		{			
			var attribVO:AttributeVO = new AttributeVO( "newAttribute"+ Math.round(Math.random()*100) );
			objectTypeVO.attributes.addItem( {label:attribVO.name, data:attribVO} );
			var langsProxy:LanguagesProxy = facade.retrieveProxy( LanguagesProxy.NAME ) as LanguagesProxy;
			attribVO.displayName = langsProxy.getNextId(objectTypeVO.languages, "1");
			attribVO.errorValidationMessage = langsProxy.getNextId(objectTypeVO.languages, "2");
			attribVO.help = langsProxy.getNextId(objectTypeVO.languages, "3");
			fillFilds(attribVO);
			view.currentItem = getCurrentItem(attribVO.name);
			view.attributesList.selectedItem = view.currentItem;
			view.attributesList.validateNow();
//			view.attributesList.scrollToIndex(view.languagesDataGrid.selectedIndex);
		}
		
		private function getCurrentItem(nameAttib:String):Object
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
			sortAttributes();
			view.attributesList.dataProvider = objectTypeVO.attributes;
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
						view.label= "Attributes";
					break;	
			}
		}

		protected function get view():Attributes
		{
			return viewComponent as Attributes;
		}
	}
}

