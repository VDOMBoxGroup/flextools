package net.vdombox.object_editor.view.mediators
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.events.FlexEvent;
	import mx.messaging.management.Attribute;
	
	import net.vdombox.object_editor.model.proxy.componentsProxy.ObjectTypeProxy;
	import net.vdombox.object_editor.model.vo.AttributeVO;
	import net.vdombox.object_editor.model.vo.ObjectTypeVO;
	import net.vdombox.object_editor.view.essence.Attributes;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	import spark.events.IndexChangeEvent;

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
		
		public function validateObjectTypeVO(event:Event):void
		{
			view.label= "Attributes*";			
			facade.sendNotification( ObjectViewMediator.OBJECT_TYPE_CHAGED, objectTypeVO);
			if( attributeVO )
			{
				if(event.target.fname.text != view.attributesList.selectedItem.label)
				{
					
					view.attributesList.selectedItem.label = event.target.fname.text;
					attributeVO.name = view.fname.text;
					
					view.validateNow();
					view.saveChanges();
				}
				else
				{				
					attributeVO.defaultValue	= view.defaultValue.text;
					attributeVO.visible			= view.visibleAtr.selected;
					attributeVO.interfaceType	= view.interfaceType.selectedIndex;
					attributeVO.colorgroup		= view.colorgroup.selectedIndex;
				}
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
			view.addAttributeButton.addEventListener   ( MouseEvent.CLICK, addAttribute );
			view.deleteAttributeButton.addEventListener( MouseEvent.CLICK, deleteAttribute );
			compliteAtributes();
			view.validateNow();
		}
		
		private function addAttribute(event:MouseEvent): void
		{			
			var attribVO:AttributeVO = new AttributeVO( "newAttribute" );
			objectTypeVO.attributes.addItem( {label:"newAttribute", data:attribVO} );
			fillFilds(attribVO);	
			view.attributesList.selectedIndex = objectTypeVO.attributes.length - 1;
			view.attributesList.validateNow();
//			view.attributesList.scrollToIndex(view.languagesDataGrid.selectedIndex);
						
		}
		
		private function deleteAttribute(event:MouseEvent): void
		{
			var selectInd:uint = view.attributesList.selectedIndex;
			var selectIt:Object = view.attributesList.selectedItem;
			objectTypeVO.attributes.removeItemAt(selectInd);
//и так удаляет =)	view.attributesList.dataProvider.removeItemAt(selectInd );
			
		}

		private  function hideAttributes(event: FlexEvent):void
		{
			view.attributesList.removeEventListener(Event.CHANGE, selectAtribute);
		}

		protected function compliteAtributes( ):void
		{			
			view.attributesList.dataProvider = objectTypeVO.attributes;
		}		

		protected function get view():Attributes
		{
			return viewComponent as Attributes;
		}
	}
}

