/*
   Class ResoursesProxy is a wrapper over the Resourses
 */
package net.vdombox.object_editor.model.proxy.componentsProxy
{
	import flash.filesystem.File;
	import flash.filesystem.FileStream;
	import flash.net.FileReference;
	import flash.net.dns.AAAARecord;

	import mx.collections.ArrayCollection;
	import mx.rpc.IResponder;
	import mx.utils.Base64Decoder;
	import mx.utils.Base64Encoder;
	import mx.utils.UIDUtil;

	import net.vdombox.object_editor.model.proxy.FileProxy;
	import net.vdombox.object_editor.model.vo.ObjectTypeVO;
	import net.vdombox.object_editor.model.vo.ResourceVO;

	import org.puremvc.as3.interfaces.*;
	import org.puremvc.as3.patterns.proxy.Proxy;

	public class ResourcesProxy extends Proxy implements IProxy
	{
		public static const NAME:String = "ResoursesProxy";

		public function ResourcesProxy ( data:Object = null ) 
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
				var resourceVO : ResourceVO =  createResFromXML(resXML);
				resourceVOArray.addItem(resourceVO);

				writeResoucetoFileSystem(resXML.@ID, resXML.toString()) 
			}	

			return resourceVOArray;
		}

		private function createResFromXML(resXML:XML):ResourceVO
		{
			return new ResourceVO(resXML.@ID, resXML.@Name, resXML.@Type );
		}



		public function createResFromFile(fileRef: FileReference):ResourceVO
		{
			var id:String = UIDUtil.createUID().toLowerCase();
			var b64:Base64Encoder = new Base64Encoder();

			b64.encodeBytes(fileRef.data);
			writeResoucetoFileSystem(id, b64.toString());

			return new ResourceVO(id, fileRef.name, fileRef.extension);
		}


		public function changeContent(resVO:ResourceVO, fileRef: FileReference):void
		{
			var b64:Base64Encoder = new Base64Encoder();
			b64.encodeBytes(fileRef.data);

			writeResoucetoFileSystem(resVO.id, b64.toString());
		}

		public function exportToFile(resVO:ResourceVO):void
		{
			var fileUpload:FileReference = new FileReference();
			var b64:Base64Decoder = new Base64Decoder();

			b64.decode(readResouce(resVO.id));

			fileUpload.save( b64.toByteArray(), resVO.name );
		}

		public function deleteFile( resVO:ResourceVO ):void
		{
			locationById(resVO.id).deleteFile();
		}

		public function toXML(ressArr:ArrayCollection):XML
		{	
			var resourcesXML : XML = new XML("<Resources/>");

			for each(var resVO:ResourceVO in ressArr)
			{
				var resXML : XML = new XML("<Resource/>");
				var resDataXML : XML = new XML("\n"+"<![CDATA[" +  readResouce(resVO.id) +"]" +"]" +">") ;

				resXML.@ID = resVO.id;
				resXML.@Name = resVO.name;
				resXML.@Type = resVO.type;
				resXML.appendChild(resDataXML)

				resourcesXML.appendChild(resXML);
			}
			return resourcesXML;
		}

		private function  locationById(id:String):File
		{
			return File.applicationStorageDirectory.resolvePath("resources/"+id);
		}


		private function  readResouce(id:String):String
		{
			var fileProxy:FileProxy = facade.retrieveProxy(FileProxy.NAME) as FileProxy;
			var nativePath : String = locationById(id).nativePath;

			return  fileProxy.readFile(nativePath);
		}


		private function writeResoucetoFileSystem(id:String, dataInBase64:String):void
		{
			var fileProxy:FileProxy = facade.retrieveProxy(FileProxy.NAME) as FileProxy;
			var nativePath : String = locationById(id).nativePath;

			fileProxy.saveFile(dataInBase64,  nativePath);
		}


	}
}


