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
//TODO: delete
			objType.data = xml; 			
			objType.information = objType.data.Information;
			
			objType.name 		= objType.data.Information.Name//xml.Type.Information.Name;
			objType.category 	= objType.information.Category;
			objType.className 	= objType.information.ClassName;
			objType.id		 	= objType.information.ID;
			
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