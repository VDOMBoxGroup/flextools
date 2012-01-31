package net.vdombox.utils
{
	
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;

	public final class FileUtils
	{
		public static function readUTFBytesFromFile( file : File ) : String
		{
			var stream : FileStream = new FileStream();
			stream.open( file, FileMode.READ );

			var result : String = stream.readUTFBytes( stream.bytesAvailable );
			stream.close();

			return result;
		}

		public static function readByteArrayFromFile( file : File ) : ByteArray
		{
			var stream : FileStream = new FileStream();
			stream.open( file, FileMode.READ );

			var result : ByteArray = new ByteArray();
			stream.readBytes( result, 0, file.size );
			stream.close();

			return result;
		}

		public static function readXMLFromFile( file : File ) : XML
		{
			// FIXME: This isn't really correct because only an XML parser can properly
			// figure out the actual encoding of the XML file being read--that information
			// is embeded in the XML declaration itself. However, the limitations of the XML
			// API are currently such that that can't be done. So, this for now.

			return new XML( readByteArrayFromFile( file ).toString() );
		}

		public static function saveXMLToFile( xml : XML, file : File ) : void
		{
			var stream : FileStream = new FileStream();
			stream.open( file, FileMode.WRITE );

			XML.prettyIndent = 4;
			var XMLString : String = xml.toXMLString();
			XMLString = XMLString.replace( /[ ]{4}/xg, "\t" );

			stream.writeUTFBytes( "<?xml version=\"1.0\" encoding=\"utf-8\"?>\r" );
			stream.writeUTFBytes( XMLString );
			stream.close();
		}

		public static function getFilenameFromURL( url : String ) : String
		{
			var idx : int = url.lastIndexOf( "/" );
			if ( idx == -1 )
			{
				return "";
			}
			return url.substr( idx + 1 );
		}

		public static function deleteFile( file : File ) : void
		{
			if ( !file.exists )
				return;
			if ( file.isDirectory )
				return;
			try
			{
				file.deleteFile();
			}
			catch ( e : Error )
			{
			}
		}

		public static function deleteFolder( file : File ) : void
		{
			if ( !file.exists )
				return;
			if ( !file.isDirectory )
				return;
			try
			{
				file.deleteDirectory( false );
			}
			catch ( e : Error )
			{
			}
		}
	}
}