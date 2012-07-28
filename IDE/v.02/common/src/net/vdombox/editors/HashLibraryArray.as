package net.vdombox.editors
{
	import flashx.textLayout.tlf_internal;
	
	import net.vdombox.editors.parsers.BackwardsParser;
	import net.vdombox.editors.parsers.Field;
	import net.vdombox.editors.parsers.Token;
	import net.vdombox.editors.parsers.python.PythonTokenizer;
	import net.vdombox.ide.common.model._vo.LibraryVO;

	public class HashLibraryArray
	{
		private static var hashLibraries : Object;
		
		public static function setLibraries( libraries : Array ) : void
		{
			hashLibraries = [];
			var library : LibraryVO;
			
			for each ( library in libraries )
				Add( new HashLibrary( library ) );
		}
		
		public static function Add( hashLibrary : HashLibrary ) : void
		{
			hashLibraries[ hashLibrary.name ] = hashLibrary;
		}
		
		public static function getLibrariesName() : Vector.<String>
		{
			var a : Vector.<String> = new Vector.<String>();
			
			var hashLibrary : HashLibrary;
			for each ( hashLibrary in hashLibraries )
				a.push( hashLibrary.name );
				
			return a;
		}
		
		public static function getImportToLibraty( importFrom : String ) : Vector.<String>
		{
			var a : Vector.<String> = new Vector.<String>();
			
			var path : Array = importFrom.split( "." );
			
			if ( !hashLibraries.hasOwnProperty( path[0] ) )
				return null;
			
			var string : String = hashLibraries[ path[0] ].libraryVO.script;
			
			var tokenizer : PythonTokenizer = new PythonTokenizer( string );
			
			while ( tokenizer.runSlice() )
				;
			
			var t : Token = tokenizer.tokenByPos(1);
			
			if ( t && t.scope && t.scope.members )
			{
				var f : Field;
				for each ( f in t.scope.members.toArray() )
				{
					a.push( f.name );
				}
			}
			
			if ( t && t.parent && t.parent.imports )
			{
				var importLibrary : Object;
				for each ( importLibrary in t.parent.imports.toArray() )
				{
					a.push( importLibrary.name );
				}
			}
			
			return a;
		}
		
		public static function getTokensToLibratyClass( importFrom : String, importToken : String, bp : BackwardsParser ) : Vector.<String>
		{
			var len : int = bp.names.length;
			
			bp.names[0] = importToken;
			
			if ( len == 1 && importFrom == importToken || len > 1 && importFrom == bp.names[len - 1] )
				return getImportToLibraty( importFrom );
			
			var a : Vector.<String> = new Vector.<String>();
			
			var path : Array = importFrom.split( "." );
			
			if ( !hashLibraries.hasOwnProperty( path[0] ) )
				return null;
			
			var string : String = hashLibraries[ path[0] ].libraryVO.script;
			
			var tokenizer : PythonTokenizer = new PythonTokenizer( string );
			
			while ( tokenizer.runSlice() )
			{
				
			}
			
			var t : Token = tokenizer.tokenByPos(1);
			var scope : Field = t.scope;
			
			
			
			if ( t && t.scope && t.scope.members )
			{	
				var f : Field;
				var flag : Boolean = true;
				for ( var i : int = 0; i < len; i++ )
				{
					flag = false;
					for each ( f in scope.members.toArray() )
					{
						if ( f.name == bp.names[i] )
						{
							scope = f;
							flag = true;
							break;
						}
					}
				}
				
				if ( flag && scope.members )
				{
					var f2 : Field;
					for each ( f2 in scope.members.toArray() )
					{
						if ( f2.isStatic || f2.isClassMethod || ( f2.fieldType == "var" && f2.access == "public" && f2.parent && f2.parent.name == importToken ) )
							a.push( f2.name );
					}
				}
			}
			
			return a;
		}
		
		public static function getPositionToken( importFrom : String, importToken : String, bp : BackwardsParser ) : Object
		{
			var len : int = bp.names.length;
			
			bp.names[0] = importToken;
			
			if ( len == 1 && importFrom == importToken || len > 1 && importFrom == bp.names[len - 1] )
				return null;//getImportToLibraty( importFrom );
			
			var path : Array = importFrom.split( "." );
			
			if ( !hashLibraries.hasOwnProperty( path[0] ) )
				return null;
			
			var libraryVO : LibraryVO = hashLibraries[ path[0] ].libraryVO;
			
			var string : String = libraryVO.script;
			
			var tokenizer : PythonTokenizer = new PythonTokenizer( string );
			tokenizer.actionVO = hashLibraries[ path[0] ].libraryVO;
			
			while ( tokenizer.runSlice() )
			{
				
			}
			
			var t : Token = tokenizer.tokenByPos(1);
			var scope : Field = t.scope;
			
			
			
			if ( t && t.scope && t.scope.members )
			{	
				var f : Field;
				var flag : Boolean = true;
				for ( var i : int = 0; i < len; i++ )
				{
					flag = false;
					for each ( f in scope.members.toArray() )
					{
						if ( f.name == bp.names[i] )
						{
							scope = f;
							flag = true;
							break;
						}
					}
				}
				
				if ( flag )
				{
					return { libraryVO : libraryVO, position : scope.pos, length : scope.name.length };
				}
			}
			
			return null;
		}
		
	}
}