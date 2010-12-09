/*
	Class ObjectTypeVOProxy is a wrapper over the ObjectTypeVO
 */
package net.vdombox.object_editor.model.proxy.componentsProxy
{
	
	
	import net.vdombox.object_editor.model.vo.ObjectTypeVO;
	
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
		
		public function newObjectTypeVO(xml:XML):ObjectTypeVO
		{				
			var objType: ObjectTypeVO = new ObjectTypeVO;
			var information: XML = xml.Information[0];
			objType.name 		= information.Name;
			objType.category 	= information.Category;
			objType.className 	= information.ClassName;
			objType.id		 	= information.ID;			
			objType.dynamic		= information.Dynamic.toString() == "1";
			objType.moveable	= information.Moveable.toString() == "1";
			//исправить
			objType.resizable	= information.Resizable;	
			objType.container	= information.Container;	
			objType.version		= information.Version;	
			objType.interfaceType	= information.InterfaceType;	
			objType.optimizationPriority	= information.OptimizationPriority;	
			
			
			
			objType.sourceCode	= xml.SourceCode;
			
			_objectTypeList[objType.id] = objType;
			return objType;
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