/*
   Class ObjectTypeVOProxy is a wrapper over the ObjectTypeVO
 */
package net.vdombox.object_editor.model.proxy.componentsProxy
{
	import mx.controls.Alert;
	import mx.messaging.channels.StreamingAMFChannel;
	
	import net.vdombox.object_editor.model.ErrorLogger;
	import net.vdombox.object_editor.model.vo.ActionParameterVO;
	import net.vdombox.object_editor.model.vo.ActionVO;
	import net.vdombox.object_editor.model.vo.ActionsContainerVO;
	import net.vdombox.object_editor.model.vo.AttributeVO;
	import net.vdombox.object_editor.model.vo.EventParameterVO;
	import net.vdombox.object_editor.model.vo.EventVO;
	import net.vdombox.object_editor.model.vo.ObjectTypeVO;
	import net.vdombox.object_editor.view.essence.Attributes;
	import net.vdombox.object_editor.view.essence.Resourses;
	import net.vdombox.object_editor.view.mediators.ApplicationMediator;
	
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

		/**
		 *	Create ObjectTypeVO and send Notification for add Tab
		**/
		public function newObjectTypeVO(objTypeXML:XML, path:String):void
		{
			if (_objectTypeList[path])
			{
				facade.sendNotification( ApplicationMediator.OBJECT_ALREADY_OPEN, path );
			}
			else
			{					
				var objTypeVO: ObjectTypeVO = initInformation(objTypeXML);			

				objTypeVO.filePath	 		= path;
				objTypeVO.actionContainers	= actionsProxy.createFromXML	(objTypeXML);
				objTypeVO.attributes 		= attributesProxy.createFromXML	(objTypeXML);
				objTypeVO.events	 		= eventsProxy.createFromXML		(objTypeXML);
				objTypeVO.languages  		= languagesProxy.createFromXML	(objTypeXML);
				objTypeVO.libraries  		= librariesProxy.createFromXML	(objTypeXML);				
				objTypeVO.sourceCode 		= getSourceCode(objTypeXML);
				objTypeVO.resources  		= resourcesProxy.createFromXML	(objTypeXML);

				//проверка на повторное использование id				
				_objectTypeList[objTypeVO.filePath] = reuseID(objTypeVO);

				facade.sendNotification( ApplicationMediator.OBJECT_COMPLIT, objTypeVO );
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
			objTypeVO.languages.tempWords = null;
			return objTypeVO;
		}

		private function reuseInformationID( objTypeVO: ObjectTypeVO):void
		{
			objTypeVO.displayName = languagesProxy.used(objTypeVO.languages, 0, objTypeVO.displayName, "Information.DisplayName");
			objTypeVO.description = languagesProxy.used(objTypeVO.languages, 0, objTypeVO.description, "Information.Dscription");
			languagesProxy.used(objTypeVO.languages, 0, "#Lang(003)", "Information.Container");
		}

		private function reuseEventsID( objTypeVO: ObjectTypeVO):void
		{
			for each (var eventObj:Object in objTypeVO.events)
			{
				var event:EventVO = eventObj.data;
				for each (var parObj:Object in event.parameters)
				{
					var eventPar:EventParameterVO = parObj.data;
					if (eventPar.help == "") 
						eventPar.help = "#Lang(905)";
					eventPar.help = languagesProxy.used(objTypeVO.languages, 9, eventPar.help, "Events."+ event.name +"."+ eventPar.name +".Help");
				}
			}
		}

		private function reuseAttributesID( objTypeVO: ObjectTypeVO):void
		{
			for each (var obj:Object in objTypeVO.attributes)
			{
				var attr:AttributeVO = obj.data;
				if (attr.displayName == "") 
					attr.displayName = "#Lang(101)";
				if (attr.help == "")
					attr.help = "#Lang(301)";
				if (attr.errorValidationMessage == "") 
					attr.errorValidationMessage = "#Lang(201)";

				attr.displayName = languagesProxy.used(objTypeVO.languages, 1, attr.displayName, "Attributes."+ attr.name +".DisplayName");
				attr.help		 = languagesProxy.used(objTypeVO.languages, 2, attr.help, "Attributes."+ attr.name +".Help");
				attr.errorValidationMessage = languagesProxy.used(objTypeVO.languages, 3, attr.errorValidationMessage, "Attributes."+ attr.name +".ErrValMessage");
				usedCodeInterface(objTypeVO, attr);
			}
		}		
		
		private function usedCodeInterface(objTypeVO: ObjectTypeVO, attr: AttributeVO):void
		{	
			if ( attr.codeInterface == "DropDown()" )
				return
				
			var ciparser:RegExp = /([^\(]+)\((.*)\)/;
			var parsed:Array = ciparser.exec(attr.codeInterface);				
			var codeInterfaceLabel:String = parsed[1];
			if ( codeInterfaceLabel == "DropDown" )
			{
				var codeIntValue:String = codeInterfaceLabel + "(";
				
				var regLangs:RegExp = /(#Lang\(\d+\))\|([\w\d\/w.`-]+)/g;
				var langs:Array = [];
				var tempStr:String;
				while (langs = regLangs.exec(attr.codeInterface))
				{
					var id:String = languagesProxy.getRegExpID(objTypeVO.languages, langs[1]);
					tempStr		  = languagesProxy.used(objTypeVO.languages, 4, langs[1], "Attributes."+ attr.name +".CodeInterface."+langs[2]);
					codeIntValue += "(" + tempStr + "|" + langs[2] + ")|";
				}	
				codeIntValue = codeIntValue.slice(0,codeIntValue.length-1);
				
				//if xml file have errors
				if ( (codeIntValue.length + 1) != attr.codeInterface.length )
				{
					if (codeIntValue == "DropDown") 
						codeIntValue = "DropDown(";
					Alert.show( "field DropDown of attribute " + attr.name + " contains an error. IDE will not keep and show this field", "Failed:" );
					ErrorLogger.instance.logError( "Failed: field DropDown of attribute contains an error.", "Attributes."+attr.name );
					trace("Failed: field DropDown of attribute " + attr.name + " contains an error.");
				}
					
				codeIntValue += ")";
				attr.codeInterface = codeIntValue;
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
					if (act.description == "")   act.description   = "#Lang(500)";
					if (act.interfaceName == "") act.interfaceName = "#Lang(600)";					
					act.description   = languagesProxy.used(objTypeVO.languages, 5, act.description,   "Actions."+ act.methodName +".Description");
					act.interfaceName = languagesProxy.used(objTypeVO.languages, 6, act.interfaceName, "Actions."+ act.methodName +".InterfaceName");
					for each (var parObj:Object in act.parameters)
					{
						var actPar:ActionParameterVO = parObj.data;
						if (actPar.interfaceName == "") actPar.interfaceName = "#Lang(700)";
						if (actPar.help          == "") actPar.help          = "#Lang(800)";
						actPar.interfaceName = languagesProxy.used(objTypeVO.languages, 7, actPar.interfaceName, "Actions.Parameter."+ actPar.scriptName +".InterfaceName");
						actPar.help			 = languagesProxy.used(objTypeVO.languages, 8, actPar.help, "Actions.Parameter."+ actPar.scriptName +".Help");
					}
				}
			}			
		}

		public function createXML( objTypeVO: ObjectTypeVO):XML
		{
			var objTypeXML:XML = getNewObjTypeXML(objTypeVO);

			objTypeXML.appendChild( attributesProxy.createXML(objTypeVO.attributes) );	
			objTypeXML.appendChild( languagesProxy.createXML(objTypeVO.languages) );
			objTypeXML.appendChild( resourcesProxy.toXML(objTypeVO.resources));
			objTypeXML.appendChild( sourceCodeToXML(objTypeVO.sourceCode) );
			objTypeXML.appendChild( librariesProxy.createXML(objTypeVO.libraries) );
			objTypeXML.appendChild( eventsProxy.createXML(objTypeVO.events) );//здесь важна последовательность!
			objTypeXML.E2vdom.appendChild( actionsProxy.createXML(objTypeVO.actionContainers) );

			return objTypeXML;
		}

		public function getObjectTypeVO(id:String):ObjectTypeVO
		{
			return _objectTypeList[id];
		}

		private function sourceCodeToXML(sourceCode:String):XML
		{				
			var sourceCodeXML:XML = <SourceCode/>;
			sourceCodeXML.appendChild( XML("\n"+"<![CDATA[" + sourceCode +"]]>") )
				
			return sourceCodeXML;
		}

		private function getNewObjTypeXML(objTypeVO : ObjectTypeVO):XML
		{
			var objTypeXML:XML = <Type/>;

			//save information
			var information:XML = <Information/>;

			information.Name 				= objTypeVO.name;
			information.DisplayName	 		= objTypeVO.displayName;	
			information.Description 		= objTypeVO.description;
			information.ClassName 			= objTypeVO.className;
			information.ID 					= objTypeVO.id;
			information.Icon				= objTypeVO.icon;
			information.EditorIcon			= objTypeVO.editorIcon;
			information.StructureIcon 		= objTypeVO.structureIcon;
			information.Moveable 			= (objTypeVO.moveable)? "1": "0";
			information.Resizable 			= objTypeVO.resizable;
			information.Container 			= objTypeVO.container;			
			information.Category 			= objTypeVO.category;
			information.Dynamic 			= (objTypeVO.dynamic)? "1": "0";
			information.Version 			= saveVertionType(objTypeVO);
			information.InterfaceType 		= objTypeVO.interfaceType;
			information.OptimizationPriority = objTypeVO.optimizationPriority;
			information.Containers			= objTypeVO.containers;
			information.Languages 			= getLanguagesName(objTypeVO);			
			
			// is top level container
			if (objTypeVO.container == 3)
			{
				information.RenderType			= objTypeVO.renderType;
				information.HTTPContentType		= objTypeVO.HTTPContentType;
			}
				
			information.Handlers 			= objTypeVO.handlers;			
			information.RemoteMethods		= objTypeVO.remoteMethods;
			information.WCAG 				= objTypeVO.wcag;
			information.XMLScriptName 		= objTypeVO.XMLScriptName;			

			objTypeXML.appendChild(information);

			return objTypeXML;
		}
		
		private function getLanguagesName(objVO:ObjectTypeVO): String
		{
			var ret: String = "";
			for each (var lang: Object in objVO.languages.locales)
			{
				ret += lang["data"] + " ,";
			}
			ret = ret.slice(0, ret.length-2);
			return ret;
		}

		public function initInformation(objTypeXML:XML):ObjectTypeVO
		{
			var objTypeVO: ObjectTypeVO = new ObjectTypeVO();
			var information: XML = objTypeXML.Information[0];			
			try
			{
				objTypeVO.category 		= information.Category;
				objTypeVO.className 	= information.ClassName;
				objTypeVO.container		= information.Container;
				objTypeVO.containers	= information.Containers;
//				checkLang(information.Description, objTypeVO.description );
//				checkLang(information.DisplayName, objTypeVO.displayName );
	
				objTypeVO.dynamic		= information.Dynamic.toString() == "1";
				objTypeVO.id			= information.ID;	
				objTypeVO.interfaceType	= information.InterfaceType;
				objTypeVO.handlers		= information.Handlers;
				objTypeVO.name 			= information.Name;
				objTypeVO.moveable		= information.Moveable.toString() == "1";
				objTypeVO.optimizationPriority = information.OptimizationPriority;						
//				objTypeVO.renderType	= information.RenderType;
				objTypeVO.resizable		= information.Resizable;				
				setVertionType(objTypeVO, information.Version);
				
				objTypeVO.wcag			= information.WCAG;
				objTypeVO.XMLScriptName = information.XMLScriptName;
				
				
				// is top level container
				if (objTypeVO.container	== 3 )
				{
					try
					{
						objTypeVO.renderType = information.RenderType;
					} 
					catch (error:Error)
					{
						ErrorLogger.instance.logError("Failed: not teg: <XMLScriptName/>", "initInformation");
						trace("Failed: not teg <XMLScriptName/>.", error.message);
					}
					
					try
					{
						objTypeVO.HTTPContentType = information.HTTPContentType;
					} 
					catch (error:Error)
					{
						ErrorLogger.instance.logError("Failed: not teg: <HTTPContentType/>", "initInformation");
						trace("Failed: not teg <HTTPContentType/>.", error.message);
					}
				}				
	
				objTypeVO.icon 			= information.Icon;
				objTypeVO.editorIcon 	= information.EditorIcon;
				objTypeVO.structureIcon = information.StructureIcon;
			}
			catch (error:Error)
			{
				ErrorLogger.instance.logError("Failed: not teg: <Information>", "initInformation");
				trace("Failed: not teg <Information/>.", error.message);
			}
			return objTypeVO;
		}
		
		private function setVertionType( objTypeVO:ObjectTypeVO, vertion:String ):void
		{
			var arr: Array = vertion.split( "." );
			if ( arr.length == 1 )
			{
				objTypeVO.majVersion = (vertion == "")? 1: int(vertion);			
			}
			else
			{
				objTypeVO.majVersion = arr[0];
				objTypeVO.minVersion = arr[1];
				objTypeVO.minServRevition = arr[2];	
			}
		}
		
		private function saveVertionType(objTypeVO:ObjectTypeVO ): String
		{
			return objTypeVO.majVersion + "." + 
					  (objTypeVO.minVersion++).toString() + "." + 
					  objTypeVO.minServRevition;
		} 

		public function removeVO(objTypeVO : ObjectTypeVO):void
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