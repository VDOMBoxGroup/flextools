package net.vdombox.editors.parsers.vdomxml
{
	import flash.net.registerClassAlias;
	import flash.utils.ByteArray;
	
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
			
			return data.getValue( typeName );
		}
		
		public function toString() : String
		{
			//return data.toArray().join(',');
			return '[TypeDB ' + dbName + ']';
		}
	}
}