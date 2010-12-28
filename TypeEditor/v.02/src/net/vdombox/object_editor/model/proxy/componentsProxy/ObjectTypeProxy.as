/*
   Class ObjectTypeVOProxy is a wrapper over the ObjectTypeVO
 */
package net.vdombox.object_editor.model.proxy.componentsProxy
{
	import mx.controls.Alert;
	
	import net.vdombox.object_editor.model.vo.AttributeVO;
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

				objTypeVO.filePath	 = path;
				objTypeVO.sourceCode = objTypeXML.SourceCode.toString();
				objTypeVO.languages  = languagesProxy.createFromXML(objTypeXML);
				objTypeVO.libraries  = librariesProxy.createFromXML(objTypeXML);
				objTypeVO.attributes = attributesProxy.createFromXML(objTypeXML);
				objTypeVO.resources  = resourcesProxy.createFromXML(objTypeXML);
				objTypeVO.events	 = eventsProxy.createFromXML(objTypeXML);

				_objectTypeList[objTypeVO.filePath] = objTypeVO;
				facade.sendNotification( ApplicationFacade.OBJECT_COMPLIT, objTypeVO );
			}
		}

		public function createXML( objTypeVO: ObjectTypeVO):XML
		{
			var objTypeXML:XML = getNewObjTypeXML(objTypeVO);

			objTypeXML.appendChild( sourceCodeToXML(objTypeVO.sourceCode) );	
			objTypeXML.appendChild( languagesProxy.createXML(objTypeVO.languages) );
			objTypeXML.appendChild( attributesProxy.createXML(objTypeVO.attributes) );
			objTypeXML.appendChild( eventsProxy.createXML(objTypeVO.events) );
			objTypeXML.appendChild( resourcesProxy.toXML(objTypeVO.resources));
			objTypeXML.appendChild( librariesProxy.createXML(objTypeVO.libraries));

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
			information.Dynamic 			= objTypeVO.dynamic;
			information.EditorIcon			= objTypeVO.editorIcon;
			information.Handlers 			= objTypeVO.handlers;
			information.Name 				= objTypeVO.name;
			information.Icon				= objTypeVO.icon;
			information.ID 					= objTypeVO.id;
			information.InterfaceType 		= objTypeVO.interfaceType;
			information.Languages 			= objTypeXML.appendChild(information);
			information.Moveable 			= objTypeVO.moveable;
			information.OptimizationPriority = objTypeVO.optimizationPriority;
			information.RemoteMethods 		= objTypeVO.remoteMethods;
			information.RenderType 			= objTypeVO.renderType;
			information.Resizable 			= objTypeVO.resizable;
			information.StructureIcon 		= objTypeVO.structureIcon;
			information.WCAG 				= objTypeVO;
			information.XMLScriptName 		= objTypeVO.XMLScriptName;	
			information.Version 			= objTypeVO.version;

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

			objTypeVO.icon 			= information.Icon;
			objTypeVO.editorIcon 	= information.EditorIcon;
			objTypeVO.structureIcon = information.StructureIcon;

			return objTypeVO;
		}

		public function removeVO(objTypeVO  : ObjectTypeVO):void
		{
			_objectTypeList[objTypeVO.filePath] = null
		}

		private function get languagesProxy():LanguagesProxy
		{
			return facade.retrieveProxy(LanguagesProxy.NAME) as LanguagesProxy;
		}

		private function get eventsProxy():EventsProxy
		{
			return facade.retrieveProxy(EventsProxy.NAME) as EventsProxy;
		}

		private function get attributesProxy():AttributesProxy
		{
			return facade.retrieveProxy(AttributesProxy.NAME) as AttributesProxy;
		}

		private function get resourcesProxy():ResourcesProxy
		{
			return facade.retrieveProxy(ResourcesProxy.NAME) as ResourcesProxy;
		}
		
		private function get librariesProxy():LibrariesProxy
		{
			return facade.retrieveProxy(LibrariesProxy.NAME) as LibrariesProxy;
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

