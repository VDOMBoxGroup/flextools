/*
   Class ResoursesProxy is a wrapper over the Resourses
 */
package net.vdombox.object_editor.model.proxy.componentsProxy
{
	import flash.net.dns.AAAARecord;

	import mx.collections.ArrayCollection;
	import mx.rpc.IResponder;

	import net.vdombox.object_editor.model.vo.ResourceVO;

	import org.puremvc.as3.interfaces.*;
	import org.puremvc.as3.patterns.proxy.Proxy;

	public class ResoursesProxy extends Proxy implements IProxy
	{
		public static const NAME:String = "ResoursesProxy";

		public function ResoursesProxy ( data:Object = null ) 
		{
			super ( NAME, data );
		}


		public function createFromXML(objTypeXML:XML):ArrayCollection
		{
			var resourceVOArray : ArrayCollection = new ArrayCollection();
			var resourcesXML : XML =  objTypeXML.Resources[0];

			if (!resourcesXML) 
				resourcesXML = new XML("<Resources/>");

			for each(var resXML:XML in resourcesXML.children())
			{
				var resourceVO : ResourceVO =  createNew(resXML);
				resourceVOArray.addItem(resourceVO);
			}	

			return resourceVOArray;
		}

		private function createNew(resXML:XML):ResourceVO
		{
			var  resourceVO : ResourceVO = new ResourceVO();

			resourceVO.id = resXML.@ID;
			resourceVO.name = resXML.@Name;
			resourceVO.type = resXML.@Type;

			// TODO: save data to filesystem

			return resourceVO;
		}


		public function changeContent():void
		{

		}

		public function exportToFile():void
		{

		}

		public function deleteFile():void
		{

		}

		public function toXML(resourceArrayCollection:ArrayCollection):XML
		{	
			var resourcesXML : XML = new XML("<Resources/>");

			return resourcesXML;
		}


	}
}


