package net.vdombox.editors.parsers.vdomxml
{
	import flash.net.registerClassAlias;
	import flash.utils.ByteArray;
	
	import net.vdombox.editors.parsers.AutoCompleteItemVO;
	import net.vdombox.editors.parsers.base.Field;
	import net.vdombox.editors.parsers.StandardWordsProxy;
	import net.vdombox.ide.common.model.TypesProxy;
	import net.vdombox.ide.common.model._vo.AttributeDescriptionVO;
	import net.vdombox.ide.common.view.components.VDOMImage;
	
	import ro.victordramba.util.HashMap;

	public class TypeDB
	{
		static private var dbList : Vector.<TypeDB> = new Vector.<TypeDB>;

		static public function get inst() : TypeDB
		{
			return dbList[ 0 ];
		}

		static public function setDB( name : String, typeDB : TypeDB ) : void
		{
			typeDB.dbName = name;
			for ( var i : int = 0; i < dbList.length; i++ )
			{
				if ( dbList[ i ].dbName == name )
				{
					dbList[ i ] = typeDB;
					typeDB.dbIndex = i;
					return;
				}
			}
			typeDB.dbIndex = i;
			dbList.push( typeDB );
		}

		static public function removeDB( name : String ) : void
		{
			//TODO remove it from the list!
			//quick one :D
			setDB( name, new TypeDB );
		}


		public var dbName : String = 'unnamed';

		private var data : HashMap = new HashMap;

		private var dbIndex : int;

		private function get parentDB() : TypeDB
		{
			return dbIndex < dbList.length - 1 ? dbList[ dbIndex + 1 ] : null;
		}


		public function addDefinition( typeField : Field ) : void
		{
			data.setValue( typeField.name, typeField );
		}

		public function listImportsFor( name : String ) : Vector.<String>
		{
			var a : Vector.<String> = parentDB ? parentDB.listImportsFor( name ) : new Vector.<String>;
			for each ( var packName : String in data.getKeys() )
			{
				for each ( var key : String in data.getValue( packName ).getKeys() )
				{
					if ( name == key && packName != '-' )
						a.push( packName );
				}
			}
			return a;
		}

		public function listAll() : Vector.<Field>
		{
			var a : Vector.<Field> = parentDB ? parentDB.listAll() : new Vector.<Field>;
			
			a = a.concat( Vector.<Field>( data.toArray() ) );
			return a;
		}

		public function getType( typeName : String ) : Field
		{
			typeName = typeName.toLowerCase();
			
			var typeField : Field = data.getValue( typeName );
			
			if ( !typeField )
				return null;
			
			if ( typeField.members.toArray().length == 1 )
			{
				var attributeDescriptions : Array = typeField.typeVO.attributeDescriptions;
				var attributeDescriptionVO : AttributeDescriptionVO;
				
				for each ( attributeDescriptionVO in attributeDescriptions )
				{
					typeField.members.setValue( attributeDescriptionVO.name, new Field( "attribute", 0, attributeDescriptionVO.name ) );
				}
			}
			
			return typeField;
		}
		
		public function getVectorByType( typeID : String ) : Vector.<AutoCompleteItemVO>
		{			
			var typeField : Field;
			for each( typeField in data.toArray() )
			{
				if ( typeField.typeVO.id == typeID )
					break;
			}
			
			var a : Vector.<AutoCompleteItemVO> = new Vector.<AutoCompleteItemVO>();
			
			if ( typeField.members.toArray().length == 1 )
			{
				var attributeDescriptions : Array = typeField.typeVO.attributeDescriptions;
				var attributeDescriptionVO : AttributeDescriptionVO;
				
				for each ( attributeDescriptionVO in attributeDescriptions )
				{
					a.push( new AutoCompleteItemVO( VDOMImage.Standard, attributeDescriptionVO.name ) );
				}
			}
			
			return a;
		}
		
		public function toString() : String
		{
			//return data.toArray().join(',');
			return '[TypeDB ' + dbName + ']';
		}
	}
}