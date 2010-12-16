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
				facade.sendNotification( ApplicationFacade.OBJECT_EXIST, objTypeVO.filePath );
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
				var resoursesProxy:ResoursesProxy = facade.retrieveProxy(ResoursesProxy.NAME) as ResoursesProxy;
				objTypeVO.resourses = resoursesProxy.createFromXML(objTypeXML);

				_objectTypeList[objTypeVO.filePath] = objTypeVO;

				facade.sendNotification( ApplicationFacade.OBJECT_COMPLIT, objTypeVO );
			}
		}

		public function initInformation(objTypeXML:XML):ObjectTypeVO
		{
			var objTypeVO: ObjectTypeVO = new ObjectTypeVO();
			var information: XML = objTypeXML.Information[0];			

			objTypeVO.name 			= information.Name;
			objTypeVO.category 		= information.Category;
			objTypeVO.className 	= information.ClassName;
			objTypeVO.id			= information.ID;			
			objTypeVO.dynamic		= information.Dynamic.toString() == "1";
			objTypeVO.moveable		= information.Moveable.toString() == "1";			
			objTypeVO.resizable		= information.Resizable;	
			objTypeVO.container		= information.Container;	
			objTypeVO.version		= information.Version;	
			objTypeVO.interfaceType	= information.InterfaceType;	
			objTypeVO.optimizationPriority = information.OptimizationPriority;	
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
			//				information.DisplayName = objTypeVO.displayName;	
			//				information.XMLScriptName = objTypeVO.;	
			//				information.RenderType = objTypeVO.renderType;
			//				information.Description = objTypeVO.description;
			information.ClassName = objTypeVO.className;
			information.ID = objTypeVO.id;
			information.Category = objTypeVO.category;
			information.Version = objTypeVO.version;
			information.OptimizationPriority = objTypeVO.optimizationPriority;
			//				information.WCAG = objTypeVO;
			information.Containers = objTypeVO.container;
			//				information.RemoteMethods = objTypeVO.;
			//				information.Handlers = objTypeVO;
			information.Moveable = objTypeVO.moveable;
			information.Dynamic = objTypeVO.dynamic;
			information.InterfaceType = objTypeVO.interfaceType;
			information.Resizable = objTypeVO.resizable;
			information.Container = objTypeVO.container;
			objTypeXML.appendChild(information);

			//sourceCode
			objTypeXML.appendChild( XML("<![CDATA[" +  objTypeVO.sourceCode +"]" +"]" +">"));				


			//resource
			var resoursesProxy:ResoursesProxy = facade.retrieveProxy(ResoursesProxy.NAME) as ResoursesProxy;
			var resoursesXML : XML = resoursesProxy.toXML(objTypeVO);
			objTypeXML.appendChild(resoursesXML);


			return objTypeXML;
		}
	}
}

