package PowerPack.com
{
	import ExtendedAPI.com.utils.FileToBase64;
	import ExtendedAPI.com.utils.FileUtils;
	import ExtendedAPI.com.utils.Utils;
	
	import PowerPack.com.utils.CryptUtils;
	
	import flash.filesystem.File;
	import flash.utils.ByteArray;
	
	import mx.utils.Base64Decoder;
	import mx.utils.Base64Encoder;
	import mx.utils.UIDUtil;
	
	public class Template
	{
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 *	Constructor
		 */ 
		public function Template(xml:XML=null)
		{
			if(xml)
			{
				_xml = xml;
				if(!Utils.getStringOrDefault(_xml.@ID, ''))
					_xml.@ID = UIDUtil.createUID();	
			}
			else
			{
				_xml = new XML(<template/>);
				_xml.@ID = UIDUtil.createUID();
			}
		}

	    //--------------------------------------------------------------------------
	    //
	    //  Variables
	    //
	    //--------------------------------------------------------------------------  
		
		[Bindable]
		public var key:String;
		
		[Bindable]
		public var modified:Boolean;
		
		[Bindable]
		public var picturePath:String;
		
		[Bindable]
		public var file:File;	

	    //--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------
	    
	    //----------------------------------
	    //  xml
	    //----------------------------------
	    
		private var _xml:XML;
				
		public function get xml():XML
		{
			return _xml;
		}

	    //----------------------------------
	    //  xmlStructure
	    //----------------------------------

		private var _xmlStructure:XML;
		
		[Bindable]
		public function set xmlStructure(value:XML):void
		{
			if(_xmlStructure!=value)
			{
				_xmlStructure=value;		
			}
		}
		public function get xmlStructure():XML
		{
			if(!_xmlStructure)
				decode();
			return _xmlStructure;
		}		
				
	    //----------------------------------
	    //  name
	    //----------------------------------

		[Bindable]
		public function set name(value:String):void
		{
			if(_xml.name != value)
				_xml.name = value;	
		}		
		public function get name():String
		{
			return Utils.getStringOrDefault(_xml.name, '');	
		}		

	    //----------------------------------
	    //  description
	    //----------------------------------

		[Bindable]
		public function set description(value:String):void
		{
			if(_xml.description != value)
				_xml.description = value;	
		}		
		public function get description():String
		{
			return Utils.getStringOrDefault(_xml.description, '');	
		}		
		
	    //----------------------------------
	    //  ID
	    //----------------------------------

		public function get ID():String
		{
			return _xml.@ID;	
		}		

	    //----------------------------------
	    //  b64picture
	    //----------------------------------

		[Bindable]
		public function set b64picture(value:String):void
		{
			if(_xml.picture != value)
				_xml.picture = value;	
		}	
		public function get b64picture():String
		{
			return Utils.getStringOrDefault(_xml.picture[0], '');	
		}		
		
	    //----------------------------------
	    //  isEncoded
	    //----------------------------------

		public function get isEncoded():Boolean
		{
			return _xml.hasOwnProperty('encoded');	
		}		

		//--------------------------------------------------------------------------
		//
		//  Class methods
		//
		//--------------------------------------------------------------------------
		
		public function save():void
		{
			
		}
		
		
		public function saveAs():void
		{
			
		}
		
		public function open():void
		{
			
		}

		public function encode():void
		{
			delete _xml.encoded;
			delete _xml.structure;
			
			if(key)
			{
				var bytes:ByteArray = CryptUtils.encrypt(_xmlStructure.toXMLString(), key);
				
				var encoder:Base64Encoder = new Base64Encoder();
			    encoder.encodeBytes(bytes);
			    _xml.encoded = encoder.flush();
			}
			else
				_xml.structure = _xmlStructure;
		}
		
		public function decode():void
		{
			_xmlStructure = null;
			
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
				 	_xmlStructure = XML(strDecoded);
				 	
					if(_xmlStructure)
				 		if(_xmlStructure.name().localName!='structure')
				 			_xmlStructure = null;				 	
				 	
				} catch(e:*) {
					_xmlStructure = null;
				}				
			}	
			else if(_xml.hasOwnProperty('structure'))
				_xmlStructure = _xml.structure[0];
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
			b64picture = fileToBase64.data.toString();
		}

	}
}