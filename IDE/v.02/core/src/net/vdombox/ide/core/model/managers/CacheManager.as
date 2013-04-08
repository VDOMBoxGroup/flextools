package net.vdombox.ide.core.model.managers
{
	import flash.errors.IOError;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;

	import mx.collections.ArrayCollection;
	import mx.collections.IViewCursor;
	import mx.collections.Sort;
	import mx.collections.SortField;

	public class CacheManager
	{

		private static var instance : CacheManager;

		/**
		 *
		 * @return
		 */
		public static function getInstance() : CacheManager
		{
			if ( !instance )
				instance = new CacheManager();

			return instance;
		}

		/**
		 *
		 * @throws Error
		 */
		public function CacheManager()
		{
			if ( instance )
				throw new Error( "Instance already exists." );

			init();
		}

		private const CACHE_SIZE : uint = 150000000;

		private var applicationId : String;

		private var cacheFolder : File;

		private var cacheSize : int;

		private var cachedFiles : ArrayCollection = new ArrayCollection();

		private var cursor : IViewCursor;

		private var fileStream : FileStream = new FileStream();

		/**
		 *
		 * @param contentName
		 * @param content
		 */
		public function cacheFile( contentName : String, content : ByteArray ) : void
		{

			var fileSize : uint = content.bytesAvailable;

			if ( fileSize > 10000000 )
				return;

			var newFileName : String = contentName;

			if ( cursor.findAny( { name: applicationPrefix + "" + contentName } ) )
			{

				cacheSize -= cursor.current.size;
				cursor.remove();

				try
				{
					cacheFolder.resolvePath( newFileName ).deleteFile();
				}
				catch ( error : IOError )
				{
					return;
				}
			}

			cleanupCache( fileSize );

			var newFile : File = cacheFolder.resolvePath( newFileName );

			try
			{

				fileStream.open( newFile, FileMode.WRITE );
				fileStream.writeBytes( content );
				fileStream.close();

			}
			catch ( error : IOError )
			{

				return;
			}

			cachedFiles.addItem( { create: newFile.creationDate.time, name: newFile.name, size: newFile.size } )
		}

		/**
		 *
		 * @param fileName
		 * @return
		 */
		public function deleteFile( fileName : String ) : Boolean
		{
			var isDone : Boolean = false;

			fileName = applicationPrefix + fileName;

			var isFind : Boolean = cursor.findAny( { name: fileName } )

			if ( isFind )
			{

				cacheSize -= cursor.current.size;
				cursor.remove();

				try
				{
					cacheFolder.resolvePath( fileName ).deleteFile();
					isDone = true
				}
				catch ( error : Error )
				{
				}
			}

			return isDone;
		}

		/**
		 *
		 * @param resourceId
		 * @return
		 */
		public function getCachedFileById( resourceId : String ) : ByteArray
		{

			var fileName : String = resourceId;

			var result : Boolean = cursor.findFirst( { name: fileName } );

			if ( result )
			{

				var file : File = cacheFolder.resolvePath( fileName );
				var fileBytes : ByteArray = new ByteArray();

				fileStream.open( file, FileMode.READ );
				fileStream.readBytes( fileBytes );
				fileStream.close();

				return fileBytes;
			}
			else
				return null;
		}

		/**
		 *
		 */
		public function init() : void
		{
			cursor = cachedFiles.createCursor();

			cachedFiles.sort = new Sort();
			cachedFiles.sort.fields = [ new SortField( "name" ) ];
			cachedFiles.refresh();

			cacheFolder = File.applicationStorageDirectory.resolvePath( "cache" );

			if ( !cacheFolder.exists )
			{
				cacheFolder.createDirectory();
				return;
			}

			sortCache();
		}


		private function get applicationPrefix() : String
		{

			if ( applicationId )
				return applicationId.substr( 0, 8 );
			else
				return "";
		}

		private function sortCache() : void
		{
			var currentDate : Number = new Date().getTime();
			var fileList : Array = cacheFolder.getDirectoryListing();
			var file : File;

			for each ( file in fileList )
			{

				/*
				   var days : Number = ( currentDate - file.creationDate.time ) / 1000 / 60 / 60 / 24;

				   if ( days > 17 )
				   {
				   file.deleteFile();
				   continue;
				   }
				 */

				cacheSize += file.size;
				cachedFiles.addItem( { create: file.creationDate.time, name: file.name, size: file.size } );
			}
		}

		private function cleanupCache( size : uint ) : void
		{

			var newCacheSize : uint = cacheSize + size;

			if ( newCacheSize > CACHE_SIZE )
			{

				cachedFiles.sort = new Sort();
				cachedFiles.sort.fields = [ new SortField( "create" ) ];
				cachedFiles.refresh();

				var item : Object = {}

				var halfCacheSize : Number = CACHE_SIZE * 0.5;

				while ( cacheSize > halfCacheSize )
				{


					item = cachedFiles.getItemAt( 0 )

					cacheSize -= item.size;
					cachedFiles.removeItemAt( 0 );

					var removeFile : File = cacheFolder.resolvePath( item.name );

					try
					{
						removeFile.deleteFile();
					}
					catch ( error : Error )
					{

					}
				}

				cachedFiles.sort = new Sort();
				cachedFiles.sort.fields = [ new SortField( "name" ) ];
				cachedFiles.refresh();
			}
		}
	}



}
