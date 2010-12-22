/*
   Class ObjectTypeVOProxy is a wrapper over the ObjectTypeVO
 */
package net.vdombox.object_editor.model.proxy.componentsProxy
{
	import net.vdombox.object_editor.model.vo.AttributeVO;
	import net.vdombox.object_editor.model.vo.ObjectTypeVO;
	import net.vdombox.object_editor.view.essence.Attributes;

	import org.puremvc.as3.interfaces.*;
	import org.puremvc.as3.patterns.proxy.Proxy;

	public class ObjectTypeProxy extends Proxy implements IProxy
	{
		public static const NAME:String = "ObjectTypeVOProxy";
		private var  _objectTypeList:Array;

		public function ObjectTypeProxy ( data:Object = null ) 
		{
			super ( NAME, data );
			_objectTypeList = new Array;			
		}	

		public function newObjectTypeVO(objTypeXML:XML, path:String):void
		{
			//information
			if (_objectTypeList[path])
			{
				facade.sendNotification( ApplicationFacade.OBJECT_EXIST, path );
			}
			else
			{					
				var objTypeVO: ObjectTypeVO = initInformation(objTypeXML);			
				objTypeVO.filePath	= path;
				//sourceCode
				objTypeVO.sourceCode = initSourceCode(objTypeXML);
				//atributes
				for each ( var data : XML in objTypeXML.descendants("Attribute"))  //xml.descendants("Attributes") )
				{
					var atrib:AttributeVO = new AttributeVO;
//					atrib.label			= data.Name;
					atrib.name			= data.Name;
					atrib.displayName	= data.DisplayName;
					atrib.defaultValue	= data.DefaultValue;
					atrib.visible		= data.Visible.toString() == "1";
					atrib.help			= data.Help;
					atrib.interfaceType	= data.InterfaceType;//uint
					atrib.codeInterface	= data.CodeInterface;
					atrib.colorgroup	= data.Colorgroup;
					atrib.errorValidationMessage		= data.ErrorValidationMessage;
					atrib.regularExpressionValidation	= data.RegularExpressionValidation;

					objTypeVO.attributes.addItem({label:atrib.name, data:atrib});	
				}
				//language 
				var languageProxy:LanguagesProxy = facade.retrieveProxy(LanguagesProxy.NAME) as LanguagesProxy;
				objTypeVO.languages = languageProxy.createNew(objTypeXML);

				//resource
				var resoursesProxy:ResourcesProxy = facade.retrieveProxy(ResourcesProxy.NAME) as ResourcesProxy;
				objTypeVO.resources = resoursesProxy.createFromXML(objTypeXML);

				_objectTypeList[objTypeVO.filePath] = objTypeVO;

				facade.sendNotification( ApplicationFacade.OBJECT_COMPLIT, objTypeVO );
				objTypeXML = null;
			}
		}

		public function initInformation(objTypeXML:XML):ObjectTypeVO
		{
			var objTypeVO: ObjectTypeVO = new ObjectTypeVO();
			var information: XML = objTypeXML.Information[0];			

			objTypeVO.category 		= information.Category;
			objTypeVO.className 	= information.ClassName;
			objTypeVO.container		= information.Container;
			objTypeVO.containers	= information.Containers;
			objTypeVO.description	= information.Description;
			objTypeVO.displayName	= information.DisplayName;
			objTypeVO.dynamic		= information.Dynamic.toString() == "1";
			objTypeVO.id			= information.ID;	
			objTypeVO.interfaceType	= information.InterfaceType;			
			objTypeVO.name 			= information.Name;
			objTypeVO.moveable		= information.Moveable.toString() == "1";
			objTypeVO.optimizationPriority = information.OptimizationPriority;						
			objTypeVO.resizable		= information.Resizable;	
			objTypeVO.version		= information.Version;	
					
			return objTypeVO;
		}

		public function initSourceCode(objTypeXML:XML):String
		{
			return objTypeXML.SourceCode.toString();
		}

		public function getObjectTypeVO(id:String):ObjectTypeVO
		{
			return _objectTypeList[id];
		}

		public function createXML( objTypeVO: ObjectTypeVO):XML
		{
			var objTypeXML:XML = new XML("<Type/>");

			//save information
			var information:XML = new XML("<Information/>");				
			information.Name = objTypeVO.name;
			information.DisplayName = objTypeVO.displayName;	
			//				information.XMLScriptName = objTypeVO.;	
			//				information.RenderType = objTypeVO.renderType;
			information.Description = objTypeVO.description;
			information.ClassName = objTypeVO.className;
			information.ID = objTypeVO.id;
			information.Category = objTypeVO.category;
			information.Version = objTypeVO.version;
			information.OptimizationPriority = objTypeVO.optimizationPriority;
			//				information.WCAG = objTypeVO;
			information.Container = objTypeVO.container;
			//				information.RemoteMethods = objTypeVO.;
			//				information.Handlers = objTypeVO;
			information.Moveable = objTypeVO.moveable;
			information.Dynamic = objTypeVO.dynamic;
			information.InterfaceType = objTypeVO.interfaceType;
			information.Resizable = objTypeVO.resizable;
			information.Containers = objTypeVO.containers;
			objTypeXML.appendChild(information);

			//sourceCode
			//TODO add <sourceCode/>
			var sourceCode:XML = XML("<SourceCode/>");
			sourceCode.appendChild( XML("\n"+"<![CDATA[" +  objTypeVO.sourceCode +"]" +"]" +">") )
			objTypeXML.appendChild( sourceCode );	

			//language 
			var languageProxy:LanguagesProxy = facade.retrieveProxy(LanguagesProxy.NAME) as LanguagesProxy;
			objTypeXML.appendChild(languageProxy.createXML(objTypeVO.languages));

			//resource
			var resourcesProxy:ResourcesProxy = facade.retrieveProxy(ResourcesProxy.NAME) as ResourcesProxy;
			var resourcesXML : XML = resourcesProxy.toXML(objTypeVO.resources);
			objTypeXML.appendChild(resourcesXML);


			return objTypeXML;
		}
	}
}

