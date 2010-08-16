package ro.victordramba.util
{
	
	

	public class HashMap
	{
		private static const o:Object = {};
		private var data:Object = {};
		private var data2:Object = {};
		
		public function setValue(key:String, value:*):void
		{
			if (key in o) data2['_'+key] = value;
			else data[key] = value;
		}

		public function getValue(key:String):*
		{
			return (key in o) ? data2['_'+key] : data[key];
		}

		public function hasKey(key:String):Boolean
		{
			return (key in o) ? (('_'+key) in data2) : (key in data);
		}

		public function toArray():Array
		{
			var a:Array = [];
			var item:*;
			for each (item in data)
				a.push(item);
			for each (item in data2)
				a.push(item);
			return a;
		}
		
		public function getKeys():Array/*of String*/
		{
			var a:Array = [];
			var item:String;
			for (item in data)
				a.push(item);
			for (item in data2)
				a.push(item);
			return a;
		}
		
		public function merge(hm:HashMap):void
		{
			var ret:HashMap = new HashMap;
			for each(var key:String in hm.getKeys())
				setValue(key, hm.getValue(key));
		}
	}
}