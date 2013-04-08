/*
   license section

   Flash MiniBuilder is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   Flash MiniBuilder is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with Flash MiniBuilder.  If not, see <http://www.gnu.org/licenses/>.


   Author: Victor Dramba
   2009
 */

package ro.victordramba.util
{
	import net.vdombox.editors.parsers.base.Field;

	public class HashMap
	{
		private var data : Object = {};

		public function HashMap()
		{
			var tt : int = 0;
		}

		public function setValue( key : String, value : * ) : void
		{
			data[ '$' + key ] = value;
		}

		public function removeValue( key : String ) : void
		{
			delete data[ '$' + key ];
		}

		public function getValue( key : String ) : *
		{
			return data[ '$' + key ];
		}

		public function hasKey( key : String ) : Boolean
		{
			return ( '$' + key ) in data;
		}

		public function removeAll() : void
		{
			var item : String;
			for ( item in data )
				delete data[ '$' + item.substr( 1 ) ];
		}

		public function toArray() : Array
		{
			var a : Array = [];
			var item : *;
			for each ( item in data )
				a.push( item );
			return a;
		}

		public function getKeys() : Array /*of String*/
		{
			var a : Array = [];
			var item : String;
			for ( item in data )
				a.push( item.substr( 1 ) );
			return a;
		}

		public function merge( hm : HashMap ) : void
		{
			var ret : HashMap = new HashMap;
			for each ( var key : String in hm.getKeys() )
				setValue( key, hm.getValue( key ) );
		}

		public function mergeExcOneField( hm : HashMap, excField : Field ) : void
		{
			var ret : HashMap = new HashMap;
			for each ( var key : String in hm.getKeys() )
			{
				var field : Field = hm.getValue( key ) as Field;
				if ( field != excField )
					setValue( key, hm.getValue( key ) );
			}

		}

		public function clone() : HashMap
		{
			var ret : HashMap = new HashMap;
			for each ( var key : String in getKeys() )
				ret.setValue( key, getValue( key ) );

			return ret;
		}

		public function getNotVariableFields() : HashMap
		{
			var ret : HashMap = new HashMap;
			for each ( var key : String in getKeys() )
			{
				var field : Field = getValue( key ) as Field;
				if ( field.fieldType == "class" || field.fieldType == "def" )
					ret.setValue( key, getValue( key ) );
			}

			return ret;
		}
	}
}