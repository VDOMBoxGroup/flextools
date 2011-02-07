/*
	Class AttributeMediator is a wrapper over the Attributes.mxml
*/
package net.vdombox.object_editor.view.mediators
{
	import flash.display.DisplayObject;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.ui.Mouse;
	
	import mx.collections.ArrayCollection;
	import mx.collections.IList;
	import mx.collections.Sort;
	import mx.collections.SortField;
	import mx.core.IVisualElement;
	import mx.events.FlexEvent;
	import mx.messaging.management.Attribute;
	import mx.messaging.messages.ErrorMessage;
	
	import net.vdombox.object_editor.model.proxy.componentsProxy.LanguagesProxy;
	import net.vdombox.object_editor.model.vo.AttributeVO;
	import net.vdombox.object_editor.model.vo.ObjectTypeVO;
	import net.vdombox.object_editor.view.AttributesListRenderer;
	import net.vdombox.object_editor.view.DropDownValue;
	import net.vdombox.object_editor.view.LangTextInput;
	import net.vdombox.object_editor.view.essence.Attributes;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	import spark.components.Button;
	import spark.components.HGroup;
	import spark.components.List;

	public class AttributeMediator extends Mediator implements IMediator
	{
		public static const NAME:String = "AttributeMediator";
		private var objectTypeVO:ObjectTypeVO;
		private var currentAttributeVO: AttributeVO;

		public function AttributeMediator( viewComponent:Object, objTypeVO:ObjectTypeVO ) 
		{			
			super( NAME+objTypeVO.id, viewComponent );
			this.objectTypeVO = objTypeVO;	
			view.addEventListener( FlexEvent.SHOW,		showAttributes );
			view.addEventListener( Event.CHANGE,		validateObjectTypeVO );
			view.addEventListener( FlexEvent.CHANGING,	changeStack );
			view.addEventListener( FlexEvent.ADD,		addDropDownRow );
		}
		
		private function selectCodeInterface( event:Event = null ):void
		{ 			
			view.label= "Attributes*";			
			facade.sendNotification( ObjectViewMediator.OBJECT_TYPE_CHAGED, objectTypeVO);
			if( currentAttributeVO )
				currentAttributeVO.codeInterface = view.CodeInterfaceValue.toString();			
		}

		private function changeName( event:Event ):void
		{ 
			view.currentAttribute.label = event.target.text;
			
			currentAttributeVO.name = view.fname.text;
			view.attributesList.dataProvider.itemUpdated(view.currentAttribute);
			
			view.attributesList.selectedItem = view.currentAttribute;
			view.attributesList.ensureIndexIsVisible(view.attributesList.selectedIndex);
			view.attributesList.validateNow();
		}
		
		public function apdateBackgroundColor(event: Event=null):void
		{	
			if (event)
				view.currentAttribute.color = event.target.selectedIndex;
			
			var selIndex:uint = view.attributesList.selectedIndex;
			var atrList:List  = view.attributesList as List;
			
			atrList.dataProvider.removeItemAt(selIndex);
			atrList.dataProvider.addItemAt(view.currentAttribute,selIndex);
			atrList.selectedItem = view.currentAttribute;
			atrList.ensureIndexIsVisible(atrList.selectedIndex);
			atrList.validateNow();
		}
		
		public function validateObjectTypeVO(event:Event):void
		{
			view.label= "Attributes*";			
			facade.sendNotification( ObjectViewMediator.OBJECT_TYPE_CHAGED, objectTypeVO);
			if (currentAttributeVO)
			{				
				currentAttributeVO.defaultValue		= view.defaultValue.text;
				currentAttributeVO.visible			= view.visibleAtr.selected;
				currentAttributeVO.interfaceType	= view.interfaceType.selectedIndex;
				currentAttributeVO.colorgroup		= view.colorgroup.selectedIndex;
				selectCodeInterface();
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
			compliteCodeInterfaceField(attributeVO.codeInterface);
			
			view.displayName.completeStructure( objectTypeVO.languages, attributeVO.displayName );
			view.help.completeStructure       ( objectTypeVO.languages, attributeVO.help );
			view.errMessage.completeStructure ( objectTypeVO.languages, attributeVO.errorValidationMessage );
		}
		
		private function showAttributes(event: FlexEvent): void
		{		
			view.attributesList.addEventListener       ( Event.CHANGE, 		selectAtribute );
			view.fname.addEventListener                ( Event.CHANGE, 		changeName );
			view.addAttributeButton.addEventListener   ( MouseEvent.CLICK,	addAttribute );
			view.deleteAttributeButton.addEventListener( MouseEvent.CLICK,	deleteAttribute );
			view.colorgroup.addEventListener		   ( Event.CHANGE, 		apdateBackgroundColor );
			compliteAtributes();
			view.validateNow();
		}
		
		private function addAttribute(event:MouseEvent): void
		{			
			var attribVO:AttributeVO = new AttributeVO( "newAttribute"+ objectTypeVO.attributes.length );
			objectTypeVO.attributes.addItem( {label:attribVO.name, data:attribVO, color:1} );
			var langsProxy:LanguagesProxy 	= facade.retrieveProxy( LanguagesProxy.NAME ) as LanguagesProxy;
			attribVO.displayName            = langsProxy.getNextId(objectTypeVO.languages, "1", attribVO.name+" displayName");
			attribVO.errorValidationMessage = langsProxy.getNextId(objectTypeVO.languages, "2", attribVO.name+" errValMess");
			attribVO.help                   = langsProxy.getNextId(objectTypeVO.languages, "3", attribVO.name+" help");
			attribVO.codeInterface			= "TextField()";
			attribVO.colorgroup				= 1;			
			fillAttributeFilds(attribVO);			
			view.currentAttribute 			= getCurrentAttribute(attribVO.name);
			currentAttributeVO    			= view.currentAttribute.data;
			view.attributesList.selectedItem= view.currentAttribute;
			view.attributesList.validateNow();
		}
		
		private function getCurrentAttribute(nameAttib:String):Object
		{			
			for each (var attr:Object in objectTypeVO.attributes)
			{
				if (attr["label"] == nameAttib)
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
			if (listIndex < 0)
				listIndex = 0;
			
			if (objectTypeVO.attributes.length > 0)
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
				{
					if (objectTypeVO == note.getBody())
						view.label= "Attributes";
					break;
				}
					
				case ApplicationFacade.CHANGE_CURRENT_LANGUAGE:
				{
					if (view.attributesList)
						changeFildWithCurrentLanguage( );
					break;
				}
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
			
			changeDropDownFildsWithCurrentLanguage() 
		}
		
		public function changeDropDownFildsWithCurrentLanguage():void
		{			
			var i:int=0;
			var dropDownHroup:HGroup = new HGroup();
			var childExist:Boolean = true;
			while (childExist)
			{	
				try
				{
					dropDownHroup = view.vGroup.getChildAt(i) as HGroup;
					var dropDownValue:DropDownValue = dropDownHroup.getChildAt(0) as DropDownValue;
					dropDownValue.langTextInput.currentLanguage = objectTypeVO.languages.currentLocation;
					dropDownValue.langTextInput.apdateFild();
					i++;				
				}
				catch (e:Error) 
				{
					childExist = false;
				}				
			}
		}
		
		public function compliteCodeInterfaceField(value:String):void
		{
			view.CodeInterfaceValue = value;
			
			var ciparser:RegExp = /([^\(]+)\((.*)\)/;
			var parsed:Array = ciparser.exec(value);				
			var codeinterfaceLabel:String = parsed[1];
			var codeIntefaceArguments:String = parsed[2];
			var arguments:Array = codeIntefaceArguments.split(",");
			
			if (codeinterfaceLabel == "Number") 
				codeinterfaceLabel+=1;
			view.codeInterface.selectedItem = codeinterfaceLabel;	
			
			
			if (codeinterfaceLabel != "!Font" &&
				codeinterfaceLabel != "File"  &&
				codeinterfaceLabel != "Color" &&
				codeinterfaceLabel != "PageLink" &&
				codeinterfaceLabel != "LinkedBase")
			{
				switch (codeinterfaceLabel) 
				{	
					case "TextField":
					{
						view.CIViewStack.selectedIndex = 0;
						view.CIViewStack.validateNow();
						view.fieldLength.text = arguments[0];
						break;
					}
						
					case "Number1":
					{
						view.CIViewStack.selectedIndex = 1;
						view.CIViewStack.validateNow();
						view.minValue.text = arguments[0];							
						view.maxValue.text = arguments[1];
						break;
					}
					
					case "MultiLine":
					{
						view.CIViewStack.selectedIndex = 2;
						view.CIViewStack.validateNow();
						view.multiLineLength.text = arguments[0]; 
						break;
					}
						
					case "DropDown":
					{
						view.CIViewStack.selectedIndex = 3;
						view.CIViewStack.validateNow();
						var regLangs:RegExp = /(#Lang\(\d+\))\|([\w\d]+)/g;
						var langs:Array = new Array();							
						
						while (langs = regLangs.exec(arguments[0]))
						{
							var dropDownValue:DropDownValue = new DropDownValue();
							dropDownValue.langTextInput.completeStructure(objectTypeVO.languages, langs[1]);
							dropDownValue.textValue.text = langs[2];
							addDropDownRow(null,dropDownValue);	
						}							
						break;
					}
						
					case "ObjectList":
					{
						view.CIViewStack.selectedIndex = 4;
						view.CIViewStack.validateNow();
						view.typeId.text = arguments[0];
						break;
					}
						
					case "ExternalEditor":
					{
						view.CIViewStack.selectedIndex = 5;
						view.CIViewStack.validateNow();
						view.title.text = arguments[0];	
						view.info.text  = arguments[1];
						break;
					}
				}
			}
		}
		
		public function addDropDownRow(event:FlexEvent, dropDownVal:DropDownValue=null):void
		{
			var hGroup:HGroup = new HGroup();
			if (!dropDownVal)
			{
				dropDownVal = new DropDownValue();	
				dropDownVal.langTextInput.completeStructure(objectTypeVO.languages, languagesProxy.getNextId(objectTypeVO.languages, "4", ""));
			}
			
			dropDownVal.langTextInput.addEventListener(Event.CHANGE, view.changeDropDownValue);
			dropDownVal.textValue.addEventListener(Event.CHANGE, view.changeDropDownValue);
			
			var deleteButton:Button = new Button();
			deleteButton.width = 30;
			deleteButton.label = "X";
			deleteButton.addEventListener( MouseEvent.CLICK, removeDropDownRow);
			
			hGroup.addElement(dropDownVal);
			hGroup.addElement(deleteButton);
			view.vGroup.addElement(hGroup);
			view.validateNow();
			changeCodeInterfaceStack(false);		
			//				setCodeInterfaceValue();
		}
		
		public function removeDropDownRow(event:MouseEvent):void
		{
			var button:Button = event.currentTarget as Button;
			var hGroup:HGroup = button.parent as HGroup;
			var dropDownVal:DropDownValue = hGroup.getElementAt(0) as DropDownValue;
			var str:String = "#Lang("+dropDownVal.langTextInput.words["ID"].toString()+")";
			languagesProxy.deleteWord(objectTypeVO, str);
			view.vGroup.removeElement( button.parent as IVisualElement );
			view.validateNow();
			changeCodeInterfaceStack(false);		
		}
		
		private function setData( label:String, isChangeStack:Boolean):void
		{	
			if (isChangeStack) 
				view.CodeInterfaceValue = label + "()";
			else
				switch (label) 
				{	
					case "TextField":
					{
						view.CodeInterfaceValue = label + "(" + view.fieldLength.text +")";
						break;
					}
						
					case "Number1":						
					{
						view.CodeInterfaceValue = "Number1" + "(" + view.minValue.text + "," + view.maxValue.text + ")";
						break;
					}
						
					case "MultiLine":
					{
						view.CodeInterfaceValue = label + "(" +view. multiLineLength.text + ")";
						break;
					}
						
					case "DropDown":
					{
						setCodeInterfaceDropDownValue();
						break;		
					}
						
					case "ObjectList":
					{
						view.CodeInterfaceValue = label + "(" + view.typeId.text + ")";
						break;
					}
						
					case "ExternalEditor":
					{
						view.CodeInterfaceValue = label + "(" + view.title.text +","+ view.info.text + ")";
						break;
					}
				}
		}
		
		public function setCodeInterfaceDropDownValue():void
		{
			var i:int=0;
			var dropDownHroup:HGroup = new HGroup();
			var childExist:Boolean = true;
			var values:String = "";
			while (childExist)
			{	
				try
				{
					dropDownHroup = view.vGroup.getChildAt(i) as HGroup;
					var dropDownValue:DropDownValue = dropDownHroup.getChildAt(0) as DropDownValue;
					values += "(#Lang(" + dropDownValue.langTextInput.words["ID"];
					values += ")|" + dropDownValue.textValue.text + ")|";
					i++;				
				}
				catch (e:Error) 
				{
					childExist = false;
				}				
			}
			
			values = values.slice(0,view.CodeInterfaceValue.length-1);
			view.CodeInterfaceValue = "DropDown(" + values + ")";	
		}
		
		public function changeStack(event:FlexEvent):void
		{					
			changeCodeInterfaceStack(event.bubbles);
		}		
		
		public function changeCodeInterfaceStack(isChangeStack:Boolean):void
		{					
			if(isChangeStack)
				clearCodeInterfaceFields();

			var label:String = view.codeInterface.selectedItem;
			if (label != "!Font" &&
				label != "File"  &&
				label != "Color" &&
				label != "PageLink" &&
				label != "LinkedBase")
			{
				var ch:* = view.CIViewStack.getChildByName(view.codeInterface.selectedItem);
				view.CIViewStack.selectedChild = ch;
				setData(label, isChangeStack);
			}	
			else
			{
				view.CIViewStack.selectedChild = view.notArguments;
				view.CodeInterfaceValue = label + "()";
			}
			selectCodeInterface();
//			dispatchEvent(new Event( Event.SELECT));
		}
		
		private function clearCodeInterfaceFields():void
		{
			var num:int 	 = view.CodeInterfaceValue.indexOf("(");				
			var label:String = view.CodeInterfaceValue.slice(0,num); 
			
			if (label != "!Font"	&&
				label != "File"		&&
				label != "Color"	&&
				label != "PageLink"	&&
				label != "LinkedBase")
			{
				switch ( label ) 
				{	
					case "TextField":
					{
						view.fieldLength.text = "";
						break;
					}
						
					case "Number1":
					{
						view.minValue.text = "";							
						view.maxValue.text = "";
						break;
					}
						
					case "MultiLine":
					{
						view.multiLineLength.text = ""; 
						break;
					}
						
					case "DropDown":
					{
						view.vGroup.removeAllElements();
						view.validateNow();
						break;	
					}
						
					case "ObjectList":
					{
						view.typeId.text = "";
						break;
					}
						
					case "ExternalEditor":
					{
						view.title.text = "";	
						view.info.text  = "";
						break;
					}
				}
			}
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

