package net.vdombox.editors.parsers.vscript
{
	import net.vdombox.editors.HashLibraryArray;
	import net.vdombox.editors.parsers.AutoCompleteItemVO;
	import net.vdombox.editors.parsers.BackwardsParser;
	import net.vdombox.editors.parsers.ClassDB;
	import net.vdombox.editors.parsers.Field;
	import net.vdombox.editors.parsers.Multiname;
	import net.vdombox.editors.parsers.StandardWordsProxy;
	import net.vdombox.editors.parsers.StructureDB;
	import net.vdombox.editors.parsers.Token;
	import net.vdombox.editors.parsers.vdomxml.TypeDB;
	import net.vdombox.ide.common.interfaces.IEventBaseVO;
	import net.vdombox.ide.common.model._vo.ServerActionVO;
	import net.vdombox.ide.common.view.components.VDOMImage;
	
	import ro.victordramba.util.HashMap;

	public class Resolver
	{
		private var classDB : ClassDB;
		private var typeDB : TypeDB;
		private var tokenizer : VScriptTokenizer;
		
		private var tokenScopeClass : Field;
		
		private var a : Vector.<AutoCompleteItemVO>;
		
		public function Resolver( tokenizer : VScriptTokenizer )
		{
			this.tokenizer = tokenizer;
			this.classDB = ClassDB.inst;
			this.typeDB = TypeDB.inst;
		}
		
		/**
		 * this only checks if the name is in the scope at pos, it will not look in the imports
		 * we use it to add an import only if it's not shadowed by a local name
		 */
		public function isInScope( name : String, pos : int ) : Boolean
		{
			//find the scope
			var t : Token = tokenizer.tokenByPos( pos );
			if ( !t )
				return false;
			
			//check in function scope chain
			//also, find if we are in static scope
			var isStatic : Boolean = false;
			var scope : Field;
			var f : Field;
			for ( scope = t.scope; scope &&
				scope.fieldType == 'function' || scope.fieldType == 'get' || scope.fieldType == 'set'; scope = scope.parent )
			{
				if ( scope.members.hasKey( name ) || scope.params.hasKey( name ) )
					return true;
				if ( scope.isStatic )
					isStatic = true;
			}
			
			//compute tokenScopeClass
			findScopeClass( t.scope );
			
			//class scope
			if ( tokenScopeClass )
			{
				//for static scope, add only static members
				//current class
				for each ( f in tokenScopeClass.members.toArray() )
				if ( ( !isStatic || f.isStatic ) && f.name == name )
					return true;
				
				//inheritance
				scope = tokenScopeClass;
				while ( ( scope = classDB.resolveName( scope.extendz ) ) )
					for each ( f in scope.members.toArray() )
					if ( f.access != 'private' && ( !isStatic || f.isStatic ) && f.name == name )
						return true;
			}
			
			return false;
		}
		
		public function getMissingImports( name : String, pos : int ) : Vector.<String>
		{
			//find the scope
			var t : Token = tokenizer.tokenByPos( pos );
			if ( !t )
				return null;
			var imports : HashMap = findImports( t );
			
			var found : Boolean = false;
			var missing : Vector.<String> = classDB.listImportsFor( name )
			loop1: for each ( var pack : String in missing )
			{
				for each ( var line : String in imports.toArray() )
				{
					var i : int = line.lastIndexOf( '.' );
					var n : String = line.substr( i + 1 );
					if ( line.substr( 0, i ) == pack && ( n == '*' || n == name ) )
					{
						found = true;
						break loop1;
					}
				}
			}
			
			if ( !found )
				return missing;
			return null;
		}
		
		public function getAllOptions( pos : int ) : Vector.<AutoCompleteItemVO>
		{
			
			var f : Field;
			
			//all package level items
			var t : VScriptToken = tokenizer.tokenByPos( pos ) as VScriptToken;
			
			if ( t && ( t.type == Token.COMMENT || t.type == Token.STRING ) )
				return null;
			
			if ( t && ( t.string.toLowerCase() == "use" || t.importZone ) )
				return HashLibraryArray.getLibrariesName();
			/*else if ( t && t.importZone )
				return HashLibraryArray.getImportToLibraty( t.importFrom );*/
			
			// default keywords
			a = StandardWordsProxy.vscriptWords;		
			//find the scope
			if ( !t )
				return a;
			
			var hash : HashMap = new HashMap;
			var scope : Field;
			
			function addKeys( map : HashMap ) : void
			{
				for each ( var name : String in map.getKeys() )
				a.push( new AutoCompleteItemVO( VDOMImage.Parameter, name ) );
			}
			
			//find items in function scope chain
			//also, find if we are in static scope
			var isStatic : Boolean = false;
			
			for ( scope = t.scope; scope &&
				scope.fieldType == 'def'; scope = scope.parent )
			{
				//addKeys( scope.members );
				addKeys( scope.params );
				if ( scope.isStatic )
					isStatic = true;
			}
			
			//compute tokenScopeClass
			//findScopeClass( t.scope );
			
			//class scope
			for each ( f in tokenizer.members.toArray() )
				a.push( StandardWordsProxy.getAutoCompleteItemVOByField( f ) );
			
			if ( t.parent.imports )
			{
				var ff : Object;
				for each ( ff in t.parent.imports.toArray() )
				{
					var field : Field;
					if ( ff.source != ff.systemName )
					{
						field = HashLibraryArray.getTokenToLibraty( ff.source, ff.systemName, "vscript" );
						a.push( StandardWordsProxy.getAutoCompleteItemVOByField( field, true ) );
					}
					else
						a.push( new AutoCompleteItemVO( VDOMImage.Library, ff.name ) );
				}
			}
			
			return a;
		}
		
		
		public function getAllTypes( isFunction : Boolean = true ) : Vector.<AutoCompleteItemVO>
		{
			var lst : Vector.<Field> = classDB.listAllTypes();
			a = StandardWordsProxy.vscriptTypeWords;
			for each ( var f : Field in lst )
				a.push( new AutoCompleteItemVO( VDOMImage.Standard, f.name ) );
			
			/*if ( isFunction )
				a.push( 'void' );*/
			
			a.sort( Array.CASEINSENSITIVE );
			return a;
		}
		
		public function getFunctionDetails( text : String, pos : int ) : String
		{
			resolve( text, pos );
			var field : Field = resolvedRef;
			
			//debug(field);
			
			//we didn't find it
			if ( !field || field.fieldType != 'def' )
				return null;
			
			
			var a : Vector.<String> = new Vector.<String>;
			var par : Field;
			for each ( par in field.params.toArray() )
			{
				var str : String = par.name;
				if ( par.type )
					str += ':' + par.type.type;
				if ( par.defaultValue )
					str += '=' + par.defaultValue;
				a.push( { label: str, value: str });
			}
			//rest
			if ( field.hasRestParams )
				a[ a.length - 1 ] = '...' + par.name;
			
			return 'def ' + field.name + '(' + a.join( ', ' ) + ')' + ( field.type ? ':' + field.type.type : '' );
		}
		
		/**
		 * called when you enter a dot
		 */
		public function getMemberList( text : String, pos : int, actionVO : Object ) : Vector.<AutoCompleteItemVO>
		{
			a = new Vector.<AutoCompleteItemVO>;
			
			var flag : Boolean = resolve( text, pos, actionVO );
			
			if ( flag )
				return a;
			
			
			if ( !resolved )
				if ( !a )
					return null;
				else
					return a;
			
			//convert member list in string list
			
			
			for each ( var m : Field in listMembers( resolved, resolvedIsClass ).toArray() )
			{
				if ( a.indexOf( m.name ) == -1 )
					a.push( StandardWordsProxy.getAutoCompleteItemVOByField( m ) );
			}
				
			a.sort( Array.CASEINSENSITIVE );
			return a;
		}
		
		private function listMembers( type : Field, statics : Boolean ) : HashMap
		{
			return statics ? listStaticMembers( type ) : listTypeMembers( type );
		}
		
		private function listStaticMembers( type : Field ) : HashMap
		{
			var map : HashMap = new HashMap;
			for each ( var m : Field in type.members.toArray() )
			if ( m.isStatic && ( m.access == 'public' || tokenScopeClass == type ) )
				map.setValue( m.name, m );
			return map;
		}
		
		
		private function listTypeMembers( type : Field, skipConstructor : Boolean = true ) : HashMap
		{
			/*if ( type.fieldType != 'class' && type.fieldType != 'interface' )
			throw new Error( 'type has to be class' );*/
			
			var map : HashMap = new HashMap;
			
			
			var protectedOK : Boolean = false;
			
			for ( ; type; type = classDB.resolveName( type.extendz ) )
			{
				if ( tokenScopeClass == type )
				{
					protectedOK = true;
					for each ( var m : Field in type.members.toArray() )
					{
						if ( m.isStatic )
							continue;
						if ( ( m.access == 'public' || ( protectedOK && m.access == 'protected' ) ) )
							map.setValue( m.name, m );
					}
					continue;
				}
				
				for each ( m  in type.members.toArray() )
				{
					if ( m.isStatic )
						continue;
					if ( ( m.access == 'public' || ( protectedOK && m.access == 'protected' ) ) )
						map.setValue( m.name, m );
				}
			}
			
			return map;
		}
		
		
		public function findDefinition( text : String, pos : int ) : Field
		{
			//adjust position to next word boundary
			var re : RegExp = /\b/g;
			re.lastIndex = pos;
			pos = re.exec( text ).index;
			resolve( text, pos );
			return resolvedRef;
		}
		
		//find the imports for this token
		private function findImports( token : Token ) : HashMap
		{
			do
			{
				token = token.parent;
			} while ( token.parent && !token.imports );
			return token.imports;
		}
		
		
		private var resolved : Field;
		private var resolvedIsClass : Boolean;
		private var resolvedRef : Field;
		
		private function resolve( text : String, pos : int, actionVO : Object = null ) : Boolean
		{
			resolved = null;
			resolvedRef = null;
			resolvedIsClass = false;
			
			var t0 : Token = tokenizer.tokenByPos( pos );
			if ( t0.type == Token.COMMENT || t0.type == Token.STRING )
				return false;
			
			var bp : BackwardsParser = new BackwardsParser;
			if ( !bp.parse( text, pos ) )
				return false;
			
			//find the scope
			var t : Token = tokenizer.tokenByPos( bp.startPos );
			if ( !t )
				return false;
			
			var i : int = 0;
			var name : String = bp.names[ 0 ].toLowerCase();
			var itemType : String = bp.types[ 0 ];
			
			var imports : HashMap = findImports( t );
			
			findScopeClass( t.scope );
			
			//1. is it in function scope chain?
			var isStatic : Boolean = false;
			for ( scope = t.scope; scope && ( scope.fieldType == 'def' || scope.fieldType == 'top' || scope.fieldType == 'class' ); scope = scope.parent )
			{
				if ( scope.isStatic )
					isStatic = true;
				if ( scope.members.hasKey( name ) )
				{
					resolved = scope.members.getValue( name );
					break;
				}
				if ( scope.params.hasKey( name ) )
				{
					resolved = scope.params.getValue( name );
					break;
				}
				if ( t.parent.imports.hasKey( name ) )
				{
					var impotrElement : Object = t.parent.imports.getValue( name );
					a = HashLibraryArray.getTokensToLibratyClass( impotrElement.source, impotrElement.systemName, bp, "vscript" );
					return true;
					//return hashLibraries.getTokensToLibratyClass( t.imports.getValue( name ).source, impotrElement.systemName );
				}
				
			}
			
			var scope : Field;
			
			//2. is it this or super?
			
			if ( name == 'this' && tokenScopeClass )
			{
				if ( resolved )
					tokenScopeClass.members.merge( resolved.members );
				resolved = tokenScopeClass;
				
				for each( var field : Field in tokenScopeClass.members.toArray() )
				{
					if ( field.parent.name == tokenScopeClass.name )
						resolved.members.setValue( field.name, field );
				}
			}
			
			
			if ( name == 'this' && actionVO is ServerActionVO && !tokenScopeClass )
			{
				a = StructureDB.getChildrenForObject( ServerActionVO( actionVO ).containerVO, bp );
			}
			
			
			//3. or is it in the class/inheritance scope?
			for ( scope = tokenScopeClass; !resolved && scope; scope = classDB.resolveName(scope.extendz) )
			{
				var m : Field = scope.members.getValue( name );
				if ( !m )
					continue;
				
				if ( scope != tokenScopeClass && m.access == 'private' )
					continue;
				
				//skip constructors in inheritance chain
				if ( m.name == scope.name )
					continue;
				
				if ( !isStatic || m.isStatic )
					resolved = m;
			}
			
			//4. last, is it an imported thing?
			if ( !resolved && imports )
			{
				resolved = classDB.resolveName( new Multiname( name, imports ) );
				if ( resolved && resolved.fieldType == 'class' && itemType == BackwardsParser.NAME )
					resolvedIsClass = true;
			}
			
			//we didn't find the first name, we quit
			if ( !resolved )
				return false;
			else if ( resolved.fieldType == 'class' && itemType == BackwardsParser.NAME && name != 'self' )
				resolvedIsClass = true;
			
			checkReturnType();
			
			
			var aM : HashMap;
			do
			{
				i++;
				if ( i > bp.names.length - 1 )
					break;
				aM = listMembers( resolved, resolvedIsClass );
				resolved = aM.getValue( bp.names[ i ].toLowerCase() );
				resolvedIsClass = false;
				itemType = bp.types[ i ];
				if ( !resolved )
					return false;
				checkReturnType();
			} while ( resolved );
			
			//check return type or var type
			function checkReturnType() : void
			{
				//for function signature
				resolvedRef = resolved;
				if ( resolved.fieldType == 'class' && resolvedIsClass ) //return the constructor
				{
					var m : Field = resolved.members.getValue( resolved.name );
					if ( m )
						resolvedRef = m;
				}
				
				
				/*if ( resolved.type && resolved.fieldType == 'var' || resolved.fieldType == 'get' || resolved.fieldType == 'set' ||
				( itemType == BackwardsParser.FUNCTION && resolved.fieldType == 'def' ) )
				{
				resolved = typeDB.resolveName( resolved.type );
				}
				else*/ if ( resolved.fieldType == 'def' && itemType != BackwardsParser.FUNCTION )
				{
					resolved = classDB.resolveName( new Multiname( 'Def' ) );
				}
			}
			
			return false;
		}
		
		private function findScopeClass( scope : Field ) : void
		{
			//can we find a better way to set the scope?
			//we set the scope to be able to deal with private/protected, etc access
			for ( tokenScopeClass = scope; tokenScopeClass.fieldType != 'class' && tokenScopeClass.parent; tokenScopeClass = tokenScopeClass.parent )
			{
			}
			if ( tokenScopeClass.fieldType != 'class' )
				tokenScopeClass = null;
		}	
	}
}