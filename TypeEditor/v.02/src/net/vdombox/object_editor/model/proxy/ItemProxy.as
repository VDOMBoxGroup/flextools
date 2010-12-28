/*
   A proxy for the Item data
 */
package net.vdombox.object_editor.model.proxy
{
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;

	import net.vdombox.object_editor.model.Item;

	import org.puremvc.as3.interfaces.*;
	import org.puremvc.as3.patterns.proxy.Proxy;

	public class ItemProxy extends Proxy implements IProxy
	{
		public static const NAME:String = "ItemProxy";

		public function ItemProxy ( data:Object = null ) 
		{
			super ( NAME, data );
		}

		public function getItem( file:File ):Item
		{
			var stream:FileStream = new FileStream();   
			stream.open(file, FileMode.READ);

			var data:String = stream.readUTFBytes(stream.bytesAvailable);
			var objectXML:XML = new XML(data);	

			var informationXML  : XML = objectXML.Information[0];
			var langEnXML 		: XML = objectXML.Languages.Language.(@Code == "en_US")[0];
			var imgResourseID:String =  getImgResourseID(informationXML);

			var item:Item = new Item;

			var contType : String = informationXML.Container.toString()
			if (contType != "3") // is not TopLave container
			{
				var categoryXML : String = informationXML.Category.toString();
				var categoryStr : String = getRegExpWord(categoryXML);
				if(categoryStr == "")
					item.groupName = categoryXML;
				else
					item.groupName =  langEnXML.Sentence.(@ID == categoryStr)[0].toString();
			}
			else
			{
				item.groupName = "Top Level Containers";
			}

			item.label = informationXML.Name.toString();
			item.img = getImgResourse(objectXML, imgResourseID);
			item.path  = file.nativePath;// or .url

			stream.close();	
			objectXML = null;
			return item;			
		}

		private function getImgResourseID(information:XML):String
		{
			var iconValue:String  = information.StructureIcon.toString();
			var phraseRE:RegExp = /^(?:#Res\(([-a-zA-Z0-9]*)\))|(?:([-a-zA-Z0-9]*))/;

			var imgResourseID:String = "";
			var matchResult : Array = iconValue.match( phraseRE );
			if (matchResult)
			{
				imgResourseID = matchResult[1]
//				trace("imgResourseID: "+imgResourseID);
			}
			return imgResourseID;
		}

		private function getRegExpWord( code:String ):String
		{	
			var  regResource:RegExp = /#Lang\((\d+)\)/;
			var matchResult:Array = code.match(regResource);			
			if (matchResult)
			{
				return matchResult[1];
			}
			return "";
		}

		private function getImgResourse(objectXML:XML, imgResourseID:String):String
		{
			var imgResourse:String = "";
			var resource: XML = objectXML.Resources.Resource.(@ID == imgResourseID)[0];	
			if (resource) 
			{
				imgResourse =  resource.toString();
			}
			else
			{
				trace("resource: " +imgResourseID+" not found!");
			}			
			return imgResourse;
		}

//		public function get item():Item
//		{
//			return item as Item;
//		}

	}
}

