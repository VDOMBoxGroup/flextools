package net.vdombox.editors.parsers
{
	import flash.net.registerClassAlias;
	import flash.utils.ByteArray;
	
	import ro.victordramba.util.HashMap;
	import net.vdombox.editors.parsers.base.Field;
	import net.vdombox.editors.parsers.base.Multiname;

	public class ClassDB
	{
		static private var dbList:Vector.<ClassDB> = new Vector.<ClassDB>;
		
		static public function get inst():ClassDB
		{
			return dbList[0];
		}
		
		static public function setDB(name:String, typeDB:ClassDB):void
		{
			typeDB.dbName = name;
			for (var i:int=0; i<dbList.length; i++)
			{
				if (dbList[i].dbName == name)
				{
					dbList[i] = typeDB;
					typeDB.dbIndex = i;
					return;
				}
			}
			typeDB.dbIndex = i;
			dbList.push(typeDB);
		}
		
		static public function removeDB(name:String):void
		{
			//TODO remove it from the list!
			//quick one :D
			setDB(name, new ClassDB);
		}
		
		
		public var dbName:String = 'unnamed';
		
		private var data:HashMap = new HashMap;
		
		private var dbIndex:int;
		
		private function get parentDB():ClassDB
		{
			return dbIndex < dbList.length-1 ? dbList[dbIndex+1] : null;
		}
		
		
		public function addDefinition(packageName:String, classField:Field, file:String=null):void
		{
			//if (classField.fieldType != 'class' && classField.fieldType != 'interface')
			//	throw new Error('not a type');
			
			if (/^_.*flash_display_(Sprite|MovieClip)$/.test(classField.name))
				return;
			
			if (packageName == '') packageName = '-';//toplevel name is '-'
			
			if (!data.hasKey(packageName))
				data.setValue(packageName, classField);
		}
		
		/*public function listTypes(imports:HashMap):Vector.<Field>
		{
			if (!imports) imports = new HashMap;
			if (!imports.hasKey('.*'))
				imports.setValue('.*', '.*');
				
			var a:Vector.<Field> = new Vector.<Field>;
			for each (var item:String in imports.toArray())
			{
				var p:int = item.lastIndexOf('.');
				var pack:String = item.substr(0, p);
				if (pack == '') pack = '-';
				var cls:String = item.substr(p+1);
				var packTypes:HashMap = data.getValue(pack);
				if (!packTypes) continue;
				if (cls == '*')
					a = a.concat(packTypes.toArray());
				else if (packTypes.hasKey(cls))
					a.push(packTypes.getValue(cls));
			}
			return a;
		}*/
		
		public function listImportsFor(name:String):Vector.<String>
		{
			var a:Vector.<String> = parentDB ? parentDB.listImportsFor(name) : new Vector.<String>;
			for each (var packName:String in data.getKeys())
			{
				for each (var key:String in data.getValue(packName).getKeys())
				{
					if (name == key && packName!='-')
						a.push(packName);
				}
			}
			return a;
		}
		
		
		public function listAllTypes():Vector.<Field>
		{
			var a:Vector.<Field> = parentDB ? parentDB.listAllTypes() : new Vector.<Field>;
			var pack:Field;
			for each (pack in data.toArray())
			{
				if (pack.fieldType=='class' || pack.fieldType=='interface')
					a.push(pack);
			}
			return a;
		}
		public function listAll():Vector.<Field>
		{
			var a:Vector.<Field> = parentDB ? parentDB.listAll() : new Vector.<Field>;
			var pack:HashMap;
			for each (pack in data.toArray())
				a = a.concat(Vector.<Field>(pack.toArray()));
			return a;
		}
		
		public function listDeps():Vector.<String>
		{
			var a:Vector.<String> = new Vector.<String>;
			var pack:String;
			for each (pack in data.getKeys())
				for each (var field:Field in data.getValue(pack).toArray())
					a.push((pack=='-' ? '' : pack+':') + field.name);
			return a;
		}
		
		public function resolveName(type:Multiname):Field
		{
			if (!type) return null;
			//TODO do we need to be able to clear all resolved at one point?
			/*if (type.resolved)
			{
				var tmp:Field = type.resolved;
				type.resolved = null;
				return tmp;
			}*/
			
			//if (type && type.imports)
			//	debug('look for ' + type.imports.toArray()+'::'+type.type + ' DB:'+dbName);
			
			var imports:HashMap = type.imports;
			
			if (!imports)
				imports = new HashMap;

			/*if (!imports.hasKey('.*'))
				imports.setValue('.*', '.*');*/
			

				var packMap:HashMap = data.getValue('top');
				if (packMap && packMap.hasKey(type.type))
				{
					//debug(type.type + ' resolved in ' + pack + ' DB:'+dbName);
					var res:Field = packMap.getValue(type.type);
					res.sourcePath = dbName;
					return res;
				}
			
			if (parentDB) 
				return parentDB.resolveName(type);
			return null;
		}
		
		/*public function merge(db:TypeDB):void
		{
			for each (var pack:String in db.data.getKeys())
			{
				var hm:HashMap = db.data.getValue(pack);
				for each (var clsName:String in hm.getKeys())
				{
					addDefinition(pack, hm.getValue(clsName));
				}
			}
		}*/
		
		
		/*public function get ser():Array
		{
			//debug('ser...');
			
			var dic:Dictionary = new Dictionary;
			var list:Array = [];
			function serField(fld:Field):int
			{
				//debug(fld.name);
				if (fld in dic) return dic[fld];
				
				var o:Object = {};
				dic[fld] = list.length;
				list.push(o);
				o.id = list.length-1;
				
				o.members = [];
				o.params = [];
				
				if (fld.parent)
					o.parent = serField(fld.parent);
					
				if (fld.type)
				{
					o.type = [fld.type.type];
					if (fld.type.imports)
						o.type = o.type.concat(fld.type.imports.toArray());
				}
				if (fld.extendz)
				{
					o.extendz = [fld.extendz.type];
					if (fld.extendz.imports)
						o.extendz = o.extendz.concat(fld.extendz.imports.toArray());
				}
					
				var f:Field;
				for each (f in fld.members.toArray())
					o.members.push(serField(f));
				for each (f in fld.params.toArray())
					o.params.push(serField(f));
				
				for each (var k:String in fieldLst)
					o[k] = fld[k];
					
				return o.id;	
			}
			
			
			var tList:Array = [];
			for each (var pack:String in data.getKeys())
			{
				var hm:HashMap = data.getValue(pack);
				for each (var clsName:String in hm.getKeys())
					tList.push([pack, serField(hm.getValue(clsName))]);
			}
			
			return [list, tList];			
		}*/
		
		static private var fieldLst:Array = ('pos,fieldType,name,access,' + 
				'hasRestParams,isGetter,defaultValue,isStatic').split(',');
		
		public function toByteArray():ByteArray
		{
			registerClassAlias('TypeDB', ClassDB);
			
			var ba:ByteArray = new ByteArray;
			ba.writeObject(this);
			return ba;
		}
		
		public function toString():String
		{
			//return data.toArray().join(',');
			return '[TypeDB '+dbName+']';
		}
	}
}