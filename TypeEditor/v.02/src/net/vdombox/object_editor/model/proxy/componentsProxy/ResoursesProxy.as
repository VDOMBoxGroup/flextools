/*
   Class ResoursesProxy is a wrapper over the Resourses
 */
package net.vdombox.object_editor.model.proxy.componentsProxy
{
	import flash.filesystem.File;
	import flash.filesystem.FileStream;
	import flash.net.dns.AAAARecord;

	import mx.collections.ArrayCollection;
	import mx.rpc.IResponder;

	import net.vdombox.object_editor.model.proxy.FileProxy;
	import net.vdombox.object_editor.model.vo.ObjectTypeVO;
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
				var resourceVO : ResourceVO =  createNewVO(resXML);
				resourceVOArray.addItem(resourceVO);
			}	

			return resourceVOArray;
		}

		private function createNewVO(resXML:XML):ResourceVO
		{
			var  resourceVO : ResourceVO = new ResourceVO();

			resourceVO.id = resXML.@ID;
			resourceVO.name = resXML.@Name;
			resourceVO.type = resXML.@Type;

			// TODO: save data to filesystem
			var location:File = File.applicationStorageDirectory.resolvePath("resources/"+resourceVO.id);
			var fileProxy:FileProxy = facade.retrieveProxy(FileProxy.NAME) as FileProxy;

			fileProxy.saveFile(resXML.toString(),  location.nativePath);

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

		public function toXML(objTypeVO:ObjectTypeVO):XML
		{	
			var resourcesXML : XML = new XML("<Resources/>");

			for each(var resVO:ResourceVO in objTypeVO.resourses)
			{
				var resXML : XML = new XML("<Resource/>");
				resXML.@Name = resVO.name;
				resXML.@Type = resVO.type;

				var location:File = File.applicationStorageDirectory.resolvePath("resources/"+resVO.id);
				var fileProxy:FileProxy = facade.retrieveProxy(FileProxy.NAME) as FileProxy;

				var resDataStr : String =  fileProxy.readFile(location.nativePath);
				var resDataXML : XML = new XML("\n"+"<![CDATA[" +  resDataStr +"]" +"]" +">") ;
				resXML.appendChild(resDataXML)

				resourcesXML.appendChild(resXML);
			}

			return resourcesXML;
		}


	}
}


