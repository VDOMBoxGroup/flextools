package net.vdombox.editors.parsers.vdomxml
{

	import net.vdombox.editors.parsers.AutoCompleteItemVO;
	import net.vdombox.editors.parsers.TypeDB;
	import net.vdombox.editors.parsers.base.BackwardsParser;
	import net.vdombox.editors.parsers.base.Field;
	import net.vdombox.editors.parsers.base.Token;
	import net.vdombox.ide.common.view.components.VDOMImage;
	
	import ro.victordramba.util.HashMap;


	internal class Resolver
	{
		private var typeDB : TypeDB;
		private var tokenizer : VdomXMLTokenizer;

		public function Resolver( tokenizer : VdomXMLTokenizer )
		{
			this.tokenizer = tokenizer;
			this.typeDB = TypeDB.inst;
		}

		public function isInTag( position : int ) : Boolean
		{
			var result : Boolean = false;

			var token : VdomXMLToken = tokenizer.tokenByPos( position ) as VdomXMLToken;

			if ( token &&
				( ( token.type == VdomXMLToken.TAGNAME && position <= token.pos + token.string.length ) ||
				( token.type == VdomXMLToken.OPENTAG && position == token.pos + token.string.length ) ) ||
				( token.type == VdomXMLToken.CLOSETAG && token.string == "</" && position == token.pos + token.string.length ))
				result = true;

			return result;
		}

		public function isInAttribute( position : int ) : Boolean
		{
			var result : Boolean = false;

			var token : VdomXMLToken = tokenizer.tokenByPos( position ) as VdomXMLToken;

			if ( token && token.string != "<" )
			{
				if ( ( token.type == VdomXMLToken.TAGNAME && position > token.pos + token.string.length ) ||
					( token.type == VdomXMLToken.ATTRIBUTENAME && position <= token.pos + token.string.length ) ||
					( token.type == VdomXMLToken.ATTRIBUTEVALUE && position > token.pos + token.string.length ) )
				{
					result = true;
				}
			}

			return result;
		}

		public function getAllTypes() : Vector.<AutoCompleteItemVO>
		{
			var lst : Vector.<Field> = typeDB.listAll();
			var a : Vector.<AutoCompleteItemVO> = new Vector.<AutoCompleteItemVO>;

			for each ( var f : Field in lst )
				a.push( new AutoCompleteItemVO( VDOMImage.Standard, f.name.toUpperCase() ) );

			return a;
		}

		public function getAttributesList( pos : int ) : Vector.<AutoCompleteItemVO>
		{

			var token : VdomXMLToken = tokenizer.tokenByPos( pos ) as VdomXMLToken;
			var typeName : String;
			var type : Field;
			var a : Vector.<AutoCompleteItemVO>

			if ( token && token.parent )
			{
				token = token.parent as VdomXMLToken;

				if ( token.type == VdomXMLToken.OPENTAG && token.children && token.children.length > 0 )
					token = token.children[ 0 ];

				if ( token.type == VdomXMLToken.TAGNAME )
					typeName = token.string;
			}

			if ( typeName )
				type = typeDB.getType( typeName );


			if ( type )
			{
				a = new Vector.<AutoCompleteItemVO>;
				
				for each ( var m : Field in type.members.toArray() )
				{
					a.push( new AutoCompleteItemVO( VDOMImage.Standard, m.name ) );
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
				token = token.parent as VdomXMLToken;
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
			if ( t0.type == VdomXMLToken.COMMENT )
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

			//1. is it in function scope chain?
			var isStatic : Boolean = false;
		}
	}
}