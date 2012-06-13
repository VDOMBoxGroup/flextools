package net.vdombox.editors
{
	import net.vdombox.editors.parsers.python.Field;
	import net.vdombox.editors.parsers.python.Token;
	import net.vdombox.editors.parsers.python.Tokenizer;

	public class HashLibraryArray
	{
		private var hashLibraries : Object;
		
		public function HashLibraryArray()
		{
			hashLibraries = [];
		}
		
		public function Add( hashLibrary : HashLibrary ) : void
		{
			hashLibraries[ hashLibrary.name ] = hashLibrary;
		}
		
		public function getLibrariesName() : Vector.<String>
		{
			var a : Vector.<String> = new Vector.<String>();
			
			var hashLibrary : HashLibrary;
			for each ( hashLibrary in hashLibraries )
				a.push( hashLibrary.name );
				
			return a;
		}
		
		public function getImportToLibraty( importFrom : String ) : Vector.<String>
		{
			var a : Vector.<String> = new Vector.<String>();
			
			var path : Array = importFrom.split( "." );
			
			if ( !hashLibraries.hasOwnProperty( path[0] ) )
				return null;
			
			var string : String = hashLibraries[ path[0] ].libraryVO.script;
			
			var tokenizer : Tokenizer = new Tokenizer( string );
			
			while ( tokenizer.runSlice() )
				;
			
			var t : Token = tokenizer.tokenByPos(1);
			
			if ( t && t.scope && t.scope.selfMembers )
			{
				var f : Field;
				for each ( f in t.scope.selfMembers.toArray() )
				{
					a.push( f.name );
				}
			}
			
			return a;
		}
	}
}