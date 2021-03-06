/*
   Class ResoursesProxy is a wrapper over the Resourses
 */
package net.vdombox.object_editor.model.proxy.componentsProxy
{
	import flash.filesystem.File;
	import flash.filesystem.FileStream;
	import flash.net.FileReference;
	import flash.utils.ByteArray;
	
	import mx.collections.ArrayCollection;
	import mx.rpc.IResponder;
	import mx.utils.Base64Decoder;
	import mx.utils.Base64Encoder;
	import mx.utils.UIDUtil;
	
	import net.vdombox.object_editor.model.ErrorLogger;
	import net.vdombox.object_editor.model.proxy.FileProxy;
	import net.vdombox.object_editor.model.vo.ObjectTypeVO;
	import net.vdombox.object_editor.model.vo.ResourceVO;
	
	import org.puremvc.as3.interfaces.*;
	import org.puremvc.as3.patterns.proxy.Proxy;

	/**
	 *
	 * @author adelfos
	 */
	public class ResourcesProxy extends Proxy implements IProxy
	{
		/**
		 *
		 * @default
		 */
		public static const NAME:String = "ResoursesProxy";

		/**
		 *
		 * @param data
		 */
		public function ResourcesProxy ( data:Object = null ) 
		{
			super ( NAME, data );
		}

		/**
		 *
		 * @param objTypeXML
		 * @return
		 */
		public function createFromXML(objTypeXML:XML):ArrayCollection
		{
			var resourceVOArray : ArrayCollection = new ArrayCollection();
			try
			{
				var resourcesXML : XML =  objTypeXML.Resources[0];
	
				if (!resourcesXML) 
					resourcesXML = <Resources/>;
	
				for each (var resXML:XML in resourcesXML.children())
				{
					var resourceVO : ResourceVO =  createResFromXML(resXML);
					resourceVOArray.addItem(resourceVO);
	
					writeResoucetoFileSystem(resXML.@ID, resXML.toString()) 
				}			
			}		
			catch(error:TypeError)
			{	
				ErrorLogger.instance.logError("Failed: not teg: <Resources>", "ResourcesProxy.createFromXML()");
			}
			finally
			{
				return resourceVOArray;
			}
		}

		private function createResFromXML(resXML:XML):ResourceVO
		{
			return new ResourceVO(resXML.@ID, resXML.@Name, resXML.@Type );
		}

		/**
		 *
		 * @param fileRef
		 * @return
		 */
		public function createResFromFile(fileRef: FileReference):ResourceVO
		{
			var id:String = UIDUtil.createUID().toLowerCase();
			var base64Data:Base64Encoder = new Base64Encoder();
			
			base64Data.insertNewLines = false;
			base64Data.encodeBytes(fileRef.data);
			writeResoucetoFileSystem(id, base64Data.toString());

			return new ResourceVO(id, fileRef.name, fileRef.extension);
		}

		/**
		 *
		 * @param resVO
		 * @param fileRef
		 */
		public function changeContent(oldID : String, changeID : Boolean, fileRef: FileReference):ResourceVO
		{
			var id:String = changeID ? UIDUtil.createUID().toLowerCase() : oldID;
			var base64Data:Base64Encoder = new Base64Encoder();
			
			base64Data.insertNewLines = false;
			base64Data.encodeBytes(fileRef.data);

			writeResoucetoFileSystem(id, base64Data.toString());
			
			return new ResourceVO(id, fileRef.name, fileRef.extension);
			
			
			//sendNotification( ApplicationFacade.RESOURCE_CHANGED, {  } );
			
		}

		/**
		 *
		 * @param resVO
		 */
		public function exportToFile(resVO:ResourceVO):void
		{
			var fileUpload:FileReference = new FileReference();
			var b64:Base64Decoder = new Base64Decoder();

			b64.decode(readResouce(resVO.id));

			fileUpload.save( b64.toByteArray(), resVO.name );
		}


		public function getByteArray(idRes:String):ByteArray
		{
			var id : String = geResourseID(idRes);
			var b64:Base64Decoder = new Base64Decoder();

			trace(id, "\nb64: \n", readResouce(id));
			b64.decode(readResouce(id));
			//trace("\nb64: \n", b64);
			return  b64.toByteArray();
		}

		/**
		 *
		 * @param resVO
		 */
		public function deleteFile( resVO:ResourceVO ):void
		{
			locationById(resVO.id).deleteFile();
		}

		/**
		 *
		 * @param ressArr
		 * @return
		 */
		public function toXML(ressArr:ArrayCollection):XML
		{	
			var resourcesXML : XML = <Resources/>;

			for each (var resVO:ResourceVO in ressArr)
			{
				var resXML : XML = <Resource/>;
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

		public function geResourseID(value:String):String
		{
			var phraseRE:RegExp = /^(?:#Res\(([-a-zA-Z0-9]*)\))|(?:([-a-zA-Z0-9]*))/;

			var imgResourseID:String = "";
			var matchResult : Array = value.match( phraseRE );
			if (matchResult)
			{
				imgResourseID = matchResult[1]
					//				trace("imgResourseID: "+imgResourseID);
			}
			//todo должен быть id в любом случае!!!!!!!!!!!!!
			if 	(imgResourseID == null) imgResourseID = "";
			return imgResourseID;
		}
		
		public function geIconByID(value:String):String
		{
			return "#Res(" + value + ")";
		}
	}
}