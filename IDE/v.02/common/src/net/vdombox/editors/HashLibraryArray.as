package net.vdombox.editors
{
	import net.vdombox.editors.parsers.AutoCompleteItemVO;
	import net.vdombox.editors.parsers.FactoryTokenizers;
	import net.vdombox.editors.parsers.ImportItemVO;
	import net.vdombox.editors.parsers.LanguageVO;
	import net.vdombox.editors.parsers.StandardWordsProxy;
	import net.vdombox.editors.parsers.base.BackwardsParser;
	import net.vdombox.editors.parsers.base.Field;
	import net.vdombox.editors.parsers.base.Token;
	import net.vdombox.editors.parsers.base.Tokenizer;
	import net.vdombox.ide.common.model._vo.LibraryVO;
	import net.vdombox.ide.common.view.components.VDOMImage;
	
	import ro.victordramba.util.HashMap;

	public class HashLibraryArray
	{
		private static var hashLibraries : Object;
		
		private static var importToLibraries : HashMap = new HashMap();
		private static var fieldToLibraries : HashMap = new HashMap();
		private static var librariesName : Vector.<AutoCompleteItemVO>;
		
		public static function setLibraries( libraries : Array ) : void
		{
			hashLibraries = [];
			var library : LibraryVO;
			
			for each ( library in libraries )
				Add( new HashLibrary( library ) );
				
			librariesName = null;
		}
		
		public static function Add( hashLibrary : HashLibrary ) : void
		{
			hashLibraries[ hashLibrary.name ] = hashLibrary;
		}
		
		public static function updateLibrary( libraryVO : LibraryVO ) : void
		{
			Add( new HashLibrary( libraryVO ) );
		}
		
		public static function getLibrariesName() : Vector.<AutoCompleteItemVO>
		{
			if ( librariesName )
				return librariesName;
			
			var a : Vector.<AutoCompleteItemVO> = new Vector.<AutoCompleteItemVO>();
			
			var hashLibrary : HashLibrary;
			for each ( hashLibrary in hashLibraries )
				a.push( new AutoCompleteItemVO( VDOMImage.Library, hashLibrary.name ) );
				
			librariesName = a;
			return a;
		}
		
		/*public static function getImportFiledToLibrary( importFrom : String, lang : String, prevImport : Object = null ) : Array
		{
			
		}*/
		
		public static function getImportToLibraty( importFrom : String, lang : String, prevImport : Object = null) : Vector.<AutoCompleteItemVO>
		{
			if ( importToLibraries.hasKey( importFrom ) )
			{
				return importToLibraries.getValue( importFrom ) as Vector.<AutoCompleteItemVO>;
			}
			else
			{
				var a : Vector.<AutoCompleteItemVO> = new Vector.<AutoCompleteItemVO>();
				
				var path : Array = importFrom.split( "." );
				
				if ( !hashLibraries.hasOwnProperty( path[0] ) )
					return null;
				
				var string : String = hashLibraries[ path[0] ].libraryVO.script;
				
				var tokenizer : Tokenizer = FactoryTokenizers.getTokenizer( lang, string );
				tokenizer.actionVO = hashLibraries[ path[0] ].libraryVO;
				
				tokenizer.prevImport = prevImport;
				
				if ( tokenizer.hasPrevImport( path[0] ) )
					return a;
				
				while ( tokenizer.runSlice() )
				{
					
				}
				
				var t : Token = tokenizer.tokenByPos(1);
				
				if ( t && t.scope && t.scope.members )
				{
					var f : Field;
					for each ( f in t.scope.members.toArray() )
					{
						a.push( StandardWordsProxy.getAutoCompleteItemVOByField( f, true ) );
					}
				}
				
				if ( t && t.parent && t.parent.scope.imports )
				{
					var importLibrary : ImportItemVO;
					var fields : Vector.<AutoCompleteItemVO>;
					var field : Field;
					for each ( importLibrary in t.parent.scope.imports.toArray() )
					{
						if ( importLibrary.source != importLibrary.systemName )
						{
							field = getTokenToLibraty( importLibrary.source, importLibrary.systemName, lang, prevImport );
							if ( field )
								a.push( StandardWordsProxy.getAutoCompleteItemVOByField( field, true ) );
						}
						else
						{
							fields = getImportToLibraty(importLibrary.source, lang, prevImport );
						}
						
						if ( fields )
							a.concat( fields );
						else
							a.push( new AutoCompleteItemVO( VDOMImage.Standard, importLibrary.name ) );
					
					}
				}
				
				importToLibraries.setValue( importFrom, a );
				
				return a;
			
			}
		}
		
		public static function getTokensToLibratyClass( importFrom : String, importToken : String, bp : BackwardsParser, lang : String, all : Boolean = false ) : Vector.<AutoCompleteItemVO>
		{
			var len : int = bp.names.length;
			
			bp.names[0] = importToken;
			
			if ( len == 1 && importFrom == importToken || len > 1 && importFrom == bp.names[len - 1] )
				return getImportToLibraty( importFrom, lang );
		
			var path : Array = importFrom.split( "." );
			var path0 : String = path[0];
			
			if ( !hashLibraries.hasOwnProperty( path0 ) )
				return null;
			
			var t : Token;
			
			if ( fieldToLibraries.hasKey( path0 ) )
			{
				t = fieldToLibraries.getValue( path0 ) as Token;;
			}
			else
			{
				var string : String = hashLibraries[ path0 ].libraryVO.script;
				
				var tokenizer : Tokenizer = FactoryTokenizers.getTokenizer( lang, string );
				
				while ( tokenizer.runSlice() )
				{
					
				}
				
				t = tokenizer.tokenByPos(1);
				fieldToLibraries.setValue( path0, t );
			}
			
			
			var scope : Field = t.scope;
			
			var a : Vector.<AutoCompleteItemVO> = new Vector.<AutoCompleteItemVO>();
			
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
						if ( all || f2.isStatic || f2.isClassMethod || ( f2.fieldType == "var" && f2.access == "public" && f2.parent && f2.parent.name == importToken ) )
							a.push( StandardWordsProxy.getAutoCompleteItemVOByField( f2, true ) );
					}
				}
			}
			
			return a;
		}
		
		public static function getTokenToLibraty( importFrom : String, importToken : String, lang : String, prevImport : Object = null ) : Field
		{			
			var path : Array = importFrom.split( "." );
			var path0 : String = path[0];
			
			if ( !hashLibraries.hasOwnProperty( path0 ) )
				return null;
			
			var t : Token;
			
			if ( fieldToLibraries.hasKey( path0 ) )
			{
				t = fieldToLibraries.getValue( path0 ) as Token;;
			}
			else
			{
				var string : String = hashLibraries[ path0 ].libraryVO.script;
				
				var tokenizer : Tokenizer = FactoryTokenizers.getTokenizer( lang, string );
				tokenizer.actionVO = hashLibraries[ path[0] ].libraryVO;
				tokenizer.prevImport = prevImport;
				
				if ( tokenizer.hasPrevImport( path[0] ) )
					return null;
				
				while ( tokenizer.runSlice() )
				{
					
				}
				
				t = tokenizer.tokenByPos(1);
				fieldToLibraries.setValue( path0, t );
			}
			
			
			var scope : Field = t.scope;
			
			if ( scope && scope.members )
			{	
				var f : Field;
				var flag : Boolean = false;
				
				for each ( f in scope.members.toArray() )
				{
					if ( f.name == importToken )
					{
						scope = f;
						flag = true;
						break;
					}
				}
				
				if ( flag )
				{
					return scope;
				}
					 
			}
			return null;
		}
		
		public static function getPositionToken( importFrom : String, importToken : String, bp : BackwardsParser, lang : String ) : Object
		{
			var len : int = bp.names.length;
			
			bp.names[0] = lang == "vscript" ? importToken.toLowerCase() : importToken;
			
			if ( len == 1 && importFrom == importToken || len > 1 && importFrom == bp.names[len - 1] )
				return null;//getImportToLibraty( importFrom );
			
			var path : Array = importFrom.split( "." );
			
			if ( !hashLibraries.hasOwnProperty( path[0] ) )
				return null;
			
			var libraryVO : LibraryVO = hashLibraries[ path[0] ].libraryVO;
			
			var string : String = libraryVO.script;
			
			var tokenizer : Tokenizer = FactoryTokenizers.getTokenizer( lang, string );
			
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
						if ( lang == LanguageVO.vscript )
						{
							if ( f.name.toLowerCase() == bp.names[i] )
							{
								scope = f;
								flag = true;
								break;
							}
						}
						else if ( f.name == bp.names[i]  )
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
		
		public static function removeAll() : void
		{
			importToLibraries.removeAll();
			fieldToLibraries.removeAll();
		}
		
		public static function removeLibrary( nameLibrary : String ) : void
		{
			importToLibraries.removeValue( nameLibrary );
			fieldToLibraries.removeValue( nameLibrary );
		}
		
	}
}