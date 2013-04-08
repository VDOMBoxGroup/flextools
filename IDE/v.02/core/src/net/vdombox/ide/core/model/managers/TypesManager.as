package net.vdombox.ide.core.model.managers
{
	import flash.errors.IOError;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;

	import net.vdombox.ide.common.model._vo.TypeVO;
	import net.vdombox.ide.core.model.vo.AuthInfoVO;

	public class TypesManager
	{
		private static var instance : TypesManager;

		private var mainFolder : String = "types";

		private var typesFolder : File;

		private var serverTypes : File;

		private var fileType : File;

		private var fileStream : FileStream = new FileStream();

		private var hostName : Array;

		public static function getInstance() : TypesManager
		{
			if ( !instance )
				instance = new TypesManager();

			return instance;
		}

		public function TypesManager()
		{
			if ( instance )
				throw new Error( "Instance already exists." );

			init();
		}

		public function init() : void
		{
			typesFolder = File.applicationStorageDirectory.resolvePath( mainFolder );

			if ( !typesFolder.exists )
			{
				typesFolder.createDirectory();
				return;
			}
		}

		public function hasServer( serverInfo : AuthInfoVO ) : Boolean
		{
			hostName = serverInfo.hostname.split( ":" );

			serverTypes = typesFolder.resolvePath( hostName[ 0 ] as String );
			if ( !serverTypes.exists )
				return false;

			if ( hostName.length == 1 )
				hostName.push( "80" );

			serverTypes = serverTypes.resolvePath( hostName[ 1 ] as String );
			if ( !serverTypes.exists )
				return false;

			serverTypes = serverTypes.resolvePath( "info" );
			if ( !serverTypes.exists )
				return false;

			try
			{
				fileStream.open( serverTypes, FileMode.READ );
				var strVersion : String = fileStream.readUTFBytes( fileStream.bytesAvailable );
				fileStream.close();
			}
			catch ( error : IOError )
			{
				return false;
			}

			if ( strVersion != serverInfo.serverVersion )
				return false;

			return true;
		}

		public function setType( serverInfo : AuthInfoVO, typeXML : XML ) : void
		{
			hostName = serverInfo.hostname.split( ":" );

			serverTypes = typesFolder.resolvePath( hostName[ 0 ] as String );
			if ( !serverTypes.exists )
				serverTypes.createDirectory();

			if ( hostName.length == 1 )
				hostName.push( "80" );

			serverTypes = serverTypes.resolvePath( hostName[ 1 ] as String );
			if ( !serverTypes.exists )
				serverTypes.createDirectory();

			fileType = serverTypes.resolvePath( typeXML.Information.ID.toString() );

			try
			{
				fileStream.open( fileType, FileMode.WRITE );
				fileStream.writeUTFBytes( typeXML.toXMLString() );
				fileStream.close();
			}
			catch ( error : IOError )
			{

				return;
			}
		}

		public function setTypes( serverInfo : AuthInfoVO, typesXML : XML ) : void
		{
			hostName = serverInfo.hostname.split( ":" );

			serverTypes = typesFolder.resolvePath( hostName[ 0 ] as String );
			if ( !serverTypes.exists )
				serverTypes.createDirectory();

			if ( hostName.length == 1 )
				hostName.push( "80" );

			serverTypes = serverTypes.resolvePath( hostName[ 1 ] as String );
			if ( !serverTypes.exists )
				serverTypes.createDirectory();

			fileType = serverTypes.resolvePath( "info" );

			try
			{
				fileStream.open( fileType, FileMode.WRITE );
				fileStream.writeUTFBytes( serverInfo.serverVersion );
				fileStream.close();
			}
			catch ( error : IOError )
			{
				////trace("setTypes ERROR");

				return;
			}



			for each ( var type : XML in typesXML.* )
			{
				fileType = serverTypes.resolvePath( type.Information.ID.toString() );
				try
				{
					fileStream.open( fileType, FileMode.WRITE );
					fileStream.writeUTFBytes( type.toXMLString() );
					fileStream.close();
				}
				catch ( error : IOError )
				{
					////trace("setTypes2 ERROR");
					continue;
				}
			}
		}

		public function getTypes( serverInfo : AuthInfoVO, typesXML : XML ) : Array
		{
			var typesVO : Array = new Array();
			var typeVO : TypeVO;

			hostName = serverInfo.hostname.split( ":" );

			serverTypes = typesFolder.resolvePath( hostName[ 0 ] as String );

			if ( hostName.length == 1 )
				hostName.push( "80" );

			serverTypes = serverTypes.resolvePath( hostName[ 1 ] as String );

			var _types : Object = [];

			for each ( var type : XML in typesXML.* )
			{
				_types[ type.@id ] = 1;
			}

			var fileList : Array = serverTypes.getDirectoryListing();
			for each ( var file : File in fileList )
			{
				if ( !_types.hasOwnProperty( file.name ) && file.name != "info" )
				{
					file.deleteFileAsync();
					continue;
				}

				fileStream.open( file, FileMode.READ );
				typeVO = new TypeVO( new XML( fileStream.readUTFBytes( fileStream.bytesAvailable ) ) );
				fileStream.close();

				typesVO.push( typeVO );
			}

			return typesVO;
		}
	}
}
