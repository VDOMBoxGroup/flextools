package net.vdombox.editors.parsers.vdomxml
{

	import ro.victordramba.util.HashMap;


	internal class Resolver
	{
		private var typeDB : TypeDB;
		private var tokenizer : Tokenizer;

		public function Resolver( tokenizer : Tokenizer )
		{
			this.tokenizer = tokenizer;
			this.typeDB = TypeDB.inst;
		}

		public function isInTag( position : int ) : Boolean
		{
			var result : Boolean = false;

			var token : Token = tokenizer.tokenByPos( position );

			if ( token &&
				( ( token.type == Token.TAGNAME && position <= token.pos + token.string.length ) ||
				( token.type == Token.OPENTAG && position == token.pos + token.string.length ) ) ||
				( token.type == Token.CLOSETAG && token.string == "</" && position == token.pos + token.string.length ))
				result = true;

			return result;
		}

		public function isInAttribute( position : int ) : Boolean
		{
			var result : Boolean = false;

			var token : Token = tokenizer.tokenByPos( position );

			if ( token && token.string != "<" )
			{
				if ( ( token.type == Token.TAGNAME && position > token.pos + token.string.length ) ||
					( token.type == Token.ATTRIBUTENAME && position <= token.pos + token.string.length ) ||
					( token.type == Token.ATTRIBUTEVALUE && position > token.pos + token.string.length ) )
				{
					result = true;
				}
			}

			return result;
		}

		public function getAllTypes() : Vector.<Object>
		{
			var lst : Vector.<Field> = typeDB.listAll();
			var a : Vector.<Object> = new Vector.<Object>;

			for each ( var f : Field in lst )
				a.push( f.name );

			return a;
		}

		public function getAttributesList( pos : int ) : Vector.<Object>
		{

			var token : Token = tokenizer.tokenByPos( pos )
			var typeName : String;
			var type : Field;

			var a : Vector.<Object>

			if ( token && token.parent )
			{
				token = token.parent;

				if ( token.type == Token.OPENTAG && token.children && token.children.length > 0 )
					token = token.children[ 0 ];

				if ( token.type == Token.TAGNAME )
					typeName = token.string;
			}

			if ( typeName )
				type = typeDB.getType( typeName );


			if ( type )
			{
				a = new Vector.<Object>;
				
				

				for each ( var m : Field in type.members.toArray() )
				{
					a.push( m.name );
				}
			}

//			for each ( var m : Field in listMembers( resolved, resolvedIsClass ).toArray() )
//				a.push( m.name );

			return a;
		}

		private function listMembers( type : Field, statics : Boolean ) : HashMap
		{
			return statics ? listStaticMembers( type ) : listTypeMembers( type );
		}

		private function listStaticMembers( type : Field ) : HashMap
		{
			var map : HashMap = new HashMap;
//			for each ( var m : Field in type.members.toArray() )
//				if ( m.isStatic && ( m.access == 'public' || tokenScopeClass == type ) )
//					map.setValue( m.name, m );
			return map;
		}


		private function listTypeMembers( type : Field, skipConstructor : Boolean = true ) : HashMap
		{
			if ( type.fieldType != 'class' && type.fieldType != 'interface' )
				throw new Error( 'type has to be class' );

			var map : HashMap = new HashMap;


			var protectedOK : Boolean = false;

//			for ( ; type; type = typeDB.resolveName( type.extendz ) )
//			{
//				if ( tokenScopeClass == type )
//				{
//					protectedOK = true;
//					map.merge( type.members );
//					continue;
//				}
//
//				for each ( var m : Field in type.members.toArray() )
//				{
//					if ( m.isStatic )
//						continue;
//					var constrCond : Boolean = ( m.name == type.name ) && skipConstructor;
//					if ( ( m.access == 'public' || ( protectedOK && m.access == 'protected' ) ) && !constrCond )
//						map.setValue( m.name, m );
//				}
//			}

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

		private function resolve( text : String, pos : int ) : void
		{
			resolved = null;
			resolvedRef = null;
			resolvedIsClass = false;

			var t0 : Token = tokenizer.tokenByPos( pos );
			if ( t0.type == Token.COMMENT )
				return;

			var bp : BackwardsParser = new BackwardsParser;
			if ( !bp.parse( text, pos ) )
				return;

			//debug('bp names: '+bp.names);

			//find the scope
			var t : Token = tokenizer.tokenByPos( bp.startPos );
			if ( !t )
				return;

			var i : int = 0;
			var name : String = bp.names[ 0 ];
			var itemType : String = bp.types[ 0 ];

			var imports : HashMap = findImports( t );

//			findScopeClass( t.scope );

			//1. is it in function scope chain?
			var isStatic : Boolean = false;
//			for ( scope = t.scope; scope &&
//				scope.fieldType == 'function' || scope.fieldType == 'get' || scope.fieldType == 'set'; scope = scope.parent )
//			{
//				if ( scope.isStatic )
//					isStatic = true;
//				if ( scope.members.hasKey( name ) )
//				{
//					resolved = scope.members.getValue( name );
//					break;
//				}
//				if ( scope.params.hasKey( name ) )
//				{
//					resolved = scope.params.getValue( name );
//					break;
//				}
//			}
//
//			var scope : Field;
//
//			//2. is it this or super?
//			if ( !resolved )
//			{
//				//non-static instance context
//				var cond : Boolean = t.scope.parent && t.scope.parent.fieldType == 'class' && !isStatic;
//				if ( name == 'this' && cond )
//					resolved = t.scope.parent;
//				if ( name == 'super' && cond )
//					resolved = typeDB.resolveName( t.scope.parent.extendz );
//			}
//
//
//			//3. or is it in the class/inheritance scope?
//			for ( scope = tokenScopeClass; !resolved && scope; scope = typeDB.resolveName( scope.extendz ) )
//			{
//				var m : Field = scope.members.getValue( name );
//				if ( !m )
//					continue;
//
//				if ( scope != tokenScopeClass && m.access == 'private' )
//					continue;
//
//				//skip constructors in inheritance chain
//				if ( m.name == scope.name )
//					continue;
//
//				if ( !isStatic || m.isStatic )
//					resolved = m;
//			}

			//4. last, is it an imported thing?
//			if ( !resolved && imports )
//			{
//				resolved = typeDB.resolveName( new Multiname( name, imports ) );
//				if ( resolved && resolved.fieldType == 'class' && itemType == BackwardsParser.NAME )
//					resolvedIsClass = true;
//			}
//
//			//we didn't find the first name, we quit
//			if ( !resolved )
//				return;
//			checkReturnType();
//
//
//			var aM : HashMap;
//			do
//			{
//				i++;
//				if ( i > bp.names.length - 1 )
//					break;
//				aM = listMembers( resolved, resolvedIsClass );
//				resolved = aM.getValue( bp.names[ i ] );
//				resolvedIsClass = false;
//				itemType = bp.types[ i ];
//				if ( !resolved )
//					return;
//				checkReturnType();
//			} while ( resolved );
//
//			//check return type or var type
//			function checkReturnType() : void
//			{
//				//for function signature
//				resolvedRef = resolved;
//				if ( resolved.fieldType == 'class' && resolvedIsClass ) //return the constructor
//				{
//					var m : Field = resolved.members.getValue( resolved.name );
//					if ( m )
//						resolvedRef = m;
//				}
//
//
//				if ( resolved.fieldType == 'var' || resolved.fieldType == 'get' || resolved.fieldType == 'set' ||
//					( itemType == BackwardsParser.FUNCTION && resolved.fieldType == 'function' ) )
//				{
//					resolved = typeDB.resolveName( resolved.type );
//				}
//				else if ( resolved.fieldType == 'function' && itemType != BackwardsParser.FUNCTION )
//				{
//					resolved = typeDB.resolveName( new Multiname( 'Function' ) );
//				}
//			}
		}

//		private function findScopeClass( scope : Field ) : void
//		{
//			//can we find a better way to set the scope?
//			//we set the scope to be able to deal with private/protected, etc access
//			for ( tokenScopeClass = scope; tokenScopeClass.fieldType != 'class' && tokenScopeClass.parent; tokenScopeClass = tokenScopeClass.parent )
//			{
//			}
//			if ( tokenScopeClass.fieldType != 'class' )
//				tokenScopeClass = null;
//		}
	}
}