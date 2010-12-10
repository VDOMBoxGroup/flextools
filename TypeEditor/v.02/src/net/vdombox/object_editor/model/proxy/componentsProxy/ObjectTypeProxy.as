/*
   Class ObjectTypeVOProxy is a wrapper over the ObjectTypeVO
 */
package net.vdombox.object_editor.model.proxy.componentsProxy
{
	import net.vdombox.object_editor.model.vo.AttributeVO;
	import net.vdombox.object_editor.model.vo.ObjectTypeVO;
	import net.vdombox.object_editor.view.essence.Atributes;

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

		public function newObjectTypeVO(xml:XML):void
		{	
			trace("newObjectTypeVO");
			var objType: ObjectTypeVO = new ObjectTypeVO;
			//information
			var information: XML = xml.Information[0];


			if (_objectTypeList[information.ID])
			{
				facade.sendNotification( ApplicationFacade.OBJECT_EXIST, information.ID.toString() );
			}else
			{				

				objType.name 		= information.Name;
				objType.category 	= information.Category;
				objType.className 	= information.ClassName;
				objType.id		 	= information.ID;			
				objType.dynamic		= information.Dynamic.toString() == "1";
				objType.moveable	= information.Moveable.toString() == "1";			
				objType.resizable	= information.Resizable;	
				objType.container	= information.Container;	
				objType.version		= information.Version;	
				objType.interfaceType	= information.InterfaceType;	
				objType.optimizationPriority = information.OptimizationPriority;	
				//sourceCode
				objType.sourceCode	= xml.SourceCode.toString();
				//atributes

				//			_data =  xml.descendants("Information")[0];
				//			if (!_data) _data = new XML("<Information/>");

				//			var count:uint = 
				for each ( var data : XML in xml.descendants("Attribute"))  //xml.descendants("Attributes") )
				{
					var atrib:AttributeVO = new AttributeVO;

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

					objType.atributes
				}
				_objectTypeList[objType.id] = objType;

				facade.sendNotification( ApplicationFacade.OBJECT_COMPLIT, objType );
			}


		}

		public function getObjectTypeVO(id:String):ObjectTypeVO
		{
			return _objectTypeList[id];
		}

//		public function newEvent( guid:uint ):Boolean
//		{
//			 
//		}
//		
//		public function getEvents( guid:uint ):Array
//		{
//			return 
//		}

	}
}

