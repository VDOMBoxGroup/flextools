package ro.victordramba.util
{
	public class HashList extends HashMap
	{
		private var list:Array = [];

		override public function setValue(key:String, value:*):void
		{
			if (list.indexOf(key) == -1)
				list.push(key);
			super.setValue(key, value);
		}
		
		public function get length():int
		{
			return list.length;
		}

		override public function toArray():Array
		{
			var a:Array = [];
			var l:uint = list.length;
			for (var i:uint=0; i<l; i++)
				a.push(getValue(list[i]));
			return a;
		}
		
		override public function merge(hm:HashMap) : void
		{
			throw new Error('Not implemented');
		}
	}
}