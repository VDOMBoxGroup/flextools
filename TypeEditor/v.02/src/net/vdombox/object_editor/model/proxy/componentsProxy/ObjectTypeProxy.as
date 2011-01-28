/*
   Class ObjectTypeVOProxy is a wrapper over the ObjectTypeVO
 */
package net.vdombox.object_editor.model.proxy.componentsProxy
{
	import mx.controls.Alert;
	
	import net.vdombox.object_editor.model.vo.ActionParameterVO;
	import net.vdombox.object_editor.model.vo.ActionVO;
	import net.vdombox.object_editor.model.vo.ActionsContainerVO;
	import net.vdombox.object_editor.model.vo.AttributeVO;
	import net.vdombox.object_editor.model.vo.EventParameterVO;
	import net.vdombox.object_editor.model.vo.EventVO;
	import net.vdombox.object_editor.model.vo.ObjectTypeVO;
	import net.vdombox.object_editor.view.essence.Attributes;
	import net.vdombox.object_editor.view.essence.Resourses;
	
	import org.puremvc.as3.interfaces.*;
	import org.puremvc.as3.patterns.proxy.Proxy;

	public class ObjectTypeProxy extends Proxy implements IProxy
	{
		public static const NAME:String = "ObjectTypeVOProxy";
		private var  _objectTypeList: Object;

		public function ObjectTypeProxy ( data:Object = null ) 
		{
			super ( NAME, data );
			_objectTypeList = new Object;			
		}	

		public function newObjectTypeVO(objTypeXML:XML, path:String):void
		{
			if (_objectTypeList[path])
			{
				facade.sendNotification( ApplicationFacade.OBJECT_EXIST, path );
			}
			else
			{					
				var objTypeVO: ObjectTypeVO = initInformation(objTypeXML);			

				objTypeVO.filePath	 		= path;
				objTypeVO.actionContainers	= actionsProxy.createFromXML(objTypeXML);
				objTypeVO.attributes 		= attributesProxy.createFromXML(objTypeXML);
				objTypeVO.events	 		= eventsProxy.createFromXML(objTypeXML);
				objTypeVO.languages  		= languagesProxy.createFromXML(objTypeXML);
				objTypeVO.libraries  		= librariesProxy.createFromXML(objTypeXML);				
				objTypeVO.sourceCode 		= getSourceCode( objTypeXML );
				objTypeVO.resources  		= resourcesProxy.createFromXML(objTypeXML);

				//проверка на повторное использование id				
				_objectTypeList[objTypeVO.filePath] = reuseID(objTypeVO);

				facade.sendNotification( ApplicationFacade.OBJECT_COMPLIT, objTypeVO );
			}
		}
		
		private function getSourceCode( objTypeXML: XML):String
		{
			return (objTypeXML.SourceCode.toString() == "")? objTypeXML.sourceCode.toString(): objTypeXML.SourceCode.toString();			
		}

		private function reuseID( objTypeVO: ObjectTypeVO):ObjectTypeVO
		{
			reuseInformationID	( objTypeVO );
			reuseActionsID		( objTypeVO );
			reuseAttributesID	( objTypeVO );
			reuseEventsID		( objTypeVO );			
			return objTypeVO;
		}

		private function reuseInformationID( objTypeVO: ObjectTypeVO):void
		{
			objTypeVO.description = languagesProxy.used(objTypeVO.languages, objTypeVO.description);
			objTypeVO.displayName = languagesProxy.used(objTypeVO.languages, objTypeVO.displayName);			
			languagesProxy.used(objTypeVO.languages, "#Lang(003)");
		}

		private function reuseEventsID( objTypeVO: ObjectTypeVO):void
		{
			for each (var eventObj:Object in objTypeVO.events)
			{
				var event:EventVO = eventObj.data;
				for each (var parObj:Object in event.parameters)
				{
					var eventPar:EventParameterVO = parObj.data;
					if( eventPar.help == "") eventPar.help = "#Lang(105)";
					eventPar.help = languagesProxy.used(objTypeVO.languages, eventPar.help);
				}
			}
		}

		private function reuseAttributesID( objTypeVO: ObjectTypeVO):void
		{
			for each (var obj:Object in objTypeVO.attributes)
			{
				var attr:AttributeVO = obj.data;
				if( attr.displayName == "") attr.displayName = "#Lang(101)";
				if( attr.help == "")attr.help = "#Lang(301)";
				if( attr.errorValidationMessage == "") attr.errorValidationMessage = "#Lang(201)";

				attr.displayName = languagesProxy.used(objTypeVO.languages, attr.displayName);
				attr.help		 = languagesProxy.used(objTypeVO.languages, attr.help);
				attr.errorValidationMessage = languagesProxy.used(objTypeVO.languages, attr.errorValidationMessage);
			}
		}

		private function reuseActionsID( objTypeVO: ObjectTypeVO):void
		{
			for each (var contObj:Object in objTypeVO.actionContainers)
			{
				var cont:ActionsContainerVO = contObj.data;
				for each (var actObj:Object in cont.actionsCollection)
				{
					var act:ActionVO = actObj.data;
					if( act.description == "")   act.description   = "#Lang(600)";
					if( act.interfaceName == "") act.interfaceName = "#Lang(700)";					
					act.description   = languagesProxy.used(objTypeVO.languages, act.description);
					act.interfaceName = languagesProxy.used(objTypeVO.languages, act.interfaceName);
					for each (var parObj:Object in act.parameters)
					{
						var actPar:ActionParameterVO = parObj.data;
						if( actPar.interfaceName == "") actPar.interfaceName = "#Lang(900)";
						if( actPar.help          == "") actPar.help          = "#Lang(800)";
						actPar.interfaceName = languagesProxy.used(objTypeVO.languages, actPar.interfaceName);
						actPar.help			 = languagesProxy.used(objTypeVO.languages, actPar.help);
					}
				}
			}			
		}

		public function createXML( objTypeVO: ObjectTypeVO):XML
		{
			var objTypeXML:XML = getNewObjTypeXML(objTypeVO);

			objTypeXML.appendChild( attributesProxy.createXML(objTypeVO.attributes) );			
			objTypeXML.appendChild( eventsProxy.createXML(objTypeVO.events) );//здесь важна последовательность!
			objTypeXML.E2vdom.appendChild( actionsProxy.createXML(objTypeVO.actionContainers) );
			objTypeXML.appendChild( languagesProxy.createXML(objTypeVO.languages) );
			objTypeXML.appendChild( librariesProxy.createXML(objTypeVO.libraries) );
			objTypeXML.appendChild( sourceCodeToXML(objTypeVO.sourceCode) );	
			objTypeXML.appendChild( resourcesProxy.toXML(objTypeVO.resources));

			return objTypeXML;
		}

		public function getObjectTypeVO(id:String):ObjectTypeVO
		{
			return _objectTypeList[id];
		}

		private function sourceCodeToXML(sourceCode:String):XML
		{				
			var sourceCodeXML:XML = XML("<SourceCode/>");
			sourceCodeXML.appendChild( XML("\n"+"<![CDATA[" + sourceCode +"]]>") )
				
			return sourceCodeXML;
		}

		private function getNewObjTypeXML(objTypeVO : ObjectTypeVO):XML
		{
			var objTypeXML:XML = new XML("<Type/>");

			//save information
			var information:XML = new XML("<Information/>");

			information.Category 			= objTypeVO.category;
			information.ClassName 			= objTypeVO.className;
			information.Container 			= objTypeVO.container;
			information.Containers 			= objTypeVO.containers;
			information.Description 		= objTypeVO.description;
			information.DisplayName	 		= objTypeVO.displayName;	
			information.Dynamic 			= (objTypeVO.dynamic)? "1": "0";
			information.EditorIcon			= objTypeVO.editorIcon;
			information.Handlers 			= objTypeVO.handlers;
			information.Name 				= objTypeVO.name;
			information.Icon				= objTypeVO.icon;
			information.ID 					= objTypeVO.id;
			information.InterfaceType 		= objTypeVO.interfaceType;
//			information.Languages 			= ""; //objTypeXML.appendChild(information); is not used
			information.Moveable 			= (objTypeVO.moveable)? "1": "0";
			information.OptimizationPriority = objTypeVO.optimizationPriority;
			information.RemoteMethods		= objTypeVO.remoteMethods;
			information.RenderType 			= objTypeVO.renderType;
			information.Resizable 			= objTypeVO.resizable;
			information.StructureIcon 		= objTypeVO.structureIcon;
			information.WCAG 				= objTypeVO.wcag;
			information.XMLScriptName 		= objTypeVO.XMLScriptName;	
			information.Version 			= objTypeVO.version;

			objTypeXML.appendChild(information);

			return objTypeXML;
		}

		public function initInformation(objTypeXML:XML):ObjectTypeVO
		{
			var objTypeVO: ObjectTypeVO = new ObjectTypeVO();
			var information: XML = objTypeXML.Information[0];			

			objTypeVO.category 		= information.Category;
			objTypeVO.className 	= information.ClassName;
			objTypeVO.container		= information.Container;
			objTypeVO.containers	= information.Containers;
			checkLang(information.Description, objTypeVO.description );
			checkLang(information.DisplayName, objTypeVO.displayName );

			objTypeVO.dynamic		= information.Dynamic.toString() == "1";
			objTypeVO.id			= information.ID;	
			objTypeVO.interfaceType	= information.InterfaceType;			
			objTypeVO.name 			= information.Name;
			objTypeVO.moveable		= information.Moveable.toString() == "1";
			objTypeVO.optimizationPriority = information.OptimizationPriority;						
			objTypeVO.resizable		= information.Resizable;	
			objTypeVO.version		= information.Version;	
			objTypeVO.wcag			= information.WCAG;

			objTypeVO.icon 			= information.Icon;
			objTypeVO.editorIcon 	= information.EditorIcon;
			objTypeVO.structureIcon = information.StructureIcon;

			return objTypeVO;
		}

		public function removeVO(objTypeVO  : ObjectTypeVO):void
		{
			_objectTypeList[objTypeVO.filePath] = null
		}

		private function get attributesProxy():AttributesProxy
		{
			return facade.retrieveProxy(AttributesProxy.NAME) as AttributesProxy;
		}

		private function get actionsProxy():ActionContainersProxy
		{
			return facade.retrieveProxy(ActionContainersProxy.NAME) as ActionContainersProxy;
		}

		private function get eventsProxy():EventsProxy
		{
			return facade.retrieveProxy(EventsProxy.NAME) as EventsProxy;
		}		

		private function get languagesProxy():LanguagesProxy
		{
			return facade.retrieveProxy(LanguagesProxy.NAME) as LanguagesProxy;
		}

		private function get librariesProxy():LibrariesProxy
		{
			return facade.retrieveProxy(LibrariesProxy.NAME) as LibrariesProxy;
		}

		private function get resourcesProxy():ResourcesProxy
		{
			return facade.retrieveProxy(ResourcesProxy.NAME) as ResourcesProxy;
		}

		private function checkLang(strXML:String, strVO:String):void
		{
			if (strXML != strVO)
			{
				var text : String = " mast be: " + strVO + " current is " + strXML;

				Alert.show(text, "Wrong Lang ID")
					//todo: делаем запись в Лангв
					//language 
					//				var languageProxy:LanguagesProxy = facade.retrieveProxy(LanguagesProxy.NAME) as LanguagesProxy;

					//				languageProxy.correctWord(strXML, strVO)
					//todo: делаем запись в лог ошибок
			}
		}

	}
}

