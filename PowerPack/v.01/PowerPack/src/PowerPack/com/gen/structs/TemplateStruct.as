package PowerPack.com.gen.structs
{
	import ExtendedAPI.com.utils.FileToBase64;
	import ExtendedAPI.com.utils.FileUtils;
	import ExtendedAPI.com.utils.Utils;
	
	import PowerPack.com.utils.CryptUtils;
	
	import flash.filesystem.File;
	import flash.utils.ByteArray;
	
	import mx.utils.Base64Decoder;
	import mx.utils.Base64Encoder;
	
	public class TemplateStruct
	{
		[Bindable]
		public var xmlTemplate:XML;
		
		[Bindable]
		public var key:String;
		
		[Bindable]
		public var picturePath:String;		
		
		public function TemplateStruct(xml:XML=null)
		{
			if(xml)
				this.xml = xml;
			else
				this.xml = new XML(<template></template>);
		}

		private var _xml:XML;		
		public function get xml():XML
		{
			return _xml;
		}
		public function set xml(value:XML):void
		{
			_xml = value;
		}
		
		[Bindable]
		public function get name():String
		{
			return Utils.getStringOrDefault(_xml.@name, '');	
		}		
		public function set name(value:String):void
		{
			_xml.@name = value;	
		}		

		[Bindable]
		public function get description():String
		{
			return Utils.getStringOrDefault(_xml.description, '');	
		}		
		public function set description(value:String):void
		{
			_xml.description = value;	
		}		
		
		[Bindable]
		public function get picture():String
		{
			return Utils.getStringOrDefault(_xml.picture[0], '');	
		}		
		public function set picture(value:String):void
		{
			_xml.picture = value;	
		}	
		
		public function get isEncoded():Boolean
		{
			return _xml.hasOwnProperty('encoded');	
		}		

		public function encode():void
		{
			delete _xml.encoded;
			delete _xml.structure;
			
			if(key)
			{
				var bytes:ByteArray = CryptUtils.encrypt(xmlTemplate.toXMLString(), key);
				
				var encoder:Base64Encoder = new Base64Encoder();
			    encoder.encodeBytes(bytes);
			    _xml.encoded = encoder.flush();
			}
			else
				_xml.structure = xmlTemplate;
		}
		
		public function decode():void
		{
			xmlTemplate = null;
			
			if(isEncoded && key)
			{			
				try {	
					var strEncoded:String = _xml.encoded[0]; 
			 		var strDecoded:String;
			 	
					var decoder:Base64Decoder = new Base64Decoder();
				    decoder.decode(strEncoded);				
					var bytes:ByteArray = decoder.flush();	
				
					bytes = CryptUtils.decrypt(bytes, key);	
					bytes.position = 0;
					strDecoded = bytes.readUTFBytes(bytes.length);
				 	xmlTemplate = XML(strDecoded);
				 	
					if(xmlTemplate)
				 		if(xmlTemplate.name().localName!='structure')
				 			xmlTemplate = null;				 	
				 	
				} catch(e:*) {
					xmlTemplate = null;
				}				
			}	
			else if(_xml.hasOwnProperty('structure'))
				xmlTemplate = _xml.structure[0];
		}
		
		public function loadPicture():void
		{
			if(!picturePath || !FileUtils.isValidPath(picturePath))
			{
				//throw new BasicError("Not valid filename");
				return;
			}
		
			var file:File = new File();
			file.url = FileUtils.pathToUrl(picturePath);
		
			if(!file.exists)
			{
				//throw new BasicError("File does not exists");
				return;
			}
			
			var fileToBase64:FileToBase64 = new FileToBase64(file.nativePath);
			fileToBase64.convert();						
			picture = fileToBase64.data.toString();
		}

	}
}