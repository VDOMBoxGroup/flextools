/*
   A proxy for the Item data
 */
package net.vdombox.object_editor.model.proxy
{
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	
	import mx.collections.ArrayCollection;
	
	import net.vdombox.object_editor.model.ErrorLogger;
	import net.vdombox.object_editor.model.Item;
	
	import org.puremvc.as3.interfaces.*;
	import org.puremvc.as3.patterns.proxy.Proxy;

	public class ObjectsProxy extends Proxy implements IProxy
	{
		public static const NAME:String = "ObjectsProxy";
		public var topLevelContainerList:ArrayCollection = new ArrayCollection();
		public var containerList:ArrayCollection = new ArrayCollection();
		private var _categorys:Array = [];


		public function ObjectsProxy ( data:Object = null ) 
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
			var listItem : Object = {label:informationXML.Name.toString(), data:informationXML.ID.toString()};	
			if (contType != "3") // is not TopLave container
			{
				var categoryXML : String = informationXML.Category.toString();
				var categoryStr : String = getRegExpWord(categoryXML);
				if(categoryStr == "")
				{
					item.groupName = categoryXML;
					_categorys[categoryXML] = categoryXML ;
				}
				else
				{
					item.groupName =  langEnXML.Sentence.(@ID == categoryStr)[0].toString();
				}

				if (contType == "2") // container
					containerList.addItem(listItem);
			}
			else
			{
				item.groupName = "Top Level Containers";
				//arrayCollection for ComboBox in actions tab
				topLevelContainerList.addItem(listItem);
				containerList.addItem(listItem);
			}

			item.label = informationXML.Name.toString();
			item.img = getImgResourse(objectXML, imgResourseID);
			item.path  = file.nativePath;// or .url

			stream.close();	
			objectXML = null;
			return item;			
		}

		public function get categorys():ArrayCollection
		{
			var arr: ArrayCollection = new ArrayCollection();
			for (var i:String in _categorys)
				arr.addItem(i);
			return arr;
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
				return matchResult[1];

			return "";
		}

		private function getImgResourse(objectXML:XML, imgResourseID:String):String
		{
			var imgResourse:String = "";
			var resource: XML = objectXML.Resources.Resource.(@ID == imgResourseID)[0];	
			if (resource) 
				imgResourse = resource.toString();
			else
			{
				ErrorLogger.instance.logError("resource: " +imgResourseID+" not found!", "ObjectsProxy.getImgResourse()");
				trace("resource: " +imgResourseID+" not found!");
			}
			return imgResourse;
		}
	}
}